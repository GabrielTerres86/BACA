/*.............................................................................

   Programa: xb1wgen0139.p
   Autor   : Tiago
   Data    : Julho/2012                      Ultima atualizacao: 02/10/2012

   Dados referentes ao programa:

   Objetivo  : BO ref. a tab094. (b1wgen0139.p)

   Alteracoes: 02/02/2012 - Corrigdo a passagem dos parametros na procedure
                            busca_dados, grava_dados (Adriano).
                            
               06/12/2016 - P341-Automatização BACENJUD - Alterar a passagem 
			                da descrição do departamento como parametro e 
							passar o código (Renato Darosci)
............................................................................ */

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdcoopex AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nmrotina AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.

DEF VAR aux_mrgsrdoc AS DECI                                           NO-UNDO.
DEF VAR aux_mrgsrchq AS DECI                                           NO-UNDO.
DEF VAR aux_mrgnrtit AS DECI                                           NO-UNDO.
DEF VAR aux_mrgsrtit AS DECI                                           NO-UNDO.
DEF VAR aux_caldevch AS DECI                                           NO-UNDO.
DEF VAR aux_mrgitgcr AS DECI                                           NO-UNDO.
DEF VAR aux_mrgitgdb AS DECI                                           NO-UNDO.
DEF VAR aux_horabloq AS CHAR                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_cddepart AS INTE                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0139tt.i }
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
            WHEN "cdcoopex" THEN aux_cdcoopex = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "nmrotina" THEN aux_nmrotina = tt-param.valorCampo.
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "mrgsrdoc" THEN aux_mrgsrdoc = DECI(tt-param.valorCampo).
            WHEN "mrgsrchq" THEN aux_mrgsrchq = DECI(tt-param.valorCampo).
            WHEN "mrgnrtit" THEN aux_mrgnrtit = DECI(tt-param.valorCampo).
            WHEN "mrgsrtit" THEN aux_mrgsrtit = DECI(tt-param.valorCampo).
            WHEN "caldevch" THEN aux_caldevch = DECI(tt-param.valorCampo).
            WHEN "mrgitgcr" THEN aux_mrgitgcr = DECI(tt-param.valorCampo).
            WHEN "mrgitgdb" THEN aux_mrgitgdb = DECI(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "horabloq" THEN aux_horabloq = tt-param.valorCampo.
            WHEN "cddepart" THEN aux_cddepart = INTE(tt-param.valorCampo).
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.

PROCEDURE busca_dados:

    RUN busca_dados IN hBO(INPUT  aux_cdcooper,
                           INPUT  aux_cdagenci,
                           INPUT  aux_nrdcaixa,
                           INPUT  aux_cdoperad,
                           INPUT  aux_cdcoopex,
                           OUTPUT TABLE tt-fluxo-fin,
                           OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida(INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport(INPUT TEMP-TABLE tt-fluxo-fin:HANDLE,
                            INPUT "Dados").
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE grava_dados:

    RUN grava_dados IN hBO(INPUT  aux_cdcooper,
                           INPUT  aux_cdagenci,
                           INPUT  aux_nrdcaixa,
                           INPUT  aux_cdoperad,
                           INPUT  aux_nmdatela,
                           INPUT  aux_cddepart,
                           INPUT  aux_idorigem,
                           INPUT  aux_dtmvtolt,
                           INPUT  aux_mrgsrdoc,
                           INPUT  aux_mrgsrchq,
                           INPUT  aux_mrgnrtit,
                           INPUT  aux_mrgsrtit,
                           INPUT  aux_caldevch,
                           INPUT  aux_mrgitgcr,
                           INPUT  aux_mrgitgdb,
                           INPUT  aux_horabloq,
                           INPUT  aux_cdcoopex,
                           OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida(INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE acesso_opcao:


    RUN acesso_opcao IN hBO(INPUT  aux_cdcooper,
                            INPUT  aux_cdagenci,
                            INPUT  aux_cddepart,
                            INPUT  aux_cddopcao,
                            OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida(INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.
