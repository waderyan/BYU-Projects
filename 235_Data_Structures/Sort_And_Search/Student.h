#pragma once
#include <iostream>
#include <vector>
#include <string>

using namespace std;

class Student
{
public:
	Student(string Nme, string ID, string Phonenum, string Address);
	Student(string ID);
	~Student(){};
	
	bool operator<(string s) const;
	bool operator>(string s) const;
	bool operator==(string s) const;
	bool operator<(const Student& s) const;
	bool operator>(const Student& s) const;
	bool operator==(const Student& s) const;
	string getID() const;
	static int compareCount;
	void clearCount();
	int getCount() const;

private:
	string name;
	string id;
	string phone_num;
	string address;
};
