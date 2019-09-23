/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0144tt.i
    Autor(a): Gabriel Capoia (DB1)
    Data    : 17/12/2012                      Ultima atualizacao: 30/05/2019
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0144.
  
    Alteracoes: 04/06/2014 - Adicionado campo cdagedst na tt-crapchd. (Reinert)
    
                27/06/2014 - Adicionado temp-table tt-crapddi. (Reinert)
    
                30/05/2019 - Adicionado campo nrdocmto e nrddigc3 na tt-crapchd. (Jackson Barcellos - AMcom #P565)
    
.............................................................................*/ 
DEFINE TEMP-TABLE tt-crapchd NO-UNDO
    FIELD nmresbcc LIKE crapban.nmresbcc
    FIELD cdagenci LIKE crapchd.cdagenci
    FIELD nrdconta LIKE crapchd.nrdconta
    FIELD nrcheque LIKE crapchd.nrcheque
    FIELD vlcheque LIKE crapchd.vlcheque
    FIELD cdbccxlt LIKE crapban.cdbccxlt
    FIELD dsbccxlt AS CHAR FORMAT "x(10)"
    FIELD cdagechq AS INTE
    FIELD dsdocmc7 LIKE crapchd.dsdocmc7
    FIELD nrctachq LIKE crapchd.nrctachq
    FIELD nmextage AS CHAR
    FIELD nmprimtl AS CHAR
    FIELD nmextbcc AS CHAR FORMAT "x(50)"
    FIELD dtmvtolt LIKE crapchd.dtmvtolt
    FIELD cdcmpchq LIKE crapchd.cdcmpchq
    FIELD cdbanchq LIKE crapchd.cdbanchq
    FIELD cdagedst LIKE crapchd.cdagedst
    FIELD nrdocmto LIKE crapchd.nrdocmto
    FIELD nrddigc3 LIKE crapchd.nrddigc3.

DEF TEMP-TABLE tt-crapchd-aux NO-UNDO LIKE tt-crapchd.

DEF TEMP-TABLE tt-crapddi NO-UNDO
    FIELD cdageaco LIKE crapddi.cdageaco
    FIELD cdagedst LIKE crapddi.cdcooper
    FIELD nrdconta LIKE crapddi.nrdconta
    FIELD cdbanchq LIKE crapddi.cdbanchq
    FIELD nrcheque LIKE crapddi.nrcheque
    FIELD cdalinea LIKE crapddi.cdalinea
    FIELD nrdcaixa AS INTE FORMAT "zz9"
    FIELD dtdeposi LIKE crapddi.dtdeposi
    FIELD insitprv LIKE crapchd.insitprv
    FIELD vlcheque LIKE crapddi.vlcheque.
