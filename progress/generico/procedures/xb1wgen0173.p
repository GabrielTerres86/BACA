/*.............................................................................

    Programa: sistema/generico/procedures/xb1wgen0173.p
    Autor   : Oliver Fagionato (GATI)
    Data    : Agosto/2013                      Ultima Atualizacao: 18/12/2014

    Objetivo  : BO de Comunicacao XML x BO 
                Tela CLDSED
                Consultar, alterar/cadastrar justificativa, listar,
                conultar detalhadamente, realizar e cancelar fechamento de
                movimentações de creditos diarios dos cooperados.
                
    Alteracoes: 18/12/2014 - Ajustado parametros na chamada da BO. Realizado
                             validacao das funcionalidades da conversão WEB.
                             (Douglas - Chamado 143945)
                   
.............................................................................*/

/*............................. DEFINICOES ..................................*/

DEFINE VARIABLE aux_cdcooper AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_cdagenci AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_nrdcaixa AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_cdoperad AS CHARACTER   NO-UNDO.
DEFINE VARIABLE aux2_dtmvtolt AS DATE        NO-UNDO.
DEFINE VARIABLE aux_idorigem AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_nmdatela AS CHARACTER   NO-UNDO.
DEFINE VARIABLE aux_cdprogra AS CHARACTER   NO-UNDO.


DEFINE VARIABLE aux_cdincoaf AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_nrdconta AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_cdstatus AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_dtrefini AS DATE        NO-UNDO.
DEFINE VARIABLE aux_dtreffim AS DATE        NO-UNDO.
DEFINE VARIABLE aux_tpdsaida AS CHARACTER   NO-UNDO.
DEFINE VARIABLE aux_nmarquiv AS CHARACTER   NO-UNDO.
DEFINE VARIABLE aux_gerexcel AS CHARACTER   NO-UNDO. /* 'S' ou 'N' */
DEFINE VARIABLE aux_nrdrowid AS ROWID       NO-UNDO.
DEFINE VARIABLE aux_cddjusti AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_dsdjusti AS CHARACTER   NO-UNDO.
DEFINE VARIABLE aux_dsobsctr AS CHARACTER   NO-UNDO.
DEFINE VARIABLE aux_opeenvcf AS CHARACTER   NO-UNDO.
DEFINE VARIABLE aux_infrepcf AS CHARACTER   NO-UNDO.

DEFINE VARIABLE aux_flextjus AS LOGICAL     NO-UNDO.
DEFINE VARIABLE aux_teldtmvtolt AS DATE        NO-UNDO.
DEFINE VARIABLE aux_nmarqimp AS CHARACTER   NO-UNDO.
DEFINE VARIABLE aux_nmarqpdf AS CHARACTER   NO-UNDO.
DEFINE VARIABLE aux_dsiduser AS CHARACTER   NO-UNDO.
DEF VAR par_dscritic AS CHAR    NO-UNDO.
DEF VAR par_infocoat AS CHAR    NO-UNDO.
DEF VAR par_ffechrea AS LOGICAL NO-UNDO.
DEF VAR par_nrdjusti AS INT     NO-UNDO.
DEF VAR par_flextjus AS LOGICAL NO-UNDO.

DEFINE VARIABLE aux_rowid_pesquisa  AS ROWID NO-UNDO.
DEFINE VARIABLE aux_rowid_atividade AS ROWID NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0173tt.i }

