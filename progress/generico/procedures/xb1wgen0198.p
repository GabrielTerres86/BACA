/*.............................................................................

    
    Programa: b1wgen0198.p
    Autor   : Odirlei Busana - AMcom
    Data    : Outubro/2017                   Ultima atualizacao: 

    Objetivo  : BO de Comunicacao XML x BO

    Alteracoes: 
    
.............................................................................*/

                                                                             

/*...........................................................................*/
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_msgrvcad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.

DEF VAR aux_cdbcochq AS INTE                                           NO-UNDO.
DEF VAR aux_cdconsul AS INTE                                           NO-UNDO.
DEF VAR aux_cdagedbb AS INTE                                           NO-UNDO.
DEF VAR aux_nrdctitg AS CHAR                                           NO-UNDO.
DEF VAR aux_nrctacns AS INTE                                           NO-UNDO.
DEF VAR aux_incadpos AS INTE                                           NO-UNDO.
DEF VAR aux_flgiddep AS INTE                                           NO-UNDO.
DEF VAR aux_flgrestr AS INTE                                           NO-UNDO.
DEF VAR aux_indserma AS INTE                                           NO-UNDO.
DEF VAR aux_inlbacen AS INTE                                           NO-UNDO.
DEF VAR aux_nmtalttl AS CHAR                                           NO-UNDO.
DEF VAR aux_qtfoltal AS INTE                                           NO-UNDO.
DEF VAR aux_cdempres AS INTE                                           NO-UNDO.
DEF VAR aux_nrinfcad AS INTE                                           NO-UNDO.
DEF VAR aux_nrpatlvr AS INTE                                           NO-UNDO.
DEF VAR aux_dsinfadi AS CHAR                                           NO-UNDO.
DEF VAR aux_nmctajur AS CHAR                                           NO-UNDO.




{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0198tt.i } 
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-WEB=SIM }
                                             
/*............................... PROCEDURES ................................*/
PROCEDURE valores_entrada:

    FOR EACH tt-param:
        
        CASE tt-param.nomeCampo:

            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "cdbcochq" THEN aux_cdbcochq = INTE(tt-param.valorCampo).
            WHEN "cdconsul" THEN aux_cdconsul = INTE(tt-param.valorCampo).
            WHEN "cdagedbb" THEN aux_cdagedbb = INTE(tt-param.valorCampo).
            WHEN "nrdctitg" THEN aux_nrdctitg = tt-param.valorCampo.
            WHEN "nrctacns" THEN aux_nrctacns = INTE(tt-param.valorCampo).
            WHEN "incadpos" THEN aux_incadpos = INTE(tt-param.valorCampo).
            WHEN "flgiddep" THEN aux_flgiddep = INTE(tt-param.valorCampo).
            WHEN "flgrestr" THEN aux_flgrestr = INTE(tt-param.valorCampo).
            WHEN "indserma" THEN aux_indserma = INTE(tt-param.valorCampo).
            WHEN "inlbacen" THEN aux_inlbacen = INTE(tt-param.valorCampo).
            WHEN "nmtalttl" THEN aux_nmtalttl = tt-param.valorCampo.
            WHEN "qtfoltal" THEN aux_qtfoltal = INTE(tt-param.valorCampo).
            WHEN "cdempres" THEN aux_cdempres = INTE(tt-param.valorCampo).
            WHEN "nrinfcad" THEN aux_nrinfcad = INTE(tt-param.valorCampo).
            WHEN "nrpatlvr" THEN aux_nrpatlvr = INTE(tt-param.valorCampo).
            WHEN "dsinfadi" THEN aux_dsinfadi = tt-param.valorCampo.
            WHEN "chavealt" THEN aux_chavealt = tt-param.valorCampo.
            WHEN "tpatlcad" THEN aux_tpatlcad = INTE(tt-param.valorCampo).
            WHEN "nmctajur" THEN aux_nmctajur = tt-param.valorCampo.
            
            

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.    



