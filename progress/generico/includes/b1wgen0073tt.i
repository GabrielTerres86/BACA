/*.............................................................................

    Programa: b1wgen0073tt.i
    Autor   : Jose Luis Marchezoni
    Data    : Maio/2010                   Ultima atualizacao: 00/00/0000

    Objetivo  : Definicao das Temp-Tables, CONTAS - CONTATOS

    Alteracoes:

.............................................................................*/



/*...........................................................................*/

DEFINE TEMP-TABLE tt-crapavt NO-UNDO 
    FIELD nrdctato LIKE crapavt.nrdctato
    FIELD nmdavali LIKE crapavt.nmdavali
    FIELD nrtelefo LIKE crapavt.nrtelefo
    FIELD dsdemail LIKE crapavt.dsdemail
    FIELD dsdemiss AS LOGICAL FORMAT " S /   "
    FIELD cdagenci LIKE crapavt.cdagenci
    FIELD nrcepend LIKE crapavt.nrcepend
    FIELD dsendere LIKE crapavt.dsendres[1]
    FIELD nrendere LIKE crapavt.nrendere
    FIELD complend LIKE crapavt.complend
    FIELD nmbairro LIKE crapavt.nmbairro
    FIELD nmcidade LIKE crapavt.nmcidade
    FIELD cdufende AS CHAR FORMAT "x(2)"
    FIELD nrcxapst LIKE crapavt.nrcxapst
    FIELD cddctato AS CHAR
    FIELD nrdrowid AS ROWID.

&IF DEFINED(TT-LOG) <> 0 &THEN

    DEFINE TEMP-TABLE tt-crapavt-ant NO-UNDO LIKE crapavt.

    DEFINE TEMP-TABLE tt-crapavt-atl NO-UNDO LIKE crapavt.

&ENDIF
