%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <stdbool.h>
#include <math.h>
#include "symbol_table.h"
#include "tercetos.h"
#include "stack.h"

#define VAL_SZ 255
#define ___ NewVoid()

void yyerror(char *s, ...);
int yylex(void);

extern int yylineno;
FILE *lexout;

/* Tabla de simbolos */
List sym_table;
void AddInteger(const char *const val);
void AddReal(const char *const val);
void AddString(const char *const val);
void AddIds(const char *const ids, const char *const types);
Symbol *Lookup(const List *const lst, const char *const name);
void CheckId(const char *const id);

/* Tercetos */
Terceto terceto;
FILE* tercetos;
TercEntry NewOperator(const char *const op);
TercEntry NewValue(const char *const value);
TercEntry NewIndexRef(const int idx);
TercEntry NewVoid(void);

Stack stack;

/* Para EQUMAX y EQUMIN */
Stack eqStack;
static bool isMax = false;

static int strConstIdx;
static int rightIdx;
static int exprIdx;
static int terminoIdx;
static int factorIdx;
static int constNumIdx;
static int assgIdx;
static int condIdx;
static int eqCondIdx;
static int condsIdx;
static int primerOperandoIdx;
static int operandoIdx;
static int branchIdx;
static int constIdx;

char *OperadorContrario(const char *op);
void RevertirBranch(Terceto t, int i, char *op);
static char ultimoOperador[10]={0};
static bool huboAnd = false;

/* para LEN */
static int szLista = 0;
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
%type <strval> left oplog

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

flowcontr: IF conds LL_ABR bloq LL_CRR {
					if ( !Stack_IsEmpty(&stack) ) {
						const int branch = Pop(&stack);
						FillVoid(terceto, branch, CurrentIndex());
					}
					if ( huboAnd ) {
						if ( !Stack_IsEmpty(&stack) ) {
							const int branch = Pop(&stack);
							FillVoid(terceto, branch, CurrentIndex());
							}
						huboAnd = false;
						}
					const int i = AddTerceto(
						terceto,
						NewOperator("BRA"), /* branch always */
						___,
						___
					);
					Push(&stack, i);
				 } ELSE LL_ABR bloq LL_CRR {
					printf("IF CON ELSE ");
					if ( !Stack_IsEmpty(&stack) ) {
						const int branch = Pop(&stack);
						FillVoid(terceto, branch, CurrentIndex());
					}
				 }
				 | IF conds LL_ABR bloq LL_CRR {
					printf("IF SIMPLE ");
					if ( !Stack_IsEmpty(&stack) ) {
						const int branch = Pop(&stack);
						FillVoid(terceto, branch, CurrentIndex());
					}
					if ( huboAnd ) {
						if ( !Stack_IsEmpty(&stack) ) {
							const int branch = Pop(&stack);
							FillVoid(terceto, branch, CurrentIndex());
						}
						huboAnd = false;
						}
					}
				 | WHILE {
					const int i = AddTerceto(terceto, NewOperator("ET"), ___, ___);
					Push(&stack, i);
					} conds LL_ABR bloq LL_CRR {
					printf("WHILE ");
					const int branchAfuera = Pop(&stack);
					FillVoid(terceto, branchAfuera, CurrentIndex()+1);

					const int branchHaciaWhile = Pop(&stack);
					AddTerceto(
						terceto,
						NewOperator("BRA"),
						NewIndexRef(branchHaciaWhile),
						___
					);
					}
				 ;

conds: cond {
				printf("Condicion ");
				condsIdx = condIdx;
				branchIdx = AddTerceto(
					terceto,
					NewOperator(ultimoOperador),
					___,
					___
				);
				Push(&stack, branchIdx);
				}
		 | cond OR {
				branchIdx = AddTerceto(
					terceto,
					NewOperator(OperadorContrario(ultimoOperador)),
					___,
					___
				);
				Push(&stack, branchIdx);
				} cond {
				printf("Condicion multiple ");
				const int branch = Pop(&stack);
				/* estoy parado en el branch, +1 es donde sigue */
				FillVoid(terceto, branch, CurrentIndex()+1);

				/* branch */
				const int i = AddTerceto(
					terceto,
					NewOperator(ultimoOperador),
					___,
					___
				);
				Push(&stack, i);
				}
		 | cond {
				branchIdx = AddTerceto(
					terceto,
					NewOperator(ultimoOperador),
					___,
					___
				);
				Push(&stack, branchIdx);
		 } AND cond {
				printf("Condicion multiple ");
				huboAnd = true;
				/* branch */
				const int i = AddTerceto(
					terceto,
					NewOperator(ultimoOperador),
					___,
					___
				);
				Push(&stack, i);
				}
		 ;

