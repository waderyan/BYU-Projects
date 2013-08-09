#include "Student.h"

int Student::compareCount = 0;

Student::Student(string Nme, string ID, string Phonenum, string Address)
{
	name = Nme;
	id = ID;
	phone_num = Phonenum;
	address = Address;
}
Student::Student(string ID)
{
	id = ID;
}
string Student::getID() const
{
	return id;
}
bool Student::operator< (const Student& s) const
{
	compareCount++;
	return id < s.getID();
}
bool Student::operator> (const Student& s) const
{
	compareCount++;
	return id > s.getID();
}
bool Student::operator== (const Student& s) const
{
	compareCount++;
	return id == s.getID();
}
void Student::clearCount()
{
	compareCount = 0;
}
int Student::getCount() const
{
	return compareCount;
}
bool Student::operator< (string s) const
{
	compareCount++;
	return id < s;
}
bool Student::operator> (string s) const
{
	compareCount++;
	return id > s;
}
bool Student::operator== (string s) const
{
	compareCount++;
	return id == s;
}