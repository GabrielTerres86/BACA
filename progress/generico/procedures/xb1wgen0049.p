/*..............................................................................

    Programa: xb1wgen0049.p
    Autor   : Jose Luis
    Data    : Marco/2010                   Ultima atualizacao: 19/04/2011   

    Objetivo  : BO de Comunicacao XML x BO - REFERENCIAS - PJ

    Alteracoes: 19/04/2011 - Inclusão campo CEP na chamada do procedimento
                             validar_dados_contato. (André - DB1)
   
..............................................................................*/

                                                                             
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_nrdctato AS INTE                                           NO-UNDO.
DEF VAR aux_cddbanco AS INTE                                           NO-UNDO.
DEF VAR aux_cdageban AS INTE                                           NO-UNDO.
DEF VAR aux_nrendere AS INTE                                           NO-UNDO.
DEF VAR aux_nrcepend AS INTE                                           NO-UNDO.
DEF VAR aux_nrcxapst AS INTE                                           NO-UNDO.

DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdavali AS CHAR                                           NO-UNDO.
DEF VAR aux_nmextemp AS CHAR                                           NO-UNDO.
DEF VAR aux_dsproftl AS CHAR                                           NO-UNDO.
DEF VAR aux_dsendere AS CHAR                                           NO-UNDO.
DEF VAR aux_complend AS CHAR                                           NO-UNDO.
DEF VAR aux_nmbairro AS CHAR                                           NO-UNDO.
DEF VAR aux_nmcidade AS CHAR                                           NO-UNDO.
DEF VAR aux_cdufende AS CHAR                                           NO-UNDO.
DEF VAR aux_nrtelefo AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdemail AS CHAR                                           NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

{ sistema/generico/includes/b1wgen0049tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-WEB=SIM }


/*............................... PROCEDURES ................................*/

    
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
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "nrdrowid" THEN aux_nrdrowid = TO-ROWID(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "nrdctato" THEN aux_nrdctato = INTE(tt-param.valorCampo).
            WHEN "nmdavali" THEN aux_nmdavali = tt-param.valorCampo.
            WHEN "nmextemp" THEN aux_nmextemp = tt-param.valorCampo.
            WHEN "cddbanco" THEN aux_cddbanco = INTE(tt-param.valorCampo).
            WHEN "cdageban" THEN aux_cdageban = INTE(tt-param.valorCampo).
            WHEN "dsproftl" THEN aux_dsproftl = tt-param.valorCampo.
            WHEN "dsendere" THEN aux_dsendere = tt-param.valorCampo.
            WHEN "nrendere" THEN aux_nrendere = INTE(tt-param.valorCampo).
            WHEN "complend" THEN aux_complend = tt-param.valorCampo.
            WHEN "nrcepend" THEN aux_nrcepend = INTE(tt-param.valorCampo).
            WHEN "nrcxapst" THEN aux_nrcxapst = INTE(tt-param.valorCampo).
            WHEN "nmbairro" THEN aux_nmbairro = tt-param.valorCampo.
            WHEN "nmcidade" THEN aux_nmcidade = tt-param.valorCampo.
            WHEN "cdufende" THEN aux_cdufende = tt-param.valorCampo.
            WHEN "nrtelefo" THEN aux_nrtelefo = tt-param.valorCampo.
            WHEN "dsdemail" THEN aux_dsdemail = tt-param.valorCampo.
            WHEN "chavealt" THEN aux_chavealt = tt-param.valorCampo.
            WHEN "tpatlcad" THEN aux_tpatlcad = INTE(tt-param.valorCampo).

        END CASE.
                 
    END. /** Fim do FOR EACH tt-param **/
                 
END PROCEDURE.    


/******************************************************************************/
/**               Procedure para carregar contatos do associado              **/
/******************************************************************************/
PROCEDURE obtem-contatos:

    RUN obtem-contatos IN hBO (INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nmdatela,
                               INPUT aux_idorigem,
                               INPUT aux_nrdconta,
                               INPUT aux_idseqttl,
                               INPUT TRUE,
                              OUTPUT TABLE tt-contato-juridica,
                              OUTPUT TABLE tt-erro) .

    IF  RETURN-VALUE = "NOK"  THEN
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-contato-juridica:HANDLE,
                        INPUT "Referencias").

