#ifndef COMPILER_STACK_H
#define COMPILER_STACK_H

#define STACK_SZ 256

typedef struct {
	int data[STACK_SZ];
	int idx;
} Stack;

void InitStack(Stack *s);
void Push(Stack *s, const int d);
int Pop(Stack *s);

#endif
