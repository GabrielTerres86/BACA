/*.............................................................................

   Programa: xb1wgen0095.p
   Autor   : André - DB1
   Data    : Junho/2011                     Ultima atualizacao: 00/00/0000

   Dados referentes ao programa:

   Objetivo  : BO ref. a Constra-Ordens/Avisos. (b1wgen0095.p)

   Alteracoes:

............................................................................ */

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nmrotina AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_dsmsgcnt AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.

DEF VAR aux_nrinichq AS INTE                                           NO-UNDO.
DEF VAR aux_cdbanchq AS INTE                                           NO-UNDO.
DEF VAR aux_cdagechq AS INTE                                           NO-UNDO.
DEF VAR aux_nrctachq AS INTE                                           NO-UNDO.
DEF VAR aux_dtemscor AS DATE                                           NO-UNDO.
DEF VAR aux_cdhistor AS INTE                                           NO-UNDO.
DEF VAR aux_nrfinchq AS INTE                                           NO-UNDO.
DEF VAR aux_tptransa AS INTE                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_msgretor AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdctitg AS CHAR                                           NO-UNDO.
DEF VAR aux_flprovis AS LOGI                                           NO-UNDO.
DEF VAR aux_dtvalcor AS DATE                                           NO-UNDO.
DEF VAR aux_cdsitdtl AS INTE                                           NO-UNDO.
DEF VAR aux_posvalid AS INTE                                           NO-UNDO.
DEF VAR aux_tplotmov AS INTE                                           NO-UNDO.
DEF VAR aux_stlcmexc AS INTE                                           NO-UNDO.
DEF VAR aux_stlcmcad AS INTE                                           NO-UNDO.
DEF VAR aux_dtemscch AS DATE                                           NO-UNDO.
DEF VAR aux_dssitdtl AS CHAR                                           NO-UNDO.
DEF VAR aux_flgsenha AS LOGI                                           NO-UNDO.
DEF VAR aux_pedsenha AS LOGI                                           NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR aux_operauto AS CHAR                                           NO-UNDO.

/* DEF VAR aux_tpatlcad AS INTE                                           NO-UNDO. */
/* DEF VAR aux_msgatcad AS CHAR                                           NO-UNDO. */
/* DEF VAR aux_chavealt AS CHAR                                           NO-UNDO. */
/* DEF VAR aux_msgrecad AS CHAR                                           NO-UNDO. */

