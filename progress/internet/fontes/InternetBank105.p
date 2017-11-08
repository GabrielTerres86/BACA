/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank105.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Fabricio
   Data    : Agosto/2014.                       Ultima atualizacao: 07/11/2017
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Buscar as autorizacoes de debito cadastradas - Debito Facil.
      
   Alteracoes : 30/05/2016 - Alteraçoes Oferta DEBAUT Sicredi (Lucas Lunelli - [PROJ320])

                07/07/2016 - Alterção na mascara do cdrefere para exibir conforme limite 
				             do campo da tabela (Odirlei-AMcom - [PROJ320])
                     
                07/11/2017 - Retornar indicadores de situacao da autorizacao (David).
   
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

ASSIGN aux_dstransa = "Buscar autorizacoes de debito cadastradas" + 
                      " - Debito Automatico Facil".

RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

IF VALID-HANDLE(h-b1wgen0092) THEN
DO:
    RUN busca_autorizacoes_cadastradas IN h-b1wgen0092 (INPUT par_cdcooper,
                                                        INPUT par_nrdconta,
                                                        INPUT par_dtmvtolt,
                                                        INPUT par_cddopcao,
                                                       OUTPUT TABLE tt-autorizacoes-cadastradas).
    
    DELETE PROCEDURE h-b1wgen0092.
                
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<AUTORIZACOES_CADASTRADAS>".

    FOR EACH tt-autorizacoes-cadastradas NO-LOCK:

        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<AUTORIZACAO><nmextcon>" +
                                       tt-autorizacoes-cadastradas.nmextcon +
                                       "</nmextcon><nmrescon>" +
                                       tt-autorizacoes-cadastradas.nmrescon +
                                       "</nmrescon><cdempcon>" +
                                       STRING(tt-autorizacoes-cadastradas.cdempcon,
                                              "9999") +
                                       "</cdempcon><cdsegmto>" +
                                       STRING(tt-autorizacoes-cadastradas.cdsegmto,
                                              "9") +
                                       "</cdsegmto><cdrefere>" +
                                       STRING(tt-autorizacoes-cadastradas.cdrefere,
                                              "zzzzzzzzzzzzzzzzzzzzzzzz9") +
                                       "</cdrefere><vlmaxdeb>" +
                                       STRING(tt-autorizacoes-cadastradas.vlmaxdeb,
                                              "zzz,zzz,zz9.99") +
                                       "</vlmaxdeb><dshisext>" +
                                       tt-autorizacoes-cadastradas.dshisext +
                                       "</dshisext><inaltera>" +
                                       STRING(tt-autorizacoes-cadastradas.inaltera) +
                                       "</inaltera><cdhistor>" +
                                       STRING(tt-autorizacoes-cadastradas.cdhistor) +
                                       "</cdhistor><insituac>" +
                                       STRING(tt-autorizacoes-cadastradas.insituac) +
                                       "</insituac><dssituac>" +
                                       tt-autorizacoes-cadastradas.dssituac +
                                       "</dssituac></AUTORIZACAO>".
        
    END.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "</AUTORIZACOES_CADASTRADAS>".
            
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


