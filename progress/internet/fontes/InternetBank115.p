/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank115.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Fabricio
   Data    : Setembro/2014.                       Ultima atualizacao: 15/12/2015
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Bloquear / Desbloquear lancamento de agendamento de debito
               (Debito Automatico Facil).
      
   Alteracoes: 15/12/2015 - Adicionado validacao de responsavel legal.
                            (Jorge/David) - Proj. Assinatura Multipla
..............................................................................*/
 
CREATE WIDGET-POOL.
 
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0092tt.i }
{ sistema/generico/includes/var_oracle.i   }

DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                     NO-UNDO.
DEF INPUT PARAM par_nrdconta LIKE crapass.nrdconta                     NO-UNDO.
DEF INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                     NO-UNDO.
DEF INPUT PARAM par_dtmvtolt LIKE craplcm.dtmvtolt                     NO-UNDO.
DEF INPUT PARAM par_dtmvtopg LIKE craplcm.dtmvtolt                     NO-UNDO.
DEF INPUT PARAM par_nrdocmto LIKE craplcm.nrdocmto                     NO-UNDO.
DEF INPUT PARAM par_cdhistor LIKE craplcm.cdhistor                     NO-UNDO.
DEF INPUT PARAM par_flcadast AS INTE                                   NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0092 AS HANDLE                                         NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dstrans1 AS CHAR                                           NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_flgconve AS LOGI                                           NO-UNDO.
DEF VAR aux_flgtitul AS LOGI                                           NO-UNDO.

DEF VAR aux_nmfatret AS CHAR                                           NO-UNDO.

DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.

DEF VAR aux_idastcjt AS INTE INIT 0                                    NO-UNDO.
DEF VAR aux_nrcpfcgc AS DECI                                           NO-UNDO.
DEF VAR aux_nmrepres AS CHAR                                           NO-UNDO.
DEF VAR aux_flcartma AS INTE                                           NO-UNDO.

ASSIGN aux_dstransa = (IF par_flcadast = 1 THEN "Bloquear" ELSE "Desbloquear")
       aux_dstransa = aux_dstransa + " lancamento de agendamento de debito " +
                      "- Debito Automatico Facil.".

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

IF aux_cdcritic <> 0   OR
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
       aux_nmrepres = ""
       aux_flcartma = 0
       aux_cdcritic = 0
       aux_dscritic = ""
       aux_idastcjt = pc_verifica_rep_assinatura.pr_idastcjt 
                          WHEN pc_verifica_rep_assinatura.pr_idastcjt <> ?
       aux_nrcpfcgc = pc_verifica_rep_assinatura.pr_nrcpfcgc 
                          WHEN pc_verifica_rep_assinatura.pr_nrcpfcgc <> ?
       aux_nmrepres = pc_verifica_rep_assinatura.pr_nmprimtl 
                          WHEN pc_verifica_rep_assinatura.pr_nmprimtl <> ?
       aux_flcartma = pc_verifica_rep_assinatura.pr_flcartma 
                          WHEN pc_verifica_rep_assinatura.pr_flcartma <> ?
       aux_cdcritic = pc_verifica_rep_assinatura.pr_cdcritic 
                          WHEN pc_verifica_rep_assinatura.pr_cdcritic <> ?
       aux_dscritic = pc_verifica_rep_assinatura.pr_dscritic
                          WHEN pc_verifica_rep_assinatura.pr_dscritic <> ?. 

IF aux_cdcritic <> 0   OR
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

