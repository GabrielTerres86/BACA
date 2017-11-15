/*.............................................................................

    Programa: xb1wgen0052.p
    Autor   : Jose Luis Marchezoni
    Data    : Junho/2010                   Ultima atualizacao: 14/11/2017

    Objetivo  : BO de Comunicacao XML x BO - Tela MATRIC

    Alteracoes: 01/02/2011 - Incluido temp-table tt-prod_serv_ativos da 
                             procedure Valida_Dados. (Jorge) 
                              
                27/04/2012 - Incluido Input aux_dtmvtolt na chamada da
                             Valida_Inicio_Inclusao.(David Kruger).
                             
                15/06/2012 - Ajustes referente ao projeto GP - Socios Menores
                             (Adriano).
                             
                09/08/2013 - Incluido campo cdufnatu. (Reinert)
                
                28/01/2015 - #239097 Ajustes para cadastro de Resp. legal 
                             0 - menor/maior. (Carlos)
                             
                13/07/2015 - Reformulacao cadastral (Gabriel-RKAM).

                01/02/2016 - Melhoria 147 - Adicionar Campos e Aprovacao de
				             Transferencia entre PAs (Heitor - RKAM)				
							 
		        26/06/2017 - Incluido rotina para buscar contas demitidas a serem listadas
				             na opcao "G" da tela MATRIC
							 (Jonata - RKAM P364).		
							 
				14/11/2017 - Ajuste na rotina que busca contas demitidas para enviar conta
						     para pesquisa e retornar valor total da pesquisa
							 (Jonata - RKAM P364). 		
.............................................................................*/

                                                                             

/*...........................................................................*/
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_rowidass AS ROWID                                          NO-UNDO.
DEF VAR aux_rowidavt AS ROWID                                          NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.
DEF VAR aux_cdagepac AS INTE                                           NO-UNDO.
DEF VAR aux_nrcpfcgc AS CHAR                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_dtcadass AS DATE                                           NO-UNDO.
DEF VAR aux_nmsegntl AS CHAR                                           NO-UNDO.
DEF VAR aux_nmpaittl AS CHAR                                           NO-UNDO.
DEF VAR aux_nmmaettl AS CHAR                                           NO-UNDO.
DEF VAR aux_nmconjug AS CHAR                                           NO-UNDO.
DEF VAR aux_cdempres AS INTE                                           NO-UNDO.
DEF VAR aux_cdsexotl AS INTE                                           NO-UNDO.
DEF VAR aux_cdsitcpf AS INTE                                           NO-UNDO.
DEF VAR aux_cdtipcta AS INTE                                           NO-UNDO.
DEF VAR aux_dtcnscpf AS DATE                                           NO-UNDO.
DEF VAR aux_dtnasctl AS DATE                                           NO-UNDO.
DEF VAR aux_tpnacion AS INTE                                           NO-UNDO.
DEF VAR aux_dsnacion AS CHAR                                           NO-UNDO.
DEF VAR aux_dsnatura AS CHAR                                           NO-UNDO.
DEF VAR aux_cdufnatu AS CHAR                                           NO-UNDO.
DEF VAR aux_cdocpttl AS INTE                                           NO-UNDO.
DEF VAR aux_rowidcem AS ROWID                                          NO-UNDO.
DEF VAR aux_dsdemail AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdddres AS INTE                                           NO-UNDO.
DEF VAR aux_nrtelres AS INTE                                           NO-UNDO.
DEF VAR aux_nrdddcel AS INTE                                           NO-UNDO.
DEF VAR aux_nrtelcel AS INTE                                           NO-UNDO.
DEF VAR aux_cdopetfn AS INTE                                           NO-UNDO.
DEF VAR aux_cdcnae   AS INTE                                           NO-UNDO.
DEF VAR aux_cdestcvl AS INTE                                           NO-UNDO.
DEF VAR aux_dsproftl AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdsecao AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcadast AS INTE                                           NO-UNDO.
DEF VAR aux_tpdocptl AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdocptl AS CHAR                                           NO-UNDO.
DEF VAR aux_cdoedptl AS CHAR                                           NO-UNDO.
DEF VAR aux_cdufdptl AS CHAR                                           NO-UNDO.
DEF VAR aux_dtemdptl AS DATE                                           NO-UNDO.
DEF VAR aux_dtdemiss AS DATE                                           NO-UNDO.
DEF VAR aux_cdmotdem AS INTE                                           NO-UNDO.
DEF VAR aux_cdufende AS CHAR                                           NO-UNDO.
DEF VAR aux_dsendere AS CHAR                                           NO-UNDO.
DEF VAR aux_nrendere AS INTE                                           NO-UNDO.
DEF VAR aux_nmbairro AS CHAR                                           NO-UNDO.
DEF VAR aux_nmcidade AS CHAR                                           NO-UNDO.
DEF VAR aux_complend AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcepend AS INTE                                           NO-UNDO.
DEF VAR aux_nrcxapst AS INTE                                           NO-UNDO.
DEF VAR aux_dtiniatv AS DATE                                           NO-UNDO.
DEF VAR aux_natjurid AS INTE                                           NO-UNDO.
DEF VAR aux_nmfansia AS CHAR                                           NO-UNDO.
DEF VAR aux_nrinsest AS DECI                                           NO-UNDO.
DEF VAR aux_cdseteco AS INTE                                           NO-UNDO.
DEF VAR aux_cdrmativ AS INTE                                           NO-UNDO.
DEF VAR aux_nrdddtfc AS INTE                                           NO-UNDO.
DEF VAR aux_nrtelefo AS DECI                                           NO-UNDO.
DEF VAR aux_inmatric AS INTE                                           NO-UNDO.
DEF VAR aux_nrdctato AS INTE                                           NO-UNDO.
DEF VAR aux_nrcpfcto AS DECI                                           NO-UNDO.
DEF VAR aux_qtparcel AS INTE                                           NO-UNDO.
DEF VAR aux_vlparcel AS DECI                                           NO-UNDO.
DEF VAR aux_dtdebito AS DATE                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.
DEF VAR aux_msgretor AS CHAR                                           NO-UNDO.
DEF VAR aux_msgalert AS CHAR                                           NO-UNDO.
DEF VAR aux_permalte AS LOG                                            NO-UNDO.
DEF VAR aux_verrespo AS LOG                                            NO-UNDO.
DEF VAR aux_nrdeanos AS INT                                            NO-UNDO.
DEF VAR aux_nrdmeses AS INT                                            NO-UNDO.
DEF VAR aux_dsdidade AS CHAR                                           NO-UNDO.
DEF VAR aux_dthabmen AS DATE                                           NO-UNDO.
DEF VAR aux_inhabmen AS INTE                                           NO-UNDO.
DEF VAR aux_rowidrsp AS ROWID                                          NO-UNDO.
DEF VAR aux_rowidbem AS ROWID                                          NO-UNDO.
DEF VAR aux_nrctanov AS INTE                                           NO-UNDO.
DEF VAR aux_nmttlrfb AS CHAR                                           NO-UNDO.
DEF VAR aux_inconrfb AS INTE                                           NO-UNDO.
DEF VAR aux_hrinicad AS INTE                                           NO-UNDO.
DEF VAR aux_idorigee AS INTE                                           NO-UNDO.
DEF VAR aux_nrlicamb AS DECI                                           NO-UNDO.
DEF VAR aux_qtregist AS INT                                            NO-UNDO.
DEF VAR aux_nrregist AS INT                                            NO-UNDO.
DEF VAR aux_nriniseq AS INT                                            NO-UNDO.
DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_vlrtotal AS DEC											   NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0052tt.i } 
{ sistema/generico/includes/b1wgen0070tt.i } 
{ sistema/generico/includes/b1wgen0072tt.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-WEB=SIM }
                                             
