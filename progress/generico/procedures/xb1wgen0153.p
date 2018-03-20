
/*..............................................................................

   Programa: xb1wgen0153.p
   Autor   : Tiago Machado / Daniel Zimmermann
   Data    : Fevereiro/2013                   Ultima atualizacao: 11/07/2017

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO153 (b1wgen0153.p) 

   Alteracoes: 21/08/2013 - Incluso novo parametro na procedure 'buscar-cadtar'
                            (Daniel).

               01/04/2015 - Adicionado novo parametro (cdprodut) na procedure 
                            'carrega-tabcadpar'. (Jorge/Rodrigo)

               01/09/2015 - Criacao da procedure lista-fvl-tarifa e
                            incluir-lista-cadfco para o Projeto Melhorias 
                            Tarifas. (Jaison/Diego)

               16/02/2016 - Migraçao das rotinas da CADCAT para Oracle. (Dionathan)

               08/03/2016 - Inclusao da procedure consulta-pacotes-tarifas,
                            Prj. 218 - Pacotes de Tarifas (Jean Michel).
							
			   14/04/2016 - Alterada procedure buscar-cadtar para buscar também
						    o campo flutlpct. Prj. 218 - Pacotes de Tarifas (Lombardi).

			   25/01/2017 - Adicionadas variaveis aux_cdhiscop e aux_cdhiscnt
							(PRJ321 - Reinert).

               07/11/2017 - Adicionados campos para comportar o cadastro de 
                            tarifas por porcentual na ALTTAR.
                            Everton (Mouts) - Melhoria 150.	  
                            
               19/03/2018 - Procedure lista-tipo-conta deletada pois nao sera mais usada. 
                            PRJ366 (Lombardi).
..............................................................................*/

DEF VAR aux_cdcooper AS INTE                                       NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                       NO-UNDO.             
DEF VAR aux_nrdcaixa AS INTE                                       NO-UNDO.
DEF VAR aux_cddgrupo AS INTE                                       NO-UNDO.
DEF VAR aux_tpaplica AS INTE                                       NO-UNDO.
DEF VAR aux_nraplica AS INTE                                       NO-UNDO.
DEF VAR aux_idorigem AS INTE                                       NO-UNDO.
DEF VAR aux_nrregist AS INTE                                       NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                       NO-UNDO.
DEF VAR aux_qtregist AS INTE                                       NO-UNDO.
DEF VAR aux_dsdgrupo AS CHAR                                       NO-UNDO.
DEF VAR aux_cdinctar AS INTE                                       NO-UNDO.
DEF VAR aux_dsinctar AS CHAR                                       NO-UNDO.
DEF VAR aux_flgocorr AS LOG                                        NO-UNDO.
DEF VAR aux_flgmotiv AS LOG                                        NO-UNDO.
DEF VAR aux_cdsubgru AS INTE                                       NO-UNDO.
DEF VAR aux_dssubgru AS CHAR                                       NO-UNDO.
DEF VAR aux_cdtipcat AS INTE                                       NO-UNDO.
DEF VAR aux_dstipcat AS CHAR                                       NO-UNDO.
DEF VAR aux_cdcatego AS INTE                                       NO-UNDO.
DEF VAR aux_dscatego AS CHAR                                       NO-UNDO.
DEF VAR aux_cdfaixav AS INTE                                       NO-UNDO.
DEF VAR aux_cdtarifa AS INTE                                       NO-UNDO.
DEF VAR aux_dstarifa AS CHAR                                       NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                       NO-UNDO.
DEF VAR aux_cdocorre AS INTE                                       NO-UNDO.
DEF VAR aux_nrcnvatu AS INTE                                       NO-UNDO.
DEF VAR aux_cdmotivo AS CHAR                                       NO-UNDO.
DEF VAR aux_flglaman AS LOG                                        NO-UNDO.
DEF VAR aux_flgpacta AS LOG                                        NO-UNDO.
DEF VAR aux_vlinifvl AS DECI                                       NO-UNDO.
DEF VAR aux_vlfinfvl AS DECI                                       NO-UNDO.
DEF VAR aux_cdhistor AS INTE                                       NO-UNDO.
DEF VAR aux_dshistor AS CHAR                                       NO-UNDO.
DEF VAR aux_cdhisest AS INTE                                       NO-UNDO.
DEF VAR aux_cdhiscop AS INTE                                       NO-UNDO.
DEF VAR aux_cdhiscnt AS INTE                                       NO-UNDO.
DEF VAR aux_dshisest AS CHAR                                       NO-UNDO.
DEF VAR aux_dshiscnt AS CHAR                                       NO-UNDO.
DEF VAR aux_dshiscop AS CHAR                                       NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                       NO-UNDO.
DEF VAR aux_nrmatric AS INTE                                       NO-UNDO.
DEF VAR aux_cdtipcta AS INTE                                       NO-UNDO.
DEF VAR aux_dstipcta AS CHAR                                       NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                       NO-UNDO.
DEF VAR aux_cdmotest AS INTE                                       NO-UNDO.
DEF VAR aux_dsmotest AS CHAR                                       NO-UNDO.
DEF VAR aux_nmresage AS CHAR                                       NO-UNDO.
DEF VAR aux_cdpartar AS INTE                                       NO-UNDO.
DEF VAR aux_nmpartar AS CHAR                                       NO-UNDO.
DEF VAR aux_tpdedado AS INTE                                       NO-UNDO.
DEF VAR aux_dsconteu AS CHAR                                       NO-UNDO.
DEF VAR aux_nmrescop AS CHAR                                       NO-UNDO.
DEF VAR aux_cdcopatu AS INTE                                       NO-UNDO.
DEF VAR aux_lstcdcop AS CHAR                                       NO-UNDO.
DEF VAR aux_lstdscon AS CHAR                                       NO-UNDO.
DEF VAR aux_lstvlrep AS CHAR                                       NO-UNDO.
DEF VAR aux_lstvltar AS CHAR                                       NO-UNDO.
DEF VAR aux_lstdtvig AS CHAR                                       NO-UNDO.
DEF VAR aux_lstdtdiv AS CHAR                                       NO-UNDO.
DEF VAR aux_lstconve AS CHAR                                       NO-UNDO.
DEF VAR aux_lscdlant AS CHAR                                       NO-UNDO.
DEF VAR aux_lscdmote AS CHAR                                       NO-UNDO.
DEF VAR aux_cdfvlcop AS INTE                                       NO-UNDO.
DEF VAR aux_nrconven AS INTE                                       NO-UNDO.
DEF VAR aux_dsconven AS CHAR                                       NO-UNDO.
DEF VAR aux_flgtodos AS LOGICAL                                    NO-UNDO.

DEF VAR aux_flgvigen AS LOGICAL                                    NO-UNDO.
DEF VAR aux_vltarifa AS DECI                                       NO-UNDO.
DEF VAR aux_vlrepass AS DECI                                       NO-UNDO.
DEF VAR aux_tpcobtar AS INTE                                       NO-UNDO.
DEF VAR aux_vlpertar AS DECI                                       NO-UNDO.
DEF VAR aux_vlmintar AS DECI                                       NO-UNDO.
DEF VAR aux_vlmaxtar AS DECI                                       NO-UNDO.
DEF VAR aux_lsttptar AS CHAR                                       NO-UNDO.
DEF VAR aux_lstvlper AS CHAR                                       NO-UNDO.
DEF VAR aux_lstvlmin AS CHAR                                       NO-UNDO.
DEF VAR aux_lstvlmax AS CHAR                                       NO-UNDO.
DEF VAR aux_dtdivulg AS DATE                                       NO-UNDO.
DEF VAR aux_dtvigenc AS DATE                                       NO-UNDO.
DEF VAR aux_flgnegat AS LOGICAL                                    NO-UNDO.

DEF VAR aux_cdoperad AS CHAR                                       NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                       NO-UNDO.
DEF VAR aux_nmaplica AS CHAR                                       NO-UNDO.
DEF VAR aux_dsdconta AS CHAR                                       NO-UNDO.

DEF VAR aux_flgerlog AS LOG                                        NO-UNDO.
DEF VAR aux_flgstapl AS LOG                                        NO-UNDO.

DEF VAR aux_cagencia AS INTE                                       NO-UNDO.
DEF VAR aux_flgchcus AS LOGICAL                                    NO-UNDO. 
DEF VAR aux_cdperiod AS INTE                                       NO-UNDO. 
DEF VAR aux_mespsqch AS INTE                                       NO-UNDO.
DEF VAR aux_anopsqch AS INTE                                       NO-UNDO. 

DEF VAR aux_lstconta AS CHAR                                       NO-UNDO. 
DEF VAR aux_lsthisto AS CHAR                                       NO-UNDO. 
DEF VAR aux_lstqtdla AS CHAR                                       NO-UNDO.
DEF VAR aux_lsvlrtar AS CHAR                                       NO-UNDO.
DEF VAR aux_lsqtdchq AS CHAR                                       NO-UNDO. 
DEF VAR aux_lsfvlcop AS CHAR                                       NO-UNDO. 

DEF VAR aux_cdbattar AS CHAR                                       NO-UNDO.
DEF VAR aux_nmidenti AS CHAR                                       NO-UNDO.
DEF VAR aux_cdprogra AS CHAR                                       NO-UNDO.
DEF VAR aux_tpcadast AS INTE                                       NO-UNDO.
DEF VAR aux_cdcadast AS INTE                                       NO-UNDO.

DEF VAR aux_cddopcap AS INTE                                       NO-UNDO. 
DEF VAR aux_dtinicio AS DATE                                       NO-UNDO.
DEF VAR aux_dtafinal AS DATE                                       NO-UNDO.

DEF VAR aux_vlrtotal AS DECI                                       NO-UNDO.

DEF VAR aux_nmarqimp AS CHAR                                       NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                       NO-UNDO.

DEF VAR aux_tprelato AS INTE                                       NO-UNDO.
DEF VAR aux_cdcoptel AS INTE                                       NO-UNDO.
DEF VAR aux_cdagetel AS INTE                                       NO-UNDO.

DEF VAR aux_dtlimest AS DATE                                       NO-UNDO. 

DEF VAR aux_ccooptel AS INTE                                       NO-UNDO.

DEF VAR aux_nmendter AS CHAR                                       NO-UNDO. 

DEF VAR aux_telinpes AS INTE                                       NO-UNDO. 
DEF VAR aux_cdcopaux AS INTE                                       NO-UNDO.

DEF VAR aux_cdlcremp AS INTE                                       NO-UNDO. 
DEF VAR aux_dslcremp AS CHAR                                       NO-UNDO. 

DEF VAR aux_cdlcratu AS INTE                                       NO-UNDO.

DEF VAR aux_lstlcrem AS CHAR                                       NO-UNDO.
DEF VAR aux_lstfaixa AS CHAR                                       NO-UNDO.
DEF VAR aux_lstocorr AS CHAR                                       NO-UNDO.

DEF VAR aux_cdprodut AS INTE                                       NO-UNDO.
DEF VAR aux_dsprodut AS CHAR                                       NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                       NO-UNDO.
DEF VAR aux_cdpacote AS INTE                                       NO-UNDO.
DEF VAR aux_dspacote AS CHAR                                       NO-UNDO.

