/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0142tt.i
    Autor(a): Gabriel Capoia (DB1)
    Data    : Novembro/2012                      Ultima atualizacao:
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0142.
  
    Alteracoes: 
    
.............................................................................*/ 

DEF TEMP-TABLE tt-crapcop NO-UNDO LIKE crapcop.

DEF TEMP-TABLE tt-tpodcto NO-UNDO
    FIELD nmtpdcto AS CHAR
    FIELD tpdocmto AS INTE.

DEF TEMP-TABLE tt-crapinf NO-UNDO LIKE crapinf
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD dstpdcto AS CHAR FORMAT "X(27)"
    FIELD dsdespac AS CHAR FORMAT "X(7)"
    FIELD nmfornec AS CHAR FORMAT "X(8)"
    FIELD qtinform AS INTE
    INDEX crapinf1 cdcooper dtmvtolt cdagenci.

DEF TEMP-TABLE tt-crapinf-aux NO-UNDO LIKE tt-crapinf.



