/*..............................................................................

   Programa: xb1wgen0101.p
   Autor   : Adriano
   Data    : Agosto/2011                        Ultima atualizacao: 28/07/2015

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO Generica (b1wgen0101.p)

   Alteracoes: 06/08/2012 - Criada a procedure 'lista-historicos'
                          - Adicionado parâmetro do Cod. do Hist para
                            consulta na procedure 'consulta_faturas'
                          - Criada a procedure 'grava-dados-fatura' (Lucas).
                          
               18/04/2013 - Alterações para Conv. SICREDI (Lucas).
               
               16/05/2013 - Alterações para aux_cdoperad INT para CHAR (Oscar).
               
               28/07/2015 - Ajuste na rotina lista-empresas-conv realizar 
                            corretamente a busca de empresas por
                            descricao
                            (Adriano).
               18/01/2018 - Alteraçoes referente ao PJ406.
..............................................................................*/

DEF VAR aux_cdcooper AS INT                                     NO-UNDO.
DEF VAR aux_cdagenci AS INT                                     NO-UNDO.
DEF VAR aux_cdhiscxa AS INT                                     NO-UNDO.
DEF VAR aux_cdagefat AS INT                                     NO-UNDO.
DEF VAR aux_tpdpagto AS CHAR                                    NO-UNDO.
DEF VAR aux_nmempres AS CHAR                                    NO-UNDO.
DEF VAR aux_dscodbar AS DECI                                    NO-UNDO.
DEF VAR aux_insitfat AS CHAR                                    NO-UNDO.
DEF VAR aux_nmextcon AS CHAR                                    NO-UNDO.
DEF VAR aux_vldpagto AS DEC                                     NO-UNDO.
DEF VAR aux_dtdpagto AS DATE                                    NO-UNDO.
DEF VAR aux_flgpagin AS LOG                                     NO-UNDO.
DEF VAR aux_flgcnvsi AS LOG                                     NO-UNDO.
DEF var aux_nrregist AS INT                                     NO-UNDO.
DEF var aux_nriniseq AS INT                                     NO-UNDO.
DEF var aux_qtregist AS INT                                     NO-UNDO.
DEF var aux_cdhistor AS INT                                     NO-UNDO.
DEF var aux_nrdcaixa AS INT                                     NO-UNDO.
DEF var aux_nrdocmto AS DEC                                     NO-UNDO.
DEF var aux_cdoperad AS CHAR                                    NO-UNDO.
DEF var aux_cdbccxlt AS INT                                     NO-UNDO.
DEF var aux_nrdolote AS INT                                     NO-UNDO.
DEF var aux_cdempcon AS INT                                     NO-UNDO.
DEF var aux_cdsegmto AS INT                                     NO-UNDO.
DEF VAR aux_vlrtotal AS DEC                                     NO-UNDO.
/* PJ406 */
DEF VAR aux_dtipagto AS DATE                                    NO-UNDO.
DEF VAR aux_dtfpagto AS DATE                                    NO-UNDO.
DEF VAR aux_nrdconta AS INT                                     NO-UNDO.
DEF VAR aux_nrautdoc AS CHAR                                    NO-UNDO.

