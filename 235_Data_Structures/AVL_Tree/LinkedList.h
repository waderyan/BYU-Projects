#pragma once
#include "Queue.h"
#include <iostream>
#include <exception>
#include <stdexcept>

using namespace std;

template <typename T> 
class LinkedList : public Queue<T>
{
private:
	//Structure of a double node
	struct DNode
	{
		DNode(T& new_data, DNode* prev_val = NULL, DNode* next_val = NULL) : data(new_data), next(next_val), prev(prev_val) {};
		T data;
		DNode* next;
		DNode* prev;	
	};
	//Points to the first element in the list
	DNode* beginpoint;
	//Points to the last element in the list
	DNode* endpoint;
	//Total number of items in the list
	int numItems;

public:
	/**---------------------------------------------
		Constructor: builds empty list
	---------------------------------------------*/
	LinkedList()
	{
		beginpoint = NULL;
		endpoint = NULL;
		numItems = 0;
	}
	/**---------------------------------------------
		Destructor: 
	---------------------------------------------*/
	~LinkedList()
	{
		clear();
	}
//Shared Methods
	/**---------------------------------------------
		Clear: gets rid off all items in list
	---------------------------------------------*/
	virtual void clear();
	/**---------------------------------------------
		Size: counts the number of items in list
	---------------------------------------------*/
	virtual int size();
//Queue Methods
	/**---------------------------------------------
		Enqueue: places item on the back of the list
	---------------------------------------------*/
	virtual void enqueue(T item);
	/**---------------------------------------------
		Dequeue: removes item from the front of the list
	---------------------------------------------*/
	virtual T dequeue();
	/**---------------------------------------------
		Peek: looks at item at the end of the queue
		Returns the item at the end of the queue
	---------------------------------------------*/
	virtual T peek();
};

//Shared Methods
/**---------------------------------------------
	Clear: gets rid off all items in list
---------------------------------------------*/
template <class T> 
void LinkedList<T>::clear()
{
	while(numItems != 0) //Iterates until head equals NULL (which means we are at the end of the list
	{
		DNode* node = beginpoint; //Create a DNode pointing to the head
		beginpoint = beginpoint->next; //Move head to point to the next position
		delete node; //Delete the node
		numItems--;
	}
	endpoint = NULL; //Set the last pointer (tail) to NULL
}
/**---------------------------------------------
	Size: counts the number of items in list
---------------------------------------------*/
template <class T> 
int LinkedList<T>::size() 
{
	return numItems; //Returns the number of items
}
//Queue Methods
/**---------------------------------------------
	Enqueue: places item on the back of the list
	@param item to be added to the list
---------------------------------------------*/
template<class T>
void LinkedList<T>::enqueue(T item)
{
	if(numItems != 0) //If it is not empty
	{
		endpoint->next = new DNode(item,endpoint,NULL); //Move the endpointer to point at the new Node
		endpoint = endpoint->next; //Move the endpointer to the new node's endpointer
		numItems++; //Increment the number of items
	}
	else //If this is the first item in the list
	{
		beginpoint = new DNode(item,NULL,beginpoint); //Make a new DNode pointing to Null for next and begin for previous data field
		endpoint = beginpoint; //Set end to point to the newly allocated DNode
		numItems++; //Increment the number of items
	}
}
/**---------------------------------------------
	Dequeue: removes item from the front of the list
---------------------------------------------*/
template <class T> 
T LinkedList<T>::dequeue()
{
	T temp; 
	if(numItems == 0) //Checks to see if there are any items in the list
	{
		throw out_of_range("deqeue [empty]"); //Throws an exception if it is empty
	}
	else
	{
		DNode* removed_node = beginpoint; //Creates a node pointing to the first node
		temp = beginpoint->data; //Stores the data in a temp variable to return at the end
		beginpoint = beginpoint->next; //moves the first node pointer to looking at the second node
		delete removed_node; //Deletes the node 
	}
	if(beginpoint != NULL) //Checks to see if the begin pointer is looking at null
	{
		beginpoint->prev = NULL; //If it is not then it points the begin pointer prev looking at NULL
	}
	else
	{
		endpoint = NULL; //Else it has the last pointer looking at NULL
	}
	--numItems; //Decrements the number of items
	return temp; //Returns the data pointed to by the deleted node in the front of the list
}
/**---------------------------------------------
	Peek: looks at item at the front of the queue
	Returns the item at the front of the queue
---------------------------------------------*/
template <class T> 
T LinkedList<T>::peek()
{
	if(numItems == 0) //Checks to see if there are any items in the list
	{
		throw out_of_range("peek [empty]"); //If there are no items than throw an exception
	}
	else
	{
		return beginpoint->data; //Grabs the data from the front node
	}
}
