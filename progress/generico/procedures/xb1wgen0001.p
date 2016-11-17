/*..............................................................................

   Programa: xb1wgen0001.p
   Autor   : Murilo/David
   Data    : Maio/2007                        Ultima atualizacao: 02/12/2015

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO de Dados da Conta Corrente
               (b1wgen0001.p)

   Alteracoes: 18/07/2008 - Incluir procedure gera_extrato_especial(Guilherme).
   
               05/08/2008 - Incluir parametros na BO carrega_dados_atenda
                            (David).
                            
               13/08/2009 - Incluir parametros na zoom-associados(Guilherme).  
               
               28/09/2009 - Substituir procedure gera_extrato_especial pela
                            procedure obtem-impressao-extrato (David).
                            
               05/07/2010 - Retirar procedure zoom-associados (David).
               
               04/08/2010 - Incluir procedure extrato-paginado (David).
               
               02/09/2010 - Ajuste para rotina DEP.VISTA (David).
               
               05/11/2010 - Inclusao de parametros ref. TAA compartilhado na
                            procedure gera-tarifa-extrato (Diego). 
                            
               18/03/2011 - Nova BO para Anotacoes na tela ATENDA (David).
               18/10/2011 - Realizada inclusão das procedures ver_cadastro e
                            ver_capital.
                            
               06/06/2013 - Retirado o parametro aux_inisenta na procedure
                            gera-tarifa-extrato. (Daniel)
                            
               25/09/2014 - Incluido na procedure carrega_dados_atenda
                            as validacoes de Pagto de titulos por Arquivo
                            (Andre Santos - SUPERO)

               05/12/2014 - Incluido na procedure carrega_dados_atenda
                            novo parametro de entrada (Daniel) 

               02/12/2015 - Remover a procedure obtem-saldo-dia nao eh utilizada
                            (Douglas - Chamado 285228)
..............................................................................*/


DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_cdpesqui AS INTE                                           NO-UNDO.
DEF VAR aux_tpdapesq AS INTE                                           NO-UNDO.
DEF VAR aux_cdagpesq AS INTE                                           NO-UNDO.
DEF VAR aux_flgchequ AS INTE                                           NO-UNDO.
DEF VAR aux_cdrelato AS INTE                                           NO-UNDO.
DEF VAR aux_inrelext AS INTE                                           NO-UNDO.
DEF VAR aux_inisenta AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_qtcopera AS INTE                                           NO-UNDO.
DEF VAR aux_qtregpag AS INTE                                           NO-UNDO.
DEF VAR aux_iniregis AS INTE                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.

DEF VAR aux_dtiniper AS DATE                                           NO-UNDO.
DEF VAR aux_dtfimper AS DATE                                           NO-UNDO.
DEF VAR aux_dtrefere AS DATE                                           NO-UNDO.

DEF VAR aux_nrdctitg AS CHAR                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdbusca AS CHAR                                           NO-UNDO.
DEF VAR aux_cdprogra AS CHAR                                           NO-UNDO.

DEF VAR aux_flgpagin AS LOGI                                           NO-UNDO.
DEF VAR aux_flgtarif AS LOGI                                           NO-UNDO.
DEF VAR aux_vllanmto AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"            NO-UNDO.

DEF VAR aux_flconven AS INTE                                    NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.

DEF VAR aux_flgerlog AS LOGI    INITIAL FALSE                          NO-UNDO. 

