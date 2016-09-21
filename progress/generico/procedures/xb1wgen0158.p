
/*..............................................................................

   Programa: xb1wgen0158.p
   Autor   : Jorge I. Hamaguchi
   Data    : Julho/2013                 Ultima atualizacao:

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO158 (b1wgen0158.p) [RELINT]

   Alteracoes: 

..............................................................................*/

DEF VAR aux_cdcooper AS INTE                                       NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                       NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                       NO-UNDO.
DEF VAR aux_idorigem AS INTE                                       NO-UNDO.
DEF VAR aux_cdagetel AS INTE                                       NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                       NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                       NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                       NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                       NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                       NO-UNDO.
DEF VAR aux_nmarqtel AS CHAR                                       NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgen0158tt.i }

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
            WHEN "nmdcampo" THEN aux_nmdcampo = tt-param.valorCampo.
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "cdagetel" THEN aux_cdagetel = INTE(tt-param.valorCampo).
            WHEN "nmarqtel" THEN aux_nmarqtel = tt-param.valorCampo.
               
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.



/*****************************************************************************
  Gerar Relatorio da Internet      
******************************************************************************/
PROCEDURE gerar_relatorio_relint:
    
    RUN gerar_relatorio_relint IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdoperad,
                                       INPUT aux_nmdatela,
                                       INPUT aux_idorigem,
                                       INPUT aux_dtmvtolt,
                                       INPUT aux_cddopcao,
                                       INPUT aux_cdagetel,
                                       INPUT aux_nmarqtel,
                                      OUTPUT aux_nmarquiv,
                                      OUTPUT aux_nmdcampo,
                                      OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE <> "OK"  THEN
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
           RUN piXmlAtributo (INPUT "nmarqpdf",INPUT aux_nmarquiv).
           RUN piXmlAtributo (INPUT "flprocok",INPUT "OK").
           RUN piXmlSave.
        END.

END PROCEDURE.
