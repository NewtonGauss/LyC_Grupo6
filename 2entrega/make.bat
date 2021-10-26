C:\GnuWin32\bin\flex.exe Lexico.l
C:\GnuWin32\bin\bison.exe -dyv Sintactico.y
C:\MinGW\bin\gcc.exe -std=c99 -o parser.exe -w lex.yy.c y.tab.c symbol_table.c tercetos.c stack.c

