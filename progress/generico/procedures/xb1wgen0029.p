/*.............................................................................

   Programa: xb1wgen0029.p
   Autor   : Guilherme
   Data    : Julho/2008                     Ultima atualizacao:   /  /

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO de Ajuda F2 (b1wgen0029.p)

   Alteracoes: 

............................................................................ */


DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nmrotina AS CHAR                                           NO-UNDO.
DEF VAR aux_inrotina AS INTE                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0029tt.i }
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
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "nmrotina" THEN aux_nmrotina = tt-param.valorCampo.
            WHEN "inrotina" THEN aux_inrotina = INTE(tt-param.valorCampo).
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.


/******************************************************************************/
/**               Procedure para listar o help da tela                       **/
/******************************************************************************/
PROCEDURE busca_help:

    RUN busca_help IN hBO (INPUT aux_cdcooper,
                           INPUT aux_cdagenci,
                           INPUT aux_nrdcaixa,
                           INPUT aux_cdoperad,
                           INPUT aux_dtmvtolt,
                           INPUT aux_idorigem,
                           INPUT aux_nmdatela,
                           INPUT aux_nmrotina,
                           INPUT aux_inrotina,
                          OUTPUT TABLE tt-erro,
                          OUTPUT TABLE tt-f2).


    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        RUN piXmlSaida (INPUT TEMP-TABLE tt-f2:HANDLE,
                        INPUT "F2_Ajuda").
    

END PROCEDURE.

