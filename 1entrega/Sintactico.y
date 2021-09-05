%{
#include <stdio.h>
#include <math.h>

#define VAL_SZ 255

void yyerror(char *s);
int yylex();

extern int yylineno;
FILE *lexout;
%}

%union {
	char strval[255 + 1];
}

%token <strval> ID

%token LL_ABR
%token LL_CRR
%token CR_ABR
%token CR_CRR
%token PR_ABR
%token PR_CRR

%token <strval> CONST_INT
%token <strval> CONST_R
%token <strval> STR

%token SUM
%token MIN
%token DIV
%token MULT

%token EQ
%token NEQ
%token LT
%token LEQ
%token GT
%token GEQ
%token NOT
%token AND
%token OR

%token IF
%token ELSE
%token WHILE

%token ASIGN

%token VAR
%token AS
%token COMA

%token INT
%token REAL
%token STRING_T

%token END_STMT
%token NL

%token GET
%token PRINT

%left  SUM MIN /* left associative, same precedence. a-b-c will be (a-b)-c */
%left  MUL DIV /* left associative, higher precedence. */
%right ASIGN /* assignment */

%%

test: VAR CR_ABR ID CR_CRR AS CR_ABR REAL CR_CRR {printf("declaracion de real\n");}

%%
/* end of grammar */

int main(int argc, char *argv[]) {
	lexout = fopen("lex.out", "wt");
	yyparse();
}

void yyerror(char *s) {
	fprintf(stderr, "%s near line %d\n", s, yylineno);
}