/*............................... PROCEDURES ................................*/
PROCEDURE valores_entrada:

    DEFINE VARIABLE aux_rowidavt AS ROWID       NO-UNDO.

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:

            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "nrdrowid" THEN aux_nrdrowid = TO-ROWID(tt-param.valorCampo).
            WHEN "rowidavt" THEN aux_rowidavt = TO-ROWID(tt-param.valorCampo).
            WHEN "rowidass" THEN aux_rowidass = TO-ROWID(tt-param.valorCampo).
            WHEN "inpessoa" THEN aux_inpessoa = INTE(tt-param.valorCampo).
            WHEN "cdagepac" THEN aux_cdagepac = INTE(tt-param.valorCampo).
            WHEN "nrcpfcgc" THEN aux_nrcpfcgc = tt-param.valorCampo.
            WHEN "nmprimtl" THEN aux_nmprimtl = tt-param.valorCampo.
            WHEN "dtmvtolt" THEN aux_dtcadass = DATE(tt-param.valorCampo).
            WHEN "nmsegntl" THEN aux_nmsegntl = tt-param.valorCampo.
            WHEN "nmpaittl" THEN aux_nmpaittl = tt-param.valorCampo.
            WHEN "nmmaettl" THEN aux_nmmaettl = tt-param.valorCampo.
            WHEN "nmconjug" THEN aux_nmconjug = tt-param.valorCampo.
            WHEN "cdempres" THEN aux_cdempres = INTE(tt-param.valorCampo).
            WHEN "cdsexotl" THEN aux_cdsexotl = INTE(tt-param.valorCampo).
            WHEN "cdsitcpf" THEN aux_cdsitcpf = INTE(tt-param.valorCampo).
            WHEN "cdtipcta" THEN aux_cdtipcta = INTE(tt-param.valorCampo).
            WHEN "dtcnscpf" THEN aux_dtcnscpf = DATE(tt-param.valorCampo).
            WHEN "dtnasctl" THEN aux_dtnasctl = DATE(tt-param.valorCampo).
            WHEN "tpnacion" THEN aux_tpnacion = INTE(tt-param.valorCampo).
            WHEN "dsnacion" THEN aux_dsnacion = tt-param.valorCampo.
            WHEN "dsnatura" THEN aux_dsnatura = tt-param.valorCampo.
            WHEN "cdufnatu" THEN aux_cdufnatu = tt-param.valorCampo.
            WHEN "cdocpttl" THEN aux_cdocpttl = INTE(tt-param.valorCampo).
            WHEN "cdestcvl" THEN aux_cdestcvl = INTE(tt-param.valorCampo).
            WHEN "dsproftl" THEN aux_dsproftl = tt-param.valorCampo.
            WHEN "nmdsecao" THEN aux_nmdsecao = tt-param.valorCampo.
            WHEN "nrcadast" THEN aux_nrcadast = INTE(tt-param.valorCampo).
            WHEN "tpdocptl" THEN aux_tpdocptl = tt-param.valorCampo.
            WHEN "nrdocptl" THEN aux_nrdocptl = tt-param.valorCampo.
            WHEN "cdoedptl" THEN aux_cdoedptl = tt-param.valorCampo.
            WHEN "rowidcem" THEN aux_rowidcem = TO-ROWID(tt-param.valorCampo).
            WHEN "dsdemail" THEN aux_dsdemail = tt-param.valorCampo.
            WHEN "nrdddres" THEN aux_nrdddres = INTE(tt-param.valorCampo).
            WHEN "nrtelres" THEN aux_nrtelres = INTE(tt-param.valorCampo).
            WHEN "nrdddcel" THEN aux_nrdddcel = INTE(tt-param.valorCampo).
            WHEN "nrtelcel" THEN aux_nrtelcel = INTE(tt-param.valorCampo).
            WHEN "cdopetfn" THEN aux_cdopetfn = INTE(tt-param.valorCampo).
            WHEN "cdcnae"   THEN aux_cdcnae   = INTE(tt-param.valorCampo). 
            WHEN "cdufdptl" THEN aux_cdufdptl = tt-param.valorCampo.
            WHEN "dtemdptl" THEN aux_dtemdptl = DATE(tt-param.valorCampo).
            WHEN "dtdemiss" THEN aux_dtdemiss = DATE(tt-param.valorCampo).
            WHEN "cdmotdem" THEN aux_cdmotdem = INTE(tt-param.valorCampo).
            WHEN "cdufende" THEN aux_cdufende = tt-param.valorCampo.
            WHEN "dsendere" THEN aux_dsendere = tt-param.valorCampo.
            WHEN "nrendere" THEN aux_nrendere = INTE(tt-param.valorCampo).
            WHEN "nmbairro" THEN aux_nmbairro = tt-param.valorCampo.
            WHEN "nmcidade" THEN aux_nmcidade = tt-param.valorCampo.
            WHEN "complend" THEN aux_complend = tt-param.valorCampo.
            WHEN "nrcepend" THEN aux_nrcepend = INTE(tt-param.valorCampo).
            WHEN "nrcxapst" THEN aux_nrcxapst = INTE(tt-param.valorCampo).
            WHEN "dtiniatv" THEN aux_dtiniatv = DATE(tt-param.valorCampo).
            WHEN "natjurid" THEN aux_natjurid = INTE(tt-param.valorCampo).
            WHEN "nmfansia" THEN aux_nmfansia = tt-param.valorCampo.
            WHEN "nrinsest" THEN aux_nrinsest = DECI(tt-param.valorCampo).
            WHEN "cdseteco" THEN aux_cdseteco = INTE(tt-param.valorCampo).
            WHEN "cdrmativ" THEN aux_cdrmativ = INTE(tt-param.valorCampo).
            WHEN "nrdddtfc" THEN aux_nrdddtfc = INTE(tt-param.valorCampo).
            WHEN "nrtelefo" THEN aux_nrtelefo = DECI(tt-param.valorCampo).
            WHEN "inmatric" THEN aux_inmatric = INTE(tt-param.valorCampo).
            WHEN "nrdctato" THEN aux_nrdctato = INTE(tt-param.valorCampo).
            WHEN "nrcpfcto" THEN aux_nrcpfcto = DECI(tt-param.valorCampo).
            WHEN "qtparcel" THEN aux_qtparcel = INTE(tt-param.valorCampo).
            WHEN "vlparcel" THEN aux_vlparcel = DECI(tt-param.valorCampo).
            WHEN "dtdebito" THEN aux_dtdebito = DATE(tt-param.valorCampo).
            WHEN "chavealt" THEN aux_chavealt = tt-param.valorCampo.
            WHEN "tpatlcad" THEN aux_tpatlcad = INTE(tt-param.valorCampo).
            WHEN "verrespo" THEN aux_verrespo = LOGICAL(tt-param.valorCampo).
            WHEN "permalte" THEN aux_permalte = LOGICAL(tt-param.valorCampo).
            WHEN "dthabmen" THEN aux_dthabmen = DATE(tt-param.valorCampo).
            WHEN "inhabmen" THEN aux_inhabmen = INTE(tt-param.valorCampo).
            WHEN "nmttlrfb" THEN aux_nmttlrfb = tt-param.valorCampo.
            WHEN "inconrfb" THEN aux_inconrfb = INTE(tt-param.valorCampo).
            WHEN "hrinicad" THEN aux_hrinicad = INTE(tt-param.valorCampo).
            WHEN "idorigee" THEN aux_idorigee = INTE(tt-param.valorCampo).
            WHEN "nrlicamb" THEN aux_nrlicamb = DECI(tt-param.valorCampo).
			WHEN "nrregist"  THEN aux_nrregist  = INTE(tt-param.valorCampo).
            WHEN "nriniseq"  THEN aux_nriniseq  = INTE(tt-param.valorCampo).

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

    FOR EACH tt-param-i 
        BREAK BY tt-param-i.nomeTabela
              BY tt-param-i.sqControle:

        CASE tt-param-i.nomeTabela:

            WHEN "Procuradores" THEN DO:

                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:
                       CREATE tt-crapavt.
                       ASSIGN aux_rowidavt = ROWID(tt-crapavt).

                    END.

                FIND tt-crapavt WHERE ROWID(tt-crapavt) = aux_rowidavt
                                      NO-ERROR.

                CASE tt-param-i.nomeCampo:
                    WHEN "nrdctato" THEN
                         tt-crapavt.nrdctato = INT(tt-param-i.valorCampo).
                    WHEN "cddctato" THEN
                         tt-crapavt.cddctato = tt-param-i.valorCampo.
                    WHEN "nmdavali" THEN
                         tt-crapavt.nmdavali = tt-param-i.valorCampo.
                    WHEN "tpdocava" THEN
                         tt-crapavt.tpdocava = tt-param-i.valorCampo.
                    WHEN "nrdocava" THEN
                         tt-crapavt.nrdocava = tt-param-i.valorCampo.
                    WHEN "cdoeddoc" THEN
                         tt-crapavt.cdoeddoc = tt-param-i.valorCampo.
                    WHEN "cdufddoc" THEN
                         tt-crapavt.cdufddoc = tt-param-i.valorCampo.
                    WHEN "dtemddoc" THEN
                         tt-crapavt.dtemddoc = DATE(tt-param-i.valorCampo).
                    WHEN "dsproftl" THEN
                         tt-crapavt.dsproftl = tt-param-i.valorCampo.
                    WHEN "nrcpfcgc" THEN
                         tt-crapavt.nrcpfcgc = DECI(tt-param-i.valorCampo).
                    WHEN "cdcpfcgc" THEN
                         tt-crapavt.cdcpfcgc = tt-param-i.valorCampo.
                    WHEN "dtvalida" THEN
                         tt-crapavt.dtvalida = DATE(tt-param-i.valorCampo).
                    WHEN "nrdrowid" THEN
                         tt-crapavt.nrdrowid = TO-ROWID(tt-param-i.valorCampo).
                    WHEN "rowidavt" THEN
                         tt-crapavt.rowidavt = TO-ROWID(tt-param-i.valorCampo).
                    WHEN "dsvalida" THEN
                         tt-crapavt.dsvalida = tt-param-i.valorCampo. 
                    WHEN "dtnascto" THEN
                         tt-crapavt.dtnascto = DATE(tt-param-i.valorCampo).
                    WHEN "cdsexcto" THEN
                         tt-crapavt.cdsexcto = INT(tt-param-i.valorCampo).
                    WHEN "cdestcvl" THEN
                         tt-crapavt.cdestcvl = INT(tt-param-i.valorCampo).
                    WHEN "dsestcvl" THEN
                         tt-crapavt.dsestcvl = tt-param-i.valorCampo.
                    WHEN "nrdeanos" THEN
                         tt-crapavt.nrdeanos = INT(tt-param-i.valorCampo).
                    WHEN "dsnacion" THEN
                         tt-crapavt.dsnacion = tt-param-i.valorCampo.
                    WHEN "dsnatura" THEN
                         tt-crapavt.dsnatura = tt-param-i.valorCampo.
                    WHEN "nmmaecto" THEN
                         tt-crapavt.nmmaecto = tt-param-i.valorCampo.
                    WHEN "nmpaicto" THEN
                         tt-crapavt.nmpaicto = tt-param-i.valorCampo.
                    WHEN "nrcepend" THEN
                         tt-crapavt.nrcepend = INT(tt-param-i.valorCampo).
                    WHEN "dsendres.1" THEN
                         tt-crapavt.dsendres[1] = tt-param-i.valorCampo.
                    WHEN "dsendres.2" THEN
                         tt-crapavt.dsendres[2] = tt-param-i.valorCampo.
                    WHEN "nrendere" THEN
                         tt-crapavt.nrendere = INT(tt-param-i.valorCampo).
                    WHEN "complend" THEN
                         tt-crapavt.complend = tt-param-i.valorCampo.
                    WHEN "nmbairro" THEN
                         tt-crapavt.nmbairro = tt-param-i.valorCampo.
                    WHEN "nmcidade" THEN
                         tt-crapavt.nmcidade = tt-param-i.valorCampo.
                    WHEN "cdufresd" THEN
                         tt-crapavt.cdufresd = tt-param-i.valorCampo.
                    WHEN "dsdrendi.1" THEN
                         tt-crapavt.dsdrendi[1] = tt-param-i.valorCampo.
                    WHEN "dsdrendi.2" THEN
                         tt-crapavt.dsdrendi[2] = tt-param-i.valorCampo.
                    WHEN "dsdrendi.3" THEN
                         tt-crapavt.dsdrendi[3] = tt-param-i.valorCampo.
                    WHEN "dsdrendi.4" THEN
                         tt-crapavt.dsdrendi[4] = tt-param-i.valorCampo.
                    WHEN "dsdrendi.5" THEN
                         tt-crapavt.dsdrendi[5] = tt-param-i.valorCampo.
                    WHEN "dsdrendi.6" THEN
                         tt-crapavt.dsdrendi[6] = tt-param-i.valorCampo.
                    WHEN "dsrelbem.1" THEN
                         tt-crapavt.dsrelbem[1] = tt-param-i.valorCampo.
                    WHEN "dsrelbem.2" THEN
                         tt-crapavt.dsrelbem[2] = tt-param-i.valorCampo.
                    WHEN "dsrelbem.3" THEN
                         tt-crapavt.dsrelbem[3] = tt-param-i.valorCampo.
                    WHEN "dsrelbem.4" THEN
                         tt-crapavt.dsrelbem[4] = tt-param-i.valorCampo.
                    WHEN "dsrelbem.5" THEN
                         tt-crapavt.dsrelbem[5] = tt-param-i.valorCampo.
                    WHEN "dsrelbem.6" THEN
                         tt-crapavt.dsrelbem[6] = tt-param-i.valorCampo.
                    WHEN "persemon.1" THEN
                         tt-crapavt.persemon[1] = DEC(tt-param-i.valorCampo).
                    WHEN "persemon.2" THEN
                         tt-crapavt.persemon[2] = DEC(tt-param-i.valorCampo).
                    WHEN "persemon.3" THEN
                         tt-crapavt.persemon[3] = DEC(tt-param-i.valorCampo).
                    WHEN "persemon.4" THEN
                         tt-crapavt.persemon[4] = DEC(tt-param-i.valorCampo).
                    WHEN "persemon.5" THEN
                         tt-crapavt.persemon[5] = DEC(tt-param-i.valorCampo).
                    WHEN "persemon.6" THEN
                         tt-crapavt.persemon[6] = DEC(tt-param-i.valorCampo).
                    WHEN "qtprebem.1" THEN
                         tt-crapavt.qtprebem[1] = INT(tt-param-i.valorCampo).
                    WHEN "qtprebem.2" THEN
                         tt-crapavt.qtprebem[2] = INT(tt-param-i.valorCampo).
                    WHEN "qtprebem.3" THEN
                         tt-crapavt.qtprebem[3] = INT(tt-param-i.valorCampo).
                    WHEN "qtprebem.4" THEN
                         tt-crapavt.qtprebem[4] = INT(tt-param-i.valorCampo).
                    WHEN "qtprebem.5" THEN
                         tt-crapavt.qtprebem[5] = INT(tt-param-i.valorCampo).
                    WHEN "qtprebem.6" THEN
                         tt-crapavt.qtprebem[6] = INT(tt-param-i.valorCampo).
                    WHEN "vlprebem.1" THEN
                         tt-crapavt.vlprebem[1] = DEC(tt-param-i.valorCampo).
                    WHEN "vlprebem.2" THEN
                         tt-crapavt.vlprebem[2] = DEC(tt-param-i.valorCampo).
                    WHEN "vlprebem.3" THEN
                         tt-crapavt.vlprebem[3] = DEC(tt-param-i.valorCampo).
                    WHEN "vlprebem.4" THEN
                         tt-crapavt.vlprebem[4] = DEC(tt-param-i.valorCampo).
                    WHEN "vlprebem.5" THEN
                         tt-crapavt.vlprebem[5] = DEC(tt-param-i.valorCampo).
                    WHEN "vlprebem.6" THEN
                         tt-crapavt.vlprebem[6] = DEC(tt-param-i.valorCampo).
                    WHEN "vlrdobem.1" THEN
                         tt-crapavt.vlrdobem[1] = DEC(tt-param-i.valorCampo).
                    WHEN "vlrdobem.2" THEN
                         tt-crapavt.vlrdobem[2] = DEC(tt-param-i.valorCampo).
                    WHEN "vlrdobem.3" THEN
                         tt-crapavt.vlrdobem[3] = DEC(tt-param-i.valorCampo).
                    WHEN "vlrdobem.4" THEN
                         tt-crapavt.vlrdobem[4] = DEC(tt-param-i.valorCampo).
                    WHEN "vlrdobem.5" THEN
                         tt-crapavt.vlrdobem[5] = DEC(tt-param-i.valorCampo).
                    WHEN "vlrdobem.6" THEN
                         tt-crapavt.vlrdobem[6] = DEC(tt-param-i.valorCampo).
                    WHEN "nrcxapst" THEN
                         tt-crapavt.nrcxapst = INT(tt-param-i.valorCampo).
                    WHEN "dtadmsoc" THEN
                         tt-crapavt.dtadmsoc = DATE(tt-param-i.valorCampo).
                    WHEN "flgdepec" THEN
                         tt-crapavt.flgdepec = LOGICAL(tt-param-i.valorCampo).
                    WHEN "persocio" THEN
                         tt-crapavt.persocio = DEC(tt-param-i.valorCampo).
                    WHEN "vledvmto" THEN
                         tt-crapavt.vledvmto = DEC(tt-param-i.valorCampo).
                    WHEN "inhabmen" THEN
                         tt-crapavt.inhabmen = INT(tt-param-i.valorCampo).
                    WHEN "dthabmen" THEN
                         tt-crapavt.dthabmen = DATE(tt-param-i.valorCampo).
                    WHEN "dshabmen" THEN
                         tt-crapavt.dshabmen = tt-param-i.valorCampo.
                    WHEN "nrctremp" THEN
                         tt-crapavt.nrctremp = INT(tt-param-i.valorCampo).
                    WHEN "nrdconta" THEN
                         tt-crapavt.nrdconta = INT(tt-param-i.valorCampo).
                    WHEN "vloutren" THEN
                         tt-crapavt.vloutren = DEC(tt-param-i.valorCampo).
                    WHEN "dsoutren" THEN
                         tt-crapavt.dsoutren = tt-param-i.valorCampo.
                    WHEN "cdcooper" THEN
                         tt-crapavt.cdcooper = INT(tt-param-i.valorCampo).
                    WHEN "tpctrato" THEN
                         tt-crapavt.tpctrato = INT(tt-param-i.valorCampo).
                    WHEN "cddconta" THEN
                         tt-crapavt.cddconta = tt-param-i.valorCampo.
                    WHEN "dstipcta" THEN
                         tt-crapavt.dstipcta = tt-param-i.valorCampo.
                    WHEN "dtmvtolt" THEN
                         tt-crapavt.dtmvtolt = DATE(tt-param-i.valorCampo).
                    WHEN "cddopcao" THEN
                        tt-crapavt.cddopcao = tt-param-i.valorCampo.
                    WHEN "deletado" THEN
                        tt-crapavt.deletado = LOGICAL(tt-param-i.valorCampo).
                    
                END CASE.
            END.


            WHEN "RespLegal" THEN DO:

                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:
                       CREATE tt-crapcrl.
                       ASSIGN aux_rowidrsp = ROWID(tt-crapcrl).
                    END.

                FIND tt-crapcrl WHERE 
                     ROWID(tt-crapcrl) = aux_rowidrsp NO-ERROR.

                CASE tt-param-i.nomeCampo:
                                            
                    WHEN "cddctato" THEN
                        ASSIGN tt-crapcrl.cddctato = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrdrowid" THEN
                        ASSIGN tt-crapcrl.nrdrowid = 
                          TO-ROWID(tt-param-i.valorCampo).
                    WHEN "cdcooper" THEN
                        ASSIGN tt-crapcrl.cdcooper = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrctamen" THEN
                        ASSIGN tt-crapcrl.nrctamen = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrcpfmen" THEN
                        ASSIGN tt-crapcrl.nrcpfmen = 
                            DEC(tt-param-i.valorCampo).
                    WHEN "idseqmen" THEN
                        ASSIGN tt-crapcrl.idseqmen = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrdconta" THEN
                        ASSIGN tt-crapcrl.nrdconta = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrcpfcgc" THEN
                        ASSIGN tt-crapcrl.nrcpfcgc = 
                            DEC(tt-param-i.valorCampo).
                    WHEN "nmrespon" THEN
                        ASSIGN tt-crapcrl.nmrespon = 
                            tt-param-i.valorCampo.
                    WHEN "nridenti" THEN
                        ASSIGN tt-crapcrl.nridenti = 
                            tt-param-i.valorCampo.
                    WHEN "tpdeiden" THEN
                        ASSIGN tt-crapcrl.tpdeiden = 
                            tt-param-i.valorCampo.
                    WHEN "dsorgemi" THEN
                        ASSIGN tt-crapcrl.dsorgemi = 
                            tt-param-i.valorCampo.
                    WHEN "cdufiden" THEN
                        ASSIGN tt-crapcrl.cdufiden = 
                            tt-param-i.valorCampo.
                    WHEN "dtemiden" THEN
                        ASSIGN tt-crapcrl.dtemiden = 
                            DATE(tt-param-i.valorCampo).
                    WHEN "dtnascin" THEN
                        ASSIGN tt-crapcrl.dtnascin = 
                            DATE(tt-param-i.valorCampo).
                    WHEN "cddosexo" THEN
                        ASSIGN tt-crapcrl.cddosexo = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "cdestciv" THEN
                        ASSIGN tt-crapcrl.cdestciv = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "dsnacion" THEN
                        ASSIGN tt-crapcrl.dsnacion = 
                            tt-param-i.valorCampo.
                    WHEN "dsnatura" THEN
                        ASSIGN tt-crapcrl.dsnatura = 
                            tt-param-i.valorCampo.
                    WHEN "cdcepres" THEN
                        ASSIGN tt-crapcrl.cdcepres = 
                            DEC(tt-param-i.valorCampo).
                    WHEN "dsendres" THEN
                        ASSIGN tt-crapcrl.dsendres = 
                            tt-param-i.valorCampo.
                    WHEN "nrendres" THEN
                        ASSIGN tt-crapcrl.nrendres = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "dscomres" THEN
                        ASSIGN tt-crapcrl.dscomres = 
                            tt-param-i.valorCampo.
                    WHEN "dsbaires" THEN
                        ASSIGN tt-crapcrl.dsbaires = 
                            tt-param-i.valorCampo.
                    WHEN "nrcxpost" THEN
                        ASSIGN tt-crapcrl.nrcxpost = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "dscidres" THEN
                        ASSIGN tt-crapcrl.dscidres = 
                            tt-param-i.valorCampo.
                    WHEN "dsdufres" THEN
                        ASSIGN tt-crapcrl.dsdufres = 
                            tt-param-i.valorCampo.
                    WHEN "nmpairsp" THEN
                        ASSIGN tt-crapcrl.nmpairsp = 
                            tt-param-i.valorCampo.
                    WHEN "nmmaersp" THEN
                        ASSIGN tt-crapcrl.nmmaersp = 
                            tt-param-i.valorCampo.
                    WHEN "cdrlcrsp" THEN
                        ASSIGN tt-crapcrl.cdrlcrsp =
                            INTE(tt-param-i.valorCampo).
                    WHEN "cddopcao" THEN
                        ASSIGN tt-crapcrl.cddopcao = 
                            tt-param-i.valorCampo.
                    WHEN "deletado" THEN
                        ASSIGN tt-crapcrl.deletado = 
                            LOGICAL(tt-param-i.valorCampo). 
                                                          
                END CASE. /* CASE tt-param-i.nomeCampo */ 

            END. /* "resp Legal"  */


        END CASE.
    END.

    FOR EACH tt-param-i BREAK BY tt-param-i.nomeTabela
                               BY tt-param-i.sqControle:
        
        CASE tt-param-i.nomeTabela:
      
             WHEN "Bens" THEN DO:

                 IF  FIRST-OF(tt-param-i.sqControle) THEN
                     DO:
                        CREATE tt-bens.
                        ASSIGN aux_rowidbem = ROWID(tt-bens).
                     END.
      
                 FIND tt-bens WHERE 
                      ROWID(tt-bens) = aux_rowidbem NO-ERROR.
      
                 CASE tt-param-i.nomeCampo:
                                             
                     WHEN "dsrelbem" THEN
                         ASSIGN tt-bens.dsrelbem = 
                                tt-param-i.valorCampo.
                     WHEN "persemon" THEN
                         ASSIGN tt-bens.persemon = 
                                DEC(tt-param-i.valorCampo).
                     WHEN "qtprebem" THEN
                         ASSIGN tt-bens.qtprebem = 
                                INT(tt-param-i.valorCampo).
                     WHEN "vlprebem" THEN
                         ASSIGN tt-bens.vlprebem = 
                                DEC(tt-param-i.valorCampo).
                     WHEN "vlrdobem" THEN
                         ASSIGN tt-bens.vlrdobem = 
                                DEC(tt-param-i.valorCampo).
                     WHEN "cdsequen" THEN
                         ASSIGN tt-bens.cdsequen = 
                                INT(tt-param-i.valorCampo).
                     WHEN "cddopcao" THEN
                         ASSIGN tt-bens.cddopcao = 
                                tt-param-i.valorCampo.
                     WHEN "deletado" THEN
                         ASSIGN tt-bens.deletado = 
                                LOGICAL(tt-param-i.valorCampo).
                     WHEN "nrdrowid" THEN
                         ASSIGN tt-bens.nrdrowid = 
                                TO-ROWID(tt-param-i.valorCampo).

                 END CASE. /* CASE tt-param-i.nomeCampo */ 
      
             END. /* "Bens"  */
      
        END CASE. /* CASE tt-param-i.nomeTabela: */
                         
    END.


