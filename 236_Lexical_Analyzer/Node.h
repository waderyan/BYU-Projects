#pragma once
#include <iostream>
#include <string>
#include <set>

using namespace std;

class Node
{
private:
	set<string> myConnections;
	string myName;
	bool myVisited;
	int myPO_Num;
	string QorR;
	vector<string> predicates;
	bool been_printed;

public:
	Node() 
	{
		been_printed = false;
		myVisited = false;
		myPO_Num = 0;
	}

	void setName(string _name, string _QorR)
	{
		myName = _name;
		QorR = _QorR;
	}

	void setName(string _name, string _QorR, vector<string> _predicates)
	{
		myName = _name;
		QorR = _QorR;
		predicates = _predicates;
	}

	void setPO_Num(int _x)
	{
		myPO_Num = _x;
	}

	string getQorR()
	{
		return QorR;
	}

	string getName()
	{
		return myName;
	}

	vector<string> getPreds()
	{
		return predicates;
	}

	int getPO_Num()
	{
		return myPO_Num;
	}

	void addConnection(string _id)
	{
		myConnections.insert(_id);
	}

	set<string> getConnections()
	{
		return myConnections;
	}

	bool isVisited()
	{
		return myVisited;
	}

	void markVisited()
	{
		myVisited = true;
	}

	void unVisit()
	{
		myVisited = false;
	}

	void markPrinted()
	{
		been_printed = true;
	}

	bool isPrinted()
	{
		return been_printed;
	}
};