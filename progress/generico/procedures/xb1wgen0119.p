/*.............................................................................

   Programa: xb1wgen0119.p
   Autor   : Fabricio
   Data    : Dezembro/2011                     Ultima atualizacao: 30/07/2012

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO - Tela PAMCAR.

   Alteracoes: 03/02/2012 - Ajuste nas procedures:
                            > Incluido o parametro dtmvtolt
                              - gera_termo_cancelamento
                              - gera_termo_adesao
                            > Incluido os parametros flgsuces, flgjaproc
                              - processa_arquivo_debito
                            (Adriano).
                            
               10/07/2012 - Incluir procedure copia_relatorio_processamento
                            (David).
                            
               30/10/2012 - Criados relatórios de Limite de Cheque Especial e 
   						    Informações Cadastrais para a opção "R" (Lucas)

............................................................................ */

DEF VAR aux_cdcooper  AS INTE                                           NO-UNDO.
DEF VAR aux_cdcopalt  AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci  AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa  AS INTE                                           NO-UNDO.
DEF VAR aux_dsdepart  AS CHAR                                           NO-UNDO.
DEF VAR aux_cdoperad  AS CHAR                                           NO-UNDO.
DEF VAR aux_vllimpam  AS DECI                                           NO-UNDO.
DEF VAR aux_vlpamuti  AS DECI                                           NO-UNDO.
DEF VAR aux_dthabpam  AS DATE                                           NO-UNDO.
DEF VAR aux_vlmenpam  AS DECI                                           NO-UNDO.
DEF VAR aux_pertxpam  AS DECI                                           NO-UNDO.
DEF VAR aux_nrdconta  AS INTE                                           NO-UNDO.
DEF VAR aux_nrdctitg  AS CHAR                                           NO-UNDO.
DEF VAR aux_flgpamca  AS LOGI                                           NO-UNDO.
DEF VAR aux_dddebpam  AS INTE                                           NO-UNDO.
DEF VAR aux_nrctapam  AS INTE                                           NO-UNDO.
DEF VAR aux_nmarqpdf  AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarquiv  AS CHAR                                           NO-UNDO.
DEF VAR aux_flgrejei  AS CHAR                                           NO-UNDO.
DEF VAR aux_flgsuces  AS CHAR                                           NO-UNDO.
DEF VAR aux_flgjapro  AS CHAR                                           NO-UNDO.
DEF VAR aux_dtinicio  AS DATE                                           NO-UNDO.
DEF VAR aux_dtfim     AS DATE                                           NO-UNDO.
DEF VAR aux_nrcpfcgc  AS DECI                                           NO-UNDO.
DEF VAR aux_dsiduser  AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp  AS CHAR                                           NO-UNDO.


{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgen0119tt.i }


/*................................ PROCEDURES ................................*/


/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/
PROCEDURE valores_entrada:

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper"  THEN aux_cdcooper =  INTE(tt-param.valorCampo).
            WHEN "cdcopalt"  THEN aux_cdcopalt  = INTE(tt-param.valorCampo).
            WHEN "cdagenci"  THEN aux_cdagenci =  INTE(tt-param.valorCampo).
            WHEN "nrdcaixa"  THEN aux_nrdcaixa =  INTE(tt-param.valorCampo).
            WHEN "dsdepart"  THEN aux_dsdepart =  tt-param.valorCampo.
            WHEN "cdoperad"  THEN aux_cdoperad =  tt-param.valorCampo.
            WHEN "vllimpam"  THEN aux_vllimpam =  DECI(tt-param.valorCampo).
            WHEN "dthabpam"  THEN aux_dthabpam =  DATE(tt-param.valorCampo).
            WHEN "vlmenpam"  THEN aux_vlmenpam =  DECI(tt-param.valorCampo).
            WHEN "pertxpam"  THEN aux_pertxpam =  DECI(tt-param.valorCampo).
            WHEN "nrdconta"  THEN aux_nrdconta =  INTE(tt-param.valorCampo).
            WHEN "nrdctitg"  THEN aux_nrdctitg =  tt-param.valorCampo.
            WHEN "flgpamca"  THEN aux_flgpamca =  LOGICAL(tt-param.valorCampo).
            WHEN "dddebpam"  THEN aux_dddebpam =  INTE(tt-param.valorCampo).
            WHEN "nrctapam"  THEN aux_nrctapam =  INTE(tt-param.valorCampo).
            WHEN "nmarquiv"  THEN aux_nmarquiv =  tt-param.valorCampo.
            WHEN "dtinicio"  THEN aux_dtinicio =  DATE(tt-param.valorCampo).
            WHEN "dtfim"     THEN aux_dtfim    =  DATE(tt-param.valorCampo).
            WHEN "nrcpfcgc"  THEN aux_nrcpfcgc =  DECI(tt-param.valorCampo).
            WHEN "dsiduser"  THEN aux_dsiduser = tt-param.valorCampo.
        END CASE.
    
    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.

