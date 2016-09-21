/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank111.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Fabricio
   Data    : Setembro/2014.                       Ultima atualizacao:
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Buscar as autorizacoes de debito suspensas - Debito Facil.
      
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

DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                     NO-UNDO.
DEF INPUT PARAM par_nrdconta LIKE crapass.nrdconta                     NO-UNDO.
DEF INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                     NO-UNDO.
DEF INPUT PARAM par_dtmvtolt LIKE craplcm.dtmvtolt                     NO-UNDO.
DEF INPUT PARAM par_cddopcao AS CHAR                                   NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

ASSIGN aux_dstransa = "Buscar autorizacoes de debito suspensas" + 
                      " - Debito Automatico Facil".

RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

IF VALID-HANDLE(h-b1wgen0092) THEN
DO:
    RUN busca_autorizacoes_suspensas IN h-b1wgen0092 (INPUT par_cdcooper,
                                                      INPUT par_nrdconta,
                                                      INPUT par_dtmvtolt,
                                                      INPUT par_cddopcao,
                                                     OUTPUT TABLE 
                                                  tt-autorizacoes-suspensas).
    
    DELETE PROCEDURE h-b1wgen0092.
                
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<AUTORIZACOES_SUSPENSAS>".

    FOR EACH tt-autorizacoes-suspensas NO-LOCK:

        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<AUTORIZACAO><nmextcon>" +
                                       tt-autorizacoes-suspensas.nmextcon +
                                       "</nmextcon><nmrescon>" +
                                       tt-autorizacoes-suspensas.nmrescon +
                                       "</nmrescon><cdempcon>" +
                                       STRING(tt-autorizacoes-suspensas.cdempcon,
                                              "9999") +
                                       "</cdempcon><cdsegmto>" +
                                       STRING(tt-autorizacoes-suspensas.cdsegmto,
                                              "9") +
                                       "</cdsegmto><cdrefere>" +
                                       STRING(tt-autorizacoes-suspensas.cdrefere,
                                              "zzzzzzzzzzzzz9") +
                                       "</cdrefere><dtinisus>" +
                                       STRING(tt-autorizacoes-suspensas.dtinisus,
                                              "99/99/9999") +
                                       "</dtinisus><dtfimsus>" +
                                       STRING(tt-autorizacoes-suspensas.dtfimsus,
                                              "99/99/9999") +
                                       "</dtfimsus>" +
                                       "</AUTORIZACAO>".
        
    END.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "</AUTORIZACOES_SUSPENSAS>".
            
    RUN proc_geracao_log (INPUT TRUE).
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



