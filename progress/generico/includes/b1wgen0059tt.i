/*.............................................................................

    Programa: b1wgen0059tt.i
    Autor   : Jose Luis Marchezoni (DB1)
    Data    : Marco/2010                   Ultima atualizacao: 02/08/2017

    Objetivo  : Definicao das Temp-Tables para telas de PESQUISA/ZOOM
                
    Alteracoes: 29/09/2010 - Retirado o indice da temp-table tt-titular 
                             (Adriano).
                             
                28/10/2010 - Criado TEMP-TABLE tt-craplrt para atender o 
                             projeto de Taxas Diferenciadas. (Éder-GATI)
                             
                06/01/2011 - Incluir temp-table da crapcco (Gabriel).  
                
                12/05/2011 - Inclusao da temp-table tt-gnmodal para atender
                             as modalidades de risco (Isara - RKAM). 
                             
                16/05/2011 - Inclusao de temp-table tt-craphis. (André - DB1)  
                
                19/05/2011 - Incluir flgregis na tt-crapcco (Guilherme).
                
                22/06/2011 - Incluir a tt-gnconve (Gabriel).
                
                04/07/2011 - Temp-table tt-craphis ordenada por descrição
                             (André - DB1).
                             
                06/10/2011 - Criado a temp-table tt-crapcop (Adriano).
                
                28/10/2011 - Criado a temp-table tt-crapecv (Adriano).
                
                07/11/2011 - Criado a temp-table tt-craptfn (Gabriel - DB1).
                
                12/01/2012 - Criado a temp-table tt-arquivos-pamcard. 
                             (Fabricio)
                             
                23/04/2012 - Incluir pesquisa da data de liberacao do emprestimo
                             (Gabriel).      
                             
                25/02/2013 - Ajuses realizados:
                             - Alterado o nome do campo da temp-table tt-crapcop
                               "cdcoosol" para "cdcopsol";
                             - Criado as temp-tables tt-crapope, tt-craprot.
                               (Adriano).
                               
                08/04/2013 - Incluir campos novos na tt-crapcop (Gabriel).
                
                22/07/2013 - Incluido o campo tt-crapage.orgaoins
                             (Adriano).               
   
                09/08/2013 -  Incluido campo nrcpfcgc e nrdconta na table
						      tt-crapttl (Jean Michel).
                              
                02/10/2013 -  Incluido campo nmrescop e cdagenci na table
						      tt-crapttl (Jean Michel).
                              
                15/10/2013 - Incluido campo nrdctato na table tt-crapttl (Jean Michel)     
                
                
                03/04/2014 - Incluso temp-table tt-titular2 (Daniel)     
                
                08/04/2014 - Incluso LIKE tt-crapttl (Jean Michel)      
                
                29/04/2014 - Incluido campos txbaspre nrfimpre tpgarant 
                             dsgarant na Temp-Table tt-craplcr. (Reinert)

                28/08/2014 - Inclusao da temp-table tt-crapfo
                             (Guilherme/SUPERO)
                             
                25/03/2015 - Inclusao da temp-table tt-produtos
                             (Jorge/Rodrigo)
                             
                09/07/2015 - Criacao do FIELD tpfinali na tt-crapfin 
                             para indentificar finalidade de portabilidade.
                             (Carlos Rafael Tanholi - Projeto Portabilidade) 
                             
                17/08/2015 - Projeto Reformulacao cadastral
                             Eliminado o campo nmdsecao (Tiago Castro - RKAM).

                23/09/2016 - Correçao nas TEMP-TABLES colocar NO-UNDO, tt-gncmapr (Oscar).                
                             Correçao nas TEMP-TABLES colocar NO-UNDO, tt-craplcr (Oscar).                
                             Correçao nas TEMP-TABLES colocar NO-UNDO, tt-crapfin (Oscar).                
                             Correçao nas TEMP-TABLES colocar NO-UNDO, tt-relacionamento2 (Oscar).                
                             
                17/08/2016 - Incluido campo txmensal na table tt-craplcr (Lombardi)
                             
				15/07/2017 - Incluido a temp-table tt-crapass. (Mauro)             
   
                31/07/2017 - Alterado leitura da CRAPNAT pela CRAPMUN.
                             PRJ339 - CRM (Odirlei-AMcom)                        
  
				02/08/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur 
							 (Adriano - P339).

                08/03/2018 - Alteracao na declaraçao da temp-table "tt-craptip" para 
                             nao referenciar mais a tabela craptip. PRJ366 (Lombardi).
                
............................................................................*/

