/*..............................................................................

   Programa: b1wgen0030tt.i
   Autor   : Guilherme
   Data    : Julho/2008                  Ultima atualizacao: 23/09/2016
   Dados referentes ao programa:

   Objetivo  : Temp-tables utlizadas na BO b1wgen0030.p - Desconto de Titulos

   Alteracoes: 25/02/2008 - Incluir temp-tables para impressoes (Guilherme).
   
               10/12/2009 - Ajuste para geracao do Rating (Gabriel).
                          - Substituido campo vlopescr por vltotsfn na 
                            TEMP-TABLE tt-dsctit_dados_limite (Elton).
               
               01/04/2010 - Incluido Temp-Table tt-emprestimo (Elton).
               
               23/06/2010 - Incluir campo de envio a sede em tt-limite_tit
                            (Gabriel).             
                            
               03/06/2011 - Incluir campo dsendco3 na tt-dados_nota_pro (David).
               
               19/03/2012 - Adicionado campos na 'tt-proposta_bordero' 
                            para área uso da Digitalizaçao (Lucas).
               
               24/04/2012 - Adicionado campo 'flgdigit' nas temp-tables
                           'tt-dsctit_dados_bordero, tt-dsctit_dados_limite',
                            indicador se há documento digitalizado
                            ou nao (Tiago).  
                            
               26/06/2012 - Adicionados novos campos nas temp-tables 
                            tt-dados_dsctit, tt-dados_cecred_dsctit,
                            tt-tarifas_dsctit (David Kruger).      
                            
               09/07/2012 - Criada tt-dados_dsctit_cr para parâmetros 
                            de títulos com Cobrança Registrada
                          - Inclusao de campos na tt-dados_dsctit [TAB052]
                          - Inclusao dos campos 'flgregis' e 'tpcobran' na
                            'tt-titulos' e na 'tt-tits_do_bordero' para 
                            controle do Tipo de Cobrança
                          - Inclusao de campos na tt-desconto_titulos para
                            listagem de informaçoes de títulos descontados 
                            com e sem Registro [ATENDA]
                          - Alterado nome da Temp-Table 'tt-dados_inclusao'
                            para 'tt-dados_validacao'
                          - Adicionados campos para cob. registrara e s/ registro
                            na temp-table 'tt-tarifas_dsctit' 
                          - Adicionados campos 'nmoperad', 'tpcobran','prtitpro'
                           'prtitcar' e na 'tt-proposta_bordero' (Lucas).
                           
               05/11/2012 - Incluido a temp-table tt-ge-desc (Adriano).
               
               25/04/2014 - Aumentado format do campo cdlcremp de 3 para 4
                            posicoes (Tiago/Gielow SD137074).  
                            
               24/06/2014 - Exclusao da criacao da temp table tt-grupo-economico
                            sera utilizado a temp table tt-grupo na include b1wgen0138tt. 
                           (Chamado 130880) - (Tiago Castro - RKAM)

               26/02/2016 - Inclusao do campo dias carencia na temptable
			                melhoria 116 (Tiago/Rodrigo).

               28/06/2016 - Criacao dos campos flaprcoo e dsdetres na 
                            tt-dsctit_bordero_restricoes. (Jaison/James)

                            
               23/09/2016 - Correçao nas TEMP-TABLES colocar NO-UNDO, tt-dados_cecred_dsctit (Oscar).
                            Correçao nas TEMP-TABLES colocar NO-UNDO, tt-dados_dsctit_cr (Oscar).
               
			   07/02/2018 - Adicionados novos campos na tt-limite_tit (Luis Fernando - GFT)               

               11/12/2017 - P404 - Inclusao de Garantia de Cobertura das Operaçoes de Crédito (Augusto / Marcos (Supero))
               
			   07/03/2018 - Inclusão do novo campo 'dtrenova' na TEMP-TABLE 'tt-desconto_titulos' (Leonardo Oliveira - GFT)

               13/03/2018 - Inclusão do novo campo 'perrenov' na TEMP-TABLE 'tt-desconto_titulos' (Leonardo Oliveira - GFT)

			   14/03/2018 - Alteração da ordem dos campos na temp-table 'tt-limite_tit' (Leonardo Oliveira - GFT)

               16/03/2018 - Inclusão dos novos campos 'flgstlcr' e 'cddlinha' na TEMP-TABLE 'tt-desconto_titulos' (Leonardo Oliveira - GFT)

               20/04/2018 - Incluido o campo 'dtultmnt' na TEMP-TABLE tt-desconto_titulos (Paulo Penteado GFT)

               18/07/2019 - Adicionado os campos Nivel de Risco e Taxa na tt-dsctit_dados_limite PRJ 438 - Sprint 16 (Mateus Z / Mouts)
..............................................................................*/
    
