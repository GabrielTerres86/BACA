/*.............................................................................

    Programa: b1wgen0069tt.i
    Autor   : Jose Luis
    Data    : Abril/2010                   Ultima atualizacao: 00/00/0000

    Objetivo  : Definicao das Temp-Tables, CONTAS FINANCEIRO - FATURAMENTO

    Alteracoes:

.............................................................................*/



/*...........................................................................*/

/* financeiro resultado */
DEFINE TEMP-TABLE tt-faturam NO-UNDO
    FIELD mesftbru AS INTE
    FIELD anoftbru AS INTE
    FIELD vlrftbru AS DECI
    FIELD nrposext AS INTE /* Posicao no extent */
    FIELD cdoperad AS CHAR
    FIELD nmoperad AS CHAR
    FIELD dtaltjfn AS DATE
    FIELD nrdrowid AS ROWID.

&IF DEFINED(TT-LOG) <> 0 &THEN

    DEFINE TEMP-TABLE tt-crapjfn-ant NO-UNDO LIKE crapjfn.

    DEFINE TEMP-TABLE tt-crapjfn-atl NO-UNDO LIKE crapjfn.

&ENDIF
