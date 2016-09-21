/*..............................................................................

   Programa: xb1wgen0005.p
   Autor   : Murilo/David
   Data    : Junho/2007                       Ultima atualizacao: 04/11/2009

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO de Consulta do Saldo para Resgate da
               Aplicacao (b1wgen0005.p)

   Alteracoes: 04/11/2009 - Ajustes na procedure saldo-rdca-resgate (David).

..............................................................................*/


DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_nraplica AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdmeses AS INTE                                           NO-UNDO.
DEF VAR aux_nrdedias AS INTE                                           NO-UNDO.

DEF VAR aux_vlsldapl AS DECI                                           NO-UNDO.
DEF VAR aux_vlrenper AS DECI                                           NO-UNDO.
DEF VAR aux_sldpresg AS DECI                                           NO-UNDO.
DEF VAR aux_vlrenacu AS DECI DECIMALS 8                                NO-UNDO.
DEF VAR aux_vlslajir AS DECI DECIMALS 8                                NO-UNDO.
DEF VAR aux_pcajsren AS DECI                                           NO-UNDO.
DEF VAR aux_perirapl AS DECI                                           NO-UNDO.
DEF VAR aux_vlrenreg AS DECI DECIMALS 8                                NO-UNDO.
DEF VAR aux_vldajtir AS DECI DECIMALS 8                                NO-UNDO. 
DEF VAR aux_sldrgttt AS DECI DECIMALS 8                                NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_cdprogra AS CHAR                                           NO-UNDO.

DEF VAR aux_dtiniapl AS DATE                                           NO-UNDO.
DEF VAR aux_dtresgat AS DATE                                           NO-UNDO.

DEF VAR aux_cdhisren LIKE craplap.cdhistor                             NO-UNDO.
DEF VAR aux_cdhisajt LIKE craplap.cdhistor                             NO-UNDO.


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
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nraplica" THEN aux_nraplica = INTE(tt-param.valorCampo).
            WHEN "vlsldapl" THEN aux_vlsldapl = DECI(tt-param.valorCampo).
            WHEN "vlrenper" THEN aux_vlrenper = DECI(tt-param.valorCampo).
            WHEN "sldpresg" THEN aux_sldpresg = DECI(tt-param.valorCampo).
            WHEN "cdprogra" THEN aux_cdprogra = tt-param.valorCampo.
            WHEN "dtresgat" THEN aux_dtresgat = DATE(tt-param.valorCampo).
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.


/******************************************************************************/
/**          Procedure para consultar saldo da poupanca programada           **/
/******************************************************************************/
PROCEDURE saldo-rdca-resgate:

    RUN saldo-rdca-resgate IN hBO (INPUT aux_cdcooper,       
                                   INPUT aux_cdagenci,       
                                   INPUT aux_nrdcaixa,       
                                   INPUT aux_cdoperad,       
                                   INPUT aux_idorigem,       
                                   INPUT aux_cdprogra,       
                                   INPUT aux_nrdconta,       
                                   INPUT aux_dtresgat,       
                                   INPUT aux_nraplica,       
                                   INPUT aux_vlsldapl,       
                                   INPUT aux_vlrenper,       
                                  OUTPUT aux_pcajsren,       
                                  OUTPUT aux_vlrenreg, 
                                  OUTPUT aux_vldajtir, 
                                  OUTPUT aux_sldrgttt, 
                                  OUTPUT aux_vlslajir, 
                                  OUTPUT aux_vlrenacu, 
                                  OUTPUT aux_nrdmeses,       
                                  OUTPUT aux_nrdedias,       
                                  OUTPUT aux_dtiniapl,       
                                  OUTPUT aux_cdhisren,       
                                  OUTPUT aux_cdhisajt,       
                                  OUTPUT aux_perirapl,
                                  INPUT-OUTPUT aux_sldpresg, 
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
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "sldpresg", INPUT aux_sldpresg).
            RUN piXmlAtributo (INPUT "pcajsren", INPUT aux_pcajsren).       
            RUN piXmlAtributo (INPUT "vlrenreg", INPUT aux_vlrenreg). 
            RUN piXmlAtributo (INPUT "vldajtir", INPUT aux_vldajtir). 
            RUN piXmlAtributo (INPUT "sldrgttt", INPUT aux_sldrgttt). 
            RUN piXmlAtributo (INPUT "vlslajir", INPUT aux_vlslajir). 
            RUN piXmlAtributo (INPUT "vlrenacu", INPUT aux_vlrenacu). 
            RUN piXmlAtributo (INPUT "nrdmeses", INPUT aux_nrdmeses).       
            RUN piXmlAtributo (INPUT "nrdedias", INPUT aux_nrdedias).       
            RUN piXmlAtributo (INPUT "dtiniapl", INPUT aux_dtiniapl).       
            RUN piXmlAtributo (INPUT "cdhisren", INPUT aux_cdhisren).       
            RUN piXmlAtributo (INPUT "cdhisajt", INPUT aux_cdhisajt).       
            RUN piXmlAtributo (INPUT "perirapl", INPUT aux_perirapl).
            RUN piXmlSave.
        END.

END PROCEDURE.


/*............................................................................*/
