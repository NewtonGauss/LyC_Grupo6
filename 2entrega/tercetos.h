#ifndef TERCETOS_H
#define TERCETOS_H

#include <stdio.h>

typedef void* Terceto;

typedef enum {
	TERC_IDX, /* indice que representa el terceto a referenciar */
	TERC_OP, /* srting que representa el operador a poner */
	TERC_VAL, /* string que representa el valor a poner */
	TERC_VOID, /* entry vacia */
	TERC_SZ /* indica el tamaño del enum */
} TercType;

typedef struct {
	const void *const data; /* TODO: cambiar por un union type */
	TercType type;
} TercEntry;

/** archivo temporal donde se guardan los tercetos */
extern FILE* tercetos;

Terceto NewTerceto(void);
int AddTerceto(Terceto t, TercEntry e1, TercEntry e2, TercEntry e3);
void FillVoid(Terceto t, int idxToFill, int branchIdx);

#endif
