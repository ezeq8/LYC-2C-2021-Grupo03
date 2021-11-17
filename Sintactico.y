%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <float.h>
#include <ctype.h>
#include "y.tab.h"

	/* Tipos de datos para la tabla de simbolos */
  #define Integer 1
	#define Float 2
	#define String 3
	#define CteInt 4
	#define CteReal 5
	#define CteString 6

	#define TAMANIO_TABLA 3000
	#define TAM_NOMBRE 32

	int yylex();
	
	/* Funciones necesarias */
	int yyerror(char* mensaje);
	void agregarVarATabla(char* nombre);
	void agregarTiposDatosATabla(void);
	void agregarCteStringATabla(char* str);
	void agregarCteIntATabla(int valor);
	void agregarCteRealATabla(float valor);
	void chequearVarEnTabla(char* nombre);
	int buscarEnTabla(char * name);
	void escribirNombreEnTabla(char* nombre, int pos);
	void guardarTabla(void);
	 char* definirOperador(char* operador);

	int yystopparser=0;
	FILE  *yyin;

	/* Estructura de tabla de simbolos */
	typedef struct {
		char nombre[TAM_NOMBRE];
		int tipo_dato;
		char valor_s[TAM_NOMBRE];
		float valor_f;
		int valor_i;
		int longitud;
	} simbolo;

	simbolo tabla_simbolo[TAMANIO_TABLA];
	int fin_tabla = -1;

	/* Globales para la declaracion de variables y la tabla de simbolos */
	int varADeclarar1 = 0;
	int cantVarsADeclarar = 0;
	int cantTipoDatoDeclarado = 0;
	int tipoDatoADeclarar;


	/*Globales para generacion de tercetos*/
	int contador_tercetos=0;
	char DELIMITADOR_TERCETO=',';
	char TERCETO_VACIO='_';
	int factor_ind=-1;
	int programa_ind=-1;
	int sentencia_ind=-1;
	int termino_ind=-1;
	int expresion_ind=-1;
	int asignacion_ind=-1;
	int entrada_ind=-1;
	int salida_ind=-1;
	int comparador_ind=-1;
	int condicion_ind=-1;
	int elem_lista_equ_ind=-1;
	int equmin_ind=-1;
	int equmax_ind=-1;
	int decision_ind=-1;
	int expresion_lado_izq_comp_ind=-1;
	int expresion_lado_der_comp_ind=-1;
	FILE* pfint;
	int intermedia_creada_con_exito=0;
	char aux_operador[30];
	
	typedef struct node node;
	struct node{
    	int data;
    	struct node *next;
	};
	

	typedef struct {
		int nro_terceto;
		char elem1[30];
		char elem2[30];
		char elem3[30];
	}terceto;

	terceto v_tercetos[1000];    //Funciona como una "Lista estatica". TODO: Reemplazar con una lista dinamica
	struct node *pila_condiciones = NULL;
	struct node *pila_factores = NULL;			
	struct node *pila_terminos = NULL;
	struct node *pila_expresiones = NULL;
	void display();
	void push(node**,int);
	int pop(node**);
	terceto crearNuevoTerceto(char * elem1,char* elem2,char* elem3);
	int agregarTerceto(terceto terc);
	void modificarTerceto(int nro_terceto,int nro_elem,char* txt );
	void escribirIntermedia();
	void avanzar();
	int ultimo_terceto_creado();
	terceto getTerceto(int nro_terceto);
	char* negarOperador(char* operador);
	int isEmpty(node**);
	int proximo_terceto();
%}

  /* Tipo de estructura de datos*/
  %union {
    int valor_int;
    float valor_float;
    char *valor_string;
  }