{ sistema/generico/includes/b1wgen0153tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }

/* .........................PROCEDURES................................... */

/**************************************************************************
       Procedure para atribuicao dos dados de entrada enviados por XML
**************************************************************************/
PROCEDURE valores_entrada:
    

    FOR EACH tt-param NO-LOCK:
    
        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).           
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "cddgrupo" THEN aux_cddgrupo = INTE(tt-param.valorCampo).
            WHEN "dsdgrupo" THEN aux_dsdgrupo = UPPER(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo). 
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "qtregist" THEN aux_qtregist = INTE(tt-param.valorCampo).
            WHEN "cdinctar" THEN aux_cdinctar = INTE(tt-param.valorCampo).
            WHEN "dsinctar" THEN aux_dsinctar = UPPER(tt-param.valorCampo).    
            WHEN "flgocorr" THEN aux_flgocorr = LOGICAL(tt-param.valorCampo).
            WHEN "flgmotiv" THEN aux_flgmotiv = LOGICAL(tt-param.valorCampo). 
            WHEN "cdsubgru" THEN aux_cdsubgru = INTE(tt-param.valorCampo).
            WHEN "dssubgru" THEN aux_dssubgru = UPPER(tt-param.valorCampo).
            WHEN "cdtipcat" THEN aux_cdtipcat = INTE(tt-param.valorCampo).
            WHEN "dstipcat" THEN aux_dstipcat = UPPER(tt-param.valorCampo).
            WHEN "cdcatego" THEN aux_cdcatego = INTE(tt-param.valorCampo).
            WHEN "dscatego" THEN aux_dscatego = UPPER(tt-param.valorCampo).
            WHEN "cdfaixav" THEN aux_cdfaixav = INTE(tt-param.valorCampo).
            WHEN "cdtarifa" THEN aux_cdtarifa = INTE(tt-param.valorCampo).
            WHEN "dstarifa" THEN aux_dstarifa = UPPER(tt-param.valorCampo).
            WHEN "cdtarifaInc" THEN aux_cdtarifa = INTE(tt-param.valorCampo).
            WHEN "cdtarifa_lancamentoInc" THEN aux_cdtarifa = INTE(tt-param.valorCampo).            
            WHEN "dstarifaInc" THEN aux_dstarifa = UPPER(tt-param.valorCampo).
            WHEN "inpessoa" THEN aux_inpessoa = INTE(tt-param.valorCampo).
			WHEN "tppessoa" THEN aux_inpessoa = INTE(tt-param.valorCampo).
            WHEN "cdocorre" THEN aux_cdocorre = INTE(tt-param.valorCampo).
            WHEN "cdmotivo" THEN aux_cdmotivo = tt-param.valorCampo. 
            WHEN "cdhistor" THEN aux_cdhistor = INTE(tt-param.valorCampo).
            WHEN "dshistor" THEN aux_dshistor = tt-param.valorCampo.
            WHEN "cdhisest" THEN aux_cdhisest = INTE(tt-param.valorCampo).
			WHEN "cdhisdebcop" THEN aux_cdhiscop = INTE(tt-param.valorCampo).
			WHEN "cdhisdebcnt" THEN aux_cdhiscnt = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "nrmatric" THEN aux_nrmatric = INTE(tt-param.valorCampo).
            WHEN "cdtipcta" THEN aux_cdtipcta = INTE(tt-param.valorCampo).
            WHEN "dstipcta" THEN aux_dstipcta = tt-param.valorCampo.
            WHEN "nmprimtl" THEN aux_nmprimtl = tt-param.valorCampo.
            WHEN "cdmotest" THEN aux_cdmotest = INTE(tt-param.valorCampo).
            WHEN "dsmotest" THEN aux_dsmotest = UPPER(tt-param.valorCampo).
            WHEN "tpaplica" THEN aux_tpaplica = INTE(tt-param.valorCampo).
            WHEN "nmresage" THEN aux_nmresage = tt-param.valorCampo.
            WHEN "flglaman" THEN aux_flglaman = LOGICAL(tt-param.valorCampo).
            WHEN "flgpacta" THEN aux_flgpacta = LOGICAL(tt-param.valorCampo).
            WHEN "cdpartar" THEN aux_cdpartar = INTE(tt-param.valorCampo).
            WHEN "nmpartar" THEN aux_nmpartar = tt-param.valorCampo.
            WHEN "tpdedado" THEN aux_tpdedado = INTE(tt-param.valorCampo).
            WHEN "dsconteu" THEN aux_dsconteu = tt-param.valorCampo.
            WHEN "vlfinfvl" THEN aux_vlfinfvl = DECI(tt-param.valorCampo).
            WHEN "vlinifvl" THEN aux_vlinifvl = DECI(tt-param.valorCampo).
            WHEN "nmrescop" THEN aux_nmrescop = tt-param.valorCampo.
            WHEN "cdcopatu" THEN aux_cdcopatu = INTE(tt-param.valorCampo).
            WHEN "lstcdcop" THEN aux_lstcdcop = tt-param.valorCampo.
            WHEN "lstdscon" THEN aux_lstdscon = tt-param.valorCampo.
            WHEN "lstconve" THEN aux_lstconve = tt-param.valorCampo.
            WHEN "vltarifa" THEN aux_vltarifa = DECI(tt-param.valorCampo).
            WHEN "vlrepass" THEN aux_vlrepass = DECI(tt-param.valorCampo).
			WHEN "tpcobtar" THEN aux_tpcobtar = INTE(tt-param.valorCampo).
			WHEN "vlpertar" THEN aux_vlpertar = DECI(tt-param.valorCampo).
			WHEN "vlmintar" THEN aux_vlmintar = DECI(tt-param.valorCampo).
			WHEN "vlmaxtar" THEN aux_vlmaxtar = DECI(tt-param.valorCampo).
            WHEN "dtdivulg" THEN aux_dtdivulg = DATE(tt-param.valorCampo).
            WHEN "dtvigenc" THEN aux_dtvigenc = DATE(tt-param.valorCampo).
            WHEN "flgvigen" THEN aux_flgvigen = LOGICAL(tt-param.valorCampo).
            WHEN "lstvlrep" THEN aux_lstvlrep = tt-param.valorCampo.
            WHEN "lstvltar" THEN aux_lstvltar = tt-param.valorCampo.
            WHEN "lstdtvig" THEN aux_lstdtvig = tt-param.valorCampo.
            WHEN "lstdtdiv" THEN aux_lstdtdiv = tt-param.valorCampo.
            WHEN "lscdlant" THEN aux_lscdlant = tt-param.valorCampo.
            WHEN "lscdmote" THEN aux_lscdmote = tt-param.valorCampo.
            WHEN "flgnegat" THEN aux_flgnegat = LOGICAL(tt-param.valorCampo).
            WHEN "cdfvlcop" THEN aux_cdfvlcop = INTE(tt-param.valorCampo).
            WHEN "flgtodos" THEN aux_flgtodos = LOGICAL(tt-param.valorCampo).
            WHEN "cagencia" THEN aux_cagencia = INTE(tt-param.valorCampo).
            WHEN "flgchcus" THEN aux_flgchcus = LOGICAL(tt-param.valorCampo).
            WHEN "dshisest" THEN aux_dshisest = tt-param.valorCampo.
			WHEN "dshisdebcnt" THEN aux_dshiscnt = tt-param.valorCampo.
			WHEN "dshisdebcop" THEN aux_dshiscop = tt-param.valorCampo.
            WHEN "cdperiod" THEN aux_cdperiod = INTE(tt-param.valorCampo).
            WHEN "mespsqch" THEN aux_mespsqch = INTE(tt-param.valorCampo). 
            WHEN "anopsqch" THEN aux_anopsqch = INTE(tt-param.valorCampo). 
            WHEN "lstconta" THEN aux_lstconta = tt-param.valorCampo.
            WHEN "lsthisto" THEN aux_lsthisto = tt-param.valorCampo.
            WHEN "lstqtdla" THEN aux_lstqtdla = tt-param.valorCampo.
            WHEN "lsvlrtar" THEN aux_lsvlrtar = tt-param.valorCampo.
            WHEN "lsqtdchq" THEN aux_lsqtdchq = tt-param.valorCampo.
            WHEN "lsfvlcop" THEN aux_lsfvlcop = tt-param.valorCampo.
            WHEN "cdbattar" THEN aux_cdbattar = UPPER(tt-param.valorCampo).
            WHEN "nmidenti" THEN aux_nmidenti = UPPER(tt-param.valorCampo).
            WHEN "tpcadast" THEN aux_tpcadast = INTE(tt-param.valorCampo).
            WHEN "cdcadast" THEN aux_cdcadast = INTE(tt-param.valorCampo).
            WHEN "cdprogra" THEN aux_cdprogra = tt-param.valorCampo.
            WHEN "cddopcap" THEN aux_cddopcap = INTE(tt-param.valorCampo). 
            WHEN "dtinicio" THEN aux_dtinicio = DATE(tt-param.valorCampo). 
            WHEN "dtafinal" THEN aux_dtafinal = DATE(tt-param.valorCampo).
            WHEN "vlrtotal" THEN aux_vlrtotal = DECI(tt-param.valorCampo).
            WHEN "nmarqimp" THEN aux_nmarqimp = tt-param.valorCampo.
            WHEN "nmarqpdf" THEN aux_nmarqpdf = tt-param.valorCampo.
            WHEN "tprelato" THEN aux_tprelato = INTE(tt-param.valorCampo).
            WHEN "cdcoptel" THEN aux_cdcoptel = INTE(tt-param.valorCampo).
            WHEN "cdagetel" THEN aux_cdagetel = INTE(tt-param.valorCampo).
            WHEN "dtlimest" THEN aux_dtlimest = DATE(tt-param.valorCampo).
            WHEN "cdagetel" THEN aux_cdagetel = INTE(tt-param.valorCampo).
            WHEN "ccooptel" THEN aux_ccooptel = INTE(tt-param.valorCampo).
            WHEN "nmendter" THEN aux_nmendter = tt-param.valorCampo.
            WHEN "telinpes" THEN aux_telinpes = INTE(tt-param.valorCampo).
            WHEN "inproces" THEN aux_inproces = INTE(tt-param.valorCampo).
            WHEN "cdcopaux" THEN aux_cdcopaux = INTE(tt-param.valorCampo).
            WHEN "nrconven" THEN aux_nrconven = INTE(tt-param.valorCampo).
            WHEN "dsconven" THEN aux_dsconven = tt-param.valorCampo.
            WHEN "nrcnvatu" THEN aux_nrcnvatu = INTE(tt-param.valorCampo).
            WHEN "cdlcremp" THEN aux_cdlcremp = INTE(tt-param.valorCampo).
            WHEN "dslcremp" THEN aux_dslcremp = tt-param.valorCampo.
            WHEN "cdlcratu" THEN aux_cdlcratu = INTE(tt-param.valorCampo).
            WHEN "lstlcrem" THEN aux_lstlcrem = tt-param.valorCampo.
            WHEN "cdprodut" THEN aux_cdprodut = INTE(tt-param.valorCampo).
            WHEN "lstfaixa" THEN aux_lstfaixa = tt-param.valorCampo.
            WHEN "lstocorr" THEN aux_lstocorr = tt-param.valorCampo.
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "cdpacote" THEN aux_cdpacote = INTE(tt-param.valorCampo).
            WHEN "dspacote" THEN aux_dspacote = tt-param.valorCampo.
			WHEN "lsttptar" THEN aux_lsttptar = tt-param.valorCampo.
			WHEN "lstvlper" THEN aux_lstvlper = tt-param.valorCampo.
			WHEN "lstvlmin" THEN aux_lstvlmin = tt-param.valorCampo.
			WHEN "lstvlmax" THEN aux_lstvlmax = tt-param.valorCampo.
			
        END CASE.
                                                                    
    END. /** Fim do FOR EACH tt-param **/
    
