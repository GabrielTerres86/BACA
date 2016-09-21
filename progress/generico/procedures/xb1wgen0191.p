/*...........................................................................

   Programa: xb1wgen0191.p
   Autor   : Jonata (RKAM)
   Data    : Setembro/2014                      Ultima atualizacao: 06/05/2015

   Dados referentes ao programa:

   Objetivo  : BO Do Projeto Automatização de Consultas em Propostas
               de Crédito/Limtes (Jonata-RKAM).
   
   Alteracoes : 06/05/2015 - Ajuste para o limite de credito (Gabriel-RKAM).
   
...........................................................................*/

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_inprodut AS INTE                                           NO-UNDO.
DEF VAR aux_nrctrato AS INTE                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0191tt.i }
{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i }

/**************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML **/
/**************************************************************************/
PROCEDURE valores_entrada:

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:

            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "inprodut" THEN aux_inprodut = INTE(tt-param.valorCampo).
            WHEN "nrctrato" THEN aux_nrctrato = INTE(tt-param.valorCampo).             

        END CASE.

    END. /* tt-param */

END.

PROCEDURE Imprime_Consulta:

    RUN Imprime_Consulta IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_nrdconta,
                                 INPUT aux_inprodut,
                                 INPUT aux_nrctrato,
                                 INPUT 5,
                                 INPUT "T",
                                OUTPUT aux_nmarqimp,
                                OUTPUT aux_nmarqpdf,
                                OUTPUT TABLE tt-erro).
                               
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
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
            RUN piXmlSave.
        END.

END.

PROCEDURE efetua_analise_ctr.

    RUN efetua_analise_ctr IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_nrdconta,
                                   INPUT aux_nrctrato,
                                  OUTPUT aux_cdcritic,
                                  OUTPUT aux_dscritic).
                               
    IF  RETURN-VALUE <> "OK" THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = aux_dscritic.
    
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlSave.

        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.


/* ......................................................................... */