%token P_Y_C
%token COMA
%token P_A 
%token P_C
%token LL_A
%token LL_C
%token C_A
%token C_C
%token OP_SUMA
%token OP_REST
%token OP_MULT
%token OP_DIVI
%token OP_ASIG
%token OP_MAYOR
%token OP_MENOR
%token OP_IGUAL
%token OP_MAYORIGUAL
%token OP_MENORIGUAL
%token OP_DISTINTO
%token OP_LOGICO
%token OP_NEGACION
%token <valor_int>CTE_INT
%token <valor_float>CTE_REAL
%token <valor_string>CTE_STRING
%token IF 
%token ELSE	
%token ESPACIO
%token INTEGER
%token FLOAT
%token STRING
%token DIM
%token AS
%token GET
%token DISPLAY
%token WHILE
%token IN
%token DO
%token ENDWHILE
%token EQUMAX
%token EQUMIN
%token <valor_string>ID
%type <valor_string> comparador;
%%
programa:  	   	   
  bloque_declaracion bloque       {
                                    printf("Regla PROGRAMA es bloque_declaracion bloque\n");
                                    printf("COMPILACION EXITOSA\n");
                                    guardarTabla();
									escribirIntermedia();
                                  }
	|bloque						{
                                    printf("Regla PROGRAMA es bloque_declaracion bloque\n");
                                    printf("COMPILACION EXITOSA\n");
                                    guardarTabla();
									escribirIntermedia();
                                  }
;  

bloque_declaracion:         	        	
  bloque_declaracion declaracion {printf("Regla BLOQUE_DECLARACION es bloque_declaracion declaracion\n");}
  |declaracion                   {printf("Regla BLOQUE_DECLARACION es declaracion\n");}
;

declaracion:  
  DIM C_A lista_var C_C AS C_A lista_tipos C_C {printf("Regla DECLARACION\n");}
;

lista_var:  
  lista_var COMA ID              {
                                  printf("Regla LISTA_VAR es lista_var, ID\n");
								  	cantVarsADeclarar++;
                                  	agregarVarATabla(yylval.valor_string);
                                  }
  |ID                            {
                                  printf("Regla LISTA_VAR es id\n");
								  cantVarsADeclarar=0;
                                  agregarVarATabla(yylval.valor_string);
									varADeclarar1 = fin_tabla; /* Guardo posicion de primer variable de esta lista de declaracion. */
                                }
;

lista_tipos:
  lista_tipos COMA tipo_dato    {
                                  printf("Regla LISTA_TIPOS es lista_tipos,tipo_dato\n");
                                  cantTipoDatoDeclarado++;
								  agregarTiposDatosATabla();
                                }
  |tipo_dato                    {
                                  printf("Regla LISTA_TIPOS es tipo_dato\n");
								  cantTipoDatoDeclarado = 0;
                                  agregarTiposDatosATabla();
                                }
  ;

tipo_dato:
  INTEGER                       {
                                  printf("Regla TIPO_DATO es integer\n");
                                  tipoDatoADeclarar = Integer;
                                }
  |FLOAT                        {
                                  printf("Regla TIPO_DATO es float\n");
                                  tipoDatoADeclarar = Float;
                                }
  |STRING                       {
                                  printf("Regla TIPO_DATO es string\n");
                                  tipoDatoADeclarar = String;
                                }
;

bloque: 
  bloque sentencia              {printf("Regla BLOQUE es bloque sentencia\n");}
  |sentencia                    {printf("Regla BLOQUE es sentencia\n");}
;

sentencia:
  ciclo                         {printf("Regla SENTENCIA es ciclo\n");}
  |if                           {printf("Regla SENTENCIA es if\n");}
  |asignacion                   {printf("Regla SENTENCIA es asignacion\n");
  								}
  |salida                       {printf("Regla SENTENCIA es salida\n");}
  |entrada                      {printf("Regla SENTENCIA es entrada\n");}
  |ciclo_especial               {printf("Regla SENTENCIA es ciclo especial\n");}
;

ciclo:
	WHILE {push(&pila_condiciones,contador_tercetos);agregarTerceto(crearNuevoTerceto("ET",NULL,NULL));}P_A decision P_C {/*push(&pila_condiciones,ultimo_terceto_creado());*//*saco el push por las decisiones anidadas. que cada decision apile su terceto*//*avanzar();*/ /**/} LL_A bloque LL_C {printf("Regla CICLO es while(decision){bloque}\n");
																																																																char aux[30];															
																																																																int aux1=agregarTerceto(crearNuevoTerceto("BI",NULL,NULL));		//Escribir BI
																																																																int z=pop(&pila_condiciones);printf("Desapilando En el while\n");													//z=Desaplilar(tope de pila)
																																																																while(!isEmpty(&pila_condiciones)){    //Los primeros n elementos de la pila corresponden a las n condiciones. el ultimo elemento (fondo de pila) corresponde a la etiqueta del inicio del while.
																																																																	sprintf(aux,"[%d]",contador_tercetos); //escribir en terceto Z n celda actual(No hace falta sumar 1 porque el contador apunta ya al proximo terceto)
																																																																	modificarTerceto(z,2,aux);			//escribir en terceto Z n celda actual
																																																																	z=pop(&pila_condiciones);								
																																																																}
																																																																
																																																																
																																																																//z=pop(&pila_condiciones);							//z=Desaplilar(tope de pila). En esta implementacion no es necearia porque cuando sale del while la pila esta vacia y z tiene el ultimo elemento de la pila (fondo de pila)
																																																																sprintf(aux,"[%d]",z);				//Escribir Z(terceto) en la celda actual. Parte 1
																																																																modificarTerceto(aux1,2,aux);	    //Escribir Z(terceto) en la celda actual. Parte 2
																																																																}
