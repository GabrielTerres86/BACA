/*..............................................................................

    Programa: b1wgen0061tt.i
    Autor   : Jose Luis
    Data    : Marco/2010                   Ultima atualizacao: 23/07/2014

    Objetivo  : Definicao das Temp-Tables para tela de CLIENTE FINANCEIRO

    Alteracoes: 23/07/2014 - Adicionado campo de instituicao detentora (Reinert)
   
..............................................................................*/



/*............................................................................*/
DEFINE TEMP-TABLE tt-dadoscf NO-UNDO 
    FIELD cdcooper AS INTEGER
    FIELD nrdconta AS INTEGER
    FIELD inpessoa AS INTEGER
    FIELD nmextttl AS CHARACTER
    FIELD nrcpfcgc AS DECIMAL  
    FIELD nmresage AS CHARACTER
    FIELD nrcpfstl AS DECIMAL  
    FIELD nmsegntl AS CHARACTER
    FIELD nmextcop AS CHARACTER
    FIELD cdagenci AS INTEGER
    FIELD nrdrowid AS ROWID.

DEFINE TEMP-TABLE tt-crapsfn NO-UNDO LIKE crapsfn
    FIELD dtmvtosf AS DATE
    FIELD nrdctasf AS INTE
    FIELD nmdbanco AS CHAR
    FIELD nmageban AS CHAR
    FIELD nrdrowid AS ROWID.

DEFINE TEMP-TABLE tt-fichacad NO-UNDO
    FIELD dspessoa AS CHAR FORMAT "X(20)"
    FIELD cdagedet AS CHAR FORMAT "X(6)"
    FIELD cddbanco AS CHAR FORMAT "X(6)"
    FIELD nmdbanco AS CHAR FORMAT "X(40)"
    FIELD cdageban AS CHAR FORMAT "X(6)"
    FIELD nmageban AS CHAR FORMAT "X(40)"
    FIELD dsdemiss AS CHAR FORMAT "X(40)"
    FIELD dssitdct AS CHAR FORMAT "X(40)"
    FIELD nmrescop AS CHAR FORMAT "X(20)"
    FIELD nmprimtl AS CHAR FORMAT "X(40)"
    FIELD nmsegntl AS CHAR FORMAT "X(40)"
    FIELD nrcpfcgc AS CHAR FORMAT "X(20)"
    FIELD nrcpfstl AS CHAR FORMAT "X(20)"
    FIELD nmextttl AS CHAR FORMAT "X(35)"
    FIELD dtabtcct AS DATE FORMAT "99/99/9999"
    FIELD nmresbr1 AS CHAR FORMAT "X(25)"
    FIELD nmresbr2 AS CHAR FORMAT "X(25)"
    FIELD dsdcabec AS CHAR FORMAT "X(60)"
    FIELD dstitulo AS CHAR FORMAT "X(60)"
    FIELD dssubtit AS CHAR FORMAT "X(60)"
    FIELD dsrodape AS CHAR FORMAT "X(60)"
    FIELD cdinsdet AS INTE FORMAT "999".
    

&IF DEFINED(SESSAO-BO) &THEN

    DEFINE TEMP-TABLE tt-crapsfn-log NO-UNDO LIKE crapsfn.

&ENDIF

