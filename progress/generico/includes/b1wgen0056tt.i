/*..............................................................................

    Programa: b1wgen0056tt.i
    Autor   : Jose Luis
    Data    : Marco/2010                   Ultima atualizacao: 19/08/2010   

    Objetivo  : Definicao das Temp-Tables para tela de BENS

    Alteracoes: 19/08/2010 - Incluir o cpf na tabela dos bens (Gabriel).
   
..............................................................................*/


DEF TEMP-TABLE tt-crapbem NO-UNDO LIKE crapbem
    FIELD nrdrowid AS ROWID
    FIELD nrcpfcgc AS DECI.

&IF DEFINED(TT-LOG) <> 0 &THEN

    DEF TEMP-TABLE tt-crapbem-ant NO-UNDO LIKE crapbem.

    DEF TEMP-TABLE tt-crapbem-atl NO-UNDO LIKE crapbem.

&ENDIF

/*............................................................................*/
