/*..............................................................................

    Programa: b1wgen0045tt.i
    Autor   : Guilherme - Precise
    Data    : Outubro/2009                       Ultima atualizacao: 20/03/2012

    Dados referentes ao programa:

    Objetivo  : Temp-tables utlizadas na BO b1wgen0045.p

    Alteracoes: 19/03/2010 - Incluido variavel "qtdebaut" na temp-table 
                             tt-convenio e criada nova temp-table "cratass"
                             para uso dos convenios (Elton).
                             
                14/05/2010 - Criada nova temp-table "crawass" para uso dos
                             convenios (Elton).             
                             
                20/03/2012 - Criado o campo cdagenci na tabela crawass
                             (Adriano).             
                             
..............................................................................*/

DEF TEMP-TABLE tt-qtde-cooper                                      NO-UNDO
    FIELD dtlibera AS DATE  
.

/* TT para Beneficios INSS*/
DEF TEMP-TABLE tt-tela-inss                                        NO-UNDO
    FIELD cdcooper LIKE craplbi.cdcooper
    FIELD cdagenci LIKE craplbi.cdagenci
    FIELD nmagenci LIKE crapage.nmresage
    FIELD dtdpagto LIKE craplbi.dtdpagto
    FIELD nrbenefi LIKE craplbi.nrbenefi
    FIELD nrrecben LIKE craplbi.nrrecben
    FIELD nrdconta LIKE craplbi.nrdconta
    FIELD nmrecben LIKE crapcbi.nmrecben
    FIELD tpmepgto AS CHAR
    FIELD vllanmto LIKE craplbi.vllanmto
    FIELD vlliqcre LIKE craplbi.vlliqcre
    FIELD vldoipmf AS DECIMAL
    .

DEF TEMP-TABLE tt-result-inss                                      NO-UNDO
   FIELD cdcooper LIKE craplbi.cdcooper
   FIELD cdagenci LIKE craplbi.cdagenci
   /* variaveis para  calcular valor total por pac, e quantidade */
   FIELD totalcre AS DECIMAL        /*Zera*/
   FIELD quantida AS INTEGER        /*Zera*/
   FIELD totaldcc AS DECIMAL        /*Zera*/
   FIELD quantid2 AS INTEGER        /*Zera*/
   FIELD totalpac AS DECIMAL        /*Zera*/
   FIELD quantpac AS INTEGER        /*Zera*/
   .

DEF TEMP-TABLE tt_convenio NO-UNDO
    FIELD inpessoa AS INT
    FIELD cdconven AS INT
    FIELD cdagenci AS INT FORMAT "zz9"
    FIELD qtfatura AS INT FORMAT "zzz,zz9"
    FIELD vlfatura AS DEC FORMAT "zzzz,zzz,zzz,zz9.99"
    FIELD vltarifa AS DEC FORMAT "zzzz,zzz,zzz,zz9.99"
    FIELD vlapagar AS DEC FORMAT "zzzz,zzz,zzz,zz9.99-"
    FIELD qtdebito AS INT FORMAT "zzz,zz9"
    FIELD vldebito AS DEC FORMAT "zzzz,zzz,zzz,zz9.99"
    FIELD vltardeb AS DEC FORMAT "zzzz,zzz,zzz,zz9.99"
    FIELD vlapadeb AS DEC FORMAT "zzzz,zzz,zzz,zz9.99-"
    FIELD qtdebaut AS INT. 

/* Usada para rotina de convenios */
DEF TEMP-TABLE cratlft  NO-UNDO
    FIELD cdagenci LIKE craplft.cdagenci
    FIELD inpessoa AS   INT
    FIELD nrdconta LIKE craplft.nrdconta
    FIELD vllanmto LIKE craplft.vllanmto.

/* Usada para rotina de convenios */
DEF TEMP-TABLE cratlcm  NO-UNDO
    field cdagenci like craplcm.cdagenci
    FIELD nrdconta LIKE craplcm.nrdconta
    FIELD vllanmto LIKE craplcm.vllanmto 
    FIELD inpessoa as int.    

