/*.............................................................................

   Programa: xb1wgen0018.p
   Autor   : Guilherme 
   Data    : Julho/2011                     Ultima atualizacao:   /  /    

   Dados referentes ao programa:

   Objetivo  : BO - Comunicacao XML com b1wgen0018.p

   Alteracoes:

............................................................................ */

DEF VAR aux_cdcooper AS INTE                                        NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                        NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                        NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                        NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                        NO-UNDO.
DEF VAR aux_idorigem AS INTE                                        NO-UNDO.
DEF VAR aux_nmrotina AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                        NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                        NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                        NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                        NO-UNDO.
DEF VAR aux_dsdepart AS CHAR                                        NO-UNDO.
DEF VAR aux_cdprogra AS CHAR                                        NO-UNDO.

DEF VAR aux_nrpacori AS INTE                                        NO-UNDO.
DEF VAR aux_nrpacdes AS INTE                                        NO-UNDO.
DEF VAR aux_dtperini AS DATE                                        NO-UNDO.
DEF VAR aux_dtperfim AS DATE                                        NO-UNDO.
DEF VAR aux_cabectra AS CHAR                                        NO-UNDO.
DEF VAR par_nmarqimp AS CHAR                                        NO-UNDO.
DEF VAR par_nmarqpdf AS CHAR                                        NO-UNDO.
DEF VAR aux_rowidaux AS ROWID                                       NO-UNDO.

DEF VAR aux_nrcpfcgc AS DECI                                        NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                        NO-UNDO.
DEF VAR aux_nrborder AS INTE                                        NO-UNDO.
DEF VAR aux_cdcmpchq AS INTE                                        NO-UNDO.
DEF VAR aux_cdbanchq AS INTE                                        NO-UNDO.
DEF VAR aux_cdagechq AS INTE                                        NO-UNDO.
DEF VAR aux_nrctachq AS DECI                                        NO-UNDO.
DEF VAR aux_nrcheque AS INTE                                        NO-UNDO.
DEF VAR aux_nmcheque AS CHAR                                        NO-UNDO.
DEF VAR aux_auxnmchq AS CHAR                                        NO-UNDO.
DEF VAR aux_auxnrcpf AS DECI                                        NO-UNDO.
DEF VAR aux_dtlibini AS DATE                                        NO-UNDO.
DEF VAR aux_dtlibfim AS DATE                                        NO-UNDO.
DEF VAR aux_vldescto AS DECI                                        NO-UNDO.
DEF VAR aux_dtlibera AS DATE                                        NO-UNDO.
DEF VAR aux_cdagencx AS INTE                                        NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                        NO-UNDO.
DEF VAR aux_vlcheque AS DECI                                        NO-UNDO.
DEF VAR aux_inresgat AS LOGI                                        NO-UNDO.
DEF VAR aux_dtiniper AS DATE                                        NO-UNDO.
DEF VAR aux_dtfimper AS DATE                                        NO-UNDO.
DEF VAR aux_cdctalis AS INTE                                        NO-UNDO.
DEF VAR aux_vlsupinf AS INTE                                        NO-UNDO.
DEF VAR aux_inchqcop AS INTE                                        NO-UNDO.
DEF VAR aux_nrdsenha AS CHAR                                        NO-UNDO.
DEF VAR aux_nvoperad AS INTE                                        NO-UNDO.
DEF VAR aux_tpcheque AS INTE                                        NO-UNDO.
DEF VAR aux_logconta AS LOGI                                        NO-UNDO.
DEF VAR aux_dtmvtini AS DATE                                        NO-UNDO.
DEF VAR aux_dtmvtfim AS DATE                                        NO-UNDO.
DEF VAR aux_nmdopcao AS LOGI                                        NO-UNDO.
DEF VAR aux_flgrelat AS LOGI                                        NO-UNDO.
DEF VAR aux_msgretur AS CHAR                                        NO-UNDO.
DEF VAR aux_tpdsaldo AS INTE                                        NO-UNDO.
DEF VAR aux_cdagelot AS INTE                                        NO-UNDO.
DEF VAR aux_nrdolote AS INTE                                        NO-UNDO.
DEF VAR aux_dsdolote AS CHAR                                        NO-UNDO.
DEF VAR aux_nmdireto AS CHAR                                        NO-UNDO.
DEF VAR aux_nrregist AS INTE                                        NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                        NO-UNDO.
DEF VAR aux_qtregist AS INTE                                        NO-UNDO.
DEF VAR aux_dtmvtolx AS DATE                                        NO-UNDO.


