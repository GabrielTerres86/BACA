/*.............................................................................

    Programa: sistema/generico/procedures/xb1wgen0070.p
    Autor   : David
    Data    : Maio/2010                      Ultima atualizacao: 14/02/2011

    Dados referentes ao programa:

    Objetivo  : BO de Comunicacao XML Vs BO da rotina TELEFONE (b1wgen0070.p).

    Alteracoes: 22/09/2010 -  Recebe parametro 'msgconta' no busca_dados 
                              e passa no XML. (Gabriel - DB1).
                              
                14/02/2011 - Incluir procedure que trata da rotina TELEFONE
                             (Gabriel).
			    
				01/02/2016 - Melhoria 147 - Adicionar Campos e Aprovacao de
				             Transferencia entre PAs (Heitor - RKAM)
    
.............................................................................*/


DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_tptelefo AS INTE                                           NO-UNDO.
DEF VAR aux_nrdddtfc AS INTE                                           NO-UNDO.
DEF VAR aux_nrdramal AS INTE                                           NO-UNDO.
DEF VAR aux_cdopetfn AS INTE                                           NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.

DEF VAR aux_nrtelefo AS DECI                                           NO-UNDO.

DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_secpscto AS CHAR                                           NO-UNDO.
DEF VAR aux_nmpescto AS CHAR                                           NO-UNDO.
DEF VAR aux_prgqfalt AS CHAR                                           NO-UNDO.
DEF VAR aux_msgconta AS CHAR                                           NO-UNDO.
DEF VAR aux_msgrvcad AS CHAR                                           NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_idsittfc AS INTE                                           NO-UNDO.
DEF VAR aux_idorigee AS INTE                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0070tt.i }
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
            WHEN "tptelefo" THEN aux_tptelefo = INTE(tt-param.valorCampo).
            WHEN "nrdddtfc" THEN aux_nrdddtfc = INTE(tt-param.valorCampo).
            WHEN "nrdramal" THEN aux_nrdramal = INTE(tt-param.valorCampo).
            WHEN "cdopetfn" THEN aux_cdopetfn = INTE(tt-param.valorCampo).
            WHEN "nrtelefo" THEN aux_nrtelefo = DECI(tt-param.valorCampo).
            WHEN "secpscto" THEN aux_secpscto = tt-param.valorCampo.
            WHEN "nmpescto" THEN aux_nmpescto = tt-param.valorCampo.
            WHEN "prgqfalt" THEN aux_prgqfalt = tt-param.valorCampo.
            WHEN "inpessoa" THEN aux_inpessoa = INTE(tt-param.valorCampo).
            WHEN "chavealt" THEN aux_chavealt = tt-param.valorCampo.
            WHEN "tpatlcad" THEN aux_tpatlcad = INTE(tt-param.valorCampo).
            WHEN "idsittfc" THEN aux_idsittfc = INTE(tt-param.valorCampo).
            WHEN "idorigee" THEN aux_idorigee = INTE(tt-param.valorCampo).

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.    


/*****************************************************************************/
/**             Procedure para retornar telefones do cooperado              **/
/*****************************************************************************/
PROCEDURE obtem-telefone-cooperado: 

    RUN obtem-telefone-cooperado IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_nmdatela,
                                         INPUT aux_idorigem,
                                         INPUT aux_nrdconta,
                                         INPUT aux_idseqttl,
                                         INPUT TRUE,
                                        OUTPUT aux_msgconta,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-telefone-cooperado).

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
        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-telefone-cooperado:HANDLE,
                        INPUT "Dados").
        RUN piXmlAtributo (INPUT "msgconta", INPUT aux_msgconta).
        RUN piXmlSave.

END PROCEDURE.


/*****************************************************************************/
/**         Procedure para obter dados para alterar/incluir telefone        **/
/*****************************************************************************/
PROCEDURE obtem-dados-gerenciar-telefone: 

    RUN obtem-dados-gerenciar-telefone IN hBO 
                                      (INPUT aux_cdcooper,
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
                                      OUTPUT TABLE tt-operadoras-celular,
                                      OUTPUT TABLE tt-telefone-cooperado).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-operadoras-celular:HANDLE,
                             INPUT "Operadoras").
            RUN piXmlExport (INPUT TEMP-TABLE tt-telefone-cooperado:HANDLE,
                             INPUT "Telefone").
            RUN piXmlAtributo (INPUT "inpessoa", INPUT STRING(aux_inpessoa)).
            RUN piXmlSave.
        END.

END PROCEDURE.


/*****************************************************************************/
/**                Procedure para validar telefone do cooperado             **/
/*****************************************************************************/
PROCEDURE validar-telefone: 

    RUN validar-telefone IN hBO (INPUT aux_cdcooper, 
                                 INPUT aux_cdagenci, 
                                 INPUT aux_nrdcaixa, 
                                 INPUT aux_cdoperad, 
                                 INPUT aux_nmdatela, 
                                 INPUT aux_idorigem, 
                                 INPUT aux_nrdconta, 
                                 INPUT aux_idseqttl, 
                                 INPUT aux_cddopcao, 
                                 INPUT aux_nrdrowid, 
                                 INPUT aux_tptelefo, 
                                 INPUT aux_nrdddtfc, 
                                 INPUT aux_nrtelefo, 
                                 INPUT aux_nrdramal, 
                                 INPUT aux_secpscto, 
                                 INPUT aux_nmpescto, 
                                 INPUT aux_cdopetfn, 
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
/**          Procedure para alteracao/exclusao/inclusao de telefone         **/
/*****************************************************************************/
PROCEDURE gerenciar-telefone: 

    RUN gerenciar-telefone IN hBO (INPUT aux_cdcooper,
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
                                   INPUT aux_tptelefo,
                                   INPUT aux_nrdddtfc,
                                   INPUT aux_nrtelefo,
                                   INPUT aux_nrdramal,
                                   INPUT aux_secpscto,
                                   INPUT aux_nmpescto,
                                   INPUT aux_cdopetfn,
                                   INPUT aux_prgqfalt,
                                   INPUT TRUE,
                                   INPUT aux_idsittfc,
                                   INPUT aux_idorigee,
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

/*****************************************************************************
 Carregar os dados da rotina TELEFONE da tela ATENDA
*****************************************************************************/
PROCEDURE obtem-telefone-titulares:

    RUN obtem-telefone-titulares IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_nmdatela,
                                         INPUT aux_idorigem,
                                         INPUT aux_nrdconta,
                                         INPUT aux_idseqttl,
                                         INPUT TRUE,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-telefone-cooperado).


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
            RUN piXmlExport (INPUT TEMP-TABLE tt-telefone-cooperado:HANDLE,
                             INPUT "Telefone").
            RUN piXmlSave. 
        END.

END PROCEDURE.

/*...........................................................................*/


