/* ..........................................................................

   Programa: Fontes/crps313.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Oni Junior
   Data    : Junho/2001.                       Ultima atualizacao: 20/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Cobrar tarifa referente aos debitos de INSS.

   Alteracoes: 24/08/2001 - Gerar aviso de debito no valor total que foi
                            debitado de cada conta corrente (Junior).
                            
               17/09/2004 - Se o valor da tarifa for zero, sair do programa
                            (Edson).

               30/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm e crapavs (Diego).
                            
               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder       
               
               20/01/2014 - Incluir VALIDATE crapavs,craplot,craplcm (Lucas R)
                            
               09/07/2018 - PRJ450 - Chamada de rotina para consistir lançamentos em conta 
                            corrente (LANC0001) na tabela CRAPLCM  (Teobaldo J. - AMcom)
                            
               06/08/2018 - PJ450 - TRatamento do nao pode debitar, crítica de negócio, 
                            após chamada da rotina de geraçao de lançamento em CONTA CORRENTE
                            (Renato Cordeiro - AMcom)

               06/08/2018 - PJ450 - TRatamento do nao pode debitar, crítica de negócio, 
                            após chamada da rotina de geraçao de lançamento em CONTA CORRENTE
                            (Renato Cordeiro - AMcom)

............................................................................ */

{ includes/var_batch.i } 
{ sistema/generico/includes/b1wgen0200tt.i }
{ sistema/generico/includes/var_oracle.i }

DEF BUFFER crablcm FOR craplcm.

DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_vltarifa AS DECI                                  NO-UNDO.
DEF        VAR tab_cdhistor AS INT                                   NO-UNDO.

DEF        VAR aux_vllanmto AS DECI                                  NO-UNDO.

/* Variaveis para rotina de lancamento craplcm */
DEF        VAR h-b1wgen0200 AS HANDLE  NO-UNDO.
DEF        VAR aux_incrineg AS INT     NO-UNDO.
DEF        VAR aux_cdcritic AS INT     NO-UNDO.
DEF        VAR aux_dscritic AS CHAR    NO-UNDO.
DEF        VAR aux_podedebi AS INT     NO-UNDO.

ASSIGN glb_cdprogra = "crps313".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

IF   glb_inrestar > 0   AND   glb_nrctares = 0   THEN
     glb_inrestar = 0.

/* Tabela que contem o historico a procurar no lcm */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "USUARI"      AND
                   craptab.cdempres = 00            AND
                   craptab.cdacesso = "VLTARIF040"  AND
                   craptab.tpregist = 1             NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 55.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                            glb_cdprogra + "' --> '" + glb_dscritic +
                            " CRED-USUARI-00-VLTARIF040-001 " +
                           " >> log/proc_batch.log").
         RETURN.
     END.

aux_vltarifa = DECIMAL(craptab.dstextab).

IF   aux_vltarifa = 0   THEN     
     DO:
         RUN fontes/fimprg.p.

         RETURN.
     END.

TRANS_1:

FOR EACH crablcm WHERE crablcm.cdcooper = glb_cdcooper  AND
                       crablcm.dtmvtolt = glb_dtmvtolt  AND
                       crablcm.nrdconta > glb_nrctares  AND
                       crablcm.cdhistor = 40 USE-INDEX craplcm4 NO-LOCK 
                       BREAK BY crablcm.nrdconta
                       TRANSACTION ON ERROR UNDO TRANS_1, RETURN:

    /* 09/07/2018 - Incluida condicao que verifica se pode realizar o debito */
    IF NOT VALID-HANDLE(h-b1wgen0200) THEN
       RUN sistema/generico/procedures/b1wgen0200.p 
       PERSISTENT SET h-b1wgen0200.

    aux_vllanmto = aux_vllanmto + aux_vltarifa.
         
    IF   LAST-OF(crablcm.nrdconta) THEN
         DO:
             IF   aux_vllanmto = 0 THEN
                  NEXT.
                  
             DO WHILE TRUE:

                FIND craplot WHERE craplot.cdcooper = glb_cdcooper  AND
                                   craplot.dtmvtolt = glb_dtmvtolt  AND
                                   craplot.cdagenci = 1             AND  
                                   craplot.cdbccxlt = 100           AND
                                   craplot.nrdolote = 8452        
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF   NOT AVAILABLE craplot   THEN
                     IF   LOCKED craplot   THEN
                          DO:
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                          END.
                     ELSE
                          DO:
                              CREATE craplot.
                              ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                                     craplot.cdagenci = 1 
                                     craplot.cdbccxlt = 100
                                     craplot.nrdolote = 8452
                                     craplot.tplotmov = 1
                                     craplot.cdcooper = glb_cdcooper.
                          END.

                LEAVE.

             END.  /*  Fim do DO WHILE TRUE  */

             /* BLOCO DA INSERÇAO DA CRAPLCM */
             RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
                (INPUT craplot.dtmvtolt                      /* par_dtmvtolt */ 
                ,INPUT craplot.cdagenci                      /* par_cdagenci */ 
                ,INPUT craplot.cdbccxlt                      /* par_cdbccxlt */ 
                ,INPUT craplot.nrdolote                      /* par_nrdolote */ 
                ,INPUT crablcm.nrdconta                      /* par_nrdconta */ 
                ,INPUT craplot.nrseqdig + 1                  /* par_nrdocmto */ 
                ,INPUT 380                                   /* par_cdhistor */ 
                ,INPUT craplot.nrseqdig + 1                  /* par_nrseqdig */ 
                ,INPUT aux_vllanmto                          /* par_vllanmto */ 
                ,INPUT crablcm.nrdconta                      /* par_nrdctabb */ 
                ,INPUT ""                                    /* par_cdpesqbb */
                ,INPUT 0                                     /* par_vldoipmf */
                ,INPUT 0                                     /* par_nrautdoc */ 
                ,INPUT 0                                     /* par_nrsequni */ 
                ,INPUT 0                            		     /* par_cdbanchq */
                ,INPUT 0                            		     /* par_cdcmpchq */
                ,INPUT 0                            		     /* par_cdagechq */
                ,INPUT 0                            		     /* par_nrctachq */
                ,INPUT 0                            		     /* par_nrlotchq */
                ,INPUT 0                            		     /* par_sqlotchq */
                ,INPUT ""                           		     /* par_dtrefere */ 
                ,INPUT ""                           		     /* par_hrtransa */
                ,INPUT ""                           		     /* par_cdoperad */                                
                ,INPUT ""                            		     /* par_dsidenti */
                ,INPUT glb_cdcooper                          /* par_cdcooper */ 
                ,INPUT STRING(crablcm.nrdconta,"99999999")   /* par_nrdctitg */ 
                ,INPUT ""                                    /* par_dscedent */
                ,INPUT 0                                     /* par_cdcoptfn */ 
                ,INPUT 0                                     /* par_cdagetfn */ 
                ,INPUT 0                                     /* par_nrterfin */ 
                ,INPUT 0                             	 	     /* par_nrparepr */
                ,INPUT 0                              	  	 /* par_nrseqava */
                ,INPUT 0                             		     /* par_nraplica */
                ,INPUT 0                             		     /* par_cdorigem */ 
                ,INPUT 0                             		     /* par_idlautom */
                /* CAMPOS OPCIONAIS DO LOTE                                                                   */
                ,INPUT 0                                     /* Processa lote                                 */
                ,INPUT 0                                     /* Tipo de lote a movimentar                     */
                /* CAMPOS DE SAIDA                                                                            */
                ,OUTPUT TABLE tt-ret-lancto                  /* Collection que contem o retorno do lancamento */
                ,OUTPUT aux_incrineg                         /* Indicador de critica de negocio               */
                ,OUTPUT aux_cdcritic                         /* Codigo da critica                             */
                ,OUTPUT aux_dscritic).                       /* Descricao da critica                          */             
             
             IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                IF aux_incrineg = 1 THEN
                DO:

                    /* Posicionando no registro da craplcm criado acima */
                    FIND FIRST tt-ret-lancto.
                    FIND FIRST craplcm WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm NO-ERROR.

                   /*Renato Cordeiro - Gera lançamento futuro quando nao pdoe debitar - INICIO*/
                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                    
                    RUN STORED-PROCEDURE pc_cria_lanc_futuro aux_handproc = PROC-HANDLE NO-ERROR
                    
                                         (INPUT glb_cdcooper,
                                          INPUT crablcm.nrdconta,
                                          INPUT STRING(crablcm.nrdconta,"99999999"),
                                          INPUT craplot.cdagenci,
                                          INPUT craplot.dtmvtolt,
                                          INPUT 380,
                                          INPUT aux_vllanmto,
                                          INPUT 0,    /*pr_nrctremp*/
                                          "BLQPREJU", /*pr_dsorigem*/
                                          OUTPUT "").
                    
                    CLOSE STORED-PROC pc_cria_lanc_futuro aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
                    
                    ASSIGN aux_dscritic = pc_cria_lanc_futuro.pr_dscritic
                                          WHEN pc_cria_lanc_futuro.pr_dscritic <> ?.
                           
                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                    
                    IF aux_dscritic <> "" THEN
                    DO:
                       ASSIGN glb_cdcritic = aux_cdcritic.
                       RUN fontes/critic.p.
                       UNIX SILENT VALUE ("echo " + 
                            STRING(TIME,"HH:MM:SS") +
                            " - " + glb_cdprogra + "' --> '" +
                            aux_dscritic + " Conta " +
                            STRING(crablcm.nrdconta) + " >> log/proc_batch.log").
                       UNDO TRANS_1, RETURN.
                    END.
                   /*Renato Cordeiro - Gera lançamento futuro quando nao pdoe debitar - FIM*/
                   END.
                
                ELSE
                DO: 
                    /* Tratamento de erro relativo banco de dados */
                    ASSIGN glb_cdcritic = aux_cdcritic.
                    RUN fontes/critic.p.
                    UNIX SILENT VALUE ("echo " + 
                         STRING(TIME,"HH:MM:SS") +
                         " - " + glb_cdprogra + "' --> '" +
                         aux_dscritic + " Conta " +
                         STRING(crablcm.nrdconta) + " >> log/proc_batch.log").
                    UNDO TRANS_1, RETURN.
                END.   
             ELSE 
                DO:
                  /* Posicionando no registro da craplcm criado acima */
                  FIND FIRST tt-ret-lancto.
                  FIND FIRST craplcm WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm NO-ERROR.
                END.                

 
             ASSIGN craplot.vlinfodb = craplot.vlinfodb + craplcm.vllanmto
                    craplot.vlcompdb = craplot.vlcompdb + craplcm.vllanmto
                    craplot.qtinfoln = craplot.qtinfoln + 1
                    craplot.qtcompln = craplot.qtcompln + 1
                    craplot.nrseqdig = craplot.nrseqdig + 1
                    aux_vllanmto = 0.
   
             VALIDATE craplot.

             FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                                crapass.nrdconta = crablcm.nrdconta
                                NO-LOCK NO-ERROR.
             
             IF   NOT AVAILABLE crapass   THEN
                  DO:
                      glb_cdcritic = 251.
                      RUN fontes/critic.p.
                      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                        " - " + glb_cdprogra + "' --> '" +
                                        glb_dscritic + " Conta " +
                                        STRING(crablcm.nrdconta) +
                                        " >> log/proc_batch.log").
                      RETURN.
                  END.
                       
             CREATE crapavs.
             ASSIGN crapavs.cdagenci = crapass.cdagenci
                    crapavs.cdempres = 0
                    crapavs.cdhistor = 380
                    crapavs.cdsecext = crapass.cdsecext
                    crapavs.dtdebito = glb_dtmvtolt
                    crapavs.dtmvtolt = glb_dtmvtolt
                    crapavs.dtrefere = glb_dtmvtolt
                    crapavs.insitavs = 0
                    crapavs.nrdconta = crapass.nrdconta
                    crapavs.nrdocmto = craplcm.nrdocmto
                    crapavs.nrseqdig = craplcm.nrseqdig
                    crapavs.tpdaviso = 2
                    crapavs.vldebito = 0
                    crapavs.vlestdif = 0
                    crapavs.vllanmto = craplcm.vllanmto
                    crapavs.flgproce = FALSE
                    crapavs.cdcooper = glb_cdcooper.
             
             VALIDATE crapavs.

             /* Cria registro de restart  */
             DO WHILE TRUE:

                FIND crapres WHERE crapres.cdcooper = glb_cdcooper  AND
                                   crapres.cdprogra = glb_cdprogra
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF   NOT AVAILABLE crapres   THEN
                     IF   LOCKED crapres   THEN
                          DO:
                             PAUSE 1 NO-MESSAGE.
                             NEXT.
                          END.
                     ELSE
                          DO:
                              glb_cdcritic = 151.
                              RUN fontes/critic.p.
                              UNIX SILENT VALUE ("echo " + 
                                   STRING(TIME,"HH:MM:SS") +
                                   " - " + glb_cdprogra + "' --> '" +
                                    glb_dscritic + " >> log/proc_batch.log").
                              UNDO TRANS_1, RETURN.
                          END.

                LEAVE.

             END.  /*  Fim do DO WHILE TRUE  */

             crapres.nrdconta = crablcm.nrdconta.
         END.

END.  /*  Fim do FOR EACH e da transacao  */

IF VALID-HANDLE(h-b1wgen0200) THEN
   DELETE PROCEDURE h-b1wgen0200.

RUN fontes/fimprg.p.

/* .......................................................................... */
