/*............................................................................

    Programa: sistema/generico/procedures/b1wgen0133.p
    Autor   : Gabriel Capoia (DB1)
    Data    : 02/02/2012                    Ultima atualizacao: 15/03/2012

    Objetivo  : BO de Comunicacao XML x BO - Tela CADSPC

    Alteracoes: 15/03/2012 - Correção tipo SPC/SERASA na impressão (Oscar).
   
............................................................................*/

/*..........................................................................*/
DEF VAR aux_cdcooper AS INTE                                        NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                        NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                        NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                        NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                        NO-UNDO.
DEF VAR aux_idorigem AS INTE                                        NO-UNDO.
DEF VAR aux_cdprogra AS CHAR                                        NO-UNDO. 
DEF VAR aux_cddopcao AS CHAR                                        NO-UNDO.

DEF VAR aux_nrcpfcgc AS DECI                                        NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                        NO-UNDO.
DEF VAR aux_tpidenti AS INTE                                        NO-UNDO.
DEF VAR aux_nrctremp AS INTE                                        NO-UNDO.
DEF VAR aux_tpctrdev AS INTE                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_nrregist AS INTE                                        NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                        NO-UNDO.
DEF VAR aux_nrctaavl AS INTE                                        NO-UNDO.
DEF VAR aux_flgassoc AS LOGI                                        NO-UNDO.
DEF VAR aux_dtvencto AS DATE                                        NO-UNDO.
DEF VAR aux_dtinclus AS DATE                                        NO-UNDO.
DEF VAR aux_vldivida AS DECI                                        NO-UNDO.
DEF VAR aux_tpinsttu AS INTE                                        NO-UNDO.
DEF VAR aux_dtdbaixa AS DATE                                        NO-UNDO.
DEF VAR aux_nrctrspc AS CHAR                                        NO-UNDO.
DEF VAR aux_dsoberv1 AS CHAR                                        NO-UNDO.
DEF VAR aux_dsoberv2 AS CHAR                                        NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                        NO-UNDO.
DEF VAR aux_cdagencx AS INTE                                        NO-UNDO.

DEF VAR aux_qtregist AS INTE                                        NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                        NO-UNDO.
DEF VAR aux_dsinsttu AS CHAR                                        NO-UNDO.
DEF VAR aux_operador AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                        NO-UNDO.
        
{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0133tt.i } 
/*............................... PROCEDURES ................................*/
PROCEDURE valores_entrada:

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:

            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "cdprogra" THEN aux_cdprogra = tt-param.valorCampo.

            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "nrctrspc" THEN aux_nrctrspc = tt-param.valorCampo.
            WHEN "dsoberv1" THEN aux_dsoberv1 = tt-param.valorCampo.
            WHEN "dsoberv2" THEN aux_dsoberv2 = tt-param.valorCampo.
            WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.

            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "tpidenti" THEN aux_tpidenti = INTE(tt-param.valorCampo).
            WHEN "nrctremp" THEN aux_nrctremp = INTE(tt-param.valorCampo).
            WHEN "tpctrdev" THEN aux_tpctrdev = INTE(tt-param.valorCampo).
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "nrctaavl" THEN aux_nrctaavl = INTE(tt-param.valorCampo).
            WHEN "tpinsttu" THEN aux_tpinsttu = INTE(tt-param.valorCampo).
            WHEN "cdagencx" THEN aux_cdagencx = INTE(tt-param.valorCampo).

            WHEN "dtvencto" THEN aux_dtvencto = DATE(tt-param.valorCampo).
            WHEN "dtinclus" THEN aux_dtinclus = DATE(tt-param.valorCampo).
            WHEN "dtdbaixa" THEN aux_dtdbaixa = DATE(tt-param.valorCampo).

            WHEN "vldivida" THEN aux_vldivida = DECI(tt-param.valorCampo).
            WHEN "nrcpfcgc" THEN aux_nrcpfcgc = DECI(tt-param.valorCampo).

            WHEN "flgassoc" THEN aux_flgassoc = LOGICAL(tt-param.valorCampo).

            WHEN "nrdrowid" THEN aux_nrdrowid = TO-ROWID(tt-param.valorCampo).
                
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE. /* valores_entrada */

