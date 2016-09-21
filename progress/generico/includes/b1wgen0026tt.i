/*..............................................................................

   Programa: b1wgen0026tt.i                  
   Autor   : Guilherme
   Data    : Fevereiro/2008                  Ultima atualizacao:   /  /

   Dados referentes ao programa:

   Objetivo  : Temp-tables utlizadas na BO b1wgen0026.p

   Alteracoes: 
                            
..............................................................................*/

DEF TEMP-TABLE tt-totconven NO-UNDO
    FIELD qtconven AS INTE.

DEF TEMP-TABLE tt-conven NO-UNDO
    FIELD cdcooper AS INTE
    FIELD nrdconta AS INTE
    FIELD cdhistor AS INTE 
    FIELD dsexthst AS CHAR
    FIELD dtiniatr AS DATE
    FIELD dtultdeb AS DATE
    FIELD cdrefere AS DECI.

/*............................................................................*/