DEF TEMP-TABLE crawljt NO-UNDO
    LIKE crapljt.

DEF TEMP-TABLE tt-risco NO-UNDO
    FIELD contador AS INTE
    FIELD dsdrisco AS CHAR
    FIELD tpregist AS INTE
    FIELD vlrrisco AS DECI
    FIELD diaratin AS INTE.

DEF TEMP-TABLE tt-analisados NO-UNDO
    FIELD recidtdb AS RECID
    INDEX tt-analisados1 recidtdb.

DEF TEMP-TABLE tt-tits_do_bordero  NO-UNDO
    FIELD cdbandoc LIKE craptdb.cdbandoc
    FIELD nrdconta LIKE craptdb.nrdconta
    FIELD nrdocmto LIKE craptdb.nrdocmto
    FIELD dtvencto LIKE craptdb.dtvencto
    FIELD dtlibbdt LIKE craptdb.dtlibbdt
    FIELD nrinssac LIKE craptdb.nrinssac
    FIELD nrcnvcob LIKE craptdb.nrcnvcob
    FIELD nrdctabb LIKE craptdb.nrdctabb 
    FIELD vltitulo LIKE craptdb.vltitulo
    FIELD vlliquid LIKE craptdb.vlliquid
    FIELD nossonum AS CHAR
    FIELD nmsacado AS CHAR 
    FIELD insittit LIKE craptdb.insittit
    FIELD flgregis AS LOG  FORMAT "REGISTRADA/SEM REGISTRO".
    
DEF TEMP-TABLE tt-dsctit_bordero_restricoes NO-UNDO
    FIELD dsrestri LIKE crapabt.dsrestri
    FIELD nrborder AS INTE    
    FIELD nrdocmto AS INTE
    FIELD nrseqdig LIKE crapabt.nrseqdig
    FIELD flaprcoo LIKE crapabt.flaprcoo
    FIELD dsdetres LIKE crapabt.dsdetres.

DEF TEMP-TABLE tt-dsctit_dados_bordero NO-UNDO
    FIELD nrborder AS INTE
    FIELD nrctrlim AS INTE
    FIELD insitbdt LIKE crapbdt.insitbdt
    FIELD txmensal LIKE crapbdt.txmensal
    FIELD txjurmor LIKE crapldc.txjurmor
    FIELD dtlibbdt LIKE crapbdt.dtlibbdt
    FIELD txdiaria LIKE crapldc.txdiaria
    FIELD qttitulo LIKE craplot.qtcompln
    FIELD vltitulo LIKE craplot.vlcompcr
    FIELD dspesqui AS CHAR
    FIELD dsdlinha AS CHAR
    FIELD dsopelib AS CHAR
    FIELD dsopedig AS CHAR
    FIELD flgdigit LIKE crapbdt.flgdigit
    FIELD cdtipdoc AS INTEGER.
      
DEF TEMP-TABLE tt-bordero_tit NO-UNDO
    FIELD dtmvtolt LIKE crapbdt.dtmvtolt
    FIELD nrborder LIKE crapbdt.nrborder
    FIELD nrctrlim LIKE crapbdt.nrctrlim
    FIELD qtcompln AS INTE
    FIELD vlcompcr AS DECI
    FIELD dssitbdt AS CHAR
    FIELD nrrecid  AS INTE
    FIELD inrisrat AS CHAR    /* P450   */
    FIELD origerat AS CHAR.   /* P450   */ 