/* ------------------------------------------------------------------------ */
/*                     EFETUA A BUSCA DOS DADOS PARA EXIBIÇÃO               */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    RUN Busca_Dados IN hBO
                  ( INPUT aux_cdcooper,
                    INPUT aux_cdagenci,
                    INPUT aux_nrdcaixa,
                    INPUT aux_cdoperad,
                    INPUT aux_cdprogra,
                    INPUT aux_idorigem,
                    INPUT aux_dtmvtolt,
                    INPUT aux_cddopcao,
                    INPUT aux_nrcpfcgc,
                    INPUT aux_nrdconta,
                    INPUT aux_tpidenti,
                    INPUT aux_nrctremp,
                    INPUT aux_tpctrdev,
                    INPUT aux_nrdrowid,
                    INPUT aux_nrregist,
                    INPUT aux_nriniseq,
                   OUTPUT aux_nmdcampo,
                   OUTPUT aux_qtregist,
                   OUTPUT TABLE tt-devedor,
                   OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR  THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
           RETURN.
        END.

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
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
           RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
           RUN piXmlSave.

        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-devedor:HANDLE,
                            INPUT "Dados").
           RUN piXmlAtributo (INPUT "qtregist", INPUT aux_qtregist).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Dados */

/* ------------------------------------------------------------------------ */
/*              EFETUA A BUSCA A CONTA DO DEVEDOR OU FIADOR                 */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Conta:

    RUN Busca_Conta IN hBO
                  ( INPUT aux_cdcooper,
                    INPUT aux_nrcpfcgc,
                   OUTPUT TABLE tt-conta) NO-ERROR.

    IF  ERROR-STATUS:ERROR  THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
           RETURN.
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
               END.

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-conta:HANDLE,
                            INPUT "Dados").
           RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Conta */

/* ------------------------------------------------------------------------ */
/*                  EFETUA A BUSCA DOS DADOS DO DEVEDOR                     */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Devedor:

    RUN Busca_Devedor IN hBO
                    ( INPUT aux_cdcooper,
                      INPUT aux_cdagenci,
                      INPUT aux_nrdcaixa,
                      INPUT aux_nrdconta,
                      INPUT aux_nrcpfcgc,
                      INPUT aux_tpidenti,
                      INPUT aux_cddopcao,
                     OUTPUT aux_nmdcampo,
                     OUTPUT TABLE tt-devedor,
                     OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR  THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
           RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
           RUN piXmlSave.

           RETURN.
        END.

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
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
           RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
           RUN piXmlSave.

        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-devedor:HANDLE,
                            INPUT "Dados").
           RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Devedor */

/* ------------------------------------------------------------------------ */
/*                  EFETUA A BUSCA DOS DADOS DO FIADOR                      */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Fiador:

    RUN Busca_Fiador IN hBO
                   ( INPUT aux_cdcooper,
                     INPUT aux_cdagenci,
                     INPUT aux_nrdcaixa,
                     INPUT aux_cddopcao,
                     INPUT aux_nrdconta,
                     INPUT aux_nrcpfcgc,
                     INPUT aux_tpidenti,
                    OUTPUT aux_nmdcampo,
                    OUTPUT aux_flgassoc,
                    OUTPUT TABLE tt-devedor,
                    OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR  THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
           RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
           RUN piXmlSave.

           RETURN.
        END.

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
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
           RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
           RUN piXmlSave.

        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-devedor:HANDLE,
                            INPUT "Dados").
           RUN piXmlAtributo (INPUT "flgassoc", INPUT aux_flgassoc).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Fiador */

/* ------------------------------------------------------------------------ */
/*                    EFETUA A VALIDACAO OS DADOS DO FIADOR                 */
/* ------------------------------------------------------------------------ */
PROCEDURE Verifica_Fiador:

    RUN Verifica_Fiador IN hBO
                      ( INPUT aux_cdcooper,
                        INPUT aux_cdagenci,
                        INPUT aux_nrdcaixa,
                        INPUT aux_cddopcao,
                        INPUT aux_nrdconta,
                        INPUT aux_nrcpfcgc,
                        INPUT aux_nrctaavl,
                        INPUT aux_tpidenti,
                       OUTPUT aux_nmdcampo, 
                       OUTPUT TABLE tt-devedor,
                       OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR  THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
           RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
           RUN piXmlSave.

           RETURN.
        END.

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
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
           RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
           RUN piXmlSave.

        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-devedor:HANDLE,
                            INPUT "Dados").
           RUN piXmlSave.
        END.

END PROCEDURE. /* Verifica_Fiador */

