#pragma once
#include <string>

using namespace std;

class Parameter
{
private:
	string myString; 
	string myID; 
public:
	Parameter() {}

	void setString(string p)
	{
		myString = p;
		myID = "";
	}

	void setID(string p)
	{
		myID = p;
		myString = "";
	}

	string toString()
	{
		if(myString == "")
		{
			return myID;
		}
		else
		{
			string temp = "'";
			temp += myString;
			temp += "'";
			return temp;
		}
	}

	string getAsString()
	{
		if(myString == "")
		{
			return myID;
		}
		else
		{
			return myString;
		}
	}

	bool isID()
	{
		if(myID != "")
			return true;
		else
			return false;
	}
};