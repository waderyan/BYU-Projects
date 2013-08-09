#pragma once
#include <string>
#include <set>
#include "Tuple.h"
#include "Scheme.h"
#include "Predicate.h"

using namespace std;

/** Stores a name, scheme, and collection of tuples.
	Has relational operations: select, project, rename.
	Must use a a set to hold the collection of tuples
**/
class Relation
{
private:
	string myName;
	Scheme myScheme;
	set<Tuple> myTuples;
	//Helper function for Join operation
	Scheme combineVecs(vector<string> _vec1, vector<string> _vec2, vector<pair<int,int> > _cols)
	{
		Scheme s;
		s.setAttNames(_vec1);

		vector<int> tempV;
		for(unsigned int i = 0; i < _cols.size(); i++)
			tempV.push_back(_cols[i].second);

		set<int> temp(tempV.begin(),tempV.end());
		for(unsigned int i = 0; i < _vec2.size(); i++)
		{
			if(!temp.count(i))
				s.setAttNames(_vec2[i]);	
		}
		return s;
	}

	Scheme combineSchemes(Relation _r1, Relation _r2, vector<pair<int,int> > _cols)
	{
		Scheme tempScheme;
		vector<string> vec1(_r1.getScheme().getAttNames());
		vector<string> vec2(_r2.getScheme().getAttNames());

		if(!_cols.empty())
			tempScheme = combineVecs(vec1,vec2,_cols);
		else 
			tempScheme.setAttNames(vec1,vec2); //Cartesian product
		return tempScheme;
	}

	bool testTuples(Tuple _t1, Tuple _t2, vector<pair<int,int> > _cols)
	{
		//Start with true because of _cols is empty then we still return true
		bool result = true;
		for(unsigned int i = 0; i < _cols.size(); i++)
		{
			if(_t1.getAttValues().size() > _cols[i].first && _t2.getAttValues().size() > _cols[i].second)
			{
				if(!(_t1.getAttValues()[_cols[i].first] == _t2.getAttValues()[_cols[i].second]))
					result = false;
			}
		}
		return result;
	}

	Tuple joinVecs(vector<string> _vec1, vector<string> _vec2, vector<pair<int,int> > _cols)
	{
		Tuple t;
		t.setAttValues(_vec1);

		vector<int> tempV;
		for(unsigned int i = 0; i < _cols.size(); i++)
			tempV.push_back(_cols[i].second);

		set<int> temp(tempV.begin(),tempV.end());

		for(unsigned int i = 0; i < _vec2.size(); i++)
		{
			if(!temp.count(i))
				t.setAttValues(_vec2[i]);	
		}
		return t;
	}

	Tuple joinTuples(Tuple _t1, Tuple _t2, vector<pair<int,int> > _sameCols)
	{
		Tuple t;
		if(!_sameCols.empty())
			t = joinVecs(_t1.getAttValues(),_t2.getAttValues(),_sameCols);
		else 
			t.setAttValues(_t1.getAttValues(),_t2.getAttValues());
		return t;
	}

	vector<pair<int,int> > detCommonCol(Relation _r1, Relation _r2)
	{
		//Determine which columns are the same
		vector<pair<int,int> > columns;
		for(unsigned int i = 0; i < _r1.getScheme().getAttNames().size(); i++)
		{
			for(unsigned int j = 0; j < _r2.getScheme().getAttNames().size(); j++)
			{
				if(_r1.getScheme().getAttNames()[i] == _r2.getScheme().getAttNames()[j])
					columns.push_back(make_pair(i,j));
			}
		}
		return columns;
	}
public:
	Relation() {}

	Relation(Scheme _scheme)
	{
		myScheme = _scheme;
	}

	Relation(Predicate _predicate)
	{
		init(_predicate);
	}

	//This predicate comes from a Scheme
	void init(Predicate _predicate)
	{
		myName = _predicate.getID();
		myScheme.setAttNames(_predicate.getListAsString());
	}

	//This predicate comes from a fact
	void addTuples(Predicate _predicate)
	{
		Tuple temp;
		temp.setAttValues(_predicate.getListAsString());
		myTuples.insert(temp);
	}

	void addTuples(vector<Tuple> _tuples)
	{
		myTuples.insert(_tuples.begin(),_tuples.end());
	}

