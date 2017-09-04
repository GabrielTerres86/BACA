/*.............................................................................

    Programa: xb1wgen0058.p
    Autor   : Jose Luis
    Data    : Marco/2010                   Ultima atualizacao: 08/05/2017

    Objetivo  : BO de Comunicacao XML x BO de Contas Procurador (b1wgen0058.p)

    Alteracoes: 15/09/2010 - Adaptacao para PF (Jose Luis - DB1)
    
                16/08/2011 - Parametros GE (Guilherme)
                
                16/04/2012 - Ajustes referente ao projeto GP - Socios Menores
                            (Adriano).
                            
                08/10/2012 - Alterado "WHEN Procuradores" no tratamento da
                             tabela dos procuradores para "WHEN Procurador"
                             (Adriano).
                             
                24/07/2013 - Incluida proc grava_dados_poderes (Jean Michel)
                
                27/07/2015 - Reformulacao cadastral (Gabriel-RKAM).
                
                26/11/2015 - Inclusao da procedure valida_responsaveis
                             para o Prj. Assinatura Conjunta (Jean Michel).
   
                27/11/2015 - Inclusao da procedure grava_resp_ass_conjunta
                             para o Prj. Assinatura Conjunta (Jean Michel).

				25/08/2016 - Alteraçoes de parametros da procedure
							 valida_responsaveis, SD 510426 (Jean Michel).
               
               
               08/05/2017 - Alteraçao DSNACION pelo campo CDNACION.
                            PRJ339 - CRM (Odirlei-AMcom) 
                            
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
DEF VAR aux_msgalert AS CHAR                                           NO-UNDO.
DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdctato AS INTE                                           NO-UNDO.
DEF VAR aux_nrcpfcgc AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdavali AS CHAR                                           NO-UNDO.
DEF VAR aux_tpdocava AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdocava AS CHAR                                           NO-UNDO.
DEF VAR aux_cdoeddoc AS CHAR                                           NO-UNDO.
DEF VAR aux_cdufddoc AS CHAR                                           NO-UNDO.
DEF VAR aux_dtemddoc AS DATE                                           NO-UNDO.
DEF VAR aux_dtnascto AS DATE                                           NO-UNDO.
DEF VAR aux_cdsexcto AS CHAR                                           NO-UNDO.
DEF VAR aux_cdestcvl AS INTE                                           NO-UNDO.
DEF VAR aux_dsestcvl AS CHAR                                           NO-UNDO.
DEF VAR aux_cdnacion AS INTE                                           NO-UNDO.
DEF VAR aux_dsnatura AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcepend AS INTE                                           NO-UNDO.
DEF VAR aux_dsendres AS CHAR                                           NO-UNDO.
DEF VAR aux_nrendere AS INTE                                           NO-UNDO.
DEF VAR aux_complend AS CHAR                                           NO-UNDO.
DEF VAR aux_nmbairro AS CHAR                                           NO-UNDO.
DEF VAR aux_nmcidade AS CHAR                                           NO-UNDO.
DEF VAR aux_cdufresd AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcxapst AS INTE                                           NO-UNDO.
DEF VAR aux_nmmaecto AS CHAR                                           NO-UNDO.
DEF VAR aux_nmpaicto AS CHAR                                           NO-UNDO.
DEF VAR aux_vledvmto AS DECI                                           NO-UNDO.
DEF VAR aux_dsrelbem AS CHAR                                           NO-UNDO.
DEF VAR aux_dtvalida AS DATE                                           NO-UNDO.
DEF VAR aux_dsproftl AS CHAR                                           NO-UNDO.
DEF VAR aux_dtadmsoc AS DATE                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_cdsequen AS INTE                                           NO-UNDO.
DEF VAR aux_seqdobem AS INTE                                           NO-UNDO.
DEF VAR aux_rowidbem AS ROWID                                          NO-UNDO.
DEF VAR aux_inhabmen AS INT                                            NO-UNDO.
DEF VAR aux_dthabmen AS DATE                                           NO-UNDO.
DEF VAR aux_nmrotina AS CHAR                                           NO-UNDO.
DEF VAR aux_lstpoder AS CHAR                                           NO-UNDO.

DEF VAR aux_persocio AS DECI                                           NO-UNDO.
DEF VAR aux_flgdepec AS LOGICAL                                        NO-UNDO.
DEF VAR aux_vloutren AS DECI                                           NO-UNDO.
DEF VAR aux_dsoutren AS CHAR                                           NO-UNDO.
DEF VAR opt_persocio AS DECI                                           NO-UNDO.
DEF VAR aux_verrespo AS LOG                                            NO-UNDO.
DEF VAR aux_rowidrsp AS ROWID                                          NO-UNDO.
DEF VAR aux_rowidavt AS ROWID                                          NO-UNDO.

DEF VAR aux_permalte AS LOG                                            NO-UNDO.
DEF VAR aux_nrdeanos AS INT                                            NO-UNDO.
DEF VAR aux_nrdmeses AS INT                                            NO-UNDO.
DEF VAR aux_dsdidade AS CHAR                                           NO-UNDO.

DEF VAR aux_tpctrato AS INT                                            NO-UNDO.
DEF VAR aux_nrdctpro AS INT                                            NO-UNDO.
DEF VAR aux_cpfprocu AS DEC                                            NO-UNDO.
DEF VAR aux_cddpoder AS INT                                            NO-UNDO.
DEF VAR aux_rowidpod AS ROWID                                          NO-UNDO.
DEF VAR aux_dscpfcgc AS CHAR                                           NO-UNDO.
DEF VAR aux_responsa AS CHAR                                           NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.
DEF VAR aux_idastcjt AS INTE                                           NO-UNDO.
DEF VAR aux_flgconju AS CHAR										   NO-UNDO.
DEF VAR aux_flgpende AS INTE										   NO-UNDO.
DEF VAR aux_qtminast AS INTE										   NO-UNDO.

DEF VAR aux_flgerlog AS LOGI INIT TRUE                                 NO-UNDO.

{ sistema/generico/includes/b1wgen0058tt.i }
{ sistema/generico/includes/b1wgen0072tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }

/*...........................................................................*/

