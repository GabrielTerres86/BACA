/*.............................................................................

    Programa: sistema/generico/procedures/xb1wgen0071.p
    Autor   : David
    Data    : Maio/2010                      Ultima atualizacao: 22/09/2010

    Dados referentes ao programa:

    Objetivo  : BO de Comunicacao XML Vs BO da rotina EMAILS (b1wgen0071.p).

    Alteracoes: 22/09/2010 -  Recebe parametro 'msgconta' no busca_dados 
                              e passa no XML. (Gabriel - DB1).
    
.............................................................................*/
                                                                            
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.

DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdemail AS CHAR                                           NO-UNDO.
DEF VAR aux_secpscto AS CHAR                                           NO-UNDO.
DEF VAR aux_nmpescto AS CHAR                                           NO-UNDO.
DEF VAR aux_prgqfalt AS CHAR                                           NO-UNDO.
DEF VAR aux_msgconta AS CHAR                                           NO-UNDO.
DEF VAR aux_msgrvcad AS CHAR                                           NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

{ sistema/generico/includes/b1wgen0071tt.i }
{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-WEB=SIM }

                                             
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
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "nrdrowid" THEN aux_nrdrowid = TO-ROWID(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "dsdemail" THEN aux_dsdemail = tt-param.valorCampo.
            WHEN "secpscto" THEN aux_secpscto = tt-param.valorCampo.
            WHEN "nmpescto" THEN aux_nmpescto = tt-param.valorCampo.
            WHEN "prgqfalt" THEN aux_prgqfalt = tt-param.valorCampo.
            WHEN "inpessoa" THEN aux_inpessoa = INTE(tt-param.valorCampo).
            WHEN "chavealt" THEN aux_chavealt = tt-param.valorCampo.
            WHEN "tpatlcad" THEN aux_tpatlcad = INTE(tt-param.valorCampo).

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.    


/*****************************************************************************/
/**              Procedure para retornar e-mails do cooperado               **/
/*****************************************************************************/
PROCEDURE obtem-email-cooperado: 

    RUN obtem-email-cooperado IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nmdatela,
                                      INPUT aux_idorigem,
                                      INPUT aux_nrdconta,
                                      INPUT aux_idseqttl,
                                      INPUT TRUE,
                                     OUTPUT aux_msgconta,
                                     OUTPUT TABLE tt-email-cooperado).

    RUN piXmlNew.
    RUN piXmlExport (INPUT TEMP-TABLE tt-email-cooperado:HANDLE,
                     INPUT "Dados").
    RUN piXmlAtributo (INPUT "msgconta", INPUT aux_msgconta).
    RUN piXmlSave.

END PROCEDURE.


/*****************************************************************************/
/**              Procedure para obter dados para alterar e-mail             **/
/*****************************************************************************/
PROCEDURE obtem-dados-gerenciar-email: 

    RUN obtem-dados-gerenciar-email IN hBO (INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_cdoperad,
                                            INPUT aux_nmdatela,
                                            INPUT aux_idorigem,
                                            INPUT aux_nrdconta,
                                            INPUT aux_idseqttl,
                                            INPUT aux_cddopcao,
                                            INPUT aux_nrdrowid,
                                            INPUT TRUE,
                                           OUTPUT aux_inpessoa,
                                           OUTPUT TABLE tt-erro,
                                           OUTPUT TABLE tt-email-cooperado).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-email-cooperado:HANDLE,
                             INPUT "Dados").
            RUN piXmlAtributo (INPUT "inpessoa", INPUT STRING(aux_inpessoa)).
            RUN piXmlSave.
        END.

END PROCEDURE.


/*****************************************************************************/
/**          Procedure para validar alteracao/inclusao de e-mail            **/
/*****************************************************************************/
PROCEDURE validar-email: 

    RUN validar-email IN hBO (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_nrdconta,
                              INPUT aux_idseqttl,
                              INPUT aux_cddopcao,
                              INPUT aux_nrdrowid,
                              INPUT aux_dsdemail,
                              INPUT aux_secpscto,
                              INPUT aux_nmpescto,
                              INPUT TRUE,
                              INPUT 0, /* Conta replicadora */
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


/*****************************************************************************/
/**          Procedure para alteracao/inclusao/exclusao de e-mail           **/
/*****************************************************************************/
PROCEDURE gerenciar-email: 

    RUN gerenciar-email IN hBO (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT aux_nrdconta,
                                INPUT aux_idseqttl,
                                INPUT aux_cddopcao,
                                INPUT aux_dtmvtolt,
                                INPUT aux_nrdrowid,
                                INPUT aux_dsdemail,
                                INPUT aux_secpscto,
                                INPUT aux_nmpescto,
                                INPUT aux_prgqfalt,
                                INPUT TRUE,
                               OUTPUT aux_tpatlcad,
                               OUTPUT aux_msgatcad,
                               OUTPUT aux_chavealt,
                               OUTPUT aux_msgrvcad,
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
            RUN piXmlAtributo (INPUT "tpatlcad", INPUT STRING(aux_tpatlcad)).
            RUN piXmlAtributo (INPUT "msgrvcad", INPUT aux_msgrvcad).
            RUN piXmlAtributo (INPUT "msgatcad", INPUT aux_msgatcad).
            RUN piXmlAtributo (INPUT "chavealt", INPUT aux_chavealt).
            RUN piXmlSave.
        END.

END PROCEDURE.


/*...........................................................................*/
