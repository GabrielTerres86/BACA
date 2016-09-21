/*..............................................................................

   Programa: xb1wgen0032.p
   Autor   : Guilherme/David
   Data    : Agosto/2008                     Ultima atualizacao: 22/07/2015

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO de Cartoes Magneticos (b1wgen0032.p)

   Alteracoes: 05/06/2009 - Novo parametro tpusucar, para permitir alteracao
                            de titular, na procedure alterar-cartao-magnetico
                          - Melhoria na procedure consiste-cartao
                            (David).
                            
               22/12/2011 - Incluido a procedure solicitar-letras (Adriano).             
                            
               05/01/2012 - Realizado a inclusao dos parametros a seguir na
                            procedure entregar-cartao-magnetico:
                            - aux_nrsenatu
                            - aux_nrsencar
                            - aux_nrsencon 
                            Criado a procedure:
                            - validar-senha-cartao-magnetico
                            (Adriano).
                            
               12/01/2012 - Alterar nome de solicitar-letras para limpar-letras
                          - Incluido parametro tpoperac na verifica-senha-atual
                            que foi adicionado pelo Diego na b1wgen0032
                          - Incluido procedure grava-senha-letras 
                          - Alterar nrsencar para char (Guilherme).
                          
               07/11/2012 - Removido parametro do Nr. do cartão magnético
                            da procedure 'grava-senha-letras' (Lucas).
                            
               11/01/2013 - Requisitar cadastro das letras ao entregar
                            cartão magnético (Lucas).
                            
               01/12/2014 - #223022 Verificada a situacao do cartao magnetico
                             (validar-entrega-cartao) para somente entrega-lo 
                             quando disponivel (Carlos)
               
               22/07/2015 - Remover procedures que nao sera mais utilizadas. (James)
..............................................................................*/

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_qtcarmag AS INTE                                           NO-UNDO.
DEF VAR aux_tpcarcta AS INTE                                           NO-UNDO.
DEF VAR aux_tpusucar AS INTE                                           NO-UNDO.
DEF VAR aux_nrsenatu AS CHAR                                           NO-UNDO.
DEF VAR aux_nrsencar AS CHAR                                           NO-UNDO.
DEF VAR aux_nrsencon AS CHAR                                           NO-UNDO.
DEF VAR aux_tpoperac AS INTE                                           NO-UNDO.

DEF VAR aux_nrcartao AS DECI                                           NO-UNDO.
DEF VAR aux_nrcpfppt AS DECI                                           NO-UNDO.

DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_nmrotina AS CHAR                                           NO-UNDO.
DEF VAR aux_nmtitcrd AS CHAR                                           NO-UNDO.
DEF VAR aux_dssencon AS CHAR                                           NO-UNDO.
DEF VAR aux_dssennov AS CHAR                                           NO-UNDO.
DEF VAR aux_flgcadas AS CHAR                                           NO-UNDO.


DEF VAR aux_flgentrg AS LOGI                                           NO-UNDO.
DEF VAR aux_flgsenat AS LOGI                                           NO-UNDO.
DEF VAR aux_flgerlog AS LOGI                                           NO-UNDO.
DEF VAR aux_flgletca AS LOGI                                           NO-UNDO.

DEF VAR aux_dtvalcar AS DATE                                           NO-UNDO.
DEF VAR aux_dtemscar AS DATE                                           NO-UNDO.
DEF VAR aux_cdsitcar AS INTE                                           NO-UNDO.



{ sistema/generico/includes/b1wgen0032tt.i }
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
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "qtcarmag" THEN aux_qtcarmag = INTE(tt-param.valorCampo).            
            WHEN "tpcarcta" THEN aux_tpcarcta = INTE(tt-param.valorCampo).
            WHEN "tpusucar" THEN aux_tpusucar = INTE(tt-param.valorCampo). 
            WHEN "tpoperac" THEN aux_tpoperac = INTE(tt-param.valorCampo). 
            WHEN "nrsenatu" THEN aux_nrsenatu = tt-param.valorCampo.
            WHEN "nrsencar" THEN aux_nrsencar = tt-param.valorCampo.
            WHEN "nrsencon" THEN aux_nrsencon = tt-param.valorCampo.
            WHEN "nrcartao" THEN aux_nrcartao = DECI(tt-param.valorCampo).
            WHEN "nrcpfppt" THEN aux_nrcpfppt = DECI(tt-param.valorCampo).            
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "nmrotina" THEN aux_nmrotina = tt-param.valorCampo.
            WHEN "nmtitcrd" THEN aux_nmtitcrd = tt-param.valorCampo.
            WHEN "dssencon" THEN aux_dssencon = tt-param.valorCampo.
            WHEN "dssennov" THEN aux_dssennov = tt-param.valorCampo.
            WHEN "flgentrg" THEN aux_flgentrg = LOGICAL(tt-param.valorCampo).
            WHEN "flgsenat" THEN aux_flgsenat = LOGICAL(tt-param.valorCampo).
            WHEN "flgerlog" THEN aux_flgerlog = LOGICAL(tt-param.valorCampo).
            WHEN "flgletca" THEN aux_flgletca = LOGICAL(tt-param.valorCampo).
                
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.


