


/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank85.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Adriano
   Data    : Maio/2014.                       Ultima atualizacao: 10/12/2015
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Realiza o cancelamento de apliações.
   
   Alteracoes: 10/12/2015 - Adicionado validacao de responsavel legal.
                            (Jorge/David) - Proj. Assinatura Multipla

..............................................................................*/

{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                     NO-UNDO.
DEF INPUT PARAM par_cdagenci LIKE crapage.cdagenci                     NO-UNDO.
DEF INPUT PARAM par_nrdcaixa AS INT                                    NO-UNDO.
DEF INPUT PARAM par_cdoperad LIKE crapope.cdoperad                     NO-UNDO.
DEF INPUT PARAM par_nmdatela AS CHAR                                   NO-UNDO.
DEF INPUT PARAM par_idorigem AS INT                                    NO-UNDO.
DEF INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                     NO-UNDO.
DEF INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                     NO-UNDO.
DEF INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                     NO-UNDO.
DEF INPUT PARAM par_nraplica LIKE craprda.nraplica                     NO-UNDO.
DEF INPUT PARAM par_flgerlog AS INT                                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.

DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dslinxml AS CHAR                                           NO-UNDO.
DEF VAR aux_idastcjt AS INTE                                           NO-UNDO.
DEF VAR aux_nrcpfcgc AS DECI                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_flcartma AS INTE                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

ASSIGN aux_dstransa = "Cancelamento de aplicacao".

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
  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

   RUN STORED-PROCEDURE pc_cria_trans_pend_aplica
       aux_handproc = PROC-HANDLE NO-ERROR
                      (INPUT  par_cdagenci,
                       INPUT  par_nrdcaixa,
                       INPUT  par_cdoperad,
                       INPUT  par_nmdatela,
                       INPUT  3,   /*  par_cdorigem */
                       INPUT  par_idseqttl,
                       INPUT  0,   /* par_nrcpfope */
                       INPUT  aux_nrcpfcgc,
                       INPUT  0,   /* par_cdcoptfn */
                       INPUT  0,   /* par_cdagetfn */
                       INPUT  0,   /* par_nrterfin */
                       INPUT  par_dtmvtolt,
                       INPUT  par_cdcooper,
                       INPUT  par_nrdconta,
                       INPUT  1,    /* par_idoperac */
                       INPUT  "A",  /* par_idtipapl */
                       INPUT  par_nraplica,
                       INPUT  0,    /* par_cdprodut */
                       INPUT  0,    /* par_tpresgat */
                       INPUT  0,    /* par_vlresgat */
                       INPUT  0,    /* par_nrdocmto */
                       INPUT  0,    /* par_idtipage */
                       INPUT  0,    /* par_idperage */
                       INPUT  0,    /* par_qtmesage */
                       INPUT  0,    /* par_dtdiaage */
                       INPUT  ?,    /* par_dtiniage */
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
                  ASSIGN aux_dscritic =  "Nao foi possivel criar transacao pendente de aplicacao.".

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
                  INPUT aux_nmprimtl).

             DELETE PROCEDURE h-b1wgen0014.
         END.

         ASSIGN aux_dscritic = "Cancelamento registrado com sucesso. "    + 
                               "Aguardando aprovacao da operacao pelos "  +
                               "demais responsaveis.".   
         ASSIGN xml_dsmsgerr = "<dsmsgsuc>" + aux_dscritic + "</dsmsgsuc>" +
                               "<idastcjt>" + STRING(aux_idastcjt) + "</idastcjt>".
         RETURN "NOK".
      END.
END.
ELSE
DO:
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
    
    RUN STORED-PROCEDURE pc_excluir_nova_aplicacao
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT par_cdoperad,
                                 INPUT par_nmdatela,
                                 INPUT par_idorigem,
                                 INPUT par_nrdconta,
                                 INPUT par_idseqttl,
                                 INPUT par_dtmvtolt,
                                 INPUT par_nraplica,
                                 INPUT par_flgerlog,
                                 OUTPUT 0,
                                 OUTPUT "").
    
    CLOSE STORED-PROC pc_excluir_nova_aplicacao
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_dslinxml = ""
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_excluir_nova_aplicacao.pr_cdcritic 
                              WHEN pc_excluir_nova_aplicacao.pr_cdcritic <> ?
           aux_dscritic = pc_excluir_nova_aplicacao.pr_dscritic
                              WHEN pc_excluir_nova_aplicacao.pr_dscritic <> ?. 
    
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
                    ASSIGN aux_dscritic = "Nao foi possivel realizar o " +
                                          "cancelamento.".
    
              END.
    
           ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                                 "</dsmsgerr>".  
    
           RETURN "NOK".
           
       END.
    ELSE
    DO:
        ASSIGN aux_dscritic = "Aplicacao Nr. " + STRING(par_nraplica) +  
                              " cancelada com sucesso.".   
        ASSIGN xml_dsmsgerr = "<dsmsgsuc>" + aux_dscritic + "</dsmsgsuc>".
        RETURN "NOK".
    END.
END.

RETURN "OK".


/*............................................................................*/



