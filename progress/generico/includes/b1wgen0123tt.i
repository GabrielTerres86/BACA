/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0123tt.i
    Autor(a): Gabriel Capoia dos Santos (DB1)
    Data    : Novembro/2011                      Ultima atualizacao: 27/05/2014
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0123.
  
    Alteracoes: Retirada da tt-lancamentos usar a b1wgen0025tt.i (Oscar).
    
                18/11/2013 - Adicionado campo flgblsaq em tt-terminal. (Jorge)
                
                03/04/2014 - Incluso a temp-table tt-crapcrm (Daniel).
                
                27/05/2014 - Incluido a informação de espécie de deposito e
                            relatório do mesmo. (Andre Santos - SUPERO)
    
.............................................................................*/ 

DEF TEMP-TABLE tt-terminal NO-UNDO
    FIELD nmoperad LIKE crapope.nmoperad
    FIELD nmterfin LIKE craptfn.nmterfin
    FIELD nrtempor LIKE craptfn.nrtempor
    FIELD tpdispen LIKE craptfn.tpdispen
    FIELD cdagenci LIKE craptfn.cdagenci      
    FIELD cdsitfin LIKE craptfn.cdsitfin
    FIELD dsfabtfn LIKE craptfn.dsfabtfn      
    FIELD dsmodelo LIKE craptfn.dsmodelo      
    FIELD dsdserie LIKE craptfn.dsdserie      
    FIELD nmnarede LIKE craptfn.nmnarede
    FIELD nrdendip LIKE craptfn.nrdendip
    FIELD qtcasset LIKE craptfn.qtcasset
    FIELD dsininot AS CHAR
    FIELD dsfimnot AS CHAR
    FIELD dssaqnot AS CHAR
    FIELD nrdlacre LIKE craptfn.nrdlacre
    FIELD qtnotcas LIKE craptfn.qtnotcas
    FIELD vlnotcas LIKE craptfn.vlnotcas
    FIELD vltotcas LIKE craptfn.vltotcas
    FIELD qtenvelo LIKE craptfn.qtenvelo
    FIELD dssittfn AS CHAR
    FIELD dsdispen AS CHAR
    FIELD qtdnotaG AS INTE
    FIELD vltotalG AS INTE
    FIELD vltotalP AS INTE
    FIELD qttotalP AS INTE
    FIELD dsterfin AS CHAR
    FIELD flsistaa AS LOGI
    FIELD dstempor AS CHAR
    FIELD flgblsaq LIKE craptfn.flgblsaq.

DEF TEMP-TABLE crattfn NO-UNDO
    FIELD cdcoptfn LIKE craptfn.cdcooper
    FIELD cdagetfn LIKE craptfn.cdagenci
    FIELD nmagetfn LIKE crapage.nmresage
    FIELD nrterfin LIKE craptfn.nrterfin
    FIELD dstransa AS CHAR
    FIELD nmnarede LIKE craptfn.nmnarede
    FIELD dsdoping AS CHAR
    INDEX crattfn1 cdcoptfn nrterfin.

DEF TEMP-TABLE tt-transacao NO-UNDO
    FIELD dttransa AS DATE
    FIELD dtmvtolt AS DATE
    FIELD hrtransa AS CHAR
    FIELD nrdconta AS INTE
    FIELD nrdocmto AS INTE
    FIELD nrsequni AS INTE
    FIELD vllanmto AS DECI
    FIELD nrcartao AS DECI
    FIELD dstransa AS CHAR
    FIELD dsoperad AS CHAR
    FIELD dstarefa AS CHAR.

DEF TEMP-TABLE tt-envelopes NO-UNDO
    FIELD dtmvtolt AS CHAR FORMAT "x(10)"
    FIELD hrtransa AS CHAR FORMAT "x(5)"
    FIELD nrdconta AS CHAR FORMAT "x(10)"
    FIELD nrseqenv AS CHAR FORMAT "x(11)"
    FIELD dsespeci AS CHAR FORMAT "x(2)"
    FIELD vlenvinf AS CHAR FORMAT "x(10)"
    FIELD vlenvcmp AS CHAR FORMAT "x(10)"
    FIELD dssitenv AS CHAR FORMAT "x(14)".

DEF TEMP-TABLE tt-sensores NO-UNDO
    FIELD dslocali AS CHAR
    FIELD dssensor AS CHAR.

DEF TEMP-TABLE tt-saldos NO-UNDO
    FIELD vldsdini AS DECI
    FIELD vldsdfin AS DECI
    FIELD vlrecolh AS DECI
    FIELD vlsuprim AS DECI
    FIELD vldsaque AS DECI
    FIELD vlestorn AS DECI
    FIELD vlrejeit AS DECI
    FIELD dsobserv AS CHAR.


DEF TEMP-TABLE tt-lanctos  /* Tab de retorno */
    FIELD cdtplanc   AS INT
    FIELD cdcooper   AS INT
    FIELD cdcoptfn   AS INT
    FIELD cdagetfn   AS INT
    FIELD nrdconta   AS DECI
    FIELD dstplanc   AS CHAR
    FIELD dscooper   AS CHAR
    FIELD dscoptfn   AS CHAR
    FIELD tpconsul   AS CHAR
    FIELD qtdecoop   AS INT
    FIELD qtdmovto   AS INT
    FIELD vlrtotal   AS DECI
    FIELD vlrtarif   AS DECI
    INDEX ix-lanc cdtplanc cdcooper cdcoptfn cdagetfn nrdconta.

DEF TEMP-TABLE tt-crapcrm
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD nrdconta LIKE crapcrm.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nrcartao LIKE crapcrm.nrcartao
    FIELD nmtitcrd LIKE crapcrm.nmtitcrd
    FIELD dttransa LIKE crapcrm.dttransa
    FIELD dtemscar LIKE crapcrm.dtemscar
    FIELD dtvalcar LIKE crapcrm.dtvalcar
    FIELD dstelefo AS CHAR
    INDEX itt-crapcrm cdcooper cdagenci nrdconta nrcartao.