{ sistema/generico/includes/b1wgen0095tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-WEB=SIM }


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
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "nmrotina" THEN aux_nmrotina = tt-param.valorCampo.
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).

            WHEN "nrinichq" THEN aux_nrinichq = INTE(tt-param.valorCampo).
            WHEN "cdbanchq" THEN aux_cdbanchq = INTE(tt-param.valorCampo).
            WHEN "cdagechq" THEN aux_cdagechq = INTE(tt-param.valorCampo).
            WHEN "nrctachq" THEN aux_nrctachq = INTE(tt-param.valorCampo).
            WHEN "dtemscor" THEN aux_dtemscor = DATE(tt-param.valorCampo).
            WHEN "cdhistor" THEN aux_cdhistor = INTE(tt-param.valorCampo).
            WHEN "nrfinchq" THEN aux_nrfinchq = INTE(tt-param.valorCampo).
            WHEN "tptransa" THEN aux_tptransa = INTE(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "dsdctitg" THEN aux_dsdctitg = tt-param.valorCampo.
            WHEN "cdsitdtl" THEN aux_cdsitdtl = INTE(tt-param.valorCampo).
            WHEN "posvalid" THEN aux_posvalid = INTE(tt-param.valorCampo).
            WHEN "tplotmov" THEN aux_tplotmov = INTE(tt-param.valorCampo).
            WHEN "stlcmcad" THEN aux_stlcmcad = INTE(tt-param.valorCampo).
            WHEN "stlcmexc" THEN aux_stlcmexc = INTE(tt-param.valorCampo).
            WHEN "dtemscch" THEN aux_dtemscch = DATE(tt-param.valorCampo).
            WHEN "flgsenha" THEN aux_flgsenha = LOGICAL(tt-param.valorCampo).
            WHEN "dtvalcor" THEN aux_dtvalcor = DATE(tt-param.valorCampo).
            WHEN "flprovis" THEN aux_flprovis = LOGICAL(tt-param.valorCampo).
            WHEN "operauto" THEN aux_operauto = tt-param.valorCampo.
            WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.

            WHEN "tpatlcad" THEN aux_tpatlcad = INTE(tt-param.valorCampo).
            WHEN "msgatcad" THEN aux_msgatcad = tt-param.valorCampo.
            WHEN "chavealt" THEN aux_chavealt = tt-param.valorCampo.
            WHEN "msgrecad" THEN aux_msgrecad = tt-param.valorCampo.
        END CASE.
        
    END. /** Fim do FOR EACH tt-param **/

    FOR EACH tt-param-i 
        BREAK BY tt-param-i.nomeTabela
              BY tt-param-i.sqControle:

        CASE tt-param-i.nomeTabela:

            WHEN "ContraOrdens" THEN DO:

                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:
                       CREATE tt-contra.
                       ASSIGN aux_rowid = ROWID(tt-contra).
                    END.

                FIND tt-contra WHERE ROWID(tt-contra) = aux_rowid NO-ERROR.

                CASE tt-param-i.nomeCampo:
                    WHEN "cdhistor" THEN
                        tt-contra.cdhistor = INTE(tt-param-i.valorCampo).
                    WHEN "nrinichq" THEN
                        tt-contra.nrinichq = INTE(tt-param-i.valorCampo).
                    WHEN "nrfinchq" THEN
                        tt-contra.nrfinchq = INTE(tt-param-i.valorCampo).
                    WHEN "nrctachq" THEN
                        tt-contra.nrctachq = INTE(tt-param-i.valorCampo).
                    WHEN "cdbanchq" THEN
                        tt-contra.cdbanchq = INTE(tt-param-i.valorCampo).
                    WHEN "cdagechq" THEN
                        tt-contra.cdagechq = INTE(tt-param-i.valorCampo).
                    WHEN "nrdconta" THEN
                        tt-contra.nrdconta = INTE(tt-param-i.valorCampo).
                    WHEN "flgfecha" THEN
                        tt-contra.flgfecha = LOGICAL(tt-param-i.valorCampo).
                    WHEN "dtvalcor" THEN
                        tt-contra.dtvalcor = DATE(tt-param-i.valorCampo).
                    WHEN "flprovis" THEN
                        tt-contra.flprovis = LOGICAL(tt-param-i.valorCampo).
                END CASE.
            END.
            WHEN "Custodia" THEN DO:

                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:
                       CREATE tt-custdesc.
                       ASSIGN aux_rowid = ROWID(tt-custdesc).
                    END.

                FIND tt-contra WHERE ROWID(tt-custdesc) = aux_rowid NO-ERROR.

                CASE tt-param-i.nomeCampo:
                    WHEN "nrdconta" THEN
                       tt-custdesc.nrdconta = INTE(tt-param-i.valorCampo).
                    WHEN "nmprimtl" THEN
                       tt-custdesc.nmprimtl = tt-param-i.valorCampo.
                    WHEN "dtliber1" THEN
                        tt-custdesc.dtliber1 = DATE(tt-param-i.valorCampo).
                    WHEN "cdpesqu1" THEN
                       tt-custdesc.cdpesqu1 = tt-param-i.valorCampo.
                    WHEN "dtliber2" THEN
                        tt-custdesc.dtliber2 = DATE(tt-param-i.valorCampo).
                    WHEN "cdpesqu2" THEN
                       tt-custdesc.cdpesqu2 = tt-param-i.valorCampo.
                    WHEN "cdbanchq" THEN
                        tt-custdesc.cdbanchq = INTE(tt-param-i.valorCampo).
                    WHEN "cdagechq" THEN
                        tt-custdesc.cdagechq = INTE(tt-param-i.valorCampo).
                     WHEN "nrctachq" THEN
                        tt-custdesc.nrctachq = DECI(tt-param-i.valorCampo).
                    WHEN "nrcheque" THEN
                        tt-custdesc.nrcheque = INTE(tt-param-i.valorCampo).
                    WHEN "cdhistor" THEN
                        tt-custdesc.cdhistor = INTE(tt-param-i.valorCampo).
                    WHEN "flgselec" THEN
                        tt-custdesc.flgselec = LOGICAL(tt-param-i.valorCampo).
                    WHEN "flgcusto" THEN
                        tt-custdesc.flgcusto = LOGICAL(tt-param-i.valorCampo).
                    WHEN "flgdesco" THEN
                        tt-custdesc.flgdesco = LOGICAL(tt-param-i.valorCampo).
                END CASE.
            END.
            WHEN "Cheques" THEN DO:

                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:
                       CREATE tt-cheques.
                       ASSIGN aux_rowid = ROWID(tt-cheques).
                    END.

                FIND tt-cheques WHERE ROWID(tt-cheques) = aux_rowid NO-ERROR.

                CASE tt-param-i.nomeCampo:
                    WHEN "cdbanchq" THEN
                        tt-cheques.cdbanchq = INTE(tt-param-i.valorCampo).
                    WHEN "cdagechq" THEN
                        tt-cheques.cdagechq = INTE(tt-param-i.valorCampo).
                    WHEN "nrctachq" THEN
                        tt-cheques.nrctachq = INTE(tt-param-i.valorCampo).
                    WHEN "nrcheque" THEN
                        tt-cheques.nrcheque = INTE(tt-param-i.valorCampo).
                    WHEN "nrinichq" THEN
                        tt-cheques.nrinichq = INTE(tt-param-i.valorCampo).
                    WHEN "nrfinchq" THEN
                        tt-cheques.nrfinchq = INTE(tt-param-i.valorCampo).
                    WHEN "nrdconta" THEN
                        tt-cheques.nrdconta = INTE(tt-param-i.valorCampo).
                    WHEN "cdhistor" THEN
                        tt-cheques.cdhistor = INTE(tt-param-i.valorCampo).
                   WHEN "dscritic" THEN
                        tt-cheques.dscritic = tt-param-i.valorCampo.
                   WHEN "dtvalcor" THEN
                        tt-cheques.dtvalcor = DATE(tt-param-i.valorCampo).
                    WHEN "flprovis" THEN
                        tt-cheques.flprovis = LOGICAL(tt-param-i.valorCampo).
                END CASE.
            END.
        END CASE.
    END.
    
END PROCEDURE.

/*****************************************************************************/
/*                                Buscar dados                               */
/*****************************************************************************/
PROCEDURE busca-dados:

    RUN busca-dados IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrdconta,
                            INPUT aux_idseqttl,
                            INPUT aux_dtmvtolt,
                            INPUT TRUE, /* LOG */
                            INPUT aux_cddopcao,
                            INPUT aux_tptransa,
                           OUTPUT aux_msgretor,
                           OUTPUT TABLE tt-erro, 
                           OUTPUT TABLE tt-dctror).
    
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
            RUN piXmlAtributo (INPUT "msgretor", INPUT aux_msgretor).
            RUN piXmlExport (INPUT TEMP-TABLE tt-dctror:HANDLE,
                             INPUT "Dados").
            RUN piXmlSave.

        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-dctror:HANDLE,
                             INPUT "Dados").
            RUN piXmlAtributo (INPUT "msgretor", INPUT aux_msgretor).
            RUN piXmlSave.
        END.

        
