
/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0184tt.i
    Autor   : Jéssica Laverde Gracino (DB1)
    Data    : 19/02/2014                     Ultima atualizacao:
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0184.
  
    Alteracoes: 
.............................................................................*/

DEF TEMP-TABLE tt-lislot NO-UNDO
    FIELD cdcooper AS INTE
    FIELD cdagenci AS INTE 
    FIELD nrdcaixa AS INTE
    FIELD cdoperad AS CHAR
    FIELD nmdatela AS CHAR
    FIELD idorigem AS INTE
    FIELD dsdepart AS CHAR
    FIELD dtmvtolt AS DATE
    FIELD cddopcao AS CHAR
    FIELD tpdopcao AS CHAR
    FIELD cdhistor AS INTE
    FIELD nrdconta AS INTE
    FIELD dtinicio AS DATE
    FIELD dttermin AS DATE.

DEF TEMP-TABLE tt-handle NO-UNDO
    FIELD dtmvtolt AS DATE FORMAT "99/99/9999"
    FIELD nrdconta AS INTE FORMAT "zzzz,zzz,9"
    FIELD nrdocmto AS DECI
    FIELD vllanmto AS DECI.

DEF TEMP-TABLE tt-retorno NO-UNDO
    FIELD dtmvtolt AS DATE FORMAT "99/99/9999"
    FIELD cdagenci AS INTE FORMAT "zz9"
    FIELD nrdconta AS INTE FORMAT "zzzz,zzz,9"
    FIELD nmprimtl AS CHAR
    FIELD nrdocmto AS DECI
    FIELD vllanmto AS DECI.

DEF TEMP-TABLE tt-craplcx NO-UNDO
    FIELD cdcooper AS INTE
    FIELD cdhistor AS INTE FORMAT "zzz9"
    FIELD dtmvtolt AS DATE FORMAT "99/99/9999"
    FIELD cdagenci AS INTE FORMAT "zz9"
    FIELD nrdcaixa AS INTE
    FIELD nrdocmto AS DECI
    FIELD vldocmto AS DECI.

DEF TEMP-TABLE tt-craplcm NO-UNDO
    FIELD dtmvtolt AS DATE FORMAT "99/99/9999"
    FIELD cdagenci AS INTE FORMAT "zz9"
    FIELD nrdconta AS INTE FORMAT "zzzz,zzz,9"
    FIELD cdbccxlt AS INTE
    FIELD nrdolote AS INTE
    FIELD vllanmto AS DECI     
    FIELD cdhistor AS INTE FORMAT "zzz9"
    INDEX dtmvtolt cdagenci
          nrdconta cdbccxlt
          nrdolote vllanmto
          cdhistor.

DEF TEMP-TABLE tt-lislot-aux NO-UNDO LIKE tt-retorno.

DEF TEMP-TABLE tt-craplcx-aux NO-UNDO LIKE tt-craplcx.

DEF TEMP-TABLE tt-craplcm-aux NO-UNDO LIKE tt-craplcm.
