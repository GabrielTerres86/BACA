/*..............................................................................

   Programa: xb1wgen0148.p
   Autor   : Lucas Lunelli
   Data    : Janeiro/2013                   Ultima atualizacao: 07/01/2015 

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO148 (b1wgen0148.p) [BLQRGT]

   Alteracoes: 14/05/2014 - Adicionado parâmetro "aux_dtmvtolt" 
                            na "busca-blqrgt" (Douglas)

               26/05/2014 - Adicionado cddopcao para a leitura de aplicacoes
                            (Douglas - Chamado 77209)
                            
               17/10/2014 - Inclusão do parametro par_idtipapl nas procedures
                            busca-blqrgt, bloqueia-blqrgt, libera-blqrgt
                            (Jean Michel).
                            
               07/01/2015 - Ajuste no log de bloqueio de aplicacoes e
                             inclusao de novos parametros (Jean Michel).
                             
..............................................................................*/

DEF VAR aux_cdcooper AS INTE                                       NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                       NO-UNDO.             
DEF VAR aux_nrdcaixa AS INTE                                       NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                       NO-UNDO.
DEF VAR aux_tpaplica AS INTE                                       NO-UNDO.
DEF VAR aux_nraplica AS INTE                                       NO-UNDO.
DEF VAR aux_idorigem AS INTE                                       NO-UNDO.
DEF VAR aux_nrregist AS INTE                                       NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                       NO-UNDO.
DEF VAR aux_qtregist AS INTE                                       NO-UNDO.

DEF VAR aux_cdoperad AS CHAR                                       NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                       NO-UNDO.
DEF VAR aux_nmaplica AS CHAR                                       NO-UNDO.
DEF VAR aux_dsdconta AS CHAR                                       NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                       NO-UNDO.
DEF VAR aux_idtipapl AS CHAR                                       NO-UNDO.
DEF VAR aux_nmprodut AS CHAR                                       NO-UNDO.

DEF VAR aux_flgerlog AS LOGI                                       NO-UNDO.
DEF VAR aux_flgstapl AS LOGI                                       NO-UNDO.

{ sistema/generico/includes/b1wgen0148tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }

/* .........................PROCEDURES................................... */

/**************************************************************************
       Procedure para atribuicao dos dados de entrada enviados por XML
**************************************************************************/
PROCEDURE valores_entrada:

    FOR EACH tt-param NO-LOCK:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).           
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "flgerlog" THEN aux_flgerlog = LOGICAL(tt-param.valorCampo).
            WHEN "nmaplica" THEN aux_nmaplica = tt-param.valorCampo.
            WHEN "dsdconta" THEN aux_dsdconta = tt-param.valorCampo.
            WHEN "flgstapl" THEN aux_flgstapl = LOGICAL(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "qtregist" THEN aux_qtregist = INTE(tt-param.valorCampo).
            WHEN "tpaplica" THEN aux_tpaplica = INTE(tt-param.valorCampo).
            WHEN "nraplica" THEN aux_nraplica = INTE(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "idtipapl" THEN aux_idtipapl = tt-param.valorCampo.
            WHEN "nmprodut" THEN aux_nmprodut = tt-param.valorCampo.
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.

/*****************************************************************************
  Carrega aplicacoes da tela BLQRGT
******************************************************************************/
PROCEDURE carrega-apl-blqrgt:

    RUN carrega-apl-blqrgt IN hBO (INPUT  aux_cdcooper,
                                   OUTPUT TABLE tt-crapcpc).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-crapcpc:HANDLE,
                            INPUT "NMAPLICA").
           RUN piXmlSave.
        END.

END PROCEDURE.

/*****************************************************************************
  Buscar os dados da tela BLQRGT
******************************************************************************/
PROCEDURE busca-blqrgt:

    RUN busca-blqrgt IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nrdconta,
                             INPUT aux_tpaplica,
                             INPUT aux_nraplica,
                             INPUT aux_dtmvtolt,
                             INPUT aux_idtipapl,
                             OUTPUT aux_flgstapl,
                             OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
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
           RUN piXmlAtributo (INPUT "flgstapl", INPUT aux_flgstapl).
           RUN piXmlSave.
        END.

END PROCEDURE.

/*****************************************************************************
  Bloquear aplicações na tela BLQRGT
******************************************************************************/
PROCEDURE bloqueia-blqrgt:
    
    RUN bloqueia-blqrgt IN hBO (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nrdconta,
                                INPUT aux_tpaplica,
                                INPUT aux_nraplica,
                                INPUT aux_dtmvtolt,
                                INPUT TRUE,
                                INPUT aux_idtipapl,
                                INPUT aux_nmprodut,
                                OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
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

/*****************************************************************************
  Liberar aplicações na tela BLQRGT
******************************************************************************/
PROCEDURE libera-blqrgt:

    RUN libera-blqrgt IN hBO (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nrdconta,
                              INPUT aux_tpaplica,
                              INPUT aux_nraplica,
                              INPUT aux_dtmvtolt,
                              INPUT TRUE,
                              INPUT aux_idtipapl,
                              INPUT aux_nmprodut,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
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

/******************************************************************************
 Listagem de Aplicações 
******************************************************************************/
PROCEDURE lista-aplicacoes:
    
    RUN lista-aplicacoes IN hBO(INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT aux_nrdconta,
                                INPUT aux_tpaplica,
                                INPUT aux_nraplica,
                                INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist), 
                                INPUT aux_nriniseq, 
                                INPUT aux_cddopcao,
                                INPUT aux_idtipapl,
                                OUTPUT aux_qtregist,
                                OUTPUT TABLE tt-aplicacoes,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-aplicacoes:HANDLE,
                             INPUT "Aplic").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/*****************************************************************************
  Validar existencia da Conta/dv
******************************************************************************/
PROCEDURE valida-conta:

    RUN valida-conta IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nrdconta,
                             OUTPUT aux_dsdconta,
                             OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
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
           RUN piXmlAtributo (INPUT "dsdconta", INPUT aux_dsdconta).
           RUN piXmlSave.
        END.

END PROCEDURE.
