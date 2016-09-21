/*.............................................................................

    Programa: b1wgen0066tt.i
    Autor   : Jose Luis
    Data    : Abril/2010                   Ultima atualizacao: 00/00/0000

    Objetivo  : Definicao das Temp-Tables, CONTAS FINANCEIRO - ATIVO/PASSIVO

    Alteracoes:

.............................................................................*/



/*...........................................................................*/

DEFINE TEMP-TABLE tt-atvpass NO-UNDO
    FIELD mesdbase AS INTE
    FIELD anodbase AS INTE
    FIELD vlcxbcaf AS DECI
    FIELD vlctarcb AS DECI
    FIELD vlrestoq AS DECI
    FIELD vloutatv AS DECI
    FIELD vlrimobi AS DECI
    FIELD vlfornec AS DECI
    FIELD vloutpas AS DECI
    FIELD vldivbco AS DECI
    FIELD dtaltjfn AS DATE
    FIELD cdopejfn AS CHAR
    FIELD nmoperad AS CHAR
    FIELD nrdrowid AS ROWID.

&IF DEFINED(TT-LOG) <> 0 &THEN

    DEFINE TEMP-TABLE tt-crapjfn-ant NO-UNDO LIKE crapjfn.

    DEFINE TEMP-TABLE tt-crapjfn-atl NO-UNDO LIKE crapjfn.

&ENDIF
