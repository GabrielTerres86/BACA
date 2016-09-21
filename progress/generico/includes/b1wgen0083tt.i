/* ...........................................................................
   
   Programa: b1wgen0083tt.i
   Autor   : Vitor
   Data    : Janeiro/2011                              Ultima atualizacao:
   
   Dados referentes ao programa:
   
   Objetivo  : Arquivo com as variaveis da BO b1wgen0083.
   
   Alteracoes:                                                                         
                                                                            
............................................................................ */

DEF TEMP-TABLE tt-sacados
    FIELD nrcpfcgc AS CHAR FORMAT "x(18)"
    FIELD nmdsacad LIKE crapsab.nmdsacad 
    FIELD dssitsac AS CHAR FORMAT "x(7)".

DEF TEMP-TABLE tt-crapsab NO-UNDO LIKE crapsab.

DEF TEMP-TABLE tt-craprej NO-UNDO
    FIELD nrinssac AS DECI.

DEF TEMP-TABLE tt-logerro NO-UNDO
    FIELD dscrdlog AS CHAR FORMAT "x(50)".
