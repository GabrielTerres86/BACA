/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0177tt.i
    Autor   : Gabriel Capoia (DB1)
    Data    : 20/09/2013                     Ultima atualizacao:
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0177.
  
    Alteracoes: 
.............................................................................*/

DEF TEMP-TABLE tt-gt0003 NO-UNDO
    FIELD cdcooper AS INTE
    FIELD nmrescop AS CHAR
    FIELD cdconven AS INTE
    FIELD dtmvtolt AS DATE
    FIELD dtcredit AS DATE
    FIELD nmarquiv AS CHAR
    FIELD qtdoctos AS INTE
    FIELD vldoctos AS DECI
    FIELD vltarifa AS DECI
    FIELD vlapagar AS DECI
    FIELD nrsequen AS INTE
    FIELD cdcopdom AS INTE
    FIELD nrcnvfbr AS CHAR
    FIELD nmempres AS CHAR
    INDEX manut AS PRIMARY cdcooper cdconven.

DEF TEMP-TABLE tt-gt0003-aux NO-UNDO LIKE tt-gt0003.
