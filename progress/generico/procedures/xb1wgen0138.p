
/*..............................................................................

   Programa: xb1wgen0138.p
   Autor   : Adriano
   Data    : Outubro/2012                     Ultima atualizacao: 

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO - Grupo Economico (b1wgen0138.p)

   Alteracoes: 
                           
..............................................................................*/

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdgrupo AS INT                                            NO-UNDO.
DEF VAR aux_gergrupo AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdrisgp AS CHAR                                           NO-UNDO.
DEF VAR aux_tpdecons AS LOG                                            NO-UNDO.
DEF VAR aux_dsdrisco AS CHAR                                           NO-UNDO.
DEF VAR aux_vlendivi AS DEC                                            NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                           NO-UNDO.
DEF VAR aux_infoagen AS LOGICAL                                        NO-UNDO.
DEF VAR aux_cdrelato AS INTE                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0138tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }


/*................................ PROCEDURES ................................*/


/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/
PROCEDURE valores_entrada:    

    FOR EACH tt-param:
        
        CASE tt-param.nomeCampo:

            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "tpdecons" THEN aux_tpdecons = LOGICAL(tt-param.valorCampo).
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "nrdgrupo" THEN aux_nrdgrupo = INT(tt-param.valorCampo).
            WHEN "infoagen" THEN aux_infoagen = LOGICAL(tt-param.valorCampo).

        END CASE.
    
    END. /** Fim do FOR EACH tt-param **/    
    
END PROCEDURE.


/*  Retorna se a conta em questao pertence a algum grupo e o valor do grupo  */
PROCEDURE busca_grupo:

   RUN piXmlNew.
   RUN piXmlAtributo (INPUT "pertgrup", INPUT (DYNAMIC-FUNCTION("busca_grupo" IN hBO, 
                                  INPUT aux_cdcooper,
                                  INPUT aux_nrdconta,
                                  OUTPUT aux_nrdgrupo,
                                  OUTPUT aux_gergrupo,
                                  OUTPUT aux_dsdrisgp))).
   RUN piXmlAtributo (INPUT "nrdgrupo", INPUT aux_nrdgrupo).
   RUN piXmlAtributo (INPUT "gergrupo", INPUT aux_gergrupo).
   RUN piXmlAtributo (INPUT "dsdrisgp", INPUT aux_dsdrisgp).
   RUN piXmlSave.
   

END PROCEDURE.


/*   Realiza o calculo do endividamento e risco do grupo    */
PROCEDURE calc_endivid_grupo:

    RUN calc_endivid_grupo IN hBO(INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_nrdgrupo,
                                  INPUT aux_tpdecons,
                                  OUTPUT aux_dsdrisco,
                                  OUTPUT aux_vlendivi,
                                  OUTPUT TABLE tt-grupo,
                                  OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                  CREATE tt-erro.
                  ASSIGN tt-erro.dscritic = "Nao possivel calcular o " + 
                                            "endividamento do grupo.".
               END.
    
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
           RUN piXmlSave.
    
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "dsdrisco", INPUT aux_dsdrisco).
           RUN piXmlAtributo (INPUT "vlendivi", INPUT aux_vlendivi).
           RUN piXmlExport   (INPUT TEMP-TABLE tt-grupo:HANDLE,INPUT "GE").
           RUN piXmlSave.

        END.

END PROCEDURE.



/*   Realiza o calculo do endividamento e risco do grupo    */
PROCEDURE relatorio_gp:

    RUN relatorio_gp IN hBO(INPUT  aux_cdcooper,
                            INPUT  aux_cdagenci,
                            INPUT  aux_nrdcaixa,
                            INPUT  aux_cdoperad,
                            INPUT  aux_nmdatela,
                            INPUT  aux_idorigem,
                            INPUT  aux_dtmvtolt,
                            INPUT  aux_nmendter,
                            INPUT  aux_cdrelato,
                            INPUT  aux_nrdgrupo,
                            INPUT  aux_infoagen,

                            OUTPUT aux_nmarqimp,
                            OUTPUT aux_dsdrisgp, 
                            OUTPUT aux_vlendivi,
                            OUTPUT TABLE tt-grupo,
                            OUTPUT TABLE tt-erro).

   
    IF  RETURN-VALUE <> "OK" THEN
        DO:

           FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                  CREATE tt-erro.
                  ASSIGN tt-erro.dscritic = "Nao foi possivel calcular " + 
                                            "o endividamento do grupo.".
               END.
    
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
           RUN piXmlSave.
    
        END.
    ELSE
        DO:

           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqimp).
           RUN piXmlExport   (INPUT TEMP-TABLE tt-grupo:HANDLE,INPUT "GE").
           RUN piXmlSave.

        END.

END PROCEDURE.

  
/* ......................................................................... */

