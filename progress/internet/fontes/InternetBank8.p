/* ............................................................................

   Programa: siscaixa/web/InternetBank8.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Marco/2007                        Ultima atualizacao:   /  /

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Carregar saldos medios do semestre.
   
   Alteracoes: 03/11/2008 inclusao widget-pool (martin)
                            
 ............................................................................ */
    
create widget-pool.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0001tt.i }

DEF VAR h-b1wgen0001 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.

DEF VAR aux_contador AS INTE                                           NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF INPUT  PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF INPUT  PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.
DEF INPUT  PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao8.

ASSIGN aux_dstransa = "Carregar saldos medios do semestre".

RUN sistema/generico/procedures/b1wgen0001.p PERSISTENT 
    SET h-b1wgen0001.

IF  VALID-HANDLE(h-b1wgen0001)  THEN
    DO:
        RUN obtem-medias IN h-b1wgen0001 (INPUT par_cdcooper,
                                          INPUT 90,
                                          INPUT 900,
                                          INPUT "996",
                                          INPUT par_nrdconta,
                                         OUTPUT TABLE tt-erro,
                                         OUTPUT TABLE tt-medias).


        DELETE PROCEDURE h-b1wgen0001.
        
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                IF  AVAILABLE tt-erro  THEN
                    aux_dscritic = tt-erro.dscritic.
                ELSE
                    aux_dscritic = "Nao foi possivel carregar os saldos " +
                                   "medios.".
                    
                xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
                RUN proc_geracao_log (INPUT FALSE).
                                
                RETURN "NOK".
            END.
            
        FIND FIRST tt-medias NO-LOCK NO-ERROR.
        
        IF  AVAILABLE tt-medias  THEN
            DO:
                CREATE xml_operacao8.
        
                ASSIGN aux_contador           = 0
                       xml_operacao8.dscabini = "<MEDIAS>"
                       xml_operacao8.dscabfim = "</MEDIAS>".
                
                FOR EACH tt-medias NO-LOCK:
                
                    ASSIGN aux_contador = aux_contador + 1.
            
                    IF  aux_contador = 1  THEN
                        ASSIGN xml_operacao8.nmmesmd1 = "<nmmesmd1>" + 
                                                      TRIM(tt-medias.periodo) +
                                                        "</nmmesmd1>"
                               xml_operacao8.vlsldmd1 = "<vlsldmd1>"+ 
                      TRIM(STRING(DECI(tt-medias.vlsmstre),"zzz,zzz,zz9.99")) +
                                                        "</vlsldmd1>".
                                                        
                    IF  aux_contador = 2  THEN
                        ASSIGN xml_operacao8.nmmesmd2 = "<nmmesmd2>" + 
                                                      TRIM(tt-medias.periodo) +
                                                        "</nmmesmd2>"
                               xml_operacao8.vlsldmd2 = "<vlsldmd2>"+ 
                      TRIM(STRING(DECI(tt-medias.vlsmstre),"zzz,zzz,zz9.99")) +
                                                        "</vlsldmd2>".
                                                                              
                    IF  aux_contador = 3  THEN
                        ASSIGN xml_operacao8.nmmesmd3 = "<nmmesmd3>" + 
                                                      TRIM(tt-medias.periodo) +
                                                        "</nmmesmd3>"
                               xml_operacao8.vlsldmd3 = "<vlsldmd3>"+ 
                      TRIM(STRING(DECI(tt-medias.vlsmstre),"zzz,zzz,zz9.99")) +
                                                        "</vlsldmd3>".
                                                                               
                    IF  aux_contador = 4  THEN
                        ASSIGN xml_operacao8.nmmesmd4 = "<nmmesmd4>" + 
                                                      TRIM(tt-medias.periodo) +
                                                        "</nmmesmd4>"
                               xml_operacao8.vlsldmd4 = "<vlsldmd4>"+ 
                      TRIM(STRING(DECI(tt-medias.vlsmstre),"zzz,zzz,zz9.99")) +
                                                        "</vlsldmd4>".
                                                                               
                    IF  aux_contador = 5  THEN
                        ASSIGN xml_operacao8.nmmesmd5 = "<nmmesmd5>" + 
                                                      TRIM(tt-medias.periodo) +
                                                        "</nmmesmd5>"
                               xml_operacao8.vlsldmd5 = "<vlsldmd5>"+ 
                      TRIM(STRING(DECI(tt-medias.vlsmstre),"zzz,zzz,zz9.99")) +
                                                        "</vlsldmd5>".
                                                                               
                    IF  aux_contador = 6  THEN
                        ASSIGN xml_operacao8.nmmesmd6 = "<nmmesmd6>" + 
                                                      TRIM(tt-medias.periodo) +
                                                        "</nmmesmd6>"
                               xml_operacao8.vlsldmd6 = "<vlsldmd6>"+ 
                      TRIM(STRING(DECI(tt-medias.vlsmstre),"zzz,zzz,zz9.99")) +
                                                        "</vlsldmd6>".           
                END.
            END.
            
        RUN proc_geracao_log (INPUT TRUE).

        RETURN "OK".
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

