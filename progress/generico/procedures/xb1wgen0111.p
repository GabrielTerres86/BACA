/*..............................................................................

   Programa: xb1wgen0111.p
   Autor   : Adriano
   Data    : Agosto/2011                        Ultima atualizacao:   /  /

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO Generica (b1wgen0111.p)

   Alteracoes: 

..............................................................................*/


DEF VAR aux_cdcooper AS INTE                                       NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                       NO-UNDO.             
DEF VAR aux_nrdcaixa AS INTE                                       NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                       NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                       NO-UNDO.
DEF VAR aux_idorigem AS INTE                                       NO-UNDO.
DEF VAR aux_flgerlog AS LOGI                                       NO-UNDO.
DEF VAR aux_dstextab AS CHAR                                       NO-UNDO.
DEF VAR aux_dsdepart AS CHAR                                       NO-UNDO.
DEF VAR aux_cdcopalt AS INTE                                       NO-UNDO.
DEF VAR aux_nmcooper AS CHAR                                       NO-UNDO.

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
            WHEN "dsdepart" THEN aux_dsdepart = tt-param.valorCampo.
            WHEN "cdcopalt" THEN aux_cdcopalt = INTE(tt-param.valorCampo).

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.

/*****************************************************************************
  Consulta TAB 
******************************************************************************/
PROCEDURE consulta_tab:
    
    RUN consulta_tab IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_cdcopalt,
                             INPUT aux_dsdepart,
                            OUTPUT aux_dstextab,
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
            RUN piXmlAtributo (INPUT "dstextab", INPUT aux_dstextab).
            RUN piXmlSave.
        END.

END PROCEDURE.


/*****************************************************************************
  Alterar  TAB 
******************************************************************************/
PROCEDURE altera_tab:

    RUN altera_tab IN hBO (INPUT aux_cdcooper,
                           INPUT aux_cdagenci,
                           INPUT aux_nrdcaixa,
                           INPUT aux_cdoperad,
                           INPUT aux_nmdatela,
                           INPUT aux_idorigem,
                           INPUT aux_dtmvtolt,
                           INPUT aux_flgerlog,
                           INPUT aux_dstextab,
                           INPUT aux_cdcopalt,
                           INPUT aux_dsdepart,
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

/* ------------------------------------------------------------------------- */
/*    RETORNA AS VARIAVEIS PARA PREENCHIMENTO DO COMBO DE COOPERATIVAS       */
/* ------------------------------------------------------------------------- */
PROCEDURE Busca_Cooperativas:

    RUN Busca_Cooperativas IN hBO ( INPUT aux_cdcooper,
                                   OUTPUT aux_nmcooper).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                  CREATE tt-erro.
                  ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                            "validacao de dados.".
               END.

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
           RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "nmcooper", INPUT aux_nmcooper).
           RUN piXmlSave.
        END.


END PROCEDURE. /* Busca_Cooperativas */