PROCEDURE valores_entrada:

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
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "nrdctato" THEN aux_nrdctato = INTE(tt-param.valorCampo).
            WHEN "nrcpfcgc" THEN aux_nrcpfcgc = tt-param.valorCampo.
            WHEN "nmdavali" THEN aux_nmdavali = tt-param.valorCampo.
            WHEN "tpdocava" THEN aux_tpdocava = tt-param.valorCampo.
            WHEN "nrdocava" THEN aux_nrdocava = tt-param.valorCampo.
            WHEN "cdoeddoc" THEN aux_cdoeddoc = tt-param.valorCampo.
            WHEN "cdufddoc" THEN aux_cdufddoc = tt-param.valorCampo.
            WHEN "dtemddoc" THEN aux_dtemddoc = DATE(tt-param.valorCampo).
            WHEN "dtnascto" THEN aux_dtnascto = DATE(tt-param.valorCampo).
            WHEN "cdsexcto" THEN aux_cdsexcto = tt-param.valorCampo.
            WHEN "cdestcvl" THEN aux_cdestcvl = INTE(tt-param.valorCampo).
            WHEN "dsestcvl" THEN aux_dsestcvl = tt-param.valorCampo.
            WHEN "cdnacion" THEN aux_cdnacion = INTE(tt-param.valorCampo).
            WHEN "dsnatura" THEN aux_dsnatura = tt-param.valorCampo.
            WHEN "nrcepend" THEN aux_nrcepend = INTE(tt-param.valorCampo).
            WHEN "dsendres" THEN aux_dsendres = tt-param.valorCampo.
            WHEN "nrendere" THEN aux_nrendere = INTE(tt-param.valorCampo).
            WHEN "complend" THEN aux_complend = tt-param.valorCampo.
            WHEN "nmbairro" THEN aux_nmbairro = tt-param.valorCampo.
            WHEN "nmcidade" THEN aux_nmcidade = tt-param.valorCampo.
            WHEN "cdufresd" THEN aux_cdufresd = tt-param.valorCampo.
            WHEN "nrcxapst" THEN aux_nrcxapst = INTE(tt-param.valorCampo).
            WHEN "nmmaecto" THEN aux_nmmaecto = tt-param.valorCampo.
            WHEN "nmpaicto" THEN aux_nmpaicto = tt-param.valorCampo.
            WHEN "vledvmto" THEN aux_vledvmto = DECI(tt-param.valorCampo).
            WHEN "dsrelbem" THEN aux_dsrelbem = tt-param.valorCampo.
            WHEN "dtvalida" OR WHEN "dsvalida" THEN 
                aux_dtvalida = DATE(tt-param.valorCampo).
            WHEN "dsproftl" THEN aux_dsproftl = tt-param.valorCampo.
            WHEN "dtadmsoc" THEN aux_dtadmsoc = DATE(tt-param.valorCampo).
            WHEN "cdsequen" THEN aux_cdsequen = INTE(tt-param.valorCampo).
            WHEN "nrdrowid" THEN aux_nrdrowid = TO-ROWID(tt-param.valorCampo).

            WHEN "persocio" THEN aux_persocio = DECI(tt-param.valorCampo).
            WHEN "flgdepec" THEN aux_flgdepec = IF (tt-param.valorCampo = "SIM" OR 
                                                    tt-param.valorCampo = "yes" OR
                                                    tt-param.valorCampo = "true")
                                                THEN TRUE
                                                ELSE FALSE.
            WHEN "vloutren" THEN aux_vloutren = DECI(tt-param.valorCampo).
            WHEN "dsoutren" THEN aux_dsoutren = tt-param.valorCampo.
            WHEN "nmrotina" THEN aux_nmrotina = tt-param.valorCampo.
            WHEN "inhabmen" THEN aux_inhabmen = INT(tt-param.valorCampo).
            WHEN "dthabmen" THEN aux_dthabmen = DATE(tt-param.valorCampo).
            WHEN "verrespo" THEN aux_verrespo = LOGICAL(tt-param.valorCampo).
            WHEN "permalte" THEN aux_permalte = LOGICAL(tt-param.valorCampo).
            WHEN "tpctrato" THEN aux_tpctrato = INT(tt-param.valorCampo).
            WHEN "nrdctpro" THEN aux_nrdctpro = INT(tt-param.valorCampo).
            WHEN "cpfprocu" THEN aux_cpfprocu = DEC(tt-param.valorCampo).
            WHEN "cddpoder" THEN aux_cddpoder = INT(tt-param.valorCampo).
            WHEN "dscpfcgc" THEN aux_dscpfcgc = tt-param.valorCampo.
            WHEN "responsa" THEN aux_responsa = tt-param.valorCampo.
            WHEN "flgerlog" THEN aux_flgerlog = LOGICAL(tt-param.valorCampo).
			WHEN "flgconju" THEN aux_flgconju = tt-param.valorCampo.
			WHEN "qtminast" THEN aux_qtminast = INT(tt-param.valorCampo).
       END CASE.

    END. /** Fim do FOR EACH tt-param **/
	
    FOR EACH tt-param-i 
        BREAK BY tt-param-i.nomeTabela
              BY tt-param-i.sqControle:

        CASE tt-param-i.nomeTabela:

            WHEN "Procurador" THEN DO:

                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:
                       CREATE tt-crapavt.
                       ASSIGN aux_rowidavt = ROWID(tt-crapavt).
                    END.

                FIND tt-crapavt WHERE ROWID(tt-crapavt) = aux_rowidavt
                                      NO-ERROR.

                CASE tt-param-i.nomeCampo:
                    WHEN "nrdctato" THEN
                         tt-crapavt.nrdctato = INTE(REPLACE(tt-param-i.valorCamp,"-","")).
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
                    WHEN "cdnacion" THEN
                         tt-crapavt.cdnacion = INT(tt-param-i.valorCampo).
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
        END CASE.
    END.

    FOR EACH tt-param-i BREAK BY tt-param-i.nomeTabela
                               BY tt-param-i.sqControle:
        
      CASE tt-param-i.nomeTabela:

            WHEN "RespLegal" THEN DO:
                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:
                       CREATE tt-resp.
                       ASSIGN aux_rowidrsp = ROWID(tt-resp).
                    END.

                FIND tt-resp WHERE 
                     ROWID(tt-resp) = aux_rowidrsp NO-ERROR.

                CASE tt-param-i.nomeCampo:
                                            
                    WHEN "cddctato" THEN
                        ASSIGN tt-resp.cddctato = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrdrowid" THEN
                        ASSIGN tt-resp.nrdrowid = 
                          TO-ROWID(tt-param-i.valorCampo).
                    WHEN "cdcooper" THEN
                        ASSIGN tt-resp.cdcooper = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrctamen" THEN
                        ASSIGN tt-resp.nrctamen = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrcpfmen" THEN
                        ASSIGN tt-resp.nrcpfmen = 
                            DEC(tt-param-i.valorCampo).
                    WHEN "idseqmen" THEN
                        ASSIGN tt-resp.idseqmen = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrdconta" THEN
                        ASSIGN tt-resp.nrdconta = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrcpfcgc" THEN
                        ASSIGN tt-resp.nrcpfcgc = 
                            DEC(tt-param-i.valorCampo).
                    WHEN "nmrespon" THEN
                        ASSIGN tt-resp.nmrespon = 
                            tt-param-i.valorCampo.
                    WHEN "nridenti" THEN
                        ASSIGN tt-resp.nridenti = 
                            tt-param-i.valorCampo.
                    WHEN "tpdeiden" THEN
                        ASSIGN tt-resp.tpdeiden = 
                            tt-param-i.valorCampo.
                    WHEN "dsorgemi" THEN
                        ASSIGN tt-resp.dsorgemi = 
                            tt-param-i.valorCampo.
                    WHEN "cdufiden" THEN
                        ASSIGN tt-resp.cdufiden = 
                            tt-param-i.valorCampo.
                    WHEN "dtemiden" THEN
                        ASSIGN tt-resp.dtemiden = 
                            DATE(tt-param-i.valorCampo).
                    WHEN "dtnascin" THEN
                        ASSIGN tt-resp.dtnascin = 
                            DATE(tt-param-i.valorCampo).
                    WHEN "cddosexo" THEN
                        ASSIGN tt-resp.cddosexo = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "cdestciv" THEN
                        ASSIGN tt-resp.cdestciv = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "cdnacion" THEN
                        ASSIGN tt-resp.cdnacion = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "dsnatura" THEN
                        ASSIGN tt-resp.dsnatura = 
                            tt-param-i.valorCampo.
                    WHEN "cdcepres" THEN
                        ASSIGN tt-resp.cdcepres = 
                            DEC(tt-param-i.valorCampo).
                    WHEN "dsendres" THEN
                        ASSIGN tt-resp.dsendres = 
                            tt-param-i.valorCampo.
                    WHEN "nrendres" THEN
                        ASSIGN tt-resp.nrendres = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "dscomres" THEN
                        ASSIGN tt-resp.dscomres = 
                            tt-param-i.valorCampo.
                    WHEN "dsbaires" THEN
                        ASSIGN tt-resp.dsbaires = 
                            tt-param-i.valorCampo.
                    WHEN "nrcxpost" THEN
                        ASSIGN tt-resp.nrcxpost = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "dscidres" THEN
                        ASSIGN tt-resp.dscidres = 
                            tt-param-i.valorCampo.
                    WHEN "dsdufres" THEN
                        ASSIGN tt-resp.dsdufres = 
                            tt-param-i.valorCampo.
                    WHEN "nmpairsp" THEN
                        ASSIGN tt-resp.nmpairsp = 
                            tt-param-i.valorCampo.
                    WHEN "nmmaersp" THEN
                        ASSIGN tt-resp.nmmaersp = 
                            tt-param-i.valorCampo.
                    WHEN "cddopcao" THEN
                        ASSIGN tt-resp.cddopcao = 
                            tt-param-i.valorCampo.
                    WHEN "deletado" THEN
                        ASSIGN tt-resp.deletado = 
                            LOGICAL(tt-param-i.valorCampo). 
                                                          
                END CASE. /* CASE tt-param-i.nomeCampo */ 

            END. /* "resp Legal"  */

        END CASE. /* CASE tt-param-i.nomeTabela: */
                         
    END.
    
    FOR EACH tt-param-i 
        BREAK BY tt-param-i.nomeTabela
              BY tt-param-i.sqControle:
        
        CASE tt-param-i.nomeTabela:

            WHEN "Poderes" THEN DO:
                
                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:
                       CREATE tt-crappod.
                       ASSIGN aux_rowidpod = ROWID(tt-crappod).
                    END.

                FIND tt-crappod WHERE ROWID(tt-crappod) = aux_rowidpod
                                      NO-ERROR.
                
                CASE tt-param-i.nomeCampo:
                    WHEN "cdcooper" THEN
                         tt-crappod.cdcooper = INTE(tt-param-i.valorCampo).
                    WHEN "nrdctpro" THEN
                         tt-crappod.nrctapro = INTE(tt-param-i.valorCampo).
                    WHEN "cpfprocu" THEN
                         tt-crappod.nrcpfpro = DEC(tt-param-i.valorCampo).
                    WHEN "cddpoder" THEN
                         tt-crappod.cddpoder = INTE(tt-param-i.valorCampo).
                    WHEN "flgconju" THEN
                         tt-crappod.flgconju = LOGICAL(tt-param-i.valorCampo).
                    WHEN "flgisola" THEN
                         tt-crappod.flgisola = LOGICAL(tt-param-i.valorCampo).
                    WHEN "dsoutpod" THEN
                         tt-crappod.dsoutpod = tt-param-i.valorCampo.
                    WHEN "nrdconta" THEN
                         tt-crappod.nrdconta = INTE(tt-param-i.valorCampo).
                END CASE.
            END.
        END CASE.
    END.
    /* FIm Poderes*/

    ASSIGN aux_seqdobem = 1.

    FOR EACH tt-param-i 
        BREAK BY tt-param-i.nomeTabela
              BY tt-param-i.sqControle:

        CASE tt-param-i.nomeTabela:

            WHEN "Bens" THEN DO:

                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:
                       CREATE tt-bens.
                       ASSIGN 
                           tt-bens.cdsequen = aux_seqdobem
                           aux_rowidbem     = ROWID(tt-bens)
                           aux_seqdobem     = tt-bens.cdsequen + 1.
                    END.

                FIND tt-bens WHERE ROWID(tt-bens) = aux_rowidbem NO-ERROR.

                CASE tt-param-i.nomeCampo:
                    WHEN "dsrelbem" THEN
                        tt-bens.dsrelbem = tt-param-i.valorCampo.
                    WHEN "persemon" THEN
                        tt-bens.persemon = DECI(tt-param-i.valorCampo).
                    WHEN "qtprebem" THEN
                        tt-bens.qtprebem = INTE(tt-param-i.valorCampo).
                    WHEN "vlprebem" THEN
                        tt-bens.vlprebem = DECI(tt-param-i.valorCampo).
                    WHEN "vlrdobem" THEN
                        tt-bens.vlrdobem = DECI(tt-param-i.valorCampo).
                    WHEN "nrdrowid" THEN
                        tt-bens.nrdrowid = TO-ROWID(tt-param-i.valorCampo).
                    WHEN "cpfdoben" THEN
                        tt-bens.cpfdoben = tt-param-i.valorCampo.
                    WHEN "deletado" THEN
                        tt-bens.deletado = LOGICAL(tt-param-i.valorCampo).
                    WHEN "cddopcao" THEN
                        tt-bens.cddopcao = tt-param-i.valorCampo.


                END CASE.
            END.
        END CASE.
    END.

