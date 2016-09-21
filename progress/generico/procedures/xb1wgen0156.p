
/*..............................................................................

   Programa: xb1wgen0156.p
   Autor   : Jorge I. Hamaguchi
   Data    : Maio/2013                 Ultima atualizacao:

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO156 (b1wgen0156.p) [LOTPRC]

   Alteracoes: 

..............................................................................*/

DEF VAR aux_cdcooper AS INTE                                       NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                       NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                       NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                       NO-UNDO.
DEF VAR aux_idorigem AS INTE                                       NO-UNDO.
DEF VAR aux_nrdolote AS INTE                                       NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                       NO-UNDO.

DEF VAR aux_cdoperad AS CHAR                                       NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                       NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                       NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                       NO-UNDO.
DEF VAR aux_nmarqerr AS CHAR                                       NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                       NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                       NO-UNDO.

DEF VAR aux_vlprocap AS DECI                                       NO-UNDO.
DEF VAR aux_dtvencnd AS DATE                                       NO-UNDO.
DEF VAR aux_cdmunben AS INTE                                       NO-UNDO.
DEF VAR aux_cdgenben AS INTE                                       NO-UNDO.
DEF VAR aux_cdporben AS INTE                                       NO-UNDO.
DEF VAR aux_cdsetben AS INTE                                       NO-UNDO.
DEF VAR aux_dtcndfed AS DATE                                       NO-UNDO.
DEF VAR aux_dtcndfgt AS DATE                                       NO-UNDO.
DEF VAR aux_dtcndest AS DATE                                       NO-UNDO.
DEF VAR aux_dtcontrt AS DATE                                       NO-UNDO.
DEF VAR aux_dtpricar AS DATE                                       NO-UNDO.
DEF VAR aux_dtfincar AS DATE                                       NO-UNDO.
DEF VAR aux_dtpriamo AS DATE                                       NO-UNDO.
DEF VAR aux_dtultamo AS DATE                                       NO-UNDO.
DEF VAR aux_cdmunbce AS INTE                                       NO-UNDO.
DEF VAR aux_cdsetpro AS INTE                                       NO-UNDO.
DEF VAR aux_lstavali AS CHAR                                       NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                       NO-UNDO.
                                                                           
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgen0156tt.i }

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
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "nrdolote" THEN aux_nrdolote = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "nmdcampo" THEN aux_nmdcampo = tt-param.valorCampo.
            WHEN "vlprocap" THEN aux_vlprocap = DECI(tt-param.valorCampo).
            WHEN "dtvencnd" THEN aux_dtvencnd = DATE(tt-param.valorCampo).
            WHEN "cdmunben" THEN aux_cdmunben = INTE(tt-param.valorCampo).
            WHEN "cdgenben" THEN aux_cdgenben = INTE(tt-param.valorCampo).
            WHEN "cdporben" THEN aux_cdporben = INTE(tt-param.valorCampo).
            WHEN "cdsetben" THEN aux_cdsetben = INTE(tt-param.valorCampo).
            WHEN "dtcndfed" THEN aux_dtcndfed = DATE(tt-param.valorCampo).
            WHEN "dtcndfgt" THEN aux_dtcndfgt = DATE(tt-param.valorCampo).
            WHEN "dtcndest" THEN aux_dtcndest = DATE(tt-param.valorCampo).
            WHEN "dtcontrt" THEN aux_dtcontrt = DATE(tt-param.valorCampo).
            WHEN "dtpricar" THEN aux_dtpricar = DATE(tt-param.valorCampo).
            WHEN "dtfincar" THEN aux_dtfincar = DATE(tt-param.valorCampo).
            WHEN "dtpriamo" THEN aux_dtpriamo = DATE(tt-param.valorCampo).
            WHEN "dtultamo" THEN aux_dtultamo = DATE(tt-param.valorCampo).
            WHEN "cdmunbce" THEN aux_cdmunbce = INTE(tt-param.valorCampo).
            WHEN "cdsetpro" THEN aux_cdsetpro = INTE(tt-param.valorCampo).
            WHEN "lstavali" THEN aux_lstavali = tt-param.valorCampo.
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "inpessoa" THEN aux_inpessoa = INTE(tt-param.valorCampo).
               
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.



