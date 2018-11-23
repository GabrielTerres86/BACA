/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | includes/crps663.i              | pc_crps663 / cnso0001 (package)   |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 11/MAI/2018 DEVERAH
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - TEOBALDO JAMUNDA    (AMcom)
   
   OBS.: As rotinas foram mantidas devido serem utilizadas pelo
         programa "debcns.p" (tela, execucao manual).
   
*******************************************************************************/

/*.............................................................................

   Programa: includes/crps663.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas R.
   Data    : Julho/2013                       Ultima atualizacao: 06/07/2018

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Procedimentos para o debito de agendamentos de consorcios. 

   Alteracoes: 05/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO) 
                            
               15/01/2014 - Correcoes e melhorias conforme softdesk 121162
                            (Carlos).
                            
               23/06/2014 - Ajustado cria-crapndb para buscar craplau.cdseqtel
                            (Lucas R.) 
                            
               07/11/2014 - Retirado as declaracoes de variaveis da includes 
                            crps663.i e declarado aqui na debcns.p para evitar 
                            problemas de imcompatibilidade na hora de usar a 
                            includes, alteracoes referentes a automatizacao da 
                            DEBCNS (Tiago SD199974).

               19/11/2015 - Ajustado para que a procedure efetua-debito-consorcio
                            utilize a obtem-saldo-dia convertida em Oracle.
                            (Douglas - Chamado 285228)
                            
               25/11/2015 - Incluida procedure gera_log_execucao_663 para gerar
                            log quando debcns for executada manualmente
                            (Tiago SD338533).

               24/10/2016 - Ajustes para que tenha uma terceira execucao
                            da DEBCNS - Melhoria349 (Tiago/Elton).
                            
               23/10/2017 - Ajustes para lançamentos duplicados e tambem para que 
                            tenhamos uma execucao matutina (Lucas Ranghetti #739738)
                            
               29/01/2018 - Ajustar DEBCNS conforme solicitaçao do chamado (Lucas Ranghetti #837834) 
                           
               21/02/2018 - Ajustar relatorio e gravar critica na lau caso 
                            tenha alguma (Lucas Ranghetti #852207)
							
               11/05/2018 - Migracao Progress --> Oracle 
                            (Teobaldo J., AMcom - Projeto Debito Unico)	  

               06/07/2018 - PJ450 Regulatório de Credito - Substituido o create na craplcm pela chamada 
                            da rotina gerar_lancamento_conta_comple. (Josiane Stiehler - AMcom)
							
.............................................................................*/

/****************************************************************************/
/******* faz a busca de consorcios nao debitados no processo noturno ********/
/****************************************************************************/

{ sistema/generico/includes/b1wgen0200tt.i }

DEF VAR aux_nrcrcard AS DECIMAL                                       NO-UNDO.

/* Variáveis de uso da BO 200 */
DEF VAR h-b1wgen0200 AS HANDLE                                          NO-UNDO.
DEF VAR aux_incrineg AS INT                                             NO-UNDO.

