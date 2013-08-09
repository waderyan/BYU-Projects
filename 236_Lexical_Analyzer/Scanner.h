#pragma once
#include "Token.h"
#include <fstream>
#include <ctype.h>
#include <stdio.h>
#include <locale>
#include <vector>

using namespace std;
/**------------------------------------------------------------
Scanner Purpose: 
1) Read a sequence of characters from a txt file
2) ID the datalog language tokens
3) Outputs each token to an output file
------------------------------------------------------------**/
class Scanner
{
private:
	//Data members
	ifstream myIn;
	ofstream myOut;
	vector<Token> Tokens;
	
	void scanFile()
	{
		try
		{
			int lineNum = 1;
			int tokenCount = 0;
			string line = "";
			while(getline(myIn,line))
			{
				scanLine(line, lineNum,tokenCount);
				lineNum++;
			}
			Token temp(lineNum);
			temp.Create(END,"");
			Tokens.push_back(temp);
			writeOutput(tokenCount);
		}
		catch(int elineNum)
		{
			writeError(elineNum);
		}
	}
	
	void scanLine(string pline, int plineNum, int& tokenCount)
	{
		for(unsigned int i = 0; i < pline.size(); i++)
		{
			Token temp(plineNum); 
			bool add_token = true;
			switch(pline[i])
			{
				case COMMA : 
					temp.Create(COMMA,","); 
					break;
				case PERIOD : 
					temp.Create(PERIOD,"."); 
					break;
				case Q_MARK : 
					temp.Create(Q_MARK,"?"); 
					break;
				case LEFT_PAREN : 
					temp.Create(LEFT_PAREN,"("); 
					break;
				case RIGHT_PAREN : 
					temp.Create(RIGHT_PAREN,")");
					break;
				case COLON:
					temp = detColon(pline,i,plineNum);	
					break;
				case '\'' :
					temp = detString(pline,i,plineNum);		
					break;
				case '#': 
					return;
				case ' ': 
					add_token = false; 
					break;
				case '\t':
					add_token = false;
					break;
				default : 
					temp = detWord(pline,i,plineNum); 
					break;
			}
			detScanToken(add_token,tokenCount,temp);
			//To write output change to detAddToken
		}
	}

	void detAddToken(bool padd, int& ptokenCount, Token ptemp)
	{
		if(padd)
		{
			ptokenCount++;
			writeOutput(ptemp);
		}
	}

	Token detColon(string pline, unsigned int& pcount, int plineNum)
	{
		Token temp(plineNum);
		if((pcount+1) < pline.size() && pline[pcount+1] == '-')
		{
			temp.Create(COLON_DASH,":-"); 
			pcount++;
		}
		else
		{
			temp.Create(COLON,":");
		}
		return temp;
	}

	Token detString(string pline, unsigned int& pcount, int plineNum)
	{
		string word = ""; 
		Token temp;
		for(int j = pcount+1; pline[j] != '\''; j++)
		{
			word += pline[j]; pcount = j;
			if((j+1) == pline.size())
				throw plineNum;
		}
		temp.Create(STRING,word,plineNum); 
		pcount++;
		return temp;
	}

	Token detWord(string pline, unsigned int& pcount, int plineNum)
	{
		if(isalpha(pline[pcount]))
		{
			string word = ""; 
			Token temp(plineNum); 
			string upperCase ="";

			while(pcount < pline.size() && isalnum(pline[pcount]))
			{
				word += pline[pcount];
				pcount++;
			}
			if(word == "Queries")
				temp.Create(QUERIES,word);
			else if(word == "Schemes")
				temp.Create(SCHEMES,word);
			else if(word == "Facts")
				temp.Create(FACTS,word);
			else if(word == "Rules")
				temp.Create(RULES,word);
			else
				temp.Create(ID,word);
			pcount--;
			return temp;
		}
		else
			throw plineNum;
	}

	void detScanToken(bool padd, int& ptokenCount, Token ptemp)
	{
		if(padd)
		{
			ptokenCount++;
			scanToken(ptemp);
		}
	}

	void scanToken(Token ptemp)
	{
		Tokens.push_back(ptemp);
	}	

	void writeOutput(Token ptoken)
	{
		myOut << "(" << ptoken.detLiteral(ptoken.getType()) << ",\"" 
			<< ptoken.getValue() << "\"," << ptoken.getLineNum() << ")" << endl;
	}

	void writeOutput(int pcount)
	{
		myOut << "Total Tokens = " << pcount << endl;
	}

	void writeError(int plineNum)
	{
		myOut << "Input Error on line " << plineNum << endl;
	}	
public:
	
	//Default Constructor
	Scanner() {}

	void processFiles(char* pIn, char* pOut)
	{
		myIn.open(pIn);
		myOut.open(pOut);
		scanFile();
	}

	void processFile(char* pIn)
	{
		myIn.open(pIn);
		scanFile();
	}

	vector<Token> getTokens() const
	{
		return Tokens;
	}

	void writeError(Token ptoken, ofstream& pOut)
	{
		pOut << "(" << ptoken.detLiteral(ptoken.getType()) << ",\"" 
			<< ptoken.getValue() << "\"," << ptoken.getLineNum() << ")" << endl;
	}

	//Default Destructor
	~Scanner() {}
	
};