DEF TEMP-TABLE tt-limite_tit NO-UNDO
    FIELD dtpropos LIKE craplim.dtpropos
    FIELD dtinivig LIKE craplim.dtinivig
    FIELD vllimite LIKE craplim.vllimite
    FIELD nrctrlim LIKE craplim.nrctrlim
    FIELD qtdiavig LIKE craplim.qtdiavig
    FIELD cddlinha LIKE craplim.cddlinha
    FIELD tpctrlim LIKE craplim.tpctrlim
    FIELD dssitlim AS CHAR
    FIELD dssitest AS CHAR
    FIELD dssitapr AS CHAR
    FIELD flgenvio AS CHAR
    FIELD insitlim AS INTE
    FIELD idcobope AS INTE /*LIKE craplim.idcobope*/
    FIELD cdageori LIKE craplim.cdageori.

DEF TEMP-TABLE tt-dsctit_dados_limite NO-UNDO
    FIELD txdmulta AS DECI
    FIELD codlinha LIKE crapldc.cddlinha
    FIELD dsdlinha LIKE crapldc.dsdlinha
    FIELD txjurmor LIKE crapldc.txjurmor 
    FIELD dsramati LIKE crapprp.dsramati
    FIELD vlmedtit LIKE crapprp.vlmedchq
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
    FIELD vltotsfn LIKE craplim.vltotsfn  
    FIELD nrperger LIKE craplim.nrperger  
    FIELD perfatcl LIKE crapjfn.perfatcl
    FIELD flgdigit LIKE craplim.flgdigit
    FIELD cdtipdoc AS INTEGER
    FIELD idcobope AS INTEGER
    /* PRJ 438 - Sprint 14 - Incluido campo de nivel de risco e taxa na tela do Desconto do Limite de Cheques */
    FIELD nivrisco LIKE craplim.dsrisco
    FIELD txmensal LIKE crapldc.txmensal.

DEF TEMP-TABLE tt-desconto_titulos NO-UNDO
    FIELD nrctrlim AS INTE
    FIELD dtinivig AS DATE
    FIELD qtdiavig AS INTE
    FIELD vllimite AS DECI
    FIELD qtrenova AS INTE
    FIELD dsdlinha AS CHAR
    FIELD vlutiliz AS DECI
    FIELD qtutiliz AS INTE
    FIELD cddopcao AS INTE
    FIELD qtutilcr AS INTE
    FIELD vlutilcr AS DECI
    FIELD qtutilsr AS INTE
    FIELD vlutilsr AS DECI
    FIELD dtrenova AS DATE
    FIELD perrenov AS INTE
    FIELD flgstlcr LIKE crapldc.flgstlcr
    FIELD cddlinha LIKE crapldc.cddlinha
    FIELD dtultmnt LIKE craplim.dtpropos.

DEF TEMP-TABLE tt-tot_descontos NO-UNDO
    FIELD vldscchq AS DECI
    FIELD qtdscchq AS INTE
    FIELD vldsctit AS DECI
    FIELD vllimtit AS DECI
    FIELD vllimchq AS DECI
    FIELD qtdsctit AS INTE
    FIELD vlmaxtit AS DECI
    FIELD qttotdsc AS INTE
    FIELD vltotdsc AS DECI. 

/* TAB052 */
DEF TEMP-TABLE tt-dados_dsctit NO-UNDO
    FIELD nrmespsq AS INTE FORMAT "  z9"
    FIELD vllimite AS DECI FORMAT "zzz,zzz,zz9.99" 
    FIELD vlconsul AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD vlmaxsac AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD vlminsac AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD qtrenova AS INTE FORMAT "  z9"
    FIELD qtdiavig AS INTE FORMAT "zzz9"
    FIELD qtprzmin AS INTE FORMAT " zz9"
    FIELD qtprzmax AS INTE FORMAT " zz9"
    FIELD qtminfil AS INTE FORMAT " zz9"
    FIELD pcmxctip AS DECI FORMAT "zzz9"
    FIELD pctolera AS DECI FORMAT "zz9"
    FIELD pcdmulta AS DECI FORMAT "zz9.999999"
    FIELD flgregis AS LOG  FORMAT "Registrada/Sem Registro"
    FIELD qtremcrt AS INTE FORMAT "zz9"
    FIELD qttitprt AS INTE FORMAT "zz9"
    FIELD cardbtit AS INTE FORMAT "zz9"
    FIELD pcnaopag AS DECI FORMAT "zz9"
    FIELD qtnaopag AS INTE FORMAT "zzz9"
    /*FIELD pctitemi AS DECI FORMAT "zz9"*/
    FIELD qtprotes AS INTE FORMAT "zzz9".

