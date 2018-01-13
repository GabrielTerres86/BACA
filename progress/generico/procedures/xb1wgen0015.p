/*..............................................................................

   Programa: xb1wgen0015.p
   Autor   : David
   Data    : 12/02/2008                        Ultima atualizacao: 12/04/2016

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO Transferencia e URA (b1wgen0015.p)

   Alteracoes: 03/09/2009 - Alteracoes do Projeto de Transferencia para 
                            Credito de Salario (David).
                            
               10/01/2011 - Retirar o tratamento sobre cobranca (Gabriel).   
               
               14/05/2012 - Projeto TED Internet (David).          
               
               03/07/2012 - Ajuste de parametro na procedure
                            valida-inclusao-conta-transferencia (David Kistner)
                            
               11/01/2013 - Requisitar cadastro das Letras ao liberar acesso (Lucas).
               
               22/04/2013 - Alteracao para cadastro de limites Vr Boleto 
                            (David Kruger).
                            
               24/01/2014 - Incluir procedure cria_senha_ura e valida_senha_ura;
                          - Incluir parametro aux_dtmvtolt na procedure 
                            altera_senha_ura;
                          - Incluir parametro aux_flgsnura na procedure
                            carrega_dados_ura. (Reinert)
                         
               16/12/2014 - Melhorias Cadastro de Favorecidos TED
                           (André Santos - SUPERO)
                           
               10/06/2015 - Inclusão da procedure busca_crapban (Vanessa)
               
               24/11/2015 - Adicionado param de entrada aux_flgimpte em 
                            proc. liberar-senha-internet.
                            (Jorge/David) Projeto Multipla Assinatura PJ.

               12/04/2016 - Remocao Aprovacao Favorecido. (Jaison/Marcos - SUPERO)

..............................................................................*/


DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_inconfir AS INTE                                           NO-UNDO.
DEF VAR aux_qtdiaace AS INTE                                           NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.
DEF VAR aux_intipdif AS INTE                                           NO-UNDO.
DEF VAR aux_insitcta AS INTE                                           NO-UNDO.
DEF VAR aux_cddbanco AS INTE                                           NO-UNDO.
DEF VAR aux_cdageban AS INTE                                           NO-UNDO.
DEF VAR aux_intipcta AS INTE                                           NO-UNDO.
DEF VAR aux_cntrgcad AS INTE                                           NO-UNDO.
DEF VAR aux_cntrgpen AS INTE                                           NO-UNDO.
DEF VAR aux_idastcjt AS INTE                                           NO-UNDO.

DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_cddsenha AS CHAR                                           NO-UNDO.
DEF VAR aux_cddsenh2 AS CHAR                                           NO-UNDO.
DEF VAR aux_cdsnhnew AS CHAR                                           NO-UNDO.
DEF VAR aux_cdsnhrep AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmtitula AS CHAR                                           NO-UNDO.
DEF VAR aux_dscpfcgc AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                           NO-UNDO.
DEF VAR aux_msgaviso AS CHAR                                           NO-UNDO.

DEF VAR aux_nrctatrf AS DECI                                           NO-UNDO.
DEF VAR aux_vllimweb AS DECI                                           NO-UNDO.
DEF VAR aux_vllimtrf AS DECI                                           NO-UNDO.
DEF VAR aux_vllimpgo AS DECI                                           NO-UNDO.
DEF VAR aux_vllimted AS DECI                                           NO-UNDO.
DEF VAR aux_vllimvrb AS DECI                                           NO-UNDO.
DEF VAR aux_nrcpfcgc AS DECI                                           NO-UNDO.

DEF VAR aux_flvldinc AS LOGI                                           NO-UNDO.
DEF VAR aux_flgletca AS LOGI                                           NO-UNDO.
DEF VAR aux_flgsnura AS LOGI                                           NO-UNDO.
DEF VAR aux_flgimpte AS LOGI                                           NO-UNDO.

DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.
DEF VAR aux_cdispbif AS INTE                                           NO-UNDO.
DEF VAR aux_nmextbcc AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdambie AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0015tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
          
/*................................ PROCEDURES ................................*/