;

ciclo_especial:
	WHILE ID IN C_A lista_expresion C_C DO LL_A bloque LL_C ENDWHILE {printf("Regla CICLO ESPECIAL es while especial(lista_expresion){bloque}\n");}
;

asignacion: 
	ID OP_ASIG expresion P_Y_C {
                                chequearVarEnTabla($1);
                                printf("Regla ASIGNACION es id:=expresion;\n");
								char aux1[30];
								sprintf(aux1,"[%d]",expresion_ind);
								asignacion_ind=agregarTerceto(crearNuevoTerceto(":=",$1,aux1));
                              }
;

if: 
	IF  P_A decision P_C LL_A bloque LL_C /*El while es para las condiciones anidadas. Hay que modificar todos los tercetos de todas las condiciones*/           {printf("Regla IF es if(decision){bloque}\n");while(!isEmpty(&pila_condiciones)) {int x=pop(&pila_condiciones);char aux[30];sprintf(aux,"[%d]",contador_tercetos);modificarTerceto(x,2,aux);}}
	|IF P_A decision P_C LL_A bloque LL_C ELSE { int z;
												while (!isEmpty(&pila_condiciones)){
													z=pop(&pila_condiciones);
													char aux [30];
													sprintf(aux,"[%d]",proximo_terceto()+1);   //Proximo terceto +1=terceto del BI
													modificarTerceto(z,2,aux);
												}
												z=agregarTerceto(crearNuevoTerceto("BI",NULL,NULL));
												push(&pila_condiciones,z);  //o ´push(&pila_condiciones,ultimo_terceto_creado) //Inicio del codigo del else
	} LL_A bloque LL_C {
						printf("Regla IF es if(decision){bloque} else {bloque}\n");
						int z=pop(&pila_condiciones);
						char aux[30];
						printf("aaaa");
						sprintf(aux,"[%d]",proximo_terceto());
						modificarTerceto(z,2,aux);
						}  //TODO: devuelve un error de conflicto cuando intento agregar accion semantica en el medio de la regla si estan las 2 reglas del if (if y if else)	

;

decision:
  condicion OP_LOGICO condicion {printf("Regla DECISION ES decision op_logico condicion\n");}  //Solo 2 condiciones maximo. No deberia ser recursiva
  |condicion                   {printf("Regla DECISION es condicion\n");decision_ind=condicion_ind;}
;

condicion:
  OP_NEGACION condicion           {
	  								printf("Regla CONDICION es not condicion\n");
									modificarTerceto(condicion_ind,1, negarOperador(getTerceto(condicion_ind).elem1));
									}
  |expresion_lado_izq_comp comparador expresion_lado_der_comp {printf("Regla CONDICION es expresion comparador expresion\n");  //TODO: Implementar lazy comparing para or
									char aux1[30];
									char aux2[30];
									sprintf(aux1,"[%d]",expresion_lado_izq_comp_ind);
									sprintf(aux2,"[%d]",expresion_lado_der_comp_ind);
									agregarTerceto(crearNuevoTerceto("CMP",aux1,aux2));
									condicion_ind=agregarTerceto(crearNuevoTerceto(definirOperador($2),NULL,NULL));
									push(&pila_condiciones,condicion_ind);
									}
  |equmax						{printf("Regla CONDICION es equmax\n");condicion_ind=equmax_ind;push(&pila_condiciones,condicion_ind);}
  |equmin						{printf("Regla CONDICION es equmin\n");condicion_ind=equmin_ind;push(&pila_condiciones,condicion_ind);}
;