{ sistema/generico/includes/b1wgen0018tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }


/*................................ PROCEDURES ...............................*/


/*****************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML    **/
/*****************************************************************************/
PROCEDURE valores_entrada:

    FOR EACH tt-param:

        /*MESSAGE "0018 XBO " tt-param.nomeCampo tt-param.valorCampo. */

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
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "dsdepart" THEN aux_dsdepart = tt-param.valorCampo.
            WHEN "cdprogra" THEN aux_cdprogra = tt-param.valorCampo.
            WHEN "dtmvtolx" THEN aux_dtmvtolx = DATE(tt-param.valorCampo).    

            WHEN "dtperini" THEN aux_dtperini = DATE(tt-param.valorCampo).  
            WHEN "dtperfim" THEN aux_dtperfim = DATE(tt-param.valorCampo).  
            WHEN "nrpacori" THEN aux_nrpacori = INTE(tt-param.valorCampo).
            WHEN "nrpacdes" THEN aux_nrpacdes = INTE(tt-param.valorCampo).
            WHEN "nmendter" THEN aux_nmendter = tt-param.valorCampo.
            WHEN "nrcpfcgc" THEN aux_nrcpfcgc = DECI(tt-param.valorCampo).
            WHEN "nrborder" THEN aux_nrborder = INTE(tt-param.valorCampo).
            WHEN "cdcmpchq" THEN aux_cdcmpchq = INTE(tt-param.valorCampo).
            WHEN "cdbanchq" THEN aux_cdbanchq = INTE(tt-param.valorCampo).
            WHEN "cdagechq" THEN aux_cdagechq = INTE(tt-param.valorCampo).
            WHEN "nrctachq" THEN aux_nrctachq = DECI(tt-param.valorCampo).
            WHEN "nrcheque" THEN aux_nrcheque = INTE(tt-param.valorCampo).
            WHEN "nmcheque" THEN aux_nmcheque = tt-param.valorCampo.
            WHEN "auxnmchq" THEN aux_auxnmchq = tt-param.valorCampo.
            WHEN "auxnrcpf" THEN aux_auxnrcpf = DECI(tt-param.valorCampo).
            WHEN "dtlibini" THEN aux_dtlibini = DATE(tt-param.valorCampo).
            WHEN "dtlibfim" THEN aux_dtlibfim = DATE(tt-param.valorCampo).
            WHEN "dtlibera" THEN aux_dtlibera = DATE(tt-param.valorCampo).
            WHEN "cdagencx" THEN aux_cdagencx = INTE(tt-param.valorCampo).
            WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.
            WHEN "vlcheque" THEN aux_vlcheque = DECI(tt-param.valorCampo).
            WHEN "inresgat" THEN aux_inresgat = LOGICAL(tt-param.valorCampo).
            WHEN "dtiniper" THEN aux_dtiniper = DATE(tt-param.valorCampo).
            WHEN "dtfimper" THEN aux_dtfimper = DATE(tt-param.valorCampo).
            WHEN "cdctalis" THEN aux_cdctalis = INTE(tt-param.valorCampo).
            WHEN "vlsupinf" THEN aux_vlsupinf = INTE(tt-param.valorCampo).
            WHEN "inchqcop" THEN aux_inchqcop = INTE(tt-param.valorCampo).
            WHEN "nrdsenha" THEN aux_nrdsenha = tt-param.valorCampo.
            WHEN "nvoperad" THEN aux_nvoperad = INTE(tt-param.valorCampo).
            WHEN "dtmvtini" THEN aux_dtmvtini = DATE(tt-param.valorCampo).
            WHEN "dtmvtfim" THEN aux_dtmvtfim = DATE(tt-param.valorCampo).
            WHEN "nmdopcao" THEN aux_nmdopcao = LOGICAL(tt-param.valorCampo).
            WHEN "flgrelat" THEN aux_flgrelat = LOGICAL(tt-param.valorCampo).
            WHEN "tpdsaldo" THEN aux_tpdsaldo = INTE(tt-param.valorCampo).
            WHEN "cdagelot" THEN aux_cdagelot = INTE(tt-param.valorCampo).
            WHEN "nrdolote" THEN aux_nrdolote = INTE(tt-param.valorCampo).
            WHEN "dsdolote" THEN aux_dsdolote = tt-param.valorCampo.
            WHEN "tpcheque" THEN aux_tpcheque = INTE(tt-param.valorCampo).
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).

                
                
                
        END CASE.

    END. /** Fim do FOR EACH tt-param **/


    FOR EACH tt-param-i 
         BREAK BY tt-param-i.nomeTabela
               BY tt-param-i.sqControle:

         CASE tt-param-i.nomeTabela:

             WHEN "Cheques" THEN DO:

                 IF  FIRST-OF(tt-param-i.sqControle) THEN
                     DO:
                        CREATE crawlot.
                        ASSIGN aux_rowidaux = ROWID(crawlot).
                     END.

                 FIND crawlot WHERE ROWID(crawlot) = aux_rowidaux NO-ERROR.

                 CASE tt-param-i.nomeCampo:
                     WHEN "indrelat" THEN
                          crawlot.indrelat = INTE(tt-param-i.valorCampo).
                     WHEN "dtmvtolt" THEN
                          crawlot.dtmvtolt = DATE(tt-param-i.valorCampo).
                     WHEN "cdagenci" THEN
                          crawlot.cdagenci = INTE(tt-param-i.valorCampo).
                     WHEN "nrdconta" THEN
                          crawlot.nrdconta = INTE(tt-param-i.valorCampo).
                     WHEN "nrborder" THEN
                          crawlot.nrborder = INTE(tt-param-i.valorCampo).
                     WHEN "nrdolote" THEN
                          crawlot.nrdolote = INTE(tt-param-i.valorCampo).
                     WHEN "qtchqcop" THEN
                          crawlot.qtchqcop = INTE(tt-param-i.valorCampo).
                     WHEN "qtchqmen" THEN
                          crawlot.qtchqmen = INTE(tt-param-i.valorCampo).
                     WHEN "qtchqmai" THEN
                          crawlot.qtchqmai = INTE(tt-param-i.valorCampo).
                     WHEN "qtchqtot" THEN
                          crawlot.qtchqtot = INTE(tt-param-i.valorCampo).
                     WHEN "vlchqcop" THEN
                          crawlot.vlchqcop = DECI(tt-param-i.valorCampo).
                     WHEN "vlchqmen" THEN
                          crawlot.vlchqmen = DECI(tt-param-i.valorCampo).
                     WHEN "vlchqmai" THEN
                          crawlot.vlchqmai = DECI(tt-param-i.valorCampo).
                     WHEN "vlchqtot" THEN
                          crawlot.vlchqtot = DECI(tt-param-i.valorCampo).
                     WHEN "nmoperad" THEN
                          crawlot.nmoperad = tt-param-i.valorCampo.
                     WHEN "dtlibera" THEN
                          crawlot.dtlibera = DATE(tt-param-i.valorCampo).
                     WHEN "cdbccxlt" THEN
                          crawlot.cdbccxlt = INTE(tt-param-i.valorCampo).
                     WHEN "qtcompln" THEN
                          crawlot.qtcompln = INTE(tt-param-i.valorCampo).
                     WHEN "vlcompdb" THEN
                          crawlot.vlcompdb = DECI(tt-param-i.valorCampo).
                 END CASE.
                 
             END.

         END CASE.
     END.

