/*.............................................................................

   Programa: xb1wgen0040.p
   Autor   : André (DB1)
   Data    : Maio/2011                     Ultima atualizacao: 01/06/2018

   Dados referentes ao programa:

   Objetivo  : BO ref. a Custodia e Consulta de Cheques. (b1wgen0040.p)

   Alteracoes:  20/07/2012 - Tratamento para a tela IMGCHQ (Fabricio/Ze).
   
                20/08/2012 - Incluir parametro no consulta-cheque-compensado 
                             - Tipo de Documento (Ze).

			    18/03/2016 - Proj 316 - Passar novo cdcooper (Tela) para 
				             consultar o cheque (Guilherme/SUPERO)

				19/10/2017 - Ajuste para remover a chamada da rotina busca-cheques,
				             pois a mesma foi convertida para oracle
							 (Adriano - SD 774552).
               
               01/06/2018 - Ajuste no retorno da PROC consulta-cheque-compensado
                             para retornar o INBLQVIC. PRJ 372 - (Mateus Z / Mouts)
				          
............................................................................ */

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdcopchq AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nmrotina AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_dsmsgcnt AS CHAR                                           NO-UNDO.

DEF VAR aux_nrtipoop AS INTE                                           NO-UNDO.
DEF VAR aux_nrcheque AS INTE                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_qtrequis AS INTE                                           NO-UNDO.
DEF VAR aux_dsmensag AS CHAR                                           NO-UNDO.
DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.

DEF VAR aux_dtcompen AS DATE                                           NO-UNDO.
DEF VAR aux_cdcmpchq AS INTE                                           NO-UNDO.
DEF VAR aux_cdbanchq AS INTE                                           NO-UNDO.
DEF VAR aux_cdagechq AS INTE                                           NO-UNDO.
DEF VAR aux_nrctachq AS DECI                                           NO-UNDO.
DEF VAR aux_tpremess AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdocmc7 AS CHAR                                           NO-UNDO.
DEF VAR aux_nmrescop AS CHAR                                           NO-UNDO.
DEF VAR aux_cdtpddoc AS INTE                                           NO-UNDO.
/* PRJ 372 */
DEF VAR aux_indblqvic AS CHAR                                           NO-UNDO.

DEF VAR aux_dttransa AS DATE                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_cdprogra AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0040tt.i }
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
			WHEN "cdcopchq" THEN aux_cdcopchq = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "nmrotina" THEN aux_nmrotina = tt-param.valorCampo.
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "nrtipoop" THEN aux_nrtipoop = INTE(tt-param.valorCampo).
            WHEN "nrcheque" THEN aux_nrcheque = INTE(tt-param.valorCampo).
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "dtcompen" THEN aux_dtcompen = DATE(tt-param.valorCampo).
            WHEN "cdcmpchq" THEN aux_cdcmpchq = INTE(tt-param.valorCampo).
            WHEN "cdbanchq" THEN aux_cdbanchq = INTE(tt-param.valorCampo).
            WHEN "cdagechq" THEN aux_cdagechq = INTE(tt-param.valorCampo).
            WHEN "nrctachq" THEN aux_nrctachq = DEC(tt-param.valorCampo).
            WHEN "tpremess" THEN aux_tpremess = tt-param.valorCampo.
            WHEN "dttransa" THEN aux_dttransa = DATE(tt-param.valorCampo).
            WHEN "dstransa" THEN aux_dstransa = tt-param.valorCampo.
            WHEN "cdprogra" THEN aux_cdprogra = tt-param.valorCampo.
        END CASE.
        
    END. /** Fim do FOR EACH tt-param **/
    
END PROCEDURE.


/*****************************************************************************/
/*                         Verifica Conta para buscar cheques                */
/*****************************************************************************/
PROCEDURE verifica-conta:

    RUN verifica-conta IN hBO ( INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT aux_nrdconta,
                                INPUT aux_idseqttl,
                                INPUT TRUE, /* LOG */
                               OUTPUT aux_nmprimtl,
                               OUTPUT aux_qtrequis,
                               OUTPUT aux_dsmsgcnt,
                               OUTPUT TABLE tt-erro ).
    
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
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmprimtl",INPUT STRING(aux_nmprimtl)).
            RUN piXmlAtributo (INPUT "qtrequis",INPUT STRING(aux_qtrequis)).
            RUN piXmlAtributo (INPUT "dsmsgcnt",INPUT STRING(aux_dsmsgcnt)).
            RUN piXmlSave.
        END.

        
END PROCEDURE.

PROCEDURE consulta-cheque-compensado:

    RUN consulta-cheque-compensado IN hBO (INPUT aux_cdcopchq, /*aux_cdcooper*/
                                           INPUT aux_cdagenci,
                                           INPUT aux_nrdcaixa,
                                           INPUT aux_dtcompen,
                                           INPUT-OUTPUT aux_cdcmpchq,
                                           INPUT aux_cdbanchq,
                                           INPUT-OUTPUT aux_cdagechq,
                                           INPUT aux_nrctachq,
                                           INPUT aux_nrcheque,
                                           INPUT aux_tpremess,
                                          OUTPUT aux_dsdocmc7,
                                          OUTPUT aux_nmrescop,
                                          OUTPUT aux_cdtpddoc,
                                          /* PRJ 372 */
                                          OUTPUT aux_indblqvic,
                                          OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel consultar o " +
                                              "cheque.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
    DO:
        RUN piXmlNew.
        RUN piXmlAtributo (INPUT "cdcmpchq", INPUT STRING(aux_cdcmpchq)).
        RUN piXmlAtributo (INPUT "cdagechq", INPUT STRING(aux_cdagechq)).
        RUN piXmlAtributo (INPUT "dsdocmc7", INPUT STRING(aux_dsdocmc7)).
        RUN piXmlAtributo (INPUT "nmrescop", INPUT STRING(aux_nmrescop)).
        RUN piXmlAtributo (INPUT "cdtpddoc", INPUT STRING(aux_cdtpddoc)).
        /* PRJ 372 */
        RUN piXmlAtributo (INPUT "indblqvic", INPUT STRING(aux_indblqvic)).
        RUN piXmlSave.
    END.


END PROCEDURE.

PROCEDURE grava-log:

    RUN grava-log IN hBO (INPUT aux_cdcooper,
                          INPUT aux_dttransa,
                          INPUT aux_cdoperad,
                          INPUT aux_dstransa,
                          INPUT aux_nrdconta,
                          INPUT aux_cdprogra).

    RUN piXmlNew.
    RUN piXmlSave.


END PROCEDURE.
