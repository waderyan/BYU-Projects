#pragma once
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include "Student.h"
#include "Set.h"
#include "Vector.h"
#include "AVL_Tree.h"
#include <vector>

using std::string;
using std::vector;
/**
	Command AVL performs the Input/Output of commands
*/
class CommandAVL
{
private:
	Vector<std::string> commands;
	Vector<Student> queries;
	vector<Student> students_vec;
	std::ofstream output;
	std::ifstream query;
	std::ifstream input;
	std::ifstream studentFile;
	/**------------------------------------------------------------------
		set_query- makes three vectors of 1/4,1/2, and full size of the original vector
		@param half list
		@param fourth list
		Returns changed half and changed fourth
	----------------------------------------------------------------------*/
	void set_query(Vector<Student>& half_Q, Vector<Student>& fourth_Q)
	{
		for(unsigned int i = 0; i < (queries.size()/2); i++)
		{
			half_Q.push(queries[i]); //Creates a query with half of the original
		}
		for(unsigned int i = 0; i < (queries.size()/4); i++)
		{
			fourth_Q.push(queries[i]); //Creates a query with a fourth of the original
		}
	}
	/**
		write_search - Writes comparison counter to the output stream divided by the query size
		clears the comparsion counter
	*/
	void write_search(Set<Student>*& myStudents, Vector<Student>& query)
	{
		if(myStudents->get_size() !=0) //Protects against access of an empty student Set
		{
			//Outputs in the correct format
			output << "size: " << myStudents->get_size() << "\tcompares: " << 
				(myStudents->get_root_data().getCount()/query.size()) << std::endl;
			myStudents->get_root_data().clearCount();
		}
	}
	/**------------------------------------------------------------------
		find_students - iterates through the query data structure and finds the query in
		the list of students
	-------------------------------------------------------------------**/
	void find_students(Set<Student>*& myStudents, Vector<Student>& query)
	{
		for(unsigned int i = 0; i < query.size(); i++)
		{
			myStudents->find(query[i]);
		}
	}
	
public:
	/**
		Constructor: void
	*/
	CommandAVL() {};
	/**
		Loads the student file
	*/
	void load_students(char * student_file, Set<Student>* mySet, Set<Student>* halfSet, Set<Student>* fourthSet)
	{
		string line = "";
		string id; string name; string address; string phone_num;
		studentFile.open(student_file);
		int i = 1;
		while (getline(studentFile, line))
		{
			if(i == 1)
			{
				id = line;
			}
			else if(i == 2)
			{
				name = line;
			}
			else if(i == 3)
			{
				address = line;
			}
			else if(i == 4)
			{
				phone_num = line;
				students_vec.push_back(Student(name,id,phone_num,address));
				i = 0;
			}
			i++;
		}
		for(unsigned int i = 0; i < students_vec.size(); i++)
		{
			mySet->add(students_vec[i]);
		}
		for(unsigned int i = 0; i < students_vec.size()/2; i++)
		{
			halfSet->add(students_vec[i]);
		}
		for(unsigned int i = 0; i < students_vec.size()/4; i++)
		{
			fourthSet->add(students_vec[i]);
		}

	}
	/**
		Loads the query file
	*/
	void load_queries(char * query_file)
	{
		query.open(query_file);
		std::string line = "";
		if(query.is_open())
		{
			while(std::getline(query,line))
			{
				queries.push(line);
			}
		}
	}
	/**
		load_commands: reads in file with commands
		pre: each command is given on one line
		@param file is input stream file from command line
		Return: modifies commands vector
	*/
	void load_commands(char* input_file)
	{
		input.open(input_file);
		std::string line;
		if(input.is_open())
		{
			while(getline(input,line))
			{
				commands.push(line);
			}
		}
	}
	/**
		loads the output file from the command line
		@param argv[] value
	*/
	void load_output(char * output_file)
	{
		output.open(output_file);
	}
	/**
		Iterates through each command
		@param mySet is a set -AVL style
	*/
	void command_read(Set<std::string>* mySet)
	{
		for(unsigned int i = 0; i < commands.size(); i++)
		{
			//Iterates through each command
			read_command(commands[i],mySet);
		}
	}
	/**
		read_commands: reads each command and calls the right function
		@param string commmand
	*/
	void read_command(std::string command, Set<string>* mySet) 
	{
		if(command == "clear") //clear function
		{
			try
			{
				mySet->clear(); //set clear function
			}
			catch(...) //Catch if it hasn't been implemented yet
			{
				std::cout << "clear not implemented yet" << std::endl;
			}
			output << command << std::endl;
		}
		else if(command[0] == 'a') //add
		{
			unsigned int j = 0;
			for(size_t i = 0; i < command.size(); i++) //Parses the string
			{
				if(isspace(command[i])) //Looking for the spot after the space
				{
					j = i+1;
				}
			}
			string temp = command.substr(j,command.size()-1); //temp is the item to add
			try
			{
				mySet->add(temp); //Calls the add function
			}
			catch(...) //Catch if not implemented
			{
				std::cout << "add not implemented yet" << std::endl;
			}
			output << command << std::endl; //prints the result
		}
		else if(command[0] == 'r' && command[1] == 'e') //remove
		{
			unsigned int j = 0;
			for(size_t i = 0; i < command.size(); i++) //Parse the string to get the item after the space
			{
				if(isspace(command[i])) //Looking for the spot after the space
				{
					j = i+1;
				}
			}
			string temp = command.substr(j,command.size()-1); //This is the item to remove set to a string
			try
			{
				mySet->remove(temp);
			}
			catch(...) //Catch if not implemented yet
			{
				std::cout << "remove not implemented yet" << std::endl;
			}
			output << command << std::endl; //Output the result of the command
		}
		else if(command[0] == 'f') //find
		{
			unsigned int j = 0;
			for(size_t i = 0; i < command.size(); i++) //Parse the string to find the value to search for
			{
				if(isspace(command[i]))
				{
					j = i+1;
				}
			}
			string temp = command.substr(j,command.size()-1); //Set the parsed string to the value to search for
			bool result = mySet->find(temp); //Store the result of the find operation in a boolean
			output << command << " " << std::boolalpha << result << std::endl; //Boolalpha converts result into a string "true" or "false"
		}
		else if(command[0] == 'r' && command[1] == 'o') //Root
		{
			string temp = mySet->get_root_data();
			output << command << " " << temp << endl;
		}
		else if(command[0] == 'r'&& command[1] == 'i') //Right
		{
			unsigned int j = 0;
			for(size_t i = 0; i < command.size(); i++) //Parse the string to find the value to search for
			{
				if(isspace(command[i]))
				{
					j = i+1;
				}
			}
			string temp = command.substr(j,command.size()-1); //Set the parsed string to the value to search for
			try
			{
				string temper = mySet->get_right_child(temp);
				output << command << " " << temper << endl;
			}
			catch(...)
			{
				output << command << " -" << endl;
			}
		}
		else if(command[0] == 'l') //Left
		{
			unsigned int j = 0;
			for(size_t i = 0; i < command.size(); i++) //Parse the string to find the value to search for
			{
				if(isspace(command[i]))
				{
					j = i+1;
				}
			}
			string temp = command.substr(j,command.size()-1); //Set the parsed string to the value to search for
			try
			{
				string temper = mySet->get_left_child(temp);
				output << command << " " << temper << endl;
			}
			catch(...)
			{
				output << command << " -" << endl;
			}
		}
		else if(command[0] == 'h') //Height
		{
			unsigned int j = 0;
			for(size_t i = 0; i < command.size(); i++) //Parse the string to find the value to search for
			{
				if(isspace(command[i]))
				{
					j = i+1;
				}
			}
			string temp = command.substr(j,command.size()-1); //Set the parsed string to the value to search for
			int height = mySet->get_height(temp);
			output << command << " " << height << endl;
		}
		else if(command[0] == 's') //size
		{
			output << command << " " << mySet->get_size() << endl;
		}
		else //print
		{
			output << command << std::endl;
			mySet->print(output);
		}
	}
	/**-------------------------------------------------------------
		student_search - counts the number of times that students are 
		compared while searching for a vector of queries
	--------------------------------------------------------------**/
	void student_search(Set<Student>* myStudents, Set<Student>* halfSet, Set<Student>* fourthSet)
	{
		Vector<Student> half_list; Vector<Student> fourth_list; //Create thre seperate lists
		set_query(half_list,fourth_list); //Run into a function to split them up
		
		output << "AVL Tree Set Find" << std::endl; //Print title
		myStudents->get_root_data().clearCount(); //Start with counter at zero
		find_students(fourthSet,fourth_list); //Find from one fourth
		write_search(fourthSet,fourth_list); //Write the results of one fourth
		find_students(halfSet, half_list); //Find from one hal
		write_search(halfSet,half_list); //Write the results of one half
		find_students(myStudents, queries); //Find from the entire query
		write_search(myStudents,queries); //Write results of entire query
		
	}

	/**
		Destructor: void
	*/
	~CommandAVL() {};

};