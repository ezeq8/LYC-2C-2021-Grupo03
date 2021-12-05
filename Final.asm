INCLUDE macros2.asm      ;incluye macros
INCLUDE number.asm       ;incluye el asm para impresion de numeros

MODEL LARGE
.386
.STACK 200h
.DATA

A	dd	?
B	dd	?
C	dd	?
D	dd	?
E	dd	?
G	db	?
F	db	?
W	dd	?
l	dd	?
i	dd	?
j	dd	?
k	dd	?
_5	dd	5
_10	dd	10
_15	dd	15
_4	dd	4
_9	dd	9
_12	dd	12
_1	dd	1
@aux	dd	?
@aux_expr	dd	?
_2	dd	2
_3	dd	3
__Mostrar_por_pantalla	db	'Mostrar por pantalla$'
_101	dd	101
_100	dd	100
_111	dd	111
@max	dd	?
__Ingrese_Numero_i	db	'Ingrese Numero i$'
__Ingrese_otro_numero_j	db	'Ingrese otro numero j$'
__Ingrese_un_numero_mas_k	db	'Ingrese un numero mas k$'
__i_es_el_mayor	db	'i es el mayor$'
__k_es_mayor	db	'k es mayor$'
__j_es_mayor	db	'j es mayor$'
aux0	dd	?
aux1	dd	?
aux2	dd	?
aux3	dd	?
aux4	dd	?
aux5	dd	?
aux6	dd	?
aux7	dd	?
aux8	dd	?
aux9	dd	?
aux10	dd	?
aux11	dd	?
aux12	dd	?
aux13	dd	?
aux14	dd	?
aux15	dd	?
aux16	dd	?
aux17	dd	?
aux18	dd	?
aux19	dd	?
aux20	dd	?
aux21	dd	?
aux22	dd	?
aux23	dd	?
aux24	dd	?
aux25	dd	?
aux26	dd	?
aux27	dd	?
aux28	dd	?
aux29	dd	?
aux30	dd	?
aux31	dd	?
aux32	dd	?
aux33	dd	?
aux34	dd	?
aux35	dd	?
aux36	dd	?
aux37	dd	?
aux38	dd	?
aux39	dd	?
aux40	dd	?
aux41	dd	?
aux42	dd	?
aux43	dd	?
aux44	dd	?


.CODE
start:
mov AX,@DATA
mov DS,AX
mov es,ax


	FILD _5
	FSTP aux0
	ffree

	fld aux0
	FISTP A


	FILD _10
	FSTP aux1
	ffree

	fld aux1
	FISTP B


	FILD _15
	FSTP aux2
	ffree

	fld aux2
	FISTP C


	FILD A
	FSTP aux3
	ffree


	FILD _4
	FSTP aux4
	ffree

	fld  aux3
	fcomp aux4
	fstsw ax
	sahf
	JAE etiq_16


	FILD B
	FSTP aux5
	ffree


	FILD _9
	FSTP aux6
	ffree

	fld  aux5
	fcomp aux6
	fstsw ax
	sahf
	JNA etiq_16


	FILD _5
	FSTP aux7
	ffree

	fld aux7
	FISTP D


etiq_16:

	FILD A
	FSTP aux8
	ffree


	FILD _4
	FSTP aux9
	ffree

	fld  aux8
	fcomp aux9
	fstsw ax
	sahf
	JNE etiq_27


	FILD B
	FSTP aux10
	ffree


	FILD _9
	FSTP aux11
	ffree

	fld  aux10
	fcomp aux11
	fstsw ax
	sahf
	JE etiq_27


	FILD _5
	FSTP aux12
	ffree

	fld aux12
	FISTP D

	JMP etiq_29


etiq_27:

	FILD _4
	FSTP aux13
	ffree

	fld aux13
	FISTP D


etiq_29:

	FILD _12
	FSTP aux14
	ffree

	fld aux14
	FISTP E

etiq_31:


	FILD E
	FSTP aux15
	ffree


	FILD B
	FSTP aux16
	ffree

	fld  aux15
	fcomp aux16
	fstsw ax
	sahf
	JNA etiq_41


	FILD E
	FSTP aux17
	ffree


	FILD _1
	FSTP aux18
	ffree

	fld aux17
	fld aux18
	FSUB
	fstp aux19

	fld aux19
	FISTP E

	JMP etiq_31