expresion_lado_izq_comp: expresion{expresion_lado_izq_comp_ind=expresion_ind;};
expresion_lado_der_comp: expresion{expresion_lado_der_comp_ind=expresion_ind;};



comparador:
  OP_IGUAL                    {printf("Regla COMPARADOR ES =\n");/*comparador_ind=agregarTerceto(crearNuevoTerceto("=",NULL,NULL));*/}
  |OP_DISTINTO                {printf("Regla COMPARADOR ES <>\n");/*comparador_ind=agregarTerceto(crearNuevoTerceto("<>",NULL,NULL));*/}
  |OP_MENORIGUAL              {printf("Regla COMPARADOR ES <=\n");/*comparador_ind=agregarTerceto(crearNuevoTerceto("<=",NULL,NULL));*/}
  |OP_MAYORIGUAL              {printf("Regla COMPARADOR ES >=\n");/*comparador_ind=agregarTerceto(crearNuevoTerceto(">=",NULL,NULL));*/}
  |OP_MAYOR                   {printf("Regla COMPARADOR ES >\n");/*comparador_ind=agregarTerceto(crearNuevoTerceto(">",NULL,NULL));*/}
  |OP_MENOR                   {printf("Regla COMPARADOR ES <\n");/*comparador_ind=agregarTerceto(crearNuevoTerceto("<",NULL,NULL));*/}
;

expresion:
  expresion OP_SUMA termino   {printf("Regla EXPRESION es expresion+termino\n");
  								char aux1[30],aux2[30];
								sprintf(aux1,"[%d]",expresion_ind);
								sprintf(aux2,"[%d]",termino_ind);
								expresion_ind=agregarTerceto(crearNuevoTerceto("+",aux1,aux2));		//TODO: Cambiar a $2 y definir tipo de dato como string
								}
	|expresion OP_REST termino  {printf("Regla EXPRESION es expresion-termino\n");
								char aux1[30],aux2[30];
								sprintf(aux1,"[%d]",expresion_ind);
								sprintf(aux2,"[%d]",termino_ind);
								expresion_ind=agregarTerceto(crearNuevoTerceto("-",aux1,aux2));}
  |termino                    {printf("Regla EXPRESION es termino\n");
  								expresion_ind=termino_ind;
								  }
;

termino: 
  termino OP_MULT factor      {printf("Regla TERMINO es termino*factor\n");
  								char aux1[30],aux2[30];
								sprintf(aux1,"[%d]",termino_ind);
								sprintf(aux2,"[%d]",factor_ind);
								termino_ind=agregarTerceto(crearNuevoTerceto("*",aux1,aux2));
  								}
	|termino OP_DIVI factor     {printf("Regla TERMINO es termino/factor\n");
								char aux1[30],aux2[30];
								sprintf(aux1,"[%d]",termino_ind);
								sprintf(aux2,"[%d]",factor_ind);
								termino_ind=agregarTerceto(crearNuevoTerceto("/",aux1,aux2));
								}
  |factor                     {printf("Regla TERMINO es factor\n");
  								termino_ind=factor_ind;
								  }
;

factor:
  P_A {/*push(&pila_factores,factor_ind);*/push(&pila_terminos,termino_ind);push(&pila_expresiones,expresion_ind);} expresion P_C { printf("Regla FACTOR es (expresion)\n");  //Haria falta una pila de expresiones para apilar expresiones ???
  																						factor_ind=expresion_ind;
																						//factor_ind=pop(&pila_factores);  //Segun entiendo no haria falta pila_factor porque al terminar de reconocer esta regla la instruccion de arriba siempre va a pisar a esta. esta instruccion no deberia pisar a la de arriba
																						termino_ind=pop(&pila_terminos);
																						expresion_ind=pop(&pila_expresiones);
																					  }
	|ID                         {
                                printf("Regla FACTOR es id\n");
                                chequearVarEnTabla(yylval.valor_string); 
								factor_ind=agregarTerceto(crearNuevoTerceto(yylval.valor_string,NULL,NULL)); 
                              }
	|CTE_STRING                 {
                                printf("Regla FACTOR es cte_string\n");
                                agregarCteStringATabla(yylval.valor_string);
								factor_ind=agregarTerceto(crearNuevoTerceto(yylval.valor_string,NULL,NULL));
                              }
	|CTE_INT                    {
                                printf("Regla FACTOR es cte_int\n");
                                agregarCteIntATabla(yylval.valor_int); 
								char aux[30];
								sprintf(aux,"%d",yylval.valor_int);
								factor_ind=agregarTerceto(crearNuevoTerceto(aux,NULL,NULL));
                              }
	|CTE_REAL                   {
                                printf("Regla FACTOR es cte_real\n");
                                agregarCteRealATabla(yylval.valor_float);char aux[30];
								sprintf(aux,"%f",yylval.valor_int);
								factor_ind=agregarTerceto(crearNuevoTerceto(aux,NULL,NULL));
}
;

