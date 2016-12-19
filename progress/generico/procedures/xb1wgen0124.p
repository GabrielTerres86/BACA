/*..............................................................................

   Programa: xb1wgen0124.p
   Autor   : Lucas
   Data    : Nov/2011                       Ultima atualizacao:

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO124 (b1wgen0124.p) [TAB036]

   Alteracoes: 06/12/2016 - P341-Automatização BACENJUD - Alterar a passagem 
			                da descrição do departamento como parametro e 
							passar o código (Renato Darosci)

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
DEF VAR aux_vlrating AS DECI                                       NO-UNDO.
DEF VAR aux_vlgrecon AS DECI                                       NO-UNDO.
 
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
            WHEN "vlrating" THEN aux_vlrating = DEC(tt-param.valorCampo).
            WHEN "vlgrecon" THEN aux_vlgrecon = DEC(tt-param.valorCampo).

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.


/*****************************************************************************
  Valida permissão
******************************************************************************/

PROCEDURE permiss_tab036:

        RUN permiss_tab036 IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
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
  Carregar os dados gravados na TAB 
******************************************************************************/
PROCEDURE busca_tab036:

        RUN busca_tab036 IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 OUTPUT aux_vlrating,
                                 OUTPUT aux_vlgrecon,
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
               RUN piXmlAtributo (INPUT "vlrating", INPUT STRING(aux_vlrating,"zzz,zzz,zz9.99")).
               RUN piXmlAtributo (INPUT "vlgrecon", INPUT STRING(aux_vlgrecon,"zz9.99")).
               RUN piXmlSave.
            END.

END PROCEDURE.

/*****************************************************************************
  Alterar os dados gravados na TAB 
******************************************************************************/
PROCEDURE altera_tab036:

    RUN altera_tab036 IN hBO (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_dtmvtolt,
                              INPUT TRUE,
                              INPUT aux_dstextab,
                              INPUT aux_cddepart,
                              INPUT aux_vlrating,
                              INPUT aux_vlgrecon,
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
