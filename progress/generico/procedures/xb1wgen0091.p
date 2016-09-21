/*..............................................................................

   Programa: b1wgen0091.p                  
   Autora  : André - DB1
   Data    : 17/05/2011                        Ultima atualizacao: 23/03/2015
    
   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : BO - Alteracao de Domicilio Bancario (b1wgen0091.p)

   Alteracoes: 20/05/2013 - Criado as procedures:
                            - solicita_consulta_beneficiario
                            - solicita_alteracao_cadastral_beneficiario
                            - solicita_troca_op_conta_corrente
                            - solicita_troca_op_conta_corrente_entre_coop
                            - solicita_comprovacao_vida
                            - solicita_demonstrativo
                            - solicita_relatorio_beneficios_pagos
                            - solicita_relatorio_beneficios_pagar
                            - relatorio_beneficios_rejeitados
                            - solicita_troca_domicilio
                            - busca_crapttl
                            - busca_cdorgins
                            - busca_crapdbi
                            (Adriano).
                            
               23/03/2015 - Decorrente a conversao das rotinas INSS - SICREDI
                            para PLSQL, foram removidas as procedures:
                            - solicita_alteracao_cadastral_beneficiario
                            - solicita_troca_op_conta_corrente_entre_coop     
                            - solicita_comprovacao_vida   
                            - solicita_demonstrativo                
                            - solicita_relatorio_beneficios_pagos
                            - relatorio_beneficios_rejeitados
                            - solicita_troca_domicilio
                            - busca_crapttl
                            - busca_cdorgins
                            - gera_arquivo_demonstrativo
                            - solicita_troca_op_conta_corrente
                            - solicita_consulta_beneficiario
                            (Adriano).
                            
..............................................................................*/

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nmrotina AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.

DEF VAR aux_cdagebcb AS INTE                                           NO-UNDO.
DEF VAR aux_dstextab AS CHAR                                           NO-UNDO.
DEF VAR aux_nrbenefi AS DECI                                           NO-UNDO.
DEF VAR aux_nrctacre AS INTE                                           NO-UNDO.
DEF VAR aux_cdorgpag AS INTE                                           NO-UNDO.
DEF VAR aux_nrrecben AS DECI                                           NO-UNDO.
DEF VAR aux_nmrecben AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdircop AS CHAR                                           NO-UNDO.
DEF VAR aux_nmextttl AS CHAR                                           NO-UNDO.
DEF VAR aux_nmoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmcidade AS CHAR                                           NO-UNDO.
DEF VAR aux_nmextcop AS CHAR                                           NO-UNDO.
DEF VAR aux_nmrescop AS CHAR                                           NO-UNDO.
DEF VAR aux_tpregist AS INTE                                           NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR aux_nrnovcta AS INTE                                           NO-UNDO.
DEF VAR aux_cdagcpac AS INTE                                           NO-UNDO.

DEF VAR aux_cdcoopbs AS INTE                                           NO-UNDO.
DEF VAR aux_tpnovmpg AS INTE                                           NO-UNDO.
DEF VAR aux_nmsistem AS CHAR                                           NO-UNDO.
DEF VAR aux_tptabela AS CHAR                                           NO-UNDO.
DEF VAR aux_cdempres AS INTE                                           NO-UNDO.
DEF VAR aux_cdacesso AS CHAR                                           NO-UNDO.
DEF VAR aux_cdaltera AS INTE                                           NO-UNDO.
DEF VAR aux_cdaltcad AS INTE                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_dsnovmpg AS CHAR                                           NO-UNDO.
DEF VAR aux_msgretor AS CHAR                                           NO-UNDO.
DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.
DEF VAR aux_dtdpagto AS DATE                                           NO-UNDO.
DEF VAR aux_dtinipag AS DATE                                           NO-UNDO.
DEF VAR aux_cdageins AS INTE                                           NO-UNDO.
DEF VAR aux_nrcpfcgc AS DECI                                           NO-UNDO.
DEF VAR aux_nrprocur AS DECI                                           NO-UNDO.
DEF VAR aux_cdrelato AS INTE                                           NO-UNDO.
DEF VAR aux_dtdinici AS DATE                                           NO-UNDO.
DEF VAR aux_dtdfinal AS DATE                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.


DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_tpnrbene AS CHAR                                           NO-UNDO.
DEF VAR aux_tpdpagto AS CHAR                                           NO-UNDO.
DEF VAR aux_dscsitua AS CHAR                                           NO-UNDO.
DEF VAR aux_idbenefi AS INT                                            NO-UNDO.
DEF VAR aux_nmbairro AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcepend AS INT                                            NO-UNDO.
DEF VAR aux_dsendere AS CHAR                                           NO-UNDO.
DEF VAR aux_cdufende AS CHAR                                           NO-UNDO.
DEF VAR aux_cdagepac AS INT                                            NO-UNDO.
DEF VAR aux_cdagesic AS INT                                            NO-UNDO.
DEF VAR aux_nmbenefi AS CHAR                                           NO-UNDO.
DEF VAR aux_dsendres AS CHAR                                           NO-UNDO.
DEF VAR aux_cdufdttl AS CHAR                                           NO-UNDO.
DEF VAR aux_respreno AS CHAR                                           NO-UNDO.
DEF VAR aux_dtvalida AS CHAR                                           NO-UNDO.
DEF VAR aux_cdagesel AS INT                                            NO-UNDO.
DEF VAR aux_dtinirec AS DATE                                           NO-UNDO.
DEF VAR aux_dtfinrec AS DATE                                           NO-UNDO.
DEF VAR aux_tpconrel AS CHAR                                           NO-UNDO.
DEF VAR aux_flgerlog AS LOGICAL                                        NO-UNDO.
DEF VAR aux_nrctaant AS INT                                            NO-UNDO.
DEF VAR aux_orgpgant AS INT                                            NO-UNDO.
DEF VAR aux_dtcompvi AS DATE                                           NO-UNDO.
DEF VAR aux_nrdddtfc AS INT                                            NO-UNDO.
DEF VAR aux_nrtelefo AS INT                                            NO-UNDO.
DEF VAR aux_opdemons AS INT                                            NO-UNDO.
DEF VAR aux_cpfdemon AS DEC                                            NO-UNDO.
DEF VAR aux_nmmaettl AS CHAR                                           NO-UNDO.
DEF VAR aux_dtnasttl AS DATE                                           NO-UNDO.
DEF VAR aux_cdsexotl AS INT                                            NO-UNDO.
DEF VAR aux_tpdosexo AS CHAR                                           NO-UNDO.
DEF VAR aux_nomdamae AS CHAR                                           NO-UNDO.
DEF VAR aux_cdcopant AS INT                                            NO-UNDO.
DEF VAR aux_tpbenefi AS CHAR                                           NO-UNDO.
DEF VAR aux_cdorgins AS INTE                                           NO-UNDO.
DEF VAR aux_nrcpfant AS DEC                                            NO-UNDO.
DEF VAR aux_nmprocur AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdocpro AS CHAR                                           NO-UNDO.
DEF VAR aux_dtvalprc AS DATE                                           NO-UNDO.
DEF VAR aux_nrendere AS INT                                            NO-UNDO.

{ sistema/generico/includes/b1wgen0091tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }


/*................................ PROCEDURES ...............................*/


