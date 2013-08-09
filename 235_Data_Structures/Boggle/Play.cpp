#include <iostream>
#include <istream>
#include <fstream>
#include <set>
#include <vector>
#include <string>
#include <list>
#include <algorithm>
#include <sstream>
#include "BogglePlayer.h"

using namespace std;

int main(int argc, char* argv[])
{
	if(argc == 4)
	{
		ifstream dictfile; dictfile.open(argv[1]); 
		ifstream bogfile; bogfile.open(argv[2]);
		ofstream outfile; outfile.open(argv[3]);	
		BogglePlayer playtime(dictfile,bogfile);
		string word;
		for(int x_pos = 0; x_pos < playtime.getDimension(); x_pos++)
		{
			for(int y_pos = 0; y_pos < playtime.getDimension(); y_pos++)
			{
				playtime.playBoggle(x_pos,y_pos,word);
				playtime.traveledReset();
				word.clear();
			}
		}
		playtime.writeOutput(outfile);
	}
	return 0;
}


