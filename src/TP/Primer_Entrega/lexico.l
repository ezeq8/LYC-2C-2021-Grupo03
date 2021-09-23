%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include <math.h>
#include "y.tab.h"

void mensajeDeError(int );

%}
%option noyywrap  
%option yylineno 


DIGITO		[0-9]
LETRA		[a-zA-Z]

CTE_REAL    	-?{DIGITO}{1,10}\.{DIGITO}{0,10}|-?{DIGITO}{0,10}\.{DIGITO}{1,10}
CTE_INT     	-?{DIGITO}+
ID				{LETRA}({LETRA}|{DIGITO})*

OP_ASIG   		":="
OP_LOGICO		["and"|"or"]
OP_NEGACION 	"not"
OP_DISTINTO		"<>"
OP_MAYORIGUAL	">="
OP_MENORIGUAL	"<="
OP_MAYOR		">"
OP_MENOR		"<"
OP_IGUAL		"=="
OP_SUMA         ["+"]
OP_DIVI         ["/"]
OP_REST         ["-"]
OP_MULT         ["*"]

P_A             ["("]
P_C             [")"]
LL_A            ["{"]
LL_C            ["}"]
C_A				["["]
C_C				["]"]

COMENT			\*-.*\-*
COMA			[","]
P_Y_C			[";"]
ESPACIO			[" "]
CTE_STRING 		\".*\"
INTEGER			"INTEGER"
FLOAT			"FLOAT"
STRING 			"STRING"
GET				"GET"
DISPLAY			"DISPLAY"

WHILE 			"WHILE"
IN				"IN"
DO				"DO"
ENDWHILE		"ENDWHILE"
IF				"IF"
ELSE			"ELSE"
DIM				"DIM"
AS				"AS"
EQUMAX			"EQUMAX"
EQUMIN			"EQUMIN"

%%


{INTEGER}		{
					printf("\nPalabra reservada: %s\n",yytext);
					return INTEGER;
				}
{FLOAT}			{
					printf("\nPalabra reservada: %s\n",yytext);
					return FLOAT;
				}
{STRING}		{
					printf("\nPalabra reservada: %s\n",yytext);
					return STRING;
				}
{IF}			{
					printf("\nPalabra reservada: %s\n",yytext);
					return IF;
				}
{ELSE}   		{
					printf("\nPalabra reservada: %s\n",yytext);
					return ELSE;
				}
{WHILE}	  		{
					printf("\nPalabra reservada: %s\n",yytext);
					return WHILE;
				}
{IN}	  		{
					printf("\nPalabra reservada: %s\n",yytext);
					return IN;
				}
{DO}	  		{
					printf("\nPalabra reservada: %s\n",yytext);
					return DO;
				}
{ENDWHILE}	  		{
					printf("\nPalabra reservada: %s\n",yytext);
					return ENDWHILE;
				}				
{DIM}			{
					printf("\nPalabra reservada: %s\n",yytext);
					return DIM;
				}
{AS}			{
					printf("\nPalabra reservada: %s\n",yytext);
					return AS;
				}
{EQUMAX}			{
					printf("\nPalabra reservada: %s\n",yytext);
					return EQUMAX;
				}
{EQUMIN}			{
					printf("\nPalabra reservada: %s\n",yytext);
					return EQUMIN;
				}

{GET}			{
					printf("\nPalabra reservada: %s\n",yytext);
					return GET;
				}
{DISPLAY}			{
					printf("\nPalabra reservada: %s\n",yytext);
					return DISPLAY;
				}