END PROCEDURE.    

/* ************************************************************************ */
/*                      BUSCA OS DADOS DO ASSOCIADO                         */
/* ************************************************************************ */
PROCEDURE Busca_Dados:

    RUN Busca_Dados IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrdconta,
                            INPUT aux_idseqttl,
                            INPUT YES,
                            INPUT aux_cddopcao,
                           OUTPUT TABLE tt-crapass,
                           OUTPUT TABLE tt-operadoras-celular,
                           OUTPUT TABLE tt-crapavt,
                           OUTPUT TABLE tt-alertas,
                           OUTPUT TABLE tt-erro,
                           OUTPUT TABLE tt-bens,
                           OUTPUT TABLE tt-crapcrl) NO-ERROR .

    IF  ERROR-STATUS:ERROR  THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
           RETURN.
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
               END.

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-crapass:HANDLE,
                            INPUT "Associado").
           RUN piXmlExport (INPUT TEMP-TABLE tt-operadoras-celular:HANDLE,
                            INPUT "Operadoras").
           RUN piXmlExport (INPUT TEMP-TABLE tt-crapavt:HANDLE,
                            INPUT "Procuradores").
           RUN piXmlExport (INPUT TEMP-TABLE tt-bens:HANDLE,
                            INPUT "Bens").
           RUN piXmlExport (INPUT TEMP-TABLE tt-alertas:HANDLE,
                            INPUT "Alertas").
           RUN piXmlExport (INPUT TEMP-TABLE tt-crapcrl:HANDLE,
                            INPUT "Responsavel"). 
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ************************************************************************ */
/*               BUSCA OS DADOS DO ASSOCIADO PARA IMPRESSAO                 */
/* ************************************************************************ */
PROCEDURE Busca_Impressao:

    RUN Busca_Impressao IN hBO (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT aux_nrdconta,
                                INPUT aux_idseqttl,
                                INPUT YES,
                                INPUT aux_dtmvtolt,
                               OUTPUT TABLE tt-relat-cab,
                               OUTPUT TABLE tt-relat-par,
                               OUTPUT TABLE tt-relat-fis,
                               OUTPUT TABLE tt-relat-jur,
                               OUTPUT TABLE tt-relat-rep,
                               OUTPUT TABLE tt-erro) NO-ERROR .

    IF  ERROR-STATUS:ERROR  THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
           RETURN.
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
               END.

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-relat-cab:HANDLE,
                            INPUT "Cabecalho").
           RUN piXmlExport (INPUT TEMP-TABLE tt-relat-par:HANDLE,
                            INPUT "Parcelas").
           RUN piXmlExport (INPUT TEMP-TABLE tt-relat-fis:HANDLE,
                            INPUT "PessoaFisica").
           RUN piXmlExport (INPUT TEMP-TABLE tt-relat-jur:HANDLE,
                            INPUT "PessoaJuridica").
           RUN piXmlExport (INPUT TEMP-TABLE tt-relat-rep:HANDLE,
                            INPUT "Procuradores").
           RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE Valida_Cidades:

    RUN Valida_Cidades IN hBO (INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nmdatela,
                               INPUT aux_idorigem,
                               INPUT aux_nmcidade,
                               INPUT aux_cdufende,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                  CREATE tt-erro.
                  ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                            "validacao de dados.".
               END.

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
           RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ************************************************************************ */
/*                      VALIDA OS DADOS DO ASSOCIADO                        */
/* ************************************************************************ */
PROCEDURE Valida_Dados:


    RUN Valida_Dados IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_nrdconta,
                             INPUT aux_idseqttl,
                             INPUT YES,
                             INPUT aux_cddopcao,
                             INPUT aux_dtmvtolt,
                             INPUT aux_inpessoa,
                             INPUT aux_cdagepac,
                             INPUT STRING(aux_nrcpfcgc),
                             INPUT aux_nmprimtl,
                             INPUT aux_dtcadass,
                             INPUT aux_nmsegntl,
                             INPUT aux_nmpaittl,
                             INPUT aux_nmmaettl,
                             INPUT aux_nmconjug,
                             INPUT aux_cdempres,
                             INPUT aux_cdsexotl,
                             INPUT aux_cdsitcpf,
                             INPUT aux_cdtipcta,
                             INPUT aux_dtcnscpf,
                             INPUT aux_dtnasctl,
                             INPUT aux_tpnacion,
                             INPUT aux_dsnacion,
                             INPUT aux_dsnatura,
                             INPUT aux_cdufnatu,
                             INPUT aux_cdocpttl,
                             INPUT aux_cdestcvl,
                             INPUT aux_dsproftl,
                             INPUT aux_nrcadast,
                             INPUT aux_tpdocptl,
                             INPUT aux_nrdocptl,
                             INPUT aux_cdoedptl,
                             INPUT aux_cdufdptl,
                             INPUT aux_dtemdptl,
                             INPUT aux_dtdemiss,
                             INPUT aux_cdmotdem,
                             INPUT aux_cdufende,
                             INPUT aux_dsendere,
                             INPUT aux_nrendere,
                             INPUT aux_nmbairro,
                             INPUT aux_nmcidade,
                             INPUT aux_complend,
                             INPUT aux_nrcepend,
                             INPUT aux_nrcxapst,
                             INPUT aux_dtiniatv,
                             INPUT aux_natjurid,
                             INPUT aux_nmfansia,
                             INPUT aux_nrinsest,
                             INPUT aux_cdseteco,
                             INPUT aux_cdrmativ,
                             INPUT aux_nrdddtfc,
                             INPUT aux_nrtelefo,
                             INPUT aux_inmatric,
                             INPUT YES,
                             INPUT aux_verrespo,
                             INPUT aux_permalte,
                             INPUT aux_inhabmen,
                             INPUT aux_dthabmen,
                             INPUT TABLE tt-crapavt,
                             INPUT TABLE tt-crapcrl,
                            OUTPUT aux_nrctanov,
                            OUTPUT aux_qtparcel,
                            OUTPUT aux_vlparcel,
                            OUTPUT aux_nmdcampo,
                            OUTPUT aux_msgretor,
                            OUTPUT aux_nrdeanos,
                            OUTPUT aux_nrdmeses,
                            OUTPUT aux_dsdidade,
                            OUTPUT TABLE tt-alertas,
                            OUTPUT TABLE tt-erro,
                            OUTPUT TABLE tt-prod_serv_ativos) NO-ERROR .

    IF  ERROR-STATUS:ERROR  THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
           RUN piXmlSave.

           RETURN.
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                  CREATE tt-erro.
                  ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                            "validacao de dados.".
               END.

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
           RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "nrctanov", INPUT aux_nrctanov).
           RUN piXmlAtributo (INPUT "msgretor", INPUT aux_msgretor).
           RUN piXmlAtributo (INPUT "qtparcel", INPUT aux_qtparcel).
           RUN piXmlAtributo (INPUT "vlparcel", INPUT aux_vlparcel).
           RUN piXmlAtributo (INPUT "nrdeanos", INPUT aux_nrdeanos).
           RUN piXmlAtributo (INPUT "nrdmeses", INPUT aux_nrdmeses).
           RUN piXmlAtributo (INPUT "dsdidade", INPUT aux_dsdidade).
           RUN piXmlExport (INPUT TEMP-TABLE tt-alertas:HANDLE,
                            INPUT "Alertas").
           RUN piXmlExport (INPUT TEMP-TABLE tt-prod_serv_ativos:HANDLE,
                            INPUT "ProdServ").
           RUN piXmlSave.
        END.

