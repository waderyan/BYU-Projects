#pragma once
#include "Predicate.h"
#include <vector>
#include <string>

using std::vector;
using std::string;

class Rule
{
private:
	Predicate myHead;
	vector<Predicate> myList;

public:
	Rule(Predicate phead)
	{
		myHead = phead;
	}

	void addPred(Predicate p)
	{
		myList.push_back(p);
	}

	void addList(vector<Predicate> _pred)
	{
		for(unsigned int i = 0; i < _pred.size(); i++)
		{
			myList.push_back(_pred[i]);
		}
	}

	void clear()
	{
		myHead.clear();
		myList.clear();
	}

	string toString()
	{
		string temp = myHead.toString();
		temp += " :- ";
		for(unsigned int i = 0; i < myList.size(); i++)
		{
			temp += myList[i].toString();
			if((i+1) < myList.size())
				temp += ",";
		}
		return temp;
	}

	string getHeadName()
	{
		return myHead.getID();
	}

	vector<Predicate> getList()
	{
		return myList;
	}

	vector<string> getListStrings()
	{
		vector<string> temp;
		for(unsigned int i = 0; i < myList.size(); i++)
		{
			temp.push_back(myList[i].getID());
		}
		return temp;
	}

	Predicate getHead()
	{
		return myHead;
	}
	
};