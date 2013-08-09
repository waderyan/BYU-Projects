#pragma once
#include <iostream>
#include <fstream>
#include <vector>
#include <set>
#include "Rule.h"
#include "Predicate.h"
#include "Parameter.h"

using namespace std;

class Datalog
{
private:
	//Data members
	vector<Predicate> myFacts;
	vector<Predicate> mySchemes;
	vector<Rule> myRules;
	vector<Predicate> myQueries;
	set<string> myDomains;
	
public:
	//Getter methods
	vector<Rule> getRules() const
	{
		return myRules;
	}

	vector<Predicate> getFacts() const
	{
		return myFacts;
	}

	vector<Predicate> getSchemes() const
	{
		return mySchemes;
	}

	vector<Predicate> getQueries() const
	{
		return myQueries;
	}

	set<string> getDomains() const
	{
		return myDomains;
	}

	//Adding methods
	void addRule(Rule p)
	{
		myRules.push_back(p);
	}

	void addFact(Predicate p)
	{
		myFacts.push_back(p);
	}

	void addSchemes(Predicate p)
	{
		mySchemes.push_back(p);
	}

	void addQuery(Predicate p)
	{
		myQueries.push_back(p);
	}

	void addDomain(string p)
	{
		myDomains.insert(p);
	}

	//Write to output
	void writeOutput(ofstream& pOut)
	{
		pOut << "Success!" << endl;
		pOut << "Schemes(" << mySchemes.size() << "):" << endl;
		printSchemes(pOut);
		pOut << "Facts(" << myFacts.size() << "):" << endl;
		printFacts(pOut);
		pOut << "Rules(" << myRules.size() << "):" << endl;
		printRules(pOut);
		pOut << "Queries(" << myQueries.size() << "):" << endl;
		printQueries(pOut);
		pOut << "Domain(" << myDomains.size() << "):" << endl;
		printDomains(pOut);
	}

	void printSchemes(ofstream& pOut)
	{
		for(unsigned int i = 0; i < mySchemes.size(); i++)
		{
			pOut << "  " << mySchemes[i].toString() << endl;
		}
	}

	void printFacts(ofstream& pOut)
	{
		for(unsigned int i = 0; i < myFacts.size(); i++)
		{
			pOut << "  " << myFacts[i].toString() << endl;
		}
	}

	void printRules(ofstream& pOut)
	{
		for(unsigned int i = 0; i < myRules.size(); i++)
		{
			pOut << "  " << myRules[i].toString() << endl;
		}
	}

	void printQueries(ofstream& pOut)
	{
		for(unsigned int i = 0; i < myQueries.size(); i++)
		{
			pOut << "  " << myQueries[i].toString() << endl;
		}
	}

	void printDomains(ofstream& pOut)
	{
		set<string>::iterator it;
		for(it = myDomains.begin(); it != myDomains.end(); ++it)
		{
			pOut << "  " << "'" <<  *it << "'" << endl;
		}
	}

	
};