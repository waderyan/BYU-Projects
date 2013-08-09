
#pragma once

template <typename T> class Queue
{
  
public:

	virtual ~Queue() {}
  
	virtual int size() = 0;
	virtual void clear() = 0;
	virtual void enqueue(T item) = 0;
	virtual T dequeue() = 0;
	virtual T peek() = 0;
 
};