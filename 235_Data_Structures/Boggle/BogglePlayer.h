#pragma once
#include <iostream>
#include <istream>
#include <fstream>
#include <set>
#include <vector>
#include <string>
#include <list>
#include <algorithm>
#include <sstream>

using namespace std;

class BogglePlayer
{
public:
	BogglePlayer(ifstream& file, ifstream& file2);
	~BogglePlayer() {};
	
	/**
		Outputs to a file a list of words found in Boggle. One word per line
		post: each word must be found in the dictionary
		post: must be at least 4 letters (check in compareWords function); 
		post: be in sorted order; lower case; output the same word only once
	*/
	void writeOutput(ofstream& file);
	/**
		Plays the game of boggle. Recursive algorithm
	*/
	void BogglePlayer::playBoggle(int x, int y, string word);
	/**
		Resets the boolean values of the board to false.
	*/
	void BogglePlayer::traveledReset();
	/**
		Returns the dimension of the board
	*/
	int getDimension() const;
	
private:
	set<string> dictionary;
	vector<vector<string> > board;
	vector<vector<bool> > bogBool;
	set<string> bogWords;
	list<string> outWords;
	vector<string> bogBoardTemp;
	int dimension;

	/**
		Processes a dictionary file.
		pre: one word per line
		post: each word is lowercase
	*/
	void buildDictionary(ifstream& file);
	/**
		BoggleBoard is textfile with a list of strings seperated by white space.
		Each string gives the letter(s) for one of the tiles on the Boggle board.
		pre: number of strings will always be a perfect square (9,16,25)
		pre: will work for strings of any length
	*/
	void buildBoard();
	/**
		Determines the size of the boggle board by reading in the file and counting how many words there are
	*/
	int determineDim(ifstream& file);
	/**
		Checks the set using lower bound function to determine if a given prefix
		is in the set. This will save time during the boggle game
		pre: prefix must be lowercased
		Returns true if the prefix is in the set
		Returns false if the prefix is not in the set
	*/
	bool checkPrefix(string prefix);
	/**
		Searches the dictionary set to see if a word is in it
		@param set 
		@param word
		Returns true if the word is in the set
		Returns false if the word is not in the set
	*/
	bool checkDict(string word);
	/**
		Calculate the size of the rows and columns
		Will be called repeatedly in boggle game
		@param the size of the boggle board
		Return the size of the rows and columns (dimension)
	*/
	int BogglePlayer::dim_size(int size);
	
};

