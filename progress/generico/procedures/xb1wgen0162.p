/*.............................................................................

   Programa: xb1wgen0162.p
   Autor   : Lucas R.
   Data    : Julho/2013                      Ultima atualizacao: //

   Dados referentes ao programa:

   Objetivo  : BO DE PROCEDURES REF. OPERACOES COM ATENDA/CONSORCIOS.
   
   Alteracoes :
   
.............................................................................*/

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_flgativo AS LOG                                            NO-UNDO.

{ sistema/generico/includes/b1wgen0162tt.i }
{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i }

/*****************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML    **/
/*****************************************************************************/
PROCEDURE valores_entrada:

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:

            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "flgativo" THEN aux_flgativo = LOGICAL(tt-param.valorCampo).

        END CASE.
    END. /* tt-param */

END.

PROCEDURE lista_consorcio:
    
    RUN lista_consorcio IN hBO (INPUT aux_cdcooper,
                                INPUT aux_cdoperad,
                                INPUT aux_idorigem,
                                INPUT aux_nrdconta,
                               OUTPUT TABLE tt-consorcios).
                               
    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel consultar os " +
                                              "registros.".
                END.
    
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlSave.

        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-consorcios:HANDLE, 
                             INPUT "DADOS").
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE indicativo_consorcio:

    RUN indicativo_consorcio IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_nrdconta,
                                    OUTPUT aux_flgativo).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel consultar os " +
                                              "registros.".
                END.
    
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "flgativo", INPUT LOGICAL(aux_flgativo)).
            RUN piXmlSave.
        END.
                                                                        
END PROCEDURE.
