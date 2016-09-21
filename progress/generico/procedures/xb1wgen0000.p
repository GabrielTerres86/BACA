/*..............................................................................

   Programa: xb1wgen0000.p
   Autor   : David
   Data    : 09/07/2007                        Ultima atualizacao: 19/01/2012
      
   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO Generica (b1wgen0000.p)

   Alteracoes: 19/01/2012 - Criado funcoes para consulta e validacao
                            do campo PAC Trabalho (Tiago).

..............................................................................*/


DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_idsistem AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_cdrelato AS INTE                                           NO-UNDO.
DEF VAR aux_nvopelib AS INTE                                           NO-UNDO.
DEF VAR aux_cdpactra AS INTE                                           NO-UNDO.
        
DEF VAR aux_cddsenha AS CHAR                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_nmrotina AS CHAR                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_cdopelib AS CHAR                                           NO-UNDO.

DEF VAR aux_vldsenha AS LOGI                                           NO-UNDO.
DEF VAR aux_flgerlog AS LOGI                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0000tt.i }
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
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "idsistem" THEN aux_idsistem = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "cdrelato" THEN aux_cdrelato = INTE(tt-param.valorCampo).
            WHEN "cddsenha" THEN aux_cddsenha = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "nmrotina" THEN aux_nmrotina = tt-param.valorCampo.        
            WHEN "vldsenha" THEN aux_vldsenha = LOGICAL(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "nvopelib" THEN aux_nvopelib = INTE(tt-param.valorCampo).
            WHEN "cdopelib" THEN aux_cdopelib = tt-param.valorCampo.
            WHEN "flgerlog" THEN aux_flgerlog = LOGICAL(tt-param.valorCampo).
            WHEN "cdpactra" THEN aux_cdpactra = INTE(tt-param.valorCampo).
        END CASE.

    END. /** Fim do FOR EACH tt-param **/
    
END PROCEDURE.


/******************************************************************************/
/**        Procedure para efetuar login no sistema Ayllos - Modo WEB         **/
/******************************************************************************/
PROCEDURE efetua_login:

    RUN efetua_login IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_idorigem,
                             INPUT aux_vldsenha,
                             INPUT aux_cddsenha,
                             INPUT aux_cdpactra,
                            OUTPUT TABLE tt-login,
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-login:HANDLE,
                        INPUT "Dados").
                                            
END PROCEDURE.

/******************************************************************************/
/**        Procedure para consulta do PAC do operador                        **/
/******************************************************************************/
PROCEDURE consulta-pac-ope:
    RUN consulta-pac-ope IN hBO (INPUT  aux_cdcooper,
                                 INPUT  aux_cdagenci,
                                 INPUT  aux_nrdcaixa,
                                 INPUT  aux_cdoperad,
                                 INPUT  aux_idorigem,
                                 OUTPUT aux_cdpactra).
              
    RUN piXmlNew.                             
    RUN piXmlAtributo (INPUT "cdpactra",
                       INPUT aux_cdpactra).
    RUN piXmlSave.                   
                       
END PROCEDURE.

/******************************************************************************/
/**          Procedure para retornar telas que usuario pode acessar          **/
/******************************************************************************/
PROCEDURE carrega_menu:

    RUN carrega_menu IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_idorigem,
                             INPUT aux_idsistem,
                            OUTPUT TABLE tt-menu,
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-menu:HANDLE,
                        INPUT "Dados").
                                            
END PROCEDURE.


/******************************************************************************/
/**  Procedure para verificar permissao de acesso em telas,rotinas e opcoes  **/
/******************************************************************************/
PROCEDURE verifica_permissao_operacao:

    RUN verifica_permissao_operacao IN hBO (INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_cdoperad,
                                            INPUT aux_idorigem,
                                            INPUT aux_idsistem,
                                            INPUT aux_nmdatela,
                                            INPUT aux_nmrotina,
                                            INPUT aux_cddopcao,
                                            INPUT aux_inproces,
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
/**  Procedure para verificar permissao de acesso em telas,rotinas e opcoes  **/
/******************************************************************************/
PROCEDURE obtem_permissao:

    RUN obtem_permissao IN hBO (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_idorigem,
                                INPUT aux_idsistem,
                                INPUT aux_nmdatela,
                                INPUT aux_nmrotina,
                                INPUT aux_cddopcao,
                                INPUT aux_inproces,
                               OUTPUT TABLE tt-opcoes,
                               OUTPUT TABLE tt-rotinas,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-opcoes:HANDLE,
                             INPUT "Opcoes").
            RUN piXmlExport (INPUT TEMP-TABLE tt-rotinas:HANDLE,
                             INPUT "Rotinas").                 
            RUN piXmlSave.
        END.
     
END PROCEDURE.


/******************************************************************************/
/**        Procedure para carregar dados para cabecalho de relatorios        **/
/******************************************************************************/
PROCEDURE cabecalho_relatorios:

    RUN cabecalho_relatorios IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_idorigem,
                                     INPUT aux_cdrelato,
                                    OUTPUT TABLE tt-cabec-relatorio,
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-cabec-relatorio:HANDLE,
                        INPUT "Dados").

END PROCEDURE.


/******************************************************************************/
/**           Procedure para validar senha do coordenador/gerente            **/
/******************************************************************************/
PROCEDURE valida-senha-coordenador:

    RUN valida-senha-coordenador IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_nmdatela,
                                         INPUT aux_idorigem,
                                         INPUT aux_nrdconta,
                                         INPUT aux_idseqttl,
                                         INPUT aux_nvopelib,
                                         INPUT aux_cdopelib,
                                         INPUT aux_cddsenha,
                                         INPUT aux_flgerlog,
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


/*............................................................................*/
