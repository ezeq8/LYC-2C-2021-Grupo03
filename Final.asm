include macros2.asm
include number.asm

.MODEL LARGE
.386
.STACK 200h


.DATA

A       					dd      ?
B       					dd      ?
C       					dd      ?
D							dd		?
E							dd		?
F							dd		?
G							dd		?

_HOL.A						db		"HOL.A"	,'$',7		dup (?)
_HOLA_TODO_BIEN				db		"HOLA TODO BIEN" ,'$',16		dup (?)
_Mostrar_por_pantalla       db		"Mostrar por pantalla" ,'$',22         dup (?)	


.CODE

START:

	mov AX,@DATA
	mov DS,AX
	mov DS,AX
	mov es,ax




    FLD _cte5
    FSTP A
	FLD _cte10
	FSTP B
	FLD _cte15
	FSTP C

	Etiq1:
		FLD A
		FLD _cte4
		FXCH
		FCOM
		FSTSW AX
		SAHF
		FFREE
		JNB Etiq2   /* si A no es menor que 4 salta a Etiq2 */

		FLD B
		FLD _cte9
		FXCH
		FCOM
		FSTSW AX
		SAHF
		FFREE
		JNA Etiq2	/* si B no es mayor que 9 salta a Etiq2 */

		FLD _cte5	/* esto se ejecuta si A es menor a 4 y B mayor que 9 */
		FSTP _D		/* esto se ejecuta si A es menor a 4 y B mayor que 9 */
		JMP Etiq2   /* salto a Etiq2 */

	Etiq2:
		FLD A
		FLD _cte4
		FXCH
		FCOM
		FSTSW AX
		SAHF
		FFREE
		JNE	Cond2	/* si A no es igual a 4 salta a Cond2 */

	Cond2:
		FLD B
		FLD _cte9
		FXCH
		FCOM
		FSTSW AX
		SAHF
		FFREE	
		JE 	else_part		/* si B no es distinto a 9 salta a else_part */
	
	then_part:
		FLD _cte5	/* esto se ejecuta si A es igual a 4 y B distinto a 9 */
    	FSTP _D		/* esto se ejecuta si A es igual a 4 y B distinto a 9 */
		JMP end_if   /* salto a end_if */
	
	else_part:
		FLD _cte5	/* esto se ejecuta si no cumple ninguna de las 2 condiciones */
    	FSTP _D		/* esto se ejecuta si no cumple ninguna de las 2 condiciones */
	

	FLD _cte12
	FSTP E

	while:
		FLD E
		FLD B
		FXCH
		FCOM
		FSTSW AX
		SAHF
		FFREE
		JNA fin_while

		FLD E
		FLD _cte1
		FSUB
		FSTP E
		JMP while

		fin_while

	
	DisplayString	 _Mostrar_por_pantalla
	DisplayString	 A
	








    

    