PROCEDURE verifica_permissao:

    RUN verifica_permissao IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_dsdepart,
                                  OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF NOT AVAILABLE tt-erro THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "verificacao de permissao.".
        END.

        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        RUN piXmlSave.

    END.
    ELSE
    DO:
        RUN piXmlNew.
        RUN piXmlSave.
    END.

END PROCEDURE.

PROCEDURE grava_registro:

    RUN grava_registro IN hBO (INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_dthabpam,
                               INPUT aux_vllimpam,
                               INPUT aux_vlmenpam,
                               INPUT aux_pertxpam).

    RUN piXmlNew.
    RUN piXmlSave.


END PROCEDURE.

PROCEDURE busca_registro:

    RUN busca_registro IN hBO (INPUT aux_cdcooper,
                               INPUT aux_cdcopalt,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               OUTPUT aux_vllimpam,
                               OUTPUT aux_vlpamuti,
                               OUTPUT aux_vlmenpam,
                               OUTPUT aux_pertxpam).

    RUN piXmlNew.
    RUN piXmlAtributo (INPUT "vllimpam", INPUT aux_vllimpam).
    RUN piXmlAtributo (INPUT "vlpamuti", INPUT aux_vlpamuti).
    RUN piXmlAtributo (INPUT "vlmenpam", INPUT aux_vlmenpam).
    RUN piXmlAtributo (INPUT "pertxpam", INPUT aux_pertxpam).
    RUN piXmlSave.

END PROCEDURE.

PROCEDURE busca_cooperativas:

    RUN busca_cooperativas IN hBO (INPUT aux_cdcooper,
                                  OUTPUT TABLE tt-crapcop,
                                  OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF NOT AVAILABLE tt-erro THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "verificacao de permissao.".
        END.

        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        RUN piXmlSave.

    END.
    ELSE
    DO:
        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-crapcop:HANDLE, INPUT "CRAPCOP").
        RUN piXmlSave.
    END.

END PROCEDURE.

PROCEDURE obtem_dados_conta:

    RUN obtem_dados_conta IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdconta,
                                  INPUT aux_nrdctitg,
                                 OUTPUT TABLE tt-dados-conta,
                                 OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF NOT AVAILABLE tt-erro THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel obter as informacoes" +
                                              " da conta.".
        END.

        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        RUN piXmlSave.

    END.
    ELSE
    DO:
        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-dados-conta:HANDLE,INPUT "Dados").
        RUN piXmlSave.
    END.


END PROCEDURE.

PROCEDURE grava_registro_convenio:

    RUN grava_registro_convenio IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nrdconta,
                                        INPUT aux_nrcpfcgc,
                                        INPUT aux_flgpamca,
                                        INPUT aux_vllimpam,
                                        INPUT aux_dddebpam,
                                        INPUT aux_nrctapam,
                                       OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF NOT AVAILABLE tt-erro THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel gravar as " +
                                              "informacoes do convenio.".
        END.

        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        RUN piXmlSave.

    END.
    ELSE
    DO:
        RUN piXmlNew.
        RUN piXmlSave.
    END.




