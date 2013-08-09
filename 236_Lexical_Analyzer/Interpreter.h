#include "Datalog.h"
#include "Relation.h"
#include "Database.h"
#include <map>
#include <stdexcept>

using namespace std;

class Interpreter
{
private:
	//Data Members
	Datalog myDatalog;
	ofstream myOut;
	int changeCounter;

	//Helper methods
	void runQuery(Relation& _relation, Predicate _query)
	{
		//Use the select operation to select the tuples from the relation that match the query
		//Iterate over the parameters of the query
		vector<int> var_positions; vector<string> var_names;		
		for(int i = 0; i < _query.getListSize(); i++)
		{
			//Iterate through each letter of the string (should only be one each time)
			//If the parameter is a constant, select the tuples from the relation -- how do we know what is constant?
			//that have the same value as the paramter in the same position as the parameter
			if(!_query.getList()[i].isID()) //Is it a constant?
				_relation = _relation.select(i,_query.getListAsString()[i]);
			else //Is it a variable?
			{
				var_positions.push_back(i);
				var_names.push_back(_query.getListAsString()[i]);
			}
		}
		_relation = _relation.project(var_positions);
		_relation.rename(var_names); 
	}

	void evaluateRules(Database& _Relations)
	{
		for(unsigned int i = 0; i < myDatalog.getRules().size(); i++)
		{
			try
			{
				//Steps 1 & 2
				Relation tempR = runRuleList(myDatalog.getRules()[i].getList(), _Relations);
				//Steps 3 & 4
				tempR = runRuleReorder(tempR,myDatalog.getRules()[i].getHead());
				//Step 5 Union
				Relation temp = _Relations.getMyRelations()[myDatalog.getRules()[i].getHead().getID()];
				tempR = tempR.Union(tempR,temp);
				_Relations.addRelation(tempR);
			}
			catch(...)
			{
				cout << "Error reading Rule: " << myDatalog.getRules()[i].getHeadName() << endl;
			}
		}
	}

	Relation runRuleList(vector<Predicate> _rulesList, Database _Relations)
	{
		//Step 1 - produce relations for each predicate in rules list
		vector<Relation> tempRelations;
		for(unsigned int i = 0; i < _rulesList.size(); i++)
		{
			Relation tempR = _Relations.getMyRelations()[_rulesList[i].getID()];
			runQuery(tempR,_rulesList[i]);
			tempRelations.push_back(tempR);
		}
		//Step 2 - Join relations to create one relation
		Relation tempR;
		if(tempRelations.size() == 1)
			tempR = tempRelations[0];
		else
			tempR = tempR.Join(tempRelations);
		return tempR;
	}

	Relation runRuleReorder(Relation _body, Predicate _head)
	{
		Relation head(_head);
		vector<int> matches;
		for(unsigned int i = 0; i < head.getScheme().getAttNames().size(); i++)
		{
			for(unsigned int j = 0; j < _body.getScheme().getAttNames().size(); j++)
			{
				if(head.getScheme().getAttNames()[i] == _body.getScheme().getAttNames()[j])
					matches.push_back(j);
			}
		}
		Relation reordered = _body.project(matches);
		//Step4
		reordered.rename(head.getScheme().getAttNames());
		return reordered;
	}	

public:
	void loadDatalog(Datalog _datalog)
	{
		myDatalog = _datalog;
		changeCounter = 0;
	}

	void loadOutput(char* _out)
	{
		myOut.open(_out);
	}

	void repeatRules(Database& _relations)
	{
		//Fixed point algorithm
		bool changes = true;
		while(changes)
		{		
			changeCounter++;
			changes = false;
			int original = _relations.getNumTuples();
			evaluateRules(_relations);
			if(original != _relations.getNumTuples())
				changes = true;
		}
	}

	void runQueries(Database _Relations)
	{
		myOut << "Converged after " << changeCounter << " passes through the Rules." << endl;
		for(unsigned int i = 0; i < myDatalog.getQueries().size(); i++)
		{
			try
			{
				Relation temp = _Relations.getMyRelations()[myDatalog.getQueries()[i].getID()];
				runQuery(temp, myDatalog.getQueries()[i]);
				output(myDatalog.getQueries()[i],temp);
			}
			catch(...)
			{
				cout << "Error reading query: " << myDatalog.getQueries()[i].getID() << endl;
			}
		}
	}

	void output(Predicate _query, Relation _relation)
	{
		myOut << _query.toString() << "? ";
		_relation.print(myOut);
	}
};