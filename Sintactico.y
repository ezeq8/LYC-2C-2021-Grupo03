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
	#define Undefined -1

	#define TAMANIO_TABLA 3000
	#define TAM_NOMBRE 33

	#define SEPARADOR_PILA -1

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
	void agregarVarConTipoDeDatoATabla(char* nombre,int tipo_dato);
	int buscarCteFloatEnTabla(float valor);
	int buscarCteIntEnTabla(int valor);
	int buscarCteStringEnTabla(char valor[]);
	void escribirTablaDeSimbolosEnSeccionDataAssembler(FILE* pfasm);
	void definirInstruccionAritmeticaAssembler(const char operador[],char instruccion_aritmetica[]);
	void definirInstruccionAsignacionAssembler(int tipo_dato,char instruccion_asignacion[]);
	void definirInstruccionCargaEnMemoriaAssembler(int tipo_dato,char instruccion_carga[]);
	void definirInstruccionSaltoAssembler(char* operador,char* instruccion_salto);
	int buscarNumeroVariableAuxiliarAssembler(char s[],int lista[],int cant);
	int agregarEtiquetaSaltoProximoAssembler(int nro_salto);
	int hayProximoSaltoAssembler(int nro_salto);
	void guardarTabla(void);
	char* definirOperador(char* operador);
	int obtenerTipoDeSimbolo(char * name);
	int tablaDeSintesisExpresion(int tipo1, int tipo2);
	int compararCompatibilidadTiposDato(int tipo1,int tipo2);
	int esTipoDatoString(int tipo);
	int esTipoDatoInt(int tipo);
	int esTipoDatoFloat(int tipo);


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
	int lista_expresion_ind=-1;
	int factor_tipo;
	int termino_tipo;
	int expresion_tipo;
	int expresion_lado_izq_comp_ind_tipo;
	int expresion_lado_der_comp_ind_tipo;
	int expresion_equ_tipo;
	int id_while_especial_tipo;
	int cant_proximo_salto=0;
	int proximo_salto[50];
	
	FILE* pfint;
	int intermedia_creada_con_exito=0;
	char aux_operador[40];
	
	typedef struct node node;
	struct node{
    	int data;
    	struct node *next;
	};
	

	typedef struct {
		int nro_terceto;
		char elem1[40];
		char elem2[40];
		char elem3[40];
	}terceto;

	/*typedef struct {
		int nro_terceto;
		int tipo_dato;
	}
	variable_auxiliar_assembler;     BORRAR DESPUES SI NO LO USO
	*/ 
	terceto v_tercetos[1000];    //Funciona como una "Lista estatica". TODO: Reemplazar con una lista dinamica
	struct node *pila_condiciones = NULL;
	struct node *pila_factores = NULL;			
	struct node *pila_terminos = NULL;
	struct node *pila_expresiones = NULL;
	void display();
	void push(node**,int);
	int pop(node**);
	int peek(node** top);
	terceto crearNuevoTerceto(char * elem1,char* elem2,char* elem3);
	int agregarTerceto(terceto terc);
	void modificarTerceto(int nro_terceto,int nro_elem,char* txt );
	void escribirIntermedia();
	void generarAssembler();
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
									generarAssembler();
									
                                  }
	|bloque						{
                                    printf("Regla PROGRAMA es bloque_declaracion bloque\n");
                                    printf("COMPILACION EXITOSA\n");
                                    guardarTabla();
									escribirIntermedia();
									generarAssembler();
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
	WHILE {push(&pila_condiciones,contador_tercetos);agregarTerceto(crearNuevoTerceto("#etiq",NULL,NULL));}P_A decision P_C {
																																/*push(&pila_condiciones,ultimo_terceto_creado());*//*saco el push por las decisiones anidadas. que cada decision apile su terceto*//*avanzar();*/ /**/
																																push(&pila_condiciones,SEPARADOR_PILA); //apilo separador de pila antes de leer el bloque para las condiciones anidadas. el -1 divide la pila, porque no puede haber 																							
																																																																} LL_A bloque LL_C {printf("Regla CICLO es while(decision){bloque}\n");
																																																																char aux[40];															
																																																																int aux1=agregarTerceto(crearNuevoTerceto("BI",NULL,NULL));		//Escribir BI
																																																																pop(&pila_condiciones);   //saco el separador de pila (para ciclos anidados)
																																																																int z=pop(&pila_condiciones);printf("Desapilando En el while\n");													//z=Desaplilar(tope de pila)
																																																																while(!isEmpty(&pila_condiciones)&&peek(&pila_condiciones)!=SEPARADOR_PILA){    //Los primeros n elementos de la pila corresponden a las n condiciones. el ultimo elemento (fondo de pila) corresponde a la etiqueta del inicio del while.
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
	WHILE ID{
				push(&pila_condiciones,proximo_terceto());
				agregarTerceto(crearNuevoTerceto("#etiq",NULL,NULL));
				chequearVarEnTabla($2);
				id_while_especial_tipo=tabla_simbolo[buscarEnTabla($2)].tipo_dato;
				int aux=agregarTerceto(crearNuevoTerceto($2,NULL,NULL));
				char aux1[40];
				sprintf(aux1,"[%d]",aux);
				agregarTerceto(crearNuevoTerceto(":=","@aux",aux1));
				agregarVarConTipoDeDatoATabla("@aux",Integer);
				agregarVarConTipoDeDatoATabla("@aux_expr",Integer);
	} IN C_A lista_expresion C_C DO LL_A 	{
												int aux_bne=pop(&pila_condiciones);
												int z=pop(&pila_condiciones);
												char aux[40];
												while(!isEmpty(&pila_condiciones)&&peek(&pila_condiciones)!=SEPARADOR_PILA){ 
													sprintf(aux,"[%d]",proximo_terceto());
													modificarTerceto(z,2,aux);
													z=pop(&pila_condiciones);
												}
												
												push(&pila_condiciones,aux_bne);
												push(&pila_condiciones,z);
												push(&pila_condiciones,SEPARADOR_PILA);
											}bloque LL_C ENDWHILE {
																printf("Regla CICLO ESPECIAL es while especial(lista_expresion){bloque}\n");
																pop(&pila_condiciones); //Saco el separador de pila y o descarto
																int z=pop(&pila_condiciones);
																char aux[40];
																sprintf(aux,"[%d]",z);
																agregarTerceto(crearNuevoTerceto("BI",aux,NULL));
																z=pop(&pila_condiciones);
																sprintf(aux,"[%d]",proximo_terceto());
																modificarTerceto(z,1,"BNE");															
																modificarTerceto(z,2,aux);															
																}
;

asignacion: 
	ID OP_ASIG expresion P_Y_C {
                                chequearVarEnTabla($1);
                                printf("Regla ASIGNACION es id:=expresion;\n");
								int id_tipo=obtenerTipoDeSimbolo($1);
								if(!compararCompatibilidadTiposDato(id_tipo,expresion_tipo))
									yyerror("El tipo de dato de la variable no es compatible con el de la expresion\n");
								char aux1[40];
								sprintf(aux1,"[%d]",expresion_ind);
								asignacion_ind=agregarTerceto(crearNuevoTerceto(":=",$1,aux1));
								
                              }
;

if: 
	IF  P_A decision_if P_C LL_A bloque LL_C /*El while es para las condiciones anidadas. Hay que modificar todos los tercetos de todas las condiciones*/           
											{	printf("Regla IF es if(decision){bloque}\n");
												pop(&pila_condiciones);  //Saco el separador de pila y lo descarto
												while(!isEmpty(&pila_condiciones)&&peek(&pila_condiciones)!=SEPARADOR_PILA) {
														int x=pop(&pila_condiciones);
														char aux[40];
														sprintf(aux,"[%d]",contador_tercetos);
														modificarTerceto(x,2,aux);
												}
											}
	|IF P_A decision_if P_C LL_A bloque LL_C ELSE { int z;
												pop(&pila_condiciones);  //Saco el separador de pila y lo descarto
												while (!isEmpty(&pila_condiciones)&&peek(&pila_condiciones)!=SEPARADOR_PILA){
													z=pop(&pila_condiciones);
													char aux [40];
													
													sprintf(aux,"[%d]",proximo_terceto()+1);   //Proximo terceto +1=terceto del BI
													modificarTerceto(z,2,aux);
												}
												z=agregarTerceto(crearNuevoTerceto("BI",NULL,NULL));
												push(&pila_condiciones,z);  //o ´push(&pila_condiciones,ultimo_terceto_creado) //Inicio del codigo del else
												push(&pila_condiciones,SEPARADOR_PILA); //como acabo de apilar, vuelvo a poner el separador, si no, si dentro del bloque anterior al else hay otro ciclo se me van a mezclar las condiciones
	} LL_A bloque LL_C {
						printf("Regla IF es if(decision){bloque} else {bloque}\n");
						pop(&pila_condiciones); //Saco el separador de pila y lo descarto
						int z=pop(&pila_condiciones);
						char aux[40];
						sprintf(aux,"[%d]",proximo_terceto());
						modificarTerceto(z,2,aux);
						}  //TODO: devuelve un error de conflicto cuando intento agregar accion semantica en el medio de la regla si estan las 2 reglas del if (if y if else)	

;

decision_if: decision{printf("Regla DECISION_IF decision\n");push(&pila_condiciones,SEPARADOR_PILA);};  //Esta regla es para apilar el separador de pila en el if sin causar conflictos shift/reduce

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
									char aux1[40];
									char aux2[40];
									sprintf(aux1,"[%d]",expresion_lado_izq_comp_ind);
									sprintf(aux2,"[%d]",expresion_lado_der_comp_ind);
									if(!compararCompatibilidadTiposDato(expresion_lado_izq_comp_ind_tipo,expresion_lado_der_comp_ind_tipo))
										yyerror("Los tipos de datos no pueden compararse");
									if(esTipoDatoString(expresion_lado_izq_comp_ind_tipo)||esTipoDatoString(expresion_lado_der_comp_ind_tipo))
										yyerror("El tipo de dato String no puede usarse en una comparacion");
									agregarTerceto(crearNuevoTerceto("CMP",aux1,aux2));
									condicion_ind=agregarTerceto(crearNuevoTerceto(definirOperador($2),NULL,NULL));
									push(&pila_condiciones,condicion_ind);
									}
  |equmax						{printf("Regla CONDICION es equmax\n");condicion_ind=equmax_ind;push(&pila_condiciones,condicion_ind);}
  |equmin						{printf("Regla CONDICION es equmin\n");condicion_ind=equmin_ind;push(&pila_condiciones,condicion_ind);}
;

expresion_lado_izq_comp: expresion {expresion_lado_izq_comp_ind=expresion_ind;expresion_lado_izq_comp_ind_tipo=expresion_tipo;};
expresion_lado_der_comp: expresion {expresion_lado_der_comp_ind=expresion_ind;expresion_lado_der_comp_ind_tipo=expresion_tipo;};



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
  								char aux1[40],aux2[40];
								sprintf(aux1,"[%d]",expresion_ind);
								sprintf(aux2,"[%d]",termino_ind);
								expresion_ind=agregarTerceto(crearNuevoTerceto("+",aux1,aux2));		//TODO: Cambiar a $2 y definir tipo de dato como string
								int aux_tipo=tablaDeSintesisExpresion(expresion_tipo,termino_tipo);
								if(esTipoDatoString(aux_tipo))
									yyerror("no se puede usar un string en una operacion aritmetica");
								expresion_tipo=aux_tipo;
								}
	|expresion OP_REST termino  {printf("Regla EXPRESION es expresion-termino\n");
								char aux1[40],aux2[40];
								sprintf(aux1,"[%d]",expresion_ind);
								sprintf(aux2,"[%d]",termino_ind);
								expresion_ind=agregarTerceto(crearNuevoTerceto("-",aux1,aux2));
								int aux_tipo=tablaDeSintesisExpresion(expresion_tipo,termino_tipo);
								if(esTipoDatoString(aux_tipo))
									yyerror("no se puede usar un string en una operacion aritmetica");
								expresion_tipo=aux_tipo;
								}
  |termino                  	{printf("Regla EXPRESION es termino\n");
  								expresion_ind=termino_ind;
								expresion_tipo=termino_tipo;
								}
;

termino: 
  termino OP_MULT factor      {printf("Regla TERMINO es termino*factor\n");
  								char aux1[40],aux2[40];
								sprintf(aux1,"[%d]",termino_ind);
								sprintf(aux2,"[%d]",factor_ind);
								termino_ind=agregarTerceto(crearNuevoTerceto("*",aux1,aux2));
								int aux_tipo=tablaDeSintesisExpresion(termino_tipo,factor_tipo);
								if(esTipoDatoString(aux_tipo))
									yyerror("no se puede usar un string en una operacion aritmetica");
								termino_tipo=aux_tipo;
  								}
	|termino OP_DIVI factor     {printf("Regla TERMINO es termino/factor\n");
								char aux1[40],aux2[40];
								sprintf(aux1,"[%d]",termino_ind);
								sprintf(aux2,"[%d]",factor_ind);
								termino_ind=agregarTerceto(crearNuevoTerceto("/",aux1,aux2));
								int aux_tipo=tablaDeSintesisExpresion(termino_tipo,factor_tipo);
								if(esTipoDatoString(aux_tipo))
									yyerror("no se puede usar un string en una operacion aritmetica");
								termino_tipo=aux_tipo;
								}
  |factor                     {printf("Regla TERMINO es factor\n");
  								termino_ind=factor_ind;
								termino_tipo=factor_tipo;  
							  }
;

factor:
  P_A {/*push(&pila_factores,factor_ind);*/push(&pila_terminos,termino_ind);push(&pila_expresiones,expresion_ind);} expresion P_C { printf("Regla FACTOR es (expresion)\n");  //Haria falta una pila de expresiones para apilar expresiones ???
  																						factor_ind=expresion_ind;
																						factor_tipo=expresion_tipo;			//TODO: Revisar si esto esta bien ubicado (va antes o despues de desapilar???)
																						//factor_ind=pop(&pila_factores);  //Segun entiendo no haria falta pila_factor porque al terminar de reconocer esta regla la instruccion de arriba siempre va a pisar a esta. esta instruccion no deberia pisar a la de arriba
																						termino_ind=pop(&pila_terminos);
																						expresion_ind=pop(&pila_expresiones);
																					  }
	|ID                         {
                                printf("Regla FACTOR es id\n");
                                chequearVarEnTabla(yylval.valor_string);
								factor_tipo=obtenerTipoDeSimbolo(yylval.valor_string);
								factor_ind=agregarTerceto(crearNuevoTerceto(yylval.valor_string,NULL,NULL)); 
                              }
	|CTE_STRING                 {
                                printf("Regla FACTOR es cte_string\n");
								agregarCteStringATabla(yylval.valor_string);
								factor_tipo=String;
								factor_ind=agregarTerceto(crearNuevoTerceto(yylval.valor_string,NULL,NULL));
                              }
	|CTE_INT                    {
                                printf("Regla FACTOR es cte_int\n");
                                agregarCteIntATabla(yylval.valor_int);
								factor_tipo=Integer;
								char aux[40];
								sprintf(aux,"%d",yylval.valor_int);
								factor_ind=agregarTerceto(crearNuevoTerceto(aux,NULL,NULL));
                              }
	|CTE_REAL                   {
                                printf("Regla FACTOR es cte_real\n");
								factor_tipo=CteReal;
                                agregarCteRealATabla(yylval.valor_float);char aux[40];
								sprintf(aux,"%f",yylval.valor_float);
								factor_ind=agregarTerceto(crearNuevoTerceto(aux,NULL,NULL));
}
;

lista_expresion:
  lista_expresion COMA expresion {
	  								printf("Regla LISTA_EXPRESION es lista_expresion,expresion\n");
									char aux1[40];
									sprintf(aux1,"[%d]",expresion_ind);
									if(!compararCompatibilidadTiposDato(id_while_especial_tipo,expresion_tipo)){
										yyerror("Error: las expresiones de la lista del while especial deben ser del mismo tipo que el ID ");
									}
									agregarTerceto(crearNuevoTerceto(":=","@aux_expr",aux1));
									agregarTerceto(crearNuevoTerceto("CMP","@aux","@aux_expr"));
									int aux=agregarTerceto(crearNuevoTerceto("BEQ",NULL,NULL));
									push(&pila_condiciones,aux);
  								  }
  | expresion                     {
	  								printf("Regla LISTA_EXPRESION es expresion\n");
									char aux1[40];
									if(!compararCompatibilidadTiposDato(id_while_especial_tipo,expresion_tipo)){
										yyerror("Error: las expresiones de la lista del while especial deben ser del mismo tipo que el ID ");
									}
									sprintf(aux1,"[%d]",expresion_ind);
									agregarTerceto(crearNuevoTerceto(":=","@aux_expr",aux1));
									agregarTerceto(crearNuevoTerceto("CMP","@aux","@aux_expr"));
									int aux=agregarTerceto(crearNuevoTerceto("BEQ",NULL,NULL));
									push(&pila_condiciones,aux);


									


										  
									  
								  }
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
															agregarVarConTipoDeDatoATabla("@aux_expr",Integer);
															agregarVarConTipoDeDatoATabla("@max",Integer);
															agregarVarConTipoDeDatoATabla("@aux",Integer);
														 	}
