
#pragma once

template <typename T> class Stack
{
public:
	
	virtual ~Stack() {}
  
	virtual int size() = 0;
	virtual void clear() = 0;
	virtual void push(T item) = 0;
	virtual T pop() = 0;
	virtual T top() = 0;
 
};