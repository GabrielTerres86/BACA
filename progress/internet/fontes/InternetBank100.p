/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank100.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : James Prust Júnior
   Data    : Agosto/2014.                       Ultima atualizacao: 09/04/2018
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Gravar os dados do credito pre-aprovado.
      
   Alteracoes: 18/11/2014 - Inclusao do parametro nrcpfope. (Jaison)
   
               10/12/2015 - Adicionado validacao de responsavel legal.
                            (Jorge/David) - Proj. Assinatura Multipla

               09/04/2018 - Ajuste para que o caixa eletronico possa utilizar o mesmo
                            servico da conta online (PRJ 363 - Rafael Muniz Monteiro)
..............................................................................*/
 
CREATE WIDGET-POOL.
 
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0188tt.i }
{ sistema/generico/includes/var_oracle.i   }

DEF  INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdagenci AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdcaixa AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdoperad AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nmdatela AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_idseqttl AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_dtmvtopr AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_qtpreemp AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_vlpreemp AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_vlemprst AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_dtdpagto AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_percetop AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_nrcpfope AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_txmensal AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_vlrtarif AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_vltaxiof AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_vltariof AS DECI                                  NO-UNDO.
/* Projeto 363 - Novo ATM */
DEF  INPUT PARAM par_cdorigem AS INT                                   NO-UNDO.
DEF  INPUT PARAM par_dsorigem AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nmprogra AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_cdcoptfn AS INT                                   NO-UNDO.
DEF  INPUT PARAM par_cdagetfn AS INT                                   NO-UNDO.
DEF  INPUT PARAM par_nrterfin AS INT                                   NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR h-b1wgen0188 AS HANDLE                                         NO-UNDO. 
DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.

DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_nrctremp AS INTE                                           NO-UNDO.
DEF VAR aux_idastcjt AS INTE                                           NO-UNDO.
DEF VAR aux_nrcpfcgc AS DECI                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_flcartma AS INTE                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_qtminast AS INTE INIT 0                                    NO-UNDO.

ASSIGN aux_dstransa = "Gravar os dados do credito pre-aprovado".

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    

RUN STORED-PROCEDURE pc_valid_repre_legal_trans
    aux_handproc = PROC-HANDLE NO-ERROR
                   (INPUT  par_cdcooper,
                    INPUT  par_nrdconta,
                    INPUT  par_idseqttl,
                    INPUT  (IF par_nrcpfope > 0 THEN 0 ELSE 1), /* pr_flvldrep  */
                    OUTPUT 0,
                    OUTPUT "").

CLOSE STORED-PROC pc_valid_repre_legal_trans 
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

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