&IF DEFINED(VAR-AMB) <> 0 &THEN

    DEFINE VARIABLE h-b1wgen0059 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE aux_qtregist AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_fezbusca AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE aux_flggener AS LOGICAL     NO-UNDO.

&ENDIF

&IF DEFINED(VAR-LOC) <> 0 &THEN

    DEFINE VARIABLE aux_nrregist AS INTEGER     NO-UNDO.

&ENDIF

&IF DEFINED(PROC-BUSCA) <> 0 &THEN

    PROCEDURE carrega-objeto:

        IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
            RUN sistema/generico/procedures/b1wgen0059.p 
                PERSISTENT SET h-b1wgen0059.

    END PROCEDURE.

    PROCEDURE remove-objeto:

        IF  VALID-HANDLE(h-b1wgen0059) THEN
            DELETE PROCEDURE h-b1wgen0059.

    END PROCEDURE.

&ENDIF

/* Controle para conexao com bancos genericos */
&IF DEFINED(BD-GEN) <> 0 &THEN
    
    DEFINE TEMP-TABLE tt-gngresc NO-UNDO LIKE gngresc.    

    DEFINE TEMP-TABLE tt-gncdfrm NO-UNDO LIKE gncdfrm.

    DEFINE TEMP-TABLE tt-gncdnto NO-UNDO LIKE gncdnto
        FIELD cdnatopc LIKE gncdnto.cdnatocp.

    DEFINE TEMP-TABLE tt-gncdocp NO-UNDO LIKE gncdocp.

    DEFINE TEMP-TABLE tt-gncdncg NO-UNDO LIKE gncdncg.

    DEFINE TEMP-TABLE tt-gnetcvl NO-UNDO LIKE gnetcvl.

    DEFINE TEMP-TABLE tt-gncdntj NO-UNDO LIKE gncdntj.

    DEFINE TEMP-TABLE tt-gnrativ NO-UNDO LIKE gnrativ.

    DEFINE TEMP-TABLE tt-gntpnac NO-UNDO LIKE gntpnac.

    DEFINE TEMP-TABLE tt-gnconve NO-UNDO LIKE gnconve.

    /* MODALIDADES */
    DEFINE TEMP-TABLE tt-gnmodal NO-UNDO
        FIELD cdmodali LIKE gnmodal.cdmodali
        FIELD dsmodali LIKE gnmodal.dsmodali.

    DEFINE TEMP-TABLE tt-gncmapr  NO-UNDO LIKE gncmapr.

&ENDIF

DEFINE TEMP-TABLE tt-craprad NO-UNDO LIKE craprad
    FIELD dsseqit1 AS CHAR.

DEFINE TEMP-TABLE tt-crapcem NO-UNDO LIKE crapcem.

DEFINE TEMP-TABLE tt-craptfc NO-UNDO LIKE craptfc.

DEFINE TEMP-TABLE tt-crapenc NO-UNDO LIKE crapenc.

DEFINE TEMP-TABLE tt-crapnac NO-UNDO LIKE crapnac.

DEFINE TEMP-TABLE tt-crapnat 
    FIELD dsnatura AS CHARACTER.

DEFINE TEMP-TABLE tt-crapban NO-UNDO LIKE crapban.

DEFINE TEMP-TABLE tt-crapagb NO-UNDO LIKE crapagb.

DEFINE TEMP-TABLE tt-craptip NO-UNDO
    FIELD cdtipcta AS INTEGER
	  FIELD dstipcta AS CHARACTER
	  FIELD cdcooper AS INTEGER.

