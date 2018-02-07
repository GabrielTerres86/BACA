/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank113.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Fabricio
   Data    : Agosto/2014.                       Ultima atualizacao: 07/11/2017
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Buscar os lancamentos agendados e efetivados - Debito Facil.
      
   Alteracoes: 07/11/2017 - Retornar indicador de situacao do lancamento e
                            protocolo de lancamento efetivado (David).
                            
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
DEF INPUT PARAM par_dtiniper LIKE craplcm.dtmvtolt                     NO-UNDO.
DEF INPUT PARAM par_dtfimper LIKE craplcm.dtmvtolt                     NO-UNDO.
DEF INPUT PARAM par_cddopcao AS CHAR                                   NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

ASSIGN aux_dstransa = "Buscar lancamentos agendados e efetivados" + 
                      " - Debito Automatico Facil".

RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

IF VALID-HANDLE(h-b1wgen0092) THEN
DO:
    RUN busca_lancamentos IN h-b1wgen0092 (INPUT par_cdcooper,
                                           INPUT par_nrdconta,
                                           INPUT par_dtmvtolt,
                                           INPUT par_dtiniper,
                                           INPUT par_dtfimper,
                                           INPUT par_cddopcao,
                                          OUTPUT TABLE tt-lancamentos).
    
    DELETE PROCEDURE h-b1wgen0092.
                
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<LANCAMENTOS>".

    FOR EACH tt-lancamentos NO-LOCK:

        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<REGISTRO><dtmvtolt>" +
                                       STRING(tt-lancamentos.dtmvtolt,
                                              "99/99/9999") +
                                       "</dtmvtolt><nmextcon>" +
                                       tt-lancamentos.nmextcon +
                                       "</nmextcon><dshisext>" +
                                       tt-lancamentos.dshisext +
                                       "</dshisext><nrdocmto>" +
                                       STRING(tt-lancamentos.nrdocmto,
                                              "zzzzzzzzzzzzz9") +
                                       "</nrdocmto><vllanmto>" +
                                       STRING(tt-lancamentos.vllanmto,
                                              "zzz,zzz,zz9.99") +
                                       "</vllanmto><situacao>" +
                                       tt-lancamentos.situacao +
                                       "</situacao><cdhistor>" +
                                       STRING(tt-lancamentos.cdhistor,
                                              "zzz9") +
                                       "</cdhistor><insituac>" +
                                       STRING(tt-lancamentos.insituac) +
                                       "</insituac><dsprotoc>" +
                                       tt-lancamentos.dsprotoc +
                                       "</dsprotoc></REGISTRO>".
        
    END.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "</LANCAMENTOS>".
            
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



