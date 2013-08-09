#pragma once
#include "Parameter.h"
#include <string>
#include <fstream>
#include <vector>

using namespace std;

class Predicate
{
private:
	string myID;
	vector<Parameter> myList;
public:
	Predicate() {}

	void setID(string p)
	{
		myID = p;
	}

	void addList(vector<Parameter> _param)
	{
		for(unsigned int i = 0; i < _param.size(); i++)
		{
			myList.push_back(_param[i]);
		}
	}

	vector<string> getListAsString()
	{
		vector<string> temp;
		for(unsigned int i = 0; i < myList.size(); i++)
		{
			temp.push_back(myList[i].getAsString());
		}
		return temp;
	}

	void clear()
	{
		myID.clear();
		myList.clear();
	}

	void clearList()
	{
		myList.clear();
	}

	string getID() const
	{
		return myID;
	}

	string toString()
	{
		string temp = myID;
		temp += "(";
		for(unsigned int i = 0 ; i < myList.size(); i++)
		{
			temp += myList[i].toString();
			if((i+1) < myList.size())
				temp += ",";
		}
		temp += ")";
		return temp;		
	}

	vector<Parameter> getList()
	{
		return myList;
	}

	int getListSize()
	{
		return myList.size();
	}

};