END PROCEDURE.

/*****************************************************************************/
/*                            Valida  Conta Cheque                           */
/*****************************************************************************/
PROCEDURE valida-ctachq:

    RUN valida-ctachq IN hBO ( INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nmdatela,
                               INPUT aux_idorigem,
                               INPUT aux_nrdconta,
                               INPUT aux_idseqttl,
                               INPUT TRUE,
                               INPUT aux_dtmvtolt,
                               INPUT aux_dtemscor,
                               INPUT aux_nrctachq,
                               INPUT aux_nrinichq,
                               INPUT aux_nrfinchq,
                               INPUT aux_cddopcao,
                               INPUT aux_cdbanchq,
                               INPUT aux_cdhistor,
                              OUTPUT aux_dsdctitg,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "dsdctitg",INPUT STRING(aux_dsdctitg)).
            RUN piXmlSave.
        END.

        
END PROCEDURE.

/*****************************************************************************/
/*                            Verifica Opcao Banco                           */
/*****************************************************************************/
PROCEDURE valida-agechq:

    RUN valida-agechq IN hBO ( INPUT aux_cdcooper, 
                               INPUT aux_cdagenci, 
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nmdatela, 
                               INPUT aux_idorigem, 
                               INPUT aux_nrdconta, 
                               INPUT aux_idseqttl,
                               INPUT TRUE,
                               INPUT aux_cdbanchq,
                               INPUT aux_cddopcao,
                              OUTPUT aux_cdagechq, 
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "cdagechq",INPUT STRING(aux_cdagechq)).
            RUN piXmlSave.
        END.

        
