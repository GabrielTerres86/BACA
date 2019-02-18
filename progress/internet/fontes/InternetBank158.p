/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank158.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Daniel Zimmermann
   Data    : Setembro/2015.                       Ultima atualizacao: 05/10/2016
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Efetua pagamento contrato
   
   Alteracoes: 05/10/2016 - Incluido tratamento no retorno da procedrure
							valida_pagamentos_geral, Prj. 302 (Jean Michel).
                            
               16/02/2019 - Ajuste variável aux_nrrecid para DECI - Paulo Martins - Mouts                            

..............................................................................*/

CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0084att.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR h-b1wgen0084a AS HANDLE                                        NO-UNDO.
DEF VAR h-b1wgen0084b AS HANDLE                                        NO-UNDO.

DEF VAR aux_dstransa  AS CHAR                                          NO-UNDO.
DEF VAR aux_nrrecid   AS DECI                                          NO-UNDO.
DEF VAR aux_cont      AS INT                                           NO-UNDO.   
DEF VAR aux_excluir   AS LOGICAL                                       NO-UNDO. 
DEF VAR aux_totatual  AS DECI                                          NO-UNDO.
DEF VAR aux_totpagto  AS DECI                                          NO-UNDO.
DEF VAR aux_qtddeprc  AS INT                                           NO-UNDO.
DEF VAR aux_vlsomato  AS DECI                                          NO-UNDO.
DEF VAR aux_dscritic  AS CHAR                                          NO-UNDO.

DEF  INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdagenci AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdcaixa AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdoperad AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nmdatela AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_idseqttl AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrcpfope AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_nrctremp AS INTE                                  NO-UNDO. 
DEF  INPUT PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_dtmvtoan AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_ordempgo AS CHAR                                  NO-UNDO. 
DEF  INPUT PARAM par_qtdprepr AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_listapar AS CHAR                                  NO-UNDO. 
DEF  INPUT PARAM par_tipopgto AS INTE                                  NO-UNDO. 
DEF  INPUT PARAM par_flmobile AS LOGI                                  NO-UNDO.
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.


ASSIGN aux_dstransa = "Pagamento de Emprestimo".

/* par_ordempgo 1 - Inicio para Final   2 - Final para Inicio 
   par_tipopgto 1 - Contrato 2 - Parcela */

IF NOT CAN-DO("1,2", STRING(par_tipopgto)) THEN
    ASSIGN aux_dscritic = "Não foi possível efetuar a operação.".
    
ELSE IF par_tipopgto = 2 THEN /* 2 - Parcela */
DO:
    IF par_qtdprepr <= 0 THEN
        ASSIGN aux_dscritic = "Não foi possível efetuar a operação.".
        
    ELSE IF par_qtdprepr <> NUM-ENTRIES(par_listapar,',') THEN
        ASSIGN aux_dscritic = "Não foi possível efetuar a operação.".
        
    ELSE IF NOT CAN-DO("1,2", STRING(par_ordempgo)) THEN
        ASSIGN aux_dscritic = "Não foi possível efetuar a operação.".
END.

IF aux_dscritic <> "" THEN
    DO:
    RUN proc_geracao_log.
        RETURN "NOK".
    END.

RUN sistema/generico/procedures/b1wgen0084a.p PERSISTENT SET h-b1wgen0084a.