;

equmin: 
	EQUMIN P_A expresion_equ P_Y_C C_A lista_var_cte_equmin C_C P_C 	{
															printf("Regla EQUMIN es equmin ( expresion ; [lista_var_cte])\n");
															int x_ind=agregarTerceto(crearNuevoTerceto("CMP","@min","@aux_expr"));
															equmin_ind=agregarTerceto(crearNuevoTerceto("BNE",NULL,NULL));
															agregarVarConTipoDeDatoATabla("@aux_expr",Integer);
															agregarVarConTipoDeDatoATabla("@min",Integer);
															agregarVarConTipoDeDatoATabla("@aux",Integer);
															}
;

lista_var_cte_equmin: lista_var_cte_equmin COMA elem_lista_equ   	{printf("Regla LISTA_VAR_CTE es lista_var_cte,elem_lista_equ\n");
													char aux[40];
													sprintf(aux,"[%d]",elem_lista_equ_ind);
													int x_ind=agregarTerceto(crearNuevoTerceto(":=","@aux",aux));
													agregarTerceto(crearNuevoTerceto("CMP","@aux","@min"));
													sprintf(aux,"[%d]",x_ind+4);
													agregarTerceto(crearNuevoTerceto("BGE",aux,NULL));
													agregarTerceto(crearNuevoTerceto(":=","@min","@aux"));
													}
			   |elem_lista_equ						{
				   									printf("Regla LISTA_VAR_CTE es elem_lista_equ\n");
													char aux[40];
													sprintf(aux,"[%d]",elem_lista_equ_ind);
				   									agregarTerceto(crearNuevoTerceto(":=","@min",aux));
													}