/******************************************************************************/
/**           Procedure para obter cartoes magneticos do associado           **/
/******************************************************************************/
PROCEDURE obtem-cartoes-magneticos:

    RUN obtem-cartoes-magneticos IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_nmdatela,
                                         INPUT aux_idorigem,
                                         INPUT aux_nrdconta,
                                         INPUT aux_idseqttl,
                                         INPUT aux_dtmvtolt,
                                         INPUT TRUE, /** LOG **/
                                        OUTPUT aux_qtcarmag,
                                        OUTPUT TABLE tt-cartoes-magneticos).

    RUN piXmlNew.
    RUN piXmlExport (INPUT TEMP-TABLE tt-cartoes-magneticos:HANDLE,
                     INPUT "Cartoes_Magneticos").
    RUN piXmlAtributo (INPUT "qtcarmag",INPUT STRING(aux_qtcarmag)).   
    RUN piXmlSave.

END PROCEDURE.


/******************************************************************************/
/**           Procedure para consultar dados de cartoes magneticos           **/
/******************************************************************************/
PROCEDURE consulta-cartao-magnetico:

    RUN consulta-cartao-magnetico IN hBO (INPUT aux_cdcooper,
                                          INPUT aux_cdagenci,
                                          INPUT aux_nrdcaixa,
                                          INPUT aux_cdoperad,
                                          INPUT aux_nmdatela,
                                          INPUT aux_idorigem,
                                          INPUT aux_nrdconta,
                                          INPUT aux_idseqttl,
                                          INPUT aux_dtmvtolt,
                                          INPUT aux_nrcartao,
                                          INPUT TRUE,
                                         OUTPUT TABLE tt-erro,
                                         OUTPUT TABLE tt-dados-carmag).

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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-dados-carmag:HANDLE,
                        INPUT "Dados").

END PROCEDURE.


/******************************************************************************/
/**                Procedure para carregar prepostos da conta                **/
/******************************************************************************/
PROCEDURE obtem-prepostos:

    RUN obtem-prepostos IN hBO (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT aux_nrdconta,
                                INPUT aux_idseqttl,
                                INPUT TRUE,
                               OUTPUT TABLE tt-erro,
                               OUTPUT TABLE tt-preposto-carmag).  
                                 
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-preposto-carmag:HANDLE,
                        INPUT "Dados").                                 

END PROCEDURE.


/******************************************************************************/
/**          Procedure para atualizar preposto do cartao magnetico           **/
/******************************************************************************/
PROCEDURE atualizar-preposto:

    RUN atualizar-preposto IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nmdatela,
                                   INPUT aux_idorigem,
                                   INPUT aux_nrdconta,
                                   INPUT aux_idseqttl,
                                   INPUT aux_nrcpfppt,
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
/**    Procedure que verifica permissao para solicitar/alterar novo cartao   **/
/******************************************************************************/
PROCEDURE obtem-permissao-solicitacao:

    RUN obtem-permissao-solicitacao IN hBO (INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_cdoperad,
                                            INPUT aux_nmdatela,
                                            INPUT aux_idorigem,
                                            INPUT aux_nrdconta,
                                            INPUT aux_idseqttl,
                                            INPUT aux_dtmvtolt,
                                            INPUT aux_nrcartao,
                                            INPUT TRUE,
                                           OUTPUT TABLE tt-erro,
                                           OUTPUT TABLE tt-dados-carmag,
                                           OUTPUT TABLE tt-titular-magnetico).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-carmag:HANDLE,
                             INPUT "Dados").
            RUN piXmlExport (INPUT TEMP-TABLE tt-titular-magnetico:HANDLE,
                             INPUT "Titulares").
            RUN piXmlSave. 
        END.                  
                        
END PROCEDURE.


