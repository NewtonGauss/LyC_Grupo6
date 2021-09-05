lexer: Lexico.l
	bison -dy Sintactico.y
	flex Lexico.l
	gcc lex.yy.c y.tab.c -lfl -o parser