PROCEDURE valores_entrada:
    FOR EACH tt-param:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper"    THEN aux_cdcooper    = INT(tt-param.valorCampo).
            WHEN 'cdagenci'    THEN aux_cdagenci    = INT(tt-param.valorCampo).
            WHEN 'nrdcaixa'    THEN aux_nrdcaixa    = INT(tt-param.valorCampo).  
            WHEN 'cdoperad'    THEN aux_cdoperad    = tt-param.valorCampo.  
            WHEN 'idorigem'    THEN aux_idorigem    = INT(tt-param.valorCampo).  
            WHEN 'nmdatela'    THEN aux_nmdatela    = tt-param.valorCampo.  
            WHEN 'cdprogra'    THEN aux_cdprogra    = tt-param.valorCampo.  
            WHEN "dtmvtolt"    THEN aux2_dtmvtolt   = DATE(tt-param.valorCampo).
            WHEN "cdincoaf"    THEN aux_cdincoaf    = INT(tt-param.valorCampo).
            WHEN "nrdconta"    THEN aux_nrdconta    = INT(tt-param.valorCampo).
            WHEN "cdstatus"    THEN aux_cdstatus    = INT(tt-param.valorCampo).
            WHEN "dtrefini"    THEN aux_dtrefini    = DATE(tt-param.valorCampo).
            WHEN "dtreffim"    THEN aux_dtreffim    = DATE(tt-param.valorCampo).
            WHEN "tpdsaida"    THEN aux_tpdsaida    = tt-param.valorCampo.
            WHEN "nmarquiv"    THEN aux_nmarquiv    = tt-param.valorCampo.
            WHEN "gerexcel"    THEN aux_gerexcel    = tt-param.valorCampo.
            WHEN "nrdrowid"    THEN aux_nrdrowid    = TO-ROWID(tt-param.valorCampo).
            WHEN "cddjusti"    THEN aux_cddjusti    = INT(tt-param.valorCampo).
            WHEN "dsdjusti"    THEN aux_dsdjusti    = tt-param.valorCampo.
            WHEN "dsobsctr"    THEN aux_dsobsctr    = tt-param.valorCampo.
            WHEN "opeenvcf"    THEN aux_opeenvcf    = tt-param.valorCampo.
            WHEN "infrepcf"    THEN aux_infrepcf    = tt-param.valorCampo.
            WHEN "cdoperad"    THEN aux_cdoperad    = tt-param.valorCampo.
            WHEN "flextjus"    THEN aux_flextjus    = LOGICAL(tt-param.valorCampo).
            WHEN "teldtmvtolt" THEN aux_teldtmvtolt = DATE(tt-param.valorCampo).
            WHEN "dsiduser"    THEN aux_dsiduser    = tt-param.valorCampo.
            
        END CASE.
    END. /* FOR EACH tt-param */

    FOR EACH tt-param-i 
        BREAK BY tt-param-i.nomeTabela
              BY tt-param-i.sqControle:

        CASE tt-param-i.nomeTabela:

            WHEN "pesquisa" THEN DO:
                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:
                       CREATE tt-pesquisa.
                       ASSIGN aux_rowid_pesquisa = ROWID(tt-pesquisa).
                    END.

                FIND tt-pesquisa WHERE 
                     ROWID(tt-pesquisa) = aux_rowid_pesquisa 
                     NO-ERROR.

                CASE tt-param-i.nomeCampo:
                    WHEN "cdagenci" THEN
                        tt-pesquisa.cdagenci = INT(tt-param-i.valorCampo).
                    WHEN "nrdconta" THEN
                        tt-pesquisa.nrdconta = INT(tt-param-i.valorCampo).
                    WHEN "dtmvtolt" THEN
                        tt-pesquisa.dtmvtolt = DATE(tt-param-i.valorCampo).
                    WHEN "vlrendim" THEN
                        tt-pesquisa.vlrendim = DEC(tt-param-i.valorCampo).
                    WHEN "vltotcre" THEN
                        tt-pesquisa.vltotcre = DEC(tt-param-i.valorCampo).
                    WHEN "qtultren" THEN
                        tt-pesquisa.qtultren = INT(tt-param-i.valorCampo).
                    WHEN "dsstatus" THEN
                        tt-pesquisa.dsstatus = tt-param-i.valorCampo.
                    WHEN "dsdjusti" THEN
                        tt-pesquisa.dsdjusti = tt-param-i.valorCampo.
                    WHEN "infrepcf" THEN
                        tt-pesquisa.infrepcf = tt-param-i.valorCampo.
                END CASE.
            END. /* WHEN "pesquisa" */

            WHEN "atividade" THEN DO:
                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:
                       CREATE tt-atividade.
                       ASSIGN aux_rowid_atividade = ROWID(tt-atividade).
                    END.

                FIND tt-atividade WHERE 
                     ROWID(tt-atividade) = aux_rowid_atividade 
                     NO-ERROR.

                CASE tt-param-i.nomeCampo:
                    WHEN "nrdconta" THEN
                        tt-atividade.nrdconta = INT(tt-param-i.valorCampo).
                    WHEN "dtmvtolt" THEN
                        tt-atividade.dtmvtolt = DATE(tt-param-i.valorCampo).
                    WHEN "tpvincul" THEN
                        tt-atividade.tpvincul = tt-param-i.valorCampo.
                    WHEN "cdagenci" THEN
                        tt-atividade.cdagenci = INT(tt-param-i.valorCampo).
                    WHEN "vlrendim" THEN
                        tt-atividade.vlrendim = DEC(tt-param-i.valorCampo).
                    WHEN "vltotcre" THEN
                        tt-atividade.vltotcre = DEC(tt-param-i.valorCampo).
                    WHEN "qtultren" THEN
                        tt-atividade.qtultren = INT(tt-param-i.valorCampo).
                    WHEN "cddjusti" THEN
                        tt-atividade.cddjusti = INT(tt-param-i.valorCampo).
                    WHEN "dsdjusti" THEN
                        tt-atividade.dsdjusti = tt-param-i.valorCampo.
                    WHEN "infrepcf" THEN
                        tt-atividade.infrepcf = tt-param-i.valorCampo.
                    WHEN "dsobserv" THEN
                        tt-atividade.dsobserv = tt-param-i.valorCampo.
                    WHEN "dsobsctr" THEN
                        tt-atividade.dsobsctr = tt-param-i.valorCampo.
                    WHEN "dsstatus" THEN
                        tt-atividade.dsstatus = tt-param-i.valorCampo.
                END CASE.
            END. /* WHEN "atividade" */

        END CASE. /* CASE tt-param-i.nomeTabela */

    END. /* FOR EACH tt-param-i  */