PROCEDURE obtem-consorcio:
         
     IF  glb_inproces = 1  THEN
         ASSIGN aux_dtrefere = glb_dtmvtolt.
     ELSE
         ASSIGN aux_dtrefere = glb_dtmvtopr.
         

     FOR EACH craplau WHERE craplau.cdcooper = crapcop.cdcooper AND
                            craplau.dtmvtopg = aux_dtrefere     AND
                           (craplau.cdhistor = 1230             OR 
                            craplau.cdhistor = 1231             OR
                            craplau.cdhistor = 1232             OR 
                            craplau.cdhistor = 1233             OR 
                            craplau.cdhistor = 1234)            AND
                            insitlau = 1 
                            NO-LOCK: 

         CASE craplau.cdhistor:
              WHEN 1230 THEN ASSIGN aux_tpconsor = 1.
              WHEN 1231 THEN ASSIGN aux_tpconsor = 2.
              WHEN 1232 THEN ASSIGN aux_tpconsor = 3.
              WHEN 1233 THEN ASSIGN aux_tpconsor = 4.
              WHEN 1234 THEN ASSIGN aux_tpconsor = 5.
         END CASE.

         /* nrdocmto com 22 posicoes - joga como string para poder dar o
            substr corretamente logo abaixo */
         IF  craplau.nrcrcard <> 0 THEN
             aux_nrdoc = STRING(craplau.nrcrcard,"9999999999999999999999").
         ELSE
         aux_nrdoc = STRING(craplau.nrdocmto,"9999999999999999999999").
         
         FOR EACH crapcns WHERE crapcns.cdcooper = craplau.cdcooper      AND
                                crapcns.tpconsor = aux_tpconsor          AND
                                crapcns.nrdconta = craplau.nrdconta      AND
                                crapcns.nrctrato = DEC(SUBSTR(aux_nrdoc,1,8))
                                NO-LOCK:

             CREATE tt-obtem-consorcio.
             ASSIGN tt-obtem-consorcio.nrdconta = crapcns.nrdconta
                    tt-obtem-consorcio.nrcotcns = crapcns.nrcotcns
                    tt-obtem-consorcio.qtparcns = crapcns.qtparcns
                    tt-obtem-consorcio.vlrcarta = crapcns.vlrcarta
                    tt-obtem-consorcio.vlparcns = craplau.vllanaut
                    tt-obtem-consorcio.nrctacns = crapcns.nrctacns
                    tt-obtem-consorcio.dscooper = CAPS(crapcop.nmrescop)
                    tt-obtem-consorcio.cdcooper = crapcns.cdcooper
                    tt-obtem-consorcio.fldebito = TRUE
                    tt-obtem-consorcio.nrdocmto = craplau.nrdocmto
                    tt-obtem-consorcio.nrdgrupo = crapcns.nrdgrupo
                    tt-obtem-consorcio.nrctrato = crapcns.nrctrato
                    tt-obtem-consorcio.tpconsor = crapcns.tpconsor.
     
             /*** busca tipo de consorcio ***/
             CASE crapcns.tpconsor:
                 WHEN 1 THEN ASSIGN tt-obtem-consorcio.dsconsor = "MOTO".
                 WHEN 2 THEN ASSIGN tt-obtem-consorcio.dsconsor = "AUTO".
                 WHEN 3 THEN ASSIGN tt-obtem-consorcio.dsconsor = "PESADOS".
                 WHEN 4 THEN ASSIGN tt-obtem-consorcio.dsconsor = "IMOVEIS".
                 WHEN 5 THEN ASSIGN tt-obtem-consorcio.dsconsor = "SERVICOS".
             END CASE.
     
             FIND FIRST crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                                      crapass.nrdconta = crapcns.nrdconta
                                      NO-LOCK NO-ERROR.
     
             IF  NOT AVAILABLE crapass  THEN
                 DO:
                    ASSIGN glb_cdcritic = 9.
                    RUN fontes/critic.p.
                    ASSIGN glb_cdcritic = 0.
                    
                    RETURN "NOK".
                 END.
             ELSE
                 ASSIGN tt-obtem-consorcio.nmprimtl = crapass.nmprimtl
                        tt-obtem-consorcio.cdagenci = crapass.cdagenci.
             END.
                 
         END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE efetua-debito-consorcio:

    DEF INPUT PARAM par_flmanual AS LOGICAL NO-UNDO.
    DEF INPUT PARAM par_nrseqexe AS INTEGER NO-UNDO.

    DEF VAR aux_cdcritic AS INTE    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR    NO-UNDO.
    DEF VAR aux_mudalote AS LOGICAL NO-UNDO. 
	DEF VAR aux_dscampos AS CHAR NO-UNDO.

    IF  glb_inproces = 1  THEN
         ASSIGN aux_dtrefere = glb_dtmvtolt.
     ELSE
         ASSIGN aux_dtrefere = glb_dtmvtopr.

    TRANS_1:
    
    FOR EACH tt-obtem-consorcio EXCLUSIVE-LOCK 
        BREAK BY tt-obtem-consorcio.cdcooper 
              BY tt-obtem-consorcio.tpconsor:  
                   
        IF  FIRST-OF(tt-obtem-consorcio.cdcooper) AND par_flmanual THEN
            DO:
                RUN gera_log_execucao_663(INPUT "DEBCNS",
                                      INPUT "Inicio execucao",
                                      INPUT tt-obtem-consorcio.cdcooper,
                                      INPUT "").
            END.
                    
        IF FIRST (tt-obtem-consorcio.cdcooper) THEN
            DO:
                FIND LAST craplot WHERE craplot.cdcooper = tt-obtem-consorcio.cdcooper AND 
                                        craplot.dtmvtolt = aux_dtrefere                AND
                                        craplot.nrdolote > 6500                        AND
                                        craplot.nrdolote < 6600                        AND
                                        craplot.tplotmov = 1             
                                        NO-LOCK NO-ERROR NO-WAIT.
    
                IF  NOT AVAILABLE craplot   THEN
                    ASSIGN aux_nrdolot1 = 6500.        
                ELSE
                    ASSIGN aux_nrdolot1 = craplot.nrdolote.
            END.
    
        /* Somar o lote somente quando mudar o historico */
        IF  FIRST-OF(tt-obtem-consorcio.tpconsor) THEN
            ASSIGN aux_mudalote = TRUE.
        ELSE
            ASSIGN aux_mudalote = FALSE.
    
        FOR EACH craplau WHERE craplau.cdcooper = tt-obtem-consorcio.cdcooper AND 
                               craplau.dtmvtopg = aux_dtrefere                AND
                               craplau.nrdconta = tt-obtem-consorcio.nrdconta AND 
                               craplau.nrdocmto = tt-obtem-consorcio.nrdocmto AND 
                              (craplau.cdhistor = 1230                        OR 
                               craplau.cdhistor = 1231                        OR
                               craplau.cdhistor = 1232                        OR 
                               craplau.cdhistor = 1233                        OR 
                               craplau.cdhistor = 1234)                       AND
                               craplau.insitlau = 1 
                               EXCLUSIVE-LOCK
                               BREAK BY craplau.cdagenci
                                     BY craplau.cdbccxlt 
                                     BY craplau.cdbccxpg 
                                     BY craplau.cdhistor
                                     BY craplau.nrdocmto
                               TRANSACTION ON ERROR UNDO TRANS_1, RETURN:
    
                                            
            ASSIGN  flg_ctamigra = FALSE
                    aux_flgentra = FALSE
                    aux_cdcooper = glb_cdcooper
                    aux_cdagenci = craplau.cdagenci
                    aux_nrdolote = aux_nrdolot1
                    aux_cdbccxlt = IF craplau.cdbccxlt = 911 THEN 11
                                   ELSE craplau.cdbccxlt
                    aux_nrdconta = craplau.nrdconta
                    glb_cdcritic = 0
                    glb_dscritic = "". 
                    
            IF  aux_mudalote THEN
            ASSIGN aux_nrdolote = aux_nrdolot1 + 1. 
            
            DO  WHILE TRUE:
                
                FIND craplot WHERE craplot.cdcooper = craplau.cdcooper AND
                                   craplot.dtmvtolt = aux_dtrefere     AND
                                   craplot.cdagenci = aux_cdagenci     AND
                                   craplot.cdbccxlt = aux_cdbccxlt     AND
                                   craplot.nrdolote = aux_nrdolote 
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                
                IF  NOT AVAILABLE craplot THEN
                    IF  LOCKED craplot   THEN
                        DO:
                            PAUSE 2 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            CREATE craplot.
                            ASSIGN craplot.dtmvtolt = aux_dtrefere
                                   craplot.cdagenci = aux_cdagenci
                                   craplot.cdbccxlt = aux_cdbccxlt 
                                   craplot.nrdolote = aux_nrdolote      
                                   craplot.cdbccxpg = 11
                                   craplot.tplotmov = 1
                                   craplot.cdcooper = craplau.cdcooper.
                            VALIDATE craplot.
                        END.
                LEAVE.
    
            END.  /*  Fim do DO WHILE TRUE  */
            
            IF  flg_ctamigra THEN
                ASSIGN aux_nrdolot2 = aux_nrdolote.
            ELSE
                ASSIGN aux_nrdolot1 = aux_nrdolote.
                    
             /* Apos 22/08/2017 buscaremos do nrcrcard que esta armazenando a referencia 
                original no crps647 */
            IF  craplau.nrcrcard <> 0 THEN
                ASSIGN aux_nrcrcard = craplau.nrcrcard.
            ELSE
                ASSIGN aux_nrcrcard = craplau.nrdocmto.  
                    
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

            /* Utilizar o tipo de busca A, para carregar do dia anterior
              (U=Nao usa data, I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1) */ 
            RUN STORED-PROCEDURE pc_obtem_saldo_dia_prog
                aux_handproc = PROC-HANDLE NO-ERROR
                                        (INPUT craplau.cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT 1, /* nrdcaixa */
                                         INPUT glb_cdoperad, 
                                         INPUT craplau.nrdconta,
                                         INPUT aux_dtrefere,
                                         INPUT "A", /* Tipo Busca */
                                         OUTPUT 0,
                                         OUTPUT "").

            CLOSE STORED-PROC pc_obtem_saldo_dia_prog
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
            
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = ""
                   aux_cdcritic = pc_obtem_saldo_dia_prog.pr_cdcritic 
                                      WHEN pc_obtem_saldo_dia_prog.pr_cdcritic <> ?
                   aux_dscritic = pc_obtem_saldo_dia_prog.pr_dscritic
                                      WHEN pc_obtem_saldo_dia_prog.pr_dscritic <> ?. 
                
            IF  aux_cdcritic <> 0  OR 
               aux_dscritic <> "" THEN
               DO: 
                   IF  aux_dscritic = "" THEN
                       ASSIGN aux_dscritic =  "Nao foi possivel carregar os saldos.".

                   ASSIGN glb_dscritic = aux_dscritic.

                   IF  par_nrseqexe = 3 THEN /* Ultima execucao dia */
                   RUN cria-crapndb.
                   ELSE
                       ASSIGN tt-obtem-consorcio.fldebito = FALSE
                              tt-obtem-consorcio.dscritic = glb_dscritic.

                   NEXT.
               END.

            /* cria lancamento apenas se saldo em CC for maior que zero */
            FIND FIRST wt_saldos NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE wt_saldos  THEN
            DO:
                ASSIGN glb_dscritic = "Nao foi possivel consultar saldo para " +
                                      "operacao.".
                    
                    IF  par_nrseqexe = 3 THEN /* Ultima execucao dia */
                RUN cria-crapndb.
                    ELSE
                        ASSIGN tt-obtem-consorcio.fldebito = FALSE
                               tt-obtem-consorcio.dscritic = glb_dscritic.
    
                NEXT.
            END.

            ASSIGN aux_nrdocmto = craplau.nrdocmto.

            FIND FIRST crapass WHERE crapass.cdcooper = craplau.cdcooper
                                 AND crapass.nrdconta = craplau.nrdconta
                                 NO-LOCK NO-ERROR.
                                 
            IF  NOT AVAILABLE crapass THEN
                DO: 
                    ASSIGN glb_cdcritic = 9
                           glb_dscritic = "Associado nao cadastrado.".
                
                    IF  par_nrseqexe = 3 THEN /* Ultima execucao dia */
                        RUN cria-crapndb.
                    ELSE
                        ASSIGN tt-obtem-consorcio.fldebito = FALSE
                               tt-obtem-consorcio.dscritic = glb_dscritic.
                END.
            ELSE
            IF  crapass.dtdemiss <> ?  THEN
                DO:
                    ASSIGN glb_cdcritic = 454
                           glb_dscritic = "Cooperado foi demitido.".
                
                    IF  par_nrseqexe = 3 THEN /* Ultima execucao dia */
                        RUN cria-crapndb.
                    ELSE
                        ASSIGN tt-obtem-consorcio.fldebito = FALSE
                               tt-obtem-consorcio.dscritic = glb_dscritic.
                END.
            ELSE 
            IF  crapass.cdsitdct = 2 OR 
                crapass.cdsitdct = 3 OR 
                crapass.cdsitdct = 4 THEN
                DO: 
                     ASSIGN glb_cdcritic = 64
                            glb_dscritic = "Conta encerrada.".
                     
                     IF  par_nrseqexe = 3 THEN /* Ultima execucao dia */
                         RUN cria-crapndb.
                     ELSE
                         ASSIGN tt-obtem-consorcio.fldebito = FALSE
                                tt-obtem-consorcio.dscritic = glb_dscritic.
                END.
            ELSE 
            IF  crapass.dtelimin <> ? THEN
                DO:
                    ASSIGN glb_cdcritic = 410
                           glb_dscritic = "Associado excluido.".
                
                    IF  par_nrseqexe = 3 THEN /* Ultima execucao dia */
                        RUN cria-crapndb.
                    ELSE
                        ASSIGN tt-obtem-consorcio.fldebito = FALSE
                               tt-obtem-consorcio.dscritic = glb_dscritic.
                END.
            ELSE 
            IF  craplau.vllanaut > (wt_saldos.vlsddisp + wt_saldos.vllimcre) THEN 
                DO: 
                    ASSIGN glb_dscritic = "Nao ha saldo suficiente para a operacao."
                           glb_cdcritic = 717.
    
                    IF  par_nrseqexe = 3 THEN /* Ultima execucao dia */
                    RUN cria-crapndb.
                    ELSE
                        ASSIGN tt-obtem-consorcio.fldebito = FALSE
                               tt-obtem-consorcio.dscritic = glb_dscritic.
                END.
            ELSE                          
                DO:
                    DO WHILE TRUE:
            
                        IF  CAN-FIND(craplcm WHERE 
                                craplcm.cdcooper = craplau.cdcooper AND
                                craplcm.dtmvtolt = aux_dtrefere     AND
                                craplcm.cdagenci = craplot.cdagenci AND
                                craplcm.cdbccxlt = craplot.cdbccxlt AND
                                craplcm.nrdolote = craplot.nrdolote AND
                                craplcm.nrdctabb = aux_nrdconta     AND
                                craplcm.nrdocmto = aux_nrdocmto
                                USE-INDEX craplcm1)     THEN
                        DO:
                            aux_nrdocmto = aux_nrdocmto + 100000000.
                            NEXT.
                        END.
                       
                        LEAVE.
    
                    END.  /*  Fim do DO WHILE TRUE  */
                
                    /* PJ450 - Regulatorio de crédito */
                    IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
                        RUN sistema/generico/procedures/b1wgen0200.p 
                        PERSISTENT SET h-b1wgen0200.
                                    
                    /*  Cria lancamento da conta do associado ................................ */ 
                    RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
                          (INPUT craplot.dtmvtolt               /* par_dtmvtolt */
                          ,INPUT craplot.cdagenci               /* par_cdagenci */
                          ,INPUT craplot.cdbccxlt               /* par_cdbccxlt */
                          ,INPUT craplot.nrdolote               /* par_nrdolote */
                          ,INPUT aux_nrdconta                   /* par_nrdconta */
                          ,INPUT aux_nrdocmto                   /* par_nrdocmto */
                          ,INPUT craplau.cdhistor               /* par_cdhistor */
                          ,INPUT craplot.nrseqdig + 1           /* par_nrseqdig */
                          ,INPUT craplau.vllanaut               /* par_vllanmto */
                          ,INPUT craplau.nrdctabb               /* par_nrdctabb */
                          ,INPUT "Lote " + 
                                              STRING(DAY(craplau.dtmvtolt),"99")      +
                                              "/"                                     +
                                              STRING(MONTH(craplau.dtmvtolt),"99")    +
                                              "-"                                     +
                                              STRING(aux_cdagenci,"999") + "-"        +
                                              STRING(craplau.cdbccxlt,"999") + "-"    +
                                              STRING(craplau.nrdolote,"999999") + "-" +
                                              STRING(craplau.nrseqdig,"99999") + "-"  +
                                        STRING(aux_nrcrcard)    /* par_cdpesqbb */
                          ,INPUT 0                              /* par_vldoipmf */
                          ,INPUT 0                              /* par_nrautdoc */
                          ,INPUT 0                              /* par_nrsequni */
                          ,INPUT 0                              /* par_cdbanchq */
                          ,INPUT 0                              /* par_cdcmpchq */
                          ,INPUT 0                              /* par_cdagechq */
                          ,INPUT 0                              /* par_nrctachq */
                          ,INPUT 0                              /* par_nrlotchq */
                          ,INPUT 0                              /* par_sqlotchq */
                          ,INPUT ""                             /* par_dtrefere */
                          ,INPUT TIME                           /* par_hrtransa */
                          ,INPUT ""                             /* par_cdoperad */
                          ,INPUT ""                             /* par_dsidenti */
                          ,INPUT craplau.cdcooper               /* par_cdcooper */
                          ,INPUT STRING(craplau.nrdctabb,"99999999") /* par_nrdctitg */
                          ,INPUT ""                             /* par_dscedent */
                          ,INPUT 0                              /* par_cdcoptfn */
                          ,INPUT 0                              /* par_cdagetfn */
                          ,INPUT 0                              /* par_nrterfin */
                          ,INPUT 0                              /* par_nrparepr */
                          ,INPUT 0                              /* par_nrseqava */
                          ,INPUT 0                              /* par_nraplica */
                          ,INPUT 0                              /* par_cdorigem */
                          ,INPUT 0                              /* par_idlautom */
                          /* CAMPOS OPCIONAIS DO LOTE                                                            */ 
                          ,INPUT 0                              /* Processa lote                                 */
                          ,INPUT 0                              /* Tipo de lote a movimentar                     */
                          /* CAMPOS DE SAÍDA                                                                     */                                            
                          ,OUTPUT TABLE tt-ret-lancto           /* Collection que contém o retorno do lançamento */
                          ,OUTPUT aux_incrineg                  /* Indicador de crítica de negócio               */
                          ,OUTPUT aux_cdcritic                  /* Código da crítica                             */
                          ,OUTPUT aux_dscritic).                /* Descriçao da crítica                          */
                          
                    IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                       DO: 
                         ASSIGN glb_cdcritic = aux_cdcritic
                                glb_dscritic = aux_dscritic.
                         IF  par_nrseqexe = 3 THEN /* Ultima execucao dia */
                             RUN cria-crapndb.
                         ELSE
                             ASSIGN tt-obtem-consorcio.fldebito = FALSE
                                    tt-obtem-consorcio.dscritic = glb_dscritic.
                       END.
                    ELSE 
                       DO:
                          /* 27/06/2018- Posicionando no registro da craplcm criado acima */
                          FIND FIRST tt-ret-lancto.
                          FIND FIRST craplcm WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm NO-ERROR.
                       END.

                    IF  VALID-HANDLE(h-b1wgen0200) THEN
                        DELETE PROCEDURE h-b1wgen0200.                
                  
                    ASSIGN craplot.qtcompln = craplot.qtcompln + 1
                           craplot.vlcompdb = craplot.vlcompdb + craplau.vllanaut
                           craplot.qtinfoln = craplot.qtinfoln + 1
                           craplot.vlinfodb = craplot.vlinfodb + craplau.vllanaut
                           craplot.nrseqdig = craplcm.nrseqdig
                           
                           craplau.insitlau = 2
                           craplau.nrseqlan = craplcm.nrseqdig
                           craplau.dtdebito = aux_dtrefere
                           craplau.dsorigem = "DEBCNS".

                  /* inicio NOTIF */
                   aux_dscampos = "#valordebito=" + STRING(craplau.vllanaut,"zzz,zz9.99") + ";#datadebito=" + STRING(aux_dtrefere,"99/99/9999") +
                                  ";#tipodebito=" + craplau.dscedent.
                                  
                  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                  
                  /* Efetuar a chamada a rotina Oracle */ 
                   RUN STORED-PROCEDURE pc_cria_notif_prgs
                   aux_handproc = PROC-HANDLE NO-ERROR 
                        ( INPUT 10                /* pr_cdorigem_mensagem  */
                         ,INPUT 1                 /* pr_cdmotivo_mensagem  */
                         ,INPUT TODAY             /* pr_dhenvio  */
                         ,INPUT craplau.cdcooper  /* pr_cdcooper  */
                         ,INPUT aux_nrdconta      /* pr_nrdconta  */
                         ,INPUT 0                 /* pr_idseqttl  */
                         ,INPUT aux_dscampos ).   /* pr_variaveis  */
                                    
                  /* Fechar o procedimento para buscarmos o resultado */ 
                   CLOSE STORED-PROC pc_cria_notif_prgs
                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                           
                   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
                  /* fim NOTIF */   
				                 
                END. /* fim else */
                
                /* Para aparecer na debcon devemos gravar a critica 717 */
                IF  glb_cdcritic <> 0 THEN
                    ASSIGN craplau.cdcritic = glb_cdcritic.
        END. /* fim for each craplau */

        IF  LAST-OF(tt-obtem-consorcio.cdcooper) AND par_flmanual THEN
            DO:
                RUN gera_log_execucao_663(INPUT "DEBCNS",
                                      INPUT "Fim execucao",
                                      INPUT tt-obtem-consorcio.cdcooper,
                                      INPUT "").                        
            END.          

    END. /* fim for each tt-obtem-consorcio */

    RETURN "OK".