END PROCEDURE.

/*****************************************************************************/
/**           Procedure para obter alteracoes de tipo de conta              **/
/*****************************************************************************/
PROCEDURE consulta_alteracoes_tp_conta:

    RUN consulta_alteracoes_tp_conta IN hBO
                                        (INPUT aux_cdcooper,
                                         INPUT aux_nrdconta,
                                         INPUT  0,
                                         INPUT  0,
                                         OUTPUT TABLE tt-detalhe-conta,
                                         OUTPUT TABLE tt-alt-tip-conta,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-detalhe-conta:HANDLE,
                             INPUT "detalhe-conta").
            RUN piXmlExport (INPUT TEMP-TABLE tt-alt-tip-conta:HANDLE,
                             INPUT "alt-tip-conta").
            RUN piXmlSave.
        END.


END PROCEDURE.

/*****************************************************************************/
/*                         Verifica Conta para buscar cheques                */
/*****************************************************************************/
PROCEDURE consulta_transf_pacs:

    RUN consulta_transf_pacs IN hBO
                                (INPUT aux_cdcooper,
                                 INPUT aux_nrpacori,
                                 INPUT aux_nrpacdes,
                                 INPUT aux_dtperini,
                                 INPUT aux_dtperfim,
                                 INPUT 0,
                                 INPUT 0,
                                 OUTPUT aux_cabectra,
                                 OUTPUT TABLE tt-transfer,
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

            RUN piXmlExport (INPUT TEMP-TABLE tt-transfer:HANDLE,
                             INPUT "transfer").
            RUN piXmlSave.
        END.


END PROCEDURE.

/*****************************************************************************
 Gerar Impressao do relatorio de transferencias de PAC
*****************************************************************************/
PROCEDURE gera-impressao-transf-pac:

   RUN gera-impressao-transf-pac IN hBo 
                              (INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nmdatela,
                               INPUT aux_idorigem,
                               INPUT aux_nrdconta,

                               INPUT aux_nrpacori,
                               INPUT aux_nrpacdes,
                               INPUT aux_dtperini,
                               INPUT aux_dtperfim,
                               INPUT aux_nmendter,
                              OUTPUT TABLE tt-erro,
                              OUTPUT par_nmarqimp,
                              OUTPUT par_nmarqpdf).

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
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT par_nmarqpdf).
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE busca_informacoes_associado:
    
    RUN busca_informacoes_associado IN hBO
                                  ( INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_nrdconta,
                                    INPUT aux_nrcpfcgc,
                                   OUTPUT TABLE tt-erro,
                                   OUTPUT TABLE tt-crapass).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.

            
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapass:HANDLE,
                             INPUT "Associado").
            RUN piXmlSave.
        END.

