/*..............................................................................
   
   Programa: sistema/generico/procedures/xb1wgen0192.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Andre Santos - SUPERO
   Data    : Agosto/2014                       Ultima atualizacao:  /  /
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Chamada de BO b1wgen0192 - Procedures referente ao
               Pagamento de Titulos por Arq (WEB)
      
   Alteracoes:
..............................................................................*/

DEF VAR aux_cdcooper AS INTE                                          NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                          NO-UNDO.
DEF VAR aux_flconven AS INTE                                          NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                          NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                          NO-UNDO.
DEF VAR aux_xmltermo AS CHAR                                          NO-UNDO.
DEF VAR aux_tpdtermo AS INTE                                          NO-UNDO.
DEF VAR aux_nrconven AS INTE                                          NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                          NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0192tt.i }
{ sistema/generico/includes/supermetodos.i }

/*............................... PROCEDURES ...............................*/

PROCEDURE valores_entrada:

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:

            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "tpdtermo" THEN aux_tpdtermo = INTE(tt-param.valorCampo).
            WHEN "nrconven" THEN aux_nrconven = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
                

       END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.


PROCEDURE verif-aceite-conven:

    RUN verif-aceite-conven IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_nrdconta,
                                    INPUT 1, /* par_nrconven - FIXO */
                                    OUTPUT aux_flconven,
                                    OUTPUT aux_cdcritic,
                                    OUTPUT aux_dscritic,
                                    OUTPUT TABLE tt-arquivos).

    IF  RETURN-VALUE = "NOK"  THEN DO:

        IF  aux_dscritic = "" THEN DO:

            FIND FIRST crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                NO-LOCK NO-ERROR.

            IF  AVAIL crapcri THEN DO:
                CREATE tt-erro.
                ASSIGN tt-erro.dscritic = crapcri.dscritic.
            END.
            ELSE DO:
               CREATE tt-erro.
               ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                         "operacao.".
            END.
        END.
        ELSE DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = aux_dscritic.
        END.

        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                        INPUT "Erro").

    END.
    ELSE DO:
        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-arquivos:HANDLE,
                         INPUT "Arquivos").
        RUN piXmlAtributo (INPUT "flconven",INPUT STRING(aux_flconven)).
        RUN piXmlAtributo (INPUT "dscritic",INPUT STRING(aux_dscritic)).
        RUN piXmlSave.  
    END.

END PROCEDURE.


PROCEDURE efetua-aceite-cancel:

    RUN efetua-aceite-cancel IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_nrdconta,
                                     INPUT aux_nrconven,
                                     INPUT aux_tpdtermo, /* 0 - Exclusao / 1 - Adesao */
                                     INPUT aux_dtmvtolt,
                                     INPUT aux_cdoperad,
                                     OUTPUT aux_cdcritic,
                                     OUTPUT aux_dscritic).

    IF  RETURN-VALUE = "NOK"  THEN DO:

        IF  aux_dscritic = "" THEN DO:

            FIND FIRST crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                NO-LOCK NO-ERROR.

            IF  AVAIL crapcri THEN DO:
                CREATE tt-erro.
                ASSIGN tt-erro.dscritic = crapcri.dscritic.
            END.
            ELSE DO:
               CREATE tt-erro.
               ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                         "operacao.".
            END.
        END.

        CREATE tt-erro.
            ASSIGN tt-erro.dscritic = aux_dscritic.

        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").

    END.
    ELSE DO:
        RUN piXmlNew.
        RUN piXmlAtributo (INPUT "retorno",INPUT STRING("OK")).
        RUN piXmlSave.
    END.

END PROCEDURE.


PROCEDURE busca-termo-servico:

    RUN busca-termo-servico IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_nrdconta,
                                    INPUT aux_nrconven,
                                    INPUT aux_tpdtermo, /* 0 - Exclusao / 1 - Adesao */
                                    INPUT aux_dtmvtolt,
                                    INPUT aux_cdoperad,
                                    OUTPUT aux_dscritic,
                                    OUTPUT aux_xmltermo).

    IF  RETURN-VALUE = "NOK"  THEN DO:

        IF  aux_dscritic = "" THEN DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = aux_dscritic.
        END.
        ELSE DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                      "operacao.".
        END.

        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").

    END.
    ELSE DO:
        RUN piXmlNew.
        RUN piXmlAtributo (INPUT "xmltermo",INPUT STRING(aux_xmltermo)).
        RUN piXmlSave.
    END.

END PROCEDURE.