END PROCEDURE.

PROCEDURE imprime-consorcios:
    
    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.

    DEF VAR aux_cddopcao AS LOGICAL FORMAT "S/N"                       NO-UNDO.
    DEF VAR aux_registro AS LOG     INIT NO                            NO-UNDO.
    
    FIND FIRST tt-obtem-consorcio WHERE 
               par_cdcooper = 0   OR 
               tt-obtem-consorcio.cdcooper = par_cdcooper 
               NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL tt-obtem-consorcio THEN
        RETURN.
    
    IF  glb_inproces = 1  THEN
        ASSIGN aux_dtrefere = glb_dtmvtolt.
    ELSE
        ASSIGN aux_dtrefere = glb_dtmvtopr.
                             
    { includes/cabrel234_1.i }

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 62.
        
    VIEW STREAM str_1 FRAME f_cabrel234_1.
 
    FOR EACH tt-obtem-consorcio WHERE 
             par_cdcooper = 0   OR 
             tt-obtem-consorcio.cdcooper = crapcop.cdcooper
             NO-LOCK BREAK BY tt-obtem-consorcio.cdcooper
                           BY tt-obtem-consorcio.fldebito
                           BY tt-obtem-consorcio.cdagenci
                           BY tt-obtem-consorcio.nrdconta 
                           BY tt-obtem-consorcio.dsconsor 
                           BY tt-obtem-consorcio.nrcotcns 
                           BY tt-obtem-consorcio.qtparcns 
                           BY tt-obtem-consorcio.vlrcarta 
                           BY tt-obtem-consorcio.vlparcns:
        
        ASSIGN aux_registro = YES.
       
        FIND FIRST crapcop WHERE 
                   crapcop.cdcooper = tt-obtem-consorcio.cdcooper 
                   NO-LOCK NO-ERROR.

        IF  AVAIL crapcop THEN
            ASSIGN aux_dscooper = CAPS(crapcop.nmrescop).

        IF  FIRST-OF(tt-obtem-consorcio.cdcooper) THEN
            DO:
                ASSIGN aux_qtefetua = 0
                       aux_vlefetua = 0.
                
                ASSIGN aux_dstiptra = "CONSORCIOS".

                DISP STREAM str_1 aux_dstiptra
                                  aux_dscooper WITH FRAME f_transacao1.

            END.
  
        IF  FIRST-OF(tt-obtem-consorcio.fldebito) THEN
            DO:
                
                ASSIGN aux_dstitulo = IF tt-obtem-consorcio.fldebito THEN
                                         " EFETUADOS "
                                      ELSE
                                          "NAO EFETUADOS ".
                DISP STREAM str_1 aux_dtrefere aux_dstitulo
                     WITH FRAME f_titulo.
                   
                IF tt-obtem-consorcio.fldebito THEN
                   VIEW STREAM str_1 FRAME f_transacao.
                ELSE 
                VIEW STREAM str_1 FRAME f_transacao2.
           END. 

         
        ASSIGN aux_qtefetua = aux_qtefetua + 1
               aux_vlefetua = aux_vlefetua + tt-obtem-consorcio.vlparcns.
        
        IF  tt-obtem-consorcio.fldebito  THEN
            DO:                               
                DISP STREAM str_1 tt-obtem-consorcio.cdagenci
                                  tt-obtem-consorcio.nrdconta
                                  tt-obtem-consorcio.nrdocmto
                                  tt-obtem-consorcio.nrctacns
                                  tt-obtem-consorcio.nmprimtl               
                                  tt-obtem-consorcio.dsconsor
                                  tt-obtem-consorcio.nrdgrupo
                                  tt-obtem-consorcio.nrcotcns
                                  tt-obtem-consorcio.vlparcns
                                  WITH FRAME f_efetuados.
                                  
                DOWN STREAM str_1 WITH FRAME f_efetuados.   
            END.
        ELSE
            DO:
                DISP STREAM str_1 tt-obtem-consorcio.cdagenci
                                  tt-obtem-consorcio.nrdconta
                                  tt-obtem-consorcio.nrdocmto
                                  tt-obtem-consorcio.nrctacns
                                  tt-obtem-consorcio.nmprimtl               
                                  tt-obtem-consorcio.dsconsor
                                  tt-obtem-consorcio.nrdgrupo
                                  tt-obtem-consorcio.nrcotcns
                                  tt-obtem-consorcio.vlparcns
                                  tt-obtem-consorcio.dscritic
                                  WITH FRAME f_nao_efetuados.    

                DOWN STREAM str_1 WITH FRAME f_nao_efetuados.
            END.

        IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1) THEN 
            DO:
                PAGE STREAM str_1.
        
                DISP STREAM str_1 aux_dstitulo 
                                  aux_dtrefere WITH FRAME f_titulo.
                
                IF  tt-obtem-consorcio.fldebito THEN
                    VIEW STREAM str_1 FRAME f_transacao.
                ELSE 
                    VIEW STREAM str_1 FRAME f_transacao2.
            END.
        
        IF  LAST-OF(tt-obtem-consorcio.cdcooper) THEN
            DISP STREAM str_1 aux_qtefetua aux_vlefetua
                 WITH FRAME f_total.
        
    END.

    OUTPUT STREAM str_1 CLOSE.

    IF  glb_inproces = 1  THEN
        DO: 
            UNIX SILENT VALUE("cp " + aux_nmarqimp + " " + aux_nmarquiv).
                     
            HIDE MESSAGE NO-PAUSE.
        END.

    ASSIGN glb_nrcopias = 1            
           glb_nmformul = "234dh"     
           glb_nmarqimp = aux_nmarqimp.

    IF  par_cdcooper = 0 THEN /* PROCESSO */
        DO:
            RUN fontes/imprim.p.               
        END.
    ELSE
        DO:
            RUN fontes/imprim_unif.p (INPUT par_cdcooper).    
        END.

    IF  aux_registro  THEN
        RETURN "OK".
    ELSE
        RETURN "NOK".

