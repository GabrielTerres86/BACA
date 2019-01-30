/*..............................................................................

    Programa: sistema/generico/procedures/xb1wgen0006.p
    Autor   : Murilo/David
    Data    : Junho/2007                      Ultima atualizacao: 19/07/2018

    Dados referentes ao programa:

    Objetivo  : BO de Comunicacao XML Vs BO de Poupanca Programada

    Alteracoes: 16/03/2010 - Adaptacao para rotina de Poup.Programada (David).
    
                05/05/2010 - Incluir campo de Tipo de impressao de extrato 
                             (Gabriel).   obtem-dados-inclusao
                             
                26/12/2011 - Alteração nas procedures 'obtem-dados-inclusao' 
                             e'validar-dados-inclusao' para cálculo de prazo 
                             de vencimento da Poup. Prog (Lucas).
                             
                19/07/2018 - Proj. 411.2 - Poupança Programada -> Aplicação Programada
				
..............................................................................*/


DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_nrctrrpp AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrmesusp AS INTE                                           NO-UNDO.
DEF VAR aux_mesdtvct AS INTE                                           NO-UNDO.
DEF VAR aux_anodtvct AS INTE                                           NO-UNDO.
DEF VAR aux_cdtiparq AS INTE                                           NO-UNDO.
DEF VAR aux_tpemiext AS INTE                                           NO-UNDO.

DEF VAR aux_dtiniper AS DATE                                           NO-UNDO.
DEF VAR aux_dtfimper AS DATE                                           NO-UNDO.
DEF VAR aux_dtresgat AS DATE                                           NO-UNDO.
DEF VAR aux_dtinirpp AS DATE                                           NO-UNDO.

DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_cdprogra AS CHAR                                           NO-UNDO.
DEF VAR aux_tpresgat AS CHAR                                           NO-UNDO.
DEF VAR aux_nmcampos AS CHAR                                           NO-UNDO.

DEF VAR aux_vlsldrpp AS DECI DECIMALS 8                                NO-UNDO.
DEF VAR aux_vlresgat AS DECI                                           NO-UNDO.
DEF VAR aux_vlrrsgat AS DECI                                           NO-UNDO.
DEF VAR aux_nrdocmto AS DECI                                           NO-UNDO.
DEF VAR aux_vlprerpp AS DECI                                           NO-UNDO.
DEF VAR aux_cddsenha AS CHAR                                           NO-UNDO.

DEF VAR aux_flgsenha AS INTE                                           NO-UNDO.
DEF VAR aux_flgctain AS LOGI                                           NO-UNDO.
DEF VAR aux_flgoprgt AS LOGI                                           NO-UNDO.
DEF VAR aux_flgcance AS LOGI                                           NO-UNDO.
DEF VAR aux_flgerlog AS LOGI  INIT TRUE                                NO-UNDO.

DEF VAR aux_cdprodut AS INTE                                           NO-UNDO.
DEF VAR aux_dsfinali AS CHAR                                           NO-UNDO.
DEF VAR aux_flgteimo AS INTE                                           NO-UNDO.
DEF VAR aux_flgdbpar AS INTE                                           NO-UNDO.

DEF VAR aux_dtmaxvct AS DATE FORMAT "99/99/9999"                       NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_nrrdcapp AS INTE										   NO-UNDO.

