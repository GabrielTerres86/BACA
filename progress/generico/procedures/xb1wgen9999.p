/*.............................................................................

   Programa: xb1wgen9999.p
   Autor   : Andre Euzébio - SUPERO
   Data    : Agosto/2013                     Ultima atualizacao:  /  /

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao referente a tela LISTAL.

   Alteracoes: 
   
............................................................................ */

DEF VAR aux_cdcooper LIKE crapcop.cdcooper                             NO-UNDO.
DEF VAR par_cdcooper LIKE crapcop.cdcooper                             NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.


DEF VAR aux_cddopcao AS CHAR FORMAT "X(1)"                             NO-UNDO.
DEF VAR aux_cdcoptel AS INT                                            NO-UNDO.
DEF VAR aux_insitreq AS INT                                            NO-UNDO.
DEF VAR aux_tprequis AS INT                                            NO-UNDO.
DEF VAR aux_dtinicio AS DATE                                           NO-UNDO.
DEF VAR aux_dttermin AS DATE                                           NO-UNDO.

DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR aux_flgexist AS LOG                                            NO-UNDO.


{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgen9999tt.i }

                                       
/*................................ PROCEDURES ................................*/

/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/
PROCEDURE valores_entrada:
    
    FOR EACH tt-param:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = STRING(tt-param.valorCampo).
            WHEN "cdcoptel" THEN aux_cdcoptel = INTE(tt-param.valorCampo).
            WHEN "insitreq" THEN aux_insitreq = INTE(tt-param.valorCampo).
            WHEN "tprequis" THEN aux_tprequis = INTE(tt-param.valorCampo).
            WHEN "dtinicio" THEN aux_dtinicio = DATE(tt-param.valorCampo).
            WHEN "dttermin" THEN aux_dttermin = DATE(tt-param.valorCampo).

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.

/******************************************************************************/

/********* LISTA COOPERATIVAS *********/
PROCEDURE consulta-cooperativas:

    RUN consulta-cooperativas IN hBO(
                                OUTPUT TABLE tt-cooper,
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

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlSave.

        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-cooper:HANDLE,
                             INPUT "CRAPCOP").
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************/

PROCEDURE listal-consulta-cheques:

    RUN listal-consulta-cheques IN hBO
                        ( INPUT aux_cdcooper,
                          INPUT aux_cdcoptel,
                          INPUT aux_insitreq,
                          INPUT aux_tprequis,
                          INPUT aux_cddopcao,
                          INPUT aux_dtinicio,
                          INPUT aux_dttermin,
                          OUTPUT TABLE tt-erro,
                          OUTPUT TABLE tt-listal).

    FIND FIRST tt-listal NO-LOCK NO-ERROR.
    FIND FIRST tt-erro NO-LOCK NO-ERROR.

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
    ELSE DO:

        IF  aux_cddopcao = "T" THEN DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-listal:HANDLE,
                             INPUT "ListaCheques").
            RUN piXmlSave.
        END.
        ELSE DO:

            RUN listal-gera-relatorio IN hBO
                        ( INPUT aux_cdcooper,
                          INPUT aux_cdcoptel,
                          INPUT aux_insitreq,
                          INPUT aux_tprequis,
                          INPUT aux_dtinicio,
                          INPUT aux_dttermin,
                          INPUT aux_idorigem ,
                          INPUT TABLE tt-listal,
                         OUTPUT aux_nmarqimp,
                         OUTPUT aux_nmarqpdf).

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
            ELSE DO:
                RUN piXmlNew.
                RUN piXmlAtributo (INPUT "nmarqimp",INPUT STRING(aux_nmarqimp)).
                RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
                RUN piXmlSave.
            END.
        END.
    END.

END PROCEDURE.

/******************************************************************************/

