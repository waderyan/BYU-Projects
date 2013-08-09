#pragma once
#include <vector>
#include <string>

using namespace std;
//Scheme is a list of attribute names
class Scheme
{
private:
	vector<string> myAttNames;
public:
	void setAttNames(vector<string> _vector)
	{
		for(unsigned int i = 0; i < _vector.size(); i++)
		{
			myAttNames.push_back(_vector[i]);
		}
	}

	void setAttNames(vector<string> _vec1, vector<string> _vec2)
	{
		myAttNames.insert(myAttNames.begin(),_vec1.begin(),_vec1.end());
		myAttNames.insert(myAttNames.end(),_vec2.begin(),_vec2.end());
	}

	void setAttNames(string _new)
	{
		myAttNames.push_back(_new);
	}

	void setAttNames(set<string> _set)
	{
		myAttNames.insert(myAttNames.begin(),_set.begin(),_set.end());
	}

	void clearNames()
	{
		myAttNames.clear();
	}

	vector<string> getAttNames()
	{
		return myAttNames;
	}

	string toString()
	{
		string temp = "";
		for(unsigned int i = 0; i < myAttNames.size(); i++)
		{
			temp += myAttNames[i];
		}
		return temp;
	}
};