/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/
PROCEDURE valores_entrada:

    DEFINE VARIABLE aux_rowid AS ROWID       NO-UNDO.

    FOR EACH tt-param:
            
        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "cddsenha" THEN aux_cddsenha = tt-param.valorCampo.
            WHEN "cddsenh2" THEN aux_cddsenh2 = tt-param.valorCampo.
            WHEN "cdsnhnew" THEN aux_cdsnhnew = tt-param.valorCampo.
            WHEN "cdsnhrep" THEN aux_cdsnhrep = tt-param.valorCampo.
            WHEN "inconfir" THEN aux_inconfir = INTE(tt-param.valorCampo).
            WHEN "vllimweb" THEN aux_vllimweb = DECI(tt-param.valorCampo).
            WHEN "vllimtrf" THEN aux_vllimtrf = DECI(tt-param.valorCampo).
            WHEN "vllimpgo" THEN aux_vllimpgo = DECI(tt-param.valorCampo).
            WHEN "vllimted" THEN aux_vllimted = DECI(tt-param.valorCampo).
            WHEN "nrcpfcgc" THEN aux_nrcpfcgc = DECI(tt-param.valorCampo).
            WHEN "nrctatrf" THEN aux_nrctatrf = DECI(tt-param.valorCampo).
            WHEN "intipdif" THEN aux_intipdif = INTE(tt-param.valorCampo).
            WHEN "insitcta" THEN aux_insitcta = INTE(tt-param.valorCampo).
            WHEN "intipcta" THEN aux_intipcta = INTE(tt-param.valorCampo).
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "nmarqimp" THEN aux_nmarqimp = tt-param.valorCampo.
            WHEN "intipcta" THEN aux_intipcta = INTE(tt-param.valorCampo).
            WHEN "nmtitula" THEN aux_nmtitula = tt-param.valorCampo.
            WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.
            WHEN "inpessoa" THEN aux_inpessoa = INTE(tt-param.valorCampo).
            WHEN "cddbanco" THEN aux_cddbanco = INTE(tt-param.valorCampo).
            WHEN "cdageban" THEN aux_cdageban = INTE(tt-param.valorCampo).
            WHEN "cntrgcad" THEN aux_cntrgcad = INTE(tt-param.valorCampo).
            WHEN "cntrgpen" THEN aux_cntrgpen = INTE(tt-param.valorCampo).
            WHEN "flvldinc" THEN aux_flvldinc = LOGICAL(tt-param.valorCampo).
            WHEN "nmtitula" THEN aux_nmtitula = tt-param.valorCampo.
            WHEN "flgletca" THEN aux_flgletca = LOGICAL(tt-param.valorCampo).
            WHEN "vllimvrb" THEN aux_vllimvrb = DECI(tt-param.valorCampo).
            WHEN "cdispbif" THEN aux_cdispbif = INTE(tt-param.valorCampo).
            WHEN "nmextbcc" THEN aux_nmextbcc = tt-param.valorCampo.
           
                

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

    FOR EACH tt-param-i 
        BREAK BY tt-param-i.nomeTabela
              BY tt-param-i.sqControle:

        CASE tt-param-i.nomeTabela:

            WHEN "CntsPend" THEN DO:

                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:
                       CREATE tt-contas-pendentes.
                       ASSIGN aux_rowid = ROWID(tt-contas-pendentes).
                    END.

                FIND tt-contas-pendentes WHERE ROWID(tt-contas-pendentes) = aux_rowid NO-ERROR.

                CASE tt-param-i.nomeCampo:
                    WHEN "cddbanco" THEN
                        tt-contas-pendentes.cddbanco = INTE(tt-param-i.valorCampo).
                    WHEN "cdageban" THEN
                        tt-contas-pendentes.cdageban = INTE(tt-param-i.valorCampo).
                    WHEN "nrctatrf" THEN
                        tt-contas-pendentes.nrctatrf = DECI(tt-param-i.valorCampo).
                    WHEN "nmtitula" THEN
                        tt-contas-pendentes.nmtitula = tt-param-i.valorCampo.
                    WHEN "nrcpfcgc" THEN
                        tt-contas-pendentes.nrcpfcgc = tt-param-i.valorCampo.
                    WHEN "dstransa" THEN
                        tt-contas-pendentes.dstransa = tt-param-i.valorCampo.
                    WHEN "dsprotoc" THEN
                        tt-contas-pendentes.dsprotoc = tt-param-i.valorCampo.
                    WHEN "inpessoa" THEN
                        tt-contas-pendentes.inpessoa = INTE(tt-param-i.valorCampo).
                END CASE.
            END.
        END CASE.
    END.

    