cond: NOT cond {printf("Negacion de condicion ");}
		| PR_ABR cond PR_CRR
		| operando {primerOperandoIdx = operandoIdx;} oplog operando {
				condIdx = AddTerceto(
					terceto,
					NewOperator("cmp"),
					NewIndexRef(primerOperandoIdx),
					NewIndexRef(operandoIdx)
				);
				strcpy(ultimoOperador, $3);
			}
		| eqcond {
			AddTerceto(
				terceto,
				NewOperator("cmp"),
				NewValue("@minmax"),
				NewIndexRef(exprIdx)
			);
			strcpy(ultimoOperador, "BNE");
			}
		;

oplog: EQ  {printf("EQ ") ; strcpy($$, "BNE"); /* paso el contrario */}
		 | NEQ {printf("NEQ "); strcpy($$, "BEQ"); /* para facilitar el */}
		 | LT  {printf("LT ") ; strcpy($$, "BGE"); /* branch de asm     */}
		 | LEQ {printf("LEQ "); strcpy($$, "BGT");}
		 | GT  {printf("GT ") ; strcpy($$, "BLE");}
		 | GEQ {printf("GEQ "); strcpy($$, "BLT");}
		 ;

eqcond: eqop PR_ABR expr COMA lista_ids PR_CRR {
			int idIdx = Pop(&eqStack);
			AddTerceto(
				terceto,
				NewValue("="),
				NewValue("@minmax"),
				NewIndexRef(idIdx)
			);
			while ( !Stack_IsEmpty(&eqStack) ) {
				idIdx = Pop(&eqStack);
				int idx = AddTerceto(
					terceto,
					NewOperator("cmp"),
					NewValue("@minmax"),
					NewIndexRef(idIdx)
				);
				AddTerceto(
					terceto,
					NewOperator(isMax ? "BLE" : "BGE"),
					NewIndexRef(idx+3),
					___
				);
				AddTerceto(
					terceto,
					NewOperator("="),
					NewValue("@minmax"),
					NewIndexRef(idIdx)
				);
				}
			}
			| eqop PR_ABR expr COMA lista_const PR_CRR {
			int idIdx = Pop(&eqStack);
			AddTerceto(
				terceto,
				NewValue("="),
				NewValue("@min"),
				NewIndexRef(idIdx)
			);
			while ( !Stack_IsEmpty(&eqStack) ) {
				idIdx = Pop(&eqStack);
				int idx = AddTerceto(
					terceto,
					NewOperator("cmp"),
					NewValue("@min"),
					NewIndexRef(idIdx)
				);
				AddTerceto(
					terceto,
					NewOperator(isMax ? "BLE" : "BGE"),
					NewIndexRef(idx+3),
					___
				);
				AddTerceto(
					terceto,
					NewOperator("="),
					NewValue("@min"),
					NewIndexRef(idIdx)
				);
				}
			}
		 ;

eqop: EQUMIN {printf("EQUMIN "); isMax = false;}
		| EQUMAX {printf("EQUMAX "); isMax = true;}
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


ids: ID {
		strcpy($$, $1);
		szLista = 1;
		Clear(&eqStack);
		const int i = AddTerceto(terceto, NewValue($1), ___, ___);
		Push(&eqStack, i);
		}
	 | ids COMA ID {
		strcpy($$, $1);
		strcat($$, ",");
		strcat($$, $3);
		szLista++;

		const int i = AddTerceto(terceto, NewValue($1), ___, ___);
		Push(&eqStack, i);
		}
	 ;

