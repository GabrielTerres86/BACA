/*..............................................................................
   
   Programa: sistema/generico/procedures/xb1wgen0193.p
   Autor   : James Prust Junior
   Data    : Janeiro/2015                       Ultima atualizacao: 05/01/2016
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Procedures referente a tela Contas - Liberar/Bloquear
      
   Alteracoes: 05/01/2016 - Adequado chamadas para o b1wgen0193 considerando o
                            campo flgcrdpa (Anderson).
..............................................................................*/

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_flgrenli AS LOG                                            NO-UNDO.
DEF VAR aux_flgcrdpa AS LOGICAL                                        NO-UNDO.
DEF VAR aux_libcrdpa AS LOGICAL                                        NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-WEB=SIM }

/*................................ PROCEDURES ...............................*/
PROCEDURE valores_entrada:

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "flgrenli" THEN aux_flgrenli = LOGICAL(tt-param.valorCampo).
            WHEN "flgcrdpa" THEN aux_flgcrdpa = LOGICAL(tt-param.valorCampo).
       END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.

PROCEDURE busca_dados:

    RUN busca_dados IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrdconta,
                            INPUT aux_dtmvtolt,
                            INPUT aux_idseqttl,
                            OUTPUT aux_flgrenli,
                            OUTPUT aux_flgcrdpa,
                            OUTPUT aux_libcrdpa,
                            OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK"  THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.
           IF NOT AVAILABLE tt-erro THEN
              DO:
                  CREATE tt-erro.
                  ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                            "busca de dados.".
              END.

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
       END.
    ELSE
       DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "flgrenli", INPUT STRING(aux_flgrenli)).
           RUN piXmlAtributo (INPUT "flgcrdpa", INPUT STRING(aux_flgcrdpa)).
           RUN piXmlAtributo (INPUT "libcrdpa", INPUT STRING(aux_libcrdpa)).
           RUN piXmlSave.
       END.

END PROCEDURE.

PROCEDURE grava_dados:
    
    RUN grava_dados IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrdconta,
                            INPUT aux_dtmvtolt,
                            INPUT aux_idseqttl,
                            INPUT aux_flgrenli,
                            INPUT aux_flgcrdpa,
                            INPUT TRUE,  /* par_flgerlog */
                            OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK"  THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.
           IF NOT AVAILABLE tt-erro THEN
              DO:
                  CREATE tt-erro.
                  ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                            "gravacao de dados.".
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
/*............................................................................*/
