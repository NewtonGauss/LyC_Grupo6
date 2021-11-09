#include "symbol_table.h"
#include "tercetos.h"
#include <string.h>

static void assembleValues(FILE *out, const List *symbols, TercEntry e);
static void assembleOperation(
		FILE *out,
		const List *symbols,
		Terceto t,
		TercEntry e1,
		TercEntry e2,
		TercEntry e3
);

static int strequals(const char *const a, const char *const b)
{
	return strcmp(a, b) == 0;
}

void GenerateAssembly(const List *symbols, Terceto t)
{
	FILE *out = fopen("Final.asm", "wt");
	const int sz = CurrentIndex(t);
	for ( register int i = 0; i < sz; i++ ) {
		TercEntries terceto = t->entries[i];
		TercEntry e1 = terceto.first, e2 = terceto.second, e3 = terceto.third;
		if ( e1.type == TERC_OP ) {
			assembleOperation(out, symbols, t, e1, e2, e3);
		} else if ( e1.type == TERC_VAL ) {
			assembleValues(out, symbols, e1);
		}
	}
}

static void assembleOperation(
		FILE *out,
		const List *symbols,
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
