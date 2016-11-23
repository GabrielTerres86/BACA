/* ..........................................................................

   Programa: Fontes/crps097.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/94.                     Ultima atualizacao: 16/08/2016

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Efetuar o lote de devolucoes e taxas de devolucoes para contra-
               ordem.

   Alteracoes: 16/05/95 - Incluido o campo crapdev.cdalinea (Edson).

               26/10/95 - Tratar lancamento 46, leitura de taxa devolucao de
                          cheque, nao criar lancamento zerado. (Odair).

               21/01/97 - Alterado para tratar historico 191 no lugar do
                          47 (Deborah).

               27/08/97 - Alterado para incluir o campo flgproce na criacao
                          do crapavs (Deborah).

               16/12/98 - Tratar historico 47 para digitacao fora compe
                          para tratamento da contabilidade (Odair)

               24/06/99 - Tratar historico 338 (Odair)

               04/08/99 - Fazer o tratamento para andar junto com as devolucoes
                          diarias da tela devolu (Odair)

               17/05/2001 - Tratar devolucao de cheque TB do bancoob (Edson).

               24/11/2002 - Tratar o nrdocmto no histor. 46 (Ze Eduardo).

               27/03/2003 - Tratar historico 156 (Dev. chq. CEF) (Edson)

               25/06/2003 - Tratar Alinea 49 (Dev. alineas 12 e 13) (Ze).

               29/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm,crapavs e crapalt (Diego).

               12/12/2005 - Alteracao de crapchq p/ crapfdc (Ze).             

               15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               12/02/2007 - Alterar consultas com indice crapfdc1 (David).

               07/03/2007 - Ajustes para o Bancoob (Magui).

               16/06/2009 - Alimentar res_nrctachq com digito 0 e nao X
                          - Validar se crapavs ja exite antes da 
                            criacao do crapavs para cdhistor 46(Guilherme).

               19/10/2009 - Alteracao Codigo Historico (Kbase).

               08/01/2010 - Acrescentar historico 573 no mesmo CAN-DO do 338
                            (Guilherme/Supero)
                            
               06/08/2010 - Incluir controle para o envio do arquivo de Dev.
                            (Ze).

               09/09/2010 - Alterado o valor de indevarq para novo padrao.
                            De 0 para 1 e de 1 para 2. (Guilherme/Supero)
                            
               24/09/2010 - Acerto na atualizacao do campo indevarq (Ze).
               
               04/10/2010 - Identificar quando lancamento foi enviado para
                            ABBC na 1a ou 2a Devolucao (Ze).
                            
               17/11/2010 - Acerto no valor do VLB Truncagem (Ze).
               
               07/01/2011 - Desprezar a criacao no lcm das ctas cadastradas
                            no TCO - Migracao de PACs (Ze).
                            
               30/03/2012 - Ignorar os registros de devolucao com nrdconta = 0
                            e alinea = 37. (Fabricio)
                            
               18/06/2012 - Alteração na leitura da craptco (David Kruger).
               
               20/12/2012 - Adaptacao para a Migracao AltoVale (Ze).
               
               21/03/2013 - Ajustes referentes ao projeto tarifas fase 2 
                            Grupo de cheques (Lucas R).
                            
               11/10/2013 - Incluido parametro cdprogra nas procedures da 
                            b1wgen0153 que carregam dados de tarifas (Tiago).
                            
               14/01/2014 - Inclusao de VALIDATE craplot e craplcm (Carlos)
               
               25/08/2015 - Inclusao do parametro pr_cdpesqbb na procedure
                            tari0001.pc_cria_lan_auto_tarifa, projeto de 
                            Tarifas-218(Jean Michel) 

	           16/08/2016 - Ajuste para alterar o campo indevarq para 2 também
							quando forem cheques VLB, pois o crps264 precisa
							identificar estes cheques para envia-los a ABBC
							no primeiro horário da manhã
							(Adriano - SD 501761).

			   18/08/2016 - Efetuada a troca da nomenclatura "ERRO" para "CRITICA"
			                caso o aviso de debito ja existir, evitando acionamento
							desnecessario visto que essa critica nao abortado a
							execucao do processo. (Daniel)	
............................................................................. */

