/*............................................................................

     Programa: sistema/generico/procedures/xb1wgen0125.p
     Autor   : Rogerius Militão
     Data    : Dezembro/2011                    Ultima atualizacao: 00/00/0000

     Objetivo  : BO de Comunicacao XML x BO - Tela CONSCR

     Alteracoes: 

.............................................................................*/
 
/*...........................................................................*/
 DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
 DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
 DEF VAR aux_cdagencx AS INTE                                           NO-UNDO. 
 DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
 DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
 DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
 DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
 
 DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
 DEF VAR aux_tpconsul AS INTE                                           NO-UNDO.
 DEF VAR aux_nrcpfcgc AS DECI                                           NO-UNDO.
 DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
 DEF VAR aux_cdvencto AS INTE                                           NO-UNDO.
 DEF VAR aux_dsiduser AS CHAR                                           NO-UNDO.
 DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
 DEF VAR aux_cdmodali AS CHAR                                           NO-UNDO.
 DEF VAR aux_dsmodali AS CHAR                                           NO-UNDO.
 DEF VAR aux_cdmodalx AS CHAR                                           NO-UNDO.

 /* OUTPUT */
 DEF VAR aux_msgretor AS CHAR                                           NO-UNDO.
 DEF VAR aux_contador AS INTE                                           NO-UNDO.
 DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
 DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.


 { sistema/generico/includes/var_internet.i } 
 { sistema/generico/includes/supermetodos.i } 
 { sistema/generico/includes/b1wgen0125tt.i }

 /*............................... PROCEDURES ................................*/
  PROCEDURE valores_entrada:

      FOR EACH tt-param:

          CASE tt-param.nomeCampo:

              WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
              WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
              WHEN "cdagencx" THEN aux_cdagencx = INTE(tt-param.valorCampo).
              WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
              WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
              WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
              WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
              WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).

              WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
              WHEN "tpconsul" THEN aux_tpconsul = INTE(tt-param.valorCampo).
              WHEN "nrcpfcgc" THEN aux_nrcpfcgc = DECI(tt-param.valorCampo).
              WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
              WHEN "cdvencto" THEN aux_cdvencto = INTE(tt-param.valorCampo).
              WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.
              WHEN "nmprimtl" THEN aux_nmprimtl = tt-param.valorCampo.
              WHEN "cdmodali" THEN aux_cdmodali = tt-param.valorCampo.
              WHEN "cdmodalx" THEN aux_cdmodalx = tt-param.valorCampo.

          END CASE.

      END. /** Fim do FOR EACH tt-param **/


  END PROCEDURE. /* valores_entrada */


 /* ------------------------------------------------------------------------ */
 /*           BUSCA DOS DADOS DA CONTA DO COOPERADO PARA CONSULTA SCR        */
 /* ------------------------------------------------------------------------ */
 PROCEDURE Busca_Dados:

     RUN Busca_Dados IN hBO
                   ( INPUT aux_cdcooper,
                     INPUT aux_cdagenci,
                     INPUT aux_nrdcaixa,
                     INPUT aux_cdoperad,
                     INPUT aux_nmdatela,
                     INPUT aux_idorigem,
                     INPUT aux_dtmvtolt,
                     INPUT aux_cddopcao,
                     INPUT aux_tpconsul,
                     INPUT aux_nrcpfcgc,
                     INPUT aux_nrdconta,
                     INPUT YES, /* flgerlog */
                    OUTPUT aux_contador,
                    OUTPUT TABLE tt-contas,
                    OUTPUT TABLE tt-erro).

     IF  RETURN-VALUE = "NOK" THEN
         DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlSave.

         END.
     ELSE
         DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-contas:HANDLE,
                             INPUT "Contas").
            RUN piXmlAtributo (INPUT "contador", INPUT aux_contador).
            RUN piXmlSave.
         END.

 END PROCEDURE. /* Busca_Dado */


 /* ------------------------------------------------------------------------ */
 /*         CONSULTA DAS INFORMACOES DA CENTRAL DE RISCO DO COOPERADO        */
 /* ------------------------------------------------------------------------ */
 PROCEDURE Busca_Complemento:

     RUN Busca_Complemento IN hBO
                         ( INPUT aux_cdcooper,
                           INPUT aux_cdoperad,
                           INPUT aux_dtmvtolt,
                           INPUT aux_cddopcao,
                           INPUT aux_nrcpfcgc,
                           INPUT aux_nrdconta,
                           INPUT YES , /* flgdelog */
                          OUTPUT aux_msgretor,
                          OUTPUT TABLE tt-complemento,
                          OUTPUT TABLE tt-erro).

     IF  RETURN-VALUE = "NOK" THEN
         DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlSave.

         END.
     ELSE
         DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-complemento:HANDLE,
                             INPUT "Complemento").
            RUN piXmlAtributo (INPUT "msgretor", INPUT aux_msgretor).
            RUN piXmlSave.
         END.

 END PROCEDURE. /* Busca_Complemento */


 /* ------------------------------------------------------------------------ */
 /*                   CONSULTAR FLUXO FINANCEIRO DO COOPERADO                */
 /* ------------------------------------------------------------------------ */
 PROCEDURE Busca_Fluxo:

     RUN Busca_Fluxo IN hBO
                   ( INPUT aux_nrcpfcgc,
                    OUTPUT aux_msgretor,
                    OUTPUT TABLE tt-fluxo,
                    OUTPUT TABLE tt-erro).

     IF  RETURN-VALUE = "NOK" THEN
         DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlSave.

         END.
     ELSE
         DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-fluxo:HANDLE,
                             INPUT "Fluxo").
            RUN piXmlAtributo (INPUT "msgretor", INPUT aux_msgretor).
            RUN piXmlSave.
         END.

 END PROCEDURE. /* Busca_Fluxo */


 /* ------------------------------------------------------------------------ */
 /*            CONSULTAR FLUXO FINANCEIRO DE VENCIMENTO DO COOPERADO         */
 /* ------------------------------------------------------------------------ */
 PROCEDURE Busca_Fluxo_Vencimento:

     RUN Busca_Fluxo_Vencimento IN hBO
                              ( INPUT aux_nrcpfcgc,
                                INPUT aux_cdvencto,
                               OUTPUT TABLE tt-venc-fluxo,
                               OUTPUT TABLE tt-erro).

     IF  RETURN-VALUE = "NOK" THEN
         DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlSave.

         END.
     ELSE
         DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-venc-fluxo:HANDLE,
                             INPUT "Vencimento").
            RUN piXmlSave.
         END.

 END PROCEDURE. /* Busca_Fluxo_Vencimento */


 /* ------------------------------------------------------------------------ */
 /*                  IMPRIMIR FLUXO FINANCEIRO DO COOPERADO                  */
 /* ------------------------------------------------------------------------ */
 PROCEDURE Imprimir_Fluxo:

     RUN Imprimir_Fluxo IN hBO
                      ( INPUT aux_cdcooper,
                        INPUT aux_cdagenci,
                        INPUT aux_nrdcaixa,
                        INPUT aux_idorigem,
                        INPUT aux_dtmvtolt,
                        INPUT aux_dsiduser,
                        INPUT aux_nrcpfcgc,
                        INPUT aux_nmprimtl,
                        INPUT aux_nrdconta,
                       OUTPUT aux_nmarqimp,
                       OUTPUT aux_nmarqpdf,
                       OUTPUT TABLE tt-erro).

     IF  RETURN-VALUE = "NOK" THEN
         DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlSave.

         END.
     ELSE
         DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp", INPUT aux_nmarqimp).
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
            RUN piXmlSave.
         END.

 END PROCEDURE. /* Imprimir_Fluxo */


 /* ------------------------------------------------------------------------ */
 /*           IMPRIMIR INFORMACOES DA CENTRAL DE RISCO DO COOPERADO.         */
 /* ------------------------------------------------------------------------ */
 PROCEDURE Imprimir_Risco:

     RUN Imprimir_Risco IN hBO
                      ( INPUT aux_cdcooper,
                        INPUT aux_cdagencx,
                        INPUT aux_nrdcaixa,
                        INPUT aux_nmdatela,
                        INPUT aux_cdoperad,
                        INPUT aux_idorigem,
                        INPUT aux_dtmvtolt,
                        INPUT aux_dsiduser,
                        INPUT aux_cddopcao,
                        INPUT aux_tpconsul,
                        INPUT aux_nrcpfcgc,
                        INPUT aux_nrdconta,
                        INPUT aux_cdagenci,
                        INPUT YES, /* flgerlog */
                        INPUT YES, /* flgdelog */
                       OUTPUT aux_nmarqimp,
                       OUTPUT aux_nmarqpdf,
                       OUTPUT TABLE tt-erro).

     IF  RETURN-VALUE = "NOK" THEN
         DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlSave.

         END.
     ELSE
         DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp", INPUT aux_nmarqimp).
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
            RUN piXmlSave.
         END.

 END PROCEDURE. /* Imprimir_Risco */


 /* ------------------------------------------------------------------------ */
 /*           CONSULTAR O HISTORICO DA CENTRAL DE RISCO DO COOPERADO.        */
 /* ------------------------------------------------------------------------ */
 PROCEDURE Busca_Historico:

     RUN Busca_Historico IN hBO
                       ( INPUT aux_nrcpfcgc,
                        OUTPUT TABLE tt-historico,
                        OUTPUT TABLE tt-erro).

     IF  RETURN-VALUE = "NOK" THEN
         DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlSave.

         END.
     ELSE
         DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-historico:HANDLE,
                             INPUT "Historico").
            RUN piXmlSave.
         END.

 END PROCEDURE. /* Busca_Historico */


 /* ------------------------------------------------------------------------ */
 /*        CONSULTAR AS MODALIDADES DA CENTRAL DE RISCO DO COOPERADO.        */
 /* ------------------------------------------------------------------------ */
 PROCEDURE Busca_Modalidade:

     RUN Busca_Modalidade IN hBO
                        ( INPUT aux_nrcpfcgc,
                         OUTPUT aux_msgretor,
                         OUTPUT TABLE tt-modalidade,
                         OUTPUT TABLE tt-erro).

     IF  RETURN-VALUE = "NOK" THEN
         DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlSave.

         END.
     ELSE
         DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-modalidade:HANDLE,
                             INPUT "Modalidade").
            RUN piXmlAtributo (INPUT "msgretor", INPUT aux_msgretor).
            RUN piXmlSave.
         END.

 END PROCEDURE. /* Busca_Modalidade */


 /* ------------------------------------------------------------------------ */
 /*   CONSULTAR OS DETALHES DA MODALIDADES DA CENTRAL DE RISCO DO COOPERADO. */
 /* ------------------------------------------------------------------------ */
 PROCEDURE Busca_Modalidade_Detalhe:

     RUN Busca_Modalidade_Detalhe IN hBO
                                ( INPUT aux_nrcpfcgc,
                                  INPUT aux_cdmodali,
                                 OUTPUT aux_cdmodali,
                                 OUTPUT aux_dsmodali,
                                 OUTPUT TABLE tt-detmodal,
                                 OUTPUT TABLE tt-erro).
     
     IF  RETURN-VALUE = "NOK" THEN
         DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlSave.

         END.
     ELSE
         DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-detmodal:HANDLE,
                             INPUT "Detalhe").
            RUN piXmlAtributo (INPUT "cdmodali", INPUT aux_cdmodali).
            RUN piXmlAtributo (INPUT "dsmodali", INPUT aux_dsmodali).
            RUN piXmlSave.
         END.

 END PROCEDURE. /* Busca_Modalidade_Detalhe */


 /* ------------------------------------------------------------------------ */
 /* CONSULTAR OS VENCIMENTOS DA MODALIDADES DA CENTRAL DE RISCO DO COOPERADO.*/
 /* ------------------------------------------------------------------------ */
 PROCEDURE Busca_Modalidade_Vencimento:

     RUN Busca_Modalidade_Vencimento IN hBO
                                   ( INPUT aux_nrcpfcgc,
                                     INPUT aux_cdmodali,
                                    OUTPUT aux_cdmodali,
                                    OUTPUT aux_dsmodali,
                                    OUTPUT aux_msgretor,
                                    OUTPUT TABLE tt-fluxo,
                                    OUTPUT TABLE tt-erro).

     IF  RETURN-VALUE = "NOK" THEN
         DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlSave.

         END.
     ELSE
         DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-fluxo:HANDLE,
                             INPUT "Vencimento").
            RUN piXmlAtributo (INPUT "cdmodali", INPUT aux_cdmodali).
            RUN piXmlAtributo (INPUT "dsmodali", INPUT aux_dsmodali).
            RUN piXmlAtributo (INPUT "msgretor", INPUT aux_msgretor).
            RUN piXmlSave.
         END.

 END PROCEDURE. /* Busca_Modalidade_Vencimento */