/*****************************************************************************
  Abrir lote      
******************************************************************************/
PROCEDURE abrir_lote:
    
    RUN abrir_lote IN hBO (INPUT aux_cdcooper,
                           INPUT aux_cdagenci,
                           INPUT aux_nrdcaixa,
                           INPUT aux_cdoperad,
                           INPUT aux_dtmvtolt,
                          OUTPUT aux_nrdolote,
                          OUTPUT aux_nmdcampo,
                          OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
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
           RUN piXmlAtributo (INPUT "nrdolote",INPUT STRING(aux_nrdolote)).
           RUN piXmlAtributo (INPUT "flprocok",INPUT "OK").
           RUN piXmlSave.
        END.

END PROCEDURE.

/*****************************************************************************
  Incluir conta no lote      
******************************************************************************/
PROCEDURE incluir_conta_lote:

    RUN incluir_conta_lote IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_dtmvtolt,
                                   INPUT aux_nrdconta,
                                   INPUT aux_nrdolote,
                                   INPUT aux_vlprocap,
                                   INPUT aux_dtvencnd,
                                   INPUT aux_cdmunben,
                                   INPUT aux_cdgenben,
                                   INPUT aux_cdporben,
                                   INPUT aux_cdsetben,
                                   INPUT aux_dtcndfed,
                                   INPUT aux_dtcndfgt,
                                   INPUT aux_dtcndest,
                                   INPUT aux_lstavali,
                                  OUTPUT aux_nmdcampo,
                                  OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
                
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "flprocok",INPUT "OK").
           RUN piXmlSave.
        END.

END PROCEDURE.

/*****************************************************************************
  Consultar conta do lote      
******************************************************************************/
PROCEDURE consultar_conta_lote:

    RUN consultar_conta_lote IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_dtmvtolt,
                                     INPUT aux_nrdconta,
                                     INPUT aux_nrdolote,
                                     INPUT aux_cddopcao,
                                    OUTPUT aux_inpessoa,
                                    OUTPUT aux_nmdcampo,
                                    OUTPUT TABLE tt-contas-lote,
                                    OUTPUT TABLE tt-avalistas,
                                    OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:     
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-avalistas:HANDLE,
                             INPUT "avalistas").
            RUN piXmlAtributo (INPUT "flprocok",INPUT "OK").
            RUN piXmlAtributo (INPUT "inpessoa",INPUT aux_inpessoa).
            RUN piXmlExport (INPUT TEMP-TABLE tt-contas-lote:HANDLE,
                             INPUT "contaslote").
            RUN piXmlSave.
        END.

END PROCEDURE.

/*****************************************************************************
  Alterar conta do lote        
******************************************************************************/
PROCEDURE alterar_conta_lote:

    RUN alterar_conta_lote IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_dtmvtolt,
                                   INPUT aux_nrdconta,
                                   INPUT aux_nrdolote,
                                   INPUT aux_vlprocap,
                                   INPUT aux_dtvencnd,
                                   INPUT aux_cdmunben,
                                   INPUT aux_cdgenben,
                                   INPUT aux_cdporben,
                                   INPUT aux_cdsetben,
                                   INPUT aux_dtcndfed,
                                   INPUT aux_dtcndfgt,
                                   INPUT aux_dtcndest,
                                   INPUT aux_lstavali,
                                  OUTPUT aux_nmdcampo,
                                  OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "flprocok",INPUT "OK").
           RUN piXmlSave.
        END.

END PROCEDURE.

/*****************************************************************************
  Excluir conta do lote      
******************************************************************************/
PROCEDURE excluir_conta_lote:

    RUN excluir_conta_lote IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_dtmvtolt,
                                   INPUT aux_nrdconta,
                                   INPUT aux_nrdolote,
                                  OUTPUT aux_nmdcampo,
                                  OUTPUT TABLE tt-erro).
           
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "flprocok",INPUT "OK").
           RUN piXmlSave.
        END.

END PROCEDURE.

/*****************************************************************************
  Consultar lote      
******************************************************************************/
PROCEDURE consultar_lote:

    RUN consultar_lote IN hBO (INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_dtmvtolt,
                               INPUT aux_nrdolote,
                               INPUT aux_cddopcao,
                              OUTPUT aux_nmdcampo,
                              OUTPUT TABLE tt-lote,
                              OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:     
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-lote:HANDLE,
                             INPUT "lotes").
            RUN piXmlAtributo (INPUT "flprocok",INPUT "OK").
            RUN piXmlSave.
        END.