END PROCEDURE. /* busca_informacoes_associado */

PROCEDURE verifica_permissao:

    RUN verifica_permissao IN hBO
                         ( INPUT aux_cdcooper,
                           INPUT aux_cdagenci,
                           INPUT aux_nrdcaixa,
                           INPUT aux_dsdepart,
                           INPUT aux_cddopcao,
                          OUTPUT aux_nmdcampo,
                          OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
            
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE. /* verifica_permissao */

PROCEDURE busca_alterar_cheques_descontados:

    RUN busca_alterar_cheques_descontados IN hBO
                                        ( INPUT aux_cdcooper,
                                          INPUT aux_cdagenci,
                                          INPUT aux_nrdconta,
                                          INPUT aux_nrborder,
                                          INPUT aux_cdcmpchq,
                                          INPUT aux_cdbanchq,
                                          INPUT aux_cdagechq,
                                          INPUT aux_nrctachq,
                                          INPUT aux_nrcheque,
                                         OUTPUT TABLE tt-alterar,
                                         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

                RUN piXmlNew.
                RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                                 INPUT "Erro").
                RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
                RUN piXmlSave.

        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-alterar:HANDLE,
                             INPUT "Cheques").
            RUN piXmlSave.
        END.

END PROCEDURE. /* busca_alterar_cheques_descontados */
    