;

lista_var_cte_equmax: lista_var_cte_equmax COMA elem_lista_equ   	{printf("Regla LISTA_VAR_CTE es lista_var_cte,elem_lista_equ\n");
													char aux[40];
													sprintf(aux,"[%d]",elem_lista_equ_ind);
													int x_ind=agregarTerceto(crearNuevoTerceto(":=","@aux",aux));
													agregarTerceto(crearNuevoTerceto("CMP","@max","@aux"));
													sprintf(aux,"[%d]",x_ind+4);
													agregarTerceto(crearNuevoTerceto("BGE",aux,NULL));
													agregarTerceto(crearNuevoTerceto(":=","@max","@aux"));
													}
			   |elem_lista_equ						{
				   									printf("Regla LISTA_VAR_CTE es elem_lista_equ\n");
													char aux[40];
													sprintf(aux,"[%d]",elem_lista_equ_ind);
				   									agregarTerceto(crearNuevoTerceto(":=","@max",aux));
													}
;

elem_lista_equ: 	CTE_INT							{printf("Regla ELEM_LISTA_EQU es cte_int\n");
													char aux[40];
													if(!compararCompatibilidadTiposDato(expresion_equ_tipo,Integer))
														yyerror("Error: el tipo de dato de los elementos de la lista de equmax/equmin deben ser del mismo tipo que la expresion de equmax/equmin");
													agregarCteIntATabla($1);
													sprintf(aux,"%d",$1);
													elem_lista_equ_ind=agregarTerceto(crearNuevoTerceto(aux,NULL,NULL));
													}
				   |CTE_REAL						{
					   								printf("Regla ELEM_LISTA_EQU es cte_real\n");
													char aux[40];
													if(!compararCompatibilidadTiposDato(expresion_equ_tipo,Float))
														yyerror("Error: el tipo de dato de los elementos de la lista de equmax/equmin deben ser del mismo tipo que la expresion de equmax/equmin");
													agregarCteRealATabla($1);
													sprintf(aux,"%f",$1);
													elem_lista_equ_ind=agregarTerceto(crearNuevoTerceto(aux,NULL,NULL));}
													
				   |ID							    {printf("Regla ELEM_LISTA_EQU es ID\n");
				   									chequearVarEnTabla($1);
													if(!compararCompatibilidadTiposDato(expresion_equ_tipo,tabla_simbolo[buscarEnTabla($1)].tipo_dato))
														yyerror("Error: el tipo de dato de los elementos de la lista de equmax/equmin deben ser del mismo tipo que la expresion de equmax/equmin");   
				   									char aux[40];
													sprintf(aux,"%s",$1);
													elem_lista_equ_ind=agregarTerceto(crearNuevoTerceto(aux,NULL,NULL));}