DEF TEMP-TABLE tt-dados_cecred_dsctit NO-UNDO LIKE tt-dados_dsctit.  
DEF TEMP-TABLE tt-dados_dsctit_cr NO-UNDO LIKE tt-dados_dsctit. /* Dados Cob. Reg. */
    
/* TAB053 */
DEF TEMP-TABLE tt-tarifas_dsctit NO-UNDO
    FIELD vltarctr AS DECI FORMAT "zz9.99"
    FIELD vltarrnv AS DECI FORMAT "zz9.99"
    FIELD vltarbdt AS DECI FORMAT "zz9.99"
    FIELD vlttitcr AS DECI FORMAT "zz9.99"
    FIELD vlttitsr AS DECI FORMAT "zz9.99"
    FIELD vltrescr AS DECI FORMAT "zz9.99"
    FIELD vltressr AS DECI FORMAT "zz9.99".
    
/* Para LANBDT, mas eh usada em outro lugares tambem */    
DEF TEMP-TABLE tt-titulos NO-UNDO
    FIELD cdbandoc LIKE crapcob.cdbandoc
    FIELD dsdoccop LIKE crapcob.dsdoccop 
    FIELD dtmvtolt LIKE crapcob.dtmvtolt
    FIELD dtlibbdt LIKE craptdb.dtlibbdt
    FIELD dtvencto LIKE crapcob.dtvencto
    FIELD idseqttl LIKE crapcob.idseqttl
    FIELD nmdsacad LIKE crapsab.nmdsacad
    FIELD nrcnvcob LIKE crapcob.nrcnvcob
    FIELD nrctrlim LIKE craplim.nrctrlim
    FIELD nrdctabb LIKE crapcob.nrdctabb
    FIELD nrdocmto LIKE crapcob.nrdocmto
    FIELD nrinssac LIKE crapcob.nrinssac
    FIELD vldescto LIKE crapcob.vldescto
    FIELD vldpagto LIKE crapcob.vldpagto
    FIELD vltitulo LIKE crapcob.vltitulo
    FIELD vlliquid LIKE craptdb.vlliquid
    FIELD flgstats AS INTE
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nrborder LIKE crapbdt.nrborder
    FIELD qtdiavig LIKE craplim.qtdiavig
    FIELD qtrenctr LIKE craplim.qtrenctr
    FIELD qtrenova LIKE craplim.qtrenova
    FIELD dtctrato LIKE craplim.dtinivig
    FIELD dssittit AS CHAR 
    FIELD flgregis AS LOGICAL
    FIELD tpcobran AS CHAR FORMAT "X(11)"
    INDEX tt-titulos1 flgstats.
    
DEF TEMP-TABLE tt-dados_validacao NO-UNDO
    FIELD qtrenova AS INTE
    FIELD qtdiamin AS INTE
    FIELD qtdiamax AS INTE
    FIELD dtvencto LIKE craplot.dtmvtopg
    FIELD qtinfoln LIKE craplot.qtinfoln
    FIELD vllimite LIKE craplim.vllimite
    FIELD vlinfodb LIKE craplot.vlinfodb
    FIELD vlinfocr LIKE craplot.vlinfocr
    FIELD qtcompln LIKE craplot.qtcompln
    FIELD vlcompdb LIKE craplot.vlcompdb
    FIELD vlcompcr LIKE craplot.vlcompcr
    FIELD vltottdb AS DECI
    FIELD vlutiliz AS DECI
    FIELD nrcustod LIKE crapass.nrdconta
    FIELD nmcustod LIKE crapass.nmprimtl
    FIELD nrborder AS INTE
    FIELD nrcpfcgc LIKE crapass.nrcpfcgc
    FIELD inpessoa LIKE crapass.inpessoa
    FIELD nrdconta LIKE crapass.nrdconta.
    