PROCEDURE alterar_cheques_descontados:

    RUN alterar_cheques_descontados IN hBO
                                  ( INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_dsdepart,
                                    INPUT aux_nrdconta,
                                    INPUT aux_nrborder,
                                    INPUT aux_cdcmpchq,
                                    INPUT aux_cdbanchq,
                                    INPUT aux_cdagechq,
                                    INPUT aux_nrctachq,
                                    INPUT aux_nrcheque,
                                    INPUT aux_nmcheque,
                                    INPUT aux_nrcpfcgc,
                                    INPUT aux_auxnmchq,
                                    INPUT aux_auxnrcpf,
                                    INPUT aux_cdoperad,
                                    INPUT aux_cddopcao,
                                    INPUT TRUE,
                                   OUTPUT aux_nmdcampo,
                                   OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE. /* alterar_cheques_descontados */

PROCEDURE consulta_cheques_descontados:

    RUN consulta_cheques_descontados IN hBO
                                   ( INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_nrdconta,
                                     INPUT aux_nrcpfcgc,
                                     INPUT aux_dtmvtoan,
                                     INPUT aux_dtlibini,
                                     INPUT aux_dtlibfim,
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-crapcdb).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
            				 INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.

        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapcdb:HANDLE,
                             INPUT "Cheques").
            RUN piXmlAtributo (INPUT "qtregist",INPUT aux_qtregist).
            RUN piXmlSave.
        END.

END PROCEDURE. /* consulta_cheques_descontados */

PROCEDURE consulta_quem_descontou:

    RUN consulta_quem_descontou IN hBO
                              ( INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_nrdconta,
                                INPUT aux_dtmvtolt,
                               OUTPUT TABLE tt-erro,
                               OUTPUT TABLE tt-crapcdb).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
            				 INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapcdb:HANDLE,
                             INPUT "Cheques").
            RUN piXmlAtributo(INPUT "vldescto",INPUT aux_vldescto).
            RUN piXmlSave.
        END.

END PROCEDURE. /* consulta_quem_descontou */

PROCEDURE pesquisa_cheque_descontado:

    RUN pesquisa_cheque_descontado IN hBO
                                 ( INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_nrdconta,
                                   INPUT aux_cdbanchq,
                                   INPUT aux_cdagechq,
                                   INPUT aux_nrctachq,
                                   INPUT aux_nrcheque,
                                  OUTPUT TABLE tt-erro,
                                  OUTPUT TABLE tt-crapcdb).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
            				 INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapcdb:HANDLE,
                             INPUT "Cheques").
            RUN piXmlSave.
        END.

END PROCEDURE. /* pesquisa_cheque_descontado */

PROCEDURE busca_fechamento_descto:

    RUN busca_fechamento_descto IN hBO
                              ( INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_dtlibera,
                                INPUT aux_nrdconta,
                                INPUT aux_dtmvtolt,
                               OUTPUT TABLE tt-erro,
                               OUTPUT TABLE tt-fechamento).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
            				 INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-fechamento:HANDLE,
                             INPUT "Fechamento").
            RUN piXmlSave.
        END.

END PROCEDURE. /* busca_fechamento_descto */

