
/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0176tt.i
    Autor   : Gabriel Capoia (DB1)
    Data    : 19/09/2013                     Ultima atualizacao:
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0176.
  
    Alteracoes: 
.............................................................................*/

DEF TEMP-TABLE tt-gt0002 NO-UNDO
    FIELD cdcooper AS INTE
    FIELD nmrescop AS CHAR
    FIELD cdconven AS INTE
    FIELD nmempres AS CHAR
    FIELD cdcooped AS INTE
    INDEX manut AS PRIMARY cdcooper cdconven.

DEF TEMP-TABLE tt-gt0002-aux NO-UNDO LIKE tt-gt0002.
