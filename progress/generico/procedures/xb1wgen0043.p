/*.............................................................................

    Programa: sistema/generico/procedures/xb1wgen0043.p
    Autor   : David
    Data    : Abril/2010                      Ultima Atualizacao: 08/04/2011
                                                                      
    Dados referentes ao programa:
  
    Objetivo  : BO de comunicacao XML referente ao RATING do cooperado.
  
    Alteracoes: 05/04/2011 - Incluso TABLE tt-impressao-risco-tl (Guilherme).
    
                08/04/2011 - Chamada para procedure 'lista_criticas'.
                             (Gabriel/DB1).    
    
.............................................................................*/

                                                                            
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_nrgarope AS INTE                                           NO-UNDO.
DEF VAR aux_nrinfcad AS INTE                                           NO-UNDO.
DEF VAR aux_nrliquid AS INTE                                           NO-UNDO.
DEF VAR aux_nrpatlvr AS INTE                                           NO-UNDO.
DEF VAR aux_nrperger AS INTE                                           NO-UNDO.
DEF VAR aux_tpctrrat AS INTE                                           NO-UNDO.
DEF VAR aux_nrctrrat AS INTE                                           NO-UNDO.
DEF VAR aux_tpctrato AS INTE                                           NO-UNDO.
DEF VAR aux_nrctrato AS INTE                                           NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.
DEF VAR aux_insitrat AS INTE                                           NO-UNDO.

DEF VAR aux_dtinirat AS DATE                                           NO-UNDO.
DEF VAR aux_dtfinrat AS DATE                                           NO-UNDO.

DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.

DEF VAR aux_flgcriar AS LOGI                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0043tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }


/*................................ PROCEDURES ................................*/


/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/
PROCEDURE valores_entrada:

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.ValorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "nrgarope" THEN aux_nrgarope = INTE(tt-param.valorCampo). 
            WHEN "nrinfcad" THEN aux_nrinfcad = INTE(tt-param.valorCampo). 
            WHEN "nrliquid" THEN aux_nrliquid = INTE(tt-param.valorCampo). 
            WHEN "nrpatlvr" THEN aux_nrpatlvr = INTE(tt-param.valorCampo). 
            WHEN "nrperger" THEN aux_nrperger = INTE(tt-param.valorCampo).
            WHEN "tpctrrat" THEN aux_tpctrrat = INTE(tt-param.valorCampo).
            WHEN "nrctrrat" THEN aux_nrctrrat = INTE(tt-param.valorCampo).
            WHEN "inpessoa" THEN aux_inpessoa = INTE(tt-param.valorCampo).
            WHEN "insitrat" THEN aux_insitrat = INTE(tt-param.valorCampo).
            WHEN "dtinirat" THEN aux_dtinirat = DATE(tt-param.valorCampo).
            WHEN "dtfinrat" THEN aux_dtfinrat = DATE(tt-param.valorCampo).
            WHEN "tpctrato" THEN aux_tpctrato = INTE(tt-param.valorCampo).
            WHEN "nrctrato" THEN aux_nrctrato = INTE(tt-param.valorCampo).
            WHEN "flgcriar" THEN aux_flgcriar = LOGICAL(tt-param.valorCampo).
        END CASE.
    
    END. /** Fim do FOR EACH tt-param **/
    
END PROCEDURE.


/******************************************************************************/
/**      Procedure para gerar o rating do cooperado e dados de impressao     **/
/******************************************************************************/
PROCEDURE gera_rating:
    
    RUN gera_rating IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrdconta,
                            INPUT aux_idseqttl,
                            INPUT aux_dtmvtolt,
                            INPUT aux_dtmvtopr,
                            INPUT aux_inproces,
                            INPUT aux_tpctrato,
                            INPUT aux_nrctrato,
                            INPUT aux_flgcriar,
                            INPUT TRUE,
                           OUTPUT TABLE tt-erro,
                           OUTPUT TABLE tt-cabrel,
                           OUTPUT TABLE tt-impressao-coop,
                           OUTPUT TABLE tt-impressao-rating,
                           OUTPUT TABLE tt-impressao-risco,
                           OUTPUT TABLE tt-impressao-risco-tl,
                           OUTPUT TABLE tt-impressao-assina,
                           OUTPUT TABLE tt-efetivacao,
                           OUTPUT TABLE tt-ratings).   

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-cabrel:HANDLE,
                             INPUT "Relatorio").
            RUN piXmlExport (INPUT TEMP-TABLE tt-impressao-coop:HANDLE,
                             INPUT "Cooperado").
            RUN piXmlExport (INPUT TEMP-TABLE tt-impressao-rating:HANDLE,
                             INPUT "Rating").
            RUN piXmlExport (INPUT TEMP-TABLE tt-impressao-risco:HANDLE,
                             INPUT "Risco").
            RUN piXmlExport (INPUT TEMP-TABLE tt-impressao-assina:HANDLE,
                             INPUT "Assinatura").
            RUN piXmlExport (INPUT TEMP-TABLE tt-efetivacao:HANDLE,
                             INPUT "Efetivacao").
            RUN piXmlExport (INPUT TEMP-TABLE tt-ratings:HANDLE,
                             INPUT "Rating_Cooperado").
            RUN piXmlExport (INPUT TEMP-TABLE tt-impressao-risco-tl:HANDLE,
                             INPUT "Risco_Cooperado").
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************/
/**           Procedure para buscar valores do rating do cooperado           **/
/******************************************************************************/
PROCEDURE busca_dados_rating:

    RUN busca_dados_rating IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_dtmvtolt,
                                   INPUT aux_nrdconta,
                                   INPUT aux_idorigem,
                                   INPUT aux_idseqttl,
                                   INPUT aux_nmdatela,
                                   INPUT TRUE,
                                  OUTPUT TABLE tt-erro,
                                  OUTPUT TABLE tt-valores-rating,
                                  OUTPUT TABLE tt-itens-topico-rating).
    
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-valores-rating:HANDLE,
                             INPUT "Valores").
            RUN piXmlExport (INPUT TEMP-TABLE tt-itens-topico-rating:HANDLE,
                             INPUT "Itens").
            RUN piXmlSave.
        END.
 
