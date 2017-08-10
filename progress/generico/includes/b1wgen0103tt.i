/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0103tt.i
    Autor(a): Gabriel Capoia dos Santos (DB1)
    Data    : Julho/2011                        Ultima atualizacao:20/04/2017
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0103.
  
    Alteracoes: 20/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur 
							(Adriano - P339).
    
.............................................................................*/ 

DEF TEMP-TABLE tt-desext NO-UNDO 
    FIELD cdcooper LIKE crapass.cdcooper
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD cdsecext LIKE crapass.cdsecext
    FIELD tpextcta LIKE crapass.tpextcta
    FIELD tpavsdeb LIKE crapass.tpavsdeb.

&IF DEFINED(TT-LOG) <> 0 &THEN

    DEFINE TEMP-TABLE tt-desext-ant NO-UNDO LIKE tt-desext.

    DEFINE TEMP-TABLE tt-desext-atl NO-UNDO LIKE tt-desext.

&ENDIF

DEF TEMP-TABLE tt-infoass NO-UNDO 
    FIELD cdcooper LIKE crapass.cdcooper
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl.

DEF TEMP-TABLE tt-poupanca NO-UNDO 
    FIELD cdcooper LIKE crapass.cdcooper
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD vlrdcapp AS DECI DECIMALS 8
    FIELD dddebito AS INTE FORMAT "99"
    FIELD dtvctopp LIKE craprpp.dtvctopp
    FIELD nrctrrpp LIKE craprpp.nrctrrpp
    FIELD dtiniper LIKE crapspp.dtsldrpp
    FIELD dtfimper LIKE craplpp.dtmvtolt.

DEF TEMP-TABLE tt-extrat NO-UNDO 
    FIELD cdcooper LIKE crapass.cdcooper
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nmsegntl LIKE crapttl.nmextttl
    FIELD vllimcre LIKE crapass.vllimcre
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD vlsanter AS DECI FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD vlstotal AS DECI FORMAT "zzz,zzz,zzz,zz9.99-".

DEF TEMP-TABLE tt-extrato NO-UNDO
    FIELD dtliblan AS CHAR FORMAT "x(5)"
    FIELD dshistor AS CHAR FORMAT "x(15)"
    FIELD indebcre AS CHAR FORMAT "!(1)"
    FIELD dtmvtolt AS CHAR FORMAT "x(5)"
    FIELD nrdolote AS INTE FORMAT "zzz,zz9"
    FIELD cdagenci AS INTE FORMAT "zz9"
    FIELD cdbccxlt AS INTE FORMAT "zz9"
    FIELD nrdocmto AS CHAR    FORMAT "x(11)"
    FIELD vllanmto AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"
    FIELD vlstotal AS CHAR FORMAT "x(16)"
    FIELD cdhistor AS INTE
    FIELD inhistor LIKE craphis.inhistor
    FIELD dsidenti AS CHAR
    FIELD nrsequen AS INTE
    INDEX tt-extrato1 dtmvtolt nrsequen.

DEF TEMP-TABLE tt-ext_cotas NO-UNDO
    FIELD dtmvtolt AS DATE
    FIELD dshistor AS CHAR
    FIELD nrdocmto AS DECI 
    FIELD nrctrpla AS DECI
    FIELD indebcre AS CHAR
    FIELD vllanmto AS DECI
    FIELD vlsldtot AS DECI
    FIELD cdagenci AS INTE
    FIELD cdbccxlt AS INTE
    FIELD nrdolote AS INTE.
    
DEF TEMP-TABLE tt-extapl NO-UNDO
    FIELD nrsequen AS INTE
    FIELD tpaplica LIKE craprda.tpaplica
    FIELD descapli AS CHAR
    FIELD nraplica LIKE craprpp.nrctrrpp
    FIELD dtmvtolt LIKE craprda.dtmvtolt
    FIELD tpemiext LIKE craprda.tpemiext
    FIELD dsemiext AS CHAR FORMAT "x(12)"
    INDEX ch-workapl AS UNIQUE PRIMARY
          nrsequen
          tpaplica
          nraplica.
