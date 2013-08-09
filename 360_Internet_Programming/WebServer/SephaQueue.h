#ifndef WebClient_SephaQueue
#define WebClient_SephaQueue

#include <semaphore.h>

#include <queue>

using namespace std;

class SephaQueue{

private:

	sem_t nfull, nempty, mutex;
	queue<int> buffer;

public:

	SephaQueue(){

	}

	SephaQueue(int size){
		init(size);
	}

	void init(int size){

		int pshared = 0; //zero means semaphore is shared between threads
		sem_init(&nfull, pshared, 0);
		sem_init(&nempty, pshared, size);
		sem_init(&mutex, pshared, 1);
	}

	void push(int skt){

		cout << "Pushing queue\n";

		sem_wait(&nempty);
		sem_wait(&mutex);
		
		buffer.push(skt);
		
		sem_post(&mutex);
		sem_post(&nfull);

		cout << "Finished pushing my queue\n";
	}

	int pop(){

		sem_wait(&nfull);

		sem_wait(&mutex);

		int lastElement = buffer.front();
		buffer.pop();

		sem_post(&mutex);
		sem_post(&nempty);

		return lastElement;
	}

	~SephaQueue(){
		sem_close(&nfull);
		sem_close(&nempty);
		sem_close(&mutex);
	}

};

#endif