END PROCEDURE.

/******************************************************************************
 Listagem de GRUPOS 
******************************************************************************/
PROCEDURE lista-grupos:

    RUN lista-grupos IN hBO(INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrregist,
                            INPUT aux_nriniseq,
                            INPUT aux_cddgrupo,
                            INPUT aux_dsdgrupo,
                            OUTPUT aux_qtregist,
                            OUTPUT TABLE tt-grupos).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-grupos:HANDLE,
                             INPUT "Grupo").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************
 Incluir cadgru
******************************************************************************/
PROCEDURE incluir-cadgru:

    RUN incluir-cadgru IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cddgrupo,
                              INPUT aux_dsdgrupo,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Alterar cadgru
******************************************************************************/
PROCEDURE alterar-cadgru:

    RUN alterar-cadgru IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cddgrupo,
                              INPUT aux_dsdgrupo,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Excluir cadgru
******************************************************************************/
PROCEDURE excluir-cadgru:

    RUN excluir-cadgru IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cddgrupo,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Buscar cadgru
******************************************************************************/
PROCEDURE buscar-cadgru:

    RUN buscar-cadgru IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cddgrupo,
                              OUTPUT aux_dsdgrupo,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "dsdgrupo",INPUT STRING(aux_dsdgrupo)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Busca de novo codigo crapgru
******************************************************************************/
PROCEDURE busca-novo-cddgrupo:

    RUN busca-novo-cddgrupo IN hBO(INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nmdatela,
                                   INPUT aux_idorigem,
                                   OUTPUT aux_cddgrupo).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "cddgrupo",INPUT STRING(aux_cddgrupo)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/**************************************************************************/
/*                  TELA CADINT                                           */
/**************************************************************************/

/******************************************************************************
 Listagem de tipos de ocorrencias 
******************************************************************************/
PROCEDURE lista-int:

    RUN lista-int IN hBO(INPUT aux_cdcooper,
                         INPUT aux_cdagenci,
                         INPUT aux_nrdcaixa,
                         INPUT aux_cdoperad,
                         INPUT aux_nmdatela,
                         INPUT aux_idorigem,
                         INPUT aux_nrregist,
                         INPUT aux_nriniseq,
                         INPUT aux_cdinctar,
                         OUTPUT aux_qtregist,
                         OUTPUT TABLE tt-cadint).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-cadint:HANDLE,
                             INPUT "Incidencia").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************
 Incluir cadint
******************************************************************************/
PROCEDURE incluir-cadint:

    RUN incluir-cadint IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdinctar,
                              INPUT aux_dsinctar,
                              INPUT aux_flgocorr,
                              INPUT aux_flgmotiv,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Alterar cadint
******************************************************************************/
PROCEDURE alterar-cadint:

    RUN alterar-cadint IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdinctar,
                              INPUT aux_dsinctar,
                              INPUT aux_flgocorr,
                              INPUT aux_flgmotiv,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Excluir cadint
******************************************************************************/
PROCEDURE excluir-cadint:

    RUN excluir-cadint IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdinctar,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Buscar cadint
******************************************************************************/
PROCEDURE buscar-cadint:

    RUN buscar-cadint IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdinctar,
                              OUTPUT aux_dsinctar,
                              OUTPUT aux_flgocorr,
                              OUTPUT aux_flgmotiv,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "dsinctar",INPUT STRING(aux_dsinctar)).
            RUN piXmlAtributo (INPUT "flgocorr",INPUT STRING(aux_flgocorr)).
            RUN piXmlAtributo (INPUT "flgmotiv",INPUT STRING(aux_flgmotiv)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Busca de novo codigo crapint
******************************************************************************/
PROCEDURE busca-novo-cdinctar:

    RUN busca-novo-cdinctar IN hBO(INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nmdatela,
                                   INPUT aux_idorigem,
                                   OUTPUT aux_cdinctar).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "cdinctar",INPUT STRING(aux_cdinctar)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/*****************************************************************************
                tela sub grupo
*****************************************************************************/

/******************************************************************************
 Buscar cadsgr
******************************************************************************/
PROCEDURE buscar-cadsgr:

    RUN buscar-cadsgr IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdsubgru,
                              OUTPUT aux_cddgrupo,
                              OUTPUT aux_dsdgrupo,
                              OUTPUT aux_dssubgru,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "cddgrupo",INPUT STRING(aux_cddgrupo)).
            RUN piXmlAtributo (INPUT "dsdgrupo",INPUT STRING(aux_dsdgrupo)).
            RUN piXmlAtributo (INPUT "dssubgru",INPUT STRING(aux_dssubgru)).
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************
 Listagem de SUBGRUPOS 
******************************************************************************/
PROCEDURE lista-subgrupos:

    RUN lista-subgrupos IN hBO(INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nmdatela,
                               INPUT aux_idorigem,
                               INPUT aux_nrregist,
                               INPUT aux_nriniseq,
                               INPUT aux_cdsubgru,
                               INPUT aux_cddgrupo,
                               INPUT aux_dssubgru,
                               OUTPUT aux_qtregist,
                               OUTPUT TABLE tt-subgrupos).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-subgrupos:HANDLE,
                             INPUT "Sub-grupo").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Incluir cadsgr
******************************************************************************/
PROCEDURE incluir-cadsgr:

    RUN incluir-cadsgr IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdsubgru,
                              INPUT aux_dssubgru,
                              INPUT aux_cddgrupo,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Alterar cadsgr
******************************************************************************/
PROCEDURE alterar-cadsgr:

    RUN alterar-cadsgr IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdsubgru,
                              INPUT aux_dssubgru,
                              INPUT aux_cddgrupo,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Excluir cadsgr
******************************************************************************/
PROCEDURE excluir-cadsgr:

    RUN excluir-cadsgr IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdsubgru,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Busca de novo codigo crapint
******************************************************************************/
PROCEDURE busca-novo-cdsubgru:

    RUN busca-novo-cdsubgru IN hBO(INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nmdatela,
                                   INPUT aux_idorigem,
                                   OUTPUT aux_cdsubgru).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "cdsubgru",INPUT STRING(aux_cdsubgru)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/*******************************************************************************
                             TELA CADTIC
*******************************************************************************/
/******************************************************************************
 Busca de novo codigo crapint
******************************************************************************/
PROCEDURE busca-novo-cdtipcat:

    RUN busca-novo-cdtipcat IN hBO(INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nmdatela,
                                   INPUT aux_idorigem,
                                   OUTPUT aux_cdtipcat).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "cdtipcat",INPUT STRING(aux_cdtipcat)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Listagem de Tipos de Categoria 
******************************************************************************/
PROCEDURE lista-tipos-categoria:

    RUN lista-tipos-categoria IN hBO(INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nmdatela,
                                     INPUT aux_idorigem,
                                     INPUT aux_nrregist,
                                     INPUT aux_nriniseq,
                                     INPUT aux_cdtipcat,
                                     OUTPUT aux_qtregist,
                                     OUTPUT TABLE tt-tipcat).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-tipcat:HANDLE,
                             INPUT "TiposCategoria").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Incluir cadtic
******************************************************************************/
PROCEDURE incluir-cadtic:

    RUN incluir-cadtic IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdtipcat,
                              INPUT aux_dstipcat,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Alterar cadtic
******************************************************************************/
PROCEDURE alterar-cadtic:

    RUN alterar-cadtic IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdtipcat,
                              INPUT aux_dstipcat,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Excluir cadtic
******************************************************************************/
PROCEDURE excluir-cadtic:

    RUN excluir-cadtic IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdtipcat,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Buscar cadtic
******************************************************************************/
PROCEDURE buscar-cadtic:

    RUN buscar-cadtic IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdtipcat,
                              OUTPUT aux_dstipcat,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "dstipcat",INPUT STRING(aux_dstipcat)).
            RUN piXmlSave.
        END.

END PROCEDURE.


/*******************************************************************************
                             TELA CADTAR
*******************************************************************************/

/******************************************************************************
 Busca de novo codigo crapcat
******************************************************************************/
PROCEDURE busca-novo-cdcatego:

    RUN busca-novo-cdcatego IN hBO(INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nmdatela,
                                   INPUT aux_idorigem,
                                   OUTPUT aux_cdcatego).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "cdcatego",INPUT STRING(aux_cdcatego)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Listagem de Convenios
******************************************************************************/
PROCEDURE lista-convenios:

    RUN lista-convenios IN hBO(INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nmdatela,
                               INPUT aux_idorigem,
                               INPUT aux_nrregist,
                               INPUT aux_nriniseq,
                               INPUT aux_cdcopatu,
                               INPUT aux_nrconven,
                               INPUT aux_dsconven,
                               INPUT aux_cdocorre,
                               INPUT aux_cdinctar,
                               OUTPUT aux_qtregist,
                               OUTPUT TABLE tt-convenios).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-convenios:HANDLE,
                             INPUT "Convenios").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Listagem de Linhas Credito
******************************************************************************/
PROCEDURE lista-linhas-credito:

    RUN lista-linhas-credito IN hBO(INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nmdatela,
                               INPUT aux_idorigem,
                               INPUT aux_nrregist,
                               INPUT aux_nriniseq,
                               INPUT aux_cdcopatu,
                               INPUT aux_cdlcremp,
                               INPUT aux_dslcremp,
                               OUTPUT aux_qtregist,
                               OUTPUT TABLE tt-linhas-cred).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-linhas-cred:HANDLE,
                             INPUT "Linhas").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Listagem de Categorias 
******************************************************************************/
PROCEDURE lista-categorias:

    RUN lista-categorias IN hBO(INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT aux_nrregist,
                                INPUT aux_nriniseq,
                                INPUT aux_cddgrupo,
                                INPUT aux_cdsubgru,
                                INPUT aux_cdtipcat, 
                                INPUT aux_cdcatego,
                                INPUT aux_dscatego,
                                OUTPUT aux_qtregist,
                                OUTPUT TABLE tt-categorias).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-categorias:HANDLE,
                             INPUT "Categorias").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.



