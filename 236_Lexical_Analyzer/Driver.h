#pragma once
#include "Graph.h"

using namespace std;

class Driver
{
private:
	Graph myGraph;
	ofstream myOut;

	void print_ruleEval()
	{
		myOut << "  Rule Evaluation Order" << endl;

		set<pair<int,string> > temp = myGraph.rule_evalOrder();
		set<pair<int,string> >::iterator setIt;

		for(setIt = temp.begin(); setIt != temp.end(); ++setIt)
		{
			myOut << "    " << setIt->second << endl;
		}
		myOut << endl;
	}

	void print_backward(set<pair<string,set<string> > > _backward)
	{
		myOut << "  Backward Edges" << endl;

		set<pair<string,set<string> > >::iterator it;
		for(it = _backward.begin(); it != _backward.end(); ++it)
		{
			myOut << "    " << it->first << ":";

			set<string>::iterator setIt;
			set<string> temp = it->second;
			for(setIt = temp.begin(); setIt != temp.end(); ++setIt)
			{
				myOut << " " << *setIt;
			}
			myOut << endl;
		}
		myOut << endl;
	}

public:

	Driver(char * _out)
	{
		myOut.open(_out);
	}

	void build_graph(Datalog _datalog)
	{
		myGraph.build_graph(_datalog);
		myGraph.print_graph(myOut);
	}

	void print_queries(Datalog _datalog)
	{
		for(unsigned int i = 0; i < _datalog.getQueries().size(); i++)
		{
			myOut << _datalog.getQueries()[i].toString() << "?\n" << endl;

			string id = myGraph.dfs_start(_datalog.getQueries()[i].getID());
			myGraph.print_POnum(myOut,i+1);
			print_ruleEval();
			print_backward(myGraph.find_backward_edges());
			myGraph.reset_POnum(id);
			
		}
	}

};