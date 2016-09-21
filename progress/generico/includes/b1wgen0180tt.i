
/******************************************************************************
*                                                                             *
*   Programa: b1wgen0180tt.i                                                  *
*   Autor   : Lucas R.                                                        *
*   Data    : Novembro/2013                    Ultima atualizacao: 26/05/2015 *
*                                                                             *
*   Dados referentes ao programa:                                             *
*                                                                             *
*   Objetivo  : BO Referente a criacao de temp tables da b1wgen0180.p         *
*                                                                             *
*   Alteracoes: 29/01/2014 - Incluir campo dtresgat (David).                  *
*                                                                             *
*               26/05/2015 - Incluir campo cdoperad e nmoperad (Tiago)        *
******************************************************************************/

DEF TEMP-TABLE tt-crapcsg  NO-UNDO LIKE crapcsg.
DEF TEMP-TABLE tt2-crapcsg NO-UNDO LIKE crapcsg.

DEF TEMP-TABLE tt-obtem-captacao NO-UNDO
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nraplica LIKE craprda.nraplica
    FIELD vlaplica LIKE craprda.vlaplica
    FIELD tpdaimpr AS CHAR
    FIELD dtresgat LIKE craplrg.dtresgat
    FIELD cdoperad LIKE crapope.cdoperad
    FIELD nmoperad LIKE crapope.nmoperad
    INDEX tt-obtem-captacao1 tpdaimpr 
                             vlaplica DESC
                             cdagenci
                             nrdconta.

DEF TEMP-TABLE tt-captacao NO-UNDO
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmprimtl AS CHAR FORMAT "x(40)"
    FIELD nraplica LIKE craprda.nraplica
    FIELD vlaplica LIKE craprda.vlaplica
    FIELD tpdaimpr AS CHAR
    FIELD dtresgat LIKE craplrg.dtresgat
    FIELD cdoperad LIKE crapope.cdoperad
    FIELD nmoperad LIKE crapope.nmoperad
    INDEX tt-obtem-captacao1 tpdaimpr 
                             vlaplica DESC
                             cdagenci
                             nrdconta.
    