lista_expresion:
  lista_expresion COMA expresion {printf("Regla LISTA_EXPRESION es lista_expresion,expresion\n");}
  | expresion                     {printf("Regla LISTA_EXPRESION es expresion\n");}
;

salida:
	DISPLAY CTE_STRING P_Y_C        {
                                printf("Regla SALIDA es DISPLAY cte_string;\n");
                                agregarCteStringATabla(yylval.valor_string);  
								salida_ind=agregarTerceto(crearNuevoTerceto("DISPLAY",$2,NULL));
                              }
	|DISPLAY ID P_Y_C               {
                                chequearVarEnTabla($2);
                                printf("Regla SALIDA es DISPLAY id;\n");
								salida_ind=agregarTerceto(crearNuevoTerceto("DISPLAY",$2,NULL));
                              }
;

entrada:
  GET ID P_Y_C                {
                                chequearVarEnTabla($2);
                                printf("Regla ENTRADA es GET id;\n");
								entrada_ind=agregarTerceto(crearNuevoTerceto("GET",$2,NULL));
                              }
;

equmax: 
	EQUMAX P_A expresion_equ P_Y_C C_A lista_var_cte_equmax C_C P_C 	{
															printf("Regla EQUMAX es equmax ( expresion ; [lista_var_cte])\n");
															int x_ind=agregarTerceto(crearNuevoTerceto("CMP","@max","@aux_expr"));
															equmax_ind=agregarTerceto(crearNuevoTerceto("BNE",NULL,NULL));
														 	}
;

equmin: 
	EQUMIN P_A expresion_equ P_Y_C C_A lista_var_cte_equmin C_C P_C 	{
															printf("Regla EQUMIN es equmin ( expresion ; [lista_var_cte])\n");
															int x_ind=agregarTerceto(crearNuevoTerceto("CMP","@min","@aux_expr"));
															equmin_ind=agregarTerceto(crearNuevoTerceto("BNE",NULL,NULL));

															}
;

lista_var_cte_equmin: lista_var_cte_equmin COMA elem_lista_equ   	{printf("Regla LISTA_VAR_CTE es lista_var_cte,elem_lista_equ\n");
													char aux[30];
													sprintf(aux,"[%d]",elem_lista_equ_ind);
													int x_ind=agregarTerceto(crearNuevoTerceto(":=","@aux",aux));
													agregarTerceto(crearNuevoTerceto("CMP","@aux","@min"));
													sprintf(aux,"[%d]",x_ind+4);
													agregarTerceto(crearNuevoTerceto("BGE",aux,NULL));
													agregarTerceto(crearNuevoTerceto(":=","@min","@aux"));
													}
			   |elem_lista_equ						{
				   									printf("Regla LISTA_VAR_CTE es elem_lista_equ\n");
													char aux[30];
													sprintf(aux,"[%d]",elem_lista_equ_ind);
				   									agregarTerceto(crearNuevoTerceto(":=","@min",aux));
													}
;

lista_var_cte_equmax: lista_var_cte_equmax COMA elem_lista_equ   	{printf("Regla LISTA_VAR_CTE es lista_var_cte,elem_lista_equ\n");
													char aux[30];
													sprintf(aux,"[%d]",elem_lista_equ_ind);
													int x_ind=agregarTerceto(crearNuevoTerceto(":=","@aux",aux));
													agregarTerceto(crearNuevoTerceto("CMP","@max","@aux"));
													sprintf(aux,"[%d]",x_ind+4);
													agregarTerceto(crearNuevoTerceto("BGE",aux,NULL));
													agregarTerceto(crearNuevoTerceto(":=","@max","@aux"));
													}
			   |elem_lista_equ						{
				   									printf("Regla LISTA_VAR_CTE es elem_lista_equ\n");
													char aux[30];
													sprintf(aux,"[%d]",elem_lista_equ_ind);
				   									agregarTerceto(crearNuevoTerceto(":=","@max",aux));
													}