END PROCEDURE.

PROCEDURE gera_termo_adesao:

    RUN gera_termo_adesao IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_nrdconta,
                                  INPUT aux_dtmvtolt,
                                 OUTPUT aux_nmarqpdf,
                                 OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF NOT AVAILABLE tt-erro THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel gerar o termo " +
                                              "de adesao.".
        END.

        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        RUN piXmlSave.

    END.
    ELSE
    DO:
        RUN piXmlNew.
        RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
        RUN piXmlSave.
    END.

END PROCEDURE.

PROCEDURE gera_termo_cancelamento:

    RUN gera_termo_cancelamento IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_nrdconta,
                                        INPUT aux_dtmvtolt,
                                       OUTPUT aux_nmarqpdf,
                                       OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF NOT AVAILABLE tt-erro THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel gerar o termo " +
                                              "de cancelamento.".
        END.

        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        RUN piXmlSave.

    END.
    ELSE
    DO:
        RUN piXmlNew.
        RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
        RUN piXmlSave.
    END.

END PROCEDURE.

PROCEDURE processa_arquivo_debito:

    RUN processa_arquivo_debito IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_nmarquiv,
                                       OUTPUT aux_flgrejei,
                                       OUTPUT aux_flgsuces,
                                       OUTPUT aux_flgjapro,
                                       OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF NOT AVAILABLE tt-erro THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel processar o arquivo " +
                                              "de debito.".
        END.

        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        RUN piXmlSave.
    END.
    ELSE
    DO:
        RUN piXmlNew.
        RUN piXmlAtributo (INPUT "flgrejei", INPUT aux_flgrejei).
        RUN piXmlAtributo (INPUT "flgsuces", INPUT aux_flgsuces).
        RUN piXmlAtributo (INPUT "flgjapro", INPUT aux_flgjapro).
        RUN piXmlSave.

    END.


END PROCEDURE.

PROCEDURE copia_relatorio_processamento:

    RUN copia_relatorio_processamento IN hBO (INPUT aux_cdcooper,
                                              INPUT aux_cdagenci,
                                              INPUT aux_nrdcaixa,
                                              INPUT aux_nmarquiv,
                                             OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel copiar o " +
                                              "relatorio.".
                END.
    
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
    
        END.

END PROCEDURE.

PROCEDURE busca_log_processamento:

    RUN busca_log_processamento IN hBO(INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_dtinicio,
                                       INPUT aux_dtfim,
                                      OUTPUT TABLE tt-log-processamento).

    RUN piXmlNew.
    RUN piXmlExport (INPUT TEMP-TABLE tt-log-processamento:HANDLE,INPUT "Log").
    RUN piXmlSave.


END PROCEDURE.


PROCEDURE gera-rel-cheque-especial:

    RUN gera-rel-cheque-especial IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_dsiduser,
                                         INPUT aux_dtmvtolt,
                                        OUTPUT aux_nmarqimp,
                                        OUTPUT aux_nmarqpdf,
                                        OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel copiar o " +
                                              "relatorio.".
                END.
    
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp", INPUT aux_nmarqimp).
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
            RUN piXmlSave.
    
        END.

END PROCEDURE.

PROCEDURE gera-rel-inf-cadastrais:

    RUN gera-rel-inf-cadastrais IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_dsiduser,
                                        INPUT aux_dtmvtolt,
                                       OUTPUT aux_nmarqimp,
                                       OUTPUT aux_nmarqpdf,
                                       OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel copiar o " +
                                              "relatorio.".
                END.
    
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp", INPUT aux_nmarqimp).
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
            RUN piXmlSave.
    
        END.

END PROCEDURE.