PROCEDURE busca_saldo_descto:

    RUN busca_saldo_descto IN hBO
                         ( INPUT aux_cdcooper,
                           INPUT aux_cdagenci,
                           INPUT aux_nrdcaixa,
                           INPUT aux_dtlibera,
                          OUTPUT TABLE tt-erro,
                          OUTPUT TABLE tt-saldo).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
            				 INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-saldo:HANDLE,
                             INPUT "Saldo").
            RUN piXmlSave.
        END.

END PROCEDURE. /* busca_saldo_descto */
    
PROCEDURE busca_todos_lancamentos_descto:

    RUN busca_todos_lancamentos_descto IN hBO
                                     ( INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_nrdconta,
                                       INPUT aux_cdbanchq,
                                       INPUT aux_nrcheque,
                                       INPUT aux_vlcheque,
                                       INPUT aux_dtmvtoan,
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-lancamentos).
    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
            				 INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-lancamentos:HANDLE,
                             INPUT "Lancamentos").
            RUN piXmlSave.
        END.

END PROCEDURE. /* busca_todos_lancamentos_descto */

PROCEDURE valida_cheques_descontados:

    RUN valida_cheques_descontados IN hBO
                                 ( INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_nrcpfcgc,
                                   INPUT aux_nmcheque,
                                  OUTPUT aux_nmdcampo,
                                  OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
            				 INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo(INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.

END PROCEDURE. /* valida_cheques_descontados */

PROCEDURE valida_operador_desconto:

    RUN valida_operador_desconto IN hBO
                               ( INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_idorigem,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nrdsenha,
                                 INPUT aux_nvoperad,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_nrdconta,
                                OUTPUT aux_nmdcampo,
                                 INPUT TABLE crawlot,
                                OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
            				 INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE. /* valida_operador_desconto */

PROCEDURE desconta_cheques_em_custodia:

    RUN desconta_cheques_em_custodia IN hBO
                                   ( INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     /*INPUT aux_idorigem,
                                     INPUT aux_nmdatela,
                                     INPUT aux_cdprogra,
                                     INPUT aux_dsiduser,*/
                                     INPUT aux_nrdconta,
                                     INPUT aux_dtmvtolt,
                                     INPUT aux_dtlibera,
                                     INPUT aux_cdoperad,
                                     INPUT TABLE crawlot,
                                    /*OUTPUT aux_nmarqimp,
                                    OUTPUT aux_nmarqpdf,*/
                                    OUTPUT TABLE tt-crapbdc,
                                    OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"  THEN
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
            RUN piXmlAtributo(INPUT "nmarqpdf",INPUT aux_nmarqpdf).
            RUN piXmlSave.
        END.

END PROCEDURE. /* desconta_cheques_em_custodia */

PROCEDURE consulta_cheques_custodia:

    RUN consulta_cheques_custodia IN hBO
                                ( INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_nrdconta,
                                  INPUT aux_tpcheque,
                                  INPUT aux_dtmvtoan,
                                  INPUT aux_dtlibini,
                                  INPUT aux_dtlibfim,
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-crapcst).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
            				 INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapcst:HANDLE,
                             INPUT "Cheques").
            RUN piXmlSave.
        END.

END PROCEDURE. /* consulta_cheques_custodia */

PROCEDURE pesquisa_cheque_custodia:

    RUN pesquisa_cheque_custodia IN hBO
                               ( INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_nrdconta,
                                 INPUT aux_cdbanchq,
                                 INPUT aux_cdagechq,
                                 INPUT aux_nrctachq,
                                 INPUT aux_nrcheque,
                                OUTPUT TABLE tt-erro,
                                OUTPUT TABLE tt-crapcst).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
            				 INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapcst:HANDLE,
                             INPUT "Cheques").
            RUN piXmlSave.
        END.

END PROCEDURE. /* pesquisa_cheque_custodia */

PROCEDURE busca_fechamento_custodia:

    RUN busca_fechamento_custodia IN hBO
                                ( INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_dtlibera,
                                  INPUT aux_nrdconta,
                                  INPUT aux_dtmvtolt,
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-fechamento).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
            				 INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-fechamento:HANDLE,
                             INPUT "Lancamentos").
            RUN piXmlAtributo(INPUT "logconta",INPUT aux_logconta).
            RUN piXmlSave.
        END.

END PROCEDURE. /* busca_fechamento_custodia */

PROCEDURE busca_saldo_custodia:

    RUN busca_saldo_custodia IN hBO
                           ( INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_tpdsaldo,
                             INPUT aux_nrdconta,
                             INPUT aux_dtlibera,
                            OUTPUT TABLE tt-erro,
                            OUTPUT TABLE tt-saldo).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
            				 INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-saldo:HANDLE,
                             INPUT "Saldo").
            RUN piXmlSave.
        END.