/******************************************************************************
 Listagem de TARIFAS
******************************************************************************/
PROCEDURE lista-tarifas:
    
    RUN lista-tarifas IN hBO(INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_nrregist,
                             INPUT aux_nriniseq,
                             INPUT aux_cdtarifa,
                             INPUT aux_dstarifa,
                             INPUT aux_cddgrupo,
                             INPUT aux_cdsubgru,
                             INPUT aux_cdcatego,
                             OUTPUT aux_qtregist,
                             OUTPUT TABLE tt-tarifas).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-tarifas:HANDLE,
                             INPUT "Tarifas").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************
 Verifica lancamentos na craplat
******************************************************************************/
PROCEDURE verifica-lanc-lat:

    RUN verifica-lanc-lat IN hBO(INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nmdatela,
                                 INPUT aux_idorigem,
                                 INPUT aux_cdhistor,
                                 OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************
 Listagem de Faixa de Valores
******************************************************************************/
PROCEDURE lista-fvl:

    RUN lista-fvl IN hBO(INPUT aux_cdcooper,
                         INPUT aux_cdagenci,
                         INPUT aux_nrdcaixa,
                         INPUT aux_cdoperad,
                         INPUT aux_nmdatela,
                         INPUT aux_idorigem,
                         INPUT aux_cdtarifa,
                         OUTPUT aux_qtregist,
                         OUTPUT TABLE tt-faixavalores).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-faixavalores:HANDLE,
                             INPUT "FaixaValores").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Busca de novo codigo craptar
******************************************************************************/
PROCEDURE busca-novo-cdtarifa:

    RUN busca-novo-cdtarifa IN hBO(INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nmdatela,
                                   INPUT aux_idorigem,
                                   OUTPUT aux_cdtarifa).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "cdtarifa",INPUT STRING(aux_cdtarifa)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Incluir cadtar
******************************************************************************/
PROCEDURE incluir-cadtar:

    RUN incluir-cadtar IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdtarifa,
                              INPUT aux_dstarifa,
                              INPUT aux_cdcatego,
                              INPUT aux_inpessoa,
                              INPUT aux_cdocorre,
                              INPUT aux_cdmotivo,
                              INPUT aux_cdinctar,
                              INPUT aux_flglaman,
                              INPUT aux_cdsubgru,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Alterar cadtar
******************************************************************************/
PROCEDURE alterar-cadtar:

    RUN alterar-cadtar IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdtarifa,
                              INPUT aux_dstarifa,
                              INPUT aux_cdcatego,
                              INPUT aux_inpessoa,
                              INPUT aux_cdocorre,
                              INPUT aux_cdmotivo,
                              INPUT aux_cdsubgru,
                              INPUT aux_cdinctar,
                              INPUT aux_flglaman,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Excluir cadtar
******************************************************************************/
PROCEDURE excluir-cadtar:
    
    RUN excluir-cadtar IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdtarifa,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
                     Buscar cadastro de tarifas
******************************************************************************/
PROCEDURE buscar-cadtar:

    RUN buscar-cadtar IN hBO(INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_cdtarifa,
                             OUTPUT aux_dstarifa,
                             OUTPUT aux_inpessoa,
                             OUTPUT aux_flglaman,
                             OUTPUT aux_flgpacta,
                             OUTPUT aux_cdocorre,
                             OUTPUT aux_cdmotivo,
                             OUTPUT aux_cddgrupo,
                             OUTPUT aux_dsdgrupo,
                             OUTPUT aux_cdsubgru,
                             OUTPUT aux_dssubgru,
                             OUTPUT aux_cdcatego,
                             OUTPUT aux_dscatego,
                             OUTPUT aux_cdinctar,
                             OUTPUT aux_cdtipcat,
                             OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "dstarifa",INPUT STRING(aux_dstarifa)).
            RUN piXmlAtributo (INPUT "inpessoa",INPUT STRING(aux_inpessoa)).
            RUN piXmlAtributo (INPUT "flglaman",INPUT STRING(aux_flglaman)).
            RUN piXmlAtributo (INPUT "flgpacta",INPUT STRING(aux_flgpacta)).
            RUN piXmlAtributo (INPUT "cdocorre",INPUT STRING(aux_cdocorre)).
            RUN piXmlAtributo (INPUT "cdmotivo",INPUT STRING(aux_cdmotivo)).
            RUN piXmlAtributo (INPUT "cddgrupo",INPUT STRING(aux_cddgrupo)).
            RUN piXmlAtributo (INPUT "dsdgrupo",INPUT STRING(aux_dsdgrupo)).
            RUN piXmlAtributo (INPUT "cdsubgru",INPUT STRING(aux_cdsubgru)).
            RUN piXmlAtributo (INPUT "dssubgru",INPUT STRING(aux_dssubgru)).
            RUN piXmlAtributo (INPUT "cdcatego",INPUT STRING(aux_cdcatego)).
            RUN piXmlAtributo (INPUT "dscatego",INPUT STRING(aux_dscatego)).
            RUN piXmlAtributo (INPUT "cdinctar",INPUT STRING(aux_cdinctar)).
            RUN piXmlAtributo (INPUT "cdtipcat",INPUT STRING(aux_cdtipcat)).
            RUN piXmlSave.
        END.

END PROCEDURE.


/*****************************************************************************/
/*                  TELA CADFVL                                              */
/*****************************************************************************/

/******************************************************************************
 Busca de novo codigo crapfvl
******************************************************************************/
PROCEDURE busca-novo-cdfaixav:

    RUN busca-novo-cdfaixav IN hBO(INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nmdatela,
                                   INPUT aux_idorigem,
                                   OUTPUT aux_cdfaixav).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "cdfaixav",INPUT STRING(aux_cdfaixav)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Incluir cadfvl
******************************************************************************/
PROCEDURE incluir-cadfvl:

    RUN incluir-cadfvl IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdfaixav,
                              INPUT aux_cdtarifa,
                              INPUT aux_vlinifvl,
                              INPUT aux_vlfinfvl,
                              INPUT aux_cdhistor,
                              INPUT aux_cdhisest,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Alterar cadfvl
******************************************************************************/
PROCEDURE alterar-cadfvl:

    RUN alterar-cadfvl IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdfaixav,
                              INPUT aux_cdtarifa,
                              INPUT aux_vlinifvl,
                              INPUT aux_vlfinfvl,
                              INPUT aux_cdhistor,
                              INPUT aux_cdhisest,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Excluir cadfvl
******************************************************************************/
PROCEDURE excluir-cadfvl:

    RUN excluir-cadfvl IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdfaixav,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Listagem de Historicos 
******************************************************************************/
PROCEDURE lista-historicos:

    IF aux_cdhistor = 0  AND
       aux_cdhisest > 0  THEN
       aux_cdhistor = aux_cdhisest.

    IF aux_dshistor  = '' AND
       aux_dshisest <> '' THEN
       aux_dshistor = aux_dshisest.

    IF aux_cdhistor = 0  AND
       aux_cdhiscop > 0  THEN
       aux_cdhistor = aux_cdhiscop.

    IF aux_dshistor  = '' AND
       aux_dshiscop <> '' THEN
       aux_dshistor = aux_dshiscop.

    IF aux_cdhistor = 0  AND
       aux_cdhiscnt > 0  THEN
       aux_cdhistor = aux_cdhiscnt.

    IF aux_dshistor  = '' AND
       aux_dshiscnt <> '' THEN
       aux_dshistor = aux_dshiscnt.

    RUN lista-historicos IN hBO(INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT aux_nrregist,
                                INPUT aux_nriniseq,
                                INPUT aux_cdhistor,
                                INPUT aux_dshistor,
                                OUTPUT aux_qtregist,
                                OUTPUT TABLE tt-historicos).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-historicos:HANDLE,
                             INPUT "Historico").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Listagem de Historicos que tem tarifas vinculadas 
******************************************************************************/
PROCEDURE lista-historicos-tarifa:

    IF aux_cdhistor = 0  AND
       aux_cdhisest > 0  THEN
       aux_cdhistor = aux_cdhisest.

    IF aux_dshistor  = '' AND
       aux_dshisest <> '' THEN
       aux_dshistor = aux_dshisest.

    RUN lista-historicos-tarifa IN hBO(INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdoperad,
                                       INPUT aux_nmdatela,
                                       INPUT aux_idorigem,
                                       INPUT aux_nrregist,
                                       INPUT aux_nriniseq,
                                       INPUT aux_cdhistor,
                                       INPUT aux_dshistor,
                                       OUTPUT aux_qtregist,
                                       OUTPUT TABLE tt-historicos).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-historicos:HANDLE,
                             INPUT "Historico").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Listagem de Historicos que tem tarifas vinculadas 
******************************************************************************/
PROCEDURE lista-historicos-estorno-tarifa:

    IF aux_cdhistor = 0  AND
       aux_cdhisest > 0  THEN
       aux_cdhistor = aux_cdhisest.

    IF aux_dshistor  = '' AND
       aux_dshisest <> '' THEN
       aux_dshistor = aux_dshisest.

    RUN lista-historicos-estorno-tarifa IN hBO(INPUT aux_cdcooper,
                                               INPUT aux_cdagenci,
                                               INPUT aux_nrdcaixa,
                                               INPUT aux_cdoperad,
                                               INPUT aux_nmdatela,
                                               INPUT aux_idorigem,
                                               INPUT aux_nrregist,
                                               INPUT aux_nriniseq,
                                               INPUT aux_cdhisest,
                                               INPUT aux_dshisest,
                                               OUTPUT aux_qtregist,
                                               OUTPUT TABLE tt-historicos).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-historicos:HANDLE,
                             INPUT "Historico").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Buscar subgrupo pelo historico
