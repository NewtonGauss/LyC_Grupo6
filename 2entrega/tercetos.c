#include "tercetos.h"
#include <string.h>
#include <stdlib.h>

static int _idx_terceto = 0;

Terceto NewTerceto(void)
{
	return NULL;  /* por compatibilidad con el futuro */
}

int AddTerceto(Terceto t, TercEntry e1, TercEntry e2, TercEntry e3)
{
# define STRB_SZ 2048
	char strb[STRB_SZ+1] = {0};
	TercEntry entries[3] = {e1, e2, e3};

	int written = 0;

	/* formato idx: |x|y|w|\n */
	written = sprintf(strb, "%d: ", _idx_terceto);
	strcat(strb, "|");
	char *ptr = strb + written + 1;
	for ( register int i = 0; i < 3; ++i ) {
		switch ( entries[i].type ) {
		case TERC_IDX:
			written = sprintf(ptr, "[%d]", *(int*)entries[i].data);
			break;
		case TERC_OP:
			written = sprintf(ptr, "%s", (char*)entries[i].data);
			break;
		case TERC_VAL:
			written = sprintf(ptr, "%s", (char*)entries[i].data);
			break;
		case TERC_VOID:
			written = sprintf(ptr, "___");
			break;
		default:
			fprintf(stderr, "error, tipo de terceto inesperado\n");
			exit(1);
		}
		strcat(strb, "|");
		ptr += written + 1;
	}
	fprintf(tercetos, "%s\n", strb);

	return _idx_terceto++;
}

void FillVoid(Terceto t, int idxToFill, int branchIdx) {}