END PROCEDURE.

/******************************************************************************/
/**           Procedure para buscar valores do rating do cooperado           **/
/******************************************************************************/
PROCEDURE busca_dados_rating_completo:

    RUN busca_dados_rating_completo IN hBO (INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_cdoperad,
                                            INPUT aux_dtmvtolt,
                                            INPUT aux_nrdconta,
                                            INPUT aux_nrctrrat,
                                            INPUT aux_tpctrrat,
                                            INPUT aux_idorigem,
                                            INPUT aux_idseqttl,
                                            INPUT aux_nmdatela,
                                            INPUT TRUE,
                                           OUTPUT TABLE tt-erro,
                                           OUTPUT TABLE tt-valores-rating,
                                           OUTPUT TABLE tt-topicos-rating,
                                           OUTPUT TABLE tt-itens-rating,
                                           OUTPUT TABLE tt-itens-topico-rating).
    
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-valores-rating:HANDLE,
                             INPUT "Valores").
            RUN piXmlExport (INPUT TEMP-TABLE tt-topicos-rating:HANDLE,
                             INPUT "Topicos").
            RUN piXmlExport (INPUT TEMP-TABLE tt-itens-rating:HANDLE,
                             INPUT "Itens").
            RUN piXmlExport (INPUT TEMP-TABLE tt-itens-topico-rating:HANDLE,
                             INPUT "Sequencias").
            RUN piXmlSave.
        END.
 
END PROCEDURE.

/******************************************************************************/
/**  Atualizar valores do rating do cooperado e retornar possiveis criticas  **/
/******************************************************************************/
PROCEDURE atualiza_valores_rating:

    RUN atualiza_valores_rating IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nmdatela,
                                        INPUT aux_idorigem,
                                        INPUT aux_nrdconta,
                                        INPUT aux_idseqttl,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_inproces,
                                        INPUT aux_nrinfcad,
                                        INPUT aux_nrpatlvr,
                                        INPUT aux_nrperger,
                                        INPUT aux_tpctrrat,
                                        INPUT aux_nrctrrat,
                                        INPUT TRUE,
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


/******************************************************************************/
/**            Procedure para gravar dados do rating do cooperado            **/
/******************************************************************************/
PROCEDURE grava_rating:

    RUN grava_rating IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_dtmvtolt,
                             INPUT aux_nrdconta,
                             INPUT aux_inpessoa,
                             INPUT aux_nrinfcad,
                             INPUT aux_nrpatlvr,
                             INPUT aux_nrperger,
                             INPUT aux_idorigem,
                             INPUT aux_idseqttl,
                             INPUT aux_nmdatela,
                             INPUT TRUE,        
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


/******************************************************************************/
/**      Procedure para validar valores de itens do rating do cooperado      **/
/******************************************************************************/
PROCEDURE valida-itens-rating:

    RUN valida-itens-rating IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_dtmvtolt,   
                                    INPUT aux_nrdconta,   
                                    INPUT aux_nrgarope,
                                    INPUT aux_nrinfcad,
                                    INPUT aux_nrliquid,
                                    INPUT aux_nrpatlvr,
                                    INPUT aux_nrperger,
                                    INPUT aux_idseqttl,   
                                    INPUT aux_idorigem,
                                    INPUT aux_nmdatela,
                                    INPUT TRUE,
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


/******************************************************************************/
/**      Procedure que traz informacoes de todos os ratings do cooperado     **/
/******************************************************************************/
PROCEDURE ratings-cooperado:
         
    RUN ratings-cooperado IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_cdoperad,
                                  INPUT aux_idorigem,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_dtmvtopr,
                                  INPUT aux_nrdconta,
                                  INPUT aux_nrctrrat,
                                  INPUT aux_tpctrrat,
                                  INPUT aux_dtinirat,
                                  INPUT aux_dtfinrat,
                                  INPUT aux_insitrat,
                                  INPUT aux_inproces,
                                 OUTPUT TABLE tt-ratings).

    RUN piXmlSaida (INPUT TEMP-TABLE tt-ratings:HANDLE,
                    INPUT "Rating").

END PROCEDURE.

/***************************************************************************
 Usada no final das propostas de operaçoes. Para trazer as criticas
 (se existir) para a geraçao do Rating.
***************************************************************************/
PROCEDURE lista_criticas:

    RUN lista_criticas IN hBO 
                     ( INPUT aux_cdcooper,
                       INPUT aux_cdagenci,
                       INPUT aux_nrdcaixa,
                       INPUT aux_cdoperad,
                       INPUT aux_dtmvtolt,
                       INPUT aux_nrdconta,
                       INPUT aux_tpctrrat,
                       INPUT aux_nrctrrat,
                       INPUT aux_idseqttl,
                       INPUT aux_idorigem,
                       INPUT aux_nmdatela,
                       INPUT aux_inproces,
                       INPUT FALSE,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Rating").
            RUN piXmlSave.
        END.


END.


/*............................................................................*/
