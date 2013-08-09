#include <string.h>
#include <vector>             // stl vector
#include <stdlib.h>
#include <fcntl.h>
#include <stdio.h>
#include <string>
#include "SnellCode.h"
#include "Client.h"
#include <iostream>
#include <regex.h>

using namespace std;

string args[4];



bool isStringNumber(string s){
    for(int i = 0; i < s.length(); i++){
        if(!isdigit(s[i]))
            return false;
    }

    return true;
}

bool validateFourArgs(char** argv){
    
    for(int i = 0; i < 4; i++)
        args[i] = argv[i];
    
    if(args[1] == "-d" || args[2] == "-d" || args[3] == "-d")
        return false;

    if(!isStringNumber(argv[2]))
        return false;

    return true;
}

bool validateFiveArgs(char** argv){

    args[0] = argv[0];
    
    int i = 1;
    while(strcmp(argv[i],"-d")){
        i++;
        if(i > 4)
            return false;
    }
    
    if(i==1){
        args[1] = argv[2];
        args[2] = argv[3];
        args[3] = argv[4];
    }else if(i == 2){
        args[1] = argv[1];
        args[2] = argv[3];
        args[3] = argv[4];
    }else if(i == 3){
        args[1] = argv[1];
        args[2] = argv[2];
        args[3] = argv[4];
    }else{ // i == 4
        args[1] = argv[1];
        args[2] = argv[2];
        args[3] = argv[3];
    }

    if(!isStringNumber(args[2]))
        return false;
    
    return true;
}

bool validateArgs(int argc, char** argv){

    if(argc == 4)
      return validateFourArgs(argv);
    else if(argc == 5)
        return validateFiveArgs(argv);
    else
        return false;

}

int main(int argc, char **argv)
{
    if(!validateArgs(argc, argv)){
        printf("USAGE: [-d]? download <hostName> <portNum> <url>\n");
        exit(-1);
    }
    
    string host = args[1];
    int port = atoi(args[2].c_str());
    string url = args[3];
    bool debug = false;
    
    if(argc == 5)
        debug = true;
    
    Client client;
    client.download(host, port, url, debug);       
}


