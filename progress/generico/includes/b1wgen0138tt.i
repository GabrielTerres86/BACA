/*..............................................................................

    Programa: sistema/generico/includes/b1wgen0138tt.i                  
    Autor   : Guilherme
    Data    : Maio/2012                      Ultima atualizacao: 11/10/2012

   Dados referentes ao programa:

   Objetivo  : Arquivo com temp-tables utlizadas na BO b1wgen0138.p

   Alteracoes: 11/10/2012 - Incluido o campo vlendigp na temp-table tt-grupo
                            (Adriano). 
   
..............................................................................*/

DEF TEMP-TABLE tt-grupo NO-UNDO LIKE crapgrp
    FIELD vlendivi AS DECI
    FIELD vlendigp AS DECI.

DEF TEMP-TABLE tt-dados-grupo NO-UNDO
    FIELD cdcooper AS INTE
    FIELD nrdgrupo AS INTE
    FIELD dsdrisco AS CHAR
    FIELD vlendivi AS DECI
    INDEX tt-dados-grupo1 cdcooper nrdgrupo.

/*............................................................................*/
