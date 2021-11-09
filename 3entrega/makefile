parser: Lexico.l Sintactico.y symbol.o tercetos.o stack.o assembly.o
	bison -dy Sintactico.y
	flex Lexico.l
	gcc -g symbol.o tercetos.o stack.o assembly.o lex.yy.c y.tab.c -lfl -o parser

symbol.o: symbol_table.c symbol_table.h
	gcc -g -c -o symbol.o symbol_table.c

tercetos.o: tercetos.c tercetos.h
	gcc -g -c -o tercetos.o tercetos.c

stack.o: stack.c stack.h
	gcc -g -c -o stack.o stack.c

assembly.o: assembly.c
	gcc -g -c -o assembly.o assembly.c

.PHONY: clean

clean:
	rm lex.yy.c parser y.tab.c y.tab.h symbol.o lex.out tercetos.o stack.o assembly.o

.PHONY: test_sym

test_sym: symbol.o
	gcc -g -o test symbol_table_test.c symbol.o
	./test

