/*.............................................................................

    Programa: b1wgen0067tt.i
    Autor   : Jose Luis
    Data    : Abril/2010                   Ultima atualizacao: 00/00/0000

    Objetivo  : Definicao das Temp-Tables, CONTAS FINANCEIRO - BANCOS

    Alteracoes:

.............................................................................*/



/*...........................................................................*/

/* financeiro bancos */
DEFINE TEMP-TABLE tt-banco NO-UNDO
    FIELD nrdlinha AS INTE
    FIELD cddbanco AS INTE 
    FIELD dsdbanco AS CHAR
    FIELD dstipope AS CHAR    
    FIELD vlropera AS DECI
    FIELD garantia AS CHAR     
    FIELD dsvencto AS CHAR
    FIELD cdoperad AS CHAR
    FIELD nmoperad AS CHAR
    FIELD dtaltjfn AS DATE
    FIELD nrdrowid AS ROWID.

&IF DEFINED(TT-LOG) <> 0 &THEN

    DEFINE TEMP-TABLE tt-crapjfn-ant NO-UNDO LIKE crapjfn.

    DEFINE TEMP-TABLE tt-crapjfn-atl NO-UNDO LIKE crapjfn.

&ENDIF
