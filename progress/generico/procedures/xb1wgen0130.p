/*..............................................................................

   Programa: xb1wgen0130.p
   Autor   : Lucas
   Data    : Nov/2011                       Ultima atualizacao:

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO130 (b1wgen0130.p) [TAB002]

   Alteracoes: 06/12/2016 - P341-Automatização BACENJUD - Alterar a passagem da descrição do 
                            departamento como parametro e passar o código (Renato Darosci)

..............................................................................*/

DEF VAR aux_cdcooper AS INTE                                       NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                       NO-UNDO.             
DEF VAR aux_nrdcaixa AS INTE                                       NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                       NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                       NO-UNDO.
DEF VAR aux_idorigem AS INTE                                       NO-UNDO.
DEF VAR aux_flgerlog AS LOGI                                       NO-UNDO.
DEF VAR aux_dstextab AS CHAR                                       NO-UNDO.
DEF VAR aux_cddepart AS INTE                                       NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                       NO-UNDO.

DEF VAR aux_qtfolind AS INT                                        NO-UNDO.
DEF VAR aux_qtfolcjt AS INT                                        NO-UNDO.

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
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "flgerlog" THEN aux_flgerlog = LOGICAL(tt-param.valorCampo).
            WHEN "dstextab" THEN aux_dstextab = tt-param.valorCampo.
            WHEN "cddepart" THEN aux_cddepart = INTE(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "qtfolind" THEN aux_qtfolind = INT(tt-param.valorCampo).
            WHEN "qtfolcjt" THEN aux_qtfolcjt = INT(tt-param.valorCampo).

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.

/*****************************************************************************
  Carregar os dados gravados na TAB002
******************************************************************************/

PROCEDURE busca_tab002:

    RUN busca_tab002 IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_cddopcao,
                             OUTPUT aux_qtfolind,
                             OUTPUT aux_qtfolcjt,
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
           RUN piXmlAtributo (INPUT "qtfolind", INPUT aux_qtfolind).
           RUN piXmlAtributo (INPUT "qtfolcjt", INPUT aux_qtfolcjt).
           RUN piXmlSave.
        END.

END PROCEDURE.

 /*****************************************************************************
  Alterar os dados gravados na tab002
******************************************************************************/

PROCEDURE altera_tab002:

    RUN altera_tab002 IN hBO (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_dtmvtolt,
                              INPUT TRUE,
                              INPUT aux_cddepart,
                              INPUT aux_qtfolind,
                              INPUT aux_qtfolcjt,
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
  Deletar registro da Cooperativa na TAB002  
******************************************************************************/

PROCEDURE deleta_tab002:

    RUN deleta_tab002 IN hBO (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_dtmvtolt,
                              INPUT TRUE,
                              INPUT aux_cddepart,
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
  Criar registro da Cooperativa na TAB002  
******************************************************************************/

PROCEDURE cria_tab002:

    RUN cria_tab002 IN hBO (  INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_dtmvtolt,
                              INPUT TRUE,
                              INPUT aux_cddepart,
                              INPUT aux_qtfolind,
                              INPUT aux_qtfolcjt,
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
