/*.............................................................................

   Programa: xb1wgen0129.p
   Autor   : Lucas
   Data    : Nov/2011                       Ultima atualizacao: 22/04/2013

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO129 (b1wgen0129.p) [TAB030]

   Alteracoes: 24/05/2012 - Inlcluido parametro "aux_diasatrs
                            (dias atraso para relatorio)" (Tiago).
                            
               22/04/2013 - Ajuste para a inclusao do parametro "Dias atraso
                            para inadimplencia" ( Adriano ).            
                            
.............................................................................*/

DEF VAR aux_cdcooper AS INTE                                       NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                       NO-UNDO.             
DEF VAR aux_nrdcaixa AS INTE                                       NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                       NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                       NO-UNDO.
DEF VAR aux_idorigem AS INTE                                       NO-UNDO.
DEF VAR aux_flgerlog AS LOGI                                       NO-UNDO.
DEF VAR aux_dstextab AS CHAR                                       NO-UNDO.
DEF VAR aux_dsdepart AS CHAR                                       NO-UNDO.
 
DEF VAR aux_vllimite AS DEC                                        NO-UNDO.
DEF VAR aux_vlsalmin AS DEC                                        NO-UNDO.
DEF VAR aux_diasatrs AS INT                                        NO-UNDO.
DEF VAR aux_atrsinad AS INT                                        NO-UNDO.


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

            WHEN "vllimite" THEN aux_vllimite = DEC(tt-param.valorCampo).
            WHEN "vlsalmin" THEN aux_vlsalmin = DEC(tt-param.valorCampo).
            WHEN "diasatrs" THEN aux_diasatrs = INT(tt-param.valorCampo).
            WHEN "atrsinad" THEN aux_atrsinad = INT(tt-param.valorCampo).

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.


/*****************************************************************************
  Carregar os dados gravados na TAB030
******************************************************************************/

PROCEDURE busca_tab030:

        RUN busca_tab030 IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 OUTPUT aux_vllimite,
                                 OUTPUT aux_vlsalmin,
                                 OUTPUT aux_diasatrs,
                                 OUTPUT aux_atrsinad,
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
               RUN piXmlAtributo (INPUT "vllimite", INPUT STRING(aux_vllimite,"zzzzz9.99")).
               RUN piXmlAtributo (INPUT "vlsalmin", INPUT STRING(aux_vlsalmin,"zzzz,zz9.99")).
               RUN piXmlAtributo (INPUT "diasatrs", INPUT STRING(aux_diasatrs,"zz9")).
               RUN piXmlAtributo (INPUT "atrsinad", INPUT STRING(aux_atrsinad,"zzz9")).
               RUN piXmlSave.
            END.

END PROCEDURE.

 /*****************************************************************************
  Alterar os dados gravados na TAB030
******************************************************************************/

PROCEDURE altera_tab030:

    RUN altera_tab030 IN hBO (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_dtmvtolt,
                              INPUT TRUE,
                              INPUT aux_dstextab,
                              INPUT aux_dsdepart,
                              INPUT aux_vllimite,
                              INPUT aux_vlsalmin,
                              INPUT aux_diasatrs,
                              INPUT aux_atrsinad,
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

