#pragma once
#include <iostream>
#include "Scanner.h"
#include "Datalog.h"
#include "Parameter.h"
#include "Predicate.h"
#define EPSELON string e = ""

using namespace std;

/**----------------------------------------------------------------
Parser purpose: 
1) Reads a datalog program from a text file
2) Builds a data structure that represents the datalog program
3) Outputs the contents of the datlog program data structure
4) Determine if there is a syntax error
-----------------------------------------------------------------**/
class Parser
{
private:
	Scanner myScan;
	vector<Token> myTokens;
	Token myToken;
	ofstream myOut;
	unsigned int myIndex;
	Datalog myDatalog;
	Predicate myPred;
	vector<Parameter> myParamList;
	vector<Predicate> myPredList;

	void funParse()
	{
		try
		{
			myToken = getToken();
			funSchemesList();
			//myDatalog.writeOutput(myOut);
		}
		catch(Token t)
		{
			if(t.getType() == END)
			{
				myOut << "Failure!" << endl;
				myOut << "(EOF,\"\"," << t.getLineNum() << ")" << endl;
			}
			else
			{
				myOut << "Failure!" << endl;
				myScan.writeError(t,myOut);
			}
		}
	}

	void funSchemesList()
	{
		if(myToken.getType() == SCHEMES)
		{
			match(SCHEMES);
			match(COLON);
			if(myToken.getType() == ID)
				funSchemeMid();
			else
				error();
		}
		else
			error();
		
	}

	void funSchemeMid()
	{
		if(myToken.getType() == ID)
			funScheme();
		else if(myToken.getType() == FACTS)
			funFactsList();
		else
			error();
	}

	void funScheme()
	{
		funPredicate();
		myDatalog.addSchemes(myPred);
		myPredList.clear();
		myPred.clear();
		funSchemeMid();
	}

	void funFactsList()
	{
		if(myToken.getType() == FACTS)
		{
			match(FACTS);
			match(COLON);
			funFactMid();
		}
		else
			error();
		
	}

	void funFactMid()
	{
		if(myToken.getType() == ID)
			funFact();
		else if(myToken.getType() == RULES)
			funRulesList();
		else
		{
			EPSELON;
			funRulesList();
		}	
	}

	void funFact()
	{
		funPredicate();
		myDatalog.addFact(myPred);
		myPredList.clear();
		myPred.clear();
		match(PERIOD);
		funFactMid();
	}

	void funRulesList()
	{
		if(myToken.getType() == RULES)
		{
			match(RULES);
			match(COLON);
			funRuleMid();
		}
		else
			error();
		
	}

	void funRuleMid()
	{
		if(myToken.getType() == ID)
			funRule();
		else if(myToken.getType() == QUERIES)
			funQueriesList();
		else
		{
			EPSELON;
			funQueriesList();
		}
	}

	void funRule()
	{
		funPredicate();
		Rule temp(myPred);
		myPred.clear();
		match(COLON_DASH);
		funPredicateList();
		match(PERIOD);
		temp.addList(myPredList);
		myDatalog.addRule(temp);
		myPredList.clear();
		funRuleMid();
	}

	void funQueriesList()
	{
		if(myToken.getType() == QUERIES)
		{
			match(QUERIES);
			match(COLON);
			if(myToken.getType() == ID)
				funQueryMid();
			else
				error();
		}
		else
			error();
	}

	void funQueryMid()
	{
		if(myToken.getType() == ID)
			funQuery();
		else if(myToken.getType() == END) 
			return;
		else
			error();
	}

	void funQuery()
	{
		funPredicate();
		myDatalog.addQuery(myPred);
		myPredList.clear();
		myPred.clear();
		match(Q_MARK);
		funQueryMid(); 
	}

	void funPredicateList()
	{
		funPredicate();
		myPredList.push_back(myPred);
		myPred.clear();
		if(myToken.getType() == PERIOD)
			return;
		match(COMMA);
		funPredicateList(); 
	}

	void funPredicate()
	{
		/**
			Set myToken value to the predicate object
			after going through the left paren
			Insert Predicate object in Schemes,Facts,Query,Rule
		**/
		myPred.setID(myToken.getValue());
		match(ID);
		match(LEFT_PAREN);
		funParameterList();
		myPred.addList(myParamList);
		myParamList.clear();
		match(RIGHT_PAREN);
	}

	void funParameterList()
	{
		funParameter();
		if(myToken.getType() == RIGHT_PAREN)
			return;
		match(COMMA);
		funParameterList(); 
	}

	void funParameter()
	{
		Parameter temp;
		if(myToken.getType() == STRING)
		{
			temp.setString(myToken.getValue());
			myDatalog.addDomain(myToken.getValue());
			match(STRING);
		}
		else if(myToken.getType() == ID)
		{
			temp.setID(myToken.getValue());
			match(ID);
		}
		else
			error();
		myParamList.push_back(temp);
	}

	void match(TokenType t)
	{
		if(myToken.getType() == t)
		{
			myToken = getToken();
		}
		else
			error();
	}

	Token getToken()
	{	
		if(myIndex < myTokens.size() -1)
		{
			return myTokens[myIndex++];
		}
		else
		{
			return myTokens[myIndex];
		}
	}

	void error()
	{
		throw myToken;
	}
	
public:
	Parser() {}

	Datalog runParser(char* pIn)
	{
		myIndex = 0;
		//myOut.open(pOut);
		myScan.processFile(pIn);	
		myTokens = myScan.getTokens();
		funParse();
		return myDatalog;
	}

	Datalog getDatalog()
	{
		return myDatalog;
	}

	~Parser() {}

};