{ sistema/generico/includes/b1wgen0006tt.i }
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
            WHEN "cdprogra" THEN aux_cdprogra = tt-param.valorCampo.
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "nrctrrpp" THEN aux_nrctrrpp = INTE(tt-param.valorCampo).
            WHEN "dtiniper" THEN aux_dtiniper = DATE(tt-param.valorCampo).
            WHEN "dtfimper" THEN aux_dtfimper = DATE(tt-param.valorCampo).
            WHEN "nrmesusp" THEN aux_nrmesusp = INTE(tt-param.valorCampo).
            WHEN "tpresgat" THEN aux_tpresgat = tt-param.valorCampo.
            WHEN "vlresgat" THEN aux_vlresgat = DECI(tt-param.valorCampo).
            WHEN "dtresgat" THEN aux_dtresgat = DATE(tt-param.valorCampo).
            WHEN "flgoprgt" THEN aux_flgoprgt = LOGICAL(tt-param.valorCampo).
            WHEN "flgctain" THEN aux_flgctain = LOGICAL(tt-param.valorCampo).
            WHEN "flgcance" THEN aux_flgcance = LOGICAL(tt-param.valorCampo).
            WHEN "nrdocmto" THEN aux_nrdocmto = DECI(tt-param.valorCampo).
            WHEN "vlprerpp" THEN aux_vlprerpp = DECI(tt-param.valorCampo).
            WHEN "dtinirpp" THEN aux_dtinirpp = DATE(tt-param.valorCampo).
            WHEN "mesdtvct" THEN aux_mesdtvct = INTE(tt-param.valorCampo).
            WHEN "anodtvct" THEN aux_anodtvct = INTE(tt-param.valorCampo).
            WHEN "tpemiext" THEN aux_tpemiext = INTE(tt-param.valorCampo). 
            WHEN "nrdrowid" THEN aux_nrdrowid = TO-ROWID(tt-param.valorCampo).
            WHEN "cdtiparq" THEN aux_cdtiparq = INTE(tt-param.valorCampo).
            WHEN "flgerlog" THEN aux_flgerlog = LOGICAL(tt-param.valorCampo).
            WHEN "dtmaxvct" THEN aux_dtmaxvct = DATE(tt-param.valorCampo).
            WHEN "vlrrsgat" THEN aux_vlrrsgat = DECI(tt-param.valorCampo).
            WHEN "cddsenha" THEN aux_cddsenha = tt-param.valorCampo.
            WHEN "flgsenha" THEN aux_flgsenha = INTE(tt-param.valorCampo).
            WHEN "cdprodut" THEN aux_cdprodut = INTE(tt-param.valorCampo).
            WHEN "dsfinali" THEN aux_dsfinali = tt-param.valorCampo.
            WHEN "flgteimo" THEN aux_flgteimo = INTE(tt-param.valorCampo).
            WHEN "flgdbpar" THEN aux_flgdbpar = INTE(tt-param.valorCampo).

        END CASE.
    
    END. /** Fim do FOR EACH tt-param **/
    
END PROCEDURE.


/******************************************************************************/
/**  Procedure para consultar saldo e demais dados de poupancas programadas  **/
/******************************************************************************/
PROCEDURE consulta-poupanca:

    RUN consulta-poupanca IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT aux_nrctrrpp,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_dtmvtopr,
                                  INPUT aux_inproces,
                                  INPUT aux_cdprogra,
                                  INPUT aux_flgerlog,
                                 OUTPUT aux_vlsldrpp,
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-dados-rpp).
    
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-rpp:HANDLE,
                             INPUT "Dados").
            RUN piXmlAtributo (INPUT "vlsldrpp",INPUT STRING(aux_vlsldrpp)).
            RUN piXmlSave.
        END.
 
END PROCEDURE.


/******************************************************************************/
/**           Procedure para atualizar dados da poupanca programada          **/
/******************************************************************************/
PROCEDURE atualizar-dados-poupanca:

    RUN atualizar-dados-poupanca IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_nmdatela,
                                         INPUT aux_idorigem,
                                         INPUT aux_nrdconta,
                                         INPUT aux_idseqttl,
                                         INPUT aux_nrctrrpp,
                                         INPUT aux_dtmvtolt,
                                         INPUT aux_dtmvtopr,
                                         INPUT aux_inproces,
                                         INPUT aux_cdprogra,
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
/**          Procedure para consultar extrato da poupanca programada         **/
/******************************************************************************/
PROCEDURE consulta-extrato-poupanca:
    
    RUN consulta-extrato-poupanca IN hBO (INPUT aux_cdcooper,
                                          INPUT aux_cdagenci,
                                          INPUT aux_nrdcaixa,
                                          INPUT aux_cdoperad,
                                          INPUT aux_nmdatela,
                                          INPUT aux_idorigem,
                                          INPUT aux_nrdconta,
                                          INPUT aux_idseqttl,
                                          INPUT aux_nrctrrpp,
                                          INPUT aux_dtiniper,
                                          INPUT aux_dtfimper,
                                          INPUT TRUE,
                                          OUTPUT TABLE tt-erro,
                                          OUTPUT TABLE tt-extr-rpp).
    
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-extr-rpp:HANDLE,
                        INPUT "Dados").
 
