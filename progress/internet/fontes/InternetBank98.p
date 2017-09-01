/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank98.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Fabricio
   Data    : Agosto/2014.                       Ultima atualizacao:
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Buscar os convenios aceitos (cod. barras c/ debito automatico).
      
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

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

ASSIGN aux_dstransa = "Buscar convenios aceitos - Debito Automatico Facil".

RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

IF VALID-HANDLE(h-b1wgen0092) THEN
DO:
    RUN busca_convenios_codbarras IN h-b1wgen0092 (INPUT par_cdcooper,
                                                   INPUT 0, /*cdempcon*/
                                                   INPUT 0, /*cdsegmto*/
                                                  OUTPUT TABLE 
                                                   tt-convenios-codbarras).
    
    DELETE PROCEDURE h-b1wgen0092.
                
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<CONVENIOS_ACEITOS>".

    FOR EACH tt-convenios-codbarras NO-LOCK:

        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<CONVENIO><nmextcon>" +
                                       tt-convenios-codbarras.nmextcon +
                                       "</nmextcon><nmrescon>" +
                                       tt-convenios-codbarras.nmrescon +
                                       "</nmrescon><cdempcon>" +
                                       STRING(tt-convenios-codbarras.cdempcon,
                                              "9999") +
                                       "</cdempcon><cdsegmto>" +
                                       STRING(tt-convenios-codbarras.cdsegmto,
                                              "9") +
                                       "</cdsegmto><cdhisdeb>" +
                                       STRING(tt-convenios-codbarras.cdhistor,
                                              "9999") +
                                       "</cdhisdeb>" +
                                       "</CONVENIO>".
        
    END.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "</CONVENIOS_ACEITOS>".
            
    /*Cria o nó de segmentos*/
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<SEGMENTOS>".
    CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = "<SEGMENTO><cdsegmto>0</cdsegmto><dssegmto>Todos</dssegmto></SEGMENTO>".
    CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<SEGMENTO><cdsegmto>1</cdsegmto><dssegmto>Prefeituras</dssegmto></SEGMENTO>".
    CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<SEGMENTO><cdsegmto>2</cdsegmto><dssegmto>Saneamento</dssegmto></SEGMENTO>".
    CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<SEGMENTO><cdsegmto>3</cdsegmto><dssegmto>Energia Elétrica e Gás</dssegmto></SEGMENTO>".
    CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<SEGMENTO><cdsegmto>4</cdsegmto><dssegmto>Telecomunicações</dssegmto></SEGMENTO>".
    CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<SEGMENTO><cdsegmto>5</cdsegmto><dssegmto>Órgãos Governamentais</dssegmto></SEGMENTO>".
    CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<SEGMENTO><cdsegmto>6</cdsegmto><dssegmto>Órgãos Identificados pelo CNPJ</dssegmto></SEGMENTO>".
    CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<SEGMENTO><cdsegmto>7</cdsegmto><dssegmto>Multas de Trânsito</dssegmto></SEGMENTO>".
    CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<SEGMENTO><cdsegmto>8</cdsegmto><dssegmto>Uso Exclusivo do Banco</dssegmto></SEGMENTO>".
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "</SEGMENTOS>".
            
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

