/* ............................................................................
   Programa: siscaixa/web/InternetBank37.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Abril/2007                        Ultima atualizacao: 25/08/2011
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Carregar convenios com que o associado gerou boletos
   
   Alteracoes: 
                            
               03/11/2008 - Inclusao widget-pool (martin)
               
               25/08/2011 - Adicionado retorno de retorna-convenios-remessa
                            gerada en procedure da b1wgen0010. (Jorge)
 
 ............................................................................ */
 
create widget-pool.
 
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0010tt.i }

DEF VAR h-b1wgen0010 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF INPUT  PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF INPUT  PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao37.

ASSIGN aux_dstransa = "Carregar convenios para gerar arquivo de retorno de " +
                      "cobranca".

RUN sistema/generico/procedures/b1wgen0010.p PERSISTENT SET h-b1wgen0010.

IF  VALID-HANDLE(h-b1wgen0010)  THEN
    DO:
        RUN retorna-convenios IN h-b1wgen0010 
                                  (INPUT par_cdcooper,   
                                   INPUT par_nrdconta, 
                                  OUTPUT TABLE tt-convenios-cobranca).
        
        RUN retorna-convenios-remessa IN h-b1wgen0010 
                                  (INPUT par_cdcooper,   
                                   INPUT par_nrdconta, 
                                  OUTPUT TABLE tt-convenios-cobrem).
        
        DELETE PROCEDURE h-b1wgen0010.

        CREATE xml_operacao37.
        ASSIGN xml_operacao37.dscabini = "<CONVENIOS>".
        FOR EACH tt-convenios-cobranca NO-LOCK BY tt-convenios-cobranca.nrcnvcob:
            CREATE xml_operacao37.
            ASSIGN xml_operacao37.nrcnvcob = "<CONVENIO><nrcnvcob>" + 
                   TRIM(STRING(tt-convenios-cobranca.nrcnvcob,"zzz,zzz,zz9")) + 
                                             "</nrcnvcob></CONVENIO>".
        END. /* FIM DE FOR EACH */
        CREATE xml_operacao37.
        ASSIGN xml_operacao37.dscabfim = "</CONVENIOS>".
                   

        CREATE xml_operacao37.
        ASSIGN xml_operacao37.dscabini = "<CONVENIOS-REM>".
        FOR EACH tt-convenios-cobrem NO-LOCK BY tt-convenios-cobrem.nrconven:
            CREATE xml_operacao37.
            ASSIGN xml_operacao37.nrcnvcob = "<CONVENIO><nrconven>" +
                    TRIM(STRING(tt-convenios-cobrem.nrconven,"zzz,zzz,zz9")) +
                                           "</nrconven><cddbanco>" +
                                  TRIM(STRING(tt-convenios-cobrem.cddbanco)) +
                                           "</cddbanco><nrremret>" +
                                  TRIM(STRING(tt-convenios-cobrem.nrremret)) +
                                           "</nrremret></CONVENIO>".
        END.
        CREATE xml_operacao37.
        ASSIGN xml_operacao37.dscabfim = "</CONVENIOS-REM>".


        RUN proc_geracao_log (INPUT TRUE).

        RETURN "OK".
        
    END. /* FIM DE VALIDA HANDLE */


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