{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/b1wgen0003tt.i }
{ sistema/generico/includes/b1wgen0031tt.i }
{ sistema/generico/includes/b1wgen0032tt.i }
{ sistema/generico/includes/b1wgen0085tt.i }
{ sistema/generico/includes/b1wgen0192tt.i }
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
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "dtiniper" THEN aux_dtiniper = DATE(tt-param.valorCampo).
            WHEN "dtfimper" THEN aux_dtfimper = DATE(tt-param.valorCampo).
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nrdctitg" THEN aux_nrdctitg = tt-param.valorCampo. 
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "cdpesqui" THEN aux_cdpesqui = INTE(tt-param.valorCampo).
            WHEN "nmdbusca" THEN aux_nmdbusca = tt-param.valorCampo.
            WHEN "tpdapesq" THEN aux_tpdapesq = INTE(tt-param.valorCampo).
            WHEN "cdagpesq" THEN aux_cdagpesq = INTE(tt-param.valorCampo).
            WHEN "flgtarif" THEN aux_flgtarif = LOGICAL(tt-param.valorCampo).
            WHEN "flgchequ" THEN aux_flgchequ = INTE(tt-param.valorCampo).
            WHEN "cdrelato" THEN aux_cdrelato = INTE(tt-param.valorCampo).
            WHEN "cdprogra" THEN aux_cdprogra = tt-param.valorCampo.
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "inrelext" THEN aux_inrelext = INTE(tt-param.valorCampo).
            WHEN "dtrefere" THEN aux_dtrefere = DATE(tt-param.valorCampo).
            WHEN "inisenta" THEN aux_inisenta = INTE(tt-param.valorCampo).
            WHEN "qtregpag" THEN aux_qtregpag = INTE(tt-param.valorCampo).
            WHEN "iniregis" THEN aux_iniregis = INTE(tt-param.valorCampo).
            WHEN "qtregist" THEN aux_qtregist = INTE(tt-param.valorCampo).
            WHEN "flgpagin" THEN aux_flgpagin = LOGICAL(tt-param.valorCampo).
            WHEN "vllanmto" THEN aux_vllanmto = DECIMAL(tt-param.valorCampo).
            WHEN "flgerlog" THEN aux_flgerlog = LOGICAL(tt-param.valorCampo).
        END CASE.

    END. /** Fim do FOR EACH tt-param **/
    
END PROCEDURE.    

PROCEDURE ver_cadastro:
    RUN ver_cadastro IN hBO (INPUT aux_cdcooper,
                             INPUT aux_nrdconta,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_dtmvtolt,
                             INPUT aux_idorigem,
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
                                            
END PROCEDURE.

PROCEDURE ver_capital:
    RUN ver_capital IN hBO (INPUT aux_cdcooper,
                            INPUT aux_nrdconta,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_vllanmto,
                            INPUT aux_dtmvtolt,
                            INPUT aux_cdprogra,
                            INPUT aux_idorigem,
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
                                            
END PROCEDURE.

/******************************************************************************/
/**            Procedure para consultar extrato da conta-corrente            **/
/******************************************************************************/
PROCEDURE consulta-extrato:

    RUN consulta-extrato IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nrdconta,
                                 INPUT aux_dtiniper,
                                 INPUT aux_dtfimper,
                                 INPUT aux_idorigem,
                                 INPUT aux_idseqttl,
                                 INPUT aux_nmdatela,
                                 INPUT TRUE,
                                OUTPUT TABLE tt-erro,
                                OUTPUT TABLE tt-extrato_conta).
    
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-extrato_conta:HANDLE,
                        INPUT "Dados").
                                            
END PROCEDURE.


