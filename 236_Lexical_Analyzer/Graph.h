#pragma once
#include <iostream>
#include <sstream>
#include <vector>
#include "Datalog.h"
#include <map>
#include "Node.h"

using namespace std;

class Graph : public map<string,Node>
{
private:
	map<string,Node> myDepGraph;
	int myNum;

	string intToString(int _x)
	{
		string id = "";
		stringstream out;
		out << _x;
		id = out.str();
		out.clear();
		return id;
	}

	string validID(string _type, string _num)
	{
		return _type + _num;
	}

	bool isDepend(string _query, string _ruleHead)
	{
		return _query == _ruleHead;
	}

	bool checkNoQ(string _x)
	{
		return string::npos == _x.find("Q");
	}
	
	void checkDepend(map<string,Node>::iterator it1, string _pred)
	{
		map<string,Node>::iterator it2; 

		for(it2 = myDepGraph.begin(); it2 != myDepGraph.end(); ++it2)
		{
			if(checkNoQ(it2->first))
			{
				if(isDepend(_pred,it2->second.getName()))
					it1->second.addConnection(it2->first);
			}
		}
	}

	void mark_edges()
	{
		map<string,Node>::iterator it1;
		
		for(it1 = myDepGraph.begin(); it1 != myDepGraph.end(); ++it1)
		{
			if(it1->second.getQorR() == "Q")
				checkDepend(it1,it1->second.getName());
			else
			{
				for(unsigned int i = 0; i < it1->second.getPreds().size(); i++)
					checkDepend(it1,it1->second.getPreds()[i]);
			}
		}
	}

	void resetVisited()
	{
		map<string,Node>::iterator it;
		for(it = myDepGraph.begin(); it != myDepGraph.end(); ++it)
		{
			it->second.unVisit();
		}
	}

	void dfs(Node& _x)
	{
		_x.markVisited();

		set<string>::iterator it;
		set<string> adjacent = _x.getConnections();

		for(it = adjacent.begin(); it != adjacent.end(); ++it)
		{
			if(!myDepGraph[*it].isVisited())
			{
				dfs(myDepGraph[*it]);
				myDepGraph[*it].setPO_Num(myNum);
				myNum++;
			}
		}
	}

	set<string> isCyclic(Node _x)
	{
		set<string>::iterator it;
		set<string> adjacent = _x.getConnections();
		set<string> temp;

		for(it = adjacent.begin(); it != adjacent.end(); ++it)
		{
			if(_x.getPO_Num() <= myDepGraph[*it].getPO_Num())
				temp.insert(*it);
		}
		return temp;	
	}

public:

	Graph()
	{		
		myNum = 1;
	}

	void build_graph(Datalog _datalog)
	{
		string type = "Q";
		for(unsigned int i = 0; i < _datalog.getQueries().size(); i++)
		{
			string id = validID(type,intToString(i+1));
			myDepGraph[id].setName(_datalog.getQueries()[i].getID(),type);
		}

		type = "R";
		for(unsigned int i = 0; i < _datalog.getRules().size(); i++)
		{
			string id = validID(type,intToString(i+1));
			vector<string> predicates = _datalog.getRules()[i].getListStrings();
			myDepGraph[id].setName(_datalog.getRules()[i].getHead().getID(),type,predicates);
		}
		
		mark_edges();
	}

	void print_graph(ofstream& _out)
	{
		_out << "Dependency Graph" << endl;
		map<string,Node>::iterator mapIt;

		for(mapIt = myDepGraph.begin(); mapIt != myDepGraph.end(); ++mapIt)
		{
			_out << "  " << mapIt->first << ":";

			set<string>::iterator setIt;
			set<string> temp = mapIt->second.getConnections();

			for(setIt = temp.begin(); setIt != temp.end(); ++setIt)
				_out << " " << *setIt;

			_out << endl;
		}
		_out << endl;
	}

	set<pair<int,string> > rule_evalOrder()
	{
		map<string,Node>::iterator it;
		set<pair<int,string> > temp;

		for(it = myDepGraph.begin(); it != myDepGraph.end(); ++it)
		{
			if(it->second.getPO_Num() > 0 && it->second.getQorR() == "R")
				temp.insert(make_pair(it->second.getPO_Num(),it->first));
		}
		return temp;
	}

	set<pair<string,set<string> > > find_backward_edges()
	{
		map<string,Node>::iterator it;
		set<pair<string,set<string> > > temp;

		for(it = myDepGraph.begin(); it != myDepGraph.end(); ++it)
		{
			if(it->second.getPO_Num() > 0 && it->second.getQorR() == "R")
			{
				set<string> result = isCyclic(it->second);
				if(!result.empty())
					temp.insert(make_pair(it->first,result));
			}				
		}
		return temp;
	}

	string dfs_start(string _pred)
	{
		string id = "";
		map<string,Node>::iterator it;
		for(it = myDepGraph.begin(); it != myDepGraph.end(); ++it)
		{
			if(!it->second.isPrinted())
			{
				if((it->second.getQorR() == "Q") && (it->second.getName() == _pred))
				{
					id = it->first;
					dfs(it->second);
					it->second.setPO_Num(myNum);					
					break;
				}
			}
		}
		resetVisited();
		return id;
	}

	void print_POnum(ofstream& _out, int _count)
	{
		_out << "  Postorder Numbers" << endl;

		map<string,Node>::iterator mapIt;
		for(mapIt = myDepGraph.begin(); mapIt != myDepGraph.end(); ++mapIt)
		{
			if(mapIt->second.getPO_Num() > 0)
			{
				if(mapIt->second.getQorR() == "Q")
					_out << "    Q" << _count << ": " << mapIt->second.getPO_Num() << endl;
				else
					_out << "    " << mapIt->first << ": " << mapIt->second.getPO_Num() << endl;
			}
		}
		_out << endl;
	}

	void reset_POnum(string _id)
	{
		myNum = 1;
		map<string,Node>::iterator it;
		for(it = myDepGraph.begin(); it != myDepGraph.end(); ++it)
		{
			it->second.setPO_Num(0);
		}

		myDepGraph[_id].markPrinted();
	}

};