{ includes/var_batch.i }
{ sistema/generico/includes/var_internet.i }

DEF        VAR res_nrctachq AS INTE                                  NO-UNDO.
DEF        VAR res_nrdocmto AS INT                                   NO-UNDO.
DEF        VAR res_cdhistor AS INT                                   NO-UNDO.

DEF        VAR tab_txdevchq AS DECIMAL                               NO-UNDO.

DEF        VAR aux_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT     INIT 100                      NO-UNDO.

DEF        VAR aux_nrdocmto AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlbtrunc AS DECI                                  NO-UNDO.

/**** Variavies do proc_conta_integracao ****/
DEF VAR aux_ctpsqitg LIKE craplcm.nrdctabb                           NO-UNDO.
DEF VAR aux_nrdctitg LIKE crapass.nrdctitg                           NO-UNDO.
DEF VAR aux_nrdigitg as char format "x(01)"                          NO-UNDO.
DEF VAR aux_nrctaass AS INT FORMAT "zzzz,zzz,9"                      NO-UNDO.

DEF        VAR h-b1wgen0153 AS HANDLE                                NO-UNDO.
DEF        VAR aux_cdhistor AS INTE                                  NO-UNDO.
DEF        VAR aux_cdhisest AS INTE                                  NO-UNDO.
DEF        VAR aux_dtdivulg AS DATE                                  NO-UNDO.
DEF        VAR aux_dtvigenc AS DATE                                  NO-UNDO.
DEF        VAR aux_cdtarifa AS CHAR                                  NO-UNDO.
DEF        VAR par_dscritic LIKE crapcri.dscritic                    NO-UNDO.
DEF        VAR aux_vltarifa AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR aux_cdfvlcop AS INTE                                  NO-UNDO.
/*variaveis da taxa bacen*/
DEF        VAR aux_cdhisbac AS INTE                                  NO-UNDO.
DEF        VAR aux_cdtarbac AS CHAR                                  NO-UNDO.
DEF        VAR aux_vltarbac AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR aux_cdfvlbac AS INTE                                  NO-UNDO.

DEF BUFFER crabass5 FOR crapass.
/*******************************************/

ASSIGN glb_cdprogra = "crps097". 

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

IF   glb_inrestar > 0   AND   glb_nrctares = 0   THEN
     glb_inrestar = 0.

IF   glb_inrestar = 0 THEN
     DO:
         TRANS_2:       /*  Remove os registros do crapdev  */

         FOR EACH crapdev WHERE crapdev.cdcooper = glb_cdcooper   AND
                                crapdev.insitdev = 1 EXCLUSIVE-LOCK
                                TRANSACTION ON ERROR UNDO TRANS_2, RETURN:
             DELETE crapdev.
         END.
         
     END.

/* Se digito da conta itg do restart for 'X' passa pra '0' */
IF  SUBSTRING(glb_dsrestar,08,01) = "x"  THEN 
    res_nrctachq = INTEGER(SUBSTRING(glb_dsrestar,01,07) + "0").
ELSE
    res_nrctachq = INTEGER(SUBSTRING(glb_dsrestar,01,08)).
        
ASSIGN res_nrdocmto = INTEGER(SUBSTRING(glb_dsrestar,10,07))
       res_cdhistor = INTEGER(SUBSTRING(glb_dsrestar,18,04)).


FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         RETURN.
     END.

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "GENERI"      AND
                   craptab.cdempres = 0             AND
                   craptab.cdacesso = "VALORESVLB"  AND
                   craptab.tpregist = 0             
                   USE-INDEX craptab1 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 55.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" + glb_dscritic +
                           " CRED-GENERI-00-VALORESVLB-001 " +
                           " >> log/proc_batch.log").
         RETURN.
     END.

