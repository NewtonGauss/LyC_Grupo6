#include "symbol_table.h"
#include <stdlib.h>
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

	/* Recorro lista hasta el final */
	while ( *lst != NULL ) {
		lst = &((*lst)->next);
	}

	/* Agrego el simbolo al final de la lista */
	new->sym = *sym;
	new->next = NULL;
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


