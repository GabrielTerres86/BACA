/*.............................................................................
   Programa: sistema/internet/fontes/InternetBank118.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Fabricio
   Data    : Setembro/2014                       Ultima atualizacao: 20/05/2016
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Listar protocolos de operacoes pertinentes ao Debito Automatico
               Facil.
   
   Alteracoes: 20/05/2016 - Carregar protocolo 15-pagamento debito automatico
                            PRJ320 - Oferta DebAut (Odirlei-AMcom)
.............................................................................*/
 
create widget-pool.
 
    
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/bo_algoritmo_seguranca.i }

DEF VAR h-b1wgen0014             AS HANDLE                             NO-UNDO.
DEF VAR h-bo_algoritmo_seguranca AS HANDLE                             NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_qttotreg AS INTE                                           NO-UNDO.
DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF INPUT  PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF INPUT  PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF INPUT  PARAM par_dtinipro LIKE crappro.dtmvtolt                    NO-UNDO.
DEF INPUT  PARAM par_dtfimpro LIKE crappro.dtmvtolt                    NO-UNDO.
DEF INPUT  PARAM par_iniconta AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_nrregist AS INTE                                  NO-UNDO.
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao25.

    /* Carregar protocolos */
    RUN carrega_protocolos  (INPUT 11). /* Debito Facil */
    IF  RETURN-VALUE = "NOK"  THEN
      DO: 
          RETURN "NOK".
      END.
      
    /* Carregar protocolos */  
    RUN carrega_protocolos  (INPUT 15). /* Pagamento */
    IF  RETURN-VALUE = "NOK"  THEN
      DO:
          RETURN "NOK".
      END.
    
    
    RUN proc_geracao_log (INPUT TRUE). 
             
    RETURN "OK".
    
    

/*................................ PROCEDURES ................................*/
/* Carregar protocolos */
PROCEDURE carrega_protocolos:
  DEF INPUT PARAM par_cdtippro AS INTE                           NO-UNDO.
  
RUN sistema/generico/procedures/bo_algoritmo_seguranca.p PERSISTENT 
    SET h-bo_algoritmo_seguranca.
                
IF  VALID-HANDLE(h-bo_algoritmo_seguranca)  THEN
    DO:
        RUN lista_protocolos IN h-bo_algoritmo_seguranca 
                                             (INPUT par_cdcooper,
                                              INPUT par_nrdconta,
                                              INPUT par_dtinipro,
                                              INPUT par_dtfimpro,
                                              INPUT "",
                                              INPUT par_iniconta,
                                              INPUT par_nrregist,
                                              INPUT par_cdtippro,
                                              INPUT 3, /** Internet **/
                                              OUTPUT aux_dstransa,
                                              OUTPUT aux_dscritic,
                                              OUTPUT aux_qttotreg,
                                              OUTPUT TABLE cratpro).

        DELETE PROCEDURE h-bo_algoritmo_seguranca.

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                                      "</dsmsgerr>".
                                           
                RUN proc_geracao_log (INPUT FALSE).
                
                RETURN "NOK".
            END.
        
          
        FOR EACH cratpro NO-LOCK:
            
            CREATE xml_operacao25.
            ASSIGN xml_operacao25.dscabini = "<DADOS>"
                   xml_operacao25.cdtippro = "<cdtippro>" +
                                             STRING(cratpro.cdtippro) +
                                             "</cdtippro>"
                   xml_operacao25.dtmvtolt = "<dtmvtolt>" + 
                                        STRING(cratpro.dtmvtolt,"99/99/9999") + 
                                             "</dtmvtolt>"
                   xml_operacao25.dttransa = "<dttransa>" + 
                                        STRING(cratpro.dttransa,"99/99/9999") + 
                                             "</dttransa>"
                   xml_operacao25.hrautent = "<hrautent>" +
                                          STRING(cratpro.hrautent,"HH:MM:SS") +
                                             "</hrautent>"
                   xml_operacao25.vldocmto = "<vldocmto>" +
                              TRIM(STRING(cratpro.vldocmto,"zzz,zzz,zz9.99")) +
                                             "</vldocmto>"
                   xml_operacao25.nrdocmto = "<nrdocmto>" +
                                    TRIM(STRING(cratpro.nrdocmto,"zzzzzzzzzzzzzz9")) +
                                             "</nrdocmto>"
                   xml_operacao25.nrseqaut = "<nrseqaut>" +
                                    TRIM(STRING(cratpro.nrseqaut,"zzzzzzz9")) +
                                             "</nrseqaut>"
                   xml_operacao25.dsinfor1 = "<dsinfor1>" +
                                             TRIM(cratpro.dsinform[1]) +
                                             "</dsinfor1>"
                   xml_operacao25.dsinfor2 = "<dsinfor2>" +
                                             TRIM(cratpro.dsinform[2]) +
                                             "</dsinfor2>"
                   xml_operacao25.dsinfor3 = "<dsinfor3>" +
                                             TRIM(cratpro.dsinform[3]) +
                                             "</dsinfor3>"
                   xml_operacao25.dsprotoc = "<dsprotoc>" + 
                                             TRIM(cratpro.dsprotoc) +
                                             "</dsprotoc>"
                   xml_operacao25.dscedent = "<dscedent>" +
                                             TRIM(cratpro.dscedent) +
                                             "</dscedent>"
                   xml_operacao25.cdagenda = "<cdagenda>" +
                                            (IF  cratpro.flgagend  THEN
                                                 "S"
                                             ELSE
                                                 "N") +
                                             "</cdagenda>"
                   xml_operacao25.qttotreg = "<qttotreg>" +
                                      TRIM(STRING(aux_qttotreg,"zzzzzzzzz9")) +
                                             "</qttotreg>"
                   xml_operacao25.nmprepos = "<nmprepos>" + 
                                             TRIM(cratpro.nmprepos) +
                                             "</nmprepos>"
                   xml_operacao25.nrcpfpre = "<nrcpfpre>" +
                                             STRING(cratpro.nrcpfpre) +
                                             "</nrcpfpre>"
                   xml_operacao25.nmoperad = "<nmoperad>" +
                                             TRIM(cratpro.nmoperad) +
                                             "</nmoperad>"
                   xml_operacao25.nrcpfope = "<nrcpfope>" +
                                             STRING(cratpro.nrcpfope) +
                                             "</nrcpfope>"
                   xml_operacao25.cdbcoctl = "<cdbcoctl>" +
                                             STRING(cratpro.cdbcoctl, "999") +
                                             "</cdbcoctl>" 
                                             WHEN cratpro.cdbcoctl <> 0
                   xml_operacao25.cdagectl = "<cdagectl>" +
                                             STRING(cratpro.cdagectl, "9999") +
                                             "</cdagectl>"
                                             WHEN cratpro.cdagectl <> 0
                   xml_operacao25.dscabfim = "</DADOS>".
        
        END. /** Fim do FOR EACH cratpro **/
                   
        RUN proc_geracao_log (INPUT TRUE). 
             
        RETURN "OK".
    END.

END PROCEDURE. /* carrega_protocolos */   

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