{OP_ASIG}		{
					printf("\nAsignacion: %s\n",yytext);
					return OP_ASIG;
				}
{OP_NEGACION}	{
					printf("\nNegacion: %s\n",yytext);
					return OP_NEGACION;
				}
{OP_SUMA}		{
					printf("\nSuma: %s\n",yytext);
					return OP_SUMA;
				}
{OP_REST}		{
					printf("\nResta: %s\n",yytext);
					return OP_REST;
				}
{OP_MULT}		{
					printf("\nMultiplicacion: %s\n",yytext);
					return OP_MULT;
				}
{OP_DIVI}		{
					printf("\nDivision: %s\n",yytext);
					return OP_DIVI;
				}
{COMA}			{
					printf("\nComa: %s\n",yytext);
					return COMA;
				}
{P_Y_C}			{
					printf("\nPunto y coma: %s\n",yytext);
					return P_Y_C;
				}
{P_A}			{
					printf("\nParentesis que abre: %s\n",yytext);
					return P_A;
				}
{P_C}			{
					printf("\nParentesis que cierra: %s\n",yytext);
					return P_C;
				}
{LL_A}			{
					printf("\nLlave que abre: %s\n",yytext);
					return LL_A;
				}
{LL_C}			{
					printf("\nLlave que cierra: %s\n",yytext);
					return LL_C;
				}
{C_A}			{
					printf("\nCorchete que abre: %s\n",yytext);
					return C_A;
				}
{C_C}			{
					printf("\nCorchete que cierra: %s\n",yytext);
					return C_C;
				}
				
{ID}			{
					printf("\nIdentificador: %s\n",yytext);
					if(strlen(yytext) <= 30){
						yylval.valor_string = strdup(yytext);
						return ID;
					}
					else {
						mensajeDeError(4);
					}
				}
				
{CTE_INT}		{
					printf("\nConstante entera: %s\n",yytext);
					if(atoll(yytext)>=-32768 && atoll(yytext)<=32767)
					{
						yylval.valor_int = atoi(yytext);
					}
					else
					{
						mensajeDeError(1);
					}
					
					return CTE_INT;
				}
{CTE_REAL}		{
					printf("\nConstante real: %s\n",yytext);
					if(atof(yytext)<=3.40282347e+38F)
					{
						yylval.valor_float = atof( yytext );
					}
					else{
						mensajeDeError(2);
					}
					return CTE_REAL;
				}
{CTE_STRING}	{
					printf( "\nConstante String: %s\n", yytext); 
					if(strlen(yytext)<=30){
						yylval.valor_string = strdup(yytext);
					}
					else{
						mensajeDeError(3);
					}
					return CTE_STRING;
				}
{OP_MAYOR}		{
					printf("\nOperador de comparacion: %s\n", yytext);
					return OP_MAYOR;
				}

{OP_MENOR}		{
					printf("\nOperador de comparacion: %s\n", yytext);
					return OP_MENOR;
				}

{OP_IGUAL}		{
					printf("\nOperador de comparacion: %s\n", yytext);
					return OP_IGUAL;
				}

{OP_MAYORIGUAL}	{
					printf("\nOperador de comparacion: %s\n", yytext);
					return OP_MAYORIGUAL;
				}

{OP_MENORIGUAL}	{
					printf("\nOperador de comparacion: %s\n", yytext);
					return OP_MENORIGUAL;
				}

{OP_DISTINTO}	{
					printf("\nOperador de comparacion: %s\n", yytext);
					return OP_DISTINTO;
				}
			
{OP_LOGICO}		{
				printf("\nOperador logico: %s\n", yytext);
				return OP_LOGICO;
				}

{COMENT} 

\n
\t
%%

void mensajeDeError(int error){

	switch(error){

        case 1:
            printf("ERROR LEXICO. Descripcion: Int fuera de rango. Debe ser un int de 16bits.\n");
            break ;

		case 2:
            printf("ERROR LEXICO. Descripcion: Float fuera de rango. Debe ser un float de 32bits.\n");
            break ;

        case 3:
            printf("ERROR LEXICO. Descripcion: String fuera de rango. La longitud maxima es de 30 caracteres.\n");
            break ;

		case 4:
			printf("ERROR LEXICO. Descripcion: Nombre de variable demasiado largo. La longitud maxima es de 30 caracteres.\n");
			break;
        }

    system ("Pause");
	exit (1);
	
}