;

elem_lista_equ: 	CTE_INT							{printf("Regla ELEM_LISTA_EQU es cte_int\n");
													char aux[30];
													sprintf(aux,"%d",$1);
													elem_lista_equ_ind=agregarTerceto(crearNuevoTerceto(aux,NULL,NULL));
													}
				   |CTE_REAL						{
					   								printf("Regla ELEM_LISTA_EQU es cte_real\n");
													char aux[30];
													sprintf(aux,"%s",$1);
													elem_lista_equ_ind=agregarTerceto(crearNuevoTerceto(aux,NULL,NULL));}
													
				   |ID							    {printf("Regla ELEM_LISTA_EQU es ID\n");
				   									char aux[30];
													sprintf(aux,"%s",$1);
													elem_lista_equ_ind=agregarTerceto(crearNuevoTerceto(aux,NULL,NULL));}
;

expresion_equ: expresion{char aux[30];sprintf(aux,"[%d]",expresion_ind);agregarTerceto(crearNuevoTerceto(":=","@aux_expr",aux));};
%%

int main(int argc,char *argv[])
{
  //#ifdef YYDEBUG
    //yydebug = 1;
  //#endif 
  
  if ((yyin = fopen(argv[1], "rt")) == NULL)
  {
	  printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
  }
  else
  {
	  yyparse();
      fclose(yyin);
  }
  return 0;
}

int yyerror(char* mensaje)
 {
	printf("Syntax Error: %s\n", mensaje);
	system ("Pause");
	exit (1);
 }



/* Funciones de la tabla de simbolos */

/* Devuleve la posicion en la que se encuentra el elemento buscado, -1 si no encuentra el elemento */
int buscarEnTabla(char * name){
   int i=0;
   while(i<=fin_tabla){
	   if(strcmp(tabla_simbolo[i].nombre,name) == 0){
		   return i;
	   }
	   i++;
   }
   return -1;
}

/** Escribe el nombre de una variable o constante en la posición indicada */
void escribirNombreEnTabla(char* nombre, int pos){
	strcpy(tabla_simbolo[pos].nombre, nombre);
}

 /** Agrega un nuevo nombre de variable a la tabla **/
 void agregarVarATabla(char* nombre){
	 //Si se llena la tabla, sale por error
	 if(fin_tabla >= TAMANIO_TABLA - 1){
		 printf("Error: No hay mas espacio en la tabla de simbolos.\n");
		 system("Pause");
		 exit(2);
	 }
	 //Si no existe en la tabla, lo agrega
	 if(buscarEnTabla(nombre) == -1){
		 fin_tabla++;
		 escribirNombreEnTabla(nombre, fin_tabla);
	 }
	 else 
	 {
	  char msg[100] ;
	  sprintf(msg,"'%s' ya se encuentra declarada previamente.", nombre);
	  yyerror(msg);
	}
 }

/** Agrega los tipos de datos a las variables declaradas. Usa las variables globales varADeclarar1, cantVarsADeclarar y tipoDatoADeclarar */
void agregarTiposDatosATabla(){
	tabla_simbolo[varADeclarar1 + cantTipoDatoDeclarado].tipo_dato = tipoDatoADeclarar;
}

/** Guarda la tabla de simbolos en un archivo de texto */
void guardarTabla(){
	if(fin_tabla == -1)
		yyerror("No se encontro la tabla de simbolos");
	FILE* arch;

	arch = fopen("ts.txt", "w");
	if(!arch){
		printf("No se pudo crear el archivo ts.txt\n");
		return;
	}

	int i;

	fprintf(arch, "%-30s|%-30s|%-30s|%-30s\n","NOMBRE","TIPO","VALOR","LONGITUD");
	fprintf(arch, "---------------------------------|---------------|--------------------------------|----------|\n");
	for(i = 0; i <= fin_tabla; i++){
		fprintf(arch, "%-30s", &(tabla_simbolo[i].nombre) );

		switch (tabla_simbolo[i].tipo_dato){
		case Float:
			fprintf(arch, "|%-30s|%-30s|%-30s","FLOAT","--","--");
			break;
		case Integer:
			fprintf(arch, "|%-30s|%-30s|%-30s","INTEGER","--","--");
			break;
		case String:
			fprintf(arch, "|%-30s|%-30s|%-30s","STRING","--","--");
			break;
		case CteReal:
			fprintf(arch, "|%-30s|%-30f|%-30s", "CTE_REAL",tabla_simbolo[i].valor_f,"--");
			break;
		case CteInt:
			fprintf(arch, "|%-30s|%-30d|%-30s", "CTE_INT",tabla_simbolo[i].valor_i,"--");
			break;
		case CteString:
			fprintf(arch, "|%-30s|%-30s|%-30d", "CTE_STRING",&(tabla_simbolo[i].valor_s), tabla_simbolo[i].longitud);
			break;
		}

		fprintf(arch, "\n");
	}
	fclose(arch);
}

