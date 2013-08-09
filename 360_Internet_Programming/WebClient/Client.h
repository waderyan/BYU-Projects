//
//  Downloader.h
//  WebClient
//
//  Created by Wade Anderson on 1/9/13.
//  Copyright (c) 2013 Brigham Young University. All rights reserved.
//

#ifndef WebClient_Downloader_h
#define WebClient_Downloader_h

//Socket API libraries
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <unistd.h>
#include <errno.h>
#include <iostream>

#define MAX_BUFF 512;

using namespace std;

class Client{
  
public:
    
    Client(){
        
    }
    
    void download(string serverHostName, int port, string url, bool debug){
        int skt;
        struct sockaddr_in addr;
        
        if((skt = socket(AF_INET,SOCK_STREAM,IPPROTO_TCP)) < 0){
            cout << "ERROR: establishing socket!" << endl;
            close(skt);
            exit(EXIT_FAILURE);
        }
        
        memset(&addr,0,sizeof(sockaddr_in));
        
        addr.sin_family = AF_INET;
        addr.sin_port = htons((u_short) port);
        
        struct hostent *host;

        if((host= gethostbyname(serverHostName.c_str())) == NULL){
            cout << "ERROR: Loading IP Address from DNS" << endl;
            close(skt);
            exit(EXIT_FAILURE);
        }
        
        memcpy((char*)&addr.sin_addr, host->h_addr_list[0], host->h_length);
        
        if(connect(skt, (sockaddr*)&addr, sizeof(addr)) < 0){
            cout << "ERROR: Could not connect with port. no connection established.\nBad port!" << endl;
            close(skt);
            exit(EXIT_FAILURE);
        }
        
        string snd = "GET " + url + " HTTP/1.0\r\nHost: " + serverHostName + "\r\n\r\n";
        send(skt,snd.c_str(),strlen(snd.c_str()),0);
        
        if(debug){
            printf("\n=======================\n");
            printf("HTTP REQUEST SENT TO SERVER\n");
            printf("=======================\n");
            cout << snd << endl;
        }

        vector<char *> headerLines;
        char buffer[MAX_MSG_SZ];
        char contentType[MAX_MSG_SZ];
        
        char* statusLine = GetLine(skt);
        if(debug){
            printf("\n=======================\n");
            printf("STATUS LINE RECIEVED FROM SERVER\n");
            printf("=======================\n");
            cout << statusLine << endl << endl;
            printf("\n=======================\n");
            printf("HEADERS RECIEVED FROM SERVER\n");
            printf("=======================\n\n");
        }

        GetHeaderLines(headerLines,skt,false);
        
        
       for (int i = 0; i < headerLines.size(); i++) {
		if(debug)
                	printf("[%d] %s\n",i,headerLines[i]);
                if(strstr(headerLines[i], "Content-Type")) 
                    sscanf(headerLines[i], "Content-Type: %s", contentType);
        }
        
        printf("\n=======================\n");
        printf("Headers are finished, now read the file\n");
        printf("Content Type is %s\n",contentType);
        printf("=======================\n");
        
        int rval;
        while((rval = read(skt,buffer,MAX_MSG_SZ))){
            write(1,buffer,rval);
        }
        
        
        close(skt);
    }
    
    ~Client(){
       
    }

    
};

//        char recieved[5000];
//        int rc = recv(skt,recieved,5000,0);
//        recieved[rc] = (char) NULL;  // Null terminate the string
//        
//        cout << "Number of bytes read: " << rc << endl;
//        cout << "Recieved: " << recieved << endl;

#endif


