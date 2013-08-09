#include <iostream>
#include "Parser.h"
#include "Datalog.h"
#include "Driver.h"

using namespace std;


int main(int args, char* argv[])
{
	Parser myPars; 
	Datalog myDatalog;
	Driver myDriver(argv[2]);

	myDatalog = myPars.runParser(argv[1]);
	myDriver.build_graph(myDatalog);
	myDriver.print_queries(myDatalog);
	
	return 0;
}