tipos: tipo {strcpy($$, $1);}
		 | tipos COMA tipo {strcpy($$, $1); strcat($$, ","); strcat($$, $3);}
		 ;

tipo: REAL {strcpy($$, "real");} | STRING_T {strcpy($$, "string");} | INT {strcpy($$, "int");};

/* =========================
 * ASIGNACION
 * ========================= */

assg: left ASIGN assg {
			printf("Asignacion multiple ");
			assgIdx = AddTerceto(
				terceto,
				NewOperator("="),
				NewValue($1),
				NewIndexRef(assgIdx)
			);
			}
		| left ASIGN right {
			printf("Asignacion ");
			assgIdx = AddTerceto(
				terceto,
				NewOperator("="),
				NewValue($1),
				NewIndexRef(rightIdx)
			);
			}
		;

left: ID {CheckId($1); strcpy($$, $1);}
		;

right: expr { rightIdx = exprIdx; }
		 | str_const { rightIdx = strConstIdx; }
		 ;

str_const: STR {
				 printf("CONST_STR ");
				 AddString($1);
				 strConstIdx = AddTerceto(terceto, NewValue($1), ___, ___);
				 }
	 ;

/* =========================
 * ARITMETICA
 * ========================= */

expr:
		expr SUM termino {
			printf("Suma ");
			exprIdx = AddTerceto(
				terceto,
				NewOperator("+"),
				NewIndexRef(exprIdx),
				NewIndexRef(terminoIdx)
			);
			}
		| expr MIN termino {
			printf("Resta ");
			exprIdx = AddTerceto(
				terceto,
				NewOperator("-"),
				NewIndexRef(exprIdx),
				NewIndexRef(terminoIdx)
			);
			}
		| termino { exprIdx = terminoIdx; }
		;

termino: termino MULT factor {
				printf("Multiplicacion: ");
				terminoIdx = AddTerceto(
					terceto,
					NewOperator("*"),
					NewIndexRef(terminoIdx),
					NewIndexRef(factorIdx)
				);
				}
			 | termino DIV factor {
				printf("Division: ");
				terminoIdx = AddTerceto(
					terceto,
					NewOperator("/"),
					NewIndexRef(terminoIdx),
					NewIndexRef(factorIdx)
				);
				}
			 | factor { terminoIdx = factorIdx; }
			 ;

factor: PR_ABR expr PR_CRR {
			printf("Expresion en parentesis ");
			factorIdx = exprIdx;
			}
		| llong {
			printf("LONGITUD ");
			char buf[100] = {0};
			sprintf(buf, "%d", szLista);
			factorIdx = AddTerceto(terceto, NewValue(buf), ___, ___);
			}
		| ID {
				CheckId($1);
				printf("ID ");
				factorIdx = AddTerceto(terceto, NewValue($1), ___, ___);
			}
		| const_num { factorIdx = constNumIdx; }
		;


const_num: CONST_R {
				 printf("CONST_R ");
				 AddReal($1);
				 constNumIdx = AddTerceto(terceto, NewValue($1), ___, ___);
				 }
		| CONST_INT {
				printf("CONST_INT ");
				AddInteger($1);
				constNumIdx = AddTerceto(terceto, NewValue($1), ___, ___);
				}
		;

llong: LEN PR_ABR lista_ids PR_CRR
		 | LEN PR_ABR lista_const PR_CRR
		 ;

lista_const: CR_ABR constantes CR_CRR
					 ;

constantes: constante {
						szLista = 1;
						Clear(&eqStack);
						Push(&eqStack, constIdx);
						}
					| constantes COMA constante {
						szLista++;
						Push(&eqStack, constIdx);
						}
					;

constante: const_num { constIdx = constNumIdx; }
				 | str_const { constIdx = strConstIdx; }
				 ;

/* =========================
 * IO
 * ========================= */

iostmt: PRINT operando {
			printf("PRINT ");
			AddTerceto(terceto, NewOperator("PRINT"), NewIndexRef(operandoIdx), ___);
			}
			| GET ID {
			CheckId($2);
			printf("GET ");
			AddTerceto(terceto, NewOperator("GET"), NewValue($2), ___);
			}
			;