/******************************************************************************/
/**                 Procedure para alterar cartao magnetico                  **/
/******************************************************************************/
PROCEDURE alterar-cartao-magnetico:

    RUN alterar-cartao-magnetico IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_nmdatela,
                                         INPUT aux_idorigem,
                                         INPUT aux_nrdconta,
                                         INPUT aux_idseqttl,
                                         INPUT aux_dtmvtolt,
                                         INPUT aux_nrcartao,
                                         INPUT aux_tpusucar,
                                         INPUT aux_nmtitcrd,                                         
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
/**               Procedure para incluir novo cartao magnetico               **/
/******************************************************************************/
PROCEDURE incluir-cartao-magnetico:

    RUN incluir-cartao-magnetico IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_nmdatela,
                                         INPUT aux_idorigem,
                                         INPUT aux_nrdconta,
                                         INPUT aux_idseqttl,
                                         INPUT aux_dtmvtolt,
                                         INPUT aux_tpcarcta,
                                         INPUT aux_tpusucar,
                                         INPUT aux_nmtitcrd,                                         
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
/**                  Procedure para excluir cartao magnetico                 **/
/******************************************************************************/
PROCEDURE excluir-cartao-magnetico:

    RUN excluir-cartao-magnetico IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_nmdatela,
                                         INPUT aux_idorigem,
                                         INPUT aux_nrdconta,
                                         INPUT aux_idseqttl,
                                         INPUT aux_dtmvtolt,
                                         INPUT aux_nrcartao,
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
/**                 Procedure para bloquear cartao magnetico                 **/
/******************************************************************************/
PROCEDURE bloquear-cartao-magnetico:

    RUN bloquear-cartao-magnetico IN hBO (INPUT aux_cdcooper,
                                          INPUT aux_cdagenci,
                                          INPUT aux_nrdcaixa,
                                          INPUT aux_cdoperad,
                                          INPUT aux_nmdatela,
                                          INPUT aux_idorigem,
                                          INPUT aux_nrdconta,
                                          INPUT aux_idseqttl,
                                          INPUT aux_dtmvtolt,
                                          INPUT aux_nrcartao,
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
/**                 Procedure para cancelar cartao magnetico                 **/
/******************************************************************************/
PROCEDURE cancelar-cartao-magnetico:

    RUN cancelar-cartao-magnetico IN hBO (INPUT aux_cdcooper,
                                          INPUT aux_cdagenci,
                                          INPUT aux_nrdcaixa,
                                          INPUT aux_cdoperad,
                                          INPUT aux_nmdatela,
                                          INPUT aux_idorigem,
                                          INPUT aux_nrdconta,
                                          INPUT aux_idseqttl,
                                          INPUT aux_dtmvtolt,
                                          INPUT aux_nrcartao,
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
/**                 Procedure para entregar cartao magnetico                 **/
/******************************************************************************/
PROCEDURE entregar-cartao-magnetico:

    RUN entregar-cartao-magnetico IN hBO (INPUT aux_cdcooper,
                                          INPUT aux_cdagenci,
                                          INPUT aux_nrdcaixa,
                                          INPUT aux_cdoperad,
                                          INPUT aux_nmdatela,
                                          INPUT aux_idorigem,
                                          INPUT aux_nrdconta,
                                          INPUT aux_idseqttl,
                                          INPUT aux_dtmvtolt,
                                          INPUT aux_nrcartao,
                                          INPUT aux_nrsenatu,
                                          INPUT aux_nrsencar,
                                          INPUT aux_nrsencon,
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
/**         Procedure que verifica a senha atual do cartao magnetico         **/
/******************************************************************************/
PROCEDURE verifica-senha-atual:

    RUN verifica-senha-atual IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nmdatela,
                                     INPUT aux_idorigem,
                                     INPUT aux_nrdconta,
                                     INPUT aux_idseqttl,
                                     INPUT aux_nrcartao,
                                     INPUT aux_tpoperac,
                                    OUTPUT aux_flgsenat,
                                    OUTPUT aux_flgletca,
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
            RUN piXmlAtributo (INPUT "flgsenat",INPUT STRING(aux_flgsenat)).
            RUN piXmlAtributo (INPUT "flgletca",INPUT STRING(aux_flgletca)).
            RUN piXmlSave.
        END.
        
END PROCEDURE.


/******************************************************************************/
/**             Procedure para alterar senha do cartao magnetico             **/
/******************************************************************************/
PROCEDURE alterar-senha-cartao-magnetico:

    RUN alterar-senha-cartao-magnetico IN hBO (INPUT aux_cdcooper,
                                               INPUT aux_cdagenci,
                                               INPUT aux_nrdcaixa,
                                               INPUT aux_cdoperad,
                                               INPUT aux_nmdatela,
                                               INPUT aux_idorigem,
                                               INPUT aux_nrdconta,
                                               INPUT aux_idseqttl,
                                               INPUT aux_dtmvtolt,
                                               INPUT aux_nrcartao,
                                               INPUT aux_nrsenatu,
                                               INPUT aux_nrsencar,
                                               INPUT aux_nrsencon,
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
/**             Procedure para validar senha do cartao magnetico             **/
/******************************************************************************/
PROCEDURE validar-senha-cartao-magnetico:

    RUN validar-senha-cartao-magnetico IN hBO (INPUT aux_cdcooper,
                                               INPUT aux_cdagenci,
                                               INPUT aux_nrdcaixa,
                                               INPUT aux_cdoperad,
                                               INPUT aux_nmdatela,
                                               INPUT aux_idorigem,
                                               INPUT aux_nrdconta,
                                               INPUT aux_idseqttl,
                                               INPUT aux_dtmvtolt,
                                               INPUT aux_nrcartao,
                                               INPUT aux_nrsenatu,
                                               INPUT aux_nrsencar,
                                               INPUT aux_nrsencon,
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
/**    Procedure para obter dados para declaracao de recebimento do cartao   **/
/******************************************************************************/
PROCEDURE declaracao-recebimento-cartao:

    RUN declaracao-recebimento-cartao IN hBO 
                                    (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nmdatela,
                                     INPUT aux_idorigem,
                                     INPUT aux_nrdconta,
                                     INPUT aux_idseqttl,
                                     INPUT aux_dtmvtolt,
                                     INPUT aux_nrcartao,
                                     INPUT TRUE,
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-declar-recebimento).

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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-declar-recebimento:HANDLE,
                        INPUT "Dados").
        
END PROCEDURE.


/******************************************************************************/
/**   Procedure que obtem dados para termo de responsabilidade para cartao   **/
/******************************************************************************/
PROCEDURE termo-responsabilidade-cartao:

    RUN termo-responsabilidade-cartao IN hBO (INPUT aux_cdcooper,
                                              INPUT aux_cdagenci,
                                              INPUT aux_nrdcaixa,
                                              INPUT aux_cdoperad,
                                              INPUT aux_nmdatela,
                                              INPUT aux_idorigem,
                                              INPUT aux_nrdconta,
                                              INPUT aux_idseqttl,
                                              INPUT aux_dtmvtolt,
                                              INPUT TRUE,
                                             OUTPUT TABLE tt-erro,
                                             OUTPUT TABLE tt-termo-magnetico,
                                             OUTPUT TABLE tt-represen-carmag).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-termo-magnetico:HANDLE,
                             INPUT "Dados").
            RUN piXmlExport (INPUT TEMP-TABLE tt-represen-carmag:HANDLE,
                             INPUT "Representantes").
            RUN piXmlSave. 
        END.
                
END PROCEDURE.


/******************************************************************************/
/**       Procedure que verifica se cartao esta disponivel para entrega      **/
/******************************************************************************/
PROCEDURE consiste-cartao:

    RUN consiste-cartao IN hBO (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT aux_nrdconta,
                                INPUT aux_idseqttl,
                                INPUT aux_nrcartao,
                                INPUT aux_flgentrg,
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-declar-recebimento:HANDLE,
                        INPUT "Dados").
        
END PROCEDURE.
 

/*............................................................................*/


/******************************************************************************/
/**            Procedure para limpar a senha de letras do taa                **/
/******************************************************************************/

PROCEDURE limpar-letras:

    
    RUN limpar-letras IN hBO (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_nrdconta,
                              INPUT aux_idseqttl,
                              INPUT aux_dtmvtolt,
                              INPUT aux_nrcartao,
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
/**     Procedure para validar e gravar a nosa senha de letras do taa        **/
/******************************************************************************/
PROCEDURE grava-senha-letras:

    RUN grava-senha-letras IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nmdatela,
                                   INPUT aux_idorigem,
                                   INPUT aux_nrdconta,
                                   INPUT aux_idseqttl,
                                   INPUT aux_dtmvtolt,
                                   INPUT aux_dssennov,
                                   INPUT aux_dssencon,
                                   INPUT TRUE,
                                   OUTPUT aux_flgcadas,
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


/******************************************************************************/
/**           Procedure para validar a entrega do cartão magnético           **/
/******************************************************************************/
PROCEDURE validar-entrega-cartao:

    RUN validar-entrega-cartao IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_nrdconta,
                                       INPUT aux_nrcartao,
                                       OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
  
        IF  NOT AVAILABLE tt-erro  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a operacao.".
        END.
        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                        INPUT "Erro").
    END.
    ELSE 
        RUN piXmlSaida (INPUT TEMP-TABLE tt-dados-carmag:HANDLE,
                        INPUT "Dados").
END PROCEDURE.
