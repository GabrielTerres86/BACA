/*..............................................................................

   Programa: b1wgen0009tt.i                  
   Autor   : Guilherme
   Data    : Março/2009                  Ultima atualizacao: 21/06/2016
   Dados referentes ao programa:

   Objetivo  : Temp-tables utlizadas na BO b1wgen0009.p - Desconto de Cheques

   Alteraçoes: 10/12/2009 - Incluir campos para o projeto do Rating (Gabriel).
                          - Substituida variavel vlopescr por vltotsfn nas
                            TEMP-TABLE's  tt-dscchq_dados_limite e 
                            tt-proposta_limite_chq (Elton).           
                            
               23/06/2010 - Incluir o RECID e o campo de envio a sede 
                            em tt-limite_chq (Gabriel).            
                            
               01/07/2010 - Retirar campos de rating da tt-proposta_limite_chq
                            (David). 
                            
               03/06/2011 - Incluir campo dsendco3 na tt-dados_nota_pro_chq
                            (David).             
                            
               19/03/2012 - Adicionado campos na 'tt-proposta_bordero_dscch' 
                            para área uso da Digitalizaçao (Lucas).
               
               25/04/2012 - Adicionado campo flgdigit na tt-dscchq_dados_bordero
                            e na tt-dscchq_dados_limite (Tiago). 
                            
               16/11/2012 - Incluido as temp-tables tt-ge-deschq,tt-linhas-desc
                            (Lucas R.)
                            
               23/06/2014 - Exclusao da criacao da temp table tt-ge-deschq 
                            sera utilizado a temp table tt-grupo na include b1wgen0138tt. 
                           (Chamado 130880) - (Tiago Castro - RKAM)
                           
               25/08/2014 - Incluir field dtinivig,txcetano,txcetmes na 
                            tt-dscchq_dados_limite Projeto CET (Lucas R./Gielow)
                            
               12/08/2015 - Projeto Reformulacao cadastral
                            Eliminado o campo nmdsecao (Tiago Castro - RKAM).

               21/06/2016 - Criacao do campo dsopecoo na tt-dscchq_dados_bordero,
                            campos flaprcoo e dsdetres na tt-dscchq_bordero_restricoes
                            e dsopecoo na tt-dados_chqs_bordero. (Jaison/James)

               05/09/2016 - Criacao do campo perrenov na tt-desconto_cheques.
                            Projeto 300. (Lombardi)
                            
               09/09/2016 - Criacao do campo insitblq na tt-desconto_cheques.
                            Projeto 300. (Lombardi)
                            
               12/09/2016 - Criacao do campo insitlim na tt-limite_chq
                            Projeto 300. (Lombardi)

               30/05/2017 - Criacao dos campos qtdaprov e vlraprov na tt-bordero_chq
                            Projeto 300. (Lombardi)								   

               31/05/2017 - Inclusao campo flcusthj.               
                            Projeto 300. (Odirlei-AMcom)
                            
               11/12/2017 - P404 - Inclusao de Garantia de Cobertura das Operaçoes de Crédito (Augusto / Marcos (Supero))
			   
               13/05/2019 - P450 - Rating - Retorno Rating na tt-limite_chq. 
                            Luiz Otavio Olinger Momm - AMcom.
               23/05/2019 - P450 - Rating - Retorno Rating na tt-limite_chq e tt-bordero_chq.
                            Luiz Otavio Olinger Momm - AMcom.
               
	       09/07/2019 - Inclusão das outras rendas do conjuge. PRJ438 - Sprint 14 - Rubens Lima (Mouts)
               
	       09/07/2019 - Adicionado os campos Nivel de Risco e Taxa na tt-dscchq_dados_limite PRJ 438 - Sprint 14 (Mateus Z / Mouts)

..............................................................................*/

DEF TEMP-TABLE tt-desconto_cheques NO-UNDO
    FIELD nrctrlim AS INTE
    FIELD dtinivig AS DATE
    FIELD qtdiavig AS INTE
    FIELD vllimite AS DECI
    FIELD qtrenova AS INTE
    FIELD dsdlinha AS CHAR
    FIELD vldscchq AS DECI
    FIELD qtdscchq AS INTE
    FIELD cddopcao AS INTE
    FIELD perrenov AS INTE
    FIELD insitblq AS INTE.
    
