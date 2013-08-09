#include "Parser.h"

using namespace std;

int main(int args, char* argv[])
{
	Parser myPars;
	myPars.runParser(argv[1], argv[2]);
	
	return 0;
}