END PROCEDURE. /* procedure Valida_Dados */

/* ************************************************************************ */
/*              VALIDA INICIO DO PROCEDIMENTO PARA INCLUSAO                 */
/* ************************************************************************ */
PROCEDURE Valida_Inicio_Inclusao:

    RUN Valida_Inicio_Inclusao IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdoperad,
                                       INPUT aux_nmdatela,
                                       INPUT aux_idorigem,
                                       INPUT aux_nrdconta,
                                       INPUT aux_idseqttl,
                                       INPUT aux_inpessoa,
                                       INPUT aux_cdagepac,
                                       INPUT TRUE,
                                       INPUT aux_dtmvtolt,
                                      OUTPUT aux_nmdcampo,
                                      OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).
       
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
            RUN piXmlSave.
       
            RETURN.
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
       
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "validacao de dados.".
                END.
       
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/* ************************************************************************ */
/*                       GRAVA OS DADOS DO ASSOCIADO                        */
/* ************************************************************************ */
PROCEDURE Grava_Dados:

    RUN Grava_Dados IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrdconta,
                            INPUT aux_idseqttl,
                            INPUT YES,
                            INPUT aux_cddopcao,
                            INPUT aux_dtmvtolt,
                            INPUT aux_dtmvtoan,
                            INPUT aux_rowidass,
                            INPUT aux_inpessoa,
                            INPUT aux_cdagepac,
                            INPUT DECI(aux_nrcpfcgc),
                            INPUT aux_nmprimtl,
                            INPUT aux_nmpaittl,
                            INPUT aux_nmmaettl,
                            INPUT aux_nmconjug,
                            INPUT aux_cdempres,
                            INPUT aux_cdsexotl,
                            INPUT aux_cdsitcpf,
                            INPUT aux_dtcnscpf,
                            INPUT aux_dtnasctl,
                            INPUT aux_tpnacion,
                            INPUT aux_dsnacion,
                            INPUT aux_dsnatura,
                            INPUT aux_cdufnatu,
                            INPUT aux_cdocpttl,
                            INPUT aux_rowidcem,
                            INPUT aux_dsdemail,
                            INPUT aux_nrdddres,
                            INPUT aux_nrtelres,
                            INPUT aux_nrdddcel,
                            INPUT aux_nrtelcel,
                            INPUT aux_cdopetfn,
                            INPUT aux_cdcnae,
                            INPUT aux_cdestcvl,
                            INPUT aux_dsproftl,
                            INPUT aux_nmdsecao,
                            INPUT aux_nrcadast,
                            INPUT aux_tpdocptl,
                            INPUT aux_nrdocptl,
                            INPUT aux_cdoedptl,
                            INPUT aux_cdufdptl,
                            INPUT aux_dtemdptl,
                            INPUT aux_dtdemiss,
                            INPUT aux_cdmotdem,
                            INPUT aux_cdufende,
                            INPUT aux_dsendere,
                            INPUT aux_nrendere,
                            INPUT aux_nmbairro,
                            INPUT aux_nmcidade,
                            INPUT aux_complend,
                            INPUT aux_nrcepend,
                            INPUT aux_nrcxapst,
                            INPUT aux_dtiniatv,
                            INPUT aux_natjurid,
                            INPUT aux_nmfansia,
                            INPUT aux_nrinsest,
                            INPUT aux_cdseteco,
                            INPUT aux_cdrmativ,
                            INPUT aux_nrdddtfc,
                            INPUT aux_nrtelefo,
                            INPUT aux_dtdebito,
                            INPUT aux_qtparcel,
                            INPUT aux_vlparcel,
                            INPUT aux_inhabmen,
                            INPUT aux_dthabmen,
                            INPUT aux_nmttlrfb,
                            INPUT aux_inconrfb,
                            INPUT aux_hrinicad,
                            INPUT TABLE tt-crapavt,
                            INPUT TABLE tt-crapcrl,
                            INPUT TABLE tt-bens,
                            INPUT aux_idorigee,
                            INPUT aux_nrlicamb,
                           OUTPUT aux_msgretor,
                           OUTPUT aux_tpatlcad,
                           OUTPUT aux_msgatcad,
                           OUTPUT aux_chavealt,
                           OUTPUT aux_msgrecad,
                           OUTPUT TABLE tt-erro) NO-ERROR .

    IF  ERROR-STATUS:ERROR  THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
           RETURN.
        END.

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "gravacao de dados.".
               END.

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "msgretor", INPUT aux_msgretor).
           RUN piXmlAtributo (INPUT "msgrecad", INPUT aux_msgrecad).
           RUN piXmlAtributo (INPUT "msgatcad", INPUT aux_msgatcad).
           RUN piXmlAtributo (INPUT "tpatlcad", INPUT aux_tpatlcad).
           RUN piXmlAtributo (INPUT "chavealt", INPUT aux_chavealt).
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ************************************************************************ */
/*               BUSCA OS DADOS DOS PROCURADORES DO ASSOCIADO               */
/* ************************************************************************ */
PROCEDURE Busca_Procurador:

    RUN Busca_Procurador IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nmdatela,
                                 INPUT aux_idorigem,
                                 INPUT aux_nrdconta,
                                 INPUT aux_idseqttl,
                                 INPUT YES,
                                 INPUT aux_cddopcao,
                                 INPUT aux_nrdctato,
                                 INPUT aux_nrcpfcto,
                                 INPUT aux_rowidavt,
                                OUTPUT TABLE tt-crapavt,
                                OUTPUT TABLE tt-erro) NO-ERROR .

    IF  ERROR-STATUS:ERROR THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
           RETURN.
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
               END.

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-crapavt:HANDLE,
                            INPUT "Procuradores").
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ************************************************************************ */
/*              VALIDA OS DADOS DOS PROCURADORES DO ASSOCIADO               */
/* ************************************************************************ */
PROCEDURE Valida_Procurador:

    RUN Valida_Procurador IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT YES,
                                  INPUT aux_dtmvtolt,
                                  INPUT TABLE tt-crapavt,
                                 OUTPUT aux_nmdcampo,
                                 OUTPUT TABLE tt-erro) NO-ERROR .

    IF  ERROR-STATUS:ERROR THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
           RETURN.
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "validacao de dados.".
               END.

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
           RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ************************************************************************ */
