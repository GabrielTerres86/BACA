DEF TEMP-TABLE  tt-consiste
    FIELD nmarquiv   AS CHAR FORMAT "x(35)" 
    FIELD nrsequen   AS INTE
    FIELD nrolinha   AS INTE
    FIELD deslinha   AS CHAR
    FIELD conterro   AS CHAR
    INDEX nmarquiv               
          nrsequen.

DEF TEMP-TABLE tt-critic
    FIELD cdcritic AS INTEGER
    field cdsequen as integer
    FIELD dscritic AS CHAR FORMAT "x(100)".

DEF TEMP-TABLE tt-vldebcta
    FIELD nrsequen AS INTE
    FIELD vldebcta AS DEC.

DEFINE TEMP-TABLE tt-integracao
       FIELD nrtiporl AS INTEGER
       FIELD dsintegr AS CHAR 
       FIELD dsempres AS CHAR
       FIELD dtmvtolt LIKE craplot.dtmvtolt
       FIELD cdagenci LIKE craplot.cdagenci
       FIELD cdbccxlt LIKE craplot.cdbccxlt
       FIELD nrdolote LIKE craplot.nrdolote
       FIELD tplotmov LIKE craplot.tplotmov.

DEFINE TEMP-TABLE tt-rejeitados
       FIELD nrtiporl AS INTEGER
       FIELD nrdconta LIKE craprej.nrdconta
       FIELD cdhistor LIKE craprej.cdhistor  
       FIELD vllanmto LIKE craprej.vllanmto  
       FIELD dscritic AS CHAR.

DEFINE TEMP-TABLE tt-totais
       FIELD qtinfoln LIKE craplot.qtinfoln  
       FIELD vlinfodb LIKE craplot.vlinfodb
       FIELD vlinfocr LIKE craplot.vlinfocr  
       FIELD qtcompln LIKE craplot.qtcompln
       FIELD vlcompdb LIKE craplot.vlcompdb  
       FIELD vlcompcr LIKE craplot.vlcompcr
       FIELD qtdifeln AS INTEGER
       FIELD vldifedb AS DECIMAL
       FIELD vldifecr AS DECIMAL
       FIELD qttarifa AS INTEGER 
       FIELD vltarifa AS DECIMAL 
       FIELD vlcobrar AS DECIMAL
       FIELD nrtiporl AS INTEGER.

DEF TEMP-TABLE tt-estouro
    FIELD nroseque     AS INTEGER
    FIELD dsagenci     AS CHAR
    FIELD qtestemp     AS INTEGER
    FIELD vlestemp     AS DECIMAL
    FIELD vlestcot     AS DECIMAL
    FIELD qtestcot     AS INTEGER
    INDEX idxseque IS PRIMARY 
          nroseque ASCENDING.

DEF TEMP-TABLE tt-aviso
    FIELD cdagenci AS INT 
    FIELD cdhistor LIKE crapavs.cdhistor
    FIELD nrdconta LIKE crapavs.nrdconta
    FIELD nrsequen AS INTEGER
    FIELD nrramemp LIKE crapass.nrramemp
    FIELD cdturnos LIKE crapttl.cdturnos
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD dshistor AS CHAR
    FIELD nrdocmto LIKE crapavs.nrdocmto 
    FIELD nrseqdig LIKE crapavs.nrseqdig
    FIELD vllanmto LIKE crapavs.vllanmto
    FIELD vldebito LIKE crapavs.vldebito
    FIELD vlestdif AS DECIMAL
    FIELD dscritic AS CHAR
    INDEX i_cdagenci IS PRIMARY
          cdhistor cdagenci nrdconta nrsequen ASCENDING.

DEF TEMP-TABLE tt-agencia
    FIELD cdagenci AS INT
    FIELD dsagenci AS CHAR
    FIELD cdhistor AS INT
    FIELD dsconven AS CHAR
    FIELD dsempres AS CHAR
    FIELD dtrefere AS DATE   
    INDEX i_cdagenci IS PRIMARY
          dsconven cdagenci ASCENDING.

DEF TEMP-TABLE tt-totais-est
    FIELD cdagenci     AS INT 
    FIELD cdhistor     AS INT
    FIELD tot_qtestden AS INTEGER
    FIELD tot_vlestden AS DECIMAL
    INDEX i-total IS PRIMARY
          cdhistor cdagenci ASCENDING.

DEF TEMP-TABLE tt-totais-den
    FIELD cdhistor AS INT
    FIELD qtestden AS INT
    FIELD vlestden AS DEC
    FIELD qtavsden AS INT
    FIELD vlavsden AS DEC 
    FIELD qtdebden AS INT
    FIELD vldebden AS DEC
    INDEX i-totden AS PRIMARY
        cdhistor ASCENDING.

DEF TEMP-TABLE tt-estconv
    FIELD nroseque     AS INTEGER
    FIELD dsconven     AS CHAR
    FIELD vlavscnv     AS DECIMAL
    FIELD vldebcnv     AS DECIMAL
    FIELD vlestcnv     AS DECIMAL
    FIELD qtavscnv     AS INTEGER
    FIELD qtdebcnv     AS INTEGER
    FIELD qtestcnv     AS INTEGER
    INDEX idxseque IS PRIMARY 
          nroseque ASCENDING.

DEF TEMP-TABLE tt-listaarq
    FIELD cdempres AS INT
    FIELD nmempres AS CHAR
    FIELD dtrefere AS DATE
    FIELD ddcredit AS CHAR.
                