END PROCEDURE.    

PROCEDURE busca_dados:
    
    RUN Busca_Dados IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrdconta,
                            INPUT aux_idseqttl,
                            INPUT aux_flgerlog,
                            INPUT aux_cddopcao,
                            INPUT aux_nrdctato,
                            INPUT aux_nrcpfcgc,
                            INPUT aux_nrdrowid,
                            OUTPUT TABLE tt-crapavt,
                            OUTPUT TABLE tt-bens,
							OUTPUT aux_qtminast,
                            OUTPUT TABLE tt-erro) NO-ERROR.

    IF ERROR-STATUS:ERROR THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
           IF NOT AVAILABLE tt-erro  THEN
              CREATE tt-erro.
                   
           ASSIGN tt-erro.dscritic = tt-erro.dscritic + " - " + 
                                     ERROR-STATUS:GET-MESSAGE(1).
    
           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").

           RETURN.
       END.

    IF RETURN-VALUE = "NOK" THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF NOT AVAILABLE tt-erro  THEN
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
		   RUN piXmlExport(INPUT TEMP-TABLE tt-crapavt:HANDLE,
                           INPUT "Procurador").
		   RUN piXmlAtributo(INPUT "qtminast", INPUT aux_qtminast).
           RUN piXmlSave.

       END.

