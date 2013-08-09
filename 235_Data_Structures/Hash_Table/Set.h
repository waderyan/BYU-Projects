#pragma once
#include <fstream>
#include <string>

using namespace std;

template <typename T> class Set
{
public:
	virtual ~Set() {}

	virtual void add(T item) = 0; 
	virtual void remove(T item) = 0; 
	virtual void clear() = 0; 
	virtual bool find(T item) = 0; 
	virtual void print(std::ofstream& file) = 0; 
	virtual int get_size() = 0;
	virtual T get_root_data() = 0;
};