END PROCEDURE.


/******************************************************************************/
/**                 Procedure para consultar dados do contato                **/
/******************************************************************************/
PROCEDURE consultar-dados-contato:

    RUN consultar-dados-contato IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nmdatela,
                                        INPUT aux_idorigem,
                                        INPUT aux_nrdconta,
                                        INPUT aux_idseqttl,
                                        INPUT aux_nrdrowid,
                                        INPUT aux_cddopcao,
                                        INPUT TRUE,
                                       OUTPUT TABLE tt-contato-jur,
                                       OUTPUT TABLE tt-erro) .

    IF  RETURN-VALUE = "NOK"  THEN
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-contato-jur:HANDLE,
                        INPUT "ContatoJur").

END PROCEDURE.


/******************************************************************************/
/**   Procedure para consultar dados de determinado cooperado para contato   **/
/******************************************************************************/
PROCEDURE consultar-dados-cooperado-contato:

    RUN consultar-dados-cooperado-contato IN hBO (INPUT aux_cdcooper,
                                                  INPUT aux_cdagenci,
                                                  INPUT aux_nrdcaixa,
                                                  INPUT aux_cdoperad,
                                                  INPUT aux_nmdatela,
                                                  INPUT aux_idorigem,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_nrdctato,
                                                  INPUT TRUE,
                                                 OUTPUT TABLE tt-contato-jur,
                                                 OUTPUT TABLE tt-erro) .

    IF  RETURN-VALUE = "NOK"  THEN
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-contato-jur:HANDLE,
                             INPUT "ContatoJurCoop").
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************/
/**                  Procedure para validar dados do contato                 **/
/******************************************************************************/
PROCEDURE validar-dados-contato:

    RUN validar-dados-contato IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nmdatela,
                                      INPUT aux_idorigem,
                                      INPUT aux_nrdconta,
                                      INPUT aux_idseqttl,
                                      INPUT aux_nrdctato,
                                      INPUT aux_nmdavali,
                                      INPUT aux_nmextemp,
                                      INPUT aux_cddbanco,
                                      INPUT aux_cdageban,
                                      INPUT aux_nrtelefo,
                                      INPUT aux_dsdemail,
                                      INPUT aux_cddopcao,
                                      INPUT TRUE,
                                      INPUT aux_nrcepend,
                                      INPUT aux_dsendere,
                                     OUTPUT TABLE tt-erro) .

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "validacao de dados.".
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
/**               Procedure para gerenciar contato do associado              **/
/******************************************************************************/
PROCEDURE gerenciar-contato:

    RUN gerenciar-contato IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_cddopcao,
                                  INPUT aux_nrdrowid,
                                  INPUT aux_nrdctato,
                                  INPUT aux_nmdavali,
                                  INPUT aux_nmextemp,
                                  INPUT aux_cddbanco,
                                  INPUT aux_cdageban,
                                  INPUT aux_dsproftl,
                                  INPUT aux_dsendere,
                                  INPUT aux_nrendere,
                                  INPUT aux_complend,
                                  INPUT aux_nrcepend,
                                  INPUT aux_nrcxapst,
                                  INPUT aux_nmbairro,
                                  INPUT aux_nmcidade,
                                  INPUT aux_cdufende,
                                  INPUT aux_nrtelefo,
                                  INPUT aux_dsdemail,
                                  INPUT TRUE,         
                                 OUTPUT aux_tpatlcad,
                                 OUTPUT aux_msgatcad,
                                 OUTPUT aux_chavealt,
                                 OUTPUT TABLE tt-erro).
                                                      
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
          
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "inclusao de dados.".
                END.
          
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "tpatlcad", INPUT STRING(aux_tpatlcad)).
            RUN piXmlAtributo (INPUT "msgatcad", INPUT aux_msgatcad).
            RUN piXmlAtributo (INPUT "chavealt", INPUT aux_chavealt).
            RUN piXmlSave.
        END.

END PROCEDURE.

/*............................................................................*/