DEF TEMP-TABLE tt-contrato_limite NO-UNDO
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
    
DEF TEMP-TABLE tt-proposta_limite NO-UNDO
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
    FIELD nmdsecao AS CHAR
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
    FIELD dsdeben1 AS CHAR
    FIELD dsdeben2 AS CHAR
    FIELD vlfatura AS DECI
    FIELD vlmedtit AS DECI
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
    FIELD nmresco2 AS CHAR.

DEFINE TEMP-TABLE tt-emprsts NO-UNDO
    FIELD nrctremp AS DECI
    FIELD vlemprst AS DECI
    FIELD vlsdeved AS DECI 
    FIELD dspreapg AS CHAR
    FIELD vlpreemp AS DECI
    FIELD dslcremp AS CHAR
    FIELD dsfinemp AS CHAR.
     
DEFINE TEMP-TABLE tt-dados_nota_pro NO-UNDO
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
    
DEF TEMP-TABLE tt-proposta_bordero NO-UNDO
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
    FIELD nmdsecao AS CHAR
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
    FIELD vlmeddsc AS DECI 
    FIELD perceden AS CHAR 
    FIELD naopagos AS INTE 
    FIELD qttitsac AS INTE 
    FIELD vltottit AS DECI 
    FIELD qttottit AS INTE 
    FIELD valormed AS DECI
    FIELD qtdbolet AS INTE
    FIELD vlmedbol AS DECI
    FIELD vlmaxdsc AS DECI
    FIELD vlslddsc AS DECI
    FIELD qtdscsld AS INTE
    FIELD nrmespsq AS INTE
    FIELD cdagenci AS INTE
    FIELD nrborder AS INTE
    FIELD tpcobran AS CHAR FORMAT "X(11)"
    FIELD prtitpro AS CHAR FORMAT "x(20)"
    FIELD prtitcar AS CHAR FORMAT "x(20)"
    FIELD nmoperad AS CHAR.
    
DEF TEMP-TABLE tt-sacado_nao_pagou NO-UNDO
    FIELD nmsacado AS CHAR
    FIELD qtdtitul AS INT
    FIELD vlrtitul AS DEC.    
    
DEF TEMP-TABLE tt-dados_tits_bordero NO-UNDO
    FIELD nrdconta AS INTE 
    FIELD cdagenci AS INTE
    FIELD nrctrlim AS INTE
    FIELD nrborder AS INTE
    FIELD nrmespsq AS INTE
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
    FIELD nmoperad AS CHAR.

DEF TEMP-TABLE tt-emprestimo NO-UNDO
    FIELD cdagenci AS INT      FORMAT "zz9"  
    FIELD nrdconta AS INT      FORMAT "zzz,zzz,zz9"
    FIELD nmprimtl AS CHAR     FORMAT "x(40)"
    FIELD nrctremp AS INT      FORMAT "zzz,zzz,zz9"
    FIELD dtmvtolt AS DATE     FORMAT "99/99/9999"
    FIELD vlemprst AS DECIMAL  FORMAT "zzz,zzz,zzz,zz9"
    FIELD vlsdeved AS DECIMAL  FORMAT "zzz,zzz,zz9"
    FIELD cdlcremp AS INT      FORMAT "zzz9"
    FIELD diaprmed AS INT      FORMAT "zz9"
    FIELD dtmvtprp AS DATE     FORMAT "99/99/9999"
    FIELD dsorigem AS CHAR.
    
DEF TEMP-TABLE tt-linhas_desc NO-UNDO
    FIELD cddlinha LIKE crapldc.cddlinha
    FIELD dsdlinha LIKE crapldc.dsdlinha
    FIELD txmensal LIKE crapldc.txmensal.



/* ......................................................................... */ 