DEFINE TEMP-TABLE tt-produtos  NO-UNDO 
    FIELD cdarnego AS INTEGER
    FIELD dsarnego AS CHARACTER
    FIELD cdprodut AS INTEGER
    FIELD dsprodut AS CHARACTER.

DEFINE TEMP-TABLE tt-turnos  NO-UNDO 
    FIELD cdturnos AS INTEGER
    FIELD dsturnos AS CHARACTER.

DEFINE TEMP-TABLE tt-cargos  NO-UNDO 
    FIELD cddcargo AS INTEGER
    FIELD dsdcargo AS CHARACTER.

DEFINE TEMP-TABLE tt-setorec NO-UNDO 
    FIELD cdseteco AS INTEGER
    FIELD nmseteco AS CHARACTER.

DEFINE TEMP-TABLE tt-crapifc NO-UNDO LIKE crapifc
    FIELD nmrelato AS CHAR
    FIELD dsdfrenv AS CHAR
    FIELD dsperiod AS CHAR
    FIELD dscritic AS CHAR.

DEFINE TEMP-TABLE tt-recebto NO-UNDO 
    FIELD cddfrenv AS INTE
    FIELD dsdfrenv AS CHAR
    FIELD cdrecebe AS INTE
    FIELD dsrecebe AS CHAR.

DEFINE TEMP-TABLE tt-tpimovel NO-UNDO 
    FIELD incasprp AS INTE
    FIELD dscasprp AS CHAR.

DEFINE TEMP-TABLE tt-crapage NO-UNDO 
    FIELD cdcooper AS INTE
    FIELD cdagepac AS INTE
    FIELD dsagepac AS CHAR
    FIELD orgaoins AS INTE.
    
DEFINE TEMP-TABLE tt-crapdes NO-UNDO 
    FIELD cdcooper AS INTE
    FIELD cdagepac AS INTE
    FIELD cdsecext AS INTE
    FIELD dssecext AS CHAR
    FIELD indespac AS INTE.

/* utilizado no zoom de associados */
DEFINE TEMP-TABLE tt-titular NO-UNDO
    FIELD cdcooper LIKE crapttl.cdcooper
    FIELD nrdconta LIKE crapttl.nrdconta
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nmextttl LIKE crapttl.nmextttl
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nrdctitg LIKE crapass.nrdctitg
    FIELD idseqttl LIKE crapttl.idseqttl
    FIELD nmpesttl LIKE crapttl.nmextttl
    FIELD dtnasttl LIKE crapttl.dtnasttl
    FIELD cdempres LIKE crapttl.cdempres
    FIELD dtdemiss LIKE crapass.dtdemiss
    FIELD nrdocttl AS CHAR
    FIELD dsagenci AS CHAR
	FIELD dsnivris LIKE crapass.dsnivris.
    
DEFINE TEMP-TABLE tt-oper-tel NO-UNDO
    FIELD cdopetfn AS INTE
    FIELD nmopetfn AS CHAR.

DEFINE TEMP-TABLE tt-tipo-depend NO-UNDO
    FIELD cdtipdep AS INTE
    FIELD dstipdep AS CHAR.

DEFINE TEMP-TABLE tt-tipo-rendi NO-UNDO
    FIELD tpdrendi AS INTE
    FIELD dsdrendi AS CHAR.

DEFINE TEMP-TABLE tt-crapemp NO-UNDO 
    FIELD cdempres LIKE crapemp.cdempres
    FIELD nmresemp LIKE crapemp.nmresemp.

DEFINE TEMP-TABLE tt-crapttl NO-UNDO LIKE crapttl
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdctato LIKE crapavt.nrdctato.

DEFINE TEMP-TABLE tt-mot-demissao NO-UNDO
    FIELD cdmotdem AS INTE
    FIELD dsmotdem AS CHAR.

DEFINE TEMP-TABLE tt-craplrt      NO-UNDO LIKE craplrt
    FIELD dsdtplin AS CHAR FORMAT "X(11)"
    FIELD dsdtxfix AS CHAR FORMAT "X(12)".

