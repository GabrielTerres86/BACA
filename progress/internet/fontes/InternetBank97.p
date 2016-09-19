/*..............................................................................

   Programa: siscaixa/web/InternetBank97.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Tiago
   Data    : Julho/2014.                       Ultima atualizacao: 11/12/2015

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Incluir agendamentos de aplicacoes e resgates.
   
   Alteracoes: 11/12/2015 - Adicionado validacao de representante quando for 
                            agendamento de resgate (Jorge/David) - Proj. 131
                            Assinatura Multipla.
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0081tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF INPUT PARAM par_cdcooper  LIKE    crapcop.cdcooper                 NO-UNDO.
DEF INPUT PARAM par_flgtipar  AS      INTE                             NO-UNDO.
DEF INPUT PARAM par_nrdconta  LIKE    crapaar.nrdconta                 NO-UNDO.
DEF INPUT PARAM par_idseqttl  LIKE    crapaar.idseqttl                 NO-UNDO.
DEF INPUT PARAM par_vlparaar  LIKE    crapaar.vlparaar                 NO-UNDO.
DEF INPUT PARAM par_flgtipin  AS      INTE                             NO-UNDO.
DEF INPUT PARAM par_qtdiacar  LIKE    crapaar.qtdiacar                 NO-UNDO.
DEF INPUT PARAM par_qtmesaar  LIKE    crapaar.qtmesaar                 NO-UNDO.
DEF INPUT PARAM par_dtiniaar  LIKE    crapaar.dtiniaar                 NO-UNDO.
DEF INPUT PARAM par_dtdiaaar  LIKE    crapaar.dtdiaaar                 NO-UNDO.
DEF INPUT PARAM par_dtvencto  LIKE    crapaar.dtvencto                 NO-UNDO.
DEF INPUT PARAM par_qtdiaven  LIKE    crapaar.qtdiacar                 NO-UNDO.
DEF INPUT PARAM par_cdoperad  LIKE    crapaar.cdoperad                 NO-UNDO.
DEF INPUT PARAM par_cdprogra  AS      CHAR                             NO-UNDO.
DEF INPUT PARAM par_idorigem  AS      INTE                             NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS LONGCHAR                              NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0004 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0081 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0155 AS HANDLE                                         NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_idastcjt AS INTE INIT 0                                    NO-UNDO.
DEF VAR aux_nrcpfcgc AS DECI                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_flcartma AS INTE                                           NO-UNDO.

ASSIGN aux_dstransa = "Inclusao de agendamentos de aplicacoes e resgates.".

FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

/* agendamento de resgate para conta com assinatura conjunta */
IF  par_flgtipar = 1  THEN 
    DO:
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
            
        RUN STORED-PROCEDURE pc_valid_repre_legal_trans
            aux_handproc = PROC-HANDLE NO-ERROR
                           (INPUT  par_cdcooper,
                            INPUT  par_nrdconta,
                            INPUT  par_idseqttl,
                            INPUT  1,  /* pr_flvldrep */
                            OUTPUT 0,
                            OUTPUT "").
        
        CLOSE STORED-PROC pc_valid_repre_legal_trans 
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN aux_cdcritic = 0
               aux_dscritic = ""
               aux_cdcritic = pc_valid_repre_legal_trans.pr_cdcritic 
                                  WHEN pc_valid_repre_legal_trans.pr_cdcritic <> ?
               aux_dscritic = pc_valid_repre_legal_trans.pr_dscritic
                                  WHEN pc_valid_repre_legal_trans.pr_dscritic <> ?. 
        
        IF  aux_cdcritic <> 0   OR
            aux_dscritic <> ""  THEN
            DO:
                IF aux_dscritic = "" THEN
                DO:
                    FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                                       NO-LOCK NO-ERROR.
                    
                    IF AVAIL crapcri THEN
                       ASSIGN aux_dscritic = crapcri.dscritic.
                    ELSE
                       ASSIGN aux_dscritic =  "Nao foi possivel validar o Representante " +
                                              "Legal.".
        
                END.
        
                ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                                      "</dsmsgerr>".  
                
                RUN proc_geracao_log (INPUT FALSE).
        
                RETURN "NOK".
            END.
        
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
        
        RUN STORED-PROCEDURE pc_verifica_rep_assinatura
            aux_handproc = PROC-HANDLE NO-ERROR
                           (INPUT  par_cdcooper,
                            INPUT  par_nrdconta,
                            INPUT  par_idseqttl,
                            INPUT  3,   /* cdorigem */
                            OUTPUT 0,   /* idastcjt */
                            OUTPUT 0,   /* nrcpfcgc */
                            OUTPUT "",  /* nmprimtl */
                            OUTPUT 0,   /* flcartma */
                            OUTPUT 0,   /* cdcritic */
                            OUTPUT ""). /* dscritic */
        
        CLOSE STORED-PROC pc_verifica_rep_assinatura 
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN aux_idastcjt = 0
               aux_nrcpfcgc = 0
               aux_nmprimtl = ""
               aux_flcartma = 0
               aux_cdcritic = 0
               aux_dscritic = ""
               aux_idastcjt = pc_verifica_rep_assinatura.pr_idastcjt 
                                  WHEN pc_verifica_rep_assinatura.pr_idastcjt <> ?
               aux_nrcpfcgc = pc_verifica_rep_assinatura.pr_nrcpfcgc 
                                  WHEN pc_verifica_rep_assinatura.pr_nrcpfcgc <> ?
               aux_nmprimtl = pc_verifica_rep_assinatura.pr_nmprimtl 
                                  WHEN pc_verifica_rep_assinatura.pr_nmprimtl <> ?
               aux_flcartma = pc_verifica_rep_assinatura.pr_flcartma 
                                  WHEN pc_verifica_rep_assinatura.pr_flcartma <> ?
               aux_cdcritic = pc_verifica_rep_assinatura.pr_cdcritic 
                                  WHEN pc_verifica_rep_assinatura.pr_cdcritic <> ?
               aux_dscritic = pc_verifica_rep_assinatura.pr_dscritic
                                  WHEN pc_verifica_rep_assinatura.pr_dscritic <> ?. 
        
        IF  aux_cdcritic <> 0   OR
            aux_dscritic <> ""  THEN
            DO:
                IF  aux_dscritic = "" THEN
                    DO:
                        FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                                           NO-LOCK NO-ERROR.
                        IF AVAIL crapcri THEN
                           ASSIGN aux_dscritic = crapcri.dscritic.
                        ELSE
                           ASSIGN aux_dscritic =  "Nao foi possivel validar o Representante " +
                                                  "Legal.".
                    END.
            
                ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                                      "</dsmsgerr>".  
                  
                RUN proc_geracao_log (INPUT FALSE).
        
                RETURN "NOK".
            END. 

        IF  aux_idastcjt = 1  THEN
            DO:
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
    
                RUN STORED-PROCEDURE pc_cria_trans_pend_aplica
                   aux_handproc = PROC-HANDLE NO-ERROR
                                  (INPUT  90,   /* par_cdagenci */
                                   INPUT  900,  /* par_nrdcaixa */
                                   INPUT  par_cdoperad,
                                   INPUT  "INTERNETBANK", /* par_nmdatela ? */
                                   INPUT  par_idorigem,
                                   INPUT  par_idseqttl,
                                   INPUT  0,   /* par_nrcpfope */
                                   INPUT  aux_nrcpfcgc,
                                   INPUT  0,   /* par_cdcoptfn */
                                   INPUT  0,   /* par_cdagetfn */
                                   INPUT  0,   /* par_nrterfin */
                                   INPUT  crapdat.dtmvtocd,
                                   INPUT  par_cdcooper,
                                   INPUT  par_nrdconta,
                                   INPUT  3,    /* par_idoperac */
                                   INPUT  "A",  /* par_idtipapl ? */
                                   INPUT  0,    /* par_nraplica */
                                   INPUT  0,    /* par_cdprodut */
                                   INPUT  0,    /* par_tpresgat */
                                   INPUT  par_vlparaar,    /* par_vlresgat ? */
                                   INPUT  0,    /* par_nrdocmto */
                                   INPUT  par_flgtipar,    /* par_idtipage ? */
                                   INPUT  par_flgtipin,    /* par_idperage */
                                   INPUT  par_qtmesaar,    /* par_qtmesage ? */
                                   INPUT  par_dtdiaaar,    /* par_dtdiaage ? */
                                   INPUT  par_dtiniaar,    /* par_dtiniage ? */
                                   INPUT  aux_idastcjt,
                                   OUTPUT 0,    /* par_cdcritic */
                                   OUTPUT "").  /* par_dscritic */
            
                CLOSE STORED-PROC pc_cria_trans_pend_aplica 
                     aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
            
                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
            
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = ""
                       aux_cdcritic = pc_cria_trans_pend_aplica.pr_cdcritic 
                                          WHEN pc_cria_trans_pend_aplica.pr_cdcritic <> ?
                       aux_dscritic = pc_cria_trans_pend_aplica.pr_dscritic
                                          WHEN pc_cria_trans_pend_aplica.pr_dscritic <> ?. 
            
                IF  aux_cdcritic <> 0   OR
                    aux_dscritic <> ""  THEN
                    DO:
                        IF  aux_dscritic = "" THEN
                            DO:
                                FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                                                   NO-LOCK NO-ERROR.
                    
                                IF AVAIL crapcri THEN
                                    ASSIGN aux_dscritic = crapcri.dscritic.
                                ELSE
                                    ASSIGN aux_dscritic =  "Nao foi possivel criar transacao pendente de aplicacao.".
                            END.
                        
                        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                                               "</dsmsgerr>".  
        
                        RUN proc_geracao_log (INPUT FALSE).
        
                        RETURN "NOK".
                    END. 
        
                ASSIGN aux_dscritic = "Agendamento de resgate registrado com sucesso. " + 
                                      "Aguardando aprovacao da operacao pelos "  +
                                      "demais responsaveis.".
        
                CREATE xml_operacao.
                ASSIGN xml_operacao.dslinxml = "<dsmsgsuc>" + aux_dscritic + "</dsmsgsuc>" +
                                               "<idastcjt>" + STRING(aux_idastcjt) + "</idastcjt>".
        
                RUN proc_geracao_log (INPUT TRUE). 
        
                RETURN "OK".
            END.
    END.