******************************************************************************/
PROCEDURE busca-subgrupo-historico:

    RUN busca-subgrupo-historico IN hBO(INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nmdatela,
                                        INPUT aux_idorigem,
                                        INPUT aux_cdhistor,
                                        OUTPUT aux_cdsubgru,
                                        OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "cdsubgru",INPUT STRING(aux_cdsubgru)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Buscar subgrupo pelo historico estorno
******************************************************************************/
PROCEDURE busca-subgrupo-historico-estorno:

    RUN busca-subgrupo-historico-estorno IN hBO(INPUT aux_cdcooper,
                                                INPUT aux_cdagenci,
                                                INPUT aux_nrdcaixa,
                                                INPUT aux_cdoperad,
                                                INPUT aux_nmdatela,
                                                INPUT aux_idorigem,
                                                INPUT aux_cdhisest,
                                                OUTPUT aux_cdsubgru,
                                                OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "cdsubgru",INPUT STRING(aux_cdsubgru)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Buscar craphis
******************************************************************************/
PROCEDURE busca-historico:

    RUN busca-historico IN hBO(INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nmdatela,
                               INPUT aux_idorigem,
                               INPUT aux_cdhistor,
                               OUTPUT aux_dshistor,
                               OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "dshistor",INPUT STRING(aux_dshistor)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Buscar craphis
******************************************************************************/
PROCEDURE busca-historico-tarifa:

    RUN busca-historico-tarifa IN hBO(INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nmdatela,
                                      INPUT aux_idorigem,
                                      INPUT aux_cdhistor,
                                      OUTPUT aux_dshistor,
                                      OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "dshistor",INPUT STRING(aux_dshistor)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Buscar craphis
******************************************************************************/
PROCEDURE busca-historico-estorno-tarifa:

    RUN busca-historico-estorno-tarifa IN hBO(INPUT aux_cdcooper,
                                              INPUT aux_cdagenci,
                                              INPUT aux_nrdcaixa,
                                              INPUT aux_cdoperad,
                                              INPUT aux_nmdatela,
                                              INPUT aux_idorigem,
                                              INPUT aux_cdhisest,
                                              OUTPUT aux_dshisest,
                                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "dshisest",INPUT STRING(aux_dshisest)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Buscar historico repetido
******************************************************************************/
PROCEDURE busca-historico-repetido:

    RUN busca-historico-repetido IN hBO(INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nmdatela,
                                        INPUT aux_idorigem,
                                        INPUT aux_cdhistor,
                                        OUTPUT aux_dshistor,
                                        OUTPUT aux_cdhisest,
                                        OUTPUT aux_dshisest,
                                        OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "dshistor",INPUT STRING(aux_dshistor)).
            RUN piXmlAtributo (INPUT "cdhisest",INPUT STRING(aux_cdhisest)).
            RUN piXmlAtributo (INPUT "dshisest",INPUT STRING(aux_dshisest)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/*****************************************************************************/
/*                  TELA CADFVL                                              */
/*****************************************************************************/

/******************************************************************************
 Busca associado
******************************************************************************/
PROCEDURE busca-associado:

    RUN busca-associado IN hBO(INPUT aux_cdcooper,
                               INPUT aux_nrdconta,
                               OUTPUT aux_cdagenci,
                               OUTPUT aux_nrmatric,
                               OUTPUT aux_cdtipcta,
                               OUTPUT aux_dstipcta,
                               OUTPUT aux_nmprimtl,
                               OUTPUT aux_inpessoa,
                               OUTPUT aux_nmresage,
                               OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "cdagenci",INPUT STRING(aux_cdagenci)).
            RUN piXmlAtributo (INPUT "nrmatric",INPUT STRING(aux_nrmatric)).
            RUN piXmlAtributo (INPUT "cdtipcta",INPUT STRING(aux_cdtipcta)).
            RUN piXmlAtributo (INPUT "dstipcta",INPUT STRING(aux_dstipcta)).
            RUN piXmlAtributo (INPUT "nmprimtl",INPUT STRING(aux_nmprimtl)).
            RUN piXmlAtributo (INPUT "inpessoa",INPUT STRING(aux_inpessoa)).
            RUN piXmlAtributo (INPUT "nmresage",INPUT STRING(aux_nmresage)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Listagem de Tarifas pelo tipo de pessoa (inpessoa)
******************************************************************************/
PROCEDURE lista-tarifa-pessoa:

    RUN lista-tarifa-pessoa IN hBO(INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nmdatela,
                                   INPUT aux_idorigem,
                                   INPUT aux_inpessoa,
                                   OUTPUT aux_qtregist,
                                   OUTPUT TABLE tt-tarifas).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-tarifas:HANDLE,
                             INPUT "Tarifas").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/*****************************************************************************/
/*                  TELA CADMET                                              */
/*****************************************************************************/

/******************************************************************************
 Listagem de Motivos de Estorno/Baixa Tarifa
******************************************************************************/
PROCEDURE lista-met:

    RUN lista-met IN hBO(INPUT aux_cdcooper,
                         INPUT aux_cdagenci,
                         INPUT aux_nrdcaixa,
                         INPUT aux_cdoperad,
                         INPUT aux_nmdatela,
                         INPUT aux_idorigem,
                         INPUT aux_nrregist,
                         INPUT aux_nriniseq,
                         INPUT aux_cdmotest,
                         OUTPUT aux_qtregist,
                         OUTPUT TABLE tt-met).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-met:HANDLE,
                             INPUT "MotivoEstorno").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************
 Incluir cadmet
******************************************************************************/
PROCEDURE incluir-cadmet:

    RUN incluir-cadmet IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdmotest,
                              INPUT aux_dsmotest,
                              INPUT aux_tpaplica,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Alterar cadmet
******************************************************************************/
PROCEDURE alterar-cadmet:

    RUN alterar-cadmet IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdmotest,
                              INPUT aux_dsmotest,
                              INPUT aux_tpaplica,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Excluir cadmet
******************************************************************************/
PROCEDURE excluir-cadmet:

    RUN excluir-cadmet IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdmotest,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Buscar cadmet
******************************************************************************/
PROCEDURE buscar-cadmet:

    RUN buscar-cadmet IN hBO(INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_cdmotest,
                             OUTPUT aux_dsmotest,
                             OUTPUT aux_tpaplica,
                             OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "dsmotest",INPUT STRING(aux_dsmotest)).
            RUN piXmlAtributo (INPUT "tpaplica",INPUT STRING(aux_tpaplica)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Busca de novo codigo crapmet
******************************************************************************/
PROCEDURE busca-novo-cdmotest:

    RUN busca-novo-cdmotest IN hBO(INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nmdatela,
                                   INPUT aux_idorigem,
                                   OUTPUT aux_cdmotest).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "cdmotest",INPUT STRING(aux_cdmotest)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 TELA RELTAR
******************************************************************************/

/******************************************************************************
 Busca associado reltar
******************************************************************************/
PROCEDURE busca-associado-reltar:

    RUN busca-associado-reltar IN hBO(INPUT aux_cdcooper,
                                       INPUT aux_nrdconta,
                                       INPUT aux_ccooptel,
                                       INPUT aux_cdagetel,
                                       OUTPUT aux_cdagenci,
                                       OUTPUT aux_nrmatric,
                                       OUTPUT aux_cdtipcta,
                                       OUTPUT aux_dstipcta,
                                       OUTPUT aux_nmprimtl,
                                       OUTPUT aux_inpessoa,
                                       OUTPUT aux_nmresage,
                                       OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "cdagenci",INPUT STRING(aux_cdagenci)).
            RUN piXmlAtributo (INPUT "nrmatric",INPUT STRING(aux_nrmatric)).
            RUN piXmlAtributo (INPUT "cdtipcta",INPUT STRING(aux_cdtipcta)).
            RUN piXmlAtributo (INPUT "dstipcta",INPUT STRING(aux_dstipcta)).
            RUN piXmlAtributo (INPUT "nmprimtl",INPUT STRING(aux_nmprimtl)).
            RUN piXmlAtributo (INPUT "inpessoa",INPUT STRING(aux_inpessoa)).
            RUN piXmlAtributo (INPUT "nmresage",INPUT STRING(aux_nmresage)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Busca Descricao PA
******************************************************************************/
PROCEDURE buscar-pac:

    RUN buscar-pac IN hBO(INPUT aux_cdcooper,
                          INPUT aux_cdagenci,
                          INPUT aux_nrdcaixa,
                          INPUT aux_cdoperad,
                          INPUT aux_nmdatela,
                          INPUT aux_idorigem,
                          OUTPUT aux_nmresage,
                          OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmresage",INPUT STRING(aux_nmresage)).
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************
 Busca Descricao PA RELTAR
******************************************************************************/
PROCEDURE buscar-pac-reltar:

    RUN buscar-pac-reltar IN hBO(INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nmdatela,
                                 INPUT aux_idorigem,
                                 INPUT aux_ccooptel,
                                 INPUT aux_cdagetel,
                                 OUTPUT aux_nmresage,
                                 OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmresage",INPUT STRING(aux_nmresage)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Listagem de PAs
******************************************************************************/
PROCEDURE lista-pacs:

    RUN lista-pacs IN hBO(INPUT aux_cdcooper,
                          INPUT aux_cdagenci,
                          INPUT aux_nrdcaixa,
                          INPUT aux_cdoperad,
                          INPUT aux_nmdatela,
                          INPUT aux_idorigem,
                          OUTPUT aux_qtregist,
                          OUTPUT TABLE tt-agenci).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-agenci:HANDLE,
                             INPUT "PA").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************
 Busca de novo codigo crappat
******************************************************************************/
PROCEDURE busca-novo-cdpartar:

    RUN busca-novo-cdpartar IN hBO(INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nmdatela,
                                   INPUT aux_idorigem,
                                   OUTPUT aux_cdpartar).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "cdpartar",INPUT STRING(aux_cdpartar)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Listagem de parametros 
******************************************************************************/
PROCEDURE lista-parametros:

    RUN lista-parametros IN hBO(INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT aux_nrregist,
                                INPUT aux_nriniseq,
                                INPUT aux_cdpartar,
                                INPUT aux_nmpartar,
                                OUTPUT aux_qtregist,
                                OUTPUT TABLE tt-partar).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-partar:HANDLE,
                             INPUT "Parametros").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************
 Incluir cadpar
******************************************************************************/
PROCEDURE incluir-cadpar:

    RUN incluir-cadpar IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdpartar,
                              INPUT aux_nmpartar,
                              INPUT aux_tpdedado,
                              INPUT aux_cdprodut,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Alterar cadpar
******************************************************************************/
PROCEDURE alterar-cadpar:

    RUN alterar-cadpar IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdpartar,
                              INPUT aux_nmpartar,
                              INPUT aux_tpdedado,
                              INPUT aux_cdprodut,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Excluir cadpar
******************************************************************************/
PROCEDURE excluir-cadpar:

    RUN excluir-cadpar IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdpartar,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Buscar cadpar
******************************************************************************/
PROCEDURE buscar-cadpar:

    RUN buscar-cadpar IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdpartar,
                              OUTPUT aux_nmpartar,
                              OUTPUT aux_tpdedado,
                              OUTPUT aux_cdprodut,
                              OUTPUT aux_dsprodut,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmpartar",INPUT STRING(aux_nmpartar)).
            RUN piXmlAtributo (INPUT "tpdedado",INPUT STRING(aux_tpdedado)).
            RUN piXmlAtributo (INPUT "cdprodut",INPUT STRING(aux_cdprodut)).
            RUN piXmlAtributo (INPUT "dsprodut",INPUT STRING(aux_dsprodut)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/*****************************************************************************/
/*                        TELA CADPCO                                        */
/*****************************************************************************/

/******************************************************************************
 Incluir cadpco
******************************************************************************/
PROCEDURE incluir-cadpco:

    RUN incluir-cadpco IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdcopatu,
                              INPUT aux_cdpartar,
                              INPUT aux_dsconteu,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Alterar cadpco
******************************************************************************/
PROCEDURE alterar-cadpco:

    RUN alterar-cadpco IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdcopatu,
                              INPUT aux_cdpartar,
                              INPUT aux_dsconteu,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Excluir cadpco
******************************************************************************/
PROCEDURE excluir-cadpco:

    RUN excluir-cadpco IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdcopatu,
                              INPUT aux_cdpartar,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Replicar cadpco
******************************************************************************/
PROCEDURE replicar-cadpco:

    RUN replicar-cadpco IN hBO(INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nmdatela,
                               INPUT aux_idorigem,
                               INPUT aux_cdpartar,
                               INPUT aux_lstcdcop,
                               INPUT aux_lstdscon,
                               OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Buscar cadpco
******************************************************************************/
PROCEDURE buscar-cadpco:

    RUN buscar-cadpco IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdpartar,
                              OUTPUT aux_dsconteu,
                              OUTPUT aux_cdcooper,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "dsconteu",INPUT STRING(aux_dsconteu)).
            RUN piXmlAtributo (INPUT "cdcooper",INPUT STRING(aux_cdcooper)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Validar cadpco
******************************************************************************/
PROCEDURE validar-cadpco:

    RUN validar-cadpco IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdpartar,
                              INPUT aux_cdcopatu,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************
 Listagem de cooperativas
******************************************************************************/
PROCEDURE lista-cooperativas:

    RUN lista-cooperativas IN hBO(INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_nrregist,
                                  INPUT aux_nriniseq,
                                  INPUT aux_nmrescop,
                                  INPUT aux_cdcopaux,
                                  OUTPUT aux_qtregist,
                                  OUTPUT TABLE tt-cooper).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-cooper:HANDLE,
                             INPUT "Cooperativa").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Buscar cooperativa
******************************************************************************/
PROCEDURE buscar-cooperativa:

    RUN buscar-cooperativa IN hBO(INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_cdcopatu,
                                  OUTPUT aux_nmrescop,
                                  OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmrescop",INPUT STRING(aux_nmrescop)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Listagem de cooperativas para replicacao
******************************************************************************/
PROCEDURE replica-cooperativas:
    
    RUN replica-cooperativas IN hBO(INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_nmdatela,
                                    INPUT aux_idorigem,
                                    INPUT aux_cdcopatu,
                                    INPUT aux_cdpartar,
                                    OUTPUT aux_qtregist,
                                    OUTPUT TABLE tt-cooper).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-cooper:HANDLE,
                             INPUT "Cooperativa").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 carrega a tabela com os parametros por cooperativa
******************************************************************************/
PROCEDURE carrega-tabcadpar:
    
    RUN carrega-tabcadpar IN hBO(INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nmdatela,
                                 INPUT aux_idorigem,
                                 INPUT aux_cdpartar,
                                 INPUT aux_cdprodut,
                                 OUTPUT aux_qtregist,
                                 OUTPUT TABLE tt-parametros).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-parametros:HANDLE,
                             INPUT "Parametros").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.
        
END PROCEDURE.

/******************************************************************************
 vincula parametros para uma tarifa
******************************************************************************/
PROCEDURE vincula-parametro-tarifa:

    RUN vincula-parametro-tarifa IN hBO(INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nmdatela,
                                        INPUT aux_idorigem,
                                        INPUT aux_cdtarifa,
                                        INPUT aux_cdpartar,
                                        OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 desvincula parametros para uma tarifa
******************************************************************************/
PROCEDURE desvincula-parametro-tarifa:

    RUN desvincula-parametro-tarifa IN hBO(INPUT aux_cdcooper,
                                           INPUT aux_cdagenci,
                                           INPUT aux_nrdcaixa,
                                           INPUT aux_cdoperad,
                                           INPUT aux_nmdatela,
                                           INPUT aux_idorigem,
                                           INPUT aux_cdtarifa,
                                           INPUT aux_cdpartar,
                                           OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Listagem de crappat 
******************************************************************************/
PROCEDURE lista-pat:

    RUN lista-pat IN hBO(INPUT aux_cdcooper,
                         INPUT aux_cdagenci,
                         INPUT aux_nrdcaixa,
                         INPUT aux_cdoperad,
                         INPUT aux_nmdatela,
                         INPUT aux_idorigem,
                         INPUT aux_cdtarifa,
                         OUTPUT aux_qtregist,
                         OUTPUT TABLE tt-partar).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-partar:HANDLE,
                             INPUT "Parametros").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************
                                TELA CADFCO
******************************************************************************/

/******************************************************************************
 Busca de novo codigo crapfco
******************************************************************************/
PROCEDURE busca-novo-cdfvlcop:

    RUN busca-novo-cdfvlcop IN hBO(INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nmdatela,
                                   INPUT aux_idorigem,
                                   OUTPUT aux_cdfvlcop).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "cdfvlcop",INPUT STRING(aux_cdfvlcop)).
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************
 Incluir cadfco
******************************************************************************/
PROCEDURE incluir-cadfco:

    RUN incluir-cadfco IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdfvlcop,
                              INPUT aux_cdcopatu,
                              INPUT aux_cdfaixav,
                              INPUT aux_flgvigen, 
                              INPUT aux_vltarifa, 
                              INPUT aux_vlrepass, 
                              INPUT aux_dtdivulg, 
                              INPUT aux_dtvigenc, 
                              INPUT aux_flgnegat,
                              INPUT aux_nrconven,
                              INPUT aux_cdocorre,
                              INPUT aux_cdlcremp,
                              INPUT aux_cdinctar,
							  INPUT aux_tpcobtar,
                              INPUT aux_vlpertar,
                              INPUT aux_vlmintar,
                              INPUT aux_vlmaxtar,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Alterar cadfco
******************************************************************************/
PROCEDURE alterar-cadfco:

    RUN alterar-cadfco IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdfvlcop,
                              INPUT aux_cdcopatu,
                              INPUT aux_cdfaixav,
                              INPUT aux_flgvigen,
                              INPUT aux_vltarifa,
                              INPUT aux_vlrepass,
                              INPUT aux_dtdivulg,
                              INPUT aux_dtvigenc,
                              INPUT aux_flgnegat,
                              INPUT aux_nrconven,
                              INPUT aux_cdocorre,
                              INPUT aux_cdlcremp,
                              INPUT aux_cdinctar,
							  INPUT aux_tpcobtar,
                              INPUT aux_vlpertar,
                              INPUT aux_vlmintar,
                              INPUT aux_vlmaxtar,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Excluir cadgru
******************************************************************************/
PROCEDURE excluir-cadfco:

    RUN excluir-cadfco IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdfvlcop,
                              INPUT aux_cdcopatu,
                              INPUT aux_cdfaixav,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Buscar convenio
******************************************************************************/
PROCEDURE buscar-convenio:

    RUN buscar-convenio IN hBO(INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nmdatela,
                               INPUT aux_idorigem,
                               INPUT aux_cdcopatu,
                               INPUT aux_nrconven,
                               INPUT aux_cdocorre,
                               INPUT aux_cdinctar,
                               OUTPUT aux_dsconven,
                               OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "dsconven",INPUT STRING(aux_dsconven)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Buscar Linha Credito
******************************************************************************/
PROCEDURE buscar-linha-credito:

    RUN buscar-linha-credito IN hBO(INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nmdatela,
                               INPUT aux_idorigem,
                               INPUT aux_cdcopatu,
                               INPUT aux_cdlcremp,
                               OUTPUT aux_dslcremp,
                               OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "dslcremp",INPUT STRING(aux_dslcremp)).
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************
 Buscar cadfco
******************************************************************************/
PROCEDURE buscar-cadfco:

    RUN buscar-cadfco IN hBO(INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_cdcopatu,
                             INPUT aux_cdfaixav,
                             OUTPUT aux_cdfvlcop,
                             OUTPUT aux_flgvigen, 
                             OUTPUT aux_vltarifa, 
                             OUTPUT aux_vlrepass, 
                             OUTPUT aux_dtdivulg, 
                             OUTPUT aux_dtvigenc, 
                             OUTPUT aux_flgnegat,
                             OUTPUT aux_nrconven,
							 OUTPUT aux_tpcobtar,
                             OUTPUT aux_vlpertar,
                             OUTPUT aux_vlmintar,
                             OUTPUT aux_vlmaxtar,
                             OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "flgvigen",INPUT STRING(aux_flgvigen)).
            RUN piXmlAtributo (INPUT "vltarifa",INPUT STRING(aux_dsdgrupo)).
            RUN piXmlAtributo (INPUT "vlrepass",INPUT STRING(aux_vlrepass)).
            RUN piXmlAtributo (INPUT "dtdivulg",INPUT STRING(aux_dtdivulg)).
            RUN piXmlAtributo (INPUT "dtvigenc",INPUT STRING(aux_dtvigenc)).
            RUN piXmlAtributo (INPUT "flgnegat",INPUT STRING(aux_flgnegat)).
			RUN piXmlAtributo (INPUT "tpcobtar",INPUT STRING(aux_flgnegat)).
			RUN piXmlAtributo (INPUT "vlpertar",INPUT STRING(aux_flgnegat)).
			RUN piXmlAtributo (INPUT "vlmintar",INPUT STRING(aux_flgnegat)).
			RUN piXmlAtributo (INPUT "vlmaxtar",INPUT STRING(aux_flgnegat)).
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************
 Listagem de Atribuicao Detalhamento
******************************************************************************/
PROCEDURE carrega-atribuicao-detalhamento:

    RUN carrega-atribuicao-detalhamento IN hBO(INPUT aux_cdcooper,
                                               INPUT aux_cdagenci,
                                               INPUT aux_nrdcaixa,
                                               INPUT aux_cdoperad,
                                               INPUT aux_nmdatela,
                                               INPUT aux_idorigem,
                                               INPUT aux_cdfaixav,
                                               INPUT aux_flgtodos,
                                               INPUT aux_cdtipcat,
                                               INPUT aux_nrregist,
                                               INPUT aux_nriniseq,                                               
                                               OUTPUT aux_qtregist,
                                               OUTPUT TABLE tt-atribdet).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-atribdet:HANDLE,
                             INPUT "Detalhamentos").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Listagem de cooperativas para replicacao
******************************************************************************/
PROCEDURE replica-cooperativas-det:
    
    RUN replica-cooperativas-det IN hBO(INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nmdatela,
                                        INPUT aux_idorigem,
                                        INPUT aux_cdcopatu,
                                        INPUT aux_cdfaixav,
                                        INPUT aux_cdlcratu,
                                        INPUT aux_cdtipcat,
                                        OUTPUT aux_qtregist,
                                        OUTPUT TABLE tt-cooper).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-cooper:HANDLE,
                             INPUT "Cooperativa").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Listagem de cooperativas para replicacao
******************************************************************************/
PROCEDURE replica-cooperativas-det-cob:
    
    RUN replica-cooperativas-det-cob IN hBO(INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_cdoperad,
                                            INPUT aux_nmdatela,
                                            INPUT aux_idorigem,
                                            INPUT aux_cdcopatu,
                                            INPUT aux_cdfaixav,
                                            INPUT aux_nrcnvatu,
                                            INPUT aux_cdocorre,
                                            INPUT aux_cdinctar,
                                            OUTPUT aux_qtregist,
                                            OUTPUT TABLE tt-cooper).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-cooper:HANDLE,
                             INPUT "Cooperativa").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Replicar cadfco
******************************************************************************/
PROCEDURE replicar-cadfco:
    
    RUN replicar-cadfco IN hBO(INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nmdatela,
                               INPUT aux_idorigem,
                               INPUT aux_cdfaixav,
                               INPUT aux_lstcdcop,
                               INPUT aux_lstdtdiv,
                               INPUT aux_lstdtvig,
                               INPUT aux_lstvlrep,
                               INPUT aux_lstvltar,
                               INPUT FALSE, /*flgvigen*/
                               INPUT FALSE, /*flgnegat*/
                               INPUT aux_lstconve,
                               INPUT aux_cdocorre,
                               INPUT aux_cdlcremp,
                               INPUT aux_lstlcrem,
                               INPUT aux_cdinctar,
							   INPUT aux_lsttptar,
                               INPUT aux_lstvlper,
                               INPUT aux_lstvlmin,
                               INPUT aux_lstvlmax,

                               OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Incluir cadfco
******************************************************************************/
PROCEDURE valida-replicacao:

    RUN valida-replicacao IN hBO(INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nmdatela,
                                 INPUT aux_idorigem,
                                 INPUT aux_cdfaixav,
                                 INPUT aux_lstcdcop,
                                 INPUT aux_lstdtdiv,
                                 INPUT aux_lstdtvig,
                                 INPUT aux_lstvlrep,
                                 INPUT aux_lstvltar,
                                 INPUT aux_flgvigen,
                                 INPUT aux_flgnegat,
                                 OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE valida-replicacao-cob:

    RUN valida-replicacao-cob IN hBO(INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nmdatela,
                                     INPUT aux_idorigem,
                                     INPUT aux_cdfaixav,
                                     INPUT aux_lstcdcop,
                                     INPUT aux_lstdtdiv,
                                     INPUT aux_lstdtvig,
                                     INPUT aux_lstvlrep,
                                     INPUT aux_lstvltar,
                                     INPUT aux_flgvigen,
                                     INPUT aux_flgnegat,
                                     INPUT aux_lstconve,
                                     OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************
 Carrega a tabela pesquisa associados
******************************************************************************/
PROCEDURE carrega-tabassociado:

    RUN carrega-tabassociado IN hBO(INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nmdatela,
                                 INPUT aux_idorigem,
                                 INPUT aux_cdpartar,
                                 INPUT aux_cagencia,
                                 INPUT aux_cdtipcta,
                                 INPUT aux_inpessoa,
                                 INPUT aux_nmprimtl,
                                 INPUT aux_flgchcus,
                                 INPUT aux_mespsqch,
                                 INPUT aux_anopsqch,
                                 INPUT aux_nrregist,
                                 INPUT aux_nriniseq,
                                 OUTPUT aux_qtregist,
                                 OUTPUT TABLE tt-associados).


    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN 
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-associados:HANDLE,
                             INPUT "Associados").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.
        
END PROCEDURE.


/******************************************************************************
 Lista os associados 
******************************************************************************/
PROCEDURE lista-associado:

    RUN lista-associado IN hBO(INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nmdatela,
                               INPUT aux_idorigem,
                               INPUT aux_lstconta,
                               OUTPUT TABLE tt-associados).


    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN 
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-associados:HANDLE,
                             INPUT "Associados").
            RUN piXmlSave.
        END.
        
END PROCEDURE.

/******************************************************************************
 Lancamento manul de tarifas
******************************************************************************/
PROCEDURE lancamento-manual-tarifa:

    RUN lancamento-manual-tarifa IN hBO( INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_nmdatela,
                                        INPUT aux_idorigem,
                                        INPUT aux_inproces,
                                        INPUT aux_lstconta,
                                        INPUT aux_lsthisto,
                                        INPUT aux_lstqtdla,
                                        INPUT aux_lsvlrtar,
                                        INPUT aux_lsqtdchq,
                                        INPUT aux_lsfvlcop,
                                        INPUT aux_inpessoa,
                                        INPUT aux_flgerlog,
                                        OUTPUT TABLE tt-erro).


  

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************
 Estorno/Baixa de lancamento de tarifas
******************************************************************************/
PROCEDURE estorno-baixa-tarifa:

    RUN estorno-baixa-tarifa IN hBO(INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_nmdatela,
                                        INPUT aux_idorigem,
                                        INPUT aux_inproces,
                                        INPUT aux_nrdconta,
                                        INPUT aux_cddopcap,
                                        INPUT aux_lscdlant,
                                        INPUT aux_lscdmote,
                                        INPUT aux_flgerlog,
                                        OUTPUT TABLE tt-erro).


    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************
                     Tela CADBAT
******************************************************************************/

/******************************************************************************
 Listagem de CADBAT 
******************************************************************************/
PROCEDURE lista-cadbat:

    RUN lista-cadbat IN hBO(INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrregist,
                            INPUT aux_nriniseq,
                            INPUT aux_cdbattar,
                            INPUT aux_nmidenti,
                            OUTPUT aux_qtregist,
                            OUTPUT TABLE tt-battar).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-battar:HANDLE,
                             INPUT "Battar").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Buscar cadbat
******************************************************************************/
PROCEDURE buscar-cadbat:

    RUN buscar-cadbat IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdbattar,
                              OUTPUT aux_nmidenti,
                              OUTPUT aux_cdprogra,
                              OUTPUT aux_tpcadast,
                              OUTPUT aux_cdcadast,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmidenti",INPUT STRING(aux_nmidenti)).
            RUN piXmlAtributo (INPUT "cdprogra",INPUT STRING(aux_cdprogra)).
            RUN piXmlAtributo (INPUT "tpcadast",INPUT STRING(aux_tpcadast)).
            RUN piXmlAtributo (INPUT "cdcadast",INPUT STRING(aux_cdcadast)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Incluir cadbat
******************************************************************************/
PROCEDURE incluir-cadbat:

    /*tipo 1 = tarifa*/
    IF  aux_tpcadast = 1 THEN
        ASSIGN aux_cdcadast = aux_cdtarifa.
    ELSE    /*tipo 2 = parametro*/
        IF  aux_tpcadast = 2 THEN
            ASSIGN aux_cdcadast = aux_cdpartar.

    RUN incluir-cadbat IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdbattar,
                              INPUT aux_nmidenti,
                              INPUT aux_tpcadast,
                              INPUT aux_cdcadast,
                              INPUT aux_cdprogra,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Alterar cadbat
******************************************************************************/
PROCEDURE alterar-cadbat:

    RUN alterar-cadbat IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdbattar,
                              INPUT aux_nmidenti,
                              INPUT aux_cdprogra,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Vincular cadbat
******************************************************************************/
PROCEDURE vincular-cadbat:

    /*tipo 1 = tarifa*/
    IF  aux_tpcadast = 1 THEN
        ASSIGN aux_cdcadast = aux_cdtarifa.
    ELSE    /*tipo 2 = parametro*/
        IF  aux_tpcadast = 2 THEN
            ASSIGN aux_cdcadast = aux_cdpartar.

    RUN vincular-cadbat IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_cdbattar,
                              INPUT aux_cdcadast,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************
Listagem de Tarifas para Baixa/Estorno
******************************************************************************/
PROCEDURE lista_tarifas_estorno:

    RUN lista_tarifas_estorno IN hBO(INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nmdatela,
                                     INPUT aux_idorigem,
                                     INPUT aux_nrdconta,
                                     INPUT aux_cddopcap,
                                     INPUT aux_dtinicio,
                                     INPUT aux_dtafinal,
                                     INPUT aux_cdhistor,
                                     OUTPUT aux_qtregist,
                                     OUTPUT aux_vlrtotal,
                                     OUTPUT TABLE tt-estorno).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-estorno:HANDLE,
                             INPUT "Estorno").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlAtributo (INPUT "vlrtotal",INPUT STRING(aux_vlrtotal)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Busca qtd dias estorno
******************************************************************************/
PROCEDURE busca-qtd-dias-estorno:

    RUN busca-qtd-dias-estorno IN hBO(INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nmdatela,
                                     INPUT aux_idorigem,
                                     INPUT aux_dtmvtolt,
                                     INPUT aux_cdbattar,
                                     OUTPUT aux_dsconteu,
                                     OUTPUT aux_dtlimest,
                                     OUTPUT TABLE tt-erro).

       IF   RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                 
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
   ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "dsconteu",INPUT STRING(aux_dsconteu)).
            RUN piXmlAtributo (INPUT "dtlimest",INPUT STRING(aux_dtlimest,"99/99/9999")).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
Relatorio Receita Tarifa
******************************************************************************/
PROCEDURE rel-receita-tarifa:
    
    RUN rel-receita-tarifa IN hBO(INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_tprelato,
                                  INPUT aux_cdhistor,
                                  INPUT aux_cdhisest,
                                  INPUT aux_cdcoptel,
                                  INPUT aux_cdagetel,
                                  INPUT aux_inpessoa,
                                  INPUT aux_nrdconta,
                                  INPUT aux_dtinicio,
                                  INPUT aux_dtafinal,
                                  INPUT aux_nmendter,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_cddgrupo,
                                  INPUT aux_cdsubgru,
                                  OUTPUT TABLE tt-erro,
                                  OUTPUT aux_nmarqimp,
                                  OUTPUT aux_nmarqpdf).

    IF   RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                 
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT aux_nmarqpdf).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
Relatorio Receita Tarifa resumido
******************************************************************************/
PROCEDURE rel-receita-tarifa-resumido:
    
    RUN rel-receita-tarifa-resumido IN hBO( INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_cdoperad,
                                            INPUT aux_nmdatela,
                                            INPUT aux_idorigem,
                                            INPUT aux_tprelato,
                                            INPUT aux_cdhistor,
                                            INPUT aux_cdhisest,
                                            INPUT aux_cdcoptel,
                                            INPUT aux_cdagetel,
                                            INPUT aux_inpessoa,
                                            INPUT aux_nrdconta,
                                            INPUT aux_dtinicio,
                                            INPUT aux_dtafinal,
                                            INPUT aux_nmendter,
                                            INPUT aux_dtmvtolt,
                                            INPUT aux_cddgrupo,
                                            INPUT aux_cdsubgru,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT aux_nmarqimp,
                                            OUTPUT aux_nmarqpdf).

    IF   RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                 
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT aux_nmarqpdf).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
Relatorio Estorno Tarifa
******************************************************************************/
PROCEDURE rel-estorno-tarifa:

    RUN rel-estorno-tarifa IN hBO(INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_tprelato,
                                  INPUT aux_cdhistor,
                                  INPUT aux_cdhisest,
                                  INPUT aux_cdcoptel,
                                  INPUT aux_cdagetel,
                                  INPUT aux_inpessoa,
                                  INPUT aux_nrdconta,
                                  INPUT aux_dtinicio,
                                  INPUT aux_dtafinal,
                                  INPUT aux_nmendter,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_cddgrupo,
                                  INPUT aux_cdsubgru,
                                  OUTPUT TABLE tt-erro,
                                  OUTPUT aux_nmarqimp,
                                  OUTPUT aux_nmarqpdf).

       IF   RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                 
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
   ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT aux_nmarqpdf).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
Relatorio Estorno Tarifa resumido
******************************************************************************/
PROCEDURE rel-estorno-tarifa-resumido:

    RUN rel-estorno-tarifa-resumido IN hBO( INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_cdoperad,
                                            INPUT aux_nmdatela,
                                            INPUT aux_idorigem,
                                            INPUT aux_tprelato,
                                            INPUT aux_cdhistor,
                                            INPUT aux_cdhisest,
                                            INPUT aux_cdcoptel,
                                            INPUT aux_cdagetel,
                                            INPUT aux_inpessoa,
                                            INPUT aux_nrdconta,
                                            INPUT aux_dtinicio,
                                            INPUT aux_dtafinal,
                                            INPUT aux_nmendter,
                                            INPUT aux_dtmvtolt,
                                            INPUT aux_cddgrupo,
                                            INPUT aux_cdsubgru,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT aux_nmarqimp,
                                            OUTPUT aux_nmarqpdf).

       IF   RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                 
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
   ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT aux_nmarqpdf).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
Relatorio Tarifa Baixada
******************************************************************************/
PROCEDURE rel-tarifa-baixada:

    RUN rel-tarifa-baixada IN hBO(INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_tprelato,
                                  INPUT aux_cdhistor,
                                  INPUT aux_cdhisest,
                                  INPUT aux_cdcoptel,
                                  INPUT aux_cdagetel,
                                  INPUT aux_inpessoa,
                                  INPUT aux_nrdconta,
                                  INPUT aux_dtinicio,
                                  INPUT aux_dtafinal,
                                  INPUT aux_nmendter,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_cddgrupo,
                                  INPUT aux_cdsubgru,
                                  OUTPUT TABLE tt-erro,
                                  OUTPUT aux_nmarqimp,
                                  OUTPUT aux_nmarqpdf).

       IF   RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                 
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
   ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT aux_nmarqpdf).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
