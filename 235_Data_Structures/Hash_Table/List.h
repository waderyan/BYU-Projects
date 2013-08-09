#pragma once
#include <exception>
#include <stdexcept>

template <typename T> class List
{
/**---------------------------------------------------
	List class
	Purposes - Store items in an array
	Resize the array when it gets close to the capacity
	Access any element in the list
	Add new items
	Clear all the items
	Size of the array list
----------------------------------------------------**/
private:
	T* storage;
	int num_items;
	int capacity;	
	/**-----------------------------------------------
		reallocate - resizes the storage area
		@param new size
	-------------------------------------------------**/
	void reallocate(int size)
	{
		T* temp = new T[size]; //Creates a new storage location with the new size
		for(int i = 0; i < num_items; i++) //Copies all the items form the old list to the new space
		{
			temp[i] = storage[i];
		}
		delete [] storage; //Deletes the old space
		storage = temp; //Assigns the old space to the new space
		capacity = size; //Resets the capacity
	}
	/**-----------------------------------------------
		construct - helper function for the constructor
		seperate so that it can be called when the items are cleared
	-------------------------------------------------**/
	void construct(int starting_cap) 
	{
		capacity = starting_cap; //Set starting capacity
		num_items = 0; //Have an emtpy list
		storage = new T[capacity]; //Allocate space according to the capacity
	}
public:
	/**-----------------------------------------------
		constructor - calls helper function construct
		creates a new MyList
	-------------------------------------------------**/
	List()
	{
		construct(1);
	}
	/**-----------------------------------------------
		size - returns the size of the MyList
	-------------------------------------------------**/
	int size() const
	{
		return num_items;
	}
	/**-----------------------------------------------
		push - adds an item to the MyList
	-------------------------------------------------**/
	void push(T item)
	{
		if(num_items == capacity) //Check to see if the num_items is equal to the capacity
			reallocate(capacity*2); //If it is then reallocate
		storage[num_items++] = item; //Add the item to the num_items position, then increment the number of items
	}
	/**-----------------------------------------------
		clear - deletes the memory space for MyList
		creates a new MyList with capacity one
	-------------------------------------------------**/
	void clear()
	{
		delete [] storage; //Deletes memory space
		construct(1); //Constructs List of size one
	}
	/**-----------------------------------------------
		operator[] - returns the item in the position given
		throws an exception if we are outside of range
	-------------------------------------------------**/
	T& operator[](int position)
	{
		return storage[position];
	}
	/**-----------------------------------------------
		destructor - deletes the memory space allocated for
		the MyList
	-------------------------------------------------**/
	~List()
	{
		delete [] storage; //Deletes memory space
	}
	/**------------------------------------------
		remove - removes a specified item from the list
		@ param int index for the item that is to be removed
	--------------------------------------------*/
	T remove(int index)
	{
		if(index < 0 || index >= num_items)
		{
			throw out_of_range("index out of range");
		}
		T item = storage[index];
		while(index < num_items-1)
		{
			storage[index] = storage[index+1];
			index++;
		}
		storage[index] = item;
		return remove();
	}
	/**------------------------------------------
		remove - pops off the last item from the list
	--------------------------------------------*/
	T remove()
	{
		if(num_items == 0)
		{
			throw out_of_range("empty list");
		}
		T item = storage[num_items-1];
		num_items--;
		if(num_items < capacity/2)
		{
			reallocate(capacity/2);
		}
		return item;
	}
};