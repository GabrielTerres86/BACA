/*..............................................................................

    Programa: b1wgen0054tt.i
    Autor   : Jose Luis
    Data    : Janeiro/2010                   Ultima atualizacao: 00/00/0000   

    Objetivo  : Definicao das Temp-Tables para tela FILIACAO (task 119)

    Alteracoes: 
   
..............................................................................*/


DEFINE TEMP-TABLE tt-filiacao NO-UNDO 
    FIELD nmpaittl AS CHARACTER
    FIELD nmmaettl AS CHARACTER.

&IF DEFINED(TT-LOG) <> 0 &THEN

    DEFINE TEMP-TABLE tt-filiacao-ant NO-UNDO 
        FIELD nmpaittl LIKE crapttl.nmpaittl
        FIELD nmmaettl LIKE crapttl.nmmaettl
        FIELD dsfiliac LIKE crapass.dsfiliac
        FIELD dsfilstl LIKE crapass.dsfilstl
        FIELD dsfilttl LIKE crapass.dsfilttl.

    DEFINE TEMP-TABLE tt-filiacao-atl NO-UNDO LIKE tt-filiacao-ant.

&ENDIF

/*............................................................................*/