	void addTuples(set<Tuple> _tuples)
	{
		myTuples.insert(_tuples.begin(),_tuples.end());
	}

	void addTuple(Tuple _tuple)
	{
		myTuples.insert(_tuple);
	}

	Scheme getScheme()
	{
		return myScheme;
	}
	
	void setName(string _name)
	{
		myName = _name;
	}

	string getName()
	{
		return myName;
	}

	set<Tuple> getTuples()
	{
		return myTuples;
	}
	//Relational operations
	Relation select(int _position, string _value)
	{
		Relation result;
		vector<Tuple> temp;
		set<Tuple>::iterator it;

		for(it = myTuples.begin(); it != myTuples.end(); ++it)
		{
			if(it->getAttValues().size() > _position)
			{
				if(it->getAttValues()[_position] == _value)
				{
					temp.push_back(*it);
				}
			}
			else
				cout << "Error in select" << endl;
		}
		result.addTuples(temp);
		return result;
	}

	Relation project(vector<int> _positions)
	{
		//Need to change P,N,Q,C,G to C,N
		//Should be project({3,1})
		Relation result;
		vector<string> tempVec;
		set<Tuple> tempSet;
		set<Tuple>::iterator it;

		for(it = myTuples.begin(); it != myTuples.end(); ++it)
		{
			for(unsigned int i = 0; i < _positions.size(); i++)
			{
				//If it doesn't exceed the bounds
				if((_positions[i]) < it->getAttValues().size())
					tempVec.push_back(it->getAttValues()[_positions[i]]);
				else
					cout << "Error in project" << endl;
			}

			Tuple tempTuple;
			tempTuple.setAttValues(tempVec);
			tempSet.insert(tempTuple);
			tempVec.clear();
		}
		result.addTuples(tempSet);
		return result;
	}

	void rename(vector<string> _name)
	{
		myScheme.clearNames();
		myScheme.setAttNames(_name);
	}

	/** Join two relations that have no common attribute names
		(result is a Cartesian product), join two relations that 
		have multiople common attribute names
	**/
	Relation Join(Relation _r1, Relation _r2)
	{
		//snap + csg = SnAPcG
		vector<pair<int,int> > columns = detCommonCol(_r1,_r2);
		Scheme s = combineSchemes(_r1,_r2,columns);
		Relation tempR(s);

		set<Tuple>::iterator it1;
		set<Tuple>::iterator it2;
		set<Tuple> set1(_r1.getTuples());
		set<Tuple> set2(_r2.getTuples());

		for(it1 = set1.begin(); it1 != set1.end(); ++it1)
		{
			for(it2 = set2.begin(); it2 != set2.end(); ++it2)
			{
				if(testTuples(*it1,*it2,columns))
					tempR.addTuple(joinTuples(*it1,*it2,columns));
			}
		}
		return tempR;
	}

	Relation Join(vector<Relation> _relations)
	{	
		Relation tempR;
		if(!_relations.empty())
			tempR = _relations[0];
		for(unsigned int i = 1; i < _relations.size(); i++)
		{
			tempR = tempR.Join(tempR,_relations[i]);
		}
		return tempR;
	}

	Relation Union(Relation _r1, Relation _r2)
	{
		Relation unioned(_r1.getScheme());
		unioned.setName(_r2.getName());
		unioned.addTuples(_r1.getTuples());
		unioned.addTuples(_r2.getTuples());
		return unioned;
	}

	void print(ofstream& _output)
	{
		if(myTuples.empty())
		{
			_output << "No" << endl;
			return;
		}
		else
		{
			_output << "Yes(" << myTuples.size() << ")" << endl;
			set<Tuple>::iterator it;
			
			for(it = myTuples.begin(); it != myTuples.end(); ++it)
			{
				if(myScheme.getAttNames().size() != 0)
					_output << "  ";
				for(unsigned int i = 0; i < myScheme.getAttNames().size(); i++)
				{
					if(it->getAttValues().size() > i)
						_output << myScheme.getAttNames()[i] << "='" << it->getAttValues()[i] << "'";
					else
						cout << "Error in print" << endl;
					if((i+1) == myScheme.getAttNames().size())
						_output << endl;
					else
						_output << ", ";
				}	
			}
		}
	}
	
};