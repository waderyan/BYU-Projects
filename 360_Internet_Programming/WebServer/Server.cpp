#include "SnellCode.h"
#include "SephaQueue.h"
#include "SocketIO.h"

//STL
#include <iostream>
#include <stdio.h>
#include <cstring>
#include <cstdlib>
#include <string>
#include <iostream>
#include <fstream>

//BSD Socket API
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <unistd.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>


//Threads
#include <pthread.h>

//Semaphores
#include <semaphore.h>

#define BUFFER_SIZE 100
#define SOCKET_ERROR -1
#define QUEUE_SIZE 5
#define MAXHOSTNAME 256

using namespace std;

bool done;
SephaQueue myQ;

struct needle{
	SephaQueue* q;

};

void * handleConn(void* arg){
	
	needle* myNeedle = (needle*)arg;
	SephaQueue* myQ = myNeedle->q;
	

	while(true){

		int skt = myQ->pop();
		cout << "Thread is handling connection\n";
		
		ReadAndWriteSocket(skt);
		
		sleep(2);
		if(close(skt) == SOCKET_ERROR)
			cout << "Error closing the socket!\n";

	}
}

int exitFailure(string msg);
bool validateArgs(int argc, char** argv);
int setListening(int portNum, sockaddr_in addr, int addressSize);

int main(int argc, char** argv){

	if(!validateArgs(argc,argv)){
		cout << "specify a port number" << endl;
		return 0;
	}

	done = false;


	int portNum = atoi(argv[1]);
	int listenSkt;
	char pBuffer[BUFFER_SIZE];

	int threadPoolSize = 10;
	int connectionSize = 1000;

	myQ.init(connectionSize);
	struct sockaddr_in addr;
	int addressSize = sizeof(struct sockaddr_in);

	pthread_t threads[threadPoolSize];

	//Create thread pool
	for(int i = 0; i < threadPoolSize; i++){

		needle* temp = new needle();
		temp->q = &myQ;

		pthread_create(&threads[i], NULL, handleConn, temp);
	}
	
	
	if((listenSkt = setListening(portNum,addr,addressSize)) == SOCKET_ERROR){
		exitFailure("Error getting listening socket!");
		return 0;
	}

	
	while(!done){
	
		int skt = accept(listenSkt, (struct sockaddr*) &addr, (socklen_t*)&addressSize);

		int optval = 1;
   		setsockopt(listenSkt,SOL_SOCKET,SO_LINGER,&optval,sizeof(optval));
		cout << "got a connection\n";

		myQ.push(skt);

	}
}

int exitFailure(string msg){
	cout << msg << endl;
	return SOCKET_ERROR;
}

int setListening(int portNum, sockaddr_in addr, int addressSize){

  int serverSktHandle = SOCKET_ERROR;

  struct hostent* hostInfo; 	//Holds info about machine
  char sysHost[MAXHOSTNAME +1];   
  int hostPort = portNum;
	       
  // Clear structure memory
  bzero(&addr,sizeof(sockaddr_in));

  //Get Info of Machine we are on
  gethostname(sysHost, MAXHOSTNAME);
  if((hostInfo = gethostbyname(sysHost)) == NULL)
    	return exitFailure("ERROR: System hostname misconfigured");


   if((serverSktHandle = socket(AF_INET,SOCK_STREAM,IPPROTO_TCP)) == SOCKET_ERROR)
	  return exitFailure("ERROR: Establsihing socket");

   addr.sin_addr.s_addr = htonl(INADDR_ANY);
   addr.sin_port = htons(hostPort);
   addr.sin_family = AF_INET;


   if(bind(serverSktHandle,(struct sockaddr*)&addr,sizeof(addr)) == SOCKET_ERROR)
   	return exitFailure("ERROR: binding server to socket!");

   getsockname(serverSktHandle, (struct sockaddr*) &addr, (socklen_t*)addressSize);
   printf("opened socket as fd (%d) on port (%d) for stream i/o\n",serverSktHandle,ntohs(addr.sin_port));

   if(listen(serverSktHandle,QUEUE_SIZE) == SOCKET_ERROR)
   	return exitFailure("ERROR: establishing a listening queue!");
   	
   int optval = 1;
   setsockopt(serverSktHandle,SOL_SOCKET,SO_REUSEADDR,&optval,sizeof(optval));

   return serverSktHandle;
}

bool validateArgs(int argc, char** argv){
	if(argc < 2){
		return false;
	}

	return true;
}