DEF TEMP-TABLE tt-limite_chq NO-UNDO
    FIELD dtpropos LIKE craplim.dtpropos
    FIELD dtinivig LIKE craplim.dtinivig
    FIELD vllimite LIKE craplim.vllimite
    FIELD nrctrlim LIKE craplim.nrctrlim
    FIELD qtdiavig LIKE craplim.qtdiavig
    FIELD cddlinha LIKE craplim.cddlinha
    FIELD dssitlim AS CHARACTER
    FIELD cddopcao AS INTEGER
    FIELD nrdrecid AS RECID
    FIELD flgenvio AS CHAR
    FIELD insitlim AS INTE
    FIELD idcobope AS INTE
    FIELD inrisrat AS CHAR    /* P450   */
    FIELD origerat AS CHAR    /* P450   */ 
    FIELD dtcancel AS DATE.


/* TAB019 */
DEF TEMP-TABLE tt-dados_dscchq NO-UNDO
    FIELD vllimite AS DECI FORMAT "zzz,zzz,zz9.99" 
    FIELD vlconchq AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD vlmaxemi AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD qtrenova AS INTE FORMAT "  z9"
    FIELD qtdiavig AS INTE FORMAT "zzz9"
    FIELD qtprzmin AS INTE FORMAT " zz9"
    FIELD qtprzmax AS INTE FORMAT " zz9"
    FIELD pcchqemi AS DECI FORMAT "zz9"
    FIELD pcchqloc AS DECI FORMAT "zz9"
    FIELD qtdevchq AS DECI FORMAT "zz9"
    FIELD pctolera AS DECI FORMAT "zz9"
    FIELD pcdmulta AS DECI FORMAT "zz9.999999"
    FIELD qtdiasoc AS INTE FORMAT "zz9".
  

DEF TEMP-TABLE tt-dscchq_dados_limite NO-UNDO
    FIELD txdmulta AS DECI
    FIELD codlinha LIKE crapldc.cddlinha
    FIELD dsdlinha LIKE crapldc.dsdlinha
    FIELD txjurmor LIKE crapldc.txjurmor 
    FIELD dsramati LIKE crapprp.dsramati
    FIELD vlmedchq LIKE crapprp.vlmedchq
    FIELD vlfatura LIKE crapprp.vlfatura
    FIELD vloutras LIKE crapprp.vloutras
    FIELD vlsalari LIKE crapprp.vlsalari
    FIELD vlsalcon LIKE crapprp.vlsalcon
    FIELD dsdbens1 AS CHAR
    FIELD dsdbens2 AS CHAR
    FIELD dsobserv AS CHAR
    FIELD insitlim LIKE craplim.insitlim
    FIELD nrctrlim LIKE craplim.nrctrlim
    FIELD vllimite LIKE craplim.vllimite
    FIELD qtdiavig LIKE craplim.qtdiavig
    FIELD cddlinha LIKE craplim.cddlinha
    FIELD dtcancel LIKE craplim.dtcancel
    FIELD nrctaav1 LIKE craplim.nrctaav1
    FIELD nrctaav2 LIKE craplim.nrctaav2
    FIELD nrgarope LIKE craplim.nrgarope
    FIELD nrinfcad LIKE craplim.nrinfcad
    FIELD nrliquid LIKE craplim.nrliquid
    FIELD nrpatlvr LIKE craplim.nrpatlvr
    FIELD nrperger LIKE craplim.nrperger                                    
    FIELD vltotsfn LIKE craplim.vltotsfn
    FIELD perfatcl LIKE crapjfn.perfatcl
    FIELD flgdigit LIKE craplim.flgdigit
    FIELD cdtipdoc AS INTEGER
    FIELD dtinivig AS DATE
    FIELD txcetano AS DECI
    FIELD txcetmes AS DECI
    FIELD idcobope AS INTEGER
    /* PRJ 438 - Sprint 14 - Incluido campo de nivel de risco e taxa na tela do Desconto do Limite de Cheques */
    FIELD nivrisco LIKE craplim.dsrisco
    FIELD txmensal LIKE crapldc.txmensal.