ASSIGN aux_vlbtrunc = DECIMAL(ENTRY(3,craptab.dstextab,";")).

{ includes/proc_conta_integracao.i }

IF  NOT VALID-HANDLE(h-b1wgen0153) THEN
    RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT SET h-b1wgen0153.

TRANS_1:
FOR EACH crapdev WHERE crapdev.cdcooper = glb_cdcooper   AND
                       crapdev.insitdev = 0              AND
                       crapdev.nrdconta >= glb_nrctares EXCLUSIVE-LOCK
                       TRANSACTION ON ERROR UNDO TRANS_1, RETURN:

    IF   crapdev.nrdconta = 0  AND 
         crapdev.cdalinea = 37 AND 
         crapdev.cdhistor = 47 THEN
         DO:
             ASSIGN crapdev.indevarq = 2 
			        crapdev.insitdev = 1.

             NEXT.
         END.

    FIND FIRST crapass WHERE crapass.cdcooper = crapdev.cdcooper AND
                             crapass.nrdconta = crapdev.nrdconta
                             NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapass THEN
         DO:
              glb_cdcritic = 251.
              RUN fontes/critic.p.
              UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                " - " + glb_cdprogra + "' --> '" +
                                STRING(crapdev.nrdconta,"zzzz,zz9,9") +
                                glb_dscritic + " >> log/proc_batch.log").
              
              IF  VALID-HANDLE(h-b1wgen0153) THEN
                   DELETE OBJECT h-b1wgen0153. 
              
              UNDO TRANS_1, RETURN.
               
         END.

    IF  crapass.inpessoa = 1 THEN
        ASSIGN aux_cdtarifa = "DEVOLCHQPF" 
               aux_cdtarbac = "DEVCHQBCPF". 
    ELSE
        ASSIGN aux_cdtarifa = "DEVOLCHQPJ" 
               aux_cdtarbac = "DEVCHQBCPJ". 

    IF  aux_cdtarifa = "DEVOLCHQPF" OR aux_cdtarifa = "DEVOLCHQPJ" THEN
        DO:
            RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                          (INPUT  glb_cdcooper,
                                           INPUT  aux_cdtarifa,
                                           INPUT  1, 
                                           INPUT  glb_cdprogra,
                                           OUTPUT aux_cdhistor,
                                           OUTPUT aux_cdhisest,
                                           OUTPUT aux_vltarifa,
                                           OUTPUT aux_dtdivulg,
                                           OUTPUT aux_dtvigenc,
                                           OUTPUT aux_cdfvlcop,
                                           OUTPUT TABLE tt-erro).
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                   FIND FIRST tt-erro NO-LOCK NO-ERROR.

                   IF AVAIL tt-erro THEN
                      UNIX SILENT VALUE("echo " + 
                           STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"
                           + tt-erro.dscritic +  
                           " >> log/proc_batch.log").      

                   IF  VALID-HANDLE(h-b1wgen0153) THEN
                       DELETE PROCEDURE h-b1wgen0153.  

                   UNDO TRANS_1, RETURN.
                END.
        END.

    /************BUSCA INFORMACOES DA TAXA BACEN**************/
    IF  aux_cdtarbac = "DEVCHQBCPF" OR aux_cdtarbac = "DEVCHQBCPJ" THEN
        DO:
            RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                          (INPUT  glb_cdcooper,
                                           INPUT  aux_cdtarbac,
                                           INPUT  1, 
                                           INPUT  glb_cdprogra,
                                           OUTPUT aux_cdhisbac,
                                           OUTPUT aux_cdhisest,
                                           OUTPUT aux_vltarbac,
                                           OUTPUT aux_dtdivulg,
                                           OUTPUT aux_dtvigenc,
                                           OUTPUT aux_cdfvlbac,
                                           OUTPUT TABLE tt-erro).
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                   FIND FIRST tt-erro NO-LOCK NO-ERROR.

                   IF AVAIL tt-erro THEN 
                      UNIX SILENT VALUE("echo " + 
                           STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"
                           + tt-erro.dscritic +  
                           " >> log/proc_batch.log").      
                   
                   IF  VALID-HANDLE(h-b1wgen0153) THEN
                       DELETE PROCEDURE h-b1wgen0153.  

                   UNDO TRANS_1, RETURN.
                   
                END.
            
        END.

    /*  Controle de restart por conta, conta base, documento e historico  */
    IF   glb_inrestar > 0    THEN
         IF   crapdev.nrdconta = glb_nrctares   THEN
              IF   crapdev.nrctachq = res_nrctachq   THEN
                   IF   crapdev.nrcheque < res_nrdocmto   THEN
                        NEXT.
                   ELSE
                   IF   crapdev.nrcheque = res_nrdocmto   THEN
                        IF   crapdev.cdhistor <= res_cdhistor   THEN
                             NEXT.
                        ELSE .
                   ELSE .
              ELSE
              IF   crapdev.nrctachq < res_nrctachq   THEN
                   NEXT.

    ASSIGN glb_cdcritic = 0
           glb_inrestar = 0.

    /*   47 = Devolucao de cheque fora compe
        156 = Devolucao de cheque CEF (Concredi)
        191 = Devolucao de cheque BB
        338 = Devolucao de cheque BANCOOB       
         78 = Devolucao de cheque Transferencia    */

    ASSIGN aux_ctpsqitg = 0
           aux_nrdctitg = crapdev.nrdctitg
           aux_nrdigitg = "".
                          
    RUN conta_itg_digito_zero.

    IF   CAN-DO("47,78,156,191,338,573",STRING(crapdev.cdhistor)) THEN
                                    /* Devolucao cheque normal */
         DO:
             RUN trata_cheque.

             IF  glb_cdcritic > 0   THEN
                 DO:
                    IF  VALID-HANDLE(h-b1wgen0153) THEN
                        DELETE PROCEDURE h-b1wgen0153.
                        RETURN.
                 END.

             /*  Verifica se a conta esta cadastrado no TCO - Se existir 
                 despreza a criacao do lanc. Soh ira criar no dia seguinte 
                 pela tela DEVOLU - Risco em criar o lanc. mas a outra coop
                 ja rodou crps001 (Ze). */
             
             IF   glb_cdcooper = 2 OR
                  glb_cdcooper = 1 THEN
                  DO:
                      FIND craptco WHERE craptco.cdcopant = glb_cdcooper     AND
                                         craptco.nrctaant = crapdev.nrdconta AND
                                         craptco.tpctatrf = 1                AND
                                         craptco.flgativo = TRUE
                                         NO-LOCK NO-ERROR.
                                         
                      IF   AVAILABLE craptco THEN
                           NEXT.
                  END.
             

             /*  Leitura do lote de devolucao de cheque  */
             
             DO WHILE TRUE:

                FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                                   craplot.dtmvtolt = glb_dtmvtolt   AND
                                   craplot.cdagenci = aux_cdagenci   AND
                                   craplot.cdbccxlt = aux_cdbccxlt   AND
                                   craplot.nrdolote = 8451
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
                                     craplot.cdagenci = aux_cdagenci
                                     craplot.cdbccxlt = aux_cdbccxlt
                                     craplot.nrdolote = 8451
                                     craplot.tplotmov = 1
                                     craplot.cdcooper = glb_cdcooper.
                              VALIDATE craplot.
                          END.

                LEAVE.

             END.  /*  Fim do DO WHILE TRUE  */

             CREATE craplcm.
             ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
                    craplcm.cdagenci = craplot.cdagenci
                    craplcm.cdbccxlt = craplot.cdbccxlt
                    craplcm.nrdolote = craplot.nrdolote
                    craplcm.nrdconta = crapdev.nrdconta
                    craplcm.nrdctabb = crapdev.nrdctabb
                    craplcm.nrdctitg = crapdev.nrdctitg
                    craplcm.nrdocmto = crapdev.nrcheque
                    craplcm.cdhistor = crapdev.cdhistor
                    craplcm.nrseqdig = craplot.nrseqdig + 1
                    craplcm.vllanmto = crapdev.vllanmto
                    craplcm.cdpesqbb = IF crapdev.cdalinea <> 0
                                          THEN STRING(crapdev.cdalinea)
                                          ELSE "21"
                    craplcm.cdcooper = glb_cdcooper                      
                    craplcm.cdbanchq = crapdev.cdbanchq
                    craplcm.cdagechq = crapdev.cdagechq
                    craplcm.nrctachq = crapdev.nrctachq
                    craplot.vlinfocr = craplot.vlinfocr + craplcm.vllanmto
                    craplot.vlcompcr = craplot.vlcompcr + craplcm.vllanmto
                    craplot.qtinfoln = craplot.qtinfoln + 1
                    craplot.qtcompln = craplot.qtcompln + 1
                    craplot.nrseqdig = craplot.nrseqdig + 1.
             VALIDATE craplcm.

             IF   AVAILABLE crapfdc   THEN
                  ASSIGN crapfdc.incheque = crapfdc.incheque - 5
                         crapfdc.dtliqchq = ?
                         crapfdc.vlcheque = 0
                         crapfdc.vldoipmf = 0.
                         
             IF   crapdev.cdbanchq = 85 THEN
                  DO:
                      /* Atribui Valor para Alinea na GNCPCHQ */
                      IF   AVAILABLE crapfdc   THEN
                           DO:
                               FIND gncpchq WHERE 
                                    gncpchq.cdcooper = crapdev.cdcooper      AND
                                    gncpchq.dtmvtolt = crapfdc.dtliqchq      AND
                                    gncpchq.cdtipreg = 3                     AND
                                    gncpchq.cdcmpchq = crapfdc.cdcmpchq      AND
                                    gncpchq.cdbanchq = crapfdc.cdbanchq      AND
                                    gncpchq.cdagechq = crapdev.cdagechq      AND
                                    gncpchq.nrctachq = crapdev.nrctachq      AND
                                    gncpchq.nrcheque = INT(crapdev.nrcheque) AND
                                    gncpchq.vlcheque = crapdev.vllanmto 
                                    USE-INDEX gncpchq1 EXCLUSIVE-LOCK NO-ERROR.

                              IF    AVAILABLE gncpchq THEN
                                    DO:
                                        IF  crapdev.cdalinea <> 0 THEN
                                            gncpchq.cdalinea = crapdev.cdalinea.
                                        ELSE 
                                            gncpchq.cdalinea = 21.
                                    END.
                           END.
                                
                      ASSIGN crapdev.indevarq = 2 
						     craplcm.dsidenti = STRING(crapdev.indevarq,"9").
                  
                  END.         
         END.
    ELSE
    IF  crapdev.cdhistor = 46 AND (aux_vltarifa > 0 OR aux_vltarbac > 0)  THEN
        DO:
             /*  Verifica se a conta esta cadastrado no TCO - Se existir 
                 despreza a criacao do lanc. Soh ira criar no dia seguinte 
                 pela tela DEVOLU - Risco em criar o lanc. mas a outra coop
                 ja rodou crps001 (Ze). */
             IF   glb_cdcooper = 2 OR
                  glb_cdcooper = 1 THEN
                  DO:
                      FIND craptco WHERE craptco.cdcopant = glb_cdcooper     AND
                                         craptco.nrctaant = crapdev.nrdconta AND
                                         craptco.tpctatrf = 1                AND
                                         craptco.flgativo = TRUE
                                         NO-LOCK NO-ERROR.
                                          
                      IF   AVAILABLE craptco THEN
                           NEXT.
                  END.
             
             /* Caso o aviso de debito ja existir gera erro no LOG e
               continua a execucao */
             FIND crapavs WHERE crapavs.cdcooper = glb_cdcooper     AND
                                crapavs.dtmvtolt = glb_dtmvtolt     AND
                                crapavs.cdempres = 0                AND
                                crapavs.cdagenci = crapass.cdagenci AND
                                crapavs.cdsecext = crapass.cdsecext AND
                                crapavs.nrdconta = crapass.nrdconta AND
                                crapavs.dtdebito = glb_dtmvtolt     AND
                                crapavs.cdhistor = 46               AND
                                crapavs.nrdocmto = crapdev.nrcheque
                                NO-LOCK NO-ERROR.
             
             IF  AVAIL crapavs  THEN
                 DO:
                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                                      " - " + glb_cdprogra + "' --> '" + 
                                      "'CRITICA: Registro de aviso de debito " +
                                      "ja existe - Conta: " +
                                      STRING(crapass.nrdconta) +
                                      " Cheque: " + STRING(crapdev.nrcheque) +
                                      "' >> log/proc_batch.log").
                    NEXT.                 
                 END.

             ASSIGN aux_nrdocmto = crapdev.nrcheque.

             IF  crapass.inpessoa <> 3        AND 
                (aux_cdtarifa = "DEVOLCHQPF"  OR 
                 aux_cdtarifa = "DEVOLCHQPJ") THEN
                 DO:
                     RUN cria_lan_auto_tarifa IN h-b1wgen0153
                                             (INPUT glb_cdcooper,
                                              INPUT crapass.nrdconta, 
                                              INPUT glb_dtmvtolt,
                                              INPUT aux_cdhistor, 
                                              INPUT aux_vltarifa,
                                              INPUT "1",
                                              INPUT 1,
                                              INPUT 100,   /*cdbccxlt */
                                              INPUT 8452, /* nrdolote */
                                              INPUT 1,     /*tpdolote */
                                              INPUT aux_nrdocmto,
                                              INPUT crapdev.nrdctabb,
                                              INPUT crapdev.nrdctitg,
                                              INPUT "Fato gerador tarifa:" + STRING(crapdev.nrcheque),  /*par_cdpesqbb*/
                                              INPUT crapdev.cdbanchq,   
                                              INPUT crapdev.cdagechq,   
                                              INPUT crapdev.nrctachq,   
                                              INPUT TRUE, /*flgaviso*/
                                              INPUT 2,  /*par_tpaviso*/
                                              INPUT aux_cdfvlcop,
                                              INPUT glb_inproces,
                                              OUTPUT TABLE tt-erro).
                                           
                     IF  RETURN-VALUE = "NOK"  THEN
                         DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.

                            IF AVAIL tt-erro THEN
                               UNIX SILENT VALUE("echo " + 
                                    STRING(TIME,"HH:MM:SS") +
                                    " - " + glb_cdprogra + "' --> '"
                                    + tt-erro.dscritic +  
                                    " >> log/proc_batch.log").

                            IF  VALID-HANDLE(h-b1wgen0153) THEN
                                DELETE PROCEDURE h-b1wgen0153.  
            
                            UNDO TRANS_1, RETURN.

                        END.
                     
                 END.
             
             IF (aux_cdtarbac = "DEVCHQBCPF"  OR 
                 aux_cdtarbac = "DEVCHQBCPJ") AND
                 crapass.inpessoa <> 3        THEN
                 DO:
                     RUN cria_lan_auto_tarifa IN h-b1wgen0153
                                             (INPUT glb_cdcooper,
                                              INPUT crapass.nrdconta, 
                                              INPUT glb_dtmvtolt,
                                              INPUT aux_cdhisbac, 
                                              INPUT aux_vltarbac,
                                              INPUT crapdev.cdoperad,
                                              INPUT 1,
                                              INPUT 100,   /*cdbccxlt */
                                              INPUT 8452, /* nrdolote */
                                              INPUT 1,     /*tpdolote */
                                              INPUT 0, /*nrdocmto*/
                                              INPUT crapdev.nrdctabb,
                                              INPUT crapdev.nrdctitg,
                                              INPUT "Fato gerador tarifa:" + STRING(crapdev.nrcheque),  /*par_cdpesqbb*/
                                              INPUT crapdev.cdbanchq,   
                                              INPUT crapdev.cdagechq,   
                                              INPUT crapdev.nrctachq,   
                                              INPUT FALSE, /*flgaviso*/
                                              INPUT 0,  /*par_tpaviso*/
                                              INPUT aux_cdfvlbac,
                                              INPUT glb_inproces,
                                              OUTPUT TABLE tt-erro).
                                           
                     IF  RETURN-VALUE = "NOK"  THEN
                         DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.

                            IF AVAIL tt-erro THEN
                               UNIX SILENT VALUE("echo " + 
                                    STRING(TIME,"HH:MM:SS") +
                                    " - " + glb_cdprogra + "' --> '"
                                    + tt-erro.dscritic +  
                                    " >> log/proc_batch.log").  

                            IF  VALID-HANDLE(h-b1wgen0153) THEN
                                DELETE PROCEDURE h-b1wgen0153.  
        
                            UNDO TRANS_1, RETURN.

                        END.
                     
                 END. /* fim do IF taxa bacen */
        END.
            
    /*  Cria registro de restart  */
    DO WHILE TRUE:




       FIND crapres WHERE crapres.cdcooper = glb_cdcooper AND 
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
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '" +
                                       glb_dscritic + " >> log/proc_batch.log").
                     
                     IF  VALID-HANDLE(h-b1wgen0153) THEN
                         DELETE OBJECT h-b1wgen0153.
                     
                     UNDO TRANS_1, RETURN.
                     
                 END.

       LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    ASSIGN crapres.nrdconta = crapdev.nrdconta
           crapres.dsrestar = STRING(crapdev.nrdctitg,"9999999x") + " " +
                              STRING(crapdev.nrcheque,"9999999")  + " " +
                              STRING(crapdev.cdhistor,"9999").
        
    crapdev.insitdev = 1.