END PROCEDURE.


/******************************************************************************/
/**                Procedure para cancelar poupanca programada               **/
/******************************************************************************/
PROCEDURE cancelar-poupanca:
 
    RUN cancelar-poupanca IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT aux_nrctrrpp,
                                  INPUT aux_dtmvtolt,
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
/**       Procedure que obtem dados para suspender poupanca programada       **/
/******************************************************************************/
PROCEDURE obtem-dados-suspensao:
 
    RUN obtem-dados-suspensao IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nmdatela,
                                      INPUT aux_idorigem,
                                      INPUT aux_nrdconta,
                                      INPUT aux_idseqttl,
                                      INPUT aux_nrctrrpp,
                                      INPUT aux_dtmvtolt,
                                      INPUT aux_dtmvtopr,
                                      INPUT aux_inproces,
                                      INPUT aux_cdprogra,
                                      INPUT TRUE,
                                     OUTPUT TABLE tt-erro,
                                     OUTPUT TABLE tt-dados-rpp).

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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-dados-rpp:HANDLE,
                        INPUT "Dados").

END PROCEDURE.


/******************************************************************************/
/**     Procedure para validar dados para suspender poupanca programada     **/
/******************************************************************************/
PROCEDURE validar-dados-suspensao:

    RUN validar-dados-suspensao IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nmdatela,
                                        INPUT aux_idorigem,
                                        INPUT aux_nrdconta,
                                        INPUT aux_idseqttl,
                                        INPUT aux_nrctrrpp,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_nrmesusp,
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
/**              Procedure para suspender a poupanca programada              **/
/******************************************************************************/
PROCEDURE suspender-poupanca:
 
    RUN suspender-poupanca IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nmdatela,
                                   INPUT aux_idorigem,
                                   INPUT aux_nrdconta,
                                   INPUT aux_idseqttl,
                                   INPUT aux_nrctrrpp,
                                   INPUT aux_dtmvtolt,
                                   INPUT aux_nrmesusp,
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
/**              Procedure para reativar a poupanca programada               **/
/******************************************************************************/
PROCEDURE reativar-poupanca:
 
    RUN reativar-poupanca IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT aux_nrctrrpp,
                                  INPUT aux_dtmvtolt,
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
/**              Procedure para reativar a aplicacao programada              **/
/******************************************************************************/
PROCEDURE reativar-aplicacao-programada:
 
    RUN reativar-aplicacao-programada IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT aux_nrctrrpp,
                                  INPUT aux_dtmvtolt,
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
/**     Procedure para validar dados do resgate ou acesso a opcao resgate    **/
/******************************************************************************/
PROCEDURE valida-resgate:
 
    RUN valida-resgate IN hBO (INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nmdatela,
                               INPUT aux_idorigem,
                               INPUT aux_nrdconta,
                               INPUT aux_idseqttl,
                               INPUT aux_nrctrrpp,
                               INPUT aux_dtmvtolt,
                               INPUT aux_dtmvtopr,
                               INPUT aux_inproces,
                               INPUT aux_cdprogra,
                               INPUT aux_tpresgat,
                               INPUT aux_vlresgat,
                               INPUT aux_dtresgat,
                               INPUT aux_flgoprgt,
                               INPUT TRUE,
                              OUTPUT aux_vlsldrpp,
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
            RUN piXmlAtributo (INPUT "vlresgat", INPUT STRING(aux_vlsldrpp, "zzz,zzz,zz9.99")).
            RUN piXmlSave.
        END.

END PROCEDURE.


PROCEDURE validar-limite-resgate:

    RUN validar-limite-resgate IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_idorigem,
                                       INPUT aux_nmdatela,
                                       INPUT aux_idseqttl,
                                       INPUT aux_nrdconta,
                                       INPUT aux_vlrrsgat,
                                       INPUT aux_cdoperad,
                                       INPUT aux_cddsenha,
                                       INPUT aux_flgsenha,
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
/**           Procedure para efetuar resgate da poupanca programada          **/
/******************************************************************************/
PROCEDURE efetuar-resgate:
    
    RUN efetuar-resgate IN hBO (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT aux_nrdconta,
                                INPUT aux_idseqttl,
                                INPUT aux_nrctrrpp,
                                INPUT aux_dtmvtolt,
                                INPUT aux_dtmvtopr,
                                INPUT aux_tpresgat,
                                INPUT aux_vlresgat,
                                INPUT aux_dtresgat,
                                INPUT aux_flgctain,
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
/**         Procedure para consultar resgates da poupanca programada         **/
/******************************************************************************/
PROCEDURE consultar-resgates:
 
    RUN consultar-resgates IN hBO (INPUT aux_cdcooper, 
                                   INPUT aux_cdagenci, 
                                   INPUT aux_nrdcaixa, 
                                   INPUT aux_cdoperad, 
                                   INPUT aux_nmdatela, 
                                   INPUT aux_idorigem, 
                                   INPUT aux_nrdconta, 
                                   INPUT aux_idseqttl, 
                                   INPUT aux_nrctrrpp, 
                                   INPUT aux_flgcance, 
                                   INPUT TRUE, 
                                  OUTPUT TABLE tt-resgates-rpp).

    RUN piXmlSaida (INPUT TEMP-TABLE tt-resgates-rpp:HANDLE,
                    INPUT "Dados").
    
END PROCEDURE.


/******************************************************************************/
/**          Procedure para cancelar resgate da poupanca programada          **/
/******************************************************************************/
PROCEDURE cancelar-resgate:
 
    RUN cancelar-resgate IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nmdatela,
                                 INPUT aux_idorigem,
                                 INPUT aux_nrdconta,
                                 INPUT aux_idseqttl,
                                 INPUT aux_nrctrrpp,
                                 INPUT aux_nrdocmto,
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
/**        Procedure que obtem dados para alterar poupanca programada        **/
/******************************************************************************/
PROCEDURE obtem-dados-alteracao:
 
    RUN obtem-dados-alteracao IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nmdatela,
                                      INPUT aux_idorigem,
                                      INPUT aux_nrdconta,
                                      INPUT aux_idseqttl,
                                      INPUT aux_nrctrrpp,
                                      INPUT aux_dtmvtolt,
                                      INPUT aux_dtmvtopr,
                                      INPUT aux_inproces,
                                      INPUT aux_cdprogra,
                                      INPUT TRUE,
                                     OUTPUT TABLE tt-erro,
                                     OUTPUT TABLE tt-dados-rpp).

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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-dados-rpp:HANDLE,
                        INPUT "Dados").