/*              VALIDA OS DADOS DO PARCELAMENTO DE CAPITAL                  */
/* ************************************************************************ */
PROCEDURE Valida_Parcelamento:

    RUN Valida_Parcelamento IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_nmdatela,
                                    INPUT aux_idorigem,
                                    INPUT aux_nrdconta,
                                    INPUT aux_idseqttl,
                                    INPUT YES,
                                    INPUT aux_dtmvtolt,
                                    INPUT aux_dtdebito,
                                    INPUT aux_qtparcel,
                                    INPUT aux_vlparcel,
                                   OUTPUT aux_msgretor,
                                   OUTPUT TABLE tt-parccap,
                                   OUTPUT TABLE tt-erro) NO-ERROR .

    IF  ERROR-STATUS:ERROR THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
           RETURN.
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "validacao de dados.".
               END.

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport   (INPUT TEMP-TABLE tt-parccap:HANDLE,
                              INPUT "ParcCap").
           RUN piXmlAtributo (INPUT "msgretor",INPUT aux_msgretor).
           RUN piXmlAtributo (INPUT "dtdebito",STRING(aux_dtdebito)).
           RUN piXmlAtributo (INPUT "qtparcel",STRING(aux_qtparcel)).
           RUN piXmlAtributo (INPUT "vlparcel",STRING(aux_vlparcel)).
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ************************************************************************ */
/*               BUSCA OS DADOS DOS PROCURADORES DO ASSOCIADO               */
/* ************************************************************************ */
PROCEDURE Grava_Procurador:

    RUN Grava_Procurador IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nmdatela,
                                 INPUT aux_idorigem,
                                 INPUT aux_nrdconta,
                                 INPUT aux_idseqttl,
                                 INPUT YES,
                                 INPUT aux_cddopcao,
                                OUTPUT TABLE tt-erro) NO-ERROR .

    IF  ERROR-STATUS:ERROR  THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
           RETURN.
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "gravacao de dados.".
               END.

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "msgatcad", INPUT aux_msgatcad).
           RUN piXmlAtributo (INPUT "tpatlcad", INPUT aux_tpatlcad).
           RUN piXmlAtributo (INPUT "chavealt", INPUT aux_chavealt).
           RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE Retorna_Conta:

    RUN Retorna_Conta IN hBo (INPUT aux_cdcooper,
                              INPUT aux_idorigem,
                             OUTPUT aux_nrdconta).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "gravacao de dados.".
               END.

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "nrctanov", INPUT aux_nrdconta).
           RUN piXmlSave.
        END.

