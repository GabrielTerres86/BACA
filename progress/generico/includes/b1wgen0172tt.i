/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0172tt.i
    Autor   : Gabriel Capoia (DB1)
    Data    : 23/08/2013                     Ultima atualizacao:
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0172.
  
    Alteracoes: 
.............................................................................*/

DEF TEMP-TABLE tt-operad NO-UNDO LIKE crapope
    FIELD dssitope AS CHAR
    FIELD ctpopera AS CHAR
    FIELD cnvopera AS CHAR
    FIELD dsperfil AS CHAR.

DEF TEMP-TABLE cratope NO-UNDO
    FIELD cdoperad AS CHAR FORMAT "x(10)"
    FIELD nmoperad AS CHAR
    FIELD cdagenci AS INTE    
    FIELD dscomite AS CHAR
    FIELD flgperac AS LOGICAL 
    FIELD vlapvcre AS DECI
    INDEX bloqueio AS PRIMARY nmoperad cdoperad.

DEF TEMP-TABLE cratoes NO-UNDO
    FIELD cdoperad AS CHAR FORMAT "x(10)"
    FIELD nmoperad AS CHAR FORMAT "x(28)"
    FIELD cdagenci LIKE crapope.cdagenci
    FIELD vlestorn LIKE crapope.vlestor1
    FIELD vlestor2 LIKE crapope.vlestor2
    INDEX operador AS PRIMARY nmoperad cdoperad.

DEF TEMP-TABLE cratope-aux NO-UNDO LIKE cratope.

DEF TEMP-TABLE cratoes-aux NO-UNDO LIKE cratoes.