/* Usada para rotina de convenios */
DEF TEMP-TABLE cratass NO-UNDO 
               FIELD nrdconta LIKE crapass.nrdconta.

/* Usada para armazenar todos os cooperados que tiveram 
   pelo menos um debito automatico na rotina de convenios */
DEF TEMP-TABLE crawass NO-UNDO
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD cdagenci LIKE crapass.cdagenci.

DEF TEMP-TABLE w-seguro                                     NO-UNDO
      FIELD tpseguro LIKE crapseg.tpseguro
      FIELD inpessoa AS INT
      FIELD cdagenci LIKE craplcm.cdagenci  
      FIELD cdsitseg LIKE crapseg.cdsitseg
      FIELD dtmvtolt LIKE crapseg.dtmvtolt
      FIELD dtcancel LIKE crapseg.dtcancel
      FIELD nrdconta LIKE crapseg.nrdconta
      FIELD tpplaseg LIKE crapseg.nrctrseg
      FIELD vllanmto LIKE crapseg.vlpremio       FORMAT "z,zzz,zz9.99"
      INDEX tt-seg1 tpseguro cdagenci nrdconta.

/*Temp-table igual a w-seguro p/ ser usada no input da trata_tt_seguro*/
DEF TEMP-TABLE w-seg-proc                                 NO-UNDO
      FIELD tpseguro LIKE crapseg.tpseguro
      FIELD inpessoa AS INT
      FIELD cdagenci LIKE craplcm.cdagenci  
      FIELD cdsitseg LIKE crapseg.cdsitseg
      FIELD dtmvtolt LIKE crapseg.dtmvtolt
      FIELD dtcancel LIKE crapseg.dtcancel
      FIELD nrdconta LIKE crapseg.nrdconta
      FIELD tpplaseg LIKE crapseg.nrctrseg
      FIELD vllanmto LIKE crapseg.vlpremio       FORMAT "z,zzz,zz9.99"
      INDEX tt-seg1 tpseguro cdagenci nrdconta.


DEF TEMP-TABLE tt-info-seguros                               NO-UNDO
      /* Chaves  */
      FIELD tpseguro LIKE crapseg.tpseguro
      FIELD cdagenci LIKE craplcm.cdagenci
      FIELD dtrefere AS   DATE
      FIELD inpessoa AS   INT
      /* Valores */
      FIELD qtsegaut AS   INTE
      FIELD vlsegaut AS   DECI
      FIELD vlrecaut AS   DECI
      FIELD vlrepaut AS   DECI
      FIELD qtsegvid AS   INTE
      FIELD vlsegvid AS   DECI
      FIELD vlrecvid AS   DECI
      FIELD vlrepvid AS   DECI
      FIELD qtsegres AS   INTE
      FIELD vlsegres AS   DECI
      FIELD vlrecres AS   DECI
      FIELD vlrepres AS   DECI
      FIELD qtincvid AS   INTE
      FIELD qtexcvid AS   INTE
      FIELD qtincres AS   INTE
      FIELD qtexcres AS   INTE
    INDEX ix-tt1 tpseguro cdagenci
    .

DEF TEMP-TABLE w-limites   NO-UNDO
      FIELD cdagenci  LIKE crawcrd.cdagenci
      FIELD nrdconta  LIKE crawcrd.nrdconta
      FIELD cdadmcrd  LIKE crawcrd.cdadmcrd    
      FIELD nrcrcard  LIKE crawcrd.nrcrcard
      FIELD nmtitcrd  LIKE crawcrd.nmtitcrd  FORMAT "x(28)" 
      FIELD insitcrd  LIKE crawcrd.insitcrd
      FIELD vllimcrd  AS DEC FORMAT "zzz,zzz,zz9.99"
      FIELD vllimdeb  AS DEC FORMAT "zzz,zzz,zz9.99"
      FIELD dtmvtolt  LIKE crawcrd.dtmvtolt
      FIELD dtentreg  LIKE crawcrd.dtentreg.


/*............................................................................*/