DEFINE TEMP-TABLE tt-dados_nota_pro_chq NO-UNDO
    FIELD ddmvtolt AS INTE
    FIELD aamvtolt AS INTE
    FIELD vlpreemp AS DECI
    FIELD dsctremp AS CHAR
    FIELD dscpfcgc AS CHAR
    FIELD dsendco1 AS CHAR
    FIELD dsendco2 AS CHAR
    FIELD dsmesref AS CHAR
    FIELD dsemsnot AS CHAR
    FIELD dtvencto AS DATE
    FIELD dsextens AS CHAR
    FIELD dsbranco AS CHAR
    FIELD dsmvtol1 AS CHAR
    FIELD dsmvtol2 AS CHAR
    FIELD dspremp1 AS CHAR
    FIELD dspremp2 AS CHAR
    FIELD nmrescop AS CHAR
    FIELD nmextcop AS CHAR
    FIELD nrdocnpj AS CHAR
    FIELD dsdmoeda AS CHAR
    FIELD nmprimtl AS CHAR
    FIELD nrdconta AS INTE
    FIELD nmcidpac AS CHAR
    FIELD dsqtdava AS CHAR
    FIELD dsendco3 AS CHAR.
    
DEF TEMP-TABLE tt-proposta_limite_chq NO-UNDO
    FIELD dsagenci AS CHAR
    FIELD vlaplica AS DECI
    FIELD vltotccr AS DECI
    FIELD telefone AS CHAR
    FIELD dstipcta AS CHAR
    FIELD vlsmdtri AS DECI
    FIELD vlcaptal AS DECI
    FIELD vlprepla AS DECI
    FIELD vlsalari AS DECI
    FIELD vlsalcon AS DECI
    FIELD vloutras AS DECI
    FIELD ddmvtolt AS INTE
    FIELD aamvtolt AS INTE
    FIELD nrctrlim AS DECI
    FIELD vllimpro AS DECI
    FIELD nrdconta AS INTE
    FIELD nrmatric AS INTE
    FIELD nmprimtl AS CHAR
    FIELD dtadmemp AS DATE
    FIELD nmempres AS CHAR
    FIELD nrcpfcgc AS CHAR
    FIELD dssitdct AS CHAR
    FIELD dtadmiss AS DATE
    FIELD nmextcop AS CHAR
    FIELD dsramati AS CHAR
    FIELD vllimcre AS DECI
    FIELD vllimchq AS DECI
    FIELD vllimtit AS DECI
    FIELD dsdeben1 AS CHAR
    FIELD dsdeben2 AS CHAR
    FIELD vlfatura AS DECI
    FIELD vlmedchq AS DECI
    FIELD dsdlinha AS CHAR
    FIELD vlsdeved AS DECI
    FIELD vlpreemp AS DECI
    FIELD dtcalcul AS DATE
    FIELD vlutiliz AS DECI
    FIELD dsobser1 AS CHAR
    FIELD dsobser2 AS CHAR
    FIELD dsobser3 AS CHAR
    FIELD dsobser4 AS CHAR
    FIELD dsmesref AS CHAR
    FIELD nmcidade AS CHAR
    FIELD nmrescop AS CHAR
    FIELD nmoperad AS CHAR
    FIELD nmresco1 AS CHAR
    FIELD nmresco2 AS CHAR
    FIELD vlrencjg AS DECI.

