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
			if ( _idx_terceto <= 10 )
				written = sprintf(ptr, "___");
			else if ( _idx_terceto <= 100 )
				written = sprintf(ptr, "____");
			else if ( _idx_terceto <= 1000 )
				written = sprintf(ptr, "_____");
			else
				written = sprintf(ptr, "______");
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

void FillVoid(Terceto t, int idxToFill, int branchIdx) {
	rewind(tercetos);
	char buf[257];
	while ( idxToFill >= 0 && fgets(buf, 256, tercetos) != NULL ) {
		idxToFill--;
	}
	const size_t sz = strlen(buf);
	/* Vuelvo al inicio del registro */
	fseek(tercetos, sz * -1, SEEK_CUR);

	/* hago el masajeo de buf: agrero el idx donde corresponde */
	/* un registro es %d: |%s|%s|%s| */
	/* quiero cambiar la segunda cadena */
	char *ptr = strchr(buf, '|');
	ptr = strchr(ptr+1, '|'); // busco el segundo |
	sprintf(ptr+1, "[%d]", branchIdx);
	fprintf(tercetos, "%s", buf);

	fseek(tercetos, 0, SEEK_END);
}

int CurrentIndex(void) { return _idx_terceto; }
