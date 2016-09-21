/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank110.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Fabricio
   Data    : Setembro/2014.                       Ultima atualizacao:
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Validar / Cadastrar / Excluir suspensao da autorizacao de debito
               (Debito Automatico Facil).
      
   Alteracoes:
..............................................................................*/
 
CREATE WIDGET-POOL.
 
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0092tt.i }

DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0092 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dstrans1 AS CHAR                                           NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_flgconve AS LOGI                                           NO-UNDO.
DEF VAR aux_flgtitul AS LOGI                                           NO-UNDO.

DEF VAR aux_nmfatret AS CHAR                                           NO-UNDO.

DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.

DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                     NO-UNDO.
DEF INPUT PARAM par_nrdconta LIKE crapass.nrdconta                     NO-UNDO.
DEF INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                     NO-UNDO.
DEF INPUT PARAM par_dtmvtolt LIKE craplcm.dtmvtolt                     NO-UNDO.
DEF INPUT PARAM par_cdsegmto LIKE crapatr.cdsegmto                     NO-UNDO.
DEF INPUT PARAM par_cdempcon LIKE crapatr.cdempcon                     NO-UNDO.
DEF INPUT PARAM par_idconsum LIKE crapatr.cdrefere                     NO-UNDO.
DEF INPUT PARAM par_dtinisus LIKE crapatr.dtinisus                     NO-UNDO.
DEF INPUT PARAM par_dtfimsus LIKE crapatr.dtfimsus                     NO-UNDO.
DEF INPUT PARAM par_flcadast AS INTE                                   NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.


RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

IF VALID-HANDLE(h-b1wgen0092) THEN
DO:
    IF par_flcadast = 0 THEN /* validar */
    DO:
        ASSIGN aux_dstransa = "Validar dados inclusao suspensao autorizacao " +
                               "de debito - Debito Automatico Facil.".

        RUN valida_datas_suspensao IN h-b1wgen0092 (INPUT par_cdcooper,
                                                    INPUT par_nrdconta,
                                                    INPUT par_dtmvtolt,
                                                    INPUT par_cdsegmto,
                                                    INPUT par_cdempcon,
                                                    INPUT par_idconsum,
                                                    INPUT par_dtinisus,
                                                    INPUT par_dtfimsus,
                                                   OUTPUT TABLE tt-erro).
    END.
    ELSE
    IF par_flcadast = 1 THEN /* cadastrar */
    DO:
        ASSIGN aux_dstransa = "Cadastrar suspensao da autorizacao de debito" +
                              " - Debito Automatico Facil.".

        RUN cadastra_suspensao_autorizacao IN h-b1wgen0092 (INPUT par_cdcooper,
                                                            INPUT par_nrdconta,
                                                            INPUT par_dtmvtolt,
                                                            INPUT par_cdsegmto,
                                                            INPUT par_cdempcon,
                                                            INPUT par_idconsum,
                                                            INPUT par_dtinisus,
                                                            INPUT par_dtfimsus,
                                                           OUTPUT TABLE tt-erro).
    END.
    ELSE /* excluir */
    DO:
        ASSIGN aux_dstransa = "Excluir suspensao da autorizacao de debito" +
                              " - Debito Automatico Facil.".

        RUN exclui_suspensao_autorizacao IN h-b1wgen0092 (INPUT par_cdcooper,
                                                          INPUT par_nrdconta,
                                                          INPUT par_cdsegmto,
                                                          INPUT par_cdempcon,
                                                          INPUT par_idconsum,
                                                          INPUT par_dtmvtolt,
                                                         OUTPUT TABLE tt-erro).
    END.

    DELETE PROCEDURE h-b1wgen0092.
                
    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF NOT AVAILABLE tt-erro THEN
            ASSIGN aux_dscritic = "Nao foi possivel " + aux_dstransa.
        ELSE
            ASSIGN aux_dscritic = tt-erro.dscritic.
                    
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                              "</dsmsgerr>".
                 
        RETURN "NOK".
    END.

    RUN proc_geracao_log (INPUT TRUE).
    
    RETURN "OK".

END.

/*................................ PROCEDURES ................................*/

PROCEDURE proc_geracao_log:
    
    DEF INPUT PARAM par_flgtrans AS LOGICAL                         NO-UNDO.
    
    RUN sistema/generico/procedures/b1wgen0014.p PERSISTENT 
        SET h-b1wgen0014.
        
    IF  VALID-HANDLE(h-b1wgen0014)  THEN
        DO:
            RUN gera_log IN h-b1wgen0014 (INPUT par_cdcooper,
                                          INPUT "996",
                                          INPUT aux_dscritic,
                                          INPUT "INTERNET",
                                          INPUT aux_dstransa,
                                          INPUT aux_datdodia,
                                          INPUT par_flgtrans,
                                          INPUT TIME,
                                          INPUT par_idseqttl,
                                          INPUT "INTERNETBANK",
                                          INPUT par_nrdconta,
                                          OUTPUT aux_nrdrowid).
                                                            
            DELETE PROCEDURE h-b1wgen0014.
        END.
    
END PROCEDURE.
 
/*............................................................................*/

