/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0179tt.i
    Autor   : Jéssica Laverde Gracino (DB1)
    Data    : 27/09/2013                     Ultima atualizacao: 11/03/2016
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0179.
  
    Alteracoes: 11/03/2016 - Homologacao e ajustes da conversao da tela
                             HISTOR para WEB (Douglas - Chamado 412552)
                             
                05/12/2017 - Melhoria 458 adicionado campo inmonpld - Antonio R. Jr (Mouts)
.............................................................................*/

DEF TEMP-TABLE tt-histor NO-UNDO
    FIELD cdcooper AS INTE
    FIELD cdhistor AS INTE
    FIELD dshistor AS CHAR
    FIELD indebcre AS CHAR
    FIELD tplotmov AS INTE
    FIELD inavisar AS INTE
    FIELD nrctadeb AS INTE
    FIELD nrctacrd AS INTE
    FIELD cdhstctb AS INTE   
    FIELD dsexthst AS CHAR
    FIELD inautori AS INTE
    FIELD inclasse AS INTE
    FIELD incremes AS INTE
    FIELD inmonpld AS INTE
    FIELD indcompl AS INTE
    FIELD indebcta AS INTE
    FIELD indebfol AS INTE
    FIELD indoipmf AS INTE
    FIELD inhistor AS INTE
    FIELD nmestrut AS CHAR
    FIELD nrctatrc AS INTE
    FIELD nrctatrd AS INTE
    FIELD tpctbccu AS INTE
    FIELD tpctbcxa AS INTE
    FIELD txdoipmf AS INTE
    FIELD ingercre AS INTE
    FIELD ingerdeb AS INTE
    FIELD flgsenha AS INTE
    FIELD dsextrat AS CHAR
    FIELD vltarcsh AS DECI
    FIELD cdgrphis AS INTE
    FIELD dsgrphis AS CHAR
    FIELD cdprodut AS INTE
    FIELD dsprodut AS CHAR
    FIELD cdagrupa AS INTE
    FIELD dsagrupa AS CHAR
    FIELD vltarifa AS DECI
    FIELD vltarayl AS DECI
    FIELD vltarcxo AS DECI
    FIELD vltarint AS DECI
    FIELD txcpmfcc AS DECI.
    
DEF TEMP-TABLE tt-crapthi NO-UNDO
    FIELD cdcooper AS INTE
    FIELD cdhistor AS INTE
    FIELD dsorigem AS CHAR
    FIELD vltarifa AS DECI.

DEF TEMP-TABLE tt-produto NO-UNDO
    FIELD cdprodut AS INTE
    FIELD dsprodut AS CHAR.

DEF TEMP-TABLE tt-agrupamento NO-UNDO
    FIELD cdagrupa AS INTE
    FIELD dsagrupa AS CHAR.
