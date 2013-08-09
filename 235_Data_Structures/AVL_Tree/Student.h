#pragma once
#include <iostream>
#include <string>
#include <ostream>

using std::string;
using std::ostream;

class Student
{
public:
	Student(string Nme, string ID, string Phonenum, string Address);
	Student(string ID);
	Student() {}; 
	~Student(){};
	
	bool operator<(string s) const;
	bool operator>(string s) const;
	bool operator==(string s) const;
	bool operator<(const Student& s) const;
	bool operator>(const Student& s) const;
	bool operator==(const Student& s) const;
	friend std::ostream& operator<<(ostream& os, const Student& stud);
	string getID() const;
	static int compareCount;
	void clearCount();
	int getCount() const;
	std::string get_name() const;

private:
	string name;
	string id;
	string phone_num;
	string address;
};