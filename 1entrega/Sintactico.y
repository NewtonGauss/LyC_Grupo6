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

%token LEN
%token EQUMAX
%token EQUMIN

%right ASIGN /* assignment */
%left  SUM MIN /* left associative, same precedence. a-b-c will be (a-b)-c */
%left  MULT DIV /* left associative, higher precedence. */

%%

prg_: prg;

prg: bloq
	 | prg bloq /* un programa y una lista de sentencias */
	 ;

bloq: flowcontr
		| sent
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
		| eqcond
		;

oplog: EQ {printf("EQ ");}
		 | NEQ {printf("NEQ ");}
		 | LT {printf("LT ");}
		 | LEQ {printf("LEQ ");}
		 | GT {printf("GT ");}
		 | GEQ {printf("GEQ ");}
		 ;

eqcond: eqop PR_ABR expr COMA lista_ids PR_CRR
			| eqop PR_ABR expr COMA lista_const PR_CRR
		 ;

eqop: EQUMIN {printf("EQUMIN ");}
		| EQUMAX {printf("EQUMAX ");}
		;

sent: decl endstmt
		| assg endstmt
		| iostmt endstmt
		| endstmt
		;

endstmt: END_STMT | NL {printf("\n");};

decl: VAR lista_ids AS CR_ABR tipos CR_CRR {printf("Declaracion de variables ");}
		;

lista_ids: CR_ABR ids CR_CRR
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

assg: left ASIGN assg {printf("Asignacion multiple ");}
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

expr: expr arth_opr termino {printf("Operacion aritmetica ");}
		| termino
		;

termino: PR_ABR expr PR_CRR {printf("Expresion en parentesis ");}
		| llong     {printf("LONGITUD ");}
		| ID        {printf("ID ");}
		| const_num
		;

const_num: CONST_R   {printf("CONST_R ");}
		| CONST_INT {printf("CONST_INT ");}
		;

arth_opr: SUM {printf("SUM ");}
				| MIN {printf("MIN ");}
				| MULT {printf("MULT ");}
				| DIV {printf("DIV ");}
				;

llong: LEN PR_ABR lista_ids PR_CRR
		 | LEN PR_ABR lista_const PR_CRR
		 ;

lista_const: CR_ABR constantes CR_CRR
					 ;

constantes: constante
					| constantes COMA constante
					;

constante: const_num | STR;

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
