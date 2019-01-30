
/*----------------------------------------------------------------------*/
/*  b1crap74.p - Movimentacoes  - Estorno Cheque Avulso (Historico 22)  */
/*----------------------------------------------------------------------*/
/*.............................................................................

Alteracoes: 02/03/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

            27/05/2011 - Enviar email de controle de Movimentacao (Gabriel).
            
            09/02/2012 - Tratamento para estornar historico 1030 (Guilherme).
            
            21/05/2012 - substituição do FIND craptab para os registros 
                         CONTACONVE pela chamada do fontes ver_ctace.p
                         (Lucas R.)
            
            19/06/2018 - Alteracoes para usar as rotinas mesmo com o processo 
                         norturno rodando (Douglas Pagel - AMcom).

            15/10/2018 - Troca DELETE CRAPLCM pela chamada da rotina estorna_lancamento_conta 
                         de dentro da b1wgen0200 
                         (Renato AMcom) 

            16/01/2019 - Revitalizacao (Remocao de lotes) - Pagamentos, Transferencias, Poupanca
                         Heitor (Mouts)

            19/11/2018 - prj450 - história 10669:Crédito de Estorno de Saque em conta em Prejuízo
                         (Fabio Adriano - AMcom).
........................................................................... **/

{dbo/bo-erro1.i}
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0200tt.i }

DEFINE VARIABLE i-cod-erro            AS INT            NO-UNDO.
DEFINE VARIABLE c-desc-erro           AS CHAR           NO-UNDO.

DEF VAR i-nro-lote                    AS INTE           NO-UNDO.
DEF VAR aux_lscontas                  AS CHAR           NO-UNDO.
DEF VAR in99                          AS INTE           NO-UNDO.
DEF VAR h-b1wgen9998                  AS HANDLE         NO-UNDO.
DEF VAR h-b1wgen0200                  AS HANDLE         NO-UNDO.

DEF VAR aux_cdcritic                  AS INTE           NO-UNDO.
DEF VAR aux_dscritic                  AS CHAR           NO-UNDO.

PROCEDURE valida-cheque-avulso.
    
    DEF INPUT  PARAM p-cooper         AS CHAR. 
    DEF INPUT  PARAM p-cod-agencia    AS INTEGER.  
    DEF INPUT  PARAM p-nro-caixa      AS INTEGER.    
    DEF INPUT  PARAM p-nro-conta      AS INTEGER.    
    DEF INPUT  PARAM p-nrdocto        AS INTEGER.
    DEF output PARAM p-valor          AS DEC.
    DEF OUTPUT PARAM p-nome-titular   AS CHAR.
    DEF OUTPUT PARAM p-historico      AS INTE.
          
    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.
 
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    ASSIGN p-nro-conta = INT(REPLACE(string(p-nro-conta),".","")).

    ASSIGN i-nro-lote = 11000 + p-nro-caixa.
  
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
  
    IF  p-nrdocto = 0  THEN 
        DO:
            ASSIGN i-cod-erro  = 22
                   c-desc-erro = " ".  /* Documento deve ser Informado */                  RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
    IF  p-nro-conta = 0  THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Conta deve ser Informada".           
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    /*  Le tabela com as contas convenio do Banco do Brasil - Geral  */
        RUN fontes/ver_ctace.p(INPUT crapcop.cdcooper,
                               INPUT 0,
                               OUTPUT aux_lscontas).

    IF   NOT CAN-DO(aux_lscontas,STRING(p-nro-conta)) THEN 
        DO:

             FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND 
                                crapass.nrdconta = p-nro-conta                                                  NO-LOCK NO-ERROR.

         IF  NOT AVAIL crapass  THEN  
             DO:
                 ASSIGN i-cod-erro  = 9   
                        c-desc-erro = " ".           
                 ruN cria-erro (INPUT p-cooper,
                                INPUT p-cod-agencia,
                                INPUT p-nro-caixa,
                                INPUT i-cod-erro,
                                INPUT c-desc-erro,
                                INPUT YES).
                RETURN "NOK".
            END.
            ASSIGN p-nome-titular = crapass.nmprimtl.
        END.

    FIND craplcm WHERE
         craplcm.cdcooper = crapcop.cdcooper  AND
         craplcm.dtmvtolt = crapdat.dtmvtocd  AND
         craplcm.cdagenci = p-cod-agencia     AND
         craplcm.cdbccxlt = 11                AND /* Fixo */
         craplcm.nrdolote = i-nro-lote        AND
         craplcm.nrdctabb = p-nro-conta       AND
         craplcm.nrdocmto = p-nrdocto  USE-INDEX craplcm1  NO-LOCK NO-ERROR.

    IF  NOT AVAIL craplcm  or
        ENTRY(1, craplcm.cdpesqbb) <> "CRAP54" THEN 
        DO:
            ASSIGN i-cod-erro  = 90
                   c-desc-erro = " ".           
            run cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
        ASSIGN p-valor = craplcm.vllanmto.

        /* Revitalizacao - Remocao de lotes
        FIND craplot WHERE
             craplot.cdcooper = crapcop.cdcooper  AND
             craplot.dtmvtolt = crapdat.dtmvtocd  AND
             craplot.cdagenci = p-cod-agencia     AND
             craplot.cdbccxlt = 11                AND  /* Fixo */
             craplot.nrdolote = i-nro-lote        NO-LOCK NO-ERROR .

    IF   NOT AVAIL   craplot   THEN  
    DO:
         ASSIGN i-cod-erro  = 60
                c-desc-erro = " ".           
         RUN cria-erro (INPUT p-cooper,
                        INPUT p-cod-agencia,
                        INPUT p-nro-caixa,
                        INPUT i-cod-erro,
                        INPUT c-desc-erro,
                        INPUT YES).
          RETURN "NOK".
    END.
    */

    ASSIGN p-historico = craplcm.cdhistor.

    RETURN "OK".

