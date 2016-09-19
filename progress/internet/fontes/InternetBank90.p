/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank90.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : James Prust Junior
   Data    : Julho/2014.                       Ultima atualizacao: 19/01/2016
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Busca o saldo disponivel para realizar a contratacao
               do emprestimo pre-aprovado
   
   Alteracoes: 11/11/2014 - Inclusao do parametro "nrcpfope" na chamada da
                            procedure "busca_dados" da "b1wgen0188". (Jaison)
                            
               19/01/2016 - Adicionado validacao de responsavel legal.
                            (David) - Proj. Assinatura Multipla             

..............................................................................*/

CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0188tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF VAR h-b1wgen0188 AS HANDLE                                         NO-UNDO.

DEF  INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdagenci AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdcaixa AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdoperad AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nmdatela AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_idseqttl AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrcpfope AS DECI                                  NO-UNDO.
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_idastcjt AS INTE INIT 0                                    NO-UNDO.
DEF VAR aux_nrcpfcgc AS DECI                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_flcartma AS INTE                                           NO-UNDO.

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

RUN STORED-PROCEDURE pc_valid_repre_legal_trans
    aux_handproc = PROC-HANDLE NO-ERROR
                   (INPUT  par_cdcooper,
                    INPUT  par_nrdconta,
                    INPUT  par_idseqttl,
                    INPUT  (IF par_nrcpfope > 0 THEN 0 ELSE 1), /* pr_flvldrep */
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
      ASSIGN xml_dsmsgerr = "<dsmsgerr>Não foi possível consultar o " +
                              "pré-aprovado.</dsmsgerr>".
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
        ASSIGN xml_dsmsgerr = "<dsmsgerr>Não foi possível consultar o " +
                              "pré-aprovado.</dsmsgerr>".
        RETURN "NOK".
    END. 

RUN sistema/generico/procedures/b1wgen0188.p PERSISTENT SET h-b1wgen0188.
                
IF VALID-HANDLE(h-b1wgen0188) THEN
   DO: 
       RUN busca_dados IN h-b1wgen0188 (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_cdoperad,
                                        INPUT par_nmdatela,
                                        INPUT 3, /* par_cdorigem */
                                        INPUT par_nrdconta,
                                        INPUT IF aux_idastcjt = 0 THEN par_idseqttl ELSE 1,
                                        INPUT par_nrcpfope,
                                        OUTPUT TABLE tt-dados-cpa,
                                        OUTPUT TABLE tt-erro).
       
       DELETE PROCEDURE h-b1wgen0188.
       IF RETURN-VALUE = "NOK" THEN
          DO:
              ASSIGN xml_dsmsgerr = "<dsmsgerr>Não foi possível consultar o " +
                                    "pré-aprovado.</dsmsgerr>".
              RETURN "NOK".
          END.

       CREATE xml_operacao.
       FIND tt-dados-cpa NO-LOCK NO-ERROR.
       IF AVAIL tt-dados-cpa THEN
          DO:
              ASSIGN xml_operacao.dslinxml = 
                 "<DADOS>"      +
                   "<vldiscrd>" + STRING(tt-dados-cpa.vldiscrd,"zzz,zzz,zz9.99-") + "</vldiscrd>" +
                   "<txmensal>" + STRING(tt-dados-cpa.txmensal,"zzz,zzz,zz9.99-") + "</txmensal>" +
                 "</DADOS>".

          END. /* END IF AVAIL tt-dados-cpa THEN */

       RETURN "OK".
   END.

/*...........................................................................*/