{ sistema/generico/includes/b1wgen0101tt.i }
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
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "cdhiscxa" THEN aux_cdhiscxa = INTE(tt-param.valorCampo).
            WHEN "cdhistor" THEN aux_cdhistor = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdagefat" THEN aux_cdagefat = INTE(tt-param.valorCampo).
            WHEN "nrdocmto" THEN aux_nrdocmto = DECI(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "cdbccxlt" THEN aux_cdbccxlt = INTE(tt-param.valorCampo).
            WHEN "nrdolote" THEN aux_nrdolote = INTE(tt-param.valorCampo).
            WHEN "tpdpagto" THEN aux_tpdpagto = tt-param.valorCampo.
            WHEN "dscodbar" THEN aux_dscodbar = DEC(tt-param.valorCampo).
            WHEN "insitfat" THEN aux_insitfat = tt-param.valorCampo.
            WHEN "nmempres" THEN aux_nmempres = tt-param.valorCampo.
            WHEN "vldpagto" THEN aux_vldpagto = DEC(tt-param.valorCampo).
            WHEN "dtdpagto" THEN aux_dtdpagto = DATE(tt-param.valorCampo).
            WHEN "flgpagin" THEN aux_flgpagin = LOGICAL(tt-param.valorCampo).
            WHEN "flgcnvsi" THEN aux_flgcnvsi = LOGICAL(tt-param.valorCampo).
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "cdempcon" THEN aux_cdempcon = INTE(tt-param.valorCampo).
            WHEN "cdsegmto" THEN aux_cdsegmto = INTE(tt-param.valorCampo).
            WHEN "nmextcon" THEN aux_nmextcon = tt-param.valorCampo.
            /* PJ406 */
            WHEN "dtipagto" THEN aux_dtipagto = DATE(tt-param.valorCampo).
            WHEN "dtfpagto" THEN aux_dtfpagto = DATE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "nrautdoc" THEN aux_nrautdoc = tt-param.valorCampo.
        END CASE.

    END. /** Fim do FOR EACH tt-param **/
    
END PROCEDURE.

/******************************************************************************/
/**  Procedure consulta os titulos                                           **/
/******************************************************************************/
PROCEDURE consulta_titulos:

    RUN consulta_titulos IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_dtdpagto,
                                 INPUT aux_vldpagto,
                                 INPUT aux_cdagenci,
                                 INPUT aux_flgpagin,
                                 INPUT aux_nrregist,
                                 INPUT aux_nriniseq,
                                 OUTPUT aux_qtregist,
                                 OUTPUT aux_vlrtotal,
                                 OUTPUT TABLE tt-dados-pesqti).

    RUN piXmlNew. 
    RUN piXmlExport (INPUT TEMP-TABLE tt-dados-pesqti:HANDLE,
                     INPUT "Dados").
    RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
    RUN piXmlAtributo (INPUT "vlrtotal",INPUT STRING(aux_vlrtotal)).
    RUN piXmlSave. 
    
END PROCEDURE.

/******************************************************************************/
/**  Procedure consulta as faturas                                           **/
/******************************************************************************/
PROCEDURE consulta_faturas:

    RUN consulta_faturas IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_dtdpagto,
                                 INPUT aux_vldpagto,
                                 INPUT aux_cdagenci,
                                 INPUT aux_flgpagin,
                                 INPUT aux_nrregist,
                                 INPUT aux_nriniseq,
                                 INPUT aux_cdempcon,
                                 INPUT aux_cdsegmto,
                                 
                                 /* PJ406 */
                                 INPUT aux_dtipagto,
                                 INPUT aux_dtfpagto,
                                 INPUT aux_nrdconta,
                                 INPUT aux_nrautdoc,
                                 
                                 OUTPUT aux_qtregist,
                                 OUTPUT aux_vlrtotal,
                                 OUTPUT TABLE tt-dados-pesqti,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-pesqti:HANDLE, 
                             INPUT "Dados").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlAtributo (INPUT "vlrtotal",INPUT STRING(aux_vlrtotal)).       
            RUN piXmlSave. 
        END.

END PROCEDURE.

/******************************************************************************/
/**  Procedure historicos                                                    **/
/******************************************************************************/
PROCEDURE lista-historicos:

    RUN lista-historicos IN hBO(INPUT aux_cdhiscxa, 
                                INPUT aux_nmempres,
                                INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist), 
                                INPUT aux_nriniseq, 
                                OUTPUT aux_qtregist, 
                                OUTPUT TABLE tt-historicos).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-historicos:HANDLE,
                             INPUT "Hist").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************/
/**  Procedure Empresas Conveniadas                                          **/
/******************************************************************************/
PROCEDURE lista-empresas-conv:

    RUN lista-empresas-conv IN hBO(INPUT aux_cdcooper, 
                                   INPUT aux_cdempcon,
                                   INPUT aux_cdsegmto,
                                   INPUT aux_nmextcon,
                                   INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist), 
                                   INPUT aux_nriniseq, 
                                   OUTPUT aux_qtregist, 
                                   OUTPUT TABLE tt-empr-conve).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-empr-conve:HANDLE,
                             INPUT "EmprConv").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************************************/
/**  Procedure para gravar alterações nos dados das faturas                  **/
/******************************************************************************/
PROCEDURE grava-dados-fatura:

    RUN grava-dados-fatura IN hBO(INPUT aux_cdcooper, 
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_cdagenci, 
                                  INPUT aux_nrdcaixa, 
                                  INPUT aux_cdoperad, 
                                  INPUT aux_cdagefat,
                                  INPUT aux_dtdpagto, 
                                  INPUT aux_nrdocmto, 
                                  INPUT aux_nrdolote, 
                                  INPUT aux_cdbccxlt, 
                                  INPUT aux_dscodbar, 
                                  INPUT aux_insitfat,
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
            RUN piXmlSave.
        END.

END PROCEDURE.

/****************************************************************************/