END PROCEDURE.

   

PROCEDURE estorna-cheque-avulso.
    
    DEF INPUT PARAM p-cooper         AS CHAR.
    DEF INPUT PARAM p-cod-agencia    AS INTEGER.  
    DEF INPUT PARAM p-nro-caixa      AS INTEGER.   
    DEF INPUT PARAM p-cod-operador   AS CHAR.
    DEF INPUT PARAM p-nro-conta      AS INTEGER.    
    DEF INPUT PARAM p-nrdocto        AS INTEGER.
    DEF INPUT PARAM p-valor          AS DEC.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
     
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    ASSIGN p-nro-conta = INT(REPLACE(string(p-nro-conta),".","")).

    ASSIGN i-nro-lote = 11000 + p-nro-caixa.
  
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
   
    ASSIGN in99 = 0.
    /* Revitalizacao - Remocao de lotes
    DO  WHILE TRUE:
        ASSIGN in99 = in99 + 1.

        FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                           craplot.dtmvtolt = crapdat.dtmvtocd  AND
                           craplot.cdagenci = p-cod-agencia     AND
                           craplot.cdbccxlt = 11                AND  /* Fixo */
                           craplot.nrdolote = i-nro-lote       
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF   NOT AVAIL   craplot   THEN  
             DO:
                IF   LOCKED craplot     THEN 
                     DO:
                       IF  in99 <  100  THEN 
                           DO:
                             PAUSE 1 NO-MESSAGE.
                             NEXT.
                           END.
                         ELSE 
                           DO:
                             ASSIGN i-cod-erro  = 0
                                    c-desc-erro = "Tabela CRAPLOT em uso ".                                   RUN cria-erro (INPUT p-cooper,
                                            INPUT p-cod-agencia,
                                            INPUT p-nro-caixa,
                                            INPUT i-cod-erro,
                                            INPUT c-desc-erro,
                                            INPUT YES).
                             RETURN "NOK".
                           END.
                     END.
        ELSE 
             DO:
                  ASSIGN i-cod-erro  = 60
                         c-desc-erro = " ".           
                  RUN cria-erro (INPUT p-cooper,
                                 INPUT p-cod-agencia,
                                 INPUT p-nro-caixa,
                                 INPUT i-cod-erro,
                                 INPUT c-desc-erro,
                                 INPUT YES).
                  RETURN "NOK".
             END.
          END.
        LEAVE.
    END.*/
    /*  DO WHILE */
     
    ASSIGN in99 = 0.
    DO  WHILE TRUE:
        ASSIGN in99 = in99 + 1.
       
        FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper  AND
                           craplcm.dtmvtolt = crapdat.dtmvtocd  AND
                           craplcm.cdagenci = p-cod-agencia     AND
                           craplcm.cdbccxlt = 11                AND /* Fixo */
                           craplcm.nrdolote = i-nro-lote        AND
                           craplcm.nrdctabb = p-nro-conta       AND
                           craplcm.nrdocmto = p-nrdocto  USE-INDEX craplcm1
                           NO-ERROR NO-WAIT.
       
        IF   NOT AVAILABLE craplcm THEN 
             DO:
             IF   LOCKED craplcm   THEN 
                  DO:
                     IF  in99 <  100  THEN 
                         DO:
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                         END.
                     ELSE 
                         DO:
                            ASSIGN i-cod-erro  = 0
                                   c-desc-erro = "Tabela CRAPLCM em uso ".                                  RUN cria-erro (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT p-nro-caixa,
                                           INPUT i-cod-erro,
                                           INPUT c-desc-erro,
                                           INPUT YES).
                            RETURN "NOK".
                        END.
                   END.
             ELSE  DO:
                 ASSIGN i-cod-erro  = 90
                        c-desc-erro = " ".           
                 RUN cria-erro (INPUT p-cooper,
                                INPUT p-cod-agencia,
                                INPUT p-nro-caixa,
                                INPUT i-cod-erro,
                                INPUT c-desc-erro,
                                INPUT YES).
                 RETURN "NOK".
             END.
        END.
        LEAVE.
    END.  /*  DO WHILE */

    /*** Controle de movimentacao em especie ***/

    FIND crapcme WHERE crapcme.cdcooper = crapcop.cdcooper   AND
                       crapcme.dtmvtolt = craplcm.dtmvtolt   AND
                       crapcme.cdagenci = craplcm.cdagenci   AND
                       crapcme.cdbccxlt = craplcm.cdbccxlt   AND
                       crapcme.nrdolote = craplcm.nrdolote   AND
                       crapcme.nrdctabb = craplcm.nrdctabb   AND
                       crapcme.nrdocmto = craplcm.nrdocmto   
                       NO-ERROR.

    IF   AVAILABLE crapcme   THEN 
         DO:
             RUN sistema/generico/procedures/b1wgen9998.p
                PERSISTENT SET h-b1wgen9998.
            
             RUN email-controle-movimentacao IN h-b1wgen9998
                      (INPUT crapcop.cdcooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa, 
                       INPUT p-cod-operador,
                       INPUT "b1crap74",
                       INPUT 2, /* Caixa online */
                       INPUT crapcme.nrdconta,
                       INPUT 1, /* Tit*/
                       INPUT 3, /* Exclusao */
                       INPUT ROWID(crapcme),
                       INPUT TRUE, /* Enviar */
                       INPUT crapdat.dtmvtocd,
                       INPUT TRUE,
                      OUTPUT TABLE tt-erro).
            
             DELETE PROCEDURE h-b1wgen9998.

             IF   RETURN-VALUE <> "OK"   THEN
                  DO:
                      FIND FIRST tt-erro NO-LOCK NO-ERROR.   
                    
                      IF   AVAIL tt-erro   THEN                            
                           IF   tt-erro.cdcritic <> 0   THEN 
                                ASSIGN i-cod-erro  = tt-erro.cdcritic.           
                           ELSE 
                                ASSIGN c-desc-erro = tt-erro.dscritic.          
                      ELSE                                                 
                           ASSIGN c-desc-erro = "Erro no envio do email.".
                  
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".                   
                  END.
               
             DELETE crapcme.
         END. 
                    
    /* Remocao lotes
    ASSIGN craplot.qtcompln  = craplot.qtcompln - 1
           craplot.qtinfoln  = craplot.qtinfoln - 1
           craplot.vlcompdb  = craplot.vlcompdb - p-valor
           craplot.vlinfodb  = craplot.vlinfodb - p-valor.
    */

		{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
		RUN STORED-PROCEDURE pc_estorno_tarifa_saque  aux_handproc = PROC-HANDLE NO-ERROR
								(INPUT 	craplcm.cdcooper,    /*Código da Cooperativa */
								 INPUT p-cod-agencia,		 /*Agencia*/
								 INPUT p-nro-caixa, 		 /*Caixa*/
								 INPUT p-cod-operador,		 /*Operador*/
								 INPUT crapdat.dtmvtocd,	 /* Data Movimento */
								 INPUT "b1crap74",		     /* Nomte da Tela */
								 INPUT  2,					 /* Caixa online */
								 INPUT p-nro-conta, 		 /* Numero da Conta */
								 INPUT p-nrdocto,		     /* Numero do documento */
								 OUTPUT 0,
								 OUTPUT ""). 
								
		/* Fechar o procedimento para buscarmos o resultado */ 
		CLOSE STORED-PROC pc_estorno_tarifa_saque
			aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
		{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

	IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
       RUN sistema/generico/procedures/b1wgen0200.p PERSISTENT SET h-b1wgen0200.
                  
    RUN estorna_lancamento_conta IN h-b1wgen0200 
      (INPUT craplcm.cdcooper               /* par_cdcooper */
      ,INPUT craplcm.dtmvtolt               /* par_dtmvtolt */
      ,INPUT craplcm.cdagenci               /* par_cdagenci*/
      ,INPUT craplcm.cdbccxlt               /* par_cdbccxlt */
      ,INPUT craplcm.nrdolote               /* par_nrdolote */
      ,INPUT craplcm.nrdctabb               /* par_nrdctabb */
      ,INPUT craplcm.nrdocmto               /* par_nrdocmto */
      ,INPUT craplcm.cdhistor               /* par_cdhistor */
      ,INPUT craplcm.nrctachq               /* PAR_nrctachq */
      ,INPUT craplcm.nrdconta               /* PAR_nrdconta */
      ,INPUT craplcm.cdpesqbb               /* PAR_cdpesqbb */
      ,OUTPUT aux_cdcritic                  /* Codigo da critica                             */
      ,OUTPUT aux_dscritic).                /* Descricao da critica                          */
                
    IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
       DO: 
           /* Tratamento de erros conforme anteriores */
           ASSIGN i-cod-erro  = aux_cdcritic
                  c-desc-erro = aux_dscritic.
                      
           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
       END.   
                
    IF  VALID-HANDLE(h-b1wgen0200) THEN
      DELETE PROCEDURE h-b1wgen0200.
   
    
    FIND craplcm WHERE craplcm.cdcooper = INT(p-cooper)  AND
                       craplcm.cdagenci = p-cod-agencia     AND
                       craplcm.cdbccxlt = 100               AND 
                       craplcm.nrdconta = p-nro-conta       AND
                       craplcm.cdhistor = 2720              AND
                       craplcm.vllanmto = p-valor           AND
                       craplcm.nrdocmto = 1  USE-INDEX craplcm1
                       NO-ERROR NO-WAIT.
                       
    IF AVAILABLE craplcm THEN 
    DO:
    
        IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
           RUN sistema/generico/procedures/b1wgen0200.p PERSISTENT SET h-b1wgen0200.
                      
        RUN pc_estorna_saque_conta_prej IN h-b1wgen0200 
          (INPUT craplcm.cdcooper               /* par_cdcooper */
          ,INPUT craplcm.dtmvtolt               /* par_dtmvtolt */
          ,INPUT craplcm.cdagenci               /* par_cdagenci*/
          ,INPUT craplcm.cdbccxlt               /* par_cdbccxlt */
          ,INPUT craplcm.nrdctabb               /* par_nrdctabb */
          ,INPUT craplcm.nrdocmto               /* par_nrdocmto */
          ,INPUT craplcm.cdhistor               /* par_cdhistor */
          ,INPUT craplcm.nrdconta               /* PAR_nrdconta */
          ,INPUT craplcm.nrseqdig               /* PAR_nrseqdig */
          ,INPUT craplcm.vllanmto               /* PAR_vllanmto */
          ,OUTPUT aux_cdcritic                  /* Codigo da critica                             */
          ,OUTPUT aux_dscritic).
     
        IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
        DO: 
           /* Tratamento de erros conforme anteriores */
           ASSIGN i-cod-erro  = aux_cdcritic
                  c-desc-erro = aux_dscritic.
                      
           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
        END.   
                
    IF VALID-HANDLE(h-b1wgen0200) THEN
       DELETE PROCEDURE h-b1wgen0200.               /* Descricao da critica                          */
        
    END.

   /* Remocao lotes
   IF  craplot.vlcompdb = 0 and
       craplot.vlinfodb = 0 and
       craplot.vlcompcr = 0 and
       craplot.vlinfocr = 0 THEN
       DELETE craplot.
   ELSE
      RELEASE craplot.
   */

   RETURN "OK".
END PROCEDURE.


/* b1crap74.p */
