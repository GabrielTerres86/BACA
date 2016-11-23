/*..............................................................................

    Programa: xb1wgen0050.p
    Autor   : David
    Data    : Novembro/2009                   Ultima atualizacao: 27/09/2016

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO de Logs SPB (b1wgen0050.p)

   Alteracoes: 30/05/2012 - Adicionado o parametro de saida aux_nmarqpdf
                            na procedure obtem-log-spb. (Fabricio)
                            
               20/12/2013 - Adicionada procedure obtem-log-teds-migradas
                            para contas migradas Acredi >> Viacredi. (Fabricio)
   
               04/08/2015 - Ajustes referentes a Melhoria Gestao de TEDs/TECs - 85 
                            Tela LOGSPB (Lucas Ranghetti)
                            
               09/11/2015 - Adicionado campo "Crise" inestcri em proc. 
                            obtem-log-spb (Jorge/Andrino)
                            
               27/09/2016 - M211 - Adicionado parametros par_cdifconv nas procs 
                            obtem-log-spb, impressao-log-pdf e impressao-log-csv
                            (Jonata-RKAM)
                            
..............................................................................*/


DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_numedlog AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_inestcri AS INTE                                           NO-UNDO.
DEF VAR aux_vlrdated AS DECI                                           NO-UNDO.

DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_cdsitlog AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.

DEF VAR aux_flgidlog AS INT                                            NO-UNDO.

DEF VAR aux_dtmvtlog AS DATE                                           NO-UNDO.

DEF VAR aux_datmigra AS DATE                                           NO-UNDO.


{ sistema/generico/includes/b1wgen0050tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }
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
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "numedlog" THEN aux_numedlog = INTE(tt-param.valorCampo).
            WHEN "dtmvtlog" THEN aux_dtmvtlog = DATE(tt-param.valorCampo).
            WHEN "flgidlog" THEN aux_flgidlog = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "cdsitlog" THEN aux_cdsitlog = tt-param.valorCampo.
            WHEN "dsorigem" THEN aux_dsorigem = tt-param.valorCampo.
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.
            WHEN "datmigra" THEN aux_datmigra = DATE(tt-param.valorCampo).
            WHEN "inestcri" THEN aux_inestcri = INTE(tt-param.valorCampo).
            WHEN "vlrdated" THEN aux_vlrdated = DECI(tt-param.valorCampo).
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.


/******************************************************************************/
/**     Procedure para obter log das transacoes com SPB (Bancoob/Cecred)     **/
/******************************************************************************/
PROCEDURE obtem-log-spb:

    RUN obtem-log-spb IN hBO (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_dsorigem,
                              INPUT aux_flgidlog,
                              INPUT aux_dtmvtlog,
                              INPUT aux_numedlog,
                              INPUT aux_cdsitlog,
                              INPUT aux_nrdconta,
                              INPUT aux_nriniseq,
                              INPUT aux_nrregist,
                              INPUT 5, /* idorigem = 5 Ayllos WEB */
                              INPUT aux_dsiduser,
                              INPUT aux_inestcri,
                              INPUT aux_vlrdated,
                             OUTPUT aux_nmarqimp,
                             OUTPUT aux_nmarqpdf,
                             OUTPUT TABLE tt-logspb-detalhe,
                             OUTPUT TABLE tt-logspb-totais,
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
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
            RUN piXmlExport (INPUT TEMP-TABLE tt-logspb-detalhe:HANDLE,
                                 INPUT "Log_Detalhado").
            RUN piXmlExport (INPUT TEMP-TABLE tt-logspb-totais:HANDLE,
                                 INPUT "Log_Totais").
            RUN piXmlSave.
        END.
       
END PROCEDURE.

/* Procedure para obter log das transacoes de TEDs migradas. 
   (Migracao Acredi >> Viacredi) */
PROCEDURE obtem-log-teds-migradas:

    RUN obtem-log-teds-migradas IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_datmigra,
                                        INPUT 5, /* idorigem = 5 Ayllos WEB */
                                       OUTPUT aux_nmarqimp,
                                       OUTPUT aux_nmarqpdf,
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
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
            RUN piXmlSave.
        END.
       
END PROCEDURE.

PROCEDURE impressao-log-pdf:
     
    RUN impressao-log-pdf IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_dsorigem,
                                  INPUT aux_flgidlog,
                                  INPUT aux_dtmvtlog,
                                  INPUT aux_numedlog,
                                  INPUT aux_cdsitlog,
                                  INPUT aux_nrdconta,                              
                                  INPUT aux_vlrdated,
                                  INPUT aux_dsiduser,
                                  INPUT aux_inestcri,
                                 OUTPUT aux_nmarqpdf,                                                            
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
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).            
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE impressao-log-csv:
     
    RUN impressao-log-csv IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_dsorigem,
                                  INPUT aux_flgidlog,
                                  INPUT aux_dtmvtlog,
                                  INPUT aux_numedlog,
                                  INPUT aux_cdsitlog,
                                  INPUT aux_nrdconta,                              
                                  INPUT aux_vlrdated,
                                  INPUT aux_dsiduser,
                                  INPUT aux_inestcri,
                                 OUTPUT aux_nmarqimp,                                                            
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
            RUN piXmlAtributo (INPUT "nmarqcsv", INPUT aux_nmarqimp).            
            RUN piXmlSave.
        END.

END PROCEDURE.

/*............................................................................*/
