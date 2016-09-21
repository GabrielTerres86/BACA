/*.............................................................................

    Programa: b1wgen0068tt.i
    Autor   : Jose Luis
    Data    : Abril/2010                   Ultima atualizacao: 00/00/0000

    Objetivo  : Definicao das Temp-Tables, CONTAS FINANCEIRO - RESULTADO

    Alteracoes:

.............................................................................*/



/*...........................................................................*/

/* financeiro resultado */
DEFINE TEMP-TABLE tt-resultado NO-UNDO
    FIELD vlrctbru AS DECI
    FIELD vlctdpad AS DECI 
    FIELD vldspfin AS DECI
    FIELD ddprzrec AS INTE
    FIELD ddprzpag AS INTE
    FIELD cdoperad AS CHAR
    FIELD nmoperad AS CHAR
    FIELD dtaltjfn AS DATE
    FIELD nrdrowid AS ROWID.

&IF DEFINED(TT-LOG) <> 0 &THEN

    DEFINE TEMP-TABLE tt-crapjfn-ant NO-UNDO LIKE crapjfn.

    DEFINE TEMP-TABLE tt-crapjfn-atl NO-UNDO LIKE crapjfn.

&ENDIF