END PROCEDURE.

/*****************************************************************************/
/*                                   Valida Dados                            */
/*************************************~****************************************/
PROCEDURE busca-ctachq:

    RUN busca-ctachq IN hBO (INPUT aux_cdcooper,      
                             INPUT aux_cdagenci,      
                             INPUT aux_nrdcaixa,
                             INPUT aux_nrdconta,      
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_idseqttl,
                             INPUT TRUE,
                             INPUT aux_nrinichq,
                             INPUT aux_cdbanchq,
                             INPUT aux_cdagechq,
                             INPUT aux_nrctachq,
                             INPUT aux_cddopcao,
                             INPUT aux_cdsitdtl,
                             INPUT aux_dsdctitg,
                             INPUT aux_posvalid,
                            OUTPUT aux_dtemscor,
                            OUTPUT aux_cdhistor,
                            OUTPUT aux_nrfinchq,
                            OUTPUT aux_dtvalcor,
                            OUTPUT aux_flprovis,
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
            RUN piXmlExport   (INPUT TEMP-TABLE tt-erro:HANDLE,
                               INPUT "Erro").
            RUN piXmlSave.        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "dtemscor",INPUT STRING(aux_dtemscor,"99/99/9999")).
            RUN piXmlAtributo (INPUT "cdhistor",INPUT STRING(aux_cdhistor)).
            RUN piXmlAtributo (INPUT "nrfinchq",INPUT STRING(aux_nrfinchq)).
            RUN piXmlAtributo (INPUT "dtvalcor",INPUT STRING(aux_dtvalcor,"99/99/9999")).
            RUN piXmlAtributo (INPUT "flprovis",INPUT STRING(aux_flprovis)).
            RUN piXmlSave.
        END.

        
END PROCEDURE.

/*****************************************************************************/
/*                               Valida Historico                            */
/*****************************************************************************/
PROCEDURE valida-hist:

    RUN valida-hist IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrdconta,
                            INPUT aux_idseqttl,
                            INPUT TRUE,
                            INPUT aux_cdhistor,
                           OUTPUT aux_tplotmov,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "tplotmov",INPUT STRING(aux_tplotmov)).
            RUN piXmlSave.
        END.

        
END PROCEDURE.


/*****************************************************************************/
/*                               Gravacao dos Dados                          */
/*****************************************************************************/
PROCEDURE grava-dados:

    RUN grava-dados IN hBO ( INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_nrdconta,
                             INPUT aux_idseqttl,
                             INPUT TRUE,
                             INPUT aux_dtmvtolt,
                             INPUT aux_cddopcao,
                             INPUT aux_tptransa,
                             INPUT aux_tplotmov,
                             INPUT aux_cdbanchq,
                             INPUT aux_cdagechq,
                             INPUT aux_nrctachq,
                             INPUT aux_nrinichq,
                             INPUT aux_cdhistor,
                             INPUT aux_stlcmexc,
                             INPUT aux_stlcmcad,
                             INPUT aux_dtemscch,
                             INPUT aux_dsdctitg,
                             INPUT aux_flprovis,
                             INPUT aux_dtvalcor,
                             INPUT TABLE tt-cheques,
                             INPUT TABLE tt-custdesc,
                            OUTPUT aux_cdsitdtl,
                            OUTPUT aux_dssitdtl,
                            OUTPUT aux_tpatlcad,
                            OUTPUT aux_msgatcad,
                            OUTPUT aux_chavealt,
                            OUTPUT aux_msgrecad,
                            OUTPUT TABLE tt-erro,
                            OUTPUT TABLE tt-criticas,
                            OUTPUT TABLE tt-contra ).
    
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-criticas:HANDLE,
                             INPUT "Criticas").
            RUN piXmlExport (INPUT TEMP-TABLE tt-contra:HANDLE,
                             INPUT "ContraOrdens").
            RUN piXmlAtributo (INPUT "dssitdtl",INPUT STRING(aux_dssitdtl)).
            RUN piXmlAtributo (INPUT "tpatlcad",INPUT STRING(aux_tpatlcad)).
            RUN piXmlAtributo (INPUT "msgatcad",INPUT STRING(aux_msgatcad)).
            RUN piXmlAtributo (INPUT "chavealt",INPUT STRING(aux_chavealt)).
            RUN piXmlAtributo (INPUT "msgrecad",INPUT STRING(aux_msgrecad)).
            RUN piXmlAtributo (INPUT "cdsitdtl",INPUT STRING(aux_cdsitdtl)).
            RUN piXmlSave.
        END.

        
