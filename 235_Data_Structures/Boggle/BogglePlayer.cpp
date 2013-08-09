#include "BogglePlayer.h"


BogglePlayer::BogglePlayer(ifstream& dictfile, ifstream& bogfile)
{
	buildDictionary(dictfile);
	int size = determineDim(bogfile);
	dimension = dim_size(size);
	buildBoard();
	traveledReset();
}
/**
	Searches the dictionary set to see if a word is in it
	@param set 
	@param word
	Returns true if the word is in the set
	Returns false if the word is not in the set
*/
bool BogglePlayer::checkDict(string word)
{
	set<string>::iterator it;
	if((it = dictionary.find(word)) != dictionary.end())
		return true;
	else
		return false;
}
/**
	Processes a dictionary file.
	pre: one word per line
	post: each word is lowercase
*/
void BogglePlayer::buildDictionary(ifstream& file)
{
	vector<string> temp;
	string word;
	while(getline(file, word))
	{
		temp.push_back(word);
	}
	for(size_t i = 0; i < temp.size(); i++)
	{
		transform(temp[i].begin(),temp[i].end(),temp[i].begin(),::tolower);
	}
	dictionary.insert(temp.begin(),temp.end());
}
/**
	BoggleBoard is textfile with a list of strings seperated by white space.
	Each string gives the letter(s) for one of the tiles on the Boggle board.
	pre: number of strings will always be a perfect square (9,16,25)
	pre: will work for strings of any length
*/
void BogglePlayer::buildBoard()
{
	vector<string> rows;
	size_t k = 0;
	for(size_t j = 0; j < dimension; j++)
	{
		for(size_t i = 0; i < dimension; i++)
		{
			rows.push_back(bogBoardTemp[k]);
			k++;
		}
		board.push_back(rows);
		rows.clear();
	}
}
/**
	Resets the boolean values of the board to false.
*/
void BogglePlayer::traveledReset()
{
	bogBool.clear();
	vector<bool> boolrows(dimension,false);
	size_t l = 0;
	for(size_t j = 0; j < dimension; j++)
	{
		bogBool.push_back(boolrows);
	}
}
/**
	Outputs to a file a list of words found in Boggle. One word per line
	post: each word must be found in the dictionary
	post: must be at least 4 letters (check in compareWords function); 
	post: be in sorted order; lower case; output the same word only once
*/
void BogglePlayer::writeOutput(ofstream& file)
{
	set<string>::iterator it;
	for(it = bogWords.begin(); it != bogWords.end(); it++)
	{
		file << *it << endl;
	}
	file.close();
}
/**
	Checks the set using lower bound function to determine if a given prefix
	is in the set. This will save time during the boggle game
	pre: prefix must be lowercased
	Returns true if the prefix is in the set
	Returns false if the prefix is not in the set
*/
bool BogglePlayer::checkPrefix(string prefix)
{
	string followingPrefix = prefix;
	//This changes the prefix to be one about what it was before Ex. thr -> ths
	followingPrefix[followingPrefix.length()-1]++; 
	/*
		This compares the lower_bound iterator to see if it is equal to the next lower_bound iterator
		:lower_bound function for sets returns an iterator to the first element in the set that
		does not compare less than prefix
	*/
	if(dictionary.lower_bound(prefix) != dictionary.lower_bound(followingPrefix)) 
	{
		//This means that there is a word between these two prefixes
		return true;
	}
	else
	{
		//This means there is no word from the prefix
		return false;
	}
}
/**
	Calculate the size of the rows and columns
	Will be called repeatedly in boggle game
	@param the size of the boggle board
	Return the size of the rows and columns (dimension)
*/
int BogglePlayer::dim_size(int size)
{
	double dim = sqrt(double(size));
	return (int) dim;
}
/**
	Determines the size of the boggle board by reading in the file and counting how many words there are
*/
int BogglePlayer::determineDim(ifstream& file)
{
	string word;
	while(file >> word)
	{
		bogBoardTemp.push_back(word);
	}
	for(size_t i = 0; i < bogBoardTemp.size(); i++)
	{
		transform(bogBoardTemp[i].begin(),bogBoardTemp[i].end(),bogBoardTemp[i].begin(),::tolower);
	}
	return bogBoardTemp.size();
}
/**
	Returns the dimension of the board
*/
int BogglePlayer::getDimension() const
{
	return dimension;
}
/**
	Plays the game of boggle. Recursive algorithm
*/
void BogglePlayer::playBoggle(int x, int y, string word)
{
	if(x < 0 || y < 0 || x >= dimension || y >= dimension) //Am I on the board?
		return;
	else if(bogBool[x][y] == true) //Have I been here before?
		return;
	else
		word += board[x][y];
	if(!checkPrefix(word)) //Is the prefix in the dict?
		return;
	else 
		bogBool[x][y] = true;
	if(checkDict(word))//Is string in the dictionary?
	{	
		if(word.size() >= 4)//Is the word big enough?
		{
			bogWords.insert(word); //Stored in a set to take account for multiple words
		}
	}	
	playBoggle((x+1),y,word); 
	playBoggle((x-1),y,word);
	playBoggle(x,(y+1),word);
	playBoggle(x,(y-1),word);
	playBoggle((x+1),(y+1),word);
	playBoggle((x-1),(y-1),word);
	playBoggle((x+1),(y-1),word);
	playBoggle((x-1),(y+1),word);
	bogBool[x][y] = false;
	return;
}