/*****************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML    **/
/*****************************************************************************/
PROCEDURE valores_entrada:

    FOR EACH tt-param:
        
        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "nmrotina" THEN aux_nmrotina = tt-param.valorCampo.
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "cdagebcb" THEN aux_cdagebcb = INTE(tt-param.valorCampo). 
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "dstextab" THEN aux_dstextab = tt-param.valorCampo.
            WHEN "nrbenefi" THEN aux_nrbenefi = DECI(tt-param.valorCampo).
            WHEN "nrctacre" THEN aux_nrctacre = INTE(tt-param.valorCampo). 
            WHEN "cdorgpag" THEN aux_cdorgpag = INTE(tt-param.valorCampo). 
            WHEN "nrrecben" THEN aux_nrrecben = DECI(tt-param.valorCampo).
            WHEN "nmrecben" THEN aux_nmrecben = tt-param.valorCampo.
            WHEN "dsdircop" THEN aux_dsdircop = tt-param.valorCampo.
            WHEN "nmextttl" THEN aux_nmextttl = tt-param.valorCampo.
            WHEN "nmoperad" THEN aux_nmoperad = tt-param.valorCampo.
            WHEN "nmcidade" THEN aux_nmcidade = tt-param.valorCampo.
            WHEN "nmextcop" THEN aux_nmextcop = tt-param.valorCampo.
            WHEN "nmrescop" THEN aux_nmrescop = tt-param.valorCampo.
            WHEN "tpregist" THEN aux_tpregist = INTE(tt-param.valorCampo).
            WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "nrnovcta" THEN aux_nrnovcta = INTE(tt-param.valorCampo).
            WHEN "dstextab" THEN aux_dstextab = tt-param.valorCampo.
            WHEN "cdagcpac" THEN aux_cdagcpac = INTE(tt-param.valorCampo).
            WHEN "cdcoopbs" THEN aux_cdcoopbs = INTE(tt-param.valorCampo).
            WHEN "cdempres" THEN aux_cdempres = INTE(tt-param.valorCampo).
            WHEN "cdaltera" THEN aux_cdaltera = INTE(tt-param.valorCampo).
            WHEN "nmsistem" THEN aux_dstextab = tt-param.valorCampo.
            WHEN "tptabela" THEN aux_dstextab = tt-param.valorCampo.
            WHEN "cdacesso" THEN aux_dstextab = tt-param.valorCampo.
            WHEN "cdaltcad" THEN aux_cdaltcad = INTE(tt-param.valorCampo).
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "dtdpagto" THEN aux_dtdpagto = DATE(tt-param.valorCampo).
            WHEN "dtinipag" THEN aux_dtinipag = DATE(tt-param.valorCampo).
            WHEN "cdageins" THEN aux_cdageins = INTE(tt-param.valorCampo).
            WHEN "nrcpfcgc" THEN aux_nrcpfcgc = DECI(tt-param.valorCampo).
            WHEN "nrprocur" THEN aux_nrprocur = DECI(tt-param.valorCampo).
            WHEN "tpnovmpg" THEN aux_tpnovmpg = INTE(tt-param.valorCampo).
            WHEN "dtdinici" THEN aux_dtdinici = DATE(tt-param.valorCampo).
            WHEN "dtdfinal" THEN aux_dtdfinal = DATE(tt-param.valorCampo).

            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "tpnrbene" THEN aux_tpnrbene = tt-param.valorCampo.
            WHEN "tpdpagto" THEN aux_tpdpagto = tt-param.valorCampo.
            WHEN "dscsitua" THEN aux_dscsitua = tt-param.valorCampo.
            WHEN "idbenefi" THEN aux_idbenefi = INT(tt-param.valorCampo).
            WHEN "nmbairro" THEN aux_nmbairro = tt-param.valorCampo.
            WHEN "nrcepend" THEN aux_nrcepend = INT(tt-param.valorCampo).
            WHEN "dsendere" THEN aux_dsendere = tt-param.valorCampo.
            WHEN "cdufende" THEN aux_cdufende = tt-param.valorCampo.
            WHEN "cdagepac" THEN aux_cdagepac = INT(tt-param.valorCampo).
            WHEN "cdagesic" THEN aux_cdagesic = INT(tt-param.valorCampo).
            WHEN "nmbenefi" THEN aux_nmbenefi = tt-param.valorCampo. 
            WHEN "dsendres" THEN aux_dsendres = tt-param.valorCampo.
            WHEN "cdufdttl" THEN aux_cdufdttl = tt-param.valorCampo.
            WHEN "respreno" THEN aux_respreno = tt-param.valorCampo.
            WHEN "dtvalida" THEN aux_dtvalida = tt-param.valorCampo.
            WHEN "cdagesel" THEN aux_cdagesel = INT(tt-param.valorCampo).
            WHEN "dtinirec" THEN aux_dtinirec = DATE(tt-param.valorCampo).
            WHEN "dtfinrec" THEN aux_dtfinrec = DATE(tt-param.valorCampo).
            WHEN "tpconrel" THEN aux_tpconrel = tt-param.valorCampo.
            WHEN "flgerlog" THEN aux_flgerlog = LOGICAL(tt-param.valorCampo). 
            WHEN "nrctaant" THEN aux_nrctaant = INTE(tt-param.valorCampo).
            WHEN "orgpgant" THEN aux_orgpgant = INTE(tt-param.valorCampo).
            WHEN "dtcompvi" THEN aux_dtcompvi = DATE(tt-param.valorCampo).
            WHEN "nrtelefo" THEN aux_nrtelefo = INTE(tt-param.valorCampo).
            WHEN "nrdddtfc" THEN aux_nrdddtfc = INTE(tt-param.valorCampo).
            WHEN "opdemons" THEN aux_opdemons = INTE(tt-param.valorCampo).
            WHEN "cpfdemon" THEN aux_cpfdemon = DEC(tt-param.valorCampo).
            WHEN "nmmaettl" THEN aux_nmmaettl = tt-param.valorCampo.
            WHEN "cdsexotl" THEN aux_cdsexotl = INT(tt-param.valorCampo).
            WHEN "dtnasttl" THEN aux_dtnasttl = DATE(tt-param.valorCampo).
            WHEN "tpdosexo" THEN aux_tpdosexo = tt-param.valorCampo.
            WHEN "nomdamae" THEN aux_nomdamae = tt-param.valorCampo.
            WHEN "cdcopant" THEN aux_cdcopant = INTE(tt-param.valorCampo).
            WHEN "tpbenefi" THEN aux_tpbenefi = tt-param.valorCampo.
            WHEN "cdorgins" THEN aux_cdorgins = INTE(tt-param.valorCampo).
            WHEN "nrcpfant" THEN aux_nrcpfant = DEC(tt-param.valorCampo).
            WHEN "nmprocur" THEN aux_nmprocur = tt-param.valorCampo.
            WHEN "nrdocpro" THEN aux_nrdocpro = tt-param.valorCampo.
            WHEN "dtvalprc" THEN aux_dtvalprc = DATE(tt-param.valorCampo).
            WHEN "nrendere" THEN aux_nrendere = INT(tt-param.valorCampo).
            

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.