;

expresion_equ: expresion{char aux[40];sprintf(aux,"[%d]",expresion_ind);agregarTerceto(crearNuevoTerceto(":=","@aux_expr",aux));expresion_equ_tipo=expresion_tipo;};
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
int buscarCteStringEnTabla(char valor[]){    //Busca constante string en la tabla de simbolos por valor
 	int i=0;
	char aux_valor[40];
	if(valor[0]=='\"'){
		strcpy(aux_valor,valor+1);  //Copio eliminando la primera comilla
		aux_valor[strlen(aux_valor)-1]='\0';	//Elimino la segunda comilla
	}
	else
		strcpy(aux_valor,valor); 

	printf("Funcion buscarCteStringEnTabla: %s\n",valor);
   	while(i<=fin_tabla){
	   if(tabla_simbolo[i].tipo_dato==CteString && strcmp(tabla_simbolo[i].valor_s,aux_valor) == 0){
		   return i;
	   }
	   i++;
   }
   return -1;
}
int buscarCteFloatEnTabla(float valor){    //Busca constante string en la tabla de simbolos por valor
 int i=0;
 printf("Funcion buscarCteFloatEnTabla\n");
   while(i<=fin_tabla){
	   if(tabla_simbolo[i].tipo_dato==CteReal && tabla_simbolo[i].valor_f==valor){
		   return i;
	   }
	   i++;
   }
   return -1;
}

