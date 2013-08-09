#pragma once
#include <string>
#include <vector>

using namespace std;
//List of attribute values :public vector<string>
class Tuple
{
private:
	vector<string> myAttValues;	
public:
	Tuple() {}

	Tuple(vector<string> _vec)
	{
		setAttValues(_vec);
	}

	void setAttValues(vector<string> _vec)
	{
		for(unsigned int i = 0; i < _vec.size(); i++)
		{
			myAttValues.push_back(_vec[i]);
		}
	}	

	void setAttValues(vector<string> _vec1, vector<string> _vec2)
	{
		myAttValues.insert(myAttValues.begin(),_vec1.begin(),_vec1.end());
		myAttValues.insert(myAttValues.end(),_vec2.begin(),_vec2.end());
	}

	void setAttValues(string _new)
	{
		myAttValues.push_back(_new);
	}

	vector<string> getAttValues() const
	{
		return myAttValues;
	}

	bool operator< (const Tuple& t) const;
	bool operator> (const Tuple& t) const;
	bool operator==(const Tuple& t) const;
};

bool Tuple::operator< (const Tuple& t) const
{
	return myAttValues < t.getAttValues();
}

bool Tuple::operator> (const Tuple& t) const
{
	return myAttValues > t.getAttValues();
}

bool Tuple::operator== (const Tuple& t) const
{
	return myAttValues == t.getAttValues();
}