END.  /*  Fim do FOR EACH e da transacao  */
                   
IF  VALID-HANDLE(h-b1wgen0153) THEN
    DELETE OBJECT h-b1wgen0153.

RUN fontes/fimprg.p.
                     
/* .......................................................................... */

PROCEDURE trata_cheque:
             
    DO WHILE TRUE:

       FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper       AND
                          crapfdc.cdbanchq = crapdev.cdbanchq   AND
                          crapfdc.cdagechq = crapdev.cdagechq   AND
                          crapfdc.nrctachq = crapdev.nrctachq   AND
                          crapfdc.nrcheque =
                          INT(SUBSTR(STRING(crapdev.nrcheque,"99999999"),1,7))
                          USE-INDEX crapfdc1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
       IF   NOT AVAILABLE crapfdc   THEN
            IF   LOCKED crapfdc   THEN
                 DO:
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
            ELSE
                 DO:
                     glb_cdcritic = 268.
                     LEAVE.
                 END.
       /*
       IF    crapfdc.tpcheque = 2 THEN
             DO:
                 IF   crapfdc.incheque <> 6   THEN
                      glb_cdcritic = 415.
             END.
       ELSE               
             IF   crapfdc.incheque <> 6   AND
                  crapdev.cdalinea <> 49  THEN
                  glb_cdcritic = 415.
       */
       LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    IF   glb_cdcritic > 0   THEN
         DO:
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '" +
                               glb_dscritic +
                               " COOP: " + STRING(glb_cdcooper) +
                               " CTA: " + STRING(crapdev.nrdconta) +
                               " ITG: " + STRING(crapdev.nrdctitg) +
                               " DOC: " + STRING(crapdev.nrcheque) +
                               " >> log/proc_batch.log").
             RETURN.
         END.

END PROCEDURE.

/* .......................................................................... */