DEF TEMP-TABLE tt-crapcco NO-UNDO
    FIELD nrconven AS CHAR
    FIELD flgativo AS CHAR
    FIELD dsorgarq AS CHAR
    FIELD flgregis AS CHAR.

DEF TEMP-TABLE tt-craplcr NO-UNDO
    FIELD cdlcremp AS INTE
    FIELD dslcremp AS CHAR
    FIELD flgstlcr AS LOGI
    FIELD tpctrato AS INTE
    FIELD txbaspre LIKE craplcr.txbaspre
    FIELD txmensal LIKE craplcr.txmensal
    FIELD nrfimpre LIKE craplcr.nrfimpre
    FIELD tpgarant LIKE craplcr.tpctrato
    FIELD dsgarant AS CHAR.


DEF TEMP-TABLE tt-crapfin NO-UNDO
    FIELD cdfinemp AS INTE
    FIELD dsfinemp AS CHAR
    FIELD flgstfin AS LOGI
    FIELD tpfinali AS INTE.	

DEF TEMP-TABLE tt-craphis NO-UNDO
    FIELD cdhistor AS INTE
    FIELD dshistor AS CHAR.

DEFINE TEMP-TABLE tt-manut-inss NO-UNDO 
    FIELD tpregist AS INTE
    FIELD dstextab AS CHAR.

DEFINE TEMP-TABLE tt-crapcgp NO-UNDO
    FIELD cdidenti AS DECI
    FIELD cddpagto AS INTE
    FIELD nrdconta AS INTE
    FIELD nmprimtl AS CHAR.

DEF TEMP-TABLE tt-crapadt NO-UNDO
    FIELD nraditiv LIKE crapadt.nraditiv
    FIELD cdaditiv LIKE crapadt.cdaditiv.

DEF TEMP-TABLE tt-crapcop NO-UNDO
    FIELD cdcopsol LIKE crapcop.cdcooper
    FIELD nmextcop LIKE crapcop.nmextcop
    FIELD cdagectl LIKE crapcop.cdagectl
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD cdbcoctl LIKE crapcop.cdbcoctl
    FIELD cdagenmr AS CHAR.

DEF TEMP-TABLE tt-crapecv NO-UNDO
    FIELD dtvencto AS CHAR 
    FIELD nmarqimp LIKE crapecv.nmarqimp.

DEFINE TEMP-TABLE tt-craptfn NO-UNDO
    FIELD cdcooper AS INTE
    FIELD nrterfin AS INTE
    FIELD nmnarede AS CHAR
    FIELD nmterfin AS CHAR.

DEFINE TEMP-TABLE tt-arquivos-pamcard NO-UNDO
    FIELD nmarquiv AS CHAR.

DEFINE TEMP-TABLE tt-data-lib NO-UNDO
    FIELD dtlibera AS DATE.

DEFINE TEMP-TABLE tt-crapope NO-UNDO LIKE crapope.

DEFINE TEMP-TABLE tt-craprot NO-UNDO LIKE craprot.

DEFINE TEMP-TABLE tt-operador NO-UNDO LIKE crapope
    INDEX operador AS PRIMARY cdcooper nmoperad.

DEF TEMP-TABLE tt-titular2 NO-UNDO LIKE tt-titular.

DEF TEMP-TABLE tt-relacionamento NO-UNDO 
    FIELD cdcooper  AS INTE
    FIELD codigo    AS INTE
    FIELD descricao AS CHAR.

DEF TEMP-TABLE tt-relacionamento2  NO-UNDO LIKE tt-relacionamento.

DEF TEMP-TABLE tt-crapass NO-UNDO
    FIELD cdcooper AS INTE
    FIELD nrdconta AS INTE
    FIELD nmprimtl AS CHAR
    FIELD inpessoa AS INTE
    FIELD nrcpfcgc AS CHAR.

/*
DEFINE TEMP-TABLE tt-crappfo NO-UNDO LIKE crappfo.
                                              
DEFINE TEMP-TABLE tt-perfil NO-UNDO LIKE crappfo.
  */

/*...........................................................................*/