END PROCEDURE.


/******************************************************************************/
/**        Procedure para obter situacao da senha do Tele-Atendimento        **/
/******************************************************************************/
PROCEDURE obtem_situacao_ura:

    RUN obtem_situacao_ura IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nmdatela,
                                   INPUT aux_idorigem,
                                   INPUT aux_nrdconta,
                                   INPUT aux_idseqttl,
                                  OUTPUT TABLE tt-situacao-ura,
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-situacao-ura:HANDLE,
                        INPUT "Dados").
     
END PROCEDURE.


/******************************************************************************/
/**           Procedure para dados sobre senha do Tele-Atendimento           **/
/******************************************************************************/
PROCEDURE carrega_dados_ura:

    RUN carrega_dados_ura IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                 OUTPUT aux_flgsnura,
                                 OUTPUT TABLE tt-dados-ura,
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-dados-ura:HANDLE,
                        INPUT "Dados").
     
END PROCEDURE.


/******************************************************************************/
/**             Procedure para alterar senha do Tele-Atendimento             **/
/******************************************************************************/
PROCEDURE altera_senha_ura:

    RUN altera_senha_ura IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nmdatela,
                                 INPUT aux_idorigem,
                                 INPUT aux_nrdconta,
                                 INPUT aux_idseqttl,
                                 INPUT aux_cddsenha,
                                 INPUT aux_dtmvtolt,
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
/**          Procedure para obter situacao da senha do InternetBank          **/
/******************************************************************************/
PROCEDURE obtem_situacao_internet:

    RUN obtem_situacao_internet IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nmdatela,
                                        INPUT aux_idorigem,
                                        INPUT aux_nrdconta,
                                        INPUT aux_idseqttl,
                                       OUTPUT TABLE tt-situacao-internet).
                             
    RUN piXmlSaida (INPUT TEMP-TABLE tt-situacao-internet:HANDLE,
                    INPUT "Dados").
     
END PROCEDURE.


/******************************************************************************/
/**       Procedure carregar dados dos titulares para acesso a Internet      **/
/******************************************************************************/
PROCEDURE obtem-dados-titulares:
               
    RUN obtem-dados-titulares IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nmdatela,
                                      INPUT aux_idorigem,
                                      INPUT aux_nrdconta,
                                      INPUT aux_idseqttl,
                                      INPUT TRUE, /** LOG **/
                                     OUTPUT aux_inpessoa,
                                     OUTPUT aux_idastcjt,
                                     OUTPUT TABLE tt-dados-titular,
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
            RUN piXmlAtributo (INPUT "inpessoa",INPUT STRING(aux_inpessoa)).
            RUN piXmlAtributo (INPUT "idastcjt",INPUT STRING(aux_idastcjt)).
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-titular:HANDLE,
                             INPUT "Dados").
            RUN piXmlSave.
        END.
        
END PROCEDURE.


/******************************************************************************/
/**              Procedure bloquear senha de acesso a Internet               **/
/******************************************************************************/
PROCEDURE bloquear-senha-internet:

    RUN bloquear-senha-internet IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nmdatela,
                                        INPUT aux_idorigem,
                                        INPUT aux_nrdconta,
                                        INPUT aux_idseqttl,
                                        INPUT aux_dtmvtolt,
                                        INPUT TRUE, /** LOG **/
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
/**              Procedure cancelar senha de acesso a Internet               **/
/******************************************************************************/
PROCEDURE cancelar-senha-internet:

    RUN cancelar-senha-internet IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nmdatela,
                                        INPUT aux_idorigem,
                                        INPUT aux_nrdconta,
                                        INPUT aux_idseqttl,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_inconfir,
                                        INPUT TRUE, /** LOG **/
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
            FIND FIRST tt-msg-confirma NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-msg-confirma  THEN
                RUN piXmlSaida (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                                INPUT "Confirmacao").
            ELSE
                DO:
                    RUN piXmlNew.
                    RUN piXmlSave.
                END.
        END.
        