END.

PROCEDURE busca_dados_bens:

    RUN Busca_Dados_Bens IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nmdatela,
                                 INPUT aux_idorigem,
                                 INPUT aux_nrdconta,
                                 INPUT aux_idseqttl,
                                 INPUT aux_cdsequen,
                                 INPUT YES,
                                 INPUT aux_nrdctato,
                                 INPUT aux_nrcpfcgc,
                                OUTPUT TABLE tt-bens,
                                OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  NOT AVAILABLE tt-erro  THEN
                CREATE tt-erro.
                    
            ASSIGN tt-erro.dscritic = tt-erro.dscritic + " - " + 
                                      ERROR-STATUS:GET-MESSAGE(1).
    
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
            RUN piXmlExport(INPUT TEMP-TABLE tt-bens:HANDLE,
                            INPUT "Bens").
            RUN piXmlSave.
        END.

END.

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
                            INPUT aux_dtmvtolt,
                            INPUT aux_cddopcao,
                            INPUT aux_nrdctato,
                            INPUT aux_nrcpfcgc,
                            INPUT aux_nmdavali,
                            INPUT aux_tpdocava,
                            INPUT aux_nrdocava,
                            INPUT aux_cdoeddoc,
                            INPUT aux_cdufddoc,
                            INPUT aux_dtemddoc,
                            INPUT aux_dtnascto,
                            INPUT aux_cdsexcto,
                            INPUT aux_cdestcvl,
                            INPUT aux_cdnacion,
                            INPUT aux_dsnatura,
                            INPUT aux_nrcepend,
                            INPUT aux_dsendres,
                            INPUT aux_nrendere,
                            INPUT aux_complend,
                            INPUT aux_nmbairro,
                            INPUT aux_nmcidade,
                            INPUT aux_cdufresd,
                            INPUT aux_nrcxapst,
                            INPUT aux_nmmaecto,
                            INPUT aux_nmpaicto,
                            INPUT aux_vledvmto,
                            INPUT aux_dsrelbem,
                            INPUT aux_dtvalida,
                            INPUT aux_dsproftl,
                            INPUT aux_dtadmsoc,
                            INPUT aux_persocio,
                            INPUT aux_flgdepec,
                            INPUT aux_vloutren,
                            INPUT aux_dsoutren,
                            INPUT aux_inhabmen,
                            INPUT aux_dthabmen,
                            INPUT aux_nmrotina,
                            INPUT TABLE tt-bens,
                            INPUT TABLE tt-resp,
                           OUTPUT aux_msgalert,
                           OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  NOT AVAILABLE tt-erro  THEN
                CREATE tt-erro.
                    
            ASSIGN tt-erro.dscritic = tt-erro.dscritic + " - " + 
                                      ERROR-STATUS:GET-MESSAGE(1).
    
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
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "msgalert", INPUT TRIM(aux_msgalert)).
            RUN piXmlSave.
        END.