/** Agrega una constante string a la tabla de simbolos */
void agregarCteStringATabla(char* str){
	if(fin_tabla >= TAMANIO_TABLA - 1){
		printf("Error: No hay mas espacio en la tabla de simbolos.\n");
		system("Pause");
		exit(2);
	}

	char nombre[31] = "_";

	int length = strlen(str);
	char auxiliar[length];
	strcpy(auxiliar,str);
	auxiliar[strlen(auxiliar)-1] = '\0';

	//Queda en auxiliar el valor SIN COMILLAS
	strcpy(auxiliar, auxiliar+1);

	//Queda en nombre como lo voy a guardar en la tabla de simbolos 
	strcat(nombre, auxiliar); 

	//Si no hay otra variable con el mismo nombre...
	if(buscarEnTabla(nombre) == -1){
		//Agregar nombre a tabla
		fin_tabla++;
		escribirNombreEnTabla(nombre, fin_tabla);

		//Agregar tipo de dato
		tabla_simbolo[fin_tabla].tipo_dato = CteString;

		//Agregar valor a la tabla
		strcpy(tabla_simbolo[fin_tabla].valor_s, auxiliar); 

		//Agregar longitud
		tabla_simbolo[fin_tabla].longitud = strlen(tabla_simbolo[fin_tabla].valor_s);
	}
}

/** Agrega una constante real a la tabla de simbolos */
void agregarCteRealATabla(float valor){
	if(fin_tabla >= TAMANIO_TABLA - 1){
		printf("Error: No hay mas espacio en la tabla de simbolos.\n");
		system("Pause");
		exit(2);
	}

	//Genero el nombre
	char nombre[12];
	sprintf(nombre, "_%f", valor);

	//Si no hay otra variable con el mismo nombre...
	if(buscarEnTabla(nombre) == -1){
		//Agregar nombre a tabla
		fin_tabla++;
		escribirNombreEnTabla(nombre, fin_tabla);

		//Agregar tipo de dato
		tabla_simbolo[fin_tabla].tipo_dato = CteReal;

		//Agregar valor a la tabla
		tabla_simbolo[fin_tabla].valor_f = valor;
	}
}

/** Agrega una constante entera a la tabla de simbolos */
void agregarCteIntATabla(int valor){
	if(fin_tabla >= TAMANIO_TABLA - 1){
		printf("Error: No hay mas espacio en la tabla de simbolos.\n");
		system("Pause");
		exit(2);
	}

	//Genero el nombre
	char nombre[30];
	sprintf(nombre, "_%d", valor);

	//Si no hay otra variable con el mismo nombre...
	if(buscarEnTabla(nombre) == -1){
		//Agregar nombre a tabla
		fin_tabla++;
		escribirNombreEnTabla(nombre, fin_tabla);

		//Agregar tipo de dato
		tabla_simbolo[fin_tabla].tipo_dato = CteInt;

		//Agregar valor a la tabla
		tabla_simbolo[fin_tabla].valor_i = valor;
	}
}


/** Se fija si ya existe una entrada con ese nombre en la tabla de simbolos. Si no existe, muestra un error de variable sin declarar y aborta la compilacion. */
void chequearVarEnTabla(char* nombre){
	//Si no existe en la tabla, error
	if( buscarEnTabla(nombre) == -1){
		char msg[100];
		sprintf(msg,"La variable '%s' debe ser declarada previamente en la seccion de declaracion de variables", nombre);
		yyerror(msg);
	}
	//Si existe en la tabla, dejo que la compilacion siga
}


