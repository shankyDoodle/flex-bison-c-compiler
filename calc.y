%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "calc.tab.h"

typedef struct symTable {
    char *sVarLabel;
    float fVarValue;
    int type;/*type=0 for int and 1 for float*/
} symTable;
symTable symbolStack[100];

void insertInStackTable(int sIndex, char *varLabel, float varValue, int varType);

void updateStackTableValue(char *vI, int t2, float v2, int sCount);

float getValueByIndex(char *varLabel, int iIndex);

int getType(char *varLabel, int iIndex);

int checkType(int type1, int type2);

int yylex();

int yyerror(char *s);

int stackCounter = 0;
%}

%token TOKEN_SUB TOKEN_MUL TOKEN_EQL TOKEN_PRINTID TOKEN_SEMICOLON
%token TOKEN_MAIN TOKEN_BRAC_O TOKEN_BRAC_C TOKEN_CURLY_BRAC_O TOKEN_CURLY_BRAC_C
%token TOKEN_INT TOKEN_FLOAT TOKEN_NUM TOKEN_DIGIT TOKEN_VAR

%union{
    int intValue;
	float floatValue;
	char * charPtrVar;
	struct expStruct {
		int type;/*0 for int and 1 for float*/
		float expValue;
	}expStruct;
}

%type <floatValue> TOKEN_NUM
%type <intValue> TOKEN_DIGIT
%type <charPtrVar> TOKEN_VAR
%type <expStruct> expr
%left TOKEN_SUB
%left TOKEN_MUL

%%

prog:
    	TOKEN_MAIN TOKEN_BRAC_O TOKEN_BRAC_C TOKEN_CURLY_BRAC_O stmts TOKEN_CURLY_BRAC_C
;

stmts:
     	| stmt TOKEN_SEMICOLON stmts
;

stmt:
	TOKEN_INT TOKEN_VAR {
		insertInStackTable(stackCounter,$2,0,0);
		stackCounter++;
	}
	| TOKEN_FLOAT TOKEN_VAR {
		insertInStackTable(stackCounter,$2,0,1);
		stackCounter++;
	}
	| TOKEN_VAR TOKEN_EQL expr {
		updateStackTableValue($1, $3.type, $3.expValue, stackCounter);
	}
	| TOKEN_PRINTID TOKEN_VAR {
		float fVal = getValueByIndex($2, stackCounter);
		if(fVal != -1) {
			fprintf(stdout, "%f\n", fVal);
		}
	}
	| TOKEN_CURLY_BRAC_O stmts TOKEN_CURLY_BRAC_C {
	    /*nothing yet */
	}
;

expr:
    expr TOKEN_SUB expr {
		int flag = checkType($1.type, $3.type);
		if(flag == 0) {
			$$.type = $1.type;
			$$.expValue = $1.expValue - $3.expValue;
		}
	}
	| expr TOKEN_MUL expr {
		int flag = checkType($1.type, $3.type);
		if(flag == 0) {
			$$.type = $1.type;
			$$.expValue = $1.expValue * $3.expValue;
		}
	}
	| TOKEN_VAR {
		$$.type = getType($1, stackCounter);
		$$.expValue = getValueByIndex($1, stackCounter);
	}
	| TOKEN_DIGIT {
	    /*printf("in digit: %d \n", $1);*/
		$$.expValue = $1;
		$$.type = 0;
	}
	| TOKEN_NUM {
		/*printf("in float: %f \n", $1);*/
		$$.expValue = $1;
		$$.type = 1;
	}
;
%%


int getType(char *varLabel, int iIndex) {
    int i, flag = 0;
    for (i = iIndex - 1; i >= 0; i--) {
        if (strcmp(symbolStack[i].sVarLabel, varLabel) == 0) {
            flag = 1;
            return symbolStack[i].type;
        }
    }
    if (!flag) {
        yyerror("Variable not declared!!!");
    }
    return -1;
}

float getValueByIndex(char *varLabel, int iIndex) {
   int i, flag = 0;
    for (i = iIndex - 1; i >= 0; i--) {
        if (strcmp(symbolStack[i].sVarLabel, varLabel) == 0) {
           flag = 1;
            return symbolStack[i].fVarValue;
        }
    }
    if (!flag) {
        yyerror("Variable not declared!!!");
    }
    return -1;
}

int checkType(int type1, int type2) {
    if (type1 == type2) {
        return 0;
    }

    yyerror("Type Does not match");
    return -1;

}

void updateStackTableValue(char *v1, int t2, float v2, int sCount) {
    /*printf("inside updateStackTableValue\n");*/
    int i;
    int flag = 0;
    for (i = sCount - 1; i >= 0; i--) {
        /*printf("inside for: %s, :%s \n", symbolStack[i].sVarLabel, v1);*/

        if (strcmp(symbolStack[i].sVarLabel, v1) == 0) {
            /*printf("inside if && %f\n", v2);*/
            if (symbolStack[i].type == t2) {
                break;
            }

            flag = 1;
            symbolStack[i].fVarValue = v2;
        }
    }

    if (!flag) {
        yyerror("Variable declaration missing or Type Error");
    }
}

void insertInStackTable(int sIndex, char *varLabel, float varValue, int varType) {
    /*printf("Here bro\n");*/
    symbolStack[sIndex].sVarLabel = varLabel;
    symbolStack[sIndex].fVarValue = varValue;
    symbolStack[sIndex].type = varType; /* Either 0 or 1*/
    /*printf("Here sym var:%s && %f && %d", symbolStack[0].sVarLabel, varValue, varType);*/

}

int yyerror(char *s) {
    extern int yylineno;
    fprintf(stdout, "\n Line no %d : %s \n", yylineno, s);
    return 0;
}

int main() {
    yyparse();
    return 0;
}