END PROCEDURE. /* valores_entrada */

PROCEDURE Valida_nao_justificado:

    RUN Valida_nao_justificado IN hBO(INPUT aux_cdcooper,  
                                      INPUT aux_cdagenci,  
                                      INPUT aux_nrdcaixa, 
                                      INPUT aux_cdoperad, 
                                      INPUT aux_teldtmvtolt,
                                      INPUT aux2_dtmvtolt,
                                      INPUT aux_idorigem,
                                      INPUT aux_nmdatela, 
                                      INPUT aux_cdprogra, 
                                      OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"  OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
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
            RUN piXmlAtributo (INPUT "dscritic",INPUT "").
            RUN piXmlSave.
        END.

   
END PROCEDURE.

PROCEDURE Valida_COAF:

    RUN Valida_COAF IN hBO(INPUT aux_cdcooper,  
                           INPUT aux_cdagenci,  
                           INPUT aux_nrdcaixa, 
                           INPUT aux_cdoperad, 
                           INPUT aux2_dtmvtolt,
                           INPUT aux_idorigem,
                           INPUT aux_nmdatela, 
                           INPUT aux_cdprogra, 
                           OUTPUT par_infocoat,
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
          RUN piXmlAtributo (INPUT "infocoat",INPUT par_infocoat).
          RUN piXmlSave.
       END.
    
END PROCEDURE.

PROCEDURE Valida_fechamento:

    RUN Valida_fechamento IN hBO(INPUT aux_cdcooper,  
                                 INPUT aux_cdagenci,  
                                 INPUT aux_nrdcaixa, 
                                 INPUT aux_cdoperad, 
                                 INPUT aux_teldtmvtolt,
                                 INPUT aux2_dtmvtolt,
                                 INPUT aux_idorigem,
                                 INPUT aux_nmdatela, 
                                 OUTPUT par_ffechrea,
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
           RUN piXmlAtributo (INPUT "ffechrea",INPUT STRING(par_ffechrea)).
           RUN piXmlSave.
       END.

END PROCEDURE.

PROCEDURE Carrega_pesquisa:

    RUN Carrega_pesquisa IN hBO(INPUT aux_cdcooper, 
                                INPUT aux_cdagenci, 
                                INPUT aux_nrdcaixa, 
                                INPUT aux_cdoperad, 
                                INPUT aux2_dtmvtolt,
                                INPUT aux_idorigem, 
                                INPUT aux_nmdatela, 
                                INPUT aux_cdprogra, 
                                INPUT aux_nrdconta,
                                INPUT aux_cdincoaf,
                                INPUT aux_cdstatus,
                                INPUT aux_dtrefini,
                                INPUT aux_dtreffim,
                                OUTPUT TABLE tt-pesquisa,
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
          RUN piXmlExport (INPUT TEMP-TABLE tt-pesquisa:HANDLE,
                           INPUT "pesquisa").
          RUN piXmlSave.
       END.

END PROCEDURE.

PROCEDURE Gera_imprime_arq_pesquisa:

    RUN Carrega_pesquisa IN hBO(INPUT aux_cdcooper, 
                                INPUT aux_cdagenci, 
                                INPUT aux_nrdcaixa, 
                                INPUT aux_cdoperad, 
                                INPUT aux2_dtmvtolt,
                                INPUT aux_idorigem, 
                                INPUT aux_nmdatela, 
                                INPUT aux_cdprogra, 
                                INPUT aux_nrdconta,
                                INPUT aux_cdincoaf,
                                INPUT aux_cdstatus,
                                INPUT aux_dtrefini,
                                INPUT aux_dtreffim,
                                OUTPUT TABLE tt-pesquisa,
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
        RETURN "NOK".
    END.

    RUN Gera_imprime_arq_pesquisa IN hBO(INPUT aux_cdcooper, 
                                         INPUT aux_cdagenci, 
                                         INPUT aux_nrdcaixa, 
                                         INPUT aux_cdoperad, 
                                         INPUT aux2_dtmvtolt,
                                         INPUT aux_idorigem, 
                                         INPUT aux_nmdatela, 
                                         INPUT aux_cdprogra, 
                                         INPUT aux_tpdsaida,
                                         INPUT TABLE tt-pesquisa,
                                         INPUT-OUTPUT aux_nmarquiv,
                                         OUTPUT aux_nmarqpdf,
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
        RETURN "NOK".
    END.
    ELSE 
    DO:
        RUN piXmlNew.
        RUN piXmlAtributo (INPUT "nmarqimp",INPUT STRING(aux_nmarquiv)).
        RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
        RUN piXmlSave.
    END.

    
            
        
END PROCEDURE.

PROCEDURE Gera_imprime_arq_atividade:

    RUN Carrega_atividade IN hBO(INPUT aux_cdcooper,  
                                 INPUT aux_cdagenci,  
                                 INPUT aux_nrdcaixa, 
                                 INPUT aux_cdoperad, 
                                 INPUT aux2_dtmvtolt,
                                 INPUT aux_idorigem,
                                 INPUT aux_nmdatela, 
                                 INPUT aux_cdprogra, 
                                 INPUT aux_dtrefini,
                                 INPUT aux_dtreffim,
                                 OUTPUT TABLE tt-atividade,
                                 OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir " +
                                              "a operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").

            RETURN "NOK".
        END.

    RUN Gera_imprime_arq_atividade IN hBO(INPUT aux_cdcooper,  
                                          INPUT aux_cdagenci,  
                                          INPUT aux_nrdcaixa, 
                                          INPUT aux_cdoperad, 
                                          INPUT aux2_dtmvtolt,
                                          INPUT aux_idorigem,
                                          INPUT aux_nmdatela, 
                                          INPUT aux_cdprogra, 
                                          INPUT aux_tpdsaida,
                                          INPUT aux_gerexcel, /* 'S' ou 'N' */
                                          INPUT TABLE tt-atividade,
                                          INPUT-OUTPUT aux_nmarquiv,
                                          OUTPUT aux_nmarqpdf,
                                          OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir " +
                                              "a operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").

            RETURN "NOK".
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp",INPUT STRING(aux_nmarquiv)).
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.

            

END PROCEDURE.

PROCEDURE Carrega_atividade:

    RUN Carrega_atividade IN hBO(INPUT aux_cdcooper, 
                                 INPUT aux_cdagenci, 
                                 INPUT aux_nrdcaixa, 
                                 INPUT aux_cdoperad, 
                                 INPUT aux2_dtmvtolt,
                                 INPUT aux_idorigem, 
                                 INPUT aux_nmdatela, 
                                 INPUT aux_cdprogra, 
                                 INPUT aux_dtrefini,
                                 INPUT aux_dtreffim,
                                 OUTPUT TABLE tt-atividade,
                                 OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir " +
                                              "a operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
       DO:
          RUN piXmlNew.
          RUN piXmlExport (INPUT TEMP-TABLE tt-atividade:HANDLE,
                           INPUT "atividade").
          RUN piXmlSave.   
       END.

    

END PROCEDURE.

PROCEDURE Justifica_movimento:
    RUN Justifica_movimento IN hBO(INPUT aux_cdcooper, 
                                   INPUT aux_cdagenci, 
                                   INPUT aux_nrdcaixa,  
                                   INPUT aux_cdoperad, 
                                   INPUT aux2_dtmvtolt,
                                   INPUT aux_idorigem, 
                                   INPUT aux_nmdatela, 
                                   INPUT aux_cdprogra, 
                                   INPUT aux_nrdrowid,
                                   INPUT aux_cddjusti,
                                   INPUT aux_dsdjusti,
                                   INPUT aux_dsobsctr,
                                   INPUT aux_opeenvcf,
                                   INPUT aux_infrepcf,
                                   INPUT aux_teldtmvtolt,
                                   OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir " +
                                              "a operacao.".
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

PROCEDURE Cancela_fechamento:

    RUN Cancela_fechamento IN hBO(INPUT aux_cdcooper, 
                                  INPUT aux_cdagenci, 
                                  INPUT aux_nrdcaixa,  
                                  INPUT aux_cdoperad, 
                                  INPUT aux2_dtmvtolt,
                                  INPUT aux_idorigem, 
                                  INPUT aux_nmdatela, 
                                  INPUT aux_cdprogra,
                                  INPUT aux_teldtmvtolt,
                                  OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir " +
                                              "a operacao.".
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

PROCEDURE Efetiva_fechamento:

    RUN Efetiva_fechamento IN hBO(INPUT aux_cdcooper,  
                                  INPUT aux_cdagenci,  
                                  INPUT aux_nrdcaixa, 
                                  INPUT aux_cdoperad, 
                                  INPUT aux2_dtmvtolt,
                                  INPUT aux_idorigem,
                                  INPUT aux_nmdatela, 
                                  INPUT aux_cdprogra, 
                                  INPUT aux_teldtmvtolt,
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
          RUN piXmlSave.
       END.

END PROCEDURE.

PROCEDURE Carrega_justificativas:

    RUN Carrega_justificativas IN hBO(INPUT aux_cdcooper,  
                                      INPUT aux_cdagenci,  
                                      INPUT aux_nrdcaixa, 
                                      INPUT aux_cdoperad, 
                                      INPUT aux2_dtmvtolt,
                                      INPUT aux_idorigem,
                                      INPUT aux_nmdatela, 
                                      INPUT aux_cdprogra,
     /* usado somente no caractere */ OUTPUT par_nrdjusti, 
                                      OUTPUT TABLE tt-just,
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
          RUN piXmlExport (INPUT TEMP-TABLE tt-just:HANDLE,
                           INPUT "just").
          RUN piXmlSave.
       END.
    
END PROCEDURE.

PROCEDURE Dados_cooperativa:

    RUN Dados_cooperativa IN hBO(INPUT  aux_cdcooper,
                                 INPUT  aux_cdagenci,
                                 INPUT  aux_nrdcaixa,
                                 INPUT  aux_cdoperad,
                                 INPUT  aux_dtmvtolt,
                                 INPUT  aux_idorigem,
                                 INPUT  aux_nmdatela,
                                 INPUT  aux_cdprogra,
                                 OUTPUT TABLE tt-crapcop,
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
          RUN piXmlExport (INPUT TEMP-TABLE tt-crapcop:HANDLE,INPUT "crapcop").
          RUN piXmlSave.
       END.
    
END PROCEDURE.

PROCEDURE Carrega_creditos:

    RUN Carrega_creditos IN hBO(INPUT aux_cdcooper,  
                                INPUT aux_cdagenci,  
                                INPUT aux_nrdcaixa, 
                                INPUT aux_cdoperad, 
                                INPUT aux2_dtmvtolt,
                                INPUT aux_idorigem,
                                INPUT aux_nmdatela, 
                                INPUT aux_cdprogra, 
                                INPUT aux_flextjus,
                                OUTPUT TABLE tt-creditos,
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
          RUN piXmlExport (INPUT TEMP-TABLE tt-creditos:HANDLE,
                           INPUT "creditos").
          RUN piXmlSave.
       END.

END PROCEDURE.

