# Compilador
UNLaM - Lenguajes y Compiladores - 2do Cuatrimestre 2021

## Integrantes
  - Facundo Garcia Pena
  - Patricio Luases
  - Pablo Rapetti
  - Ezequiel Silvero
  - Mariano Vildozola


### Para compilar

Primera parte
```
cd src\TP\Primera_Entrega
Flex Lexico.l
Bison -dyv Sintactico.y
gcc lex.yy.c y.tab.c -o Primera
```
