#include <iostream>
#include "Set.h"
#include <string>
#include "Student.h"
#include "Command_HT.h"
#include "Hash_Table.h"
#include "List.h"

using std::string;

int main(int argc, char* argv[])
{
	/** List test cases:
	List<int> myVec;
	for(int i = 0; i < 10; i++)
	{
		myVec.push(i);
	}
	cout << "myVec contains: " << endl;
	for(int i = 0; i < myVec.size(); i++)
	{
		cout << myVec[i] << endl;
	}
	myVec.remove(5);
	cout << "myVec contains: " << endl;
	for(int i = 0; i < myVec.size(); i++)
	{
		cout << myVec[i] << endl;
	}
	myVec.remove(4);
	cout << "myVec contains: " << endl;
	for(int i = 0; i < myVec.size(); i++)
	{
		cout << myVec[i] << endl;
	}
	myVec.remove();
	cout << "myVec contains: " << endl;
	for(int i = 0; i < myVec.size(); i++)
	{
		cout << myVec[i] << endl;
	}
	**/
	//Large Test cases
	/**
	Set<int>* myIntSet = new AVL_Tree<int>();
	ofstream test("largetest.txt");
	for(int i = 0; i < 1000; i++)
	{
		myIntSet->add(i);
	}
	for(int i = 0; i < 500; i++)
	{
		myIntSet->remove(i);
	}
	myIntSet->print(test);
	myIntSet->clear();
	*/
	
	Command_HT IOmaster;
	if(argc == 3)
	{
		Set<std::string>* mySet = new Hash_Table<std::string>();
		IOmaster.load_commands(argv[1]);
		IOmaster.load_output(argv[2]);
		IOmaster.command_read(mySet);
		delete mySet;
	}
	else if(argc == 4)
	{
		Set<Student>* myStudents = new Hash_Table<Student>();
		Set<Student>* halfSet = new Hash_Table<Student>();
		Set<Student>* fourthSet = new Hash_Table<Student>();
		IOmaster.load_students(argv[1], myStudents,halfSet,fourthSet);
		IOmaster.load_queries(argv[2]);
		IOmaster.load_output(argv[3]);
		IOmaster.student_search(myStudents,halfSet,fourthSet);
		delete myStudents;
		delete halfSet;
		delete fourthSet;
	}
	else
	{
		return 1;
	}
	
	return 0;
}