operando: expr {operandoIdx = exprIdx;}
				| str_const {operandoIdx = strConstIdx;};

%%
/* end of grammar */

int main(int argc, char *argv[]) {
	sym_table = NewList();
	terceto = NewTerceto();
	tercetos = fopen("intermedio.txt", "wt+");
	InitStack(&stack);
	InitStack(&eqStack);

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

	fflush(NULL);
}

/**
 * Crea un mensaje del tipo "Cerca de la linea x: ... \n". "..." con lo que se
 * mande en fmt. Funciona como printf
 */
void yyerror(char *fmt, ...) {
	va_list ap;
	va_start(ap, fmt);

	/* Creo el comienzo del mensaje */
	char buf[4096];
	snprintf(buf, 4096 - 1, "Cerca de la linea %d: ", yylineno);

	/* le agrego el mensaje formateado */
	const size_t len = strlen(buf);
	vsnprintf(buf + len, 4096 - len - 1, fmt, ap);

	/* un \n para que quede bien */
	strcat(buf, "\n");

	fflush(stdout); /* por si stdout es igual que stderr */

	/* imprimo el mensaje de error */
	fputs(buf, stderr);
	fflush(NULL); /* hago flush de todos */

	va_end(ap);
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

	if ( *id_start && !*type_start ) {
		yyerror("Error de declaracion: la cantidad de tipos de datos debe ser "
			"igual a la cantidad de identificadores.");
		exit(1);
	}

	if ( !*id_start && *type_start ) {
		yyerror("Error de declaracion: la cantidad de identificadores debe ser "
			"igual a la cantidad de tipos de datos.");
		exit(1);
	}
}

/**
 * Verifica que un id se encuentre en la tabla de simbolos.
 * Si no se encuentra, print de error y exit(1);
 */
void CheckId(const char *const id)
{
	if ( Lookup(&sym_table, id) == NULL ) { /* no se ha declarado */
		yyerror("No se ha declarado la variable \"%s\"", id);
		exit(1);
	}
}

/**
 * Realiza una busqueda en la lista por name del Symbol
 * En caso de no encontrarlo, retorna NULL.
 * El puntero retornado es una variable static, por lo tanto, no deberia ser
 * utilizado luego de otra llamada a Lookup, dado que su valor puede cambiar.
 */
Symbol *Lookup(const List *const lst, const char *const name)
{
	ListIterator it = Iterator(lst);
	while ( HasNext(&it) ) {
		static Symbol s;
		s = Next(&it);
		if ( strcmp(s.name, name) == 0 )
			return &s;
	}

	return NULL;
}

TercEntry NewOperator(const char *const op)
{
	return (TercEntry){
		.data = op,
		.type = TERC_OP
	};
}

TercEntry NewValue(const char *const value)
{
	return (TercEntry){
		.data = value,
		.type = TERC_VAL
	};
}

TercEntry NewIndexRef(const int idx)
{
	int *val = malloc(sizeof(int));
	if ( val == NULL ) {
		fprintf(stderr, "error malloc NewIndexRef\n");
		exit(1);
	}
	*val = idx;

	return (TercEntry){
		.data = val,
		.type = TERC_IDX
	};
}

TercEntry NewVoid(void)
{
	return (TercEntry){
		.data = NULL,
		.type = TERC_VOID
	};
}

char *OperadorContrario(const char *op)
{
	static char *ret;
	if ( strcmp(op, "BNE") == 0 ) {
		ret = "BEQ";
	} else if ( strcmp(op, "BEQ") == 0 ) {
		ret = "BNE";
	} else if ( strcmp(op, "BGE") == 0 ) {
		ret = "BLT";
	} else if ( strcmp(op, "BGT") == 0 ) {
		ret = "BLE";
	} else if ( strcmp(op, "BLE") == 0 ) {
		ret = "BGT";
	} else if ( strcmp(op, "BLT") == 0 ) {
		ret = "BGE";
	} else {
		yyerror("error, operador invalido: %s\n", op);
		exit(1);
	}

	return ret;
}

