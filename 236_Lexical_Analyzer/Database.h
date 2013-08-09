#pragma once
#include <map>
#include <string>
#include "Relation.h"
#include "Datalog.h"

using namespace std;
/**
	Database stores the collection of relations
	Using a map because then I can search using the name as the key
**/
class Database
{
private:
	map<string,Relation> myRelations;
public:
	map<string,Relation> getMyRelations()
	{
		return myRelations;
	}

	void addRelation(Relation _r)
	{
		string tName = _r.getName();
		myRelations[tName].addTuples(_r.getTuples());
	}

	void buildRelations(Datalog _datalog)
	{
		//Iterate over each scheme and insert into map
		//name of the scheme is the key and the relation is the value
		for(unsigned int i = 0; i < _datalog.getSchemes().size(); i++)
		{
			try
			{
				Relation tRel(_datalog.getSchemes()[i]);
				string tName = _datalog.getSchemes()[i].getID();
				myRelations.insert(pair<string,Relation>(tName,tRel));
			}
			catch(...)
			{
				cout << "Error reading scheme: " << _datalog.getSchemes()[i].getID() << endl;
			}
		}
		//Iterate over each fact and insert it into the right relation
		//Each fact uses the name of the fact to get the key in the map
		//Once there add into the relation
		for(unsigned int i = 0; i < _datalog.getFacts().size(); i++)
		{
			try
			{
				myRelations[_datalog.getFacts()[i].getID()].addTuples(_datalog.getFacts()[i]);
			}
			catch(...)
			{
				cout << "Error reading fact: " << _datalog.getFacts()[i].getID() << endl;
			}
		}
	}

	int getNumTuples()
	{
		int total = 0;
		map<string,Relation>::iterator it;
		for(it = myRelations.begin(); it != myRelations.end(); ++it)
		{
			total += it->second.getTuples().size();
		}
		return total;
	}
	
};