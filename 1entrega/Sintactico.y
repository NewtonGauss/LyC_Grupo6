%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "symbol_table.h"

#define VAL_SZ 255

void yyerror(char *s);
int yylex();

extern int yylineno;
FILE *lexout;

/* Tabla de simbolos */
List sym_table;
void AddInteger(const char *const val);
void AddReal(const char *const val);
void AddString(const char *const val);
void AddIds(const char *const ids, const char *const types);
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

/* Para poner ids y tipos en la tabla de simbolos */
%type <strval> ids lista_ids tipo tipos

%%

prg_: prg {printf("Compilacion exitosa!\n");};

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

decl: VAR lista_ids AS CR_ABR tipos CR_CRR {printf("Declaracion de variables "); AddIds($2, $5);}
		;

lista_ids: CR_ABR ids CR_CRR {strcpy($$, $2);}
		 ;


ids: ID {strcpy($$, $1);}
	 | ids COMA ID {strcpy($$, $1); strcat($$, ","); strcat($$, $3);}
	 ;

tipos: tipo {strcpy($$, $1);}
		 | tipos COMA tipo {strcpy($$, $1); strcat($$, ","); strcat($$, $3);}
		 ;

tipo: REAL {strcpy($$, "real");} | STRING_T {strcpy($$, "string");} | INT {strcpy($$, "int");};

/* =========================
 * ASIGNACION
 * ========================= */

assg: left ASIGN assg {printf("Asignacion multiple ");}
		| left ASIGN right {printf("Asignacion ");}
		;

left: ID
		;

right: expr
		 | str_const
		 ;

str_const: STR {printf("CONST_STR "); AddString($1);}
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

const_num: CONST_R   {printf("CONST_R "); AddReal($1);}
		| CONST_INT {printf("CONST_INT "); AddInteger($1);}
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

constante: const_num | str_const;

/* =========================
 * IO
 * ========================= */

iostmt: PRINT operando {printf("PRINT ");}
			| GET ID {printf("GET ");}
			;

operando: expr | str_const;

%%
/* end of grammar */

int main(int argc, char *argv[]) {
	sym_table = NewList();

	lexout = fopen("lex.out", "wt");
	yyparse();


	/* Guardo la tabla */
	FILE *tstxt = fopen("ts.txt", "wt");
	fprintf(tstxt, "%40s%10s%40s%10s\n", "Nombre", "Tipo", "Valor", "Longitud");
	ListIterator it = Iterator(&sym_table);
	while ( HasNext(&it) ) {
		Symbol sym = Next(&it);
		char *type;
		switch ( sym.type ) {
		case TABLE_INT:
			type = "Integer";
			break;
		case TABLE_REAL:
			type = "Real";
			break;
		case TABLE_STRING:
			type = "String";
			break;
		default:
			fprintf(stderr, "Tipo de dato invalido");
			exit(1);
		}
		fprintf(tstxt, "%40s%10s%40s%10d\n", sym.name, type, sym.value, sym.len);
	}
}

void yyerror(char *s) {
	fprintf(stderr, "%s near line %d\n", s, yylineno);
}

void doAddConstant(const char *const val, DataType type)
{
	Symbol s;
	strcpy(s.name, "_");
	strcat(s.name, val);
	s.type = type;
	strcpy(s.value, val);
	s.len = 0;
	AddSymbol(&sym_table, &s);
}

void AddInteger(const char *const val)
{
	doAddConstant(val, TABLE_INT);
}


void AddReal(const char *const val)
{
	doAddConstant(val, TABLE_REAL);
}


void AddString(const char *const val)
{
	char buf[SYM_NAME_SZ];
	/* saco la primer comilla */
	strcpy(buf, val+1);
	/* saco la ultima comilla */
	buf[strlen(buf)-1] = 0;

	doAddConstant(buf, TABLE_STRING);
}

void addId(const char *id, DataType type)
{
	Symbol s;
	strcpy(s.name, id);
	s.type = type;
	strcpy(s.value, "");
	s.len = 0;
	AddSymbol(&sym_table, &s);
}


void AddIds(const char *const ids, const char *const types)
{
	const char *id_start = ids, *id_comma = ids;
	const char *type_start = types, *type_comma = types;

	while ( *id_start && *type_start ) {
		while ( *id_comma && *id_comma != ',' )
				id_comma++;
		while ( *type_comma && *type_comma != ',' )
				type_comma++;

		char id[255];
		strncpy(id, id_start, id_comma - id_start);
		id[id_comma - id_start] = 0;
		DataType type;
		if (strncmp("real", type_start, type_comma - type_start) == 0) {
			type = TABLE_REAL;
		} else if ( strncmp("int", type_start, type_comma - type_start) == 0 ) {
			type = TABLE_INT;
		} else if ( strncmp("string", type_start, type_comma - type_start) == 0 ) {
			type = TABLE_STRING;
		}

		addId(id, type);

		/*
		 * lo pongo en el principio del proximo id en caso de que no se haya
		 * encontrado el \0
		 */
		id_start = id_comma = *id_comma != 0 ? id_comma + 1 : id_comma;
		type_start = type_comma = *type_comma != 0 ? type_comma + 1 : type_comma;
	}
}