etiq_41:

	FILD A
	FSTP aux20
	ffree

	fld aux20
	FISTP @aux


	FILD _2
	FSTP aux21
	ffree

	fld aux21
	FISTP @aux_expr

	fld  @aux
	fcomp @aux_expr
	fstsw ax
	sahf
	JE etiq_56


	FILD _3
	FSTP aux22
	ffree

	fld aux22
	FISTP @aux_expr

	fld  @aux
	fcomp @aux_expr
	fstsw ax
	sahf
	JE etiq_56


	FILD _4
	FSTP aux23
	ffree

	fld aux23
	FISTP @aux_expr

	fld  @aux
	fcomp @aux_expr
	fstsw ax
	sahf
	JNE etiq_61


etiq_56:

	FILD B
	FSTP aux24
	ffree


	FILD _1
	FSTP aux25
	ffree

	fld aux24
	fld aux25
	FADD
	fstp aux26

	fld aux26
	FISTP B

	JMP etiq_41


etiq_61:
	DisplayString __Mostrar_por_pantalla
	newLine 1

	GetString F
	DisplayInteger A
	newLine 1


	FILD _10
	FSTP aux27
	ffree


	FILD _101
	FSTP aux28
	ffree

	fld aux27
	fld aux28
	FADD
	fstp aux29

	fld aux29
	FISTP @aux_expr


	FILD _100
	FSTP aux30
	ffree

	fld aux30
	FISTP @max


	FILD _111
	FSTP aux31
	ffree

	fld aux31
	FISTP @aux

	fld  @max
	fcomp @aux
	fstsw ax
	sahf
	JAE etiq_75

	fld aux31
	FISTP @max


etiq_75:

	FILD C
	FSTP aux32
	ffree

	fld aux32
	FISTP @aux

	fld  @max
	fcomp @aux
	fstsw ax
	sahf
	JAE etiq_80

	fld aux32
	FISTP @max


etiq_80:
	fld  @max
	fcomp @aux_expr
	fstsw ax
	sahf
	JNE etiq_84


	FILD _5
	FSTP aux33
	ffree

	fld aux33
	FISTP D


etiq_84:

	FILD l
	FSTP aux34
	ffree


	FILD _3
	FSTP aux35
	ffree

	fld  aux34
	fcomp aux35
	fstsw ax
	sahf
	JAE etiq_119

	DisplayString __Ingrese_Numero_i
	newLine 1

	GetInteger i
	DisplayString __Ingrese_otro_numero_j
	newLine 1

	GetInteger j
	DisplayString __Ingrese_un_numero_mas_k
	newLine 1

	GetInteger k

	FILD i
	FSTP aux36
	ffree


	FILD j
	FSTP aux37
	ffree

	fld  aux36
	fcomp aux37
	fstsw ax
	sahf
	JNA etiq_107


	FILD i
	FSTP aux38
	ffree


	FILD k
	FSTP aux39
	ffree

	fld  aux38
	fcomp aux39
	fstsw ax
	sahf
	JNA etiq_105

	DisplayString __i_es_el_mayor
	newLine 1

	JMP etiq_106


etiq_105:
	DisplayString __k_es_mayor
	newLine 1


etiq_106:
	JMP etiq_114


etiq_107:

	FILD j
	FSTP aux40
	ffree


	FILD k
	FSTP aux41
	ffree

	fld  aux40
	fcomp aux41
	fstsw ax
	sahf
	JNA etiq_113

	DisplayString __j_es_mayor
	newLine 1

	JMP etiq_114


etiq_113:
	DisplayString __k_es_mayor
	newLine 1


etiq_114:

	FILD l
	FSTP aux42
	ffree


	FILD _1
	FSTP aux43
	ffree

	fld aux42
	fld aux43
	FADD
	fstp aux44

	fld aux44
	FISTP l

	JMP etiq_84


etiq_119:


mov ax,4c00h
int 21h

END start