/*****************************************************************************/
/*                            Buscar dados do titular                        */
/*****************************************************************************/
PROCEDURE busca-domins:

    RUN busca-domins IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_nrdconta,
                             INPUT aux_idseqttl,
                             INPUT TRUE, /* LOG */
                            OUTPUT TABLE tt-erro, 
                            OUTPUT TABLE tt-domins).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-domins:HANDLE,
                             INPUT "Dados").
            RUN piXmlSave.
        END.


END PROCEDURE.

/*****************************************************************************/
/*                              Valida NB e NIT                              */
/*****************************************************************************/
PROCEDURE valida-nbnit:

    RUN valida-nbnit IN hBO ( INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad, 
                              INPUT aux_nmdatela, 
                              INPUT aux_idorigem, 
                              INPUT aux_nrdconta, 
                              INPUT aux_idseqttl, 
                              INPUT TRUE, 
                              INPUT aux_tpregist,
                              INPUT aux_nrbenefi,
                              INPUT aux_nrrecben,
                             OUTPUT aux_nmdcampo,
                             OUTPUT TABLE tt-erro ).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport   (INPUT TEMP-TABLE tt-erro:HANDLE,
                               INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.


END PROCEDURE.

/*****************************************************************************/
/*                      Gera impressao da autorizacao                        */
/*****************************************************************************/
PROCEDURE gera-impressao:

    RUN gera-impressao IN hBO ( INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad, 
                                INPUT aux_nmdatela, 
                                INPUT aux_idorigem, 
                                INPUT aux_nrdconta, 
                                INPUT aux_idseqttl, 
                                INPUT TRUE, 
                                INPUT aux_cdagebcb, 
                                INPUT aux_dtmvtolt, 
                                INPUT aux_nrbenefi, 
                                INPUT aux_nrctacre, 
                                INPUT aux_cdorgpag, 
                                INPUT aux_nrrecben, 
                                INPUT aux_nmrecben, 
                                INPUT aux_dsdircop, 
                                INPUT aux_nmextttl, 
                                INPUT aux_nmoperad, 
                                INPUT aux_nmcidade, 
                                INPUT aux_nmextcop, 
                                INPUT aux_nmrescop,
                                INPUT aux_dsiduser,
                               OUTPUT aux_nmarqimp,
                               OUTPUT aux_nmarqpdf,
                               OUTPUT TABLE tt-erro ).

    IF RETURN-VALUE = "NOK" THEN
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
            RUN piXmlAtributo (INPUT "nmarqimp",INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.


END PROCEDURE.

/*****************************************************************************/
/*                         Trata opcao de alteracao                          */
/*****************************************************************************/
PROCEDURE trata-opcao:

    RUN trata-opcao IN hBO ( INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad, 
                             INPUT aux_nmdatela, 
                             INPUT aux_idorigem, 
                             INPUT aux_nrdconta, 
                             INPUT aux_idseqttl, 
                             INPUT TRUE, 
                             INPUT aux_dtmvtolt, 
                             INPUT aux_nrrecben, 
                             INPUT aux_nmrecben, 
                             INPUT aux_nrbenefi,
                             INPUT aux_nrnovcta,
                             INPUT aux_cdaltera, 
                             INPUT aux_dsiduser, 
                             INPUT aux_cdaltcad, 
                            OUTPUT aux_nmarqimp,
                            OUTPUT aux_nmarqpdf,
                            OUTPUT TABLE tt-erro ).

    IF RETURN-VALUE = "NOK" THEN
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
            RUN piXmlAtributo (INPUT "nmarqimp",INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.


END PROCEDURE.

/*****************************************************************************/
/*                         Valida opcao de alteracao                         */
/*****************************************************************************/
PROCEDURE valida-opcao:

    RUN valida-opcao IN hBO ( INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad, 
                              INPUT aux_nmdatela, 
                              INPUT aux_idorigem, 
                              INPUT aux_nrdconta, 
                              INPUT aux_idseqttl, 
                              INPUT TRUE, 
                              INPUT aux_dtmvtolt, 
                              INPUT aux_nrrecben, 
                              INPUT aux_nrbenefi,
                              INPUT aux_cdaltera, 
                             OUTPUT aux_nmprimtl,
                             OUTPUT aux_dsnovmpg,
                             OUTPUT aux_nrnovcta,
                             OUTPUT aux_tpnovmpg,
                             OUTPUT aux_msgretor,
                             OUTPUT aux_dstextab,
                             OUTPUT aux_nmdcampo,
                             OUTPUT TABLE tt-erro ).

    IF RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport   (INPUT TEMP-TABLE tt-erro:HANDLE,
                               INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmprimtl",INPUT STRING(aux_nmprimtl)).
            RUN piXmlAtributo (INPUT "dsnovmpg",INPUT STRING(aux_dsnovmpg)).
            RUN piXmlAtributo (INPUT "nrnovcta",INPUT STRING(aux_nrnovcta)).
            RUN piXmlAtributo (INPUT "tpnovmpg",INPUT STRING(aux_tpnovmpg)).
            RUN piXmlAtributo (INPUT "msgretor",INPUT STRING(aux_msgretor)).
            RUN piXmlAtributo (INPUT "dstextab",INPUT STRING(aux_dstextab)).
            RUN piXmlSave.
        END.


END PROCEDURE.


/*****************************************************************************/
/*                             Gera Log Cadins                               */
/*****************************************************************************/
PROCEDURE gera_log_cdns:

    RUN gera_log_cdns IN hBO ( INPUT aux_dtmvtolt,
                               INPUT aux_cdoperad,
                               INPUT aux_nrnovcta,
                               INPUT aux_cdoperad, 
                               INPUT aux_nmrecben, 
                               INPUT aux_nrbenefi, 
                               INPUT aux_nrrecben, 
                               INPUT aux_dstextab ).

    IF RETURN-VALUE = "NOK" THEN
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

/*****************************************************************************/
/*                         Valida opcao de alteracao                         */
/*****************************************************************************/
PROCEDURE busca-benefic:

    RUN busca-benefic IN hBO ( INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_nmrecben, 
                               INPUT aux_cdagcpac,
                               INPUT aux_nrregist,
                               INPUT aux_nriniseq,
                              OUTPUT aux_qtregist,
                              OUTPUT TABLE tt-erro,
                              OUTPUT TABLE tt-benefic ).

    IF RETURN-VALUE = "NOK" THEN
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-benefic:HANDLE,INPUT "Dados").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.


END PROCEDURE.


PROCEDURE busca-benefic-beinss:

    RUN busca-benefic-beinss IN hBO ( INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_nmrecben,
                                      INPUT aux_cdageins,
                                      INPUT aux_nrcpfcgc,
                                      INPUT aux_nrprocur,
                                      INPUT aux_nrregist,
                                      INPUT aux_nriniseq,
                                     OUTPUT aux_qtregist,
                                     OUTPUT TABLE tt-erro,
                                     OUTPUT TABLE tt-benefic ).

    IF RETURN-VALUE = "NOK" THEN
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-benefic:HANDLE,
                             INPUT "Dados").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.


END PROCEDURE.

/* ************************************************************************ */
/*                           Valida nova conta - CADINS                     */
/* ************************************************************************ */
PROCEDURE valida-nvconta:

    RUN valida-nvconta IN hBO
                     ( INPUT aux_cdcooper,
                       INPUT aux_cdagenci,
                       INPUT aux_nrdcaixa,
                       INPUT aux_cdoperad,
                       INPUT aux_nmdatela,
                       INPUT aux_idorigem,
                       INPUT aux_nrdconta,
                       INPUT aux_idseqttl,
                       INPUT TRUE,        
                       INPUT aux_nrnovcta,
                      OUTPUT aux_nmdcampo,
                      OUTPUT aux_nmprimtl,
                      OUTPUT TABLE tt-erro ).

    IF RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport   (INPUT TEMP-TABLE tt-erro:HANDLE,
                               INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmprimtl",INPUT aux_nmprimtl).
            RUN piXmlSave.
        END.

END.

/*****************************************************************************/
/**               Procedure para geracao de declaracao - CADINS             **/
/*************************************************************************** */
PROCEDURE gera-declaracao:

    RUN gera-declaracao IN hBO
                      ( INPUT aux_cdcooper,
                        INPUT aux_cdagenci,
                        INPUT aux_nrdcaixa,
                        INPUT aux_cdoperad,
                        INPUT aux_nmdatela,
                        INPUT aux_idorigem,
                        INPUT aux_nrdconta,
                        INPUT aux_idseqttl,
                        INPUT TRUE,
                        INPUT aux_dtmvtolt,
                        INPUT aux_nmrecben,
                        INPUT aux_nrbenefi,
                        INPUT aux_dsiduser,
                        INPUT aux_cdagcpac,
                       OUTPUT aux_nmarqimp,
                       OUTPUT aux_nmarqpdf,
                       OUTPUT aux_cdrelato,
                       OUTPUT TABLE tt-erro ).

    IF RETURN-VALUE = "NOK" THEN
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


END.

/*****************************************************************************/
/**            Procedure para consultar beneficio pela data - BEINSS        **/
/*************************************************************************** */
PROCEDURE busca-beneficio:

    RUN busca-beneficio IN hBO
                      ( INPUT aux_cdcooper, 
                        INPUT aux_cdagenci, 
                        INPUT aux_nrdcaixa, 
                        INPUT aux_cdoperad, 
                        INPUT aux_nrrecben, 
                        INPUT aux_nrbenefi, 
                        INPUT aux_dtdinici, 
                        INPUT aux_dtdfinal, 
                        INPUT aux_dtmvtolt,
                       OUTPUT TABLE tt-erro,
                       OUTPUT TABLE tt-lancred ).

    IF RETURN-VALUE = "NOK" THEN
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-lancred:HANDLE,
                             INPUT "Dados").
            RUN piXmlSave.
        END.

END.

PROCEDURE busca_crapdbi:

    RUN busca_crapdbi IN hBO(INPUT aux_cdcooper,
                             INPUT aux_nrcpfcgc,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdagenci,
                             INPUT aux_nrregist,
                             INPUT aux_nriniseq,
                             OUTPUT aux_qtregist,
                             OUTPUT aux_nmdcampo,
                             OUTPUT TABLE tt-benefic,
                             OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK" THEN
       DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.

          IF NOT AVAILABLE tt-erro  THEN
             DO:
                CREATE tt-erro.
                ASSIGN tt-erro.dscritic = "Nao foi possivel consultar " +
                                          "beneficios.".
             END.

          RUN piXmlNew.
          RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
          RUN piXmlSave.

       END.
    ELSE
       DO:
          RUN piXmlNew.
          RUN piXmlExport (INPUT TEMP-TABLE tt-benefic:HANDLE, 
                           INPUT "Beneficio").
          RUN piXmlAtributo (INPUT "qtregist", INPUT aux_qtregist).
          RUN piXmlSave.

       END.

END PROCEDURE.
/* .......................................................................... */
