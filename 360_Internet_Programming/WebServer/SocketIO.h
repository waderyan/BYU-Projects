#ifndef WebClient_SocketIO_h
#define WebClient_SocketIO_h

#include <sstream>
#include <fstream>
#include <cstring>
#include <string.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stddef.h>
#include <stdlib.h>
#include <sys/sendfile.h>
#include <netinet/in.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>

#define HTTP_OK 200
#define HTTP_FILENOTFOUND 404
#define HTTP_SERVER_ERROR 500

bool debug;
string docRoot;

enum HTTP_STATUS{
    OK, FILE_NOT_FOUND, SERVER_ERROR, DIRECTORY
};

enum Content_type{
    HTML, TXT, JPG, GIF, NA
};

enum Request_type{
    GET, CGI
};

string GetFile(string line){

    int firstspace = 0;
    int secondspace = 0;

    for(int i = 0; i < line.size(); i++){
        if(line[i] == ' '){
            if(firstspace == 0)
                firstspace= i;
            else
                secondspace = i;
        }
    }

    return line.substr(firstspace+2,secondspace-(firstspace+2));

}

string createHeaders(HTTP_STATUS status, Content_type contentType, int contentLength){
  
    debug = true;

    string response = "";
    string content = "";

    if(status == OK)
        response = "HTTP/1.0 200 OK";
    else if(status == FILE_NOT_FOUND)
        response = "HTTP/1.1 404 NOT FOUND";
    else if(status == SERVER_ERROR)
        response = "HTTP/1.1 500 Server error";

    if(contentType == HTML)
        content = "Content-Type: text/html";
    else if(contentType == TXT)
        content = "Content-Type: text/plain";
    else if(contentType == JPG)
        content = "Content-Type: image/jpg";
    else if(contentType == GIF)
        content = "Content-Type: image/gif";
    else
        content = "Content-Type: ";

    std::ostringstream oss;
    oss << contentLength;

    return response + "\n\r" + content + "\n\rContent-Length: "+ oss.str() + "\n\r\n\r";
}

string printDirectoryListing(string directory){

    const int BUFFER_SIZE = 1024;

    char html[BUFFER_SIZE] = "<HTML>\n<HEAD>\n<TITLE>DirectoryListing</TITLE>\n</HEAD>";
    strcpy(html,"<BODY BGCOLOR=#FFFFFF TEXT=#000000>");
    strcat(html,"<p>\n<H2>Listing for ");
    strcat(html,directory.c_str());
    strcat(html," </H2>\n<p>\n");
    strcat(html,"<ol>\n");

    DIR* dir;
    struct dirent *ent;

    if((dir = opendir(directory.c_str())) != NULL){
        while((ent = readdir(dir)) != NULL){
            strcat(html,"<li> <a href= ");
            strcat(html,ent->d_name);
            strcat(html,">");
            strcat(html,+ ent->d_name);
            strcat(html,"</a>");
        }
    }else
        cout << "Error creating directory listing\n";

    closedir(dir);
    strcat(html,"</ol>\n</BODY>\n</HTML>");

    return html;
}

bool hasIndexHtml(string directory){

    string newLocation = directory + "/index.html";
    ifstream ifile(newLocation.c_str());
    return ifile;
}

bool fileExists(string file){
    ifstream ifile(file.c_str());
    return ifile;
}

Content_type getContentType(string file){

    Content_type fileType;

    int fileSize = file.length();
    string type = file.substr(fileSize-3,3);

    cout << "File type test: " << type << endl;


    if(type == "txt")
        fileType = TXT;
    else if(type == "tml")
        fileType = HTML;
    else if(type == "peg")
        fileType = JPG;
    else if(type == "gif")
        fileType = GIF;
    else
        fileType = NA;

    return fileType;
}

vector<string> getTokens(int skt){

    vector<char*> headerLines;
    GetHeaderLines(headerLines,skt,false);

    vector<string> tokens;

    char *ptr;
    char *token;
    char *cp;
    const char delimiters[] = " /";

    cp = strdupa(headerLines[0]); //Makes a writable copy

    cout << "header lines [0] " << headerLines[0] << endl;

    token = strtok_r(cp,delimiters,&ptr); //Token == GET
    tokens.push_back(token);

    cout << "token: " << token << endl;
    token = strtok_r(NULL,delimiters,&ptr); //Token == file path
    tokens.push_back(token);

    cout << "token: " << token << endl;

    return tokens;
}

Request_type parseHeaderTokens(vector<string> tokens, string &file){

    file = tokens[1];
    string request = tokens[0];
    Request_type type;

    if(request == "GET")
        type = GET;

    return type;
}