END PROCEDURE.


/*****************************************************************************/
/*                               Busca Contra-Ordens                         */
/*****************************************************************************/
PROCEDURE busca-contra-ordens:

    RUN busca-contra-ordens IN hBO ( INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdagechq,
                                     INPUT aux_nrctachq,
                                     INPUT aux_cdbanchq,
                                     INPUT aux_cddopcao,
                                     INPUT aux_nrinichq,
                                     INPUT aux_nrfinchq,
                                     INPUT aux_cdhistor,
                                     INPUT aux_nrdconta,
                                     INPUT aux_flprovis,
                                     INPUT TABLE tt-contra,
                                    OUTPUT TABLE tt-dctror,
                                    OUTPUT TABLE tt-erro ).
    
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-dctror:HANDLE,
                             INPUT "Dados").
            RUN piXmlSave.
        END.

        
END PROCEDURE.

/*****************************************************************************/
/*                        Valida Contra-Ordens Inseridas                     */
/*****************************************************************************/
PROCEDURE valida-contra:

    RUN valida-contra IN hBO ( INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_nrdconta,
                               INPUT aux_cddopcao,
                               INPUT aux_flgsenha,
                               INPUT aux_operauto,
                               INPUT aux_dsdctitg,
                               INPUT aux_flprovis, /*Se provisorio */
                               INPUT TABLE tt-contra,
                              OUTPUT aux_pedsenha,
                              OUTPUT TABLE tt-cheques,
                              OUTPUT TABLE tt-custdesc ).
    
    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                      "operacao.".
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "pedsenha",INPUT STRING(aux_pedsenha)).
            RUN piXmlExport (INPUT TEMP-TABLE tt-cheques:HANDLE,
                             INPUT "Cheques").
            RUN piXmlExport (INPUT TEMP-TABLE tt-custdesc:HANDLE,
                             INPUT "CustDesc").
            RUN piXmlSave.
        END.

        
END PROCEDURE.

/*****************************************************************************/
/*                               Imprimir dados                              */
/*****************************************************************************/
PROCEDURE imprimir-dados:

    RUN imprimir-dados IN hBO ( INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_idorigem,
                                INPUT aux_dtmvtolt,
                                INPUT aux_nrdconta,
                                INPUT aux_dsiduser,
                                INPUT aux_cddopcao,
                                INPUT TABLE tt-contra,
                               OUTPUT aux_nmarqimp,
                               OUTPUT aux_nmarqpdf,
                               OUTPUT TABLE tt-erro ).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                      "operacao.".
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp",INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.

        
END PROCEDURE.


/*****************************************************************************/
/*             Gera log ao abandonar inclusão de cheques na exclusao         */
/*****************************************************************************/
PROCEDURE gera-log:

    RUN gera-log IN hBO ( INPUT aux_cdcooper,
                          INPUT aux_cdagenci,
                          INPUT aux_nrdcaixa,
                          INPUT aux_cdoperad,
                          INPUT aux_nmdatela,
                          INPUT aux_idseqttl,
                          INPUT aux_idorigem,
                          INPUT TABLE tt-contra,
                         OUTPUT aux_msgretor ).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                      "operacao.".

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "msgretor",INPUT STRING(aux_msgretor)).
            RUN piXmlSave.
        END.

        
END PROCEDURE.