IF VALID-HANDLE(h-b1wgen0084a) THEN
   DO: 
       /* Incluir BO */ 
       RUN busca_pagamentos_parcelas IN h-b1wgen0084a
                                 (INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT par_cdoperad,
                                  INPUT par_nmdatela,
                                  INPUT 3,     /* aux_idorigem, */
                                  INPUT par_nrdconta,
                                  INPUT par_idseqttl,
                                  INPUT par_dtmvtolt,
                                  INPUT FALSE, /*  aux_flgerlog, */
                                  INPUT par_nrctremp,
                                  INPUT par_dtmvtoan,
                                  INPUT 0,     /* aux_nrparepr, */
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-pagamentos-parcelas,
                                 OUTPUT TABLE tt-calculado).


       DELETE PROCEDURE h-b1wgen0084a.
       IF RETURN-VALUE = "NOK" THEN
          DO:
              ASSIGN aux_dscritic = "Não foi possível consultar as parcelas do contratos.".
              RUN proc_geracao_log.
              RETURN "NOK".
          END.

      ASSIGN aux_qtddeprc = 0.

      IF NUM-ENTRIES(par_listapar,',') > 0 THEN
      DO:
    
        FOR EACH tt-pagamentos-parcelas EXCLUSIVE-LOCK:
    
           aux_totatual = aux_totatual + tt-pagamentos-parcelas.vlatrpag.
    
           aux_excluir = TRUE.
    
           DO aux_cont=1 TO NUM-ENTRIES(par_listapar,','):

             IF tt-pagamentos-parcelas.nrparepr = INTE(ENTRY(aux_cont,par_listapar,','))  THEN
               DO:

                 aux_qtddeprc = aux_qtddeprc + 1. 

                 aux_excluir = FALSE.
                 aux_totpagto = aux_totpagto + tt-pagamentos-parcelas.vlatrpag.

                 ASSIGN tt-pagamentos-parcelas.vlpagpar = tt-pagamentos-parcelas.vlatrpag.
               END.
    
           END.
    
           /* Caso a parcela nao esteja na lista deve ser excluida */
           IF aux_excluir = TRUE THEN
               DELETE tt-pagamentos-parcelas.
    
        END.

        IF NUM-ENTRIES(par_listapar,',') <> aux_qtddeprc THEN
        DO: /*
            ASSIGN xml_dsmsgerr = "<dsmsgerr>Não foi possível consultar as " +
                                    "parcelas do contratos.</dsmsgerr>".
            */                        
            ASSIGN aux_dscritic = "Ha valores pagos na(s) parcela(s) selecionada(s), " +
                                  "consulte o extrato do seu contrato.".
            RUN proc_geracao_log.
            RETURN "NOK".
        END.


      END.
      ELSE
      DO:
        /* Soma valores totais a pagar */
        FOR EACH tt-pagamentos-parcelas NO-LOCK:
          aux_totatual = aux_totatual + tt-pagamentos-parcelas.vlatrpag.
          aux_totpagto = aux_totpagto + tt-pagamentos-parcelas.vlatrpag.

          ASSIGN tt-pagamentos-parcelas.vlpagpar = tt-pagamentos-parcelas.vlatrpag.
        END.

      END.


      RUN sistema/generico/procedures/b1wgen0084b.p PERSISTENT SET h-b1wgen0084b.

      IF VALID-HANDLE(h-b1wgen0084b) THEN
      DO:
    
        RUN valida_pagamentos_geral IN h-b1wgen0084b
                                     (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT 3,                /* aux_idorigem, */
                                      INPUT par_nrdconta,
                                      INPUT par_nrctremp,
                                      INPUT par_idseqttl,
                                      INPUT par_dtmvtolt,
                                      INPUT FALSE,            /*  aux_flgerlog, */
                                      INPUT par_dtmvtolt,
                                      INPUT aux_totpagto,     /* aux_vlapagar, */
                                     OUTPUT TABLE tt-erro,
                                     OUTPUT aux_vlsomato,
                                     OUTPUT TABLE tt-msg-confirma).

           DELETE PROCEDURE h-b1wgen0084b.
           IF RETURN-VALUE = "NOK" THEN
              DO:
                  FIND FIRST tt-erro NO-LOCK NO-ERROR.

                  IF AVAILABLE tt-erro THEN
                     ASSIGN aux_dscritic = tt-erro.dscritic.
                  ELSE
                     ASSIGN aux_dscritic = "Erro Saldo".                  
                  
                  RUN proc_geracao_log.
                  RETURN "NOK".
              END.
           ELSE
           DO:
             FIND FIRST tt-msg-confirma NO-LOCK NO-ERROR.
         
             IF AVAILABLE tt-msg-confirma  THEN
                 DO:
                      ASSIGN aux_dscritic = tt-msg-confirma.dsmensag.
                      RUN proc_geracao_log.
                      RETURN "NOK".
                 END.


           END.
       END.

      RUN sistema/generico/procedures/b1wgen0084a.p 
        PERSISTENT SET h-b1wgen0084a.

      IF VALID-HANDLE(h-b1wgen0084a) THEN
      DO: 

       RUN gera_pagamentos_parcelas IN h-b1wgen0084a
                                 (INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT par_cdoperad,
                                  INPUT par_nmdatela,
                                  INPUT 3, /* aux_idorigem, 3-Internet */
                                  INPUT 90, /* par_cdpactra Verificar */
                                  INPUT par_nrdconta,
                                  INPUT par_idseqttl,
                                  INPUT par_dtmvtolt,
                                  INPUT FALSE, /*  aux_flgerlog, */
                                  INPUT par_nrctremp,
                                  INPUT par_dtmvtoan,
                                  INPUT aux_totatual,
                                  INPUT aux_totpagto,
                                  INPUT 0, /* par_nrseqava, */
                                  INPUT TABLE tt-pagamentos-parcelas,
                                 OUTPUT TABLE tt-erro).

       IF  VALID-HANDLE(h-b1wgen0084a) THEN
            DELETE PROCEDURE h-b1wgen0084a.

         IF RETURN-VALUE = "NOK" THEN
         DO:
             /*
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
             IF AVAILABLE tt-erro  THEN
                 DO:
                     MESSAGE  tt-erro.dscritic
                         VIEW-AS ALERT-BOX INFO BUTTONS OK.
                 END.
*/

              ASSIGN aux_dscritic = "Não foi possível efetuar o " +
                                    "pagamento das parcelas do contratos.".
              RUN proc_geracao_log.
              RETURN "NOK".
         END.

      END.
      ELSE
      DO :
        ASSIGN aux_dscritic = "Não foi possível efetuar a operação.".
        RUN proc_geracao_log.
        RETURN "NOK".
      END.
  END.
