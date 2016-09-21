/*..............................................................................

   Programa: xb1wgen0146.p
   Autor   : David Kruger
   Data    : Janeiro/2013                      Ultima atualizacao: 19/11/2013

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO para tela NOTJUS (b1wgen0146.p)
   

   Alteracoes: 19/11/2013 - Ajustes para homologação (Adriano)

..............................................................................*/


DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_nrseqdig AS INTE                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0146tt.i }
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
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "nrseqdig" THEN aux_nrseqdig = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            
        END CASE.
    
    END. /** Fim do FOR EACH tt-param **/
    
END PROCEDURE.


PROCEDURE busca_associado:
   
   RUN busca_associado IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_dtmvtolt,
                              INPUT aux_cddopcao,
                              INPUT aux_nrdconta,
                              OUTPUT aux_nmdcampo,
                              OUTPUT aux_nmprimtl,
                              OUTPUT TABLE tt-erro).
    
    IF RETURN-VALUE <> "OK" THEN
       DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
          IF NOT AVAILABLE tt-erro THEN
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
           RUN piXmlAtributo(INPUT "nmdcampo",INPUT STRING(aux_nmdcampo)).
           RUN piXmlAtributo(INPUT "nmprimtl",INPUT STRING(aux_nmprimtl)).
           RUN piXmlSave.

       END.

END PROCEDURE.


PROCEDURE busca_estouro:

    RUN busca_estouro IN hBO(INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_dtmvtolt,
                             INPUT aux_cddopcao,
                             INPUT aux_nrdconta,
                             OUTPUT aux_nmdcampo,
                             OUTPUT TABLE tt-estouro, 
                             OUTPUT TABLE tt-erro).
    
    IF RETURN-VALUE <> "OK" THEN
       DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
          IF NOT AVAILABLE tt-erro THEN
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
           RUN piXmlExport(INPUT TEMP-TABLE tt-estouro:HANDLE, INPUT "Estouro").
           RUN piXmlAtributo(INPUT "nmdcampo",INPUT STRING(aux_nmdcampo)).
           RUN piXmlSave.
       END.

END PROCEDURE.

PROCEDURE exclui_registro:

      RUN exclui_registro IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_cddopcao,
                                  INPUT aux_nrdconta,
                                  INPUT aux_nrseqdig,
                                  OUTPUT aux_nmdcampo,
                                  OUTPUT TABLE tt-erro).

    IF RETURN-VALUE <> "OK" THEN
       DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
          IF NOT AVAILABLE tt-erro THEN
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
           RUN piXmlAtributo(INPUT "nmdcampo",INPUT STRING(aux_nmdcampo)).
           RUN piXmlSave.
       END.

END PROCEDURE.

PROCEDURE justifica_estouro:

      RUN justifica_estouro IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_nmdatela,
                                    INPUT aux_idorigem,
                                    INPUT aux_dtmvtolt,
                                    INPUT aux_cddopcao,
                                    INPUT aux_nrdconta,
                                    INPUT aux_nrseqdig,
                                    OUTPUT aux_nmdcampo,
                                    OUTPUT TABLE tt-erro).

    IF RETURN-VALUE <> "OK" THEN
       DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
          IF NOT AVAILABLE tt-erro THEN
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
           RUN piXmlAtributo (INPUT "nmdcampo",INPUT STRING(aux_nmdcampo)).
           RUN piXmlSave.
       END.

END PROCEDURE.

PROCEDURE cria_notificacao:

      RUN cria_notificacao IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nmdatela,
                                   INPUT aux_idorigem,
                                   INPUT aux_dtmvtolt,
                                   INPUT aux_cddopcao,
                                   INPUT aux_nrdconta,
                                   OUTPUT aux_nmdcampo,
                                   OUTPUT TABLE tt-erro).

    IF RETURN-VALUE <> "OK" THEN
       DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
          IF NOT AVAILABLE tt-erro THEN
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
           RUN piXmlAtributo (INPUT "nmdcampo",INPUT STRING(aux_nmdcampo)).
           RUN piXmlSave.
       END.

END PROCEDURE.

