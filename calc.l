%{
#include <stdio.h>
#include "calc.tab.h"
%}

digit	[0-9]
floatDig   [0-9]+\.[0-9]+

%%
"main"				    {return(TOKEN_MAIN);}
"("						{return(TOKEN_BRAC_O);}
")"						{return(TOKEN_BRAC_C);}
"{"				        {return(TOKEN_CURLY_BRAC_O);}
"}"				        {return(TOKEN_CURLY_BRAC_C);}
"int"					{return(TOKEN_INT);}
"float"					{return(TOKEN_FLOAT);}
"printID"               {return(TOKEN_PRINTID);}
";"						{return(TOKEN_SEMICOLON);}
"="						{return(TOKEN_EQL);}
"-"						{return(TOKEN_SUB);}
"*"						{return(TOKEN_MUL);}
{digit}+	            {
                            sscanf(yytext, "%d", &(yylval.intValue));
                            return(TOKEN_DIGIT);
                        }
{floatDig}	            {
		                    sscanf(yytext, "%f", &(yylval.floatValue));
		                    return TOKEN_NUM;
		                }
[a-z]+\w*	            {
                            char *myVar = (char*)malloc(1000);
                            strcpy(myVar, yytext);
                            yylval.charPtrVar = myVar;
                            /*scanf(yytext, "%s", &(yylval.charPtrVar));*/
		                    return TOKEN_VAR;
		                }

[ \n] 	                {yylineno++;}

.	                    {printf("This character '%c' is invalid and ignored, \n",yytext[0]);}

%%
