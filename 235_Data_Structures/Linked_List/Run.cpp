#include <iostream>
#include "Stack.h"
#include "Queue.h"
#include "LinkedList.h"
#include "CommandIO.h"
#include <string>
#include <fstream>

int main(int argc, char* argv[])
{
	CommandIO report;
	vector<std::string> commands;
	if(argc == 3)
	{
		std::ifstream comfile;
		comfile.open(argv[1]);
		report.load_commands(comfile);
		report.load_output(argv[2]);
		Stack<std::string>* myStack = new LinkedList<std::string>();
		Queue<std::string>* myQueue = new LinkedList<std::string>();
		commands = report.get_commands();
		for(unsigned int i = 0; i < commands.size(); i++)
		{
			report.read_commands(commands[i],myStack,myQueue);
		}
		delete myStack;
		delete myQueue;
	}

	
	return 0;
}