PROCEDURE Valida_Dados:

  DEF VAR aux_cotcance AS CHAR                           NO-UNDO.

    RUN valida_dados IN hBO (INPUT aux_cdcooper
                            ,INPUT aux_cdagenci
                            ,INPUT aux_nrdcaixa
                            ,INPUT aux_cdoperad
                            ,INPUT aux_nmdatela
                            ,INPUT aux_idorigem
                            ,INPUT aux_nrdconta
                            ,INPUT aux_idseqttl
                            ,INPUT TRUE
                            ,INPUT aux_cddopcao
                            ,INPUT aux_dtmvtolt
                            ,INPUT aux_cdbcochq
                            ,INPUT aux_cdconsul
                            ,INPUT aux_cdagedbb
                            ,INPUT aux_nrdctitg
                            ,INPUT aux_nrctacns
                            ,INPUT aux_incadpos
                            ,INPUT aux_flgiddep
                            ,INPUT aux_flgrestr
                            ,INPUT aux_indserma
                            ,INPUT aux_inlbacen
                            ,INPUT aux_nmtalttl
                            ,INPUT aux_qtfoltal
                            ,INPUT aux_cdempres
                            ,INPUT aux_nrinfcad
                            ,INPUT aux_nrpatlvr
                            ,INPUT aux_dsinfadi
                            ,INPUT aux_nmctajur                            
                            ,OUTPUT TABLE tt-erro                            
                            ,OUTPUT aux_nmdcampo) NO-ERROR .
                               

    IF  ERROR-STATUS:ERROR  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
            RETURN.
        END.
        
    IF  RETURN-VALUE <> "OK" THEN    
        DO: 
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "validacao.".
                END.
                
            RUN piXmlNew. 
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo", INPUT TRIM(aux_nmdcampo)).
            RUN piXmlSave.
        END.
    ELSE
        DO: 
            RUN piXmlNew. 
            RUN piXmlAtributo (INPUT "dsdmsgok", INPUT 'OK').
            RUN piXmlSave.
        END.    

   
END PROCEDURE.

PROCEDURE Grava_Dados:

  DEF VAR aux_cotcance AS CHAR                           NO-UNDO.

    RUN Grava_Dados IN hBO ( INPUT aux_cdcooper
                            ,INPUT aux_cdagenci
                            ,INPUT aux_nrdcaixa
                            ,INPUT aux_cdoperad
                            ,INPUT aux_nmdatela
                            ,INPUT aux_idorigem
                            ,INPUT aux_nrdconta
                            ,INPUT aux_idseqttl
                            ,INPUT TRUE
                            ,INPUT aux_cddopcao
                            ,INPUT aux_dtmvtolt
                            ,INPUT aux_cdbcochq
                            ,INPUT aux_cdconsul
                            ,INPUT aux_cdagedbb
                            ,INPUT aux_nrdctitg
                            ,INPUT aux_nrctacns
                            ,INPUT aux_incadpos
                            ,INPUT aux_flgiddep
                            ,INPUT aux_flgrestr
                            ,INPUT aux_indserma
                            ,INPUT aux_inlbacen
                            ,INPUT aux_nmtalttl
                            ,INPUT aux_qtfoltal
                            ,INPUT aux_cdempres
                            ,INPUT aux_nrinfcad
                            ,INPUT aux_nrpatlvr
                            ,INPUT aux_dsinfadi
                            ,INPUT aux_nmctajur
                            
                            ,OUTPUT aux_tpatlcad
                            ,OUTPUT aux_msgatcad
                            ,OUTPUT aux_chavealt
                            ,OUTPUT aux_msgrvcad
                            ,OUTPUT aux_cotcance
                            ,OUTPUT TABLE tt-erro) NO-ERROR .
                               

    IF  ERROR-STATUS:ERROR  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
            RETURN.
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
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
           RUN piXmlAtributo (INPUT "msgatcad", INPUT aux_msgatcad).
           RUN piXmlAtributo (INPUT "msgrvcad", INPUT aux_msgrvcad).
           RUN piXmlAtributo (INPUT "tpatlcad", INPUT aux_tpatlcad).
           RUN piXmlAtributo (INPUT "chavealt", INPUT aux_chavealt).
           RUN piXmlAtributo (INPUT "cotcance", INPUT aux_cotcance).
           RUN piXmlSave.
        END.        

END PROCEDURE.




