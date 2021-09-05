%{
#include <stdlib.h>
#include <errno.h>

#include "y.tab.h"

char *str_dup(const char * const str);
void errtok(const char * const msg);

extern FILE *lexout;
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
						fprintf(lexout, "CONST_INT");
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
					fprintf(lexout, "CONST_R");
					}
{STR} {
			if ( strlen(yytext) > 30 )
				{
				errtok("string mayor a 30 caracteres");
				}

			fprintf(lexout, "STR");
			}

{SUM} {fprintf(lexout, "SUM");}
{MIN} {fprintf(lexout, "MIN");}
{DIV} {fprintf(lexout, "DIV");}
{MULT} {fprintf(lexout, "MULT");}

{EQ}  {fprintf(lexout, "EQ");}
{NEQ} {fprintf(lexout, "NEQ");}
{LT}  {fprintf(lexout, "LT");}
{LEQ} {fprintf(lexout, "LEQ");}
{GT}  {fprintf(lexout, "GT");}
{GEQ} {fprintf(lexout, "GEQ");}
{NOT} {fprintf(lexout, "NOT");}
{AND} {fprintf(lexout, "AND");}
{OR}  {fprintf(lexout, "OR");}

{IF}    {fprintf(lexout, "IF");}
{ELSE}  {fprintf(lexout, "ELSE");}
{WHILE} {fprintf(lexout, "WHILE");}

{ASIGN} {fprintf(lexout, "ASIGN");}

{VAR}  {fprintf(lexout, "VAR"); return VAR;}
{AS}   {fprintf(lexout, "AS"); return AS;}
{COMA} {fprintf(lexout, "COMA");}

{INT}      {fprintf(lexout, "INT");}
{REAL}     {fprintf(lexout, "REAL"); return REAL;}
{STRING_T} {fprintf(lexout, "STRING_T");}

{END_STMT} fprintf(lexout, "%s", yytext);
{NL} {
			yylineno++;
			fprintf(lexout, "%s", yytext);
		 }

{GET}   {fprintf(lexout, "GET");}
{PRINT} {fprintf(lexout, "PRINT");}

{ID} {fprintf(lexout, "ID"); return ID;}
{LL_ABR} {fprintf(lexout, "LL_ABR");}
{LL_CRR} {fprintf(lexout, "LL_CRR");}
{CR_ABR} {fprintf(lexout, "CR_ABR"); return CR_ABR;}
{CR_CRR} {fprintf(lexout, "CR_CRR"); return CR_CRR;}
{PR_ABR} {fprintf(lexout, "PR_ABR");}
{PR_CRR} {fprintf(lexout, "PR_CRR");}

{WHITE} fprintf(lexout, "%s", yytext);
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
//int main()
//{
//	yylex();
//}