/* ------------------------------------------------------------------------ */
/*                   EFETUA A BUSCA DOS DADOS DO CONTRATO                   */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Contratos:

    RUN Busca_Contratos IN hBO
                      ( INPUT aux_cdcooper,
                        INPUT aux_cdagenci,
                        INPUT aux_nrdcaixa,
                        INPUT aux_cddopcao,
                        INPUT aux_nrdconta,
                        INPUT aux_nrcpfcgc,
                        INPUT aux_nrctremp,
                        INPUT aux_tpidenti,
                        INPUT aux_tpctrdev,
                        INPUT aux_nrctaavl,
                       OUTPUT aux_nmdcampo,
                       OUTPUT TABLE tt-contrato,
                       OUTPUT TABLE tt-erro) NO-ERROR.
    
    IF  ERROR-STATUS:ERROR  THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
           RETURN.
        END.

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
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
           RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
           RUN piXmlSave.

        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-contrato:HANDLE,
                            INPUT "Dados").
           RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Contratos */

/* ------------------------------------------------------------------------ */
/*                 EFETUA A VALIDACAO DOS DADOS DO CONTRATO                 */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Dados:

    RUN Valida_Dados IN hBO
                   ( INPUT aux_cdcooper,
                     INPUT aux_cdagenci,
                     INPUT aux_nrdcaixa,
                     INPUT aux_idorigem,
                     INPUT aux_cddopcao,
                     INPUT aux_cdoperad,
                     INPUT aux_nrdconta,
                     INPUT aux_nrcpfcgc,
                     INPUT aux_tpidenti,
                     INPUT aux_dtvencto,
                     INPUT aux_dtinclus,
                     INPUT aux_vldivida,
                     INPUT aux_tpinsttu,
                     INPUT aux_dtdbaixa,
                    OUTPUT aux_nmdcampo,
                    OUTPUT aux_dsinsttu,
                    OUTPUT aux_operador,
                    OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR  THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").

           RETURN.
        END.

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
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
           RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
           RUN piXmlSave.

        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "dsinsttu", INPUT aux_dsinsttu).
           RUN piXmlAtributo (INPUT "operador", INPUT aux_operador).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Valida_Dados */

/* ------------------------------------------------------------------------ */
/*                     EFETUA A VALIDACAO DO CONTRATO                       */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Contrato:

    RUN Valida_Contrato IN hBO
                      ( INPUT aux_cdcooper,
                        INPUT aux_cdagenci,
                        INPUT aux_nrdcaixa,
                        INPUT aux_idorigem,
                        INPUT aux_cddopcao,
                        INPUT aux_cdoperad,
                        INPUT aux_tpctrdev,
                        INPUT aux_nrdconta,
                        INPUT aux_nrctremp,
                        INPUT aux_nrcpfcgc,
                        INPUT aux_tpidenti,
                        INPUT aux_nrctaavl,
                       OUTPUT aux_nmdcampo,
                       OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR  THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
           RETURN.
        END.

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
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
           RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
           RUN piXmlSave.

        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Valida_Contrato */

/* ------------------------------------------------------------------------ */
/*                      EFETUA A GRAVACAO DOS DADO                          */
/* ------------------------------------------------------------------------ */
PROCEDURE Grava_Dados:

    RUN Grava_Dados IN hBO
                  ( INPUT aux_cdcooper,
                    INPUT aux_cdagenci,
                    INPUT aux_nrdcaixa,
                    INPUT aux_idorigem,
                    INPUT aux_nmdatela,
                    INPUT aux_cdoperad,
                    INPUT aux_dtmvtolt,
                    INPUT aux_cddopcao,
                    INPUT aux_nrcpfcgc,
                    INPUT aux_nrdconta,
                    INPUT aux_tpidenti,
                    INPUT aux_nrctremp,
                    INPUT aux_tpctrdev,
                    INPUT aux_dtinclus,
                    INPUT aux_nrctrspc,
                    INPUT aux_dtvencto,
                    INPUT aux_vldivida,
                    INPUT aux_tpinsttu,
                    INPUT aux_dsoberv1,
                    INPUT aux_dtdbaixa,
                    INPUT aux_dsoberv2,
                    INPUT aux_nrctaavl,
                    INPUT aux_nrdrowid,
                   OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR  THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
           RETURN.
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
               END.

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlSave.
        END.

END PROCEDURE. /* Grava_Dados */

PROCEDURE Gera_Impressao:

    RUN Gera_Impressao IN hBO
                     ( INPUT aux_cdcooper,
                       INPUT aux_cdagenci,           
                       INPUT aux_nrdcaixa,           
                       INPUT aux_idorigem,           
                       INPUT aux_nmdatela,
                       INPUT aux_cdprogra,
                       INPUT aux_dtmvtolt,
                       INPUT aux_dsiduser,
                       INPUT aux_cdagencx,
                      OUTPUT aux_nmarqimp, 
                      OUTPUT aux_nmarqpdf,
                      OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR  THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
           RETURN.
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
               END.

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Gera_Impressao */
