/* ..........................................................................

   Programa: Fontes/crps284.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Marco/2000.                     Ultima atualizacao: 20/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Gerar lancamento de tarifa de devolucao de cheque BANCOOB

   Alteracoes: 08/01/2003 - Criar tabela para contas isentas (Deboreah).

               07/04/2003 - Incluir tratamento do histor 399 (Margarete).
               
               30/06/2005 - Alimentado campo cdcooper das tabelas craplot
                            e craplcm (Diego).

               10/12/2005 - Atualizar craplcm.nrdctitg (Magui).
                
               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.  
               
               20/01/2014 - Incluir VALIDATE craplcm, craplot (Lucas R.)
               
               29/05/2018 - Alteraçao INSERT na craplcm pela chamada da rotina LANC0001
                            PRJ450 - Renato Cordeiro (AMcom)         

............................................................................. */
 
{ includes/var_batch.i  } 
{ sistema/generico/includes/b1wgen0200tt.i } /*renato PJ450*/

DEF VAR h-b1wgen0200 AS HANDLE        NO-UNDO.
{ sistema/generico/includes/var_oracle.i }
DEF BUFFER crablcm FOR craplcm.

DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_vltarifa AS DECI                                  NO-UNDO.
DEF        VAR tab_cdhistor AS INT                                   NO-UNDO.

DEF        VAR aux_vllanmto AS DECI                                  NO-UNDO.
DEF        VAR aux_lscontas AS CHAR                                  NO-UNDO.

DEF        VAR aux_cdcritic AS INT  NO-UNDO.
DEF        VAR aux_dscritic AS CHAR NO-UNDO.
DEF        VAR aux_incrineg AS INT  NO-UNDO.

glb_cdprogra = "crps284".

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
                   craptab.cdacesso = "VLTARIF351"  AND
                   craptab.tpregist = 1             NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 55.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                            glb_cdprogra + "' --> '" + glb_dscritic +
                            " CRED-USUARI-00-VLTARIF351-001 " +
                           " >> log/proc_batch.log").
         RETURN.
     END.

aux_vltarifa= DECI(craptab.dstextab).

/* Tabela que contem as contas isentas */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "USUARI"      AND
                   craptab.cdempres = 00            AND
                   craptab.cdacesso = "ISTARIF351"  AND
                   craptab.tpregist = 1             NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     aux_lscontas = "".
ELSE
     aux_lscontas = craptab.dstextab.

TRANS_1:

FOR EACH crablcm WHERE crablcm.cdcooper = glb_cdcooper               AND
                       crablcm.dtmvtolt = glb_dtmvtolt               AND
                       crablcm.nrdconta > glb_nrctares               AND
                   NOT CAN-DO(aux_lscontas,STRING(crablcm.nrdconta)) AND 
                       CAN-DO("24,27,351,399",STRING(crablcm.cdhistor))
                       USE-INDEX craplcm4 NO-LOCK BREAK BY crablcm.nrdconta
                       TRANSACTION ON ERROR UNDO TRANS_1, RETURN:

    aux_vllanmto = aux_vllanmto + aux_vltarifa.
         
    IF   LAST-OF(crablcm.nrdconta) THEN
         DO:
             
             IF   aux_vllanmto = 0 THEN
                  NEXT.
                  
             DO WHILE TRUE:

                FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                                   craplot.dtmvtolt = glb_dtmvtolt   AND
                                   craplot.cdagenci = 1              AND  
                                   craplot.cdbccxlt = 100            AND
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
                              ASSIGN 
                                  craplot.dtmvtolt = glb_dtmvtolt
                                  craplot.cdagenci = 1 
                                  craplot.cdbccxlt = 100
                                  craplot.nrdolote = 8452
                                  craplot.tplotmov = 1
                                  craplot.cdcooper = glb_cdcooper.
                          END.

                LEAVE.

             END.  /*  Fim do DO WHILE TRUE  */

             /* renato PJ450*/

             /* Identificar orgao expedidor */
             IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
                 RUN sistema/generico/procedures/b1wgen0200.p 
                     PERSISTENT SET h-b1wgen0200.

             aux_cdcritic = 0.
             aux_dscritic = "".
             aux_incrineg = 0.

             RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
                         (INPUT craplot.dtmvtolt                      /*par_dtmvtolt*/
                         ,INPUT craplot.cdagenci                      /*par_cdagenci*/
                         ,INPUT craplot.cdbccxlt                      /*par_cdbccxlt*/
                         ,INPUT craplot.nrdolote                      /*par_nrdolote*/
                         ,INPUT crablcm.nrdconta                      /*par_nrdconta*/
                         ,INPUT craplot.nrseqdig + 1                  /*par_nrdocmto*/
                         ,INPUT 352                                   /*par_cdhistor*/
                         ,INPUT craplot.nrseqdig + 1                  /*par_nrseqdig*/
                         ,INPUT aux_vllanmto                          /*par_vllanmto*/
                         ,INPUT crablcm.nrdconta                      /*par_nrdctabb*/
                         ,INPUT ""                                    /*par_cdpesqbb*/
                         ,INPUT 0                                     /*par_vldoipmf*/
                         ,INPUT 0                                     /*par_nrautdoc*/
                         ,INPUT 0                                     /*par_nrsequni*/
                         ,INPUT 0                                     /*par_cdbanchq*/
                         ,INPUT 0                                     /*par_cdcmpchq*/
                         ,INPUT 0                                     /*par_cdagechq*/
                         ,INPUT 0                                     /*par_nrctachq*/
                         ,INPUT 0                                     /*par_nrlotchq*/
                         ,INPUT 0                                     /*par_sqlotchq*/
                         ,INPUT craplot.dtmvtolt                      /*par_dtrefere*/
                         ,INPUT TIME                                  /*par_hrtransa*/
                         ,INPUT ""                                    /*par_cdoperad*/
                         ,INPUT ""                                    /*par_dsidenti*/
                         ,INPUT glb_cdcooper                          /*par_cdcooper*/
                         ,INPUT STRING(crablcm.nrdconta,"99999999")   /*par_nrdctitg*/
                         ,INPUT ""                                    /*par_dscedent*/
                         ,INPUT 0                                     /*par_cdcoptfn*/
                         ,INPUT 0                                     /*par_cdagetfn*/
                         ,INPUT 0                                     /*par_nrterfin*/
                         ,INPUT 0                                     /*par_nrparepr*/
                         ,INPUT 0                                     /*par_nrseqava*/
                         ,INPUT 0                                     /*par_nraplica*/
                         ,INPUT 0                                     /*par_cdorigem*/
                         ,INPUT 0                                     /*par_idlautom*/
                         ,INPUT 0                                     /*par_inprolot */
                         ,INPUT 0                                     /*par_tplotmov */
                         ,OUTPUT TABLE tt-ret-lancto
                         ,OUTPUT aux_incrineg
                         ,OUTPUT aux_cdcritic
                         ,OUTPUT aux_dscritic).
             IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
             DO:   

                /* Posicionando no registro da craplcm criado acima */
                FIND FIRST tt-ret-lancto NO-ERROR.
                FIND FIRST craplcm WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm NO-ERROR.

                IF aux_incrineg = 1 THEN
                DO:
                    
                    aux_cdcritic = 0.
                    aux_dscritic = "".

                   /*Renato Cordeiro - Gera lançamento futuro quando nao pdoe debitar - INICIO*/
                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                    
                    RUN STORED-PROCEDURE pc_cria_lanc_futuro aux_handproc = PROC-HANDLE NO-ERROR
                    
                                         (INPUT glb_cdcooper,
                                          INPUT crablcm.nrdconta,
                                          INPUT STRING(crablcm.nrdconta,"99999999"),
                                          INPUT craplot.cdagenci,
                                          INPUT craplot.dtmvtolt,
                                          INPUT 352,
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
             /* historico marcado para debitar incondicionalmente */
                glb_cdcritic = aux_cdcritic.
                RUN fontes/critic.p.
                UNIX SILENT VALUE ("echo " + 
                  STRING(TIME,"HH:MM:SS") +
                       " - " + aux_dscritic + "' --> '" + 
                         " >> log/proc_batch.log").
                UNDO TRANS_1, RETURN.
             END.

            IF VALID-HANDLE(h-b1wgen0200) THEN
               DELETE PROCEDURE h-b1wgen0200. 

            ASSIGN  craplot.vlinfodb = craplot.vlinfodb + aux_vllanmto
                    craplot.vlcompdb = craplot.vlcompdb + aux_vllanmto
                    craplot.qtinfoln = craplot.qtinfoln + 1
                    craplot.qtcompln = craplot.qtcompln + 1
                    craplot.nrseqdig = craplot.nrseqdig + 1

                    aux_vllanmto = 0.
            
             VALIDATE craplot.
        
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

RUN fontes/fimprg.p.

/* .......................................................................... */