/******************************************************************************/
/**    Procedure para controlar listagem do extrato da conta em paginacao    **/
/******************************************************************************/
PROCEDURE extrato-paginado:

     RUN extrato-paginado IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT aux_dtiniper,
                                  INPUT aux_dtfimper,
                                  INPUT aux_iniregis,
                                  INPUT aux_qtregpag,
                                  INPUT TRUE,
                                 OUTPUT aux_qtregist,
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-extrato_conta).
     
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-extrato_conta:HANDLE,
                             INPUT "Dados").
            RUN piXmlAtributo (INPUT "qtregist", INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.
                                            
END PROCEDURE.


/******************************************************************************/
/**           Procedure para listar cheques recebidos em deposito            **/
/******************************************************************************/
PROCEDURE obtem-cheques-deposito:

    RUN obtem-cheques-deposito IN hBO (INPUT aux_cdcooper, 
                                       INPUT aux_cdagenci, 
                                       INPUT aux_nrdcaixa, 
                                       INPUT aux_cdoperad, 
                                       INPUT aux_nmdatela, 
                                       INPUT aux_idorigem, 
                                       INPUT aux_nrdconta, 
                                       INPUT aux_idseqttl, 
                                       INPUT aux_dtiniper, 
                                       INPUT aux_dtfimper, 
                                       INPUT aux_flgpagin,
                                       INPUT aux_iniregis,
                                       INPUT aux_qtregpag,
                                       INPUT TRUE, 
                                      OUTPUT TABLE tt-extrato_cheque).

    RUN piXmlNew.
    RUN piXmlExport (INPUT TEMP-TABLE tt-extrato_cheque:HANDLE,
                     INPUT "Dados").
    RUN piXmlAtribute (INPUT "qtregist", INPUT STRING(aux_qtregist)).
    RUN piXmlSave.

END PROCEDURE.    


/******************************************************************************/
/**              Procedure para listar depositos identificados               **/
/******************************************************************************/
PROCEDURE obtem-depositos-identificados:

    RUN obtem-depositos-identificados IN hBO (INPUT aux_cdcooper,
                                              INPUT aux_cdagenci,
                                              INPUT aux_nrdcaixa,
                                              INPUT aux_cdoperad,
                                              INPUT aux_nmdatela,
                                              INPUT aux_idorigem,
                                              INPUT aux_nrdconta,
                                              INPUT aux_idseqttl,
                                              INPUT aux_dtiniper,
                                              INPUT aux_dtfimper,
                                              INPUT aux_flgpagin,
                                              INPUT aux_iniregis,
                                              INPUT aux_qtregpag,
                                              INPUT TRUE,
                                             OUTPUT aux_qtregist,
                                             OUTPUT TABLE tt-dep-identificado,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-dep-identificado:HANDLE,
                             INPUT "Dados").
            RUN piXmlAtribute (INPUT "qtregist", INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************/
/**      Procedure para gerar tarifa referente a impressao de extrato        **/
/******************************************************************************/
PROCEDURE gera-tarifa-extrato:

    RUN gera-tarifa-extrato IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_nmdatela,
                                    INPUT aux_idorigem,
                                    INPUT aux_nrdconta,
                                    INPUT aux_idseqttl,
                                    INPUT aux_dtrefere,
                                    INPUT aux_inproces,
                                    INPUT aux_flgtarif,
                                    INPUT TRUE,
                                    INPUT 0,
                                    INPUT 0,
                                    INPUT 0,
                                   OUTPUT TABLE tt-msg-confirma,
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                        INPUT "Dados").

END PROCEDURE.


/******************************************************************************/
/**      Procedure para validar impressao do extrato de conta corrente       **/
/******************************************************************************/
PROCEDURE valida-impressao-extrato:

    RUN valida-impressao-extrato IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_nmdatela,
                                         INPUT aux_idorigem,
                                         INPUT aux_nrdconta,
                                         INPUT aux_idseqttl,
                                         INPUT aux_dtmvtolt,
                                         INPUT aux_dtiniper,
                                         INPUT aux_dtfimper,
                                         INPUT aux_inisenta,
                                         INPUT TRUE,
                                        OUTPUT TABLE tt-msg-confirma, 
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                        INPUT "Dados").

END PROCEDURE.