END.

PROCEDURE Grava_Bens:

    RUN Grava_Bens IN hBO (INPUT aux_cdcooper,
                           INPUT aux_nrdconta,
                           INPUT aux_idseqttl,
                           INPUT DEC(aux_nrcpfcgc),
                           INPUT TABLE tt-bens,
                          OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  NOT AVAILABLE tt-erro  THEN
                CREATE tt-erro.
                    
            ASSIGN tt-erro.dscritic = tt-erro.dscritic + " - " + 
                                      ERROR-STATUS:GET-MESSAGE(1).
    
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
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "msgalert", INPUT TRIM(aux_msgalert)).
           RUN piXmlSave.
        END.
END.

PROCEDURE Exclui_Dados:

    RUN Exclui_Dados IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_nrdconta,
                             INPUT aux_idseqttl,
                             INPUT YES,
                             INPUT aux_nrcpfcgc,
                            OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  NOT AVAILABLE tt-erro  THEN
                CREATE tt-erro.
                    
            ASSIGN tt-erro.dscritic = tt-erro.dscritic + " - " + 
                                      ERROR-STATUS:GET-MESSAGE(1).
    
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
END.

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
                             INPUT aux_dtmvtolt,
                             INPUT aux_cddopcao,
                             INPUT aux_nrdctato,
                             INPUT aux_nrcpfcgc,
                             INPUT aux_nmdavali,
                             INPUT aux_tpdocava,
                             INPUT aux_nrdocava,
                             INPUT aux_cdoeddoc,
                             INPUT aux_cdufddoc,
                             INPUT aux_dtemddoc,
                             INPUT aux_dtnascto,
                             INPUT aux_cdsexcto,
                             INPUT aux_cdestcvl,
                             INPUT aux_cdnacion,
                             INPUT aux_dsnatura,
                             INPUT aux_nrcepend,
                             INPUT aux_dsendres,
                             INPUT aux_nrendere,
                             INPUT aux_complend,
                             INPUT aux_nmbairro,
                             INPUT aux_nmcidade,
                             INPUT aux_cdufresd,
                             INPUT aux_nrcxapst,
                             INPUT aux_nmmaecto,
                             INPUT aux_nmpaicto,
                             INPUT aux_vledvmto,
                             INPUT aux_dsrelbem,
                             INPUT aux_dtvalida,
                             INPUT aux_dsproftl,
                             INPUT aux_dtadmsoc,
                             INPUT aux_persocio,
                             INPUT aux_flgdepec,
                             INPUT aux_vloutren,
                             INPUT aux_dsoutren,
                             INPUT aux_inhabmen,
                             INPUT aux_dthabmen,
                             INPUT aux_nmrotina,
                             INPUT aux_verrespo,
                             INPUT aux_permalte,
                             INPUT TABLE tt-bens,
                             INPUT TABLE tt-resp,
                             INPUT TABLE tt-crapavt,
                            OUTPUT aux_msgalert,
                            OUTPUT TABLE tt-erro,
                            OUTPUT aux_nrdeanos,
                            OUTPUT aux_nrdmeses,
                            OUTPUT aux_dsdidade) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO: 
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  NOT AVAILABLE tt-erro  THEN
                CREATE tt-erro.
                    
            ASSIGN tt-erro.dscritic = tt-erro.dscritic + " - " + 
                                      ERROR-STATUS:GET-MESSAGE(1).
    
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
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "msgalert", INPUT TRIM(aux_msgalert)).
           RUN piXmlAtributo (INPUT "nrdeanos", INPUT aux_nrdeanos).
           RUN piXmlAtributo (INPUT "nrdmeses", INPUT aux_nrdmeses).
           RUN piXmlAtributo (INPUT "dsdidade", INPUT aux_dsdidade).
           RUN piXmlSave.
        END.