int buscarCteIntEnTabla(int valor){    //Busca constante string en la tabla de simbolos por valor
 int i=0;
	printf("Funcion buscarCteIntEnTabla");
   while(i<=fin_tabla){
	   if(tabla_simbolo[i].tipo_dato==CteInt && tabla_simbolo[i].valor_i==valor){
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

	char nombre[40] = "__";  //doble guion bajo para diferernciar constantes string del resto y evitar que colisionen

	int length = strlen(str);
	char auxiliar[length];
	strcpy(auxiliar,str);
	auxiliar[strlen(auxiliar)-1] = '\0';

	//Queda en auxiliar el valor SIN COMILLAS
	strcpy(auxiliar, auxiliar+1);

	//Queda en nombre como lo voy a guardar en la tabla de simbolos 
	strcat(nombre, auxiliar); 
	
	for(int i=0;i<strlen(nombre);i++){  //Reemplazo los espacios por gion
		if(isspace(nombre[i]))
			nombre[i]='_';
	}


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
	*strchr(nombre,'.')='_';

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
	char nombre[40];
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


// hay que llamar primero a chequearVarEnTabla antes de llamar a esta funcion
int obtenerTipoDeSimbolo(char * name){
   return tabla_simbolo[buscarEnTabla(name)].tipo_dato;
}


void agregarVarConTipoDeDatoATabla(char* nombre,int tipo_dato){
	printf("Funcion agregarVarConTipoDeDatoATabla: %s %d",nombre,tipo_dato);

	if(fin_tabla >= TAMANIO_TABLA - 1){
		 printf("Error: No hay mas espacio en la tabla de simbolos.\n");
		 system("Pause");
		 exit(2);
	 }
	 //Si no existe en la tabla, lo agrega
	 if(buscarEnTabla(nombre) == -1){
		fin_tabla++;
		strcpy(tabla_simbolo[fin_tabla].nombre, nombre);
		tabla_simbolo[fin_tabla].tipo_dato=tipo_dato;

	 }

}

int tablaDeSintesisExpresion(int tipo1, int tipo2){

	printf("\nFuncion tablaDeSintesisExpresion: %d %d\n",tipo1,tipo2);
	if(esTipoDatoString(tipo1)||esTipoDatoString(tipo2))
		return String;
	if(esTipoDatoFloat(tipo1)||esTipoDatoFloat(tipo2)) 
		return Float;
	if(esTipoDatoInt(tipo1) && esTipoDatoInt(tipo2))
		return Integer;
	return Undefined;
}

int compararCompatibilidadTiposDato(int tipo1,int tipo2){
	return 	  (esTipoDatoString(tipo1) && esTipoDatoString(tipo2))
			||(esTipoDatoInt(tipo1) && esTipoDatoInt(tipo2))
			||(esTipoDatoFloat(tipo1) && esTipoDatoFloat(tipo2));
}

int esTipoDatoString(int tipo){
	return tipo==String || tipo == CteString;
}

int esTipoDatoInt(int tipo){
	return tipo==Integer || tipo == CteInt;
}
int esTipoDatoFloat(int tipo){
	return tipo==Float || tipo == CteReal;
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
	printf("Funcion definirOperador; %s",operador);
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
int peek(node** top){
	if (*top == NULL)
    {
        printf("\n\nERROR: La pila esta vacia\n");
		return -1;
    }
	return (*top)->data;
}
int isEmpty(node** top){
	printf("Funcion isEmpty: %s\n",*top == NULL?"true":"False");
	return *top == NULL;
}


void generarAssembler(){

	const char header []="INCLUDE macros2.asm      ;incluye macros\nINCLUDE number.asm       ;incluye el asm para impresion de numeros\n\nMODEL LARGE\n.386\n.STACK 200h\n.DATA\n\n"; 
	const char code_init[]=".CODE\nstart:\nmov AX,@DATA\nmov DS,AX\nmov es,ax\n\n";
	const char trailer[]="mov ax,4c00h\nint 21h\n\nEND start";
	FILE* pfasm=fopen("Final.asm","w");
	char lista_code_assembler[1000][60];
	int cont_aux=-1;
	int lista_var_aux[50];
	int i_terceto=0,i_assembler=0;
	char aux_string[40];
	int i; //borrar despues
	if(!pfasm){
		printf("Error: No se pudo crear el archivo de assembler");
		exit(1);
	}

	fprintf(pfasm,header);
	escribirTablaDeSimbolosEnSeccionDataAssembler(pfasm);

	for(i_terceto=0;i_terceto<=ultimo_terceto_creado();i_terceto++){
		terceto aux=v_tercetos[i_terceto];
		int ind;
		if(hayProximoSaltoAssembler(i_terceto))
			sprintf(lista_code_assembler[i_assembler++],"\netiq_%d:",i_terceto);
		if(!strcmp(aux.elem1,"DISPLAY")){
			printf("DEBUG: DISPLAY\n");
			if(aux.elem2[0]=='"'){
				ind=buscarCteStringEnTabla(aux.elem2);
				sprintf(lista_code_assembler[i_assembler++],"\tDisplayString %s\n\tnewLine 1\n",tabla_simbolo[ind].nombre);
			}
			else{
				int aux_tipo_dato=tabla_simbolo[buscarEnTabla(aux.elem2)].tipo_dato;
				if(aux_tipo_dato==Integer)
					sprintf(lista_code_assembler[i_assembler++],"\tDisplayInteger %s\n\tnewLine 1\n",aux.elem2);
				else if(aux_tipo_dato==Float)
					sprintf(lista_code_assembler[i_assembler++],"\tDisplayFloat %s, 3\n\tnewLine 1\n",aux.elem2);
				else if(aux_tipo_dato==String)
					sprintf(lista_code_assembler[i_assembler++],"\tDisplayString %s\n\tnewLine 1\n",aux.elem2);
			}
		}
		if(!strcmp(aux.elem1,"GET")){
			printf("DEBUG: GET");
			int aux_tipo_dato=tabla_simbolo[buscarEnTabla(aux.elem2)].tipo_dato;
				if(aux_tipo_dato==Integer)
					sprintf(lista_code_assembler[i_assembler++],"\tGetInteger %s",aux.elem2);
				else if(aux_tipo_dato==Float)
					sprintf(lista_code_assembler[i_assembler++],"\tGetFloat %s",aux.elem2);
				else if(aux_tipo_dato==String)
					sprintf(lista_code_assembler[i_assembler++],"\tGetString %s",aux.elem2);

		}
		if(!strcmp(aux.elem1,"+")||!strcmp(aux.elem1,"-")||!strcmp(aux.elem1,"*")||!strcmp(aux.elem1,"/")){
			printf("DEBUG: ARITMETICA\n");
			char instruccion_aritmetica[5];
			definirInstruccionAritmeticaAssembler(aux.elem1,instruccion_aritmetica);
			int nro_variable_auxiliar_izq,nro_variable_auxiliar_der;
			if(aux.elem2[0]=='['){       //Por ahora asumo que la unica posibilidad es que esto sea un terceto
				nro_variable_auxiliar_izq=buscarNumeroVariableAuxiliarAssembler(aux.elem2,lista_var_aux,cont_aux);
			}
			if(aux.elem3[0]=='['){       //Por ahora asumo que la unica posibilidad es que esto sea un terceto
				nro_variable_auxiliar_der=buscarNumeroVariableAuxiliarAssembler(aux.elem3,lista_var_aux,cont_aux);
			}
			cont_aux++;
			lista_var_aux[cont_aux]=i_terceto;
			
			sprintf(lista_code_assembler[i_assembler++],"\tfld aux%d\n\tfld aux%d\n\t%s\n\tfstp aux%d\n",nro_variable_auxiliar_izq,nro_variable_auxiliar_der,instruccion_aritmetica,cont_aux);
		}
		if(!strcmp(aux.elem1,":="))
		{
			printf("DEBUG: ASIGNACION\n");
			char instruccion_asignacion[6];
			int tipo_dato=tabla_simbolo[buscarEnTabla(aux.elem2)].tipo_dato;
			int nro_variable_auxiliar_der;
			definirInstruccionAsignacionAssembler(tipo_dato,instruccion_asignacion);
			if(aux.elem3[0]=='['){  //Por ahora supongo que esto solo ouede ser un indica de otro terceto
				nro_variable_auxiliar_der=buscarNumeroVariableAuxiliarAssembler(aux.elem3,lista_var_aux,cont_aux);
			}

			sprintf(lista_code_assembler[i_assembler++],"\tfld aux%d\n\t%s %s\n",nro_variable_auxiliar_der,instruccion_asignacion,aux.elem2);
		}
		if(aux.elem1[0] !='#' && strcmp(aux.elem1,"BI") && strlen(aux.elem2) == 1 && strlen(aux.elem3) == 1 && aux.elem2[0] == TERCETO_VACIO && aux.elem2[0] == TERCETO_VACIO){ //pregunta si es un terceto de un unico elemento, o sea un terceto de declaracion de variable o constante. TODO: buscar una mejor forma de identificarlo
			printf("DEBUG: CARGA EN MEMORIA\n");
			char instruccion_carga[5];
			int ind;
			int tipo_dato;
			
			if(aux.elem1[0]=='\"')	
				ind=buscarCteStringEnTabla(aux.elem1);
			else if (strchr(aux.elem1,'.')!= NULL)
				ind=buscarCteFloatEnTabla(atof(aux.elem1));
			else if(isdigit(aux.elem1[0])){
				
				ind=buscarCteIntEnTabla(atoi(aux.elem1));}
			else
				ind=buscarEnTabla(aux.elem1);
			
			tipo_dato=tabla_simbolo[ind].tipo_dato;  //TODO, constantes. queda pendiente
			
			definirInstruccionCargaEnMemoriaAssembler(tipo_dato,instruccion_carga);
			
			cont_aux++;
			lista_var_aux[cont_aux]=i_terceto;
			
			sprintf(lista_code_assembler[i_assembler++],"\n\t%s %s\n\tFSTP aux%d\n\tffree\n",instruccion_carga,tabla_simbolo[ind].nombre,cont_aux);
		}
		if(!strcmp(aux.elem1,"CMP")){
			printf("DEBUG: CMP");
			char operador1[31];
			char operador2[31];
			if(aux.elem2[0]=='[')
				sprintf(operador1,"aux%d",buscarNumeroVariableAuxiliarAssembler(aux.elem2,lista_var_aux,cont_aux));
			else
				strcpy(operador1,aux.elem2);
			if(aux.elem3[0]=='['){
				sprintf(operador2,"aux%d",buscarNumeroVariableAuxiliarAssembler(aux.elem3,lista_var_aux,cont_aux));
			}
			else{
				strcpy(operador2,aux.elem3);

				}
			aux=v_tercetos[++i_terceto];		//Leo el proximo terceto, ya se que es un branch porque siempre despues de cmp viene un branch
			int nro_salto;
			sscanf(aux.elem2,"[%d]",&nro_salto);
			char etiqueta[10];
			char instruccion_salto[5];
			definirInstruccionSaltoAssembler(aux.elem1,instruccion_salto);
			if(nro_salto>i_terceto){  //Si tengo que saltar a un terceto que todavia no escribi, lo guardo para crear la etiqueta cuando llegue el terceto
				agregarEtiquetaSaltoProximoAssembler(nro_salto);
			}
			sprintf(lista_code_assembler[i_assembler++],"\tfld  %s\n\tfcomp %s\n\tfstsw ax\n\tsahf\n\t%s etiq_%d\n",operador1,operador2,instruccion_salto,nro_salto);
		}
		if(aux.elem1[0]=='#'){  //Etiqueta
			if(!hayProximoSaltoAssembler(i_terceto)) //Para evitar agregar 2 veces la etiqueta. si esta como proximo salto no hace falta agregarla, se va a agregar al principio.
				sprintf(lista_code_assembler[i_assembler++],"etiq_%d:\n",aux.nro_terceto);  //+1 para no imprimir el #

		}
		if(!strcmp(aux.elem1,"BI")){
			int nro_salto;
			sscanf(aux.elem2,"[%d]",&nro_salto);
			sprintf(lista_code_assembler[i_assembler++],"\tJMP etiq_%d\n",nro_salto);
			if(nro_salto>i_terceto){  //Si tengo que saltar a un terceto que todavia no escribi, lo guardo para crear la etiqueta cuando llegue el terceto
				agregarEtiquetaSaltoProximoAssembler(nro_salto);
			}

		}


		
	}
	if(hayProximoSaltoAssembler(i_terceto))
			sprintf(lista_code_assembler[i_assembler++],"\netiq_%d:",i_terceto);

	for(int j=0;j<=cont_aux;j++){
		fprintf(pfasm,"aux%d	dd	?\n",j);
	}

	fprintf(pfasm,"\n\n%s",code_init);
	
	for(int j=0;j<i_assembler;j++){
		fprintf(pfasm,"%s\n",lista_code_assembler[j]);
	}
	fprintf(pfasm,"\n\n%s",trailer);
	fclose(pfasm);

}



void escribirTablaDeSimbolosEnSeccionDataAssembler(FILE* pfasm){
	int i;
	simbolo aux;
	for(i=0;i<=fin_tabla;i++){
		aux=tabla_simbolo[i];
		if(aux.tipo_dato==Integer || aux.tipo_dato == Float)
			fprintf(pfasm,"%s\tdd\t?\n",aux.nombre);
		if(aux.tipo_dato==String)
			fprintf(pfasm,"%s\tdb\t?\n",aux.nombre);
		if(aux.tipo_dato==CteInt)
			fprintf(pfasm,"%s\tdd\t%d\n",aux.nombre,aux.valor_i);
		if(aux.tipo_dato == CteReal)
			fprintf(pfasm,"%s\tdd\t%f\n",aux.nombre,aux.valor_f);
		if(aux.tipo_dato==CteString)
			fprintf(pfasm,"%s\tdb\t'%s$'\n",aux.nombre,aux.valor_s);
	}

}

void definirInstruccionAritmeticaAssembler(const char operador[],char instruccion_aritmetica[]){
	if(!strcmp(operador,"+"))
		strcpy(instruccion_aritmetica,"FADD");
	if(!strcmp(operador,"/"))
		strcpy(instruccion_aritmetica,"FDIV");
	if(!strcmp(operador,"-"))
		strcpy(instruccion_aritmetica,"FSUB");
	if(!strcmp(operador,"*"))
		strcpy(instruccion_aritmetica,"FMUL");
}

void definirInstruccionAsignacionAssembler(int tipo_dato,char instruccion_asignacion[]){
	printf("definirInstruccionAsignacionAssembler: %d",tipo_dato);
	if(tipo_dato==Float)
		strcpy(instruccion_asignacion,"FSTP");
	if(tipo_dato==Integer)
		strcpy(instruccion_asignacion,"FISTP");
	//TODO: Que se hace con el string??. no creo que se lo cargue en la pila del coprocesador
}

void definirInstruccionCargaEnMemoriaAssembler(int tipo_dato,char instruccion_carga[]){
	if(tipo_dato==Float||tipo_dato==CteReal)
		strcpy(instruccion_carga,"FLD");
	if(tipo_dato==Integer||tipo_dato==CteInt)
		strcpy(instruccion_carga,"FILD");
}


void definirInstruccionSaltoAssembler(char* operador,char* instruccion_salto){
	if(!strcmp(operador,"BLT"))
		strcpy(instruccion_salto,"JB");
	else if (!strcmp(operador,"BLE"))
		strcpy(instruccion_salto,"JNA");
	else if (!strcmp(operador,"BGT"))
		strcpy(instruccion_salto,"JA");
	else if (!strcmp(operador,"BGE"))
		strcpy(instruccion_salto,"JAE");
	else if (!strcmp(operador,"BEQ"))
		strcpy(instruccion_salto,"JE");
	else if (!strcmp(operador,"BNE"))
		strcpy(instruccion_salto,"JNE");

}

int buscarNumeroVariableAuxiliarAssembler(char s[],int lista[],int cant){
	int aux;
	int i;
	sscanf(s,"[%d]",&aux);
	
	
	for(i=0;i<=cant;i++){
		if(lista[i]==aux)
			return i;
	}
	printf("Error: no se encuentra la variable auxiliar donde se cargo el terceto: %s",s );
	exit(1);
}
int agregarEtiquetaSaltoProximoAssembler(int nro_salto){
	printf("Funcion agregarEtiquetaSaltoProximoAssembler::: %d",nro_salto);
	proximo_salto[cant_proximo_salto++]=nro_salto;
}

int hayProximoSaltoAssembler(int nro_terceto){
	printf("HayProximoSaltoAssembler: %d\n",nro_terceto);
	for(int i=0;i<cant_proximo_salto;i++)
		if(proximo_salto[i]==nro_terceto)
			return 1;
	return 0;
}