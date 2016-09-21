/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank92.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : James Prust Junior
   Data    : Julho/2014.                       Ultima atualizacao: 10/12/2015
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Busca as parcelas disponiveis para realizar a contratacao
               do emprestimo pre-aprovado
   
   Alteracoes: 18/11/2014 - Inclusao do parametro nrcpfope. (Jaison)

               10/12/2015 - Adicionado validacao de responsavel legal.
                            (Jorge/David) - Proj. Assinatura Multipla

               18/01/2016 - Retornar erro quando nao houver nenhuma parcela 
                            disponivel. (Carlos Rafael Tanholi - PRJ261 – 
                            Pré-Aprovado fase II)
..............................................................................*/

CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0188tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF  INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdagenci AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdcaixa AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdoperad AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nmdatela AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_idseqttl AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_vlemprst AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_diapagto AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrcpfope AS DECI                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR h-b1wgen0188 AS HANDLE                                         NO-UNDO.

DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_idastcjt AS INTE INIT 0                                    NO-UNDO.
DEF VAR aux_nrcpfcgc AS DECI                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_flcartma AS INTE                                           NO-UNDO.
DEF VAR aux_controle AS CHAR                                           NO-UNDO.

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

        RETURN "NOK".
    END. 

IF NOT VALID-HANDLE(h-b1wgen0188) THEN
   RUN sistema/generico/procedures/b1wgen0188.p PERSISTENT SET h-b1wgen0188.
                
IF VALID-HANDLE(h-b1wgen0188) THEN
   DO: 
       RUN valida_dados IN h-b1wgen0188 (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_cdoperad,
                                         INPUT par_nmdatela,
                                         INPUT 3, /* par_cdorigem */
                                         INPUT par_nrdconta,
                                         INPUT IF aux_idastcjt = 1 THEN 1 ELSE par_idseqttl,
                                         INPUT par_vlemprst,
                                         INPUT par_diapagto,
                                         INPUT par_nrcpfope, 
                                         OUTPUT TABLE tt-erro).
       IF RETURN-VALUE = "NOK" THEN
          DO:
              DELETE PROCEDURE h-b1wgen0188.
              FIND tt-erro NO-LOCK NO-ERROR.
              IF AVAIL tt-erro THEN
                 ASSIGN xml_dsmsgerr = "<dsmsgerr>" + tt-erro.dscritic + "</dsmsgerr>".
              ELSE   
                 DO:
                     ASSIGN xml_dsmsgerr = "<dsmsgerr>Não foi possível " +
                                           "consultar as parcelas do "   +
                                           "pré-aprovado.</dsmsgerr>".
                 END.

              RETURN "NOK".
          END.

       RUN calcula_parcelas_emprestimo IN h-b1wgen0188 (INPUT par_cdcooper,
                                                        INPUT par_cdagenci,
                                                        INPUT par_nrdcaixa,
                                                        INPUT par_cdoperad,
                                                        INPUT par_nmdatela,
                                                        INPUT 3, /* par_cdorigem */
                                                        INPUT par_nrdconta,
                                                        INPUT 1,
                                                        INPUT par_dtmvtolt,
                                                        INPUT par_vlemprst,
                                                        INPUT par_diapagto,
                                                        OUTPUT TABLE tt-parcelas-cpa,
                                                        OUTPUT TABLE tt-erro).
       
       DELETE PROCEDURE h-b1wgen0188.
       IF RETURN-VALUE = "NOK" THEN
          DO:
              ASSIGN xml_dsmsgerr = "<dsmsgerr>Não foi possível consultar as " +
                                    "parcelas do pré-aprovado.</dsmsgerr>".
              RETURN "NOK".
          END.
       /* se nao houver nenhuma parcela disponivel, apresenta mensagem */
       aux_controle = 'N'.


       CREATE xml_operacao.
       ASSIGN xml_operacao.dslinxml = "<DADOS>".

       /* Valida se a quantidade de parcelas eh maior que zero */
       FOR EACH tt-parcelas-cpa NO-LOCK:
           CREATE xml_operacao.
           ASSIGN xml_operacao.dslinxml = "<PARCELA>" + 
                "<nrparepr>"  + STRING(tt-parcelas-cpa.nrparepr) + "</nrparepr>" +
                "<vlparepr>"  + TRIM(STRING(tt-parcelas-cpa.vlparepr,"zzz,zzz,zz9.99")) + "</vlparepr>" +
                "<dtvencto>"  + STRING(tt-parcelas-cpa.dtvencto,"99/99/9999") + "</dtvencto>" +
                "<flgdispo>"  + STRING(INT(tt-parcelas-cpa.flgdispo)) + "</flgdispo>" +
             "</PARCELA>".

           /* se ao menos uma parcela estiver disponivel */
           IF INT(tt-parcelas-cpa.flgdispo) = 1 THEN
           DO:
            aux_controle = 'S'.
           END.

       END. /* END FOR EACH tt-parcelas-cpa */

       CREATE xml_operacao.
       ASSIGN xml_operacao.dslinxml = "</DADOS>".


       /* consistencia sobre o numero de parcelas. PRJ 261 */
       IF aux_controle = 'N' THEN 
       DO:
            ASSIGN xml_dsmsgerr = "<dsmsgerr>Não é possível calcular parcela para o vencimento/valor" +
                                             "informado, realize alteração no vencimento/valor.</dsmsgerr>".
            RETURN "NOK".
       END.


       RETURN "OK".
       
   END.

/*...........................................................................*/