END PROCEDURE.


/******************************************************************************/
/**              Procedure alterar senha de acesso a Internet                **/
/******************************************************************************/
PROCEDURE alterar-senha-internet:

    RUN alterar-senha-internet IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdoperad,
                                       INPUT aux_nmdatela,
                                       INPUT aux_idorigem,
                                       INPUT aux_nrdconta,
                                       INPUT aux_idseqttl,
                                       INPUT aux_dtmvtolt,
                                       INPUT aux_cddsenha,
                                       INPUT aux_cdsnhnew,
                                       INPUT aux_cdsnhrep,
                                       INPUT TRUE, /** LOG **/
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
/**              Procedure liberar senha de acesso a Internet                **/
/******************************************************************************/
PROCEDURE liberar-senha-internet:
        
    RUN liberar-senha-internet IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdoperad,
                                       INPUT aux_nmdatela,
                                       INPUT aux_idorigem,
                                       INPUT aux_nrdconta,
                                       INPUT aux_idseqttl,
                                       INPUT aux_dtmvtolt,
                                       INPUT aux_cdsnhnew,
                                       INPUT aux_cdsnhrep,
                                       INPUT TRUE, /** LOG **/
                                      OUTPUT aux_qtdiaace,
                                      OUTPUT aux_flgletca,
                                      OUTPUT aux_flgimpte,
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
            RUN piXmlAtributo (INPUT "qtdiaace",INPUT STRING(aux_qtdiaace)).
            RUN piXmlAtributo (INPUT "flgletca",INPUT STRING(aux_flgletca)).
            RUN piXmlAtributo (INPUT "flgimpte",INPUT STRING(aux_flgimpte)).
            RUN piXmlSave.
        END.
        
END PROCEDURE.
        

/******************************************************************************/
/**           Procedure carregar limites de operacoes na Internet            **/
/******************************************************************************/
PROCEDURE obtem-dados-limites:

    RUN obtem-dados-limites IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_nmdatela,
                                    INPUT aux_idorigem,
                                    INPUT aux_nrdconta,
                                    INPUT aux_idseqttl,
                                    INPUT TRUE, /** LOG **/
                                   OUTPUT TABLE tt-dados-habilitacao,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-habilitacao:HANDLE,
                             INPUT "Dados").
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************/
/**            Procedure validar limites de operacoes na Internet            **/
/******************************************************************************/
PROCEDURE valida-dados-limites:

    RUN valida-dados-limites IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nmdatela,
                                     INPUT aux_idorigem,
                                     INPUT aux_nrdconta,
                                     INPUT aux_idseqttl,
                                     INPUT aux_vllimweb,
                                     INPUT aux_vllimtrf,
                                     INPUT aux_vllimpgo,
                                     INPUT aux_vllimted,
                                     INPUT aux_vllimvrb,
                                     INPUT TRUE, /** LOG **/
                                    OUTPUT TABLE tt-dados-preposto,
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-dados-preposto:HANDLE,
                        INPUT "Dados").

END PROCEDURE.