/******************************************************************************/
/**       Procedure para obter impressao do extrato de conta corrente        **/
/******************************************************************************/
PROCEDURE obtem-impressao-extrato:

    RUN obtem-impressao-extrato IN hBO (INPUT aux_cdcooper, 
                                        INPUT aux_cdagenci, 
                                        INPUT aux_nrdcaixa, 
                                        INPUT aux_cdoperad, 
                                        INPUT aux_nmdatela, 
                                        INPUT aux_idorigem, 
                                        INPUT aux_nrdconta, 
                                        INPUT aux_idseqttl, 
                                        INPUT aux_dtmvtolt, 
                                        INPUT aux_dtiniper, 
                                        INPUT aux_dtfimper, 
                                        INPUT aux_inrelext,
                                        INPUT aux_inisenta,
                                        INPUT aux_inproces,
                                        INPUT aux_flgtarif,
                                        INPUT TRUE,
                                       OUTPUT TABLE tt-cabrel,  
                                       OUTPUT TABLE tt-dados_cooperado,
                                       OUTPUT TABLE tt-extrato_conta,
                                       OUTPUT TABLE tt-extrato_cheque,
                                       OUTPUT TABLE tt-dep-identificado,
                                       OUTPUT TABLE tt-taxajuros,
                                       OUTPUT TABLE tt-totais-futuros,
                                       OUTPUT TABLE tt-lancamento_futuro,
                                       OUTPUT TABLE tt-msg-confirma,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-cabrel:HANDLE,
                             INPUT "Dados_Cabecalho").
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados_cooperado:HANDLE,
                             INPUT "Dados_Cooperado").
            RUN piXmlExport (INPUT TEMP-TABLE tt-extrato_conta:HANDLE,
                             INPUT "Extrato").
            RUN piXmlExport (INPUT TEMP-TABLE tt-extrato_cheque:HANDLE,
                             INPUT "Cheques").            
            RUN piXmlExport (INPUT TEMP-TABLE tt-taxajuros:HANDLE,
                             INPUT "Taxa_Juros").
            RUN piXmlExport (INPUT TEMP-TABLE tt-dep-identificado:HANDLE,
                             INPUT "Depositos").                 
            RUN piXmlExport (INPUT TEMP-TABLE tt-totais-futuros:HANDLE,
                             INPUT "Totais_Futuros"). 
            RUN piXmlExport (INPUT TEMP-TABLE tt-lancamento_futuro:HANDLE,
                             INPUT "Lancamentos_Futuros").
            RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                             INPUT "Mensagem").
            RUN piXmlSave.         
        END.
        
END PROCEDURE.


/******************************************************************************/
/**               Procedure para obter saldos da conta-corrente              **/
/******************************************************************************/
PROCEDURE obtem-saldo:

    RUN obtem-saldo IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nrdconta,
                            INPUT aux_dtiniper,
                            INPUT aux_idorigem,
                           OUTPUT TABLE tt-erro,
                           OUTPUT TABLE tt-saldos).
            
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-saldos:HANDLE,
                        INPUT "Dados").

END PROCEDURE.


/******************************************************************************/
/**                    Procedure para obter valor de CPMF                    **/
/******************************************************************************/
PROCEDURE obtem-cpmf:

    RUN obtem-cpmf IN hBO (INPUT aux_cdcooper,
                           INPUT aux_cdagenci,
                           INPUT aux_nrdcaixa,
                           INPUT aux_cdoperad,
                           INPUT aux_nrdconta,
                           INPUT aux_idorigem,
                           INPUT aux_idseqttl,
                           INPUT aux_nmdatela,
                          OUTPUT TABLE tt-erro,
                          OUTPUT TABLE tt-cpmf).

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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-cpmf:HANDLE,
                        INPUT "Dados").
                         
END PROCEDURE.


/******************************************************************************/
/**           Procedure para obter saldos medios da conta-corrente           **/
/******************************************************************************/
PROCEDURE obtem-medias:
                                 
    RUN obtem-medias IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nrdconta,
                            OUTPUT TABLE tt-erro,
                            OUTPUT TABLE tt-medias).
            
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-medias:HANDLE,
                        INPUT "Dados").
                             
END PROCEDURE.


/******************************************************************************/
/**         Procedure para obter saldos anteriores da conta-corrente         **/
/******************************************************************************/
PROCEDURE obtem-saldos-anteriores:

    RUN obtem-saldos-anteriores IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nmdatela,
                                        INPUT aux_idorigem,
                                        INPUT aux_nrdconta,
                                        INPUT aux_idseqttl,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_dtmvtoan,
                                        INPUT aux_dtrefere,
                                        INPUT TRUE,
                                       OUTPUT TABLE tt-erro,
                                       OUTPUT TABLE tt-saldos).

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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-saldos:HANDLE,
                        INPUT "Dados").

END PROCEDURE.


/******************************************************************************/
/**            Procedure para obter dados principais do associado            **/
/******************************************************************************/
PROCEDURE obtem-cabecalho:
 
    RUN obtem-cabecalho IN hBO (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nrdconta,
                                INPUT aux_nrdctitg,
                                INPUT aux_dtiniper,
                                INPUT aux_dtfimper,
                                INPUT aux_idorigem,
                               OUTPUT TABLE tt-erro,
                               OUTPUT TABLE tt-cabec).

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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-cabec:HANDLE,
                        INPUT "Dados").
                                            
END PROCEDURE.

