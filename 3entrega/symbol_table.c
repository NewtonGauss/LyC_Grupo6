#include "symbol_table.h"
#include <stdlib.h>
#include <string.h>
#include <assert.h>

List NewList(void)
{
	const List lst = NULL;

	return lst;
}


void AddSymbol(List *lst, const Symbol * const sym)
{
	Node *new = malloc(sizeof(Node));
	assert( new != NULL );

	int cmp = -1;
	while ( *lst != NULL
			&& ( cmp = strcmp((*lst)->sym.name, sym->name) ) < 0 ) {
		lst = &((*lst)->next);
	}

	/* ya esta en la lista */
	if ( cmp == 0 )
		return;

	/* Agrego el simbolo en orden */
	new->sym = *sym;
	new->next = *lst;
	*lst = new;
}



ListIterator Iterator(const List * const lst)
{
	assert(lst != NULL);

	ListIterator it = {
		.current_node = *lst
	};

	return it;
}



bool HasNext(ListIterator *it)
{
	assert(it != NULL);
	return it->current_node != NULL;
}


Symbol Next(ListIterator *it)
{
	assert(it != NULL);
	assert(it->current_node != NULL);

	/* guardo el simbolo a retornar y avanzo */
	const Symbol sym = it->current_node->sym;
	it->current_node = it->current_node->next;

	return sym;
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

char *ConstantName(const char *const val)
{
	static char buf[SYM_NAME_SZ+1];
	strcpy(buf, "_");

	if ( val[0] == '"' )
		strcat(buf, val+1);
	else
		strcat(buf, val);

	char *ptr;
	while ( (ptr = strchr(buf, ' ')) != NULL ) {
		*ptr = '_';
	}

	const size_t len = strlen(buf);
	if ( len > 0 && buf[len-1] == '"' )
		buf[len-1] = 0;

	return buf;
}

