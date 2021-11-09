#include "symbol_table.h"
#include "tercetos.h"
#include "stack.h"
#include <string.h>
#include <stdlib.h>

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
		fprintf(out, "newline 1\n");
	} else if ( (s = Lookup(symbols, ConstantName((char*)e.data))) != NULL ) {
		if ( s->type == TABLE_INT || s->type == TABLE_REAL ) {
			fprintf(out, "displayFloat %s\n", s->name);
		} else if ( s->type == TABLE_STRING ) {
			fprintf(out, "displayString %s\n", s->name);
		}
		fprintf(out, "newline 1\n");
	}
}