DEF TEMP-TABLE tt-contrato_limite_chq NO-UNDO
    FIELD nmcidade AS CHAR
    FIELD nrctrlim AS INTE
    FIELD nmextcop LIKE crapcop.nmextcop
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD dslinha1 AS CHAR
    FIELD dslinha2 AS CHAR
    FIELD dslinha3 AS CHAR
    FIELD dslinha4 AS CHAR
    FIELD nmprimt1 AS CHAR
    FIELD nmprimt2 AS CHAR
    FIELD nrdconta AS INTE
    FIELD nrcpfcgc AS CHAR
    FIELD txnrdcid AS CHAR
    FIELD dsdmoeda AS CHAR
    FIELD vllimite AS DECI
    FIELD dslimit1 AS CHAR
    FIELD dslimit2 AS CHAR
    FIELD dsdlinha AS CHAR
    FIELD qtdiavig AS INTE
    FIELD txqtdvi1 AS CHAR
    FIELD txqtdvi2 AS CHAR 
    FIELD dsjurmo1 AS CHAR
    FIELD dsjurmo2 AS CHAR
    FIELD txdmulta AS CHAR
    FIELD txmulex1 AS CHAR
    FIELD txmulex2 AS CHAR
    FIELD nmresco1 AS CHAR
    FIELD nmresco2 AS CHAR
    FIELD nmdaval1 AS CHAR 
    FIELD nmdcjav1 AS CHAR
    FIELD dscpfav1 AS CHAR
    FIELD dscfcav1 AS CHAR
    FIELD nmdaval2 AS CHAR
    FIELD nmdcjav2 AS CHAR
    FIELD dscpfav2 AS CHAR
    FIELD dscfcav2 AS CHAR
    FIELD nmoperad AS CHAR.
   
    
DEF TEMP-TABLE tt-bordero_chq NO-UNDO
    FIELD dtmvtolt LIKE crapbdc.dtmvtolt
    FIELD nrborder LIKE crapbdc.nrborder
    FIELD nrctrlim LIKE crapbdc.nrctrlim
    FIELD qtcompln AS INTE
    FIELD vlcompcr AS DECI
    FIELD dssitbdc AS CHAR
    FIELD nrrecid  AS INTE
    FIELD nrdolote LIKE crapbdc.nrdolote
    FIELD dtlibbdc LIKE crapbdc.dtlibbdc
    FIELD qtdaprov AS INTE
    FIELD vlraprov AS DECI
    FIELD flcusthj AS INTE   /* flag bordero possui cheques custodiados hj */
    FIELD inrisrat AS CHAR   /* P450   */
    FIELD origerat AS CHAR.  /* P450   */ 
    
DEF TEMP-TABLE tt-dscchq_dados_bordero NO-UNDO
    FIELD nrborder AS INTE
    FIELD nrctrlim AS INTE
    FIELD insitbdc LIKE crapbdc.insitbdc
    FIELD txmensal LIKE crapbdc.txmensal
    FIELD txjurmor LIKE crapldc.txjurmor
    FIELD dtlibbdc LIKE crapbdc.dtlibbdc
    FIELD txdiaria LIKE crapldc.txdiaria
    FIELD qtcheque LIKE craplot.qtcompln
    FIELD vlcheque LIKE craplot.vlcompcr
    FIELD dspesqui AS CHAR
    FIELD dsdlinha AS CHAR
    FIELD dsopelib AS CHAR
    FIELD dsopedig AS CHAR
    FIELD flgdigit LIKE crapbdc.flgdigit
    FIELD cdtipdoc AS INTEGER
    FIELD dsopecoo AS CHAR.
    
DEF TEMP-TABLE tt-abc_dscchq NO-UNDO
    FIELD nrrecabc AS RECID
    INDEX cratabc1 nrrecabc.    

DEF TEMP-TABLE tt-ljd_dscchq NO-UNDO
    LIKE crapljd.


DEF TEMP-TABLE tt-chqs_do_bordero  NO-UNDO
    FIELD cdcmpchq LIKE crapcdb.cdcmpchq
    FIELD cdbanchq LIKE crapcdb.cdbanchq
    FIELD cdagechq LIKE crapcdb.cdagechq
    FIELD nrddigc1 LIKE crapcdb.nrddigc1 
    FIELD nrctachq LIKE crapcdb.nrctachq
    FIELD nrddigc2 LIKE crapcdb.nrddigc2
    FIELD nrcheque LIKE crapcdb.nrcheque
    FIELD nrddigc3 LIKE crapcdb.nrddigc3
    FIELD vlcheque LIKE crapcdb.vlcheque
    FIELD vlliquid LIKE crapcdb.vlliquid
    FIELD dscpfcgc AS CHAR 
    FIELD dtlibera LIKE crapcdb.dtlibera
    FIELD nmcheque AS CHAR
    FIELD dtlibbdc LIKE crapcdb.dtlibbdc
    FIELD dtmvtolt AS DATE.

