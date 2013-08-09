
#ifndef WEBSERVER_SERVER
#define WEBSERVER_SERVER

//Socket API libraries
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <unistd.h>
#include <errno.h>
#include <iostream>
#include <stdio.h>
#include <sstream>
#include <cstring>
#include <cstdlib>
#include <string>
#include <fstream>
#include <pthread.h>

#include "SephaQueue.h"
#include "SnellCode.h"

#define BUFFER_SIZE 100
#define SOCKET_ERROR -1
#define QUEUE_SIZE 5
#define MAXHOSTNAME 256

#define HTTP_OK 200
#define HTTP_FILENOTFOUND 404
#define HTTP_SERVER_ERROR 500


using namespace std;

class Server{
private:
	int serverSktHandle; 
    bool debug;

    enum HTTP_STATUS{
        OK, FILE_NOT_FOUND, SERVER_ERROR
    };

    enum Content_type{
        HTML, TXT, JPG, GIF
    };

	void exitFailure(string msg){
		cout << msg << endl;
		close(serverSktHandle);
		exit(EXIT_FAILURE);
	}

    string formatHeaders(HTTP_STATUS status, Content_type contentType, int contentLength){
        string response = "";
        string content = "";

        if(status == OK)
            response = "HTTP/1.1 200 OK";
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

        std::ostringstream oss;
        oss << contentLength;

        return response + "\n\r" + content + "\n\rContent-Length: "+ oss.str() + "\n\r\n\r";

    }

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

public:


    void* HandleConnection(void* ptr){

        int newSkt = (int *) ptr;

        //IO
        vector<char *> headerLines;
        char buffer[MAX_MSG_SZ];
        char contentType[MAX_MSG_SZ];

        GetHeaderLines(headerLines,newSkt,false);
    
        
        for (int i = 0; i < headerLines.size(); i++) {
            if(debug)
                    printf("[%d] %s\n",i,headerLines[i]);
                if(strstr(headerLines[i], "Content-Type")) 
                    sscanf(headerLines[i], "Content-Type: %s", contentType);
        }

        string file = GetFile(headerLines[0]);

        cout << "File Name: " << file << endl;

        string responseHeader = formatHeaders(OK,TXT,1000);
        strcpy(buffer,responseHeader.c_str());

        ifstream myFile (file.c_str());

        string result = "";
        string line = "";
        if(myFile.is_open()){
            while(myFile.good()){
                getline(myFile,line);
                result += (line + "\n");
            }
            myFile.close();
        }

        strcat(buffer,result.c_str());    

        write(newSkt,buffer,strlen(buffer)+1);

    }

	Server(){
        debug = true;

    }

    ~Server(){}

	void start(int portNum){


    	//Handles the socket
    	struct hostent* hostInfo; 	//Holds info about machine
        struct sockaddr_in addr; 	//Internet socket address
    	char sysHost[MAXHOSTNAME +1];   

        char pBuffer[BUFFER_SIZE];
        int hostPort = portNum;
        int addressSize = sizeof(struct sockaddr_in);
            
    	// Clear structure memory
    	bzero(&addr,sizeof(sockaddr_in));

    	//Get Info of Machine we are on
    	gethostname(sysHost, MAXHOSTNAME);
    	if((hostInfo = gethostbyname(sysHost)) == NULL){
    		cout << "ERROR: System hostname misconfigured" << endl;
    		exit(EXIT_FAILURE);
    	}

        // Establish socket
        if((serverSktHandle = socket(AF_INET,SOCK_STREAM,IPPROTO_TCP)) == SOCKET_ERROR)
            exitFailure("ERROR: Establsihing socket");

        // Fill in addr struct
        addr.sin_addr.s_addr = htonl(INADDR_ANY);
        addr.sin_port = htons(hostPort);
        addr.sin_family = AF_INET;

        // Bind to a port
        if(bind(serverSktHandle,(struct sockaddr*)&addr,sizeof(addr)) == SOCKET_ERROR)
        	exitFailure("ERROR: binding server to socket!");

        // Get Port Number
        getsockname(serverSktHandle, (struct sockaddr*) &addr, (socklen_t*)addressSize);
        printf("opened socket as fd (%d) on port (%d) for stream i/o\n",serverSktHandle,ntohs(addr.sin_port));

        // Establish a listening queue
        if(listen(serverSktHandle,QUEUE_SIZE) == SOCKET_ERROR)
        	exitFailure("ERROR: establishing a listening queue!");


        pthread_attr_t *thread_def = NULL;

        Threader *arg;
        bool done = false;
        pthread_t thread1, thread2;
        int thread1result, thread2result;

        // Listen
        while(!done){
        	printf("\nWaiting for connection ...\n");

        	// Get the connected socket
        	int newSkt = accept(serverSktHandle, (struct sockaddr*) &addr, (socklen_t*)&addressSize);
        	printf("\nGot a connection\n");

            int* skt = &newSkt;

            //Fire off thread to do communication    
            pthread_create(&thread1,thread_def,HandleConnection, (void*) skt);       

            pthread_join(thread1,(void*)&thread1result);
            printf("End thread1 with %d\n",thread1result);

        	printf("\nClosing the socket");
        	if(close(newSkt) == SOCKET_ERROR)
        		exitFailure("ERROR: Could not close socket\n");
        }
	}



};

#endif
