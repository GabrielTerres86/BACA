/*.............................................................................

    Programa: b1wgen0064tt.i
    Autor   : Jose Luis
    Data    : Abril/2010                   Ultima atualizacao: 00/00/0000

    Objetivo  : Definicao das Temp-Tables para tela de INFORMATIVOS

    Alteracoes:

.............................................................................*/



/*...........................................................................*/
/* Cooperado solicitou */
DEF TEMP-TABLE tt-crapcra NO-UNDO LIKE crapcra
    FIELD dsrecebe AS CHAR
    FIELD nmrelato AS CHAR
    FIELD dsdfrenv AS CHAR
    FIELD dsperiod AS CHAR
    FIELD nrdrowid AS ROWID.

/* Cooperativa dispoe */
DEFINE TEMP-TABLE tt-informativos NO-UNDO LIKE crapifc
    FIELD nmrelato AS CHAR
    FIELD dsdfrenv AS CHAR
    FIELD dsperiod AS CHAR
    FIELD dscritic AS CHAR.

/* uso de geracao de log - antiga e atual */
DEF TEMP-TABLE tt-crapcra-ant NO-UNDO LIKE tt-crapcra.

DEF TEMP-TABLE tt-crapcra-atl NO-UNDO LIKE tt-crapcra.