ELSE
   DO :
        ASSIGN aux_dscritic = "Não foi possível efetuar a operação.".
          RUN proc_geracao_log.
          RETURN "NOK".
   END.
   

/*................................ PROCEDURES ................................*/

PROCEDURE proc_geracao_log:
    
      /* Gerar log(CRAPLGM) - Rotina Oracle */
      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
      RUN STORED-PROCEDURE pc_gera_log_prog
        aux_handproc = PROC-HANDLE NO-ERROR
        (INPUT par_cdcooper    /* pr_cdcooper */
        ,INPUT "996"           /* pr_cdoperad */
        ,INPUT aux_dscritic    /* pr_dscritic */
        ,INPUT "INTERNET"      /* pr_dsorigem */
        ,INPUT aux_dstransa    /* pr_dstransa */
        ,INPUT aux_datdodia    /* pr_dttransa */
        ,INPUT 0 /* Operacao sem sucesso */ /* pr_flgtrans */
        ,INPUT TIME            /* pr_hrtransa */
        ,INPUT par_idseqttl    /* pr_idseqttl */
        ,INPUT "INTERNETBANK"  /* pr_nmdatela */
        ,INPUT par_nrdconta    /* pr_nrdconta */
        ,OUTPUT 0 ). /* pr_nrrecid  */
    
      CLOSE STORED-PROC pc_gera_log_prog
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl}}
    
    
      ASSIGN aux_nrrecid = pc_gera_log_prog.pr_nrrecid
                              WHEN pc_gera_log_prog.pr_nrrecid <> ?.       
                              
      /* Gerar log item (CRAPLGI) - Rotina Oracle */
      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
     
      RUN STORED-PROCEDURE pc_gera_log_item_prog
               aux_handproc = PROC-HANDLE NO-ERROR
                  (INPUT aux_nrrecid,
                   INPUT "Tipo Pagamento",
                   INPUT "",
                   INPUT STRING(par_tipopgto=1,"Pagamento Total/Pagamento Parcial")).

      CLOSE STORED-PROC pc_gera_log_item_prog
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
      
      RUN STORED-PROCEDURE pc_gera_log_item_prog
               aux_handproc = PROC-HANDLE NO-ERROR
                  (INPUT aux_nrrecid,
                   INPUT "Contrato",
                   INPUT "",
                   INPUT STRING(par_nrctremp)).

      CLOSE STORED-PROC pc_gera_log_item_prog
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

      IF par_tipopgto = 2 THEN
      DO:
          RUN STORED-PROCEDURE pc_gera_log_item_prog
                   aux_handproc = PROC-HANDLE NO-ERROR
                      (INPUT aux_nrrecid,
                       INPUT "Ordem Pagamento",
                       INPUT "",
                       INPUT STRING(par_ordempgo="1","Inicio para Final/Final para Inicio")).

          CLOSE STORED-PROC pc_gera_log_item_prog
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

          RUN STORED-PROCEDURE pc_gera_log_item_prog
                   aux_handproc = PROC-HANDLE NO-ERROR
                      (INPUT aux_nrrecid,
                       INPUT "Quantidade de Parcelas",
                       INPUT "",
                       INPUT STRING(par_qtdprepr)).

          CLOSE STORED-PROC pc_gera_log_item_prog
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

          RUN STORED-PROCEDURE pc_gera_log_item_prog
                   aux_handproc = PROC-HANDLE NO-ERROR
                      (INPUT aux_nrrecid,
                       INPUT "Número das Parcelas",
                       INPUT "",
                       INPUT par_listapar).

          CLOSE STORED-PROC pc_gera_log_item_prog
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
      END.
      
      RUN STORED-PROCEDURE pc_gera_log_item_prog
               aux_handproc = PROC-HANDLE NO-ERROR
                  (INPUT aux_nrrecid,
                   INPUT "Origem",
                   INPUT "",
                   INPUT STRING(par_flmobile,"MOBILE/INTERNETBANK")).

      CLOSE STORED-PROC pc_gera_log_item_prog
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

     { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl}}
     

     IF aux_dscritic <> "" THEN DO:               
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".        
     END.
    
END PROCEDURE.