/******************************************************************************/
/**                    Procedure para atualizar preposto                     **/
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
                                   INPUT aux_nrcpfcgc,
                                   INPUT TRUE, /** LOG **/
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
/**            Procedure alterar limites de operacoes na Internet            **/
/******************************************************************************/
PROCEDURE alterar-limites-internet:

    RUN alterar-limites-internet IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_nmdatela,
                                         INPUT aux_idorigem,
                                         INPUT aux_nrdconta,
                                         INPUT aux_idseqttl,
                                         INPUT aux_vllimweb,
                                         INPUT aux_vllimtrf,
                                         INPUT aux_vllimpgo,
                                         INPUT aux_vllimted,
                                         INPUT aux_vllimvrb,
                                         INPUT TRUE, /** LOG **/
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
/**           Procedure com dados do contrato de acesso a Internet           **/
/******************************************************************************/
PROCEDURE gera-termo-responsabilidade:

    RUN gera-termo-responsabilidade IN hBO (INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_cdoperad,
                                            INPUT aux_nmdatela,                                            
                                            INPUT aux_nrdconta,
                                            INPUT aux_idorigem,
                                            INPUT aux_idseqttl,
                                            INPUT aux_dsiduser,
                                            OUTPUT aux_nmarqimp,
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
            RUN piXmlAtributo (INPUT "nmarqimp",INPUT aux_nmarqimp).

            RUN piXmlSave.
        END.
    
END PROCEDURE.

/******************************************************************************/
/**            Procedure para consultar contas para TED cadastradas          **/
/******************************************************************************/
PROCEDURE consulta-contas-cadastradas:

    RUN consulta-contas-cadastradas IN hBO (INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_cdoperad,
                                            INPUT aux_nmdatela,
                                            INPUT aux_idorigem,
                                            INPUT aux_nrdconta,
                                            INPUT aux_idseqttl,
                                            INPUT aux_dtmvtolt,
                                            INPUT aux_inpessoa,
                                            INPUT aux_intipdif,
                                            INPUT aux_nmtitula,
                                           OUTPUT TABLE tt-contas-cadastradas).
                                 
    RUN piXmlSaida (INPUT TEMP-TABLE tt-contas-cadastradas:HANDLE,
                    INPUT "ContasCadastr").

END PROCEDURE.

/******************************************************************************/
/**      Procedure para alterar situação das contas para TED cadastradas     **/
/******************************************************************************/
PROCEDURE altera-dados-cont-cadastrada:

    RUN altera-dados-cont-cadastrada IN hBO (INPUT aux_cdcooper,
                                             INPUT aux_cdagenci,
                                             INPUT aux_nrdcaixa,
                                             INPUT aux_cdoperad,
                                             INPUT aux_nmdatela,
                                             INPUT aux_idorigem,
                                             INPUT aux_nrdconta,
                                             INPUT aux_idseqttl,
                                             INPUT aux_dtmvtolt,
                                             INPUT TRUE, /** LOG **/
                                             INPUT aux_nmtitula,
                                             INPUT aux_nrcpfcgc,
                                             INPUT aux_inpessoa,
                                             INPUT aux_intipcta,
                                             INPUT aux_insitcta,
                                             INPUT aux_intipdif,
                                             INPUT aux_cddbanco,
                                             INPUT aux_cdageban,
                                             INPUT aux_nrctatrf,
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
/**     Procedure para validar inclusao de contas para transferencia         **/
/******************************************************************************/
PROCEDURE valida-inclusao-conta-transferencia:

    RUN valida-inclusao-conta-transferencia IN hBO (INPUT aux_cdcooper,
                                                    INPUT aux_cdagenci,
                                                    INPUT aux_nrdcaixa,
                                                    INPUT aux_cdoperad,
                                                    INPUT aux_nmdatela,
                                                    INPUT aux_idorigem,
                                                    INPUT aux_nrdconta,
                                                    INPUT aux_idseqttl,
                                                    INPUT aux_dtmvtolt,
                                                    INPUT TRUE, /** LOG **/
                                                    INPUT aux_cddbanco,
                                                    INPUT aux_cdispbif,
                                                    INPUT aux_cdageban,
                                                    INPUT aux_nrctatrf,
                                                    INPUT aux_intipdif,
                                                    INPUT-OUTPUT aux_intipcta,
                                                    INPUT aux_insitcta,
                                                    INPUT-OUTPUT aux_inpessoa,
                                                    INPUT-OUTPUT aux_nrcpfcgc,
                                                    INPUT aux_flvldinc,
                                                    INPUT "", /* Validacao de Registro */
                                                    INPUT-OUTPUT aux_nmtitula,
                                                   OUTPUT aux_dscpfcgc,
                                                   OUTPUT aux_nmdcampo,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "dscpfcgc",INPUT STRING(aux_dscpfcgc)).
            RUN piXmlAtributo (INPUT "nmtitula",INPUT aux_nmtitula).
            RUN piXmlAtributo (INPUT "inpessoa",INPUT STRING(aux_inpessoa)).
            RUN piXmlAtributo (INPUT "nrcpfcgc",INPUT STRING(aux_nrcpfcgc)).
            RUN piXmlSave.
        END.

END PROCEDURE.


PROCEDURE verifica-senha-internet:

    RUN verifica-senha-internet IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nmdatela,
                                        INPUT aux_idorigem,
                                        INPUT aux_nrdconta,
                                        INPUT aux_idseqttl,
                                        INPUT aux_dtmvtolt,
                                        INPUT TRUE, /** LOG **/
                                        INPUT aux_cddsenha,
                                        INPUT aux_cdsnhrep,
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

PROCEDURE inclui-conta-transferencia:

    RUN inclui-conta-transferencia IN hBO (INPUT aux_cdcooper,
                                           INPUT aux_cdagenci,
                                           INPUT aux_nrdcaixa,
                                           INPUT aux_cdoperad,
                                           INPUT aux_nmdatela,
                                           INPUT aux_idorigem,
                                           INPUT aux_nrdconta,
                                           INPUT aux_idseqttl,
                                           INPUT aux_dtmvtolt,
                                           INPUT 0,            /* nrcpfope */
                                           INPUT TRUE,         /* flgerlog */
                                           INPUT aux_cddbanco,
                                           INPUT aux_cdageban,
                                           INPUT aux_nrctatrf,
                                           INPUT aux_nmtitula,
                                           INPUT aux_nrcpfcgc,
                                           INPUT aux_inpessoa,
                                           INPUT aux_intipcta,
                                           INPUT aux_intipdif,
                                           INPUT "",           /* rowidcti */
                                           INPUT aux_cdispbif,
                                          OUTPUT aux_msgaviso,
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
            RUN piXmlAtributo(INPUT "msgaviso", INPUT aux_msgaviso).
            RUN piXmlSave.
        END.

END PROCEDURE.



/******************************************************************************/
/**     Procedure para validar inclusao de contas para transferencia         **/
/******************************************************************************/
PROCEDURE resumo-cnts-internet:

    RUN resumo-cnts-internet IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nmdatela,
                                     INPUT aux_idorigem,
                                     INPUT aux_nrdconta,
                                     INPUT aux_idseqttl,
                                     INPUT aux_dtmvtolt,
                                     INPUT FALSE, /** LOG **/
                                     OUTPUT aux_cntrgcad,
                                     OUTPUT aux_cntrgpen,
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
            RUN piXmlAtributo (INPUT "cntrgcad",INPUT STRING(aux_cntrgcad,"999")).
            RUN piXmlAtributo (INPUT "cntrgpen",INPUT STRING(aux_cntrgpen,"999")).
            RUN piXmlSave.
        END.

END PROCEDURE.

/*............................................................................*/

/******************************************************************************/
/**     Procedure para retornar tipos de contas [consultados na CRAPTAB]     **/
/******************************************************************************/
PROCEDURE consulta-tipos-contas:

    RUN consulta-tipos-contas IN hBO(INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                    OUTPUT TABLE tt-tp-contas,
                                    OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN DO:
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-tp-contas:HANDLE,
                             INPUT "TpContas").
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE cria_senha_ura:
    
    RUN cria_senha_ura IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_nrdconta,
                              INPUT aux_cddsenha,
                              INPUT aux_dtmvtolt,
                              INPUT aux_cdoperad,
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

PROCEDURE valida_senha_ura:

    RUN valida_senha_ura IN hBO(INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cddsenha,
                                INPUT aux_cddsenh2,
                               OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"  THEN 
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

PROCEDURE busca_crapban:

    RUN busca_crapban IN hBO(INPUT aux_cddbanco,
                             INPUT aux_nmextbcc,
                             INPUT aux_cdispbif,
                             OUTPUT TABLE  tt-crapban-ispb).

    IF  RETURN-VALUE <> "OK"  THEN 
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
            RUN piXmlExport (INPUT TEMP-TABLE  tt-crapban-ispb:HANDLE,
                             INPUT "bancos").
            RUN piXmlSave.
        END.

END PROCEDURE.
/*............................................................................*/


