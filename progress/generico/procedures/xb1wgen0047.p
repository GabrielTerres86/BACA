/*.............................................................................

    Programa: sistema/generico/procedures/xb1wgen0047.p
    Autor   : David
    Data    : Maio/2010                      Ultima atualizacao: 22/09/2010

    Dados referentes ao programa:

    Objetivo  : BO de Comunicacao XML Vs BO da rotina DEPENDENTES 

   Alteracoes: 22/09/2010 -  Recebe parametro 'msgconta' no busca_dados 
                              e passa no XML. (Gabriel - DB1).
    
.............................................................................*/


DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_cdtipdep AS INTE                                           NO-UNDO.

DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdepend AS CHAR                                           NO-UNDO.
DEF VAR aux_msgconta AS CHAR                                           NO-UNDO.
DEF VAR aux_msgrvcad AS CHAR                                           NO-UNDO.

DEF VAR aux_dtnascto AS DATE                                           NO-UNDO.
    
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

{ sistema/generico/includes/b1wgen0047tt.i }
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
            WHEN "nmdepend" THEN aux_nmdepend = tt-param.valorCampo.
            WHEN "dtnascto" THEN aux_dtnascto = DATE(tt-param.valorCampo).
            WHEN "cdtipdep" THEN aux_cdtipdep = INTE(tt-param.valorCampo).
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.    


/*****************************************************************************/
/**        Procedure para carregar dados dos dependentes do associado       **/
/*****************************************************************************/
PROCEDURE obtem-dependentes:

    RUN obtem-dependentes IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT TRUE,
                                 OUTPUT aux_msgconta,
                                 OUTPUT TABLE tt-dependente).

    RUN piXmlNew.
    RUN piXmlExport   (INPUT TEMP-TABLE tt-dependente:HANDLE,
                       INPUT "Dados").
    RUN piXmlAtributo (INPUT "msgconta", INPUT aux_msgconta).
    RUN piXmlSave.

END PROCEDURE.


/*****************************************************************************/
/**     Procedure que carrega dados para alteracao, exclusao ou inclusao    **/
/*****************************************************************************/
PROCEDURE obtem-dados-operacao:

    RUN obtem-dados-operacao IN hBO (INPUT aux_cdcooper,
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
                                    OUTPUT TABLE tt-dependente,
                                    OUTPUT TABLE tt-tipos-dependente,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-dependente:HANDLE,
                             INPUT "Dependente").
            RUN piXmlExport (INPUT TEMP-TABLE tt-tipos-dependente:HANDLE,
                             INPUT "Tipos").
            RUN piXmlSave.
        END.

END PROCEDURE.


/*****************************************************************************/
/**         Procedure para validar operacao de alteracao e inclusao         **/
/*****************************************************************************/
PROCEDURE valida-operacao:

    RUN valida-operacao IN hBO (INPUT aux_cdcooper,
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
                                INPUT aux_nmdepend,
                                INPUT aux_dtnascto,
                                INPUT aux_cdtipdep,
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


/*****************************************************************************/
/**     Procedure para alterar,excluir ou incluir dependente do associado   **/
/*****************************************************************************/
PROCEDURE gerenciar-dependente:

    RUN gerenciar-dependente IN hBO (INPUT aux_cdcooper,
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
                                     INPUT aux_nmdepend,
                                     INPUT aux_dtnascto,
                                     INPUT aux_cdtipdep,
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
            RUN piXmlAtributo (INPUT "msgatcad", INPUT aux_msgatcad).
            RUN piXmlAtributo (INPUT "chavealt", INPUT aux_chavealt).
            RUN piXmlAtributo (INPUT "msgrvcad", INPUT aux_msgrvcad).
            RUN piXmlSave.
        END.

END PROCEDURE.


/*...........................................................................*/
