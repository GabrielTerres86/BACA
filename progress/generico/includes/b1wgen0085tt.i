/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0085tt.i
    Autor(a): Jose Luis Marchezoni (DB1)
    Data    : Fevereiro/2011                    Ultima atualizacao:
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0085.
  
    Alteracoes: 
    
.............................................................................*/

DEF TEMP-TABLE tt-crapobs NO-UNDO LIKE crapobs
    FIELD recidobs AS RECID
    FIELD hrtransc AS CHAR
    FIELD nmoperad LIKE crapope.nmoperad.

DEF TEMP-TABLE tt-infoass NO-UNDO 
    FIELD cdcooper LIKE crapass.cdcooper
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl.

&IF DEFINED(TT-LOG) <> 0 &THEN

    DEF TEMP-TABLE tt-crapobs-ant NO-UNDO LIKE crapobs.

    DEF TEMP-TABLE tt-crapobs-atl NO-UNDO LIKE crapobs.

&ENDIF