DEF TEMP-TABLE tt-dscchq_bordero_restricoes NO-UNDO
    FIELD nrborder LIKE crapcdb.nrborder
    FIELD nrcheque LIKE crapcdb.nrcheque
    FIELD dsrestri LIKE crapabc.dsrestri
    FIELD tprestri AS INTE
    FIELD flaprcoo LIKE crapabc.flaprcoo
    FIELD dsdetres LIKE crapabc.dsdetres.

DEF TEMP-TABLE tt-proposta_bordero_dscchq NO-UNDO
    FIELD dsagenci AS CHAR
    FIELD vlaplica AS DECI
    FIELD vltotccr AS DECI
    FIELD telefone AS CHAR
    FIELD dstipcta AS CHAR
    FIELD vlsmdtri AS DECI
    FIELD vlcaptal AS DECI
    FIELD vlprepla AS DECI
    FIELD vlsalari AS DECI
    FIELD vlsalcon AS DECI
    FIELD vloutras AS DECI
    FIELD ddmvtolt AS INTE
    FIELD aamvtolt AS INTE
    FIELD nrctrlim AS DECI
    FIELD vllimpro AS DECI
    FIELD nrdconta AS INTE
    FIELD nrmatric AS INTE
    FIELD nmprimtl AS CHAR
    FIELD dtadmemp AS DATE
    FIELD nmempres AS CHAR
    FIELD nrcpfcgc AS CHAR
    FIELD dssitdct AS CHAR
    FIELD dtadmiss AS DATE
    FIELD nmextcop AS CHAR
    FIELD dsramati AS CHAR
    FIELD vllimcre AS DECI
    FIELD vllimchq AS DECI
    FIELD vllimtit AS DECI
    FIELD dsdeben1 AS CHAR
    FIELD dsdeben2 AS CHAR
    FIELD vlfatura AS DECI
    FIELD vlsdeved AS DECI
    FIELD vlpreemp AS DECI
    FIELD dtcalcul AS DATE
    FIELD dsobser1 AS CHAR
    FIELD dsobser2 AS CHAR
    FIELD dsobser3 AS CHAR
    FIELD dsobser4 AS CHAR
    FIELD dsmesref AS CHAR
    FIELD nmcidade AS CHAR
    FIELD nmrescop AS CHAR
    FIELD vlmaxdsc AS DECI
    FIELD vlslddsc AS DECI
    FIELD qtdscsld AS INTE
    FIELD qtborchq AS INTE
    FIELD vlborchq AS DECI
    FIELD cdagenci AS INTE
    FIELD nrborder AS INTE.

DEF TEMP-TABLE tt-dados_chqs_bordero NO-UNDO
    FIELD nrdconta AS INTE 
    FIELD cdagenci AS INTE
    FIELD nrctrlim AS INTE
    FIELD nrborder AS INTE
    FIELD txdiaria AS DECI
    FIELD txmensal AS DECI 
    FIELD txdanual AS DECI 
    FIELD vllimite AS DECI
    FIELD ddmvtolt AS INTE 
    FIELD dsmesref AS CHAR 
    FIELD aamvtolt AS INTE 
    FIELD nmprimtl AS CHAR 
    FIELD nmresco1 AS CHAR 
    FIELD nmresco2 AS CHAR 
    FIELD nmcidade AS CHAR
    FIELD nmoperad AS CHAR
    FIELD dsopecoo AS CHAR.

DEF TEMP-TABLE tt-linhas-desc-chq NO-UNDO
    FIELD cddlinha LIKE crapldc.cddlinha
    FIELD dsdlinha LIKE crapldc.dsdlinha
    FIELD txmensal LIKE crapldc.txmensal.

/* ......................................................................... */ 