END PROCEDURE.

PROCEDURE busca_perc_socio:

    RUN busca_perc_socio IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_dsproftl,
                                 INPUT aux_persocio,
                                OUTPUT opt_persocio,
                                OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  NOT AVAILABLE tt-erro  THEN
                CREATE tt-erro.
                    
            ASSIGN tt-erro.dscritic = tt-erro.dscritic + " - " + 
                                      ERROR-STATUS:GET-MESSAGE(1).
    
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
                                             "busca do percentual societario.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "persocio", INPUT opt_persocio).
            RUN piXmlSave.
        END.


END PROCEDURE.

PROCEDURE busca_dados_poderes:

    RUN Busca_Dados_Poderes IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_tpctrato,
                                    INPUT aux_nrdconta,
                                    INPUT aux_nrdctpro,
                                    INPUT aux_cpfprocu,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_nmdatela,
                                    INPUT aux_idorigem,
                                    INPUT DATE(aux_dtmvtolt),
                                    INPUT aux_idseqttl,
                                    OUTPUT aux_inpessoa,
                                    OUTPUT aux_idastcjt,
                                    OUTPUT TABLE tt-crappod,
                                    OUTPUT TABLE tt-erro) NO-ERROR.

    IF ERROR-STATUS:ERROR THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
           IF NOT AVAILABLE tt-erro  THEN
              CREATE tt-erro.
                   
           ASSIGN tt-erro.dscritic = tt-erro.dscritic + " - " + 
                                     ERROR-STATUS:GET-MESSAGE(1).
    
           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").

           RETURN.
       END.

    IF RETURN-VALUE = "NOK" THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF NOT AVAILABLE tt-erro  THEN
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
           RUN piXmlAtributo (INPUT "inpessoa", INPUT aux_inpessoa).
           RUN piXmlAtributo (INPUT "idastcjt", INPUT aux_idastcjt).
           RUN piXmlExport(INPUT TEMP-TABLE tt-crappod:HANDLE,
                           INPUT "Poderes").
           RUN piXmlSave.

       END.

