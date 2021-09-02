%{
#include <stdlib.h>
#include <errno.h>

char *str_dup(const char * const str);
void errtok(const char * const msg);
%}

/* patrones */
DIGIT [0-9]
LETRA [[:alpha:]]

/* identificador comienza con letra, contiene letras y digitos */
ID {LETRA}({LETRA}|{DIGIT})*

COMMENT \*\/.*\/\*

/* llaves, parentesis y corchetes */
LL_ABR \{
LL_CRR \}
CR_ABR \[
CR_CRR \]
PR_ABR \(
PR_CRR \)

/* constante entera */
CONST_INT {DIGIT}+

/* constante real */
CONST_R ({DIGIT}+\.{DIGIT}*)|({DIGIT}*\.{DIGIT}+)

/* string */
STR \"(([^\"]|\\\")*[^\\])?\"

/* operadores aritmeticos + - / * */
SUM  \+
MIN  \-
DIV  \/
MULT \*

/* operadores logicos */
EQ  ==
NEQ !=
LT  <
LEQ <=
GT  >
GEQ >=
NOT !
AND &&
OR  \|\|

/* flow control */
IF    if
ELSE  else
WHILE while

/* asignacion */
ASIGN =

/* declaracion */
VAR  var
AS   as
COMA ,

/* tipos de dato */
INT      int
REAL     real
STRING_T string

/* fin de instruccion */
END_STMT ;
NL \n

/* IO */
GET   get
PRINT print

/* otros */
WHITE [ \t]+

%%

{COMMENT} /* discard */

{CONST_INT} {
						char *yydup = str_dup(yytext), *ret;

						errno = 0;
						long num = strtol(yydup, &ret, 10);

						if ( errno != 0 || (num > 32767 || num < -32768) )
							{
							errtok("entero fuera de rango");
							}

						free(yydup);
						printf("CONST_INT");
						}
{CONST_R} {
					char *yydup = str_dup(yytext), *ret;

					errno = 0;
					float num = strtof(yydup, &ret);

					if ( errno != 0 )
					{
						errtok("real fuera de rango");
					}

					free(yydup);
					printf("CONST_R");
					}
{STR} {
			if ( strlen(yytext) > 30 )
				{
				errtok("string mayor a 30 caracteres");
				}

			printf("STR");
			}

{SUM} {printf("SUM");}
{MIN} {printf("MIN");}
{DIV} {printf("DIV");}
{MULT} {printf("MULT");}

{EQ}  {printf("EQ");}
{NEQ} {printf("NEQ");}
{LT}  {printf("LT");}
{LEQ} {printf("LEQ");}
{GT}  {printf("GT");}
{GEQ} {printf("GEQ");}
{NOT} {printf("NOT");}
{AND} {printf("AND");}
{OR}  {printf("OR");}

{IF}    {printf("IF");}
{ELSE}  {printf("ELSE");}
{WHILE} {printf("WHILE");}

{ASIGN} {printf("ASIGN");}

{VAR}  {printf("VAR");}
{AS}   {printf("AS");}
{COMA} {printf("COMA");}

{INT}      {printf("INT");}
{REAL}     {printf("REAL");}
{STRING_T} {printf("STRING_T");}

{END_STMT} ECHO;
{NL} {
			yylineno++;
			ECHO;
		 }

{GET}   {printf("GET");}
{PRINT} {printf("PRINT");}

{ID} {printf("ID");}
{LL_ABR} {printf("LL_ABR");}
{LL_CRR} {printf("LL_CRR");}
{CR_ABR} {printf("CR_ABR");}
{CR_CRR} {printf("CR_CRR");}
{PR_ABR} {printf("PR_ABR");}
{PR_CRR} {printf("PR_CRR");}

{WHITE} ECHO;
. {errtok("desconocido");}

%%

char *str_dup(const char * const str)
{
	char *new_str = malloc(strlen(str) + 1);
	if ( new_str == NULL ) {
		fprintf(stderr, "No hay espacio suficiente para compilar\n");
		exit(1);
	}

	strcpy(new_str, str);
	return new_str;
}

void errtok(const char * const msg)
{
	fprintf(stderr, "Token invalido en la linea %d: %s\n", yylineno, msg);
}

/* codigo C */
int main()
{
	yylex();
}
