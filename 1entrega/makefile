parser: Lexico.l Sintactico.y
	bison -dy Sintactico.y
	flex Lexico.l
	gcc lex.yy.c y.tab.c -lfl -o parser

.PHONY: clean

clean:
	rm lex.yy.c parser y.tab.c y.tab.h