END PROCEDURE.

PROCEDURE cria-crapndb:

    IF  glb_cdcritic = 64 OR 
        glb_cdcritic = 9  OR  
        glb_cdcritic = 454 THEN
        ASSIGN aux_cdcritic = "15". /** Conta corrente invalida **/
    ELSE
    ASSIGN aux_cdcritic = "01". /** Insuficiencias de fundos **/
     
    FIND FIRST crapcop WHERE 
               crapcop.cdcooper = tt-obtem-consorcio.cdcooper 
               NO-LOCK NO-ERROR.
                             
    IF  AVAIL crapcop THEN                                     
        ASSIGN aux_nrctasic = STRING(crapcop.cdagesic,"9999").
    
    IF  glb_inproces = 1  THEN
        ASSIGN aux_dtrefere = glb_dtmvtolt.
    ELSE
        ASSIGN aux_dtrefere = glb_dtmvtopr.
    
    CREATE crapndb.
    ASSIGN crapndb.cdcooper = craplau.cdcooper
           crapndb.dtmvtolt = aux_dtrefere 
           crapndb.nrdconta = craplau.nrdconta
           crapndb.cdhistor = craplau.cdhistor
           crapndb.flgproce = FALSE.

    ASSIGN crapndb.dstexarq = "F"                              +
           STRING(aux_nrcrcard,"9999999999999999999999")       +
                  FILL(" ",3)                                  +
                  aux_nrctasic                                 +
                  STRING(tt-obtem-consorcio.nrctacns,"999999") +
                  FILL(" ",8)                                +
                  STRING(YEAR(aux_dtrefere),"9999")          +
                  STRING(MONTH(aux_dtrefere),"99")           +
                  STRING(DAY(aux_dtrefere),"99")             +
                  STRING(craplau.vllanaut * 100,       
                         "999999999999999")                  +
                         aux_cdcritic + STRING(craplau.cdseqtel,"x(60)") +
                  FILL(" ",16) +
                         STRING(aux_cdagenci,"99")           +
                  "J5"                                       + /* Codigo da empresa */
                  FILL(" ",8) + "0".
    
    ASSIGN craplau.insitlau = 3
           craplau.dtdebito = aux_dtrefere            
           tt-obtem-consorcio.fldebito = FALSE
           tt-obtem-consorcio.dscritic = glb_dscritic.
    VALIDATE crapndb.

END PROCEDURE.

PROCEDURE gera_log_execucao_663:

    DEF INPUT PARAM par_nmprgexe    AS  CHAR        NO-UNDO.
    DEF INPUT PARAM par_indexecu    AS  CHAR        NO-UNDO.
    DEF INPUT PARAM par_cdcooper    AS  INT         NO-UNDO.
    DEF INPUT PARAM par_tpexecuc    AS  CHAR        NO-UNDO.
    
    DEF VAR aux_nmarqlog            AS  CHAR        NO-UNDO.

    ASSIGN aux_nmarqlog = "log/prcctl_" + STRING(YEAR(glb_dtmvtolt),"9999") +
                          STRING(MONTH(glb_dtmvtolt),"99") +
                          STRING(DAY(glb_dtmvtolt),"99") + ".log".
    
    UNIX SILENT VALUE("echo " + "Manual - " + 
                      STRING(TIME,"HH:MM:SS") + "' --> '"  +
                      "Coop.:" + STRING(par_cdcooper) + " '" +  
                      par_tpexecuc + "' - '" + 
                      par_nmprgexe + "': " + 
                      par_indexecu +  
                      " >> " + aux_nmarqlog).

    RETURN "OK".  
END PROCEDURE.