END PROCEDURE.


/******************************************************************************/
/**    Procedure para validar dados da poupanca programada para alteracao    **/
/******************************************************************************/
PROCEDURE validar-dados-alteracao:
 
    RUN validar-dados-alteracao IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nmdatela,
                                        INPUT aux_idorigem,
                                        INPUT aux_nrdconta,
                                        INPUT aux_idseqttl,
                                        INPUT aux_nrctrrpp,
                                        INPUT aux_vlprerpp,
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
/**            Procedure para alterar dados da poupanca programada           **/
/******************************************************************************/
PROCEDURE alterar-poupanca-programada:
 
    RUN alterar-poupanca-programada IN hBO (INPUT aux_cdcooper, 
                                            INPUT aux_cdagenci, 
                                            INPUT aux_nrdcaixa, 
                                            INPUT aux_cdoperad, 
                                            INPUT aux_nmdatela, 
                                            INPUT aux_idorigem, 
                                            INPUT aux_nrdconta, 
                                            INPUT aux_idseqttl, 
                                            INPUT aux_nrctrrpp, 
                                            INPUT aux_dtmvtolt, 
                                            INPUT aux_vlprerpp, 
                                            INPUT TRUE, 
                                           OUTPUT aux_nrdrowid,
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
            RUN piXmlAtributo (INPUT "nrdrowid",INPUT STRING(aux_nrdrowid)).
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************/
/**        Procedure que obtem dados para incluir poupanca programada        **/
/******************************************************************************/
PROCEDURE obtem-dados-inclusao:
 
    RUN obtem-dados-inclusao IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nmdatela,
                                     INPUT aux_idorigem,
                                     INPUT aux_nrdconta,
                                     INPUT aux_idseqttl,
                                     INPUT aux_dtmvtolt,
                                     INPUT aux_cdprogra,
                                     INPUT TRUE,
                                     INPUT-OUTPUT aux_dtinirpp,
                                     OUTPUT aux_dtmaxvct,
                                     OUTPUT aux_tpemiext,
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
            RUN piXmlAtributo (INPUT "dtmaxvct", INPUT STRING(aux_dtmaxvct, "99/99/9999")).
            RUN piXmlAtributo (INPUT "dtinirpp", INPUT STRING(aux_dtinirpp, "99/99/9999")).      
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************/
/**     Procedure para validar dados da poupanca programada para inclusao    **/
/******************************************************************************/
PROCEDURE validar-dados-inclusao:
 
    RUN validar-dados-inclusao IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdoperad,
                                       INPUT aux_nmdatela,
                                       INPUT aux_idorigem,
                                       INPUT aux_nrdconta,
                                       INPUT aux_idseqttl,
                                       INPUT aux_dtmvtolt,
                                       INPUT aux_dtinirpp,
                                       INPUT aux_mesdtvct,
                                       INPUT aux_anodtvct,
                                       INPUT aux_vlprerpp,
                                       INPUT aux_tpemiext,
                                       INPUT TRUE,
                                       OUTPUT aux_nmcampos,
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

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmcampos", INPUT STRING(aux_nmcampos)).
            RUN piXmlSave. 

        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************/
/**                Procedure para incluir poupanca programada                **/
/******************************************************************************/
PROCEDURE incluir-poupanca-programada:
 
    RUN incluir-poupanca-programada IN hBO (INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_cdoperad,
                                            INPUT aux_nmdatela,
                                            INPUT aux_idorigem,
                                            INPUT aux_nrdconta,
                                            INPUT aux_idseqttl,
                                            INPUT aux_dtmvtolt,
                                            INPUT aux_dtinirpp,
                                            INPUT aux_mesdtvct,
                                            INPUT aux_anodtvct,
                                            INPUT aux_vlprerpp,
                                            INPUT aux_tpemiext,
                                            INPUT TRUE,
                                           OUTPUT aux_nrdrowid,
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
            RUN piXmlAtributo (INPUT "nrdrowid",INPUT STRING(aux_nrdrowid)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************/
/**                Procedure para incluir aplicacao programada               **/
/******************************************************************************/
PROCEDURE incluir-aplicacao-programada:
 
    RUN incluir-aplicacao-programada IN hBO (INPUT aux_cdcooper,
                                             INPUT aux_cdagenci,
                                             INPUT aux_nrdcaixa,
                                             INPUT aux_cdoperad,
                                             INPUT aux_nmdatela,
                                             INPUT aux_idorigem,
                                             INPUT aux_nrdconta,
                                             INPUT aux_idseqttl,
                                             INPUT aux_dtmvtolt,
                                             INPUT aux_dtinirpp,
                                             INPUT aux_mesdtvct,
                                             INPUT aux_anodtvct,
                                             INPUT aux_vlprerpp,
                                             INPUT aux_tpemiext,
                                             INPUT TRUE,
											 INPUT aux_cdprodut,
											 INPUT aux_dsfinali,
											 INPUT aux_flgteimo,
											 INPUT aux_flgdbpar,
                                            OUTPUT aux_nrdrowid,
											OUTPUT aux_nrrdcapp,
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
            RUN piXmlAtributo (INPUT "nrdrowid",INPUT STRING(aux_nrdrowid)).
            RUN piXmlAtributo (INPUT "nrrdcapp",INPUT STRING(aux_nrrdcapp)).
            RUN piXmlSave.
        END.

END PROCEDURE.



/******************************************************************************/
/**      Procedure para impressao de autorizacao da poupanca programada      **/
/******************************************************************************/
PROCEDURE obtem-dados-autorizacao:
 
    RUN obtem-dados-autorizacao IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nmdatela,
                                        INPUT aux_idorigem,
                                        INPUT aux_nrdconta,
                                        INPUT aux_idseqttl,
                                        INPUT aux_nrdrowid,
                                        INPUT aux_cdtiparq,
                                        INPUT aux_dtmvtolt,
                                        INPUT TRUE,
                                       OUTPUT TABLE tt-erro,
                                       OUTPUT TABLE tt-autoriza-rpp).

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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-autoriza-rpp:HANDLE,
                        INPUT "Dados").

END PROCEDURE.


/*............................................................................*/
