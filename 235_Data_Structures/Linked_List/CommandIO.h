#pragma once
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include "LinkedList.h"
#include "Stack.h"
#include "Queue.h"


using namespace std;

class CommandIO
{
private:
	std::vector<std::string> commands;
	std::ofstream output;
public:
	/**
		Constructor: void
	*/
	CommandIO() {};
	/**
		load_commands: reads in file with commands
		pre: each command is given on one line
		@param file is input stream file
		Return: modifies commands vector
	*/
	void load_commands(std::ifstream& file)
	{
		string line;
		if(file.is_open())
		{
			while(getline(file,line))
			{
				commands.push_back(line);
			}
		}
	}
	void load_output(char * output_file)
	{
		output.open(output_file);
	}
	/**
		get_commands: user access to commands vector
		Return: vector of commands
	*/
	std::vector<std::string> get_commands() const
	{
		return commands;
	}
/**
	read_commands: reads each command and calls the right function
	@param string commmand
	@param Stack<string>*  pointer to a linked list with stack implementation
	@param Queue<string>* pointer to a linkedlist with queue implementation
*/
void read_commands(string command, Stack<string>* myStack, Queue<string>* myQueue)
{
	if(command == "clear stack")
	{
		myStack->clear();
		output << command << endl;
	}
	else if(command == "clear queue")
	{
		myQueue->clear();
		output << command << endl;
	}
	else if(command == "top")
	{
		string temp = myStack->top();
		output << command << " " <<  temp << endl;
	}
	else if(command == "pop")
	{
		try
		{
			string temp = myStack->pop();
			output << command << " " << temp << endl;
		}
		catch(out_of_range ex)
		{
			output << command << "[empty]" << endl;
		}
	}
	else if(command == "dequeue")
	{
		try
		{
			string temp = myQueue->dequeue();
			output << command << " " << temp << endl;
		}
		catch(out_of_range ex)
		{
			output << command << "[empty]" << endl;
		}
	}
	else if(command == "peek")
	{
		try
		{
			string temp = myQueue->peek();
			output << command << " " << temp << endl;
		}
		catch(out_of_range ex)
		{
			output << command << "[empty]" << endl;
		}
	}
	else if(command == "size queue")
	{
		int temp = myQueue->size();	
		output << command << " " << temp << endl;
	}
	else if(command == "size stack")
	{
		int temp = myStack->size();	
		output << command << " " << temp << endl;	
	}
	else 
	{
		if(command[0] == 'p') //push
		{
			int j = 0;
			for(size_t i = 0; i < command.size(); i++)
			{
				if(isspace(command[i]))
				{
					j = i+1;
				}
			}
			string temp = command.substr(j,command.size()-1);
			myStack->push(temp);
			output << command << endl;
		}
		else if(command[0] = 'e') //enqueue
		{
			int j = 0;
			for(size_t i = 0; i < command.size(); i++)
			{
				if(isspace(command[i]))
				{
					j = i+1;
				}
			}
			string temp = command.substr(j,command.size()-1);
			myQueue->enqueue(temp);
			output << command << endl;
		}
	}
}
	/**
		Destructor: void
	*/
	~CommandIO() {};

};