/******************************************************************************/
/**    Procedure para obter o resto dos principais dados do associado        **/
/******************************************************************************/
PROCEDURE completa-cabecalho:
 
    RUN completa-cabecalho IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nrdconta,
                                   INPUT aux_nrdctitg,
                                   INPUT aux_dtiniper,
                                   INPUT aux_idorigem,
                                  OUTPUT TABLE tt-erro,
                                  OUTPUT TABLE tt-comp_cabec).

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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-comp_cabec:HANDLE,
                        INPUT "Dados").
                                            
END PROCEDURE.

/******************************************************************************/
/**            Procedure para obter dados principais do saldo Dep. Vista     **/
/******************************************************************************/
PROCEDURE carrega_dep_vista:
 
    RUN carrega_dep_vista IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nrdconta,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_idorigem,
                                  INPUT aux_idseqttl,
                                  INPUT aux_nmdatela,
                                  INPUT TRUE,
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-saldos,
                                 OUTPUT TABLE tt-libera-epr).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-saldos:HANDLE,
                             INPUT "Saldos").
            RUN piXmlExport (INPUT TEMP-TABLE tt-libera-epr:HANDLE,
                             INPUT "Emprestimos").
            RUN piXmlSave.         
        END.
        
END PROCEDURE.

/******************************************************************************/
/**            Procedure para obter medias do saldo Dep. Vista               **/
/******************************************************************************/
PROCEDURE carrega_medias:
 
    RUN carrega_medias IN hBO (INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nrdconta,
                               INPUT aux_dtmvtolt,
                               INPUT aux_idorigem,
                               INPUT aux_idseqttl,
                               INPUT aux_nmdatela,
                               INPUT TRUE, /** GERAR LOG **/
                              OUTPUT TABLE tt-erro,
                              OUTPUT TABLE tt-medias,
                              OUTPUT TABLE tt-comp_medias).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-medias:HANDLE,
                             INPUT "Medias").        
            RUN piXmlExport (INPUT TEMP-TABLE tt-comp_medias:HANDLE,
                             INPUT "Comp.Medias").
            RUN piXmlSave.         
        END.
                                            
END PROCEDURE.

/******************************************************************************/
/**      Procedure para carregar dados principais e saldos do associado      **/
/******************************************************************************/
PROCEDURE carrega_dados_atenda:

    RUN carrega_dados_atenda IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,   
                                     INPUT aux_dtmvtolt,
                                     INPUT aux_dtmvtopr,
                                     INPUT aux_dtmvtoan,
                                     INPUT aux_dtiniper,
                                     INPUT aux_dtfimper,
                                     INPUT aux_nmdatela,
                                     INPUT aux_idorigem,
                                     INPUT aux_nrdconta,
                                     INPUT aux_idseqttl,
                                     INPUT aux_nrdctitg,
                                     INPUT aux_inproces,
                                     INPUT aux_flgerlog,
                                    OUTPUT aux_flconven,
                                    OUTPUT aux_cdcritic,
                                    OUTPUT aux_dscritic,
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-cabec,
                                    OUTPUT TABLE tt-comp_cabec,
                                    OUTPUT TABLE tt-valores_conta,
                                    OUTPUT TABLE tt-crapobs,
                                    OUTPUT TABLE tt-mensagens-atenda,
                                    OUTPUT TABLE tt-arquivos).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-cabec:HANDLE,
                             INPUT "Cabecalho").
            RUN piXmlExport (INPUT TEMP-TABLE tt-comp_cabec:HANDLE,
                             INPUT "Comp.Cabecalho").        
            RUN piXmlExport (INPUT TEMP-TABLE tt-valores_conta:HANDLE,
                             INPUT "Valores").
            RUN piXmlExport (INPUT TEMP-TABLE tt-mensagens-atenda:HANDLE,
                             INPUT "Mensagens").
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapobs:HANDLE,
                             INPUT "Anotacoes").
            RUN piXmlAtributo (INPUT "flconven",INPUT STRING(aux_flconven)).
            RUN piXmlAtributo (INPUT "dscritic",INPUT STRING(aux_dscritic)).
            RUN piXmlSave.         
        END.
        
END PROCEDURE.


/*............................................................................*/