/* Se a conta for exgir assinatura multipla */
IF aux_idastcjt = 1 THEN 
DO:
  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

   RUN STORED-PROCEDURE pc_cria_trans_pend_deb_aut
            aux_handproc = PROC-HANDLE NO-ERROR
                          (INPUT  90,
                           INPUT  900,
                           INPUT  "996",
                           INPUT  "INTERNETBANK",
                           INPUT  3,   /*  pr_cdorigem */
                           INPUT  par_idseqttl, 
                           INPUT  0,   /* pr_nrcpfope */
                           INPUT  aux_nrcpfcgc, /* pr_nrcpfrep */
                           INPUT  0,   /* pr_cdcoptfn */
                           INPUT  0,   /* pr_cdagetfn */
                           INPUT  0,   /* pr_nrterfin */
                           INPUT  par_dtmvtolt,
                           INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  (IF par_flcadast = 1 THEN 2 ELSE 3),   /* pr_idoperac, se par_flcadast = 1 (bloqueio), se 2 (desbloqueio) */
                           INPUT  par_cdhistor,    /* par_cdhisdeb */
                           INPUT  0,    /* par_idconsum */
                           INPUT  '',   /* par_dshisext */
                           INPUT  0,    /* par_vlmaxdeb */
                           INPUT  0,    /* par_cdempcon */
                           INPUT  0,    /* par_cdsegmto */
                           INPUT  par_dtmvtopg,
                           INPUT  par_nrdocmto,
                           INPUT  aux_idastcjt,
                           OUTPUT 0,    /* pr_cdcritic */
                           OUTPUT "").  /* pr_dscritic */
            
    CLOSE STORED-PROC pc_cria_trans_pend_deb_aut 
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_cria_trans_pend_deb_aut.pr_cdcritic 
                              WHEN pc_cria_trans_pend_deb_aut.pr_cdcritic <> ?
           aux_dscritic = pc_cria_trans_pend_deb_aut.pr_dscritic
                              WHEN pc_cria_trans_pend_deb_aut.pr_dscritic <> ?. 
    
    IF aux_cdcritic <> 0   OR
       aux_dscritic <> ""  THEN
    DO:
        IF aux_dscritic = "" THEN
        DO:
           FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                              NO-LOCK NO-ERROR.
        
           IF AVAIL crapcri THEN
              ASSIGN aux_dscritic = crapcri.dscritic.
           ELSE
              ASSIGN aux_dscritic =  "Nao foi possivel cadastrar debito automatico pendente.".
        
        END.
        
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                           "</dsmsgerr>".  

        RUN proc_geracao_log (INPUT FALSE).
        
        RETURN "NOK".
    END. 
    
    ASSIGN aux_dscritic = (IF par_flcadast = 1 THEN "Bloqueio" ELSE "Desbloqueio") 
           aux_dscritic = aux_dscritic + " de lancamento registrado com sucesso. " + 
                          "Aguardando aprovacao da operacao pelos "  +
                          "demais responsaveis.".   

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<dsmsgsuc>" + aux_dscritic + "</dsmsgsuc>" +
                                   "<idastcjt>" + STRING(aux_idastcjt) + "</idastcjt>".

    RUN proc_geracao_log (INPUT TRUE).

    RETURN "OK".
END.
ELSE
DO:
    RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.
    
    IF VALID-HANDLE(h-b1wgen0092) THEN
    DO:
        IF par_flcadast = 1 THEN /* bloquear */
        DO:
            RUN bloqueia_lancamento IN h-b1wgen0092 (INPUT par_cdcooper,
                                                     INPUT par_nrdconta,
                                                     INPUT par_dtmvtolt,
                                                     INPUT par_dtmvtopg,
                                                     INPUT par_nrdocmto,
                                                     INPUT par_cdhistor,
                                                    OUTPUT TABLE tt-erro).
        END.
        ELSE
        IF par_flcadast = 2 THEN /* desbloquear */
        DO:
            RUN desbloqueia_lancamento IN h-b1wgen0092 (INPUT par_cdcooper,
                                                        INPUT par_nrdconta,
                                                        INPUT par_dtmvtolt,
                                                        INPUT par_dtmvtopg,
                                                        INPUT par_nrdocmto,
                                                        INPUT par_cdhistor,
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

            RUN proc_geracao_log (INPUT FALSE).
                     
            RETURN "NOK".
        END.
    
        RUN proc_geracao_log (INPUT TRUE).
        
        RETURN "OK".
   END.
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
                        INPUT aux_nmrepres).
                END.
                                                            
            DELETE PROCEDURE h-b1wgen0014.
        END.
    
END PROCEDURE.
 
/*............................................................................*/


