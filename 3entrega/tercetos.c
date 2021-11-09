#include "tercetos.h"
#include <string.h>
#include <stdlib.h>

Terceto NewTerceto(void)
{
	Terceto t = malloc(sizeof(_terceto));
	return t;
}

int AddTerceto(Terceto t, TercEntry e1, TercEntry e2, TercEntry e3)
{
	TercEntries entries = (TercEntries) {
		.first = e1, .second = e2, .third = e3
	};
	t->entries[t->current++] = entries;
	return t->current-1;
}

void FillVoid(Terceto t, int idxToFill, int branchIdx) {
	int *filler = malloc(sizeof(int));
	*filler = branchIdx;
	t->entries[idxToFill].second.data = (void*)filler;
	t->entries[idxToFill].second.type = TERC_IDX;
}

int CurrentIndex(Terceto t) { return t->current+1; }

static void _print_entry(char *buf, TercEntry entry);

char *Printable(Terceto t, int idx)
{
# define BUF_SZ 1024
	static char buf[BUF_SZ+1];

	char e1[100];
	_print_entry(e1, t->entries[idx].first);

	char e2[100];
	_print_entry(e2, t->entries[idx].second);

	char e3[100];
	_print_entry(e3, t->entries[idx].third);

	int n = sprintf(buf, "%d: |%s|%s|%s|\n", idx, e1, e2, e3);
	buf[n] = 0;

	return buf;
}

static void _print_entry(char *buf, TercEntry entry) {
	switch ( entry.type ) {
	case TERC_IDX:
		sprintf(buf, "[%d]", *(int*)entry.data);
		break;
	case TERC_OP:
	case TERC_VAL:
		sprintf(buf, "%s", (char*)entry.data);
		break;
	case TERC_VOID:
		sprintf(buf, "___");
		break;
	default:
		fprintf(stderr, "error, tipo de terceto inesperado");
		exit(1);
	}
}