END PROCEDURE.


/*****************************************************************************
  Fechar lote      
******************************************************************************/
PROCEDURE fechar_lote:

    RUN fechar_lote IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_dtmvtolt,
                            INPUT aux_nrdolote,
                           OUTPUT aux_nmdcampo,
                           OUTPUT aux_nmarqerr,
                           OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlAtributo (INPUT "nmarqerr",INPUT aux_nmarqerr).
            RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "flprocok",INPUT "OK").
           RUN piXmlSave.
        END.

END PROCEDURE.

/*****************************************************************************
  Reabrir lote      
******************************************************************************/
PROCEDURE reabrir_lote:

    RUN reabrir_lote IN hBO(INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_dtmvtolt,
                            INPUT aux_nrdolote,
                           OUTPUT aux_nmdcampo,
                           OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "flprocok",INPUT "OK").
           RUN piXmlSave.
        END.

END PROCEDURE.

/*****************************************************************************
  Finalizar lote      
******************************************************************************/
PROCEDURE finalizar_lote:

    RUN finalizar_lote IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_dtmvtolt,
                              INPUT aux_nrdolote,
                             OUTPUT aux_nmdcampo,
                             OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "flprocok",INPUT "OK").
           RUN piXmlSave.
        END.

END PROCEDURE.

/*****************************************************************************
  Incluir , Alterar informacoes do lote        
******************************************************************************/
PROCEDURE alterar_lote:

    RUN alterar_lote IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_dtmvtolt,
                             INPUT aux_nrdolote,
                             INPUT aux_dtcontrt,
                             INPUT aux_dtpricar,
                             INPUT aux_dtfincar,
                             INPUT aux_dtpriamo,
                             INPUT aux_dtultamo,
                             INPUT aux_cdmunbce,
                             INPUT aux_cdsetpro,
                            OUTPUT aux_nmdcampo,
                            OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "flprocok",INPUT "OK").
           RUN piXmlSave.
        END.

END PROCEDURE.


/*****************************************************************************
  Gerar arquivo para encaminhamento ao BRDE      
******************************************************************************/
PROCEDURE gerar_arq_enc_brde:

    RUN gerar_arq_enc_brde IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_dtmvtolt,
                                   INPUT aux_nrdolote,
                                  OUTPUT aux_nmarquiv,
                                  OUTPUT aux_nmdcampo,
                                  OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "flprocok",INPUT "OK").
           RUN piXmlAtributo (INPUT "nmarquiv",INPUT aux_nmarquiv).
           RUN piXmlSave.
        END.

END PROCEDURE.

/*****************************************************************************
  Gerar arquivo final ao BRDE      
******************************************************************************/
PROCEDURE gerar_arq_fin_brde:

    RUN gerar_arq_fin_brde IN hBO.
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
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
           RUN piXmlAtributo (INPUT "flprocok",INPUT "OK").
           RUN piXmlSave.
        END.

END PROCEDURE.

/*****************************************************************************
  Relatorio de lote      
******************************************************************************/
PROCEDURE relatorio_lote:

    RUN relatorio_lote IN hBO (INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_dtmvtolt,
                               INPUT aux_nrdolote,
                              OUTPUT aux_nmdcampo,
                              OUTPUT aux_nmarqimp,
                              OUTPUT aux_nmarqpdf,
                              OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "flprocok",INPUT "OK").
           RUN piXmlAtributo (INPUT "nmarqimp",INPUT aux_nmarqimp).
           RUN piXmlAtributo (INPUT "nmarqpdf",INPUT aux_nmarqpdf).
           RUN piXmlSave.
        END.

END PROCEDURE.

/*****************************************************************************
  Verificar Conta e Lote (valida e verifica se conta consta no lote)     
******************************************************************************/
PROCEDURE verificar_conta_lote:
    
    RUN verificar_conta_lote IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_dtmvtolt,
                                     INPUT aux_nrdconta,
                                     INPUT aux_nrdolote,
                                    OUTPUT aux_inpessoa,
                                    OUTPUT aux_nmdcampo,
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-avalistas).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-avalistas:HANDLE, 
                            INPUT "avalistas").
           RUN piXmlAtributo (INPUT "flprocok",INPUT "OK").
           RUN piXmlAtributo (INPUT "inpessoa",INPUT aux_inpessoa).
           RUN piXmlSave.
        END.

END PROCEDURE.