END PROCEDURE. /* busca_saldo_custodia */

PROCEDURE busca_todos_lancamentos_custodia:

    RUN busca_todos_lancamentos_custodia IN hBO
                                       ( INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_nrdconta,
                                         INPUT aux_cdbanchq,
                                         INPUT aux_nrcheque,
                                         INPUT aux_vlcheque,
                                         INPUT aux_dtmvtoan,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-lancamentos).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
            				 INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-lancamentos:HANDLE,
                             INPUT "Lancamentos").
            RUN piXmlSave.
        END.

END PROCEDURE. /* busca_todos_lancamentos_custodia */

PROCEDURE valida_limites_desconto:

    RUN valida_limites_desconto IN hBO
                              ( INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_nrdconta,
                                INPUT aux_dtmvtolt,
                               OUTPUT aux_dtlibera,
                               OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
            				 INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo(INPUT "dtlibera",INPUT STRING(aux_dtlibera,"99/99/9999")).
            RUN piXmlSave.
        END.

END PROCEDURE. /* valida_limites_desconto */

PROCEDURE valida_dados_desconto:

    RUN valida_dados_desconto IN hBO
                            ( INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_nrdconta,
                              INPUT aux_dtmvtolt,
                              INPUT aux_dtlibera,
                             OUTPUT aux_nmdcampo,
                             OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
            				 INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE. /* valida_dados_desconto */

PROCEDURE valida_lote_desconto:

    RUN valida_lote_desconto IN hBO
                            (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_dtmvtolx,
                             INPUT aux_cdagelot,
                             INPUT aux_nrdolote,
                             INPUT aux_nrdconta,
                             INPUT aux_dtlibera,
                      INPUT-OUTPUT TABLE crawlot,
                            OUTPUT TABLE tt-erro,
                            OUTPUT aux_nmdcampo,
                            OUTPUT aux_dsdolote).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
            				 INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE crawlot:HANDLE,
                             INPUT "Lotes").
            RUN piXmlAtributo(INPUT "dsdolote",INPUT aux_dsdolote).
            RUN piXmlSave.
        END.

END PROCEDURE. /* valida_lote_desconto */

PROCEDURE Inicializa_Opcao:

    RUN Inicializa_Opcao IN hBO
                       ( INPUT aux_cdcooper,
                         INPUT aux_cdagenci,
                         INPUT aux_nrdcaixa,
                         INPUT aux_idorigem,
                         INPUT aux_dtmvtolt,
                         INPUT aux_cddopcao,
                        OUTPUT aux_dtmvtini,
                        OUTPUT aux_dtmvtfim,
                        OUTPUT aux_nmdireto,
                        OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"  THEN
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
            RUN piXmlAtributo(INPUT "dtmvtini",INPUT STRING(aux_dtmvtini,"99/99/9999")).
            RUN piXmlAtributo(INPUT "dtmvtfim",INPUT STRING(aux_dtmvtfim,"99/99/9999")).
            RUN piXmlAtributo(INPUT "nmdireto",INPUT aux_nmdireto).
            RUN piXmlSave.
        END.

END PROCEDURE. /* Inicializa_Opcao */