{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    

RUN STORED-PROCEDURE pc_verifica_rep_assinatura
    aux_handproc = PROC-HANDLE NO-ERROR
                   (INPUT  par_cdcooper,
                    INPUT  par_nrdconta,
                    INPUT  par_idseqttl,
                    INPUT  par_cdorigem, /* Projeto 363 - Novo ATM -> estava fixo 3,*/   /* cdorigem */
                    OUTPUT 0,   /* idastcjt */
                    OUTPUT 0,   /* nrcpfcgc */
                    OUTPUT "",  /* nmprimtl */
                    OUTPUT 0,   /* flcartma */
                    OUTPUT 0,   /* cdcritic */
                    OUTPUT ""). /* dscritic */


CLOSE STORED-PROC pc_verifica_rep_assinatura 
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

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

/* Se a conta for exgir assinatura multipla */
IF aux_idastcjt = 1 THEN 
DO:
   { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    

    RUN STORED-PROCEDURE pc_cria_trans_pend_credito
        aux_handproc = PROC-HANDLE NO-ERROR
                       (INPUT  par_cdagenci,
                        INPUT  par_nrdcaixa,
                        INPUT  par_cdoperad,
                        INPUT  par_nmdatela,
                        INPUT  par_cdorigem, /* Projeto 363 - Novo ATM -> estava fixo 3,*/   /*  par_cdorigem */
                        INPUT  par_idseqttl,
                        INPUT  0,   /* par_nrcpfope */
                        INPUT  aux_nrcpfcgc,
                        INPUT  par_cdcoptfn, /* Projeto 363 - Novo ATM -> estava fixo 0,*/   /* par_cdcoptfn */
                        INPUT  par_cdagetfn, /* Projeto 363 - Novo ATM -> estava fixo 0,*/   /* par_cdagetfn */
                        INPUT  par_nrterfin, /* Projeto 363 - Novo ATM -> estava fixo 0,*/   /* par_nrterfin */
                        INPUT  par_dtmvtolt,
                        INPUT  par_cdcooper,
                        INPUT  par_nrdconta,
                        INPUT  par_vlemprst,
                        INPUT  par_qtpreemp,
                        INPUT  par_vlpreemp,
                        INPUT  par_dtdpagto,
                        INPUT  par_percetop,
                        INPUT  par_vlrtarif,
                        INPUT  par_txmensal,
                        INPUT  par_vltariof,
                        INPUT  par_vltaxiof,
                        INPUT  aux_idastcjt,
                        OUTPUT 0,   /* cdcritic */
                        OUTPUT ""). /* dscritic */
    
    CLOSE STORED-PROC pc_cria_trans_pend_credito 
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_cria_trans_pend_credito.pr_cdcritic 
                              WHEN pc_cria_trans_pend_credito.pr_cdcritic <> ?
           aux_dscritic = pc_cria_trans_pend_credito.pr_dscritic
                              WHEN pc_cria_trans_pend_credito.pr_dscritic <> ?. 
    
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
                   ASSIGN aux_dscritic =  "Nao foi possivel criar transacao pendente de credito.".
    
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
                                            INPUT par_dsorigem, /* Projeto 363 - Novo ATM -> estava fixo "INTERNET",*/
                                            INPUT aux_dstransa,
                                            INPUT aux_datdodia,
                                            INPUT TRUE,
                                            INPUT TIME,
                                            INPUT par_idseqttl,
                                            INPUT par_nmprogra, /* Projeto 363 - Novo ATM -> estava fixo "InternetBank",*/
                                            INPUT par_nrdconta,
                                            OUTPUT aux_nrdrowid).
            
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
            
              DELETE PROCEDURE h-b1wgen0014.
          END.

          ASSIGN aux_dscritic = "Credito Pre-Aprovado registrado com sucesso. " + 
                                "Aguardando aprovacao da operacao pelos "       +
                                "demais responsaveis.".   

          /* Se possui assinatura conjunta, retornamos a quantidade minima de assinatura na conta */
          /*  Projeto 363 - Novo ATM  */
          ASSIGN aux_qtminast = 0.
          FIND FIRST crapass 
               WHERE crapass.cdcooper = par_cdcooper
                 AND crapass.nrdconta = par_nrdconta
               NO-LOCK NO-ERROR.
                 
          IF AVAIL crapass THEN
          DO:
              ASSIGN aux_qtminast = crapass.qtminast.
          END.
          
          CREATE xml_operacao.
          ASSIGN xml_operacao.dslinxml = "<dsmsgsuc>" + aux_dscritic + "</dsmsgsuc>" +
                                         "<idastcjt>" + STRING(aux_idastcjt) + "</idastcjt>" +
                                         "<qtminast>" + STRING(aux_qtminast) + "</qtminast>".

          RETURN "OK".
       END.
END.
ELSE
DO:
    IF NOT VALID-HANDLE(h-b1wgen0188) THEN
        RUN sistema/generico/procedures/b1wgen0188.p PERSISTENT SET h-b1wgen0188.

    IF VALID-HANDLE(h-b1wgen0188) THEN
    DO:
       RUN grava_dados IN h-b1wgen0188 (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_cdoperad,
                                        INPUT par_nmdatela,
                                        INPUT par_cdorigem, /* Projeto 363 - Novo ATM -> estava fixo 3, *//* par_idorigem */
                                        INPUT par_nrdconta,
                                        INPUT 1,
                                        INPUT par_dtmvtolt,
                                        INPUT par_dtmvtopr,
                                        INPUT par_qtpreemp,
                                        INPUT par_vlpreemp,
                                        INPUT par_vlemprst,
                                        INPUT par_dtdpagto,
                                        INPUT par_percetop,
                                        INPUT  par_cdcoptfn, /* Projeto 363 - Novo ATM -> estava fixo 0,*/   /* par_cdcoptfn */
                                        INPUT  par_cdagetfn, /* Projeto 363 - Novo ATM -> estava fixo 0,*/   /* par_cdagetfn */
                                        INPUT  par_nrterfin, /* Projeto 363 - Novo ATM -> estava fixo 0,*/   /* par_nrterfin */                                        
                                        INPUT par_nrcpfope,
                                        OUTPUT aux_nrctremp,
                                        OUTPUT TABLE tt-erro).

       DELETE PROCEDURE h-b1wgen0188.

       IF RETURN-VALUE <> "OK" THEN
          DO:
              FIND FIRST tt-erro NO-LOCK NO-ERROR.
              IF AVAIL tt-erro THEN
                 ASSIGN xml_dsmsgerr = "<dsmsgerr>" + tt-erro.dscritic + "</dsmsgerr>".
              ELSE   
                 DO:
                     ASSIGN xml_dsmsgerr = "<dsmsgerr>Não foi possível "      +
                                           "gravar os dados do pré-aprovado." +
                                           "</dsmsgerr>".
                 END.

              RETURN "NOK".
          END.
                
       CREATE xml_operacao.
       ASSIGN xml_operacao.dslinxml = "<DADOS>" +
           "<nrctremp>" + STRING(aux_nrctremp) + "</nrctremp>"  +
          "</DADOS>".
       RETURN "OK".
    END.
END.


/*............................................................................*/
