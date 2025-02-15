%{
#include <stdlib.h>
#include <errno.h>
#include <string.h>

#include "y.tab.h"

char *str_dup(const char * const str);
void errtok(const char * const msg);

extern FILE *lexout;
%}
%option noyywrap
%option yylineno

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

/* Temas especiales */
/* Longitud de lista */
LEN len

/* EQUMAX y EQUMIN */
EQUMAX eqmax
EQUMIN eqmin

%%

{COMMENT} /* discard */

{CONST_INT} {
						char *yydup = str_dup(yytext), *ret;

						errno = 0;
						long num = strtol(yydup, &ret, 10);

						if ( errno != 0 || (num > 32767 || num < -32768) )
							{
							// TODO: return error?
							errtok("entero fuera de rango");
							}

						strcpy(yylval.strval, yydup);
						free(yydup);
						fprintf(lexout, "CONST_INT");

						return CONST_INT;
						}
{CONST_R} {
					char *yydup = str_dup(yytext), *ret;

					errno = 0;
					float num = strtof(yydup, &ret);

					if ( errno != 0 )
					{
						// TODO: return error?
						errtok("real fuera de rango");
					}

					strcpy(yylval.strval, yydup);
					free(yydup);
					fprintf(lexout, "CONST_R");

					return CONST_R;
					}
{STR} {
			if ( strlen(yytext) > 30 )
				{
				// TODO: return error?
				errtok("string mayor a 30 caracteres");
				}

			strcpy(yylval.strval, yytext);
			fprintf(lexout, "STR");
			return STR;
			}

{LEN} {fprintf(lexout, "LEN"); return LEN;}
{EQUMAX} {fprintf(lexout, "EQUMAX"); return EQUMAX;}
{EQUMIN} {fprintf(lexout, "EQUMIN"); return EQUMIN;}

{SUM} {fprintf(lexout, "SUM"); return SUM;}
{MIN} {fprintf(lexout, "MIN"); return MIN;}
{DIV} {fprintf(lexout, "DIV"); return DIV;}
{MULT} {fprintf(lexout, "MULT"); return MULT;}

{EQ}  {fprintf(lexout, "EQ"); return EQ;}
{NEQ} {fprintf(lexout, "NEQ"); return NEQ;}
{LT}  {fprintf(lexout, "LT"); return LT;}
{LEQ} {fprintf(lexout, "LEQ"); return LEQ;}
{GT}  {fprintf(lexout, "GT"); return GT;}
{GEQ} {fprintf(lexout, "GEQ"); return GEQ;}
{NOT} {fprintf(lexout, "NOT"); return NOT;}
{AND} {fprintf(lexout, "AND"); return AND;}
{OR}  {fprintf(lexout, "OR"); return OR;}

{IF}    {fprintf(lexout, "IF"); return IF;}
{ELSE}  {fprintf(lexout, "ELSE"); return ELSE;}
{WHILE} {fprintf(lexout, "WHILE"); return WHILE;}

{ASIGN} {fprintf(lexout, "ASIGN"); return ASIGN;}

{VAR}  {fprintf(lexout, "VAR"); return VAR;}
{AS}   {fprintf(lexout, "AS"); return AS;}
{COMA} {fprintf(lexout, "COMA"); return COMA;}

{INT}      {fprintf(lexout, "INT"); return INT;}
{REAL}     {fprintf(lexout, "REAL"); return REAL;}
{STRING_T} {fprintf(lexout, "STRING_T"); return STRING_T;}

{END_STMT} {fprintf(lexout, "%s", yytext); return END_STMT;}
{NL} {
			yylineno++;
			fprintf(lexout, "%s", yytext);

			return NL;
		 }

{GET}   {fprintf(lexout, "GET"); return GET;}
{PRINT} {fprintf(lexout, "PRINT"); return PRINT;}

{ID} {fprintf(lexout, "ID"); strcpy(yylval.strval, yytext); return ID;}
{LL_ABR} {fprintf(lexout, "LL_ABR"); return LL_ABR;}
{LL_CRR} {fprintf(lexout, "LL_CRR"); return LL_CRR;}
{CR_ABR} {fprintf(lexout, "CR_ABR"); return CR_ABR;}
{CR_CRR} {fprintf(lexout, "CR_CRR"); return CR_CRR;}
{PR_ABR} {fprintf(lexout, "PR_ABR"); return PR_ABR;}
{PR_CRR} {fprintf(lexout, "PR_CRR"); return PR_CRR;}

{WHITE} fprintf(lexout, "%s", yytext); /* me como el texto, lo imprimo en out, pero no lo mando al sintactico */
. {errtok("desconocido"); /*TODO: return error ?*/}

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

