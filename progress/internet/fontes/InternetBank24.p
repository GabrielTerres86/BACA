/* ............................................................................
   Programa: siscaixa/web/InternetBank24.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Maio/2007.                        Ultima atualizacao: 09/12/2015
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Listar holerites para Internet.
   
   Alteracoes: 09/10/2007 - Gerar log com data TODAY e nao dtmvtolt (David).
               10/03/2008 - Utilizar includes de temp-tables (David).
   
               03/11/2008 - Inclusao widget-pool (martin)
               
               18/08/2015 - Alteraçoes Projeto 158 - Folha IB (Vanessa)
               
               09/12/2015 - Ajustando campo dtrefere para CHAR.
                           (Andre Santos - SUPERO)
 ............................................................................ */
 
create widget-pool.
 
    
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0017tt.i }
DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0017 AS HANDLE                                         NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dsholeri AS CHAR                                           NO-UNDO.
DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF INPUT  PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF INPUT  PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao24.
RUN sistema/generico/procedures/b1wgen0017.p PERSISTENT 
    SET h-b1wgen0017.
                
ASSIGN aux_dstransa = "Consulta de holerites".

IF  VALID-HANDLE(h-b1wgen0017)  THEN
    DO: 
        RUN lista_holerites IN h-b1wgen0017 (INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT par_idseqttl,
                                            OUTPUT TABLE tt-holerites,
                                            OUTPUT aux_dscritic).
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                                      "</dsmsgerr>".
                                           
                DELETE PROCEDURE h-b1wgen0017.
                
                RUN proc_geracao_log (INPUT FALSE).
                
                RETURN "NOK".
            END.
        
        FOR EACH tt-holerites NO-LOCK:

            ASSIGN aux_dsholeri =  STRING(tt-holerites.idtipfol).
            CREATE xml_operacao24.
            ASSIGN xml_operacao24.dscabini = "<HOLERITE>"
                   xml_operacao24.dtrefere = "<dtrefere>" + 
                                             tt-holerites.dtrefere +
                                             "</dtrefere>"
                   xml_operacao24.dsdpagto = "<dsdpagto>" +
                                             TRIM(tt-holerites.dsdpagto) +
                                             "</dsdpagto>"
                   xml_operacao24.dsholeri = "<dsholeri>" + 
                                             aux_dsholeri +
                                             "</dsholeri>"
                  xml_operacao24.idtipfol = "<idtipfol>" + 
                                      STRING(tt-holerites.idtipfol) +
                                             "</idtipfol>"
                  xml_operacao24.nrdrowid = "<nrdrowid>" + 
                                      STRING(tt-holerites.nrdrowid) +
                                             "</nrdrowid>"
                  xml_operacao24.dscabfim = "</HOLERITE>".
        
        END. /** Fim do FOR EACH tt-holerites **/           
              
        DELETE PROCEDURE h-b1wgen0017.
        
        RUN proc_geracao_log (INPUT TRUE).      
    END.
/* ............................... PROCEDURES ............................... */
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
                                          INPUT TODAY,
                                          INPUT par_flgtrans,
                                          INPUT TIME,
                                          INPUT par_idseqttl,
                                          INPUT "INTERNETBANK",
                                          INPUT par_nrdconta,
                                          OUTPUT aux_nrdrowid).
                                           
            DELETE PROCEDURE h-b1wgen0014.
        END.
    
END PROCEDURE.
