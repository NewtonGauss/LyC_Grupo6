#include "stack.h"

#include <assert.h>

void InitStack(Stack *s) { s->idx = 0; }

void Push(Stack *s, const int d)
{
	assert(s->idx + 1 <= STACK_SZ);
	s->data[s->idx++] = d;
}

int Pop(Stack *s)
{
	int popped = s->data[--s->idx];

	assert(s->idx >= 0);
	return popped;
}

bool Stack_IsEmpty(const Stack * const s)
{
	return s->idx == 0;
}
