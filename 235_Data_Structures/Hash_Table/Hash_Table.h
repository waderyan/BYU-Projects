#pragma once
#include <iostream>
#include <stdexcept>
#include <stdio.h>
#include <stdlib.h>
#include "List.h"
#include "Student.h"

using namespace std;
//Global Hash Functions
/**--------------------------------------------------
string hashCode
----------------------------------------------------**/
int hashCode(const std::string& value, int size)
{
	int hashVal = 0;
	for(unsigned int i = 0; i < value.size(); i++)
	{
		hashVal = (hashVal*31 + value[i]);
	}
	unsigned int hashIndex = (unsigned int) hashVal;
	hashIndex %= size;

	return hashIndex;
}
/**--------------------------------------------------
Student hashCode
----------------------------------------------------**/
int hashCode(const Student& value, int size)
{
	int hashVal = atoi(value.getID().c_str()); //Converts string to int value
	hashVal %= size;
	return hashVal;
}
/**--------------------------------------------------
int hashCode
----------------------------------------------------**/
int hashCode(int& value, int size)
{
	return value%size;
}
/**--------------------------------------------------
Hash_Table: implements abstract class Set
Provides operations add,remove,find in O(1) time
----------------------------------------------------**/
template <typename T> class Hash_Table : public Set<T>
{
private:
	List<T>* table;
	int table_cap;
	int table_count;
	int array_count;
	/**--------------------------------------------------
		init - creates a new hash_table with capacity 
		starting at the given starting_cap
		@param int starting_cap
	----------------------------------------------------**/
	void init(int cap)
	{
		table_count = 0;
		table_cap = cap;
		array_count = 0;
		table = new List<T>[cap];
	}
	/**--------------------------------------------------
	rehash - creates a new table with each item rehashed 
	from the old table
	@param old_size
	@param new_size 
	Return new table that has been created	
	----------------------------------------------------**/
	List<T>* rehash(int old_size, int new_size)
	{
		List<T>* temp_table = new List<T>[new_size];
		for(int i = 0; i < old_size; i++)
		{
			//If table[i].size() == 0 do nothing
			if(table[i].size() == 1)
			{
				int index = hashCode(table[i][0],new_size);
				temp_table[index].push(table[i][0]);
			}	
			else if(table[i].size() > 1)
			{
				for(int j=0; j < table[i].size(); j++)
				{
					int index = hashCode(table[i][j],new_size);
					temp_table[index].push(table[i][j]);
				}
			}
		}
		return temp_table;
	}
	/**--------------------------------------------------
		rehash_smaller - creates a table half the size
	----------------------------------------------------**/
	void rehash_smaller()
	{
		int old_cap = table_cap;
		table_cap /= 2;
		if(table_cap == 0)
				table_cap = 1;
		List<T>* temp = rehash(old_cap,table_cap);
		delete [] table;
		table = temp;	
	}
	/**--------------------------------------------------
		rehash_larger - creates a table twice the size
	----------------------------------------------------**/
	void rehash_larger()
	{
		int old_cap = table_cap;
		table_cap = table_cap*2 +1;
		List<T>* temp = rehash(old_cap,table_cap);
		delete [] table;
		table = temp;
	}
public:
	/**--------------------------------------------------
		constructor- calls init function and sets initial 
		capacity at one
	----------------------------------------------------**/
	Hash_Table()
	{
		init(1);
	}
	/**--------------------------------------------------
		destructor- calls clear function
	----------------------------------------------------**/
	~Hash_Table()
	{
		for(int i = 0; i < table_cap; i++)
		{
			if(table[i].size() >= 1)
				table[i].clear();
		}
		delete [] table;
	}
	/**--------------------------------------------------
		add- adds an new item into the hash table if the item
		has not already been added
		@param item is the item to be added
		Algorithm:
		Use hash function to find the index of the bucket to add item
		Check if the item is a duplicate
			then don't add the item
		Check to see if the table is already full
			rehash_lareger
		Add the new item to the end of the list of items 
	----------------------------------------------------**/
	virtual void add(T item)
	{
		int test = hashCode(item,table_cap);
		if(table[test].size() != 0) //Check if there is a duplicate
		{
			for(int i = 0; i < table[test].size(); i++)
			{
				if(table[test][i] == item)
					return;
			}
		}
		if(table_count == table_cap) //Number of items in the table
		{
			rehash_larger();
		}
		int index = hashCode(item,table_cap);
		table[index].push(item);
		table_count++;
		//If this adds an item to a new place in the table then increment
		if(table[index].size() == 1)
			array_count++;
	}
	/**--------------------------------------------------
		remove - remove the given item from the table
		@param item - item to be removed
		Algorithm:
		Calculate the index
		Check to see if the item is present in the table
			if it is not then return doing nothing
		Remove the item; decrement table_count
		Check to see if removing the item caused the number of
		items in the table to be less than half the size of the
		hash table arra
			if this is true then rehash the table to a smaller size
	----------------------------------------------------**/
	virtual void remove(T item)
	{
		if(table_count<= 0)
			return;
		int index = hashCode(item,table_cap);
		bool present = false;
		int pos = 0;
		if(table[index].size() != 0) //Check if the item is there
		{
			for(int i = 0; i < table[index].size(); i++)
			{
				//Iterate through each part of the list
				if(table[index][i] == item)
				{
					pos = i;
					present = true;
				}
			}
			if(!present) //If the item was never found
				return;
		}
		else
		{
			return;
		}
		//Find the position of the string in the list
		table[index].remove(pos);
		table_count--;
		if(table[index].size() == 0)
		{
			array_count--;
		}
		//Is array_count less than half the size?
		if(table_count <= table_cap/2) //Number of items in the table
		{
			rehash_smaller();
		}

	}
	/**--------------------------------------------------
	clear - deletes all the items in the list
	Algorithm:
		Walk through each list pointer and clear the items in the list
		Delete the entire table
		Set table_cap = 1 and table_count = 0;
	----------------------------------------------------**/
	virtual void clear()
	{
		for(int i = 0; i < table_cap; i++)
		{
			if(table[i].size() >= 1)
				table[i].clear();
		}
		delete [] table;
		//Need to create something to continue adding into
		init(1);
	}
	/**--------------------------------------------------
	 find - searches for a specified item in the hash table
	 @param item is the item to search for
	 Returns true if found; false otherwise
	 Algorithm:
		Calculates the index of the item
		Checks to see if there are items in that index
			if not return false
		Checks to see if there are more than one item in that index
			if there is one check it - if that is the item return true
			otherwise return false
		If there are more than one than sequential search that list to find the item
			If it is found then return true if not then return false
	----------------------------------------------------**/
	virtual bool find(T item)
	{
		int first_element = 0;
		int index = hashCode(item,table_cap);
		if(table[index].size() == 0)
			return false;
		else if(table[index].size() == 1)
			if(table[index][first_element] == item)
				return true;
			else
				return false;
		else
		{
			for(int i = 0; i < table[index].size(); i++)
			{
				if(table[index][i] == item)
					return true;
			}
			return false;
		}
	}
	/**--------------------------------------------------
	print - traverses the hash table and prints each item
	according to their hash index
	@param file is the output file to write to
	Algorithm: 
		Iterate through the entire table
			Check to see if there is no items in that index
				Then output hash x:
			Check to see if there is one item in that index
				Then output hash x: item
			Check to see if there is more than one item
				Then output hash x: item1 item2 ...
	----------------------------------------------------**/
	virtual void print(std::ofstream& file)
	{
		//if there are no items then don't print anything
		int first_element = 0;
		if(table_count == 0)
			return;
		for(int i = 0; i < table_cap; i++)
		{
			if(table[i].size() == 0)
				file << "hash " << i << ":" << std::endl;
			else if(table[i].size() == 1)
				file << "hash " << i << ": " << table[i][first_element] << std::endl;
			else if(table[i].size() >1)
			{
				file << "hash " << i << ":";
				int print_count = 0;
				for(int j=0; j < table[i].size(); j++)
				{
					//Check to see if I have outputed more than eight one one line
					if(print_count == 8)
					{
						file << '\n' << "hash " << i << ":";
						print_count = 0;
					}
					 file << " " << table[i][j];
					 print_count++;

				}
				file << std::endl;
			}
		}
	}
	/**--------------------------------------------------
		get_size - returns the count of how many items are 
		in the hash table
	----------------------------------------------------**/
	virtual int get_size()
	{
		return table_count;
	}
	/**--------------------------------------------------
		get_root_data - returns the first item in the list
	----------------------------------------------------**/
	virtual T get_root_data()
	{
		T temp;
		if(table_count == 0)
			throw out_of_range("empty table");
		else
		{
			for(int i = 0; i < table_cap; i++)
			{
				if(table[i].size() == 0)
					continue;
				else
				{
					temp = table[i][0];
					break;
				}
			}
			return temp;
		}
	}
};