END PROCEDURE.

PROCEDURE lista_poderes:
    
    DYNAMIC-FUNCTION("ListaPoderes" IN hBO, OUTPUT aux_lstpoder).
    
    RUN piXmlNew.
    RUN piXmlAtributo (INPUT "lstpoder", INPUT aux_lstpoder).
    RUN piXmlSave.
END PROCEDURE.

PROCEDURE grava_dados_poderes:
    
    RUN Grava_Dados_Poderes IN hBO (INPUT aux_cdcooper,
                                INPUT aux_nrdctpro,
                                INPUT aux_nrdconta,
                                INPUT aux_cpfprocu,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT aux_dtmvtolt,
                                INPUT aux_idseqttl,
                                INPUT TABLE tt-crappod,
                                OUTPUT TABLE tt-crappod,
                                OUTPUT TABLE tt-erro) NO-ERROR.
            
    IF  RETURN-VALUE = "NOK" THEN
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
           RUN piXmlExport(INPUT TEMP-TABLE tt-crappod:HANDLE,
                           INPUT "Poderes").
           RUN piXmlSave.

       END.
END PROCEDURE.


PROCEDURE valida_responsaveis:

    RUN valida_responsaveis IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_nmdatela,
                                    INPUT aux_idorigem,
                                    INPUT aux_cdagenci,
                                    INPUT aux_dtmvtolt,
                                    INPUT aux_nrdconta,
                                    INPUT aux_dscpfcgc,
									INPUT aux_flgconju,
									INPUT aux_qtminast,
								   OUTPUT aux_flgpende,	
                                   OUTPUT TABLE tt-erro).
							   
    IF  RETURN-VALUE = "NOK" THEN
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
		    RUN piXmlAtributo (INPUT "flgpende", INPUT STRING(aux_flgpende)).
            RUN piXmlAtributo (INPUT "OK", INPUT "OK").
            RUN piXmlSave.
        END.
   
END PROCEDURE.

PROCEDURE grava_resp_ass_conjunta:
    
    RUN grava_resp_ass_conjunta IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nmdatela,
                                        INPUT aux_idorigem,
                                        INPUT aux_cdagenci,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_nrdconta,
                                        INPUT aux_idseqttl,
                                        INPUT aux_responsa,
										INPUT aux_qtminast,
                                       OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK" THEN
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
            RUN piXmlAtributo (INPUT "OK", INPUT "OK").
            RUN piXmlSave.
        END.
   
END PROCEDURE.
