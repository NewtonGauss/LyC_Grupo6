#include "symbol_table.h"
#include "tercetos.h"
#include "stack.h"
#include <string.h>
#include <stdlib.h>

#define DATA_HEADER "include macros2.asm\n"\
"include number.asm\n"\
".MODEL LARGE\n"\
".386\n"\
".STACK 200h\n"\
".DATA\n"

#define CODE_HEADER ".CODE\n"\
"start:\n"\
"MOV EAX,@DATA\n"\
"MOV DS,EAX\n"\
"MOV ES,EAX\n"

#define CODE_END "MOV EAX, 4c00h\n"\
"INT 21h\n"\
"END start;\n"

static void assembleData(FILE *out, const List *symbols);
static void assembleValues(FILE *out, const List *symbols, TercEntry e);
static void assembleOperation(
		FILE *out,
		const List *symbols,
		Stack *stack,
		int i,
		Terceto t,
		TercEntry e1,
		TercEntry e2,
		TercEntry e3
);
static int isArithmeticOperator(const char *op);
static char *arithmeticOperation(const char *op);
static int isBranchOperator(const char *op);
static char *branchOperation(const char *op);
static void assemblePrint(FILE *out, const List *symbols, TercEntry e);

static int strequals(const char *const a, const char *const b)
{
	return strcmp(a, b) == 0;
}

void GenerateAssembly(const List *symbols, Terceto t)
{
	FILE *out = fopen("Final.asm", "wt");

	assembleData(out, symbols);
	fprintf(out, "%s\n", CODE_HEADER);

	const int sz = CurrentIndex(t)-1;
	Stack stack;
	InitStack(&stack);
	for ( register int i = 0; i < sz; i++ ) {
		if ( !Stack_IsEmpty(&stack) && Peek(&stack) == i ) {
			Pop(&stack);
			fprintf(out, "@et%d:\n", i);
		}
		TercEntries terceto = t->entries[i];
		TercEntry e1 = terceto.first, e2 = terceto.second, e3 = terceto.third;
		if ( e1.type == TERC_OP ) {
			assembleOperation(out, symbols, &stack, i, t, e1, e2, e3);
		} else if ( e1.type == TERC_VAL ) {
			assembleValues(out, symbols, e1);
		}
	}

	fprintf(out, "%s\n", CODE_END);
}

static void assembleData(FILE *out, const List *symbols)
{
	fprintf(out, "%s\n", DATA_HEADER);
	ListIterator it = Iterator(symbols);
	while ( HasNext(&it) ) {
		const Symbol s = Next(&it);
		const int esConst = strlen(s.value) != 0;
		if ( s.type == TABLE_INT || s.type == TABLE_REAL ) {
			if ( esConst ) {
				fprintf(out, "%s dd %s\n", s.name, s.value);
			} else {
				fprintf(out, "%s dd ?\n", s.name);
			}
		} else if ( s.type == TABLE_STRING ) {
			fprintf(out, "%s db %s, '$', %ld dup (?)\n", s.name, s.value, s.len);
		}
	}
	fprintf(out, "%s dd ?\n", "@aux");
	fprintf(out, "\n");
}

static void assembleOperation(
		FILE *out,
		const List *symbols,
		Stack *stack,
		int i,
		Terceto t,
		TercEntry e1,
		TercEntry e2,
		TercEntry e3
) {
	char *op = (char*)e1.data;
	if ( strequals(op, "=") ) {
		Symbol *id = Lookup(symbols, (char*)e2.data);
		if ( id->type != TABLE_STRING ) {
			fprintf(out, "FSTP %s\n", id->name);
		}
	} else if ( isArithmeticOperator(op) ) {
		fprintf(out, "%s\n", arithmeticOperation(op));
		fprintf(out, "FSTP @aux\n"); // limpio la posicion 0 de pila.
	} else if ( strequals(op, "cmp") ) {
		fprintf(out, "FXCH\nFCOM\nFSTSW AX\nSAHF\n");
	} else if ( isBranchOperator(op) ) {
		const int jumpIdx = *(int*)e2.data;
		if ( jumpIdx > i )
			Push(stack, jumpIdx);
		fprintf(out, "%s @et%d\n", branchOperation(op), jumpIdx);
	} else if ( strequals(op, "PRINT") ) {
		assemblePrint(out, symbols, e2);
	} else if ( strequals(op, "GET") ) {
		fprintf(out, "getFloat %s\n", (char*)e2.data);
	} else if ( strequals(op, "ET") ) {
		fprintf(out, "@et%d:\n", i);
	}
}

static void assembleValues(FILE *out, const List *symbols, TercEntry e) {
	Symbol *s;
	/* Para valores */
	if ( (s = Lookup(symbols, (char*)e.data)) != NULL ) {
		/* es un id */
		if ( s->type == TABLE_INT ) {
			fprintf(out, "FILD %s\n", s->name);
		} else if ( s->type == TABLE_REAL ) {
			fprintf(out, "FLD %s\n", s->name);
		}
	} else if ( (s = Lookup(symbols, ConstantName((char*)e.data))) != NULL ) {
		/* es constante */
		if ( s->type == TABLE_INT ) {
			fprintf(out, "FILD %s\n", s->name);
		} else if ( s->type == TABLE_REAL ) {
			fprintf(out, "FLD %s\n", s->name);
		}
	}
}

static int isArithmeticOperator(const char *op)
{
	return strequals(op, "+")
		|| strequals(op, "-")
		|| strequals(op, "*")
		|| strequals(op, "/");
}

static char *arithmeticOperation(const char *op)
{
	if (strequals(op, "+")) return "FADD";
	if (strequals(op, "-")) return "FSUB";
	if (strequals(op, "*")) return "FMUL";
	if (strequals(op, "/")) return "FDIV";
	return NULL;
}

static int isBranchOperator(const char *op)
{
	return strequals(op, "BNE")
		||   strequals(op, "BEQ")
		||   strequals(op, "BGE")
		||   strequals(op, "BGT")
		||   strequals(op, "BLE")
		||   strequals(op, "BLT")
		||   strequals(op, "BRA");
}

static char *branchOperation(const char *op)
{
	if (strequals(op, "BNE")) return "JNE";
	if (strequals(op, "BEQ")) return "JE";
	if (strequals(op, "BGE")) return "JAE";
	if (strequals(op, "BGT")) return "JA";
	if (strequals(op, "BLE")) return "JNA";
	if (strequals(op, "BLT")) return "JB";
	if (strequals(op, "BRA")) return "JMP";
	return NULL;
}

static void assemblePrint(FILE *out, const List *symbols, TercEntry e) {
	Symbol *s;
	if ( (s = Lookup(symbols, (char*)e.data)) != NULL ) {
		/* es un id */
		if ( s->type == TABLE_INT || s->type == TABLE_REAL ) {
			fprintf(out, "displayFloat %s\n", s->name);
		} else if ( s->type == TABLE_STRING ) {
			fprintf(out, "displayString %s\n", s->name);
		}
		fprintf(out, "newLine 1\n");
	} else if ( (s = Lookup(symbols, ConstantName((char*)e.data))) != NULL ) {
		if ( s->type == TABLE_INT || s->type == TABLE_REAL ) {
			fprintf(out, "displayFloat %s\n", s->name);
		} else if ( s->type == TABLE_STRING ) {
			fprintf(out, "displayString %s\n", s->name);
		}
		fprintf(out, "newLine 1\n");
	}
}