terceto crearNuevoTerceto(char * elem1,char* elem2,char* elem3){
	terceto terc;
	printf("funcion crearNuevoTerceto. elementos: %s %s %s\n",elem1,elem2,elem3);
	sprintf(terc.elem1,"%s",elem1);
	
	if(elem2!=NULL){
		sprintf(terc.elem2,"%s",elem2);
	}
	else
		sprintf(terc.elem2,"%c",TERCETO_VACIO);
	if(elem3!=NULL){
		sprintf(terc.elem3,"%s",elem3);
	}
	else
		sprintf(terc.elem3,"%c",TERCETO_VACIO);
	return terc;
}

int agregarTerceto(terceto terc){
	printf("funcion agregarTerceto. [%d](%s,%s,%s)\n",contador_tercetos,terc.elem1,terc.elem2,terc.elem3);
	terc.nro_terceto=contador_tercetos;
	v_tercetos[contador_tercetos]=terc;
	return contador_tercetos++;
}

void modificarTerceto(int nro_terceto,int nro_elem,char* txt ){
	printf("funcion ModificarTerceto: [%d] elem%d: %s\n",nro_terceto,nro_elem,txt);
	if(nro_terceto < 0 || nro_terceto > ultimo_terceto_creado()){
		printf("ERROR: El terceto %d no existe",nro_terceto);
		return;
	}
	if(nro_elem == 1){
		sprintf(v_tercetos[nro_terceto].elem1,txt);
	}
	else if(nro_elem == 2){
		sprintf(v_tercetos[nro_terceto].elem2,txt);
	}
	else if(nro_elem == 3){
		sprintf(v_tercetos[nro_terceto].elem3,txt);
	}

}


void escribirIntermedia(){
	int i=0;
	pfint=fopen("intermedia.txt","w");
	
	if(pfint == NULL)
	{
		printf("ERROR: No se pudo crear el archivo de notacion intermedia. %d",errno);
		exit(1);

	}
	for(i=0;i<contador_tercetos;i++){
		fprintf(pfint,"[%d](%s%c%s%c%s)\n",i,v_tercetos[i].elem1,DELIMITADOR_TERCETO,v_tercetos[i].elem2,DELIMITADOR_TERCETO,v_tercetos[i].elem3);
	}
	fclose(pfint);


}

void avanzar(){
	contador_tercetos++;
}

int ultimo_terceto_creado(){
	return contador_tercetos-1;
}

terceto getTerceto(int nro_terceto){
	return v_tercetos[nro_terceto];
}

int proximo_terceto(){
	printf("Funcion proximo_terceto:  %d\n",contador_tercetos);
	return contador_tercetos;
}


char* definirOperador(char* operador){
	if(!strcmp(	operador,	">="))
		return "BLT";
	else if(!strcmp(operador,">"))
		return "BLE";
	else if(!strcmp(operador,"<="))
		return "BGT";
	else if(!strcmp(operador,"<"))
		return "BGE";
	else if(!strcmp(operador,"<>"))
		return "BEQ";
	else if(!strcmp(operador,"=="))
		return "BNE";
	return "";
}

char* negarOperador(char* operador){
	if(!strcmp(operador,"BEQ"))
		return "BNE";
	if(!strcmp(operador,"BNE"))
		return "BEQ";
	if(!strcmp(operador,"BGT"))
		return "BLE";
	if(!strcmp(operador,"BLE"))
		return "BGT";
	if(!strcmp(operador,"BGE"))
		return "BLT";
	if(!strcmp(operador,"BLT"))
		return "BGE";
}

void push(node **top,int item)
{	
	printf("funcion push: %d\n",item);
    struct node *nptr = malloc(sizeof(struct node));
    nptr->data = item;
    nptr->next = *top;
    *top = nptr;
}

void display(node* top)
{
    struct node *temp;
    temp = top;
    while (temp != NULL)
    {
        printf("\n%d", temp->data);
        temp = temp->next;
    }
}

int pop(node** top)
{
	int num;
    if (*top == NULL)
    {
        printf("\n\nERROR: La pila esta vacia\n");
		return -1;
    }
    else
    {
        struct node *temp;
        temp = *top;
        *top = (*top)->next;
        num=temp->data;
        free(temp);
		printf("funcion pop: %d\n",num);
		return num;
    }
}

int isEmpty(node** top){
	printf("Funcion isEmpty: %s\n",*top == NULL?"true":"False");
	return *top == NULL;
}