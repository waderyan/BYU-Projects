#pragma once
#include <string>

using std::string;


/**------------------------------------------------------------
TokenType purpose:
1) Reprsents all the different tokens that can be read
------------------------------------------------------------**/
enum TokenType
{
	COMMA =',', PERIOD ='.', Q_MARK = '?', LEFT_PAREN = '(', RIGHT_PAREN = ')', 
	COLON = ':', COLON_DASH = 1, SCHEMES = 2, FACTS =3 , RULES=4, QUERIES=5,
	ID=6, STRING=7, ERROR=100, END, NEWLINE = '\n'
};
/**------------------------------------------------------------
Token Purpose:
1) Object of a token with type, value, and location
------------------------------------------------------------**/
class Token
{
private:
	//Data members
	TokenType type;
	string value;
	int lineNum;
	/** init-----------------------------------------------
		@param ptype - type of token
		@param pvalue - value of token
		@param plineNum - location of token
		1) initializes the token
		-----------------------------------------------------**/
	void init(TokenType ptype, string pvalue, int plineNum)
	{
		type = ptype;
		value = pvalue;
		lineNum = plineNum;
	}
public:
	/** Constructor-----------------------------------------------
		1) Initializes an empty token
		-----------------------------------------------------**/
	Token()
	{
		init(STRING,"Empty",0);
	}

	Token(int plineNum)
	{
		lineNum = plineNum;
		type = ERROR;
		value = "ERROR";
	}

	Token(string end,int plineNum)
	{
		lineNum = plineNum;
		type = END;
		value = "";
	}

	//Default constructo
	~Token(){}

	void Create(TokenType ptype, string pvalue)
	{
		type = ptype;
		value = pvalue;
	}

	/** Creates-----------------------------------------------
		@param ptype - type of token
		@param pvalue - value of token
		@param plineNum - location of token
		1) Calls initializer
		-----------------------------------------------------**/
	void Create(TokenType ptype, string pvalue, int plineNum)
	{
		init(ptype,pvalue,plineNum);
	}

	//Token type getter
	TokenType getType() const
	{
		return type;
	}

	//Token value getter
	string getValue() const
	{
		return value;
	}

	//Token line number getter
	int getLineNum() const
	{
		return lineNum;
	}

	/** Creates-----------------------------------------------
		@param ptype - type of token
		1) Determines the string interpretation of the TokenType
		@return the string intepretation
		-----------------------------------------------------**/
	string detLiteral(TokenType ptype) const
	{
		if(ptype == COMMA)
			return "COMMA";
		else if(ptype == PERIOD)
			return "PERIOD";
		else if(ptype == Q_MARK)
			return "Q_MARK";
		else if(ptype == LEFT_PAREN) 
			return "LEFT_PAREN";
		else if(ptype == RIGHT_PAREN)
			return "RIGHT_PAREN";
		else if(ptype == COLON)
			return "COLON";
		else if(ptype == COLON_DASH)
			return "COLON_DASH";
		else if(ptype == SCHEMES)
			return "SCHEMES";
		else if(ptype == FACTS)
			return "FACTS";
		else if(ptype == QUERIES)
			return "QUERIES";
		else if(ptype == ID)
			return "ID";
		else if(ptype == RULES)
			return "RULES";
		else if(ptype == STRING)
			return "STRING";
		else
			return "ERROR";
	}
};