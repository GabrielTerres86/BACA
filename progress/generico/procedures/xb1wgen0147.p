/*.............................................................................

   Programa: xb1wgen0147.p
   Autor   : Lucas R.
   Data    : Maio/2013                      Ultima atualizacao: //

   Dados referentes ao programa:

   Objetivo  : BO DE PROCEDURES REF. OPERACOES COM O BNDES.
   
   Alteracoes :
   
.............................................................................*/

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_vlparepr AS DECI                                           NO-UNDO.
DEF VAR aux_vlsaldod AS DECI                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0147tt.i }
{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i }

/*****************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML    **/
/*****************************************************************************/
PROCEDURE valores_entrada:

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:

            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "vlparepr" THEN aux_vlparepr = DEC(tt-param.valorCampo).
            WHEN "vlsaldod" THEN aux_vlsaldod = DEC(tt-param.valorCampo).

        END CASE.
    END. /* tt-param */

END.

/*** BUSCA DADOS DO COOPERADO ***/
PROCEDURE busca_dados:

    RUN busca_dados IN hBO(INPUT aux_cdcooper,
                           INPUT aux_nrdconta,
                           INPUT aux_cddopcao,
                           OUTPUT TABLE tt-infoass).
                           
    IF  RETURN-VALUE <> "OK" THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                      "busca de dados.".

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport(INPUT TEMP-TABLE tt-infoass:HANDLE,
                                                  INPUT "Dados").
            RUN piXmlSave.   
        END.

END.

/******************************************************************************
******** RESPINSAVEL POR CRIAR, ALTERAR, EXCLUIR DADOS DA TELA CADBND *********
******************************************************************************/
PROCEDURE cria_dados_totvs:

    RUN cria_dados_totvs IN hBO(INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_cdoperad,
                                INPUT aux_nmdatela,
                                INPUT aux_nrdconta,
                                INPUT aux_cddopcao,
                                OUTPUT TABLE tt-erro).
                               
    IF  RETURN-VALUE <> "OK" THEN
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
     
END.

/******************************************************************************
***RESPONSAVEL POR BUSACR DADOS DO BNDES PARA MOSTAR NA ROTINA DE EMPRESTIMOS**
******************************************************************************/
PROCEDURE dados_bndes:

    RUN dados_bndes IN hBO(INPUT aux_cdcooper,
                           INPUT aux_nrdconta,
                          OUTPUT aux_vlparepr, /* paracela */
                          OUTPUT aux_vlsaldod, /* saldo devedor */
                          OUTPUT TABLE tt-saldo-devedor-bndes).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                      "busca dos dados.".

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport(INPUT TEMP-TABLE tt-saldo-devedor-bndes:HANDLE,
                                                  INPUT "Dados_BNDES").
            RUN piXmlAtributo(INPUT "vlparepr", INPUT aux_vlparepr).
            RUN piXmlAtributo(INPUT "vlsaldod", INPUT aux_vlsaldod).
            RUN piXmlSave.   
        END.

END.