END PROCEDURE.
/* ************************************************************************ */
/*                      BUSCA AS CONTAS DEMITIDAS                           */
/* ************************************************************************ */
PROCEDURE busca_contas_demitidas:

    RUN busca_contas_demitidas IN hBO (INPUT aux_cdcooper,
									   INPUT aux_cdagenci,
									   INPUT aux_nrdcaixa,
									   INPUT aux_cdoperad,
									   INPUT aux_nmdatela,
									   INPUT aux_idorigem,
									   INPUT aux_cddopcao,
									   INPUT aux_nrdconta,
									   INPUT aux_nriniseq,
									   INPUT aux_nrregist,
									   OUTPUT aux_qtregist,
									   OUTPUT aux_vlrtotal,
                                       OUTPUT TABLE tt-contas_demitidas,
									   OUTPUT TABLE tt-erro) NO-ERROR .

    IF  ERROR-STATUS:ERROR  THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
           RETURN.
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de contas demitidas.".
               END.

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-contas_demitidas:HANDLE,
                            INPUT "ContasDemitidas").
		   RUN piXmlAtributo (INPUT "qtregist", INPUT STRING(aux_qtregist)).
		   RUN piXmlAtributo (INPUT "vlrtotal", INPUT aux_vlrtotal).
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ************************************************************************ */
/*                      Busca servicos ativos                               */
/* ************************************************************************ */
PROCEDURE Produtos_Servicos_Ativos:

	
    RUN Produtos_Servicos_Ativos IN hBO (INPUT aux_cdcooper,
										 INPUT aux_dtdemiss,
										 INPUT aux_cdagenci,
										 INPUT aux_nrdcaixa,
										 INPUT aux_cdoperad,
										 INPUT aux_nmdatela,
										 INPUT aux_idorigem,
										 INPUT aux_nrdconta,
										 INPUT aux_idseqttl,
										 INPUT YES,
										 INPUT aux_dtmvtolt,
										OUTPUT TABLE tt-erro,
										OUTPUT TABLE tt-prod_serv_ativos) NO-ERROR .

    IF  ERROR-STATUS:ERROR  THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
           RUN piXmlSave.

           RETURN.
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
		   FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de servicos ativos.".
               END.

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
			
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-prod_serv_ativos:HANDLE,
                            INPUT "ProdServ").
           RUN piXmlSave.
        END.

END PROCEDURE. /* procedure Valida_Dados */

/* ......................................................................... */


