/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank99.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Fabricio
   Data    : Agosto/2014.                       Ultima atualizacao: 15/12/2015
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Validar / Cadastrar / Alterar / Excluir autorizacao de debito 
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
DEF INPUT PARAM par_cdsegmto LIKE crapatr.cdsegmto                     NO-UNDO.
DEF INPUT PARAM par_cdempcon LIKE crapatr.cdempcon                     NO-UNDO.
DEF INPUT PARAM par_idconsum LIKE crapatr.cdrefere                     NO-UNDO.
DEF INPUT PARAM par_flglimit LIKE crapatr.flgmaxdb                     NO-UNDO.
DEF INPUT PARAM par_vlmaxdeb LIKE crapatr.vlrmaxdb                     NO-UNDO.
DEF INPUT PARAM par_dshisext LIKE crapatr.dshisext                     NO-UNDO.
DEF INPUT PARAM par_cdhisdeb LIKE gnconve.cdhisdeb                     NO-UNDO.
DEF INPUT PARAM par_flcadast AS INTE                                   NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.


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

DEF VAR aux_idastcjt AS INTE                                           NO-UNDO.
DEF VAR aux_nmrepres AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcpfcgc AS DECI                                           NO-UNDO.
DEF VAR aux_flcartma AS INTE                                           NO-UNDO.


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

     RETURN "NOK".

  END.


RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

IF VALID-HANDLE(h-b1wgen0092) THEN
DO:
    IF par_flcadast = 0 THEN /* validar */
    DO:
        ASSIGN aux_dstransa = "Validar dados cadastro autorizacao de debito" +
                              " - Debito Automatico Facil.".

        RUN valida-dados IN h-b1wgen0092 (INPUT par_cdcooper,
                                         INPUT 90, /* cdagenci */
                                         INPUT 900, /* nrdcaixa */
                                         INPUT "996", /* cdoperad */
                                         INPUT "INTERNETBANK", /* nmdatela */
                                         INPUT 3, /* idorigem */
                                         INPUT par_nrdconta,
                                         INPUT par_idseqttl,
                                         INPUT FALSE,
                                         INPUT "I", /* cddopcao */
                                         INPUT par_cdhisdeb, /* cdhistor */
                                         INPUT par_idconsum, /* cdrefere */
                                         INPUT par_dtmvtolt, /* dtiniatr */
                                         INPUT ?, /* dtfimatr */
                                         INPUT ?,
                                         INPUT par_dtmvtolt,
                                         INPUT 0, /* dtvencto */
                                        OUTPUT aux_nmdcampo,
                                        OUTPUT aux_nmprimtl,
                                        OUTPUT TABLE tt-erro).
    END.
    ELSE
    IF par_flcadast = 1 THEN /* cadastrar */
    DO:
        ASSIGN aux_dstransa = "Cadastrar autorizacao de debito" +
                              " - Debito Automatico Facil.".
        
        /* se conta exige assinatura conjunta */
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
                           INPUT  1,   /* pr_idoperac */
                           INPUT  par_cdhisdeb,
                           INPUT  par_idconsum,
                           INPUT  par_dshisext,
                           INPUT  par_vlmaxdeb,
                           INPUT  par_cdempcon,
                           INPUT  par_cdsegmto,
                           INPUT  par_dtmvtolt, /* pr_dtmvtopg */
                           INPUT  0,    /* pr_nrdocmto */
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
            
             RETURN "NOK".
            
            END. 
            ELSE
            DO:
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
                                               INPUT TRUE,
                                               INPUT TIME,
                                               INPUT par_idseqttl,
                                               INPUT "InternetBank",
                                               INPUT par_nrdconta,
                                               OUTPUT aux_nrdrowid).
            
                 RUN gera_log_item IN h-b1wgen0014 
                     (INPUT aux_nrdrowid,
                      INPUT "Origem",
                      INPUT "",
                      INPUT "INTERNETBANK").
            
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
            
                 DELETE PROCEDURE h-b1wgen0014.
             END.
            
             ASSIGN aux_dscritic = "Autorizacao registrado com sucesso. "     + 
                                   "Aguardando aprovacao da operacao pelos "  +
                                   "demais responsaveis.".   
             ASSIGN xml_dsmsgerr = "<dsmsgsuc>" + aux_dscritic + "</dsmsgsuc>" +
                                   "<idastcjt>" + STRING(aux_idastcjt) + "</idastcjt>".
             RETURN "NOK".
            END.    
        END.
        ELSE
        DO:
            RUN grava-dados IN h-b1wgen0092 (INPUT par_cdcooper,
                                             INPUT 90, /* cdagenci */
                                             INPUT 900, /* nrdcaixa */
                                             INPUT "996", /* cdoperad */
                                             INPUT "INTERNETBANK", /* nmdatela */
                                             INPUT 3, /* idorigem */
                                             INPUT par_nrdconta,
                                             INPUT par_idseqttl,
                                             INPUT FALSE,
                                             INPUT par_dtmvtolt,
                                             INPUT "I", /* cddopcao */
                                             INPUT STRING(par_cdhisdeb), /* cdhistor */
                                             INPUT par_idconsum,
                                             INPUT 0, /* cddddtel */
                                             INPUT par_dtmvtolt,
                                             INPUT ?, /* dtfimatr */
                                             INPUT ?,
                                             INPUT 0, /* dtvencto */
                                             INPUT par_dshisext,
                                             INPUT par_vlmaxdeb,
                                             INPUT "", /* flgsicre */
                                             INPUT par_cdempcon,
                                             INPUT par_cdsegmto,
                                             INPUT "",
                                             INPUT "",
                                             INPUT "",
                                             INPUT "",
                                             INPUT "",
                                             INPUT "",
                                            OUTPUT aux_nmfatret,
                                            OUTPUT TABLE tt-erro).
        END.
    END.
    ELSE
    IF par_flcadast = 2 THEN /* alterar */
    DO:
        ASSIGN aux_dstransa = "Alterar autorizacao de debito" +
                              " - Debito Automatico Facil.".

        RUN altera_autorizacao IN h-b1wgen0092 (INPUT par_cdcooper,
                                                INPUT par_nrdconta,
                                                INPUT par_dtmvtolt,
                                                INPUT par_cdsegmto,
                                                INPUT par_cdempcon,
                                                INPUT par_idconsum,
                                                INPUT par_vlmaxdeb,
                                                INPUT par_dshisext,
                                               OUTPUT TABLE tt-erro).
    END.
    ELSE /* excluir */
    DO:
        ASSIGN aux_dstransa = "Excluir autorizacao de debito" +
                              " - Debito Automatico Facil.".

        RUN exclui_autorizacao IN h-b1wgen0092 (INPUT par_cdcooper,
                                                INPUT par_nrdconta,
                                                INPUT par_dtmvtolt,
                                                INPUT par_cdsegmto,
                                                INPUT par_cdempcon,
                                                INPUT par_idconsum,
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
                 
        RETURN "NOK".
    END.

    RUN proc_geracao_log (INPUT TRUE).
    
    RETURN "OK".

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
