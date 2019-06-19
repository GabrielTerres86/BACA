/*.............................................................................

   Programa: xb1wgen0167.p
   Autor   : Andre Santos - SUPERO
   Data    : Agosto/2013                     Ultima atualizacao: 06/02/2019

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao referente a tela FINALI,
               Finalidade de  Emprestimos.

   Alteracoes: 04/08/2015 - Alterações e correções (Lunelli SD 102123)
   
               06/02/2019 - P510 - Remoção de proc convertida excluir-lcr-finali (Marcos-Envolti)

............................................................................ */

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_cdlcremp AS INTE                                           NO-UNDO.
DEF VAR aux_dslcremp AS CHAR                                           NO-UNDO.
DEF VAR aux_dssitfin AS CHAR                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.
DEF VAR aux_cdfinemp AS INTE                                           NO-UNDO.
DEF VAR aux_dsfinemp AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgen0167tt.i }

/*................................ PROCEDURES ................................*/

/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/
PROCEDURE valores_entrada:

    DEFINE VARIABLE aux_rowid AS ROWID       NO-UNDO.

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = STRING(tt-param.valorCampo).
            WHEN "nmdatela" THEN aux_nmdatela = STRING(tt-param.valorCampo).
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "cdlcremp" THEN aux_cdlcremp = INTE(tt-param.valorCampo).
            WHEN "dslcremp" THEN aux_dslcremp = STRING(tt-param.valorCampo).            
            WHEN "dssitfin" THEN aux_dssitfin = STRING(tt-param.valorCampo).            
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "cdfinemp" THEN aux_cdfinemp = INTE(tt-param.valorCampo).
            WHEN "dsfinemp" THEN aux_dsfinemp = STRING(tt-param.valorCampo).

                
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

    FOR EACH tt-param-i
        BREAK BY tt-param-i.nomeTabela
              BY tt-param-i.sqControle:
        
        CASE tt-param-i.nomeTabela:

            WHEN "FinaliLcr" THEN DO:

                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:
                       CREATE tt-craplch.
                       ASSIGN aux_rowid = ROWID(tt-craplch).
                    END.

                FIND tt-craplch WHERE ROWID(tt-craplch) = aux_rowid NO-ERROR.

                CASE tt-param-i.nomeCampo:
                    WHEN "cdlcrhab" THEN
                        tt-craplch.cdlcrhab = INTE(tt-param-i.valorCampo).

                        
                END CASE.
            END.

        END CASE.
    END.

END PROCEDURE.

PROCEDURE consulta-finali:

    RUN consulta-finali IN hBO
                       (INPUT aux_cdcooper,
                        INPUT aux_cdagenci,
                        INPUT aux_nrdcaixa,
                        INPUT aux_cdoperad,
                        INPUT aux_nmdatela,
                        INPUT aux_idorigem,
                        INPUT aux_dtmvtolt,
                        INPUT aux_cddopcao,
                        INPUT aux_cdfinemp,
                        INPUT aux_nrregist,
                        INPUT aux_nriniseq,
                        OUTPUT aux_dsfinemp,
                        OUTPUT aux_dssitfin,
                        OUTPUT aux_qtregist,
                        OUTPUT TABLE tt-craplch,
                        OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN 
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  NOT AVAILABLE tt-erro THEN 
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
                END.
    
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").    
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-craplch:HANDLE, INPUT "LinhasFinali").
            RUN piXmlAtributo (INPUT "dsfinemp",INPUT STRING(aux_dsfinemp)).
            RUN piXmlAtributo (INPUT "dssitfin",INPUT STRING(aux_dssitfin)).
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE atualiza-finali:

    RUN atualiza-finali IN hBO
                       (INPUT aux_cdcooper,
                        INPUT aux_cdagenci,
                        INPUT aux_nrdcaixa,
                        INPUT aux_cdoperad,
                        INPUT aux_nmdatela,
                        INPUT aux_idorigem,
                        INPUT aux_dtmvtolt,
                        INPUT aux_cddopcao,
                        INPUT aux_cdfinemp,
                        INPUT CAPS(aux_dsfinemp),
                        OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN 
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  NOT AVAILABLE tt-erro THEN 
                DO:
                    CREATE tt-erro.     
                    ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
                END.
    
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE bloqueia-libera-finali:

    RUN bloqueia-libera-finali IN hBO
                              (INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nmdatela,
                               INPUT aux_idorigem,
                               INPUT aux_dtmvtolt,
                               INPUT aux_cddopcao,
                               INPUT aux_cdfinemp,
                               OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE <> "OK" THEN 
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
            IF  NOT AVAILABLE tt-erro THEN 
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
                END.
        
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.
    
END PROCEDURE.


PROCEDURE incluir-finali:

    RUN incluir-finali IN hBO
                      (INPUT aux_cdcooper,
                       INPUT aux_cdagenci,
                       INPUT aux_nrdcaixa,
                       INPUT aux_cdoperad,
                       INPUT aux_nmdatela,
                       INPUT aux_idorigem,
                       INPUT aux_dtmvtolt,
                       INPUT aux_cddopcao,
                       INPUT aux_cdfinemp,
                       INPUT CAPS(aux_dsfinemp),
                       INPUT TABLE tt-craplch,
                       OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN 
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  NOT AVAILABLE tt-erro THEN 
                DO:
                    CREATE tt-erro.     
                    ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE excluir-finali:

    RUN excluir-finali IN hBO
                      (INPUT aux_cdcooper,
                       INPUT aux_cdagenci,
                       INPUT aux_nrdcaixa,
                       INPUT aux_cdoperad,
                       INPUT aux_nmdatela,
                       INPUT aux_idorigem,
                       INPUT aux_dtmvtolt,
                       INPUT aux_cddopcao,
                       INPUT aux_cdfinemp,
                       OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN 
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  NOT AVAILABLE tt-erro THEN 
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
                END.
    
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        END.
    ELSE 
        DO:            
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE lista-linha-credito:

    RUN lista-linha-credito IN hBO
                           (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrregist,
                            INPUT aux_nriniseq,
                            INPUT aux_cdlcremp,
                            INPUT aux_dslcremp,
                            INPUT aux_cddopcao,
                            OUTPUT aux_qtregist,
                            OUTPUT TABLE tt-linhas-cred).

    IF  RETURN-VALUE <> "OK" THEN 
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  NOT AVAILABLE tt-erro THEN 
                DO:
                    CREATE tt-erro.     
                    ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
            RUN piXmlSave.
           
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-linhas-cred:HANDLE, INPUT "LinhasCredito").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.