/* Gerar agendamento de resgate e nova aplicacao para contas sem assinatura conjunta */
RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT 
    SET h-b1wgen0081.
                
IF  VALID-HANDLE(h-b1wgen0081)  THEN
    DO:  
        RUN incluir-novo-agendamento
          IN h-b1wgen0081 (INPUT par_cdcooper,
                           INPUT par_flgtipar,
                           INPUT par_nrdconta,  
                           INPUT par_idseqttl,  
                           INPUT par_vlparaar,  
                           INPUT par_flgtipin,  
                           INPUT par_qtdiacar,  
                           INPUT par_qtmesaar,  
                           INPUT par_dtiniaar,  
                           INPUT par_dtdiaaar,  
                           INPUT par_dtvencto,  
                           INPUT par_qtdiaven,
                           INPUT "966",  
                           INPUT "INTERNETBANK",
                           INPUT 3,
                           OUTPUT TABLE tt-erro).

        DELETE PROCEDURE h-b1wgen0081.
             
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                 
                IF  AVAILABLE tt-erro  THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.
                ELSE
                    ASSIGN aux_dscritic = "Nao foi possivel consultar agendamentos.".
                     
                ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
    
                RUN proc_geracao_log (INPUT FALSE).
                 
                RETURN "NOK".
            END.

        RUN proc_geracao_log (INPUT TRUE). 

        RETURN "OK".
    END.

RETURN "OK".

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
                                          INPUT TODAY,
                                          INPUT par_flgtrans,
                                          INPUT TIME,
                                          INPUT par_idseqttl,
                                          INPUT "INTERNETBANK",
                                          INPUT par_nrdconta,
                                          OUTPUT aux_nrdrowid).

            IF  aux_idastcjt = 1  THEN
                DO:
                    RUN gera_log_item IN h-b1wgen0014 
                         (INPUT aux_nrdrowid,
                          INPUT "CPF Representante/Procurador" ,
                          INPUT "",
                          INPUT aux_nrcpfcgc).
        
                    RUN gera_log_item IN h-b1wgen0014 
                         (INPUT aux_nrdrowid,
                          INPUT "Nome Representante/Procurador" ,
                          INPUT "",
                          INPUT aux_nmprimtl).
                END.
                                           
            DELETE PROCEDURE h-b1wgen0014.
        END.
    
END PROCEDURE.

/*............................................................................*/