bool isDirectory(string fileName){
    struct stat filestat;
    stat(fileName.c_str(),&filestat);
    return S_ISDIR(filestat.st_mode);
}

string failureStatus(){
    return "HTTP/1.1 404 File Not Found";
}

string readFile(string fileName){

    std::ifstream myfile (fileName.c_str());
    string response = "";

    string line;
    if(myfile.is_open()){
        while(myfile.good()){
            getline(myfile,line);
            response = response + line + "\n";
        }
    }

    return response;
}

string createResponse(string fileName, string &header){

    HTTP_STATUS status = OK;
    Content_type type;
    int content_size = 0;

    string content = "";

    if(!fileExists(fileName))
        return failureStatus();

    if(isDirectory(fileName)){

        if(hasIndexHtml(fileName))
            fileName += "/index.html";
        else{
            content = printDirectoryListing(fileName);
            header = createHeaders(status,HTML,content.length());

            return header + content;
        }
    }

    content = readFile(fileName);
    content_size = content.length();
    type = getContentType(fileName);
    header = createHeaders(status,type,content_size);

    return header + content;
}

void MessageResponse(int skt, int status,string type,string length){

    string header = "HTTP/1.1 200 OK\n\rContent-Type: " + type + "\n\rContent-Length: " + length + "\n\r";
    char buffer[MAX_MSG_SZ];

    strcpy(buffer,header.c_str());
    write(skt, buffer, strlen(buffer)+1);
}

void ReadAndWriteSocket(int skt){

    docRoot = "/users/guest/s/slammers/Developer/CS360/WebServer/";
    //Parse Header
    vector<string> tokens = getTokens(skt);
    string fileName = "";
    Request_type request = parseHeaderTokens(tokens, fileName);
    
    fileName = docRoot + fileName;
    cout << fileName << endl;

    string header = "";

    string response = createResponse(fileName, header);
    

    if(response.length() < MAX_MSG_SZ){
        char buffer[MAX_MSG_SZ];

        cout << "Less than" << endl;
         cout << "length: " << response.length() << endl;

        strcpy(buffer, response.c_str());
        int bytes = write(skt,buffer,strlen(buffer)); 
        cout << "bytes sent: " << bytes << endl;
    }
    else{
        
        char buffer[MAX_MSG_SZ];
        strcpy(buffer, header.c_str());
        int headerBytes = write(skt,buffer,header.length());

        printf("\n=======================================\n");
        printf("RESPONSE HEADER:\n");
        printf(header.c_str());
        printf("=========================================\n\n");

        int fd = open(fileName.c_str(),O_RDONLY);

        struct stat stat_buf;
        fstat(fd,&stat_buf);

        while((rval = read(fd,buffer,MAX_MSG_SZ)) > 0)
            write(skt,buffer,rval);
    }
}


#endif

/**
struct stat stat_buf; 
        cout << "FileName to be opened and sent: " << fileName << endl;

        int fd = open(fileName.c_str(), O_RDONLY);
        if(fd == -1){
            fprintf(stderr, "unable to open '%s': %s\n", fileName.c_str(), strerror(errno));
            exit(1);
        }

        //get size of the file to be sent
        fstat(fd, &stat_buf);
        off_t offset = 0;
        int rc = sendfile(skt,fd,&offset,stat_buf.st_size);

        if (rc == -1) {
          fprintf(stderr, "error from sendfile: %s\n", strerror(errno));
          exit(1);
        }

        cout << "bytes sent " << rc << endl;
        if (rc != stat_buf.st_size) {
          fprintf(stderr, "incomplete transfer from sendfile: %d of %d bytes\n",
                  rc,
                  (int)stat_buf.st_size);
          exit(1);
        }

        // close descriptor for file that was sent 
        close(fd);   

        */

//MessageResponse(skt,200,"image/gif","100000");


/**
        ifstream file(fileName.c_str(),ios::binary);
        char buffer[100000];
        file.read(buffer,1000000);
        write(skt,buffer,1000000);

*/

  /**       
        char buffer[100000];

        strcpy(buffer, response.c_str());
        int bytes = write(skt,buffer,response.length()+1); 
        cout << "bytes sent: " << bytes << endl;

        */

        /**
         for(int i = 0; i< response.length(); i++){
            string tmp = response.substr(i,1);

            unsigned char* buffer = (unsigned char*) tmp.c_str();

            int bytes = write(skt,buffer,1);

            cout << "substring length: " << tmp.length() << endl;
            cout << "bytes sent: " << bytes << endl;
        }

        */