Relatorio Tarifa Baixada Resumido
******************************************************************************/
PROCEDURE rel-tarifa-baixada-resumido:

    RUN rel-tarifa-baixada-resumido IN hBO( INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_cdoperad,
                                            INPUT aux_nmdatela,
                                            INPUT aux_idorigem,
                                            INPUT aux_tprelato,
                                            INPUT aux_cdhistor,
                                            INPUT aux_cdhisest,
                                            INPUT aux_cdcoptel,
                                            INPUT aux_cdagetel,
                                            INPUT aux_inpessoa,
                                            INPUT aux_nrdconta,
                                            INPUT aux_dtinicio,
                                            INPUT aux_dtafinal,
                                            INPUT aux_nmendter,
                                            INPUT aux_dtmvtolt,
                                            INPUT aux_cddgrupo,
                                            INPUT aux_cdsubgru,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT aux_nmarqimp,
                                            OUTPUT aux_nmarqpdf).

       IF   RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                 
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
   ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT aux_nmarqpdf).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
Relatorio Tarifa Pendente
******************************************************************************/
PROCEDURE rel-tarifa-pendente:

    RUN rel-tarifa-pendente IN hBO(INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_tprelato,
                                  INPUT aux_cdhistor,
                                  INPUT aux_cdhisest,
                                  INPUT aux_cdcoptel,
                                  INPUT aux_cdagetel,
                                  INPUT aux_inpessoa,
                                  INPUT aux_nrdconta,
                                  INPUT aux_dtinicio,
                                  INPUT aux_dtafinal,
                                  INPUT aux_nmendter,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_cddgrupo,
                                  INPUT aux_cdsubgru,
                                  OUTPUT TABLE tt-erro,
                                  OUTPUT aux_nmarqimp,
                                  OUTPUT aux_nmarqpdf).

   IF   RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                 
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
   ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT aux_nmarqpdf).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
Relatorio Tarifa Pendente
******************************************************************************/
PROCEDURE rel-tarifa-pendente-resumido:

    RUN rel-tarifa-pendente-resumido IN hBO(INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_cdoperad,
                                            INPUT aux_nmdatela,
                                            INPUT aux_idorigem,
                                            INPUT aux_tprelato,
                                            INPUT aux_cdhistor,
                                            INPUT aux_cdhisest,
                                            INPUT aux_cdcoptel,
                                            INPUT aux_cdagetel,
                                            INPUT aux_inpessoa,
                                            INPUT aux_nrdconta,
                                            INPUT aux_dtinicio,
                                            INPUT aux_dtafinal,       
                                            INPUT aux_nmendter,
                                            INPUT aux_dtmvtolt,
                                            INPUT aux_cddgrupo,
                                            INPUT aux_cdsubgru,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT aux_nmarqimp,
                                            OUTPUT aux_nmarqpdf).

   IF   RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                 
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
   ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT aux_nmarqpdf).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
Relatorio Estouro CC
******************************************************************************/
PROCEDURE rel-estouro-cc:

    RUN rel-estouro-cc IN hBO(INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_tprelato,
                                  INPUT aux_cdhistor,
                                  INPUT aux_cdhisest,
                                  INPUT aux_cdcoptel,
                                  INPUT aux_cdagetel,
                                  INPUT aux_inpessoa,
                                  INPUT aux_nrdconta,
                                  INPUT aux_dtinicio,
                                  INPUT aux_dtafinal,
                                  INPUT aux_nmendter,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_cddgrupo,
                                  INPUT aux_cdsubgru,
                                  OUTPUT TABLE tt-erro,
                                  OUTPUT aux_nmarqimp,
                                  OUTPUT aux_nmarqpdf).

       IF   RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                 
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
   ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT aux_nmarqpdf).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
Relatorio Estouro CC Resumido
******************************************************************************/
PROCEDURE rel-estouro-cc-resumido:

    RUN rel-estouro-cc-resumido IN hBO(INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdoperad,
                                       INPUT aux_nmdatela,
                                       INPUT aux_idorigem,
                                       INPUT aux_tprelato,
                                       INPUT aux_cdhistor,
                                       INPUT aux_cdhisest,
                                       INPUT aux_cdcoptel,
                                       INPUT aux_cdagetel,
                                       INPUT aux_inpessoa,
                                       INPUT aux_nrdconta,
                                       INPUT aux_dtinicio,
                                       INPUT aux_dtafinal,
                                       INPUT aux_nmendter,
                                       INPUT aux_dtmvtolt,
                                       INPUT aux_cddgrupo,
                                       INPUT aux_cdsubgru,
                                       OUTPUT TABLE tt-erro,
                                       OUTPUT aux_nmarqimp,
                                       OUTPUT aux_nmarqpdf).

       IF   RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                 
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
   ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT aux_nmarqpdf).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Busca associado LANTAR
******************************************************************************/
PROCEDURE busca-associado-lantar:

    RUN busca-associado-lantar IN hBO(INPUT aux_cdcooper,
                                      INPUT aux_nrdconta,
                                      INPUT aux_telinpes,
                                      OUTPUT aux_cdagenci,
                                      OUTPUT aux_nrmatric,
                                      OUTPUT aux_cdtipcta,
                                      OUTPUT aux_dstipcta,
                                      OUTPUT aux_nmprimtl,
                                      OUTPUT aux_inpessoa,
                                      OUTPUT aux_nmresage,
                                      OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "cdagenci",INPUT STRING(aux_cdagenci)).
            RUN piXmlAtributo (INPUT "nrmatric",INPUT STRING(aux_nrmatric)).
            RUN piXmlAtributo (INPUT "cdtipcta",INPUT STRING(aux_cdtipcta)).
            RUN piXmlAtributo (INPUT "dstipcta",INPUT STRING(aux_dstipcta)).
            RUN piXmlAtributo (INPUT "nmprimtl",INPUT STRING(aux_nmprimtl)).
            RUN piXmlAtributo (INPUT "inpessoa",INPUT STRING(aux_inpessoa)).
            RUN piXmlAtributo (INPUT "nmresage",INPUT STRING(aux_nmresage)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Valida Replicacao Linha Credito
******************************************************************************/
PROCEDURE valida-replicacao-credito:

    RUN valida-replicacao-credito IN hBO(INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_nmdatela,
                                         INPUT aux_idorigem,
                                         INPUT aux_cdfaixav,
                                         INPUT aux_lstcdcop,
                                         INPUT aux_lstdtdiv,
                                         INPUT aux_lstdtvig,
                                         INPUT aux_lstvlrep,
                                         INPUT aux_lstvltar,
                                         INPUT aux_lstlcrem,
                                         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************
 Listagem de Faixa de Valores com as suas tarifas
******************************************************************************/
PROCEDURE lista-fvl-tarifa:

    RUN lista-fvl-tarifa IN hBO(INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT aux_cdtarifa,
                                INPUT aux_cdsubgru,
                                INPUT aux_cdcatego,
                                INPUT aux_cdlcremp,
                                INPUT aux_nrconven,
                                OUTPUT aux_qtregist,
                                OUTPUT TABLE tt-faixavalores).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-faixavalores:HANDLE,
                             INPUT "FaixaValores").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************
 Inclusao de lista de tarifas na fco
******************************************************************************/
PROCEDURE incluir-lista-cadfco:
    
    RUN incluir-lista-cadfco IN hBO(INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_nmdatela,
                                    INPUT aux_idorigem,
                                    INPUT aux_dtdivulg,
                                    INPUT aux_dtvigenc,
                                    INPUT aux_lstfaixa,
                                    INPUT aux_lstvltar,
                                    INPUT aux_lstconve,
                                    INPUT aux_lstocorr,
                                    INPUT aux_lstlcrem,
                                    INPUT aux_cdinctar,
                                    INPUT aux_lstvlper,
                                    INPUT aux_lstvlmin,
                                    INPUT aux_lstvlmax,
							        INPUT aux_lsttptar,
                                    OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE consulta-pacotes-tarifas:

    RUN consulta-pacotes-tarifas IN hBO(INPUT aux_cdcooper, 
                                        INPUT aux_cdagenci, 
                                        INPUT aux_nrdcaixa, 
                                        INPUT aux_cdoperad, 
                                        INPUT aux_dtmvtolt, 
                                        INPUT aux_cddopcao,
                                        INPUT aux_cdpacote,
                                        INPUT aux_dspacote,
                                        INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
                                        INPUT aux_nriniseq,
                                       OUTPUT aux_qtregist,
                                       OUTPUT TABLE tt-tbtarif-pacotes,
                                       OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-tbtarif-pacotes:HANDLE,
                             INPUT "tbtarif-pacotes").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE consulta_pacote_manpac:

    RUN consulta_pacote_manpac IN hBO(INPUT aux_cdcooper, 
                                      INPUT aux_cdagenci, 
                                      INPUT aux_nrdcaixa, 
                                      INPUT aux_cdoperad, 
                                      INPUT aux_dtmvtolt, 
                                      INPUT aux_cddopcao,
                                      INPUT aux_cdpacote,
                                      INPUT aux_dspacote,
                                      INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
                                      INPUT aux_nriniseq,
                                     OUTPUT aux_qtregist,
                                     OUTPUT TABLE tt-tbtarif-pacotes,
                                     OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-tbtarif-pacotes:HANDLE,
                             INPUT "tbtarif-pacotes").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE lista-tarifas-pactar:
    
    RUN lista-tarifas-pactar IN hBO(INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_nrregist,
                             INPUT aux_nriniseq,
                             INPUT aux_cdtarifa,
                             INPUT aux_dstarifa,
                             INPUT aux_cddgrupo,
                             INPUT aux_cdsubgru,
                             INPUT aux_cdcatego,
                             INPUT aux_inpessoa,
                             OUTPUT aux_qtregist,
                             OUTPUT TABLE tt-tarifas).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-tarifas:HANDLE,
                             INPUT "Tarifas").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.
