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
%left  MULT DIV /* left associative, higher precedence. */
%right ASIGN /* assignment */

%%

prg: /* nada */
	 | prg bloq /* un programa y una lista de sentencias */
	 ;

bloq: /* nada */
		| bloq flowcontr
		| bloq sent
		;

flowcontr: IF conds LL_ABR bloq LL_CRR ELSE LL_ABR bloq LL_CRR {printf("IF CON ELSE ");}
				 | IF conds LL_ABR bloq LL_CRR {printf("IF SIMPLE ");}
				 | WHILE conds LL_ABR bloq LL_CRR {printf("WHILE ");}
				 ;

conds: cond {printf("Condicion ");}
		 | conds unionlog cond {printf("Condicion multiple ");}
		 ;

unionlog: AND {printf("AND ");}
				| OR  {printf("OR ");}
				;

cond: NOT cond {printf("Negacion de condicion ");}
		| PR_ABR cond PR_CRR
		| operando oplog operando
		;

oplog: EQ {printf("EQ ");}
		 | NEQ {printf("NEQ ");}
		 | LT {printf("LT ");}
		 | LEQ {printf("LEQ ");}
		 | GT {printf("GT ");}
		 | GEQ {printf("GEQ ");}
		 ;

sent: decl endstmt
		| assg endstmt
		| iostmt endstmt
		| endstmt
		;

endstmt: END_STMT | NL {printf("\n");};

decl: VAR CR_ABR ids CR_CRR AS CR_ABR tipos CR_CRR {printf("Declaracion de variables ");}
		;

ids: ID
	 | ids COMA ID
	 ;

tipos: tipo
		 | tipos COMA tipo
		 ;

tipo: REAL | STRING_T | INT;

/* =========================
 * ASIGNACION
 * ========================= */

assg: left ASIGN assg
		| left ASIGN right {printf("Asignacion ");}
		;

left: ID
		;

right: expr
		 | STR {printf("CONST_STR ");}
		 ;

/* =========================
 * ARITMETICA
 * ========================= */

expr: expr arth_opr expr {printf("Operacion aritmetica ");}
		| PR_ABR expr PR_CRR {printf("Expresion en parentesis ");}
		| ID        {printf("ID ");}
		| CONST_R   {printf("CONST_R ");}
		| CONST_INT {printf("CONST_INT ");}
		;

arth_opr: SUM {printf("SUM ");}
				| MIN {printf("MIN ");}
				| MULT {printf("MULT ");}
				| DIV {printf("DIV ");}
				;

/* =========================
 * IO
 * ========================= */

iostmt: PRINT operando {printf("PRINT ");}
			| GET ID {printf("GET ");}
			;

operando: expr | STR;

%%
/* end of grammar */

int main(int argc, char *argv[]) {
	lexout = fopen("lex.out", "wt");
	yyparse();
}

void yyerror(char *s) {
	fprintf(stderr, "%s near line %d\n", s, yylineno);
}
