#pragma once
#include <fstream>
#include <string>

using namespace std;

template <typename T> class Set
{
public:
	
	virtual ~Set() {}

	virtual void add(T item) = 0; //Works for three test cases. Begins to slow down at 1,000,000. This is Big O(logn)
	virtual void remove(T item) = 0; //Works on two cases. Slows down at 500000. Might be larger than Big O(logn)
	virtual void clear() = 0; //Works for two cases. Exhibits Big O(n) behavior
	virtual bool find(T item) = 0; //Works for three test cases
	virtual void print(std::ofstream& file) = 0; //Need to implement
	virtual unsigned int get_size() = 0;
	virtual T get_root_data() = 0; 
	virtual void split() = 0;
	virtual void copy(Set<T>*& other) = 0;
	virtual T get_left_child(T item) = 0;
	virtual T get_right_child(T item) = 0;
	virtual int get_height(T item) = 0;
	virtual int get_size(T item)=0;
};