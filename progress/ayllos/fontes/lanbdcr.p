/* .............................................................................

   Programa: Fontes/lanbdcr.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Outubro/2003.                       Ultima atualizacao: 24/10/2018

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de resgate de cheques da tela lanbdc.

   Alteracoes: 10/02/2004 - Efetuado controle por PAC(tabelas horario 
                            compel/titulo) (Mirtes)

               27/02/2004 - Alterado a forma de gravacao do crapljd. Antes era
                            por bordero, agora e' por cheque (Edson).

               06/04/2004 - Quando resgatado no mesmo dia da liberacao, efetuar
                            atualizacao crapljd(Mirtes/Edson).

               16/05/2005 - Tratamento Conta Integracao(Mirtes)

               04/07/2005 - Alimentado campo cdcooper dos buffers crablot
                            e crablcm (Diego).
                            
               09/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).

               30/11/2005 - Ajustes na conversao crapchq/crapfdc (Edson).

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               13/02/2007 - Alterar consultas com indice crapfdc1 (David).
               
               28/01/2009 - Substituida a mensagem que mencionava o nome do
                            Edson;
                          - Liberar os lotes que sao comuns a varias operacoes 
                            para nao prender outras telas, lotes de numero
                            4501 e 8477 (Evandro).

               10/03/2009 - Corrigir problema de transacoes (Gabriel). 
               
               02/07/2009 - Acerto no tratamento de espera de LOCK (Evandro).

               08/07/2010 - Tratamento para Compe 085 (Ze).
               
               19/10/2010 - Nao resgatar caso ja tenha gerado o arquivo -
                            Compe por Imagem (Ze).
                            
               18/04/2013 - Ajuste para AltoVale - Task 54211 (Ze).
               
               05/09/2013 - Bloquear resgate do cheque caso estiver sendo
                            enviado para a compe - Task 84413 (Rafael).
                            
               07/11/2013 - Verificacao de quantidade de dias uteis e horario
                            limite para resgate de cheque; parametrizado na
                            TAB019. (Fabricio)
                            
               12/12/2013 - Inclusao de VALIDATE crablot e crablcm (Carlos)
               
               23/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                            
               21/06/2018 - P450 Regulatório de Credito - Substituido o create na craplcm pela chamada 
                            da rotina gerar_lancamento_conta_comple. (Josiane Stiehler - AMcom)
              
               19/10/2018 - PRJ450 - Regulatorios de Credito - centralizacao de 
                            estorno de lançamentos na conta corrente              
                            pc_estorna_lancto_prog (Fabio Adriano - AMcom).               
              
............................................................................. */

{ includes/var_online.i }

{ includes/var_lanbdc.i }

{ includes/proc_conta_integracao.i }
{ sistema/generico/includes/b1wgen0200tt.i }

DEF BUFFER crablot FOR craplot.
DEF BUFFER crablcm FOR craplcm.

DEF        VAR aux_txdiaria AS DECIMAL DECIMALS 7                    NO-UNDO.
DEF        VAR aux_vlliquid AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlliqori AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlliqnov AS DECIMAL                               NO-UNDO.
DEF        VAR aux_qtdprazo AS INT                                   NO-UNDO.
DEF        VAR aux_vlcheque AS DECIMAL                               NO-UNDO.
DEF        VAR aux_dtrefere AS DATE                                  NO-UNDO.
DEF        VAR aux_dtperiod AS DATE                                  NO-UNDO.
DEF        VAR aux_dtrefjur AS DATE                                  NO-UNDO.
DEF        VAR aux_dtultdat AS DATE                                  NO-UNDO.
DEF        VAR aux_vldjuros AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vljurper AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vljurant AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vldjuori AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vldjunov AS DECIMAL                               NO-UNDO.


DEF        VAR aux_qtdias   AS INT                                   NO-UNDO.
DEF        VAR aux_qtdiasli AS INT                                   NO-UNDO.
DEF        VAR aux_hrlimite AS INT                                   NO-UNDO.

DEF VAR aux_cdcritic        AS INTE                                NO-UNDO.
DEF VAR aux_dscritic        AS CHAR                                NO-UNDO.

DEF        VAR h-b1wgen0009 AS HANDLE                                NO-UNDO.

/* Variáveis de uso da BO 200 */
DEF VAR h-b1wgen0200         AS HANDLE                              NO-UNDO.
DEF VAR aux_incrineg         AS INT                                 NO-UNDO.

DEF TEMP-TABLE crawljd                                               NO-UNDO 
    LIKE crapljd.
               
ASSIGN tel_nmcustod = ""
       tel_dtlibera = ?
       tel_nrcustod = 0
       tel_cdcmpchq = 0
       tel_cdbanchq = 0
       tel_cdagechq = 0
       tel_nrddigc1 = 0
       tel_nrctachq = 0
       tel_nrddigc2 = 0
       tel_nrcheque = 0
       tel_nrddigc3 = 0
       tel_vlcheque = 0
       tel_nrseqdig = 1.

CMC-7:
      
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   IF   glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            ASSIGN glb_cdcritic = 0
                   tel_dsdocmc7 = "".
        END.
      
   UPDATE tel_dsdocmc7 WITH FRAME f_lanbdc
         
   EDITING:
            
      READKEY.
       
      IF   NOT CAN-DO(aux_lsvalido,KEYLABEL(LASTKEY))   THEN
           DO:
               glb_cdcritic = 666.
               NEXT.
           END.

      IF   KEYLABEL(LASTKEY) = "G"   THEN
           APPLY KEYCODE(":").
      ELSE
           APPLY LASTKEY.
    
   END.  /*  Fim do EDITING  */
         
   HIDE MESSAGE NO-PAUSE.
       
   IF   TRIM(tel_dsdocmc7) <> ""   THEN
        DO:
            IF   LENGTH(tel_dsdocmc7) <> 34            OR
                 SUBSTRING(tel_dsdocmc7,01,1) <> "<"   OR
                 SUBSTRING(tel_dsdocmc7,10,1) <> "<"   OR
                 SUBSTRING(tel_dsdocmc7,21,1) <> ">"   OR
                 SUBSTRING(tel_dsdocmc7,34,1) <> ":"   THEN
                 DO:
                     glb_cdcritic = 666.
                     NEXT.
                 END.
        
            RUN mostra_dados.

            IF   glb_cdcritic > 0   THEN
                 NEXT.
        END.
   ELSE
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               RUN fontes/cmc7.p (OUTPUT tel_dsdocmc7).
                     
               IF   LENGTH(tel_dsdocmc7) <> 34   THEN
                    APPLY "END-ERROR".

               DISPLAY tel_dsdocmc7 WITH FRAME f_lanbdc.
                     
               RUN mostra_dados.

               IF   glb_cdcritic > 0   THEN
                    NEXT.
                   
               LEAVE.
                  
            END.  /*  Fim do DO WHILE TRUE  */
                  
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
                 NEXT.
        END.
     
     DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:    
     
        FIND craptab WHERE  
             craptab.cdcooper = glb_cdcooper AND
             craptab.nmsistem = "CRED"       AND
             craptab.tptabela = "USUARI"     AND
             craptab.cdempres = 11           AND
             craptab.cdacesso = "BLQRESGCHQ" AND
             craptab.tpregist = 00           
             NO-LOCK NO-ERROR.
           
        IF  AVAIL(craptab) THEN 
            DO: 
               IF  craptab.dstextab = "S" THEN
                   DO:
                       /* resgate de cheque bloqueado. Tente Novamente */
                       glb_cdcritic = 959.
                       LEAVE.
                   END.
            END.

        FIND crapcdb WHERE crapcdb.cdcooper = glb_cdcooper   AND 
                           crapcdb.dtmvtolt = tel_dtmvtolt   AND
                           crapcdb.cdagenci = tel_cdagenci   AND
                           crapcdb.cdbccxlt = tel_cdbccxlt   AND
                           crapcdb.nrdolote = tel_nrdolote   AND
                           crapcdb.cdcmpchq = tel_cdcmpchq   AND
                           crapcdb.cdbanchq = tel_cdbanchq   AND
                           crapcdb.cdagechq = tel_cdagechq   AND
                           crapcdb.nrctachq = tel_nrctachq   AND
                           crapcdb.nrcheque = tel_nrcheque
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                           
        IF   NOT AVAILABLE crapcdb   THEN
             IF   LOCKED crapcdb   THEN
                  DO:
                      PAUSE 2 NO-MESSAGE.
                      NEXT.
                  END.
             ELSE
                  DO:

                      IF  (tel_cdbanchq = 756            AND 
                           tel_cdagechq = aux_cdagebcb)  OR
                          (tel_cdbanchq = aux_cdbcoctl   AND
                           tel_cdagechq = aux_cdagectl)  THEN
                           DO:
                               FIND FIRST craptrf WHERE
                                    craptrf.cdcooper = glb_cdcooper      AND 
                                    craptrf.nrdconta = INT(tel_nrctachq) AND
                                    craptrf.tptransa = 1 
                                    USE-INDEX craptrf1 NO-LOCK NO-ERROR.

                               IF   AVAILABLE craptrf THEN
                                    DO:
                                        tel_nrctachq = craptrf.nrsconta.
                                        DISPLAY tel_nrctachq
                                                WITH FRAME f_lanbdc.
                                        NEXT.
                                    END.
                           END.
                      
                      glb_cdcritic = 90.
                      LEAVE.
                  END.

        FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                           craptab.nmsistem = "CRED"        AND
                           craptab.tptabela = "USUARI"      AND
                           craptab.cdempres = 11            AND
                           craptab.cdacesso = "LIMDESCONT"  AND
                           craptab.tpregist = 0
                           NO-LOCK NO-ERROR.

        IF AVAIL craptab THEN
        DO:
            IF NOT VALID-HANDLE(h-b1wgen0009) THEN
                RUN sistema/generico/procedures/b1wgen0009.p PERSISTENT SET
                                                                h-b1wgen0009.

            IF VALID-HANDLE(h-b1wgen0009) THEN
            DO:
                RUN calc_qtd_dias_uteis IN h-b1wgen0009 
                                                    (INPUT glb_dtmvtolt,
                                                     INPUT crapcdb.dtlibera,
                                                    OUTPUT aux_qtdias).

                DELETE PROCEDURE h-b1wgen0009.

                /* busca o limite de dias uteis/horario parametrizado na TAB019 */
                ASSIGN aux_qtdiasli = INT(SUBSTR(craptab.dstextab,121,02))
                       aux_hrlimite = INT(SUBSTR(craptab.dstextab,124,05)).
                
                IF aux_qtdias < aux_qtdiasli THEN
                DO:
                    ASSIGN glb_cdcritic = 960.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic VIEW-AS ALERT-BOX.

                    LEAVE.
                END.
                ELSE
                IF aux_qtdias = aux_qtdiasli THEN
                DO:
                    IF TIME > aux_hrlimite THEN
                    DO:
                        ASSIGN glb_cdcritic = 960.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic VIEW-AS ALERT-BOX.

                        LEAVE.
                    END.
                END.
            END.
        END.

        /*  Leitura do bordero no qual o cheque esta descontado ............. */
        
       /* FIND crapbdc OF crapcdb NO-LOCK NO-ERROR.*/
       FIND crapbdc WHERE crapbdc.cdcooper = glb_cdcooper     AND 
                          crapbdc.nrborder = crapcdb.nrborder AND
                          crapbdc.nrdolote = crapcdb.nrdolote AND   
                          crapbdc.cdbccxlt = crapcdb.cdbccxlt AND
                          crapbdc.cdagenci = crapcdb.cdagenci AND
                          crapbdc.dtmvtolt = crapcdb.dtmvtolt NO-LOCK NO-ERROR.
        
        IF   NOT AVAILABLE crapbdc   THEN
             DO:
                 MESSAGE "BORDERO NAO ENCONTRADO."
                 glb_cdcritic = 79.
                 LEAVE.
             END.

        IF   crapbdc.insitbdc <> 3   THEN            /*  Deve estar liberado  */
             DO:
                 MESSAGE "BORDERO DEVE ESTAR LIBERADO."
                 glb_cdcritic = 79.
                 LEAVE.
             END.
        
        aux_txdiaria = ROUND((EXP(1 + (crapbdc.txmensal / 100),1 / 30) - 1),7).

        FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND 
                           craplot.dtmvtolt = tel_dtmvtolt   AND
                           craplot.cdagenci = tel_cdagenci   AND
                           craplot.cdbccxlt = tel_cdbccxlt   AND
                           craplot.nrdolote = tel_nrdolote
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF   NOT AVAILABLE craplot   THEN
             IF   LOCKED craplot   THEN
                  DO:
                      PAUSE 2 NO-MESSAGE.
                      NEXT.
                  END.
             ELSE
                  glb_cdcritic = 60.
        ELSE
             DO:   
                 IF   craplot.tplotmov <> 26   THEN
                      glb_cdcritic = 100.
             END.
                   
        IF   glb_cdcritic > 0   THEN
             LEAVE.

        FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND 
                           crapass.nrdconta = crapcdb.nrdconta NO-LOCK NO-ERROR.
      
        IF   NOT AVAILABLE crapass   THEN
             DO:
                 glb_cdcritic = 9.
                 LEAVE.
             END.

        ASSIGN tel_nmcustod = crapass.nmprimtl
               tel_vlcheque = crapcdb.vlcheque
               tel_dtlibera = crapcdb.dtlibera
               tel_nrcustod = crapcdb.nrdconta
               tel_nrseqdig = crapcdb.nrseqdig

               tel_vlcompdb = craplot.vlcompdb
               tel_vlcompcr = craplot.vlcompcr
               tel_qtcompln = craplot.qtcompln
               tel_vlinfodb = craplot.vlinfodb
               tel_vlinfocr = craplot.vlinfocr
               tel_qtinfoln = craplot.qtinfoln
               tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
               tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr
               tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln.

       DISPLAY tel_qtinfoln tel_qtcompln tel_vlinfodb
               tel_vlcompdb tel_vlinfocr tel_vlcompcr
               tel_qtdifeln tel_vldifedb tel_vldifecr
               
               tel_cdcmpchq tel_cdbanchq tel_cdagechq
               tel_nrddigc1 tel_nrctachq tel_nrddigc2
               tel_nrcheque tel_nrddigc3 tel_nrcustod 
               tel_nmcustod tel_dtlibera tel_vlcheque
               tel_nrseqdig
               WITH FRAME f_lanbdc.
 
        IF   crapcdb.insitchq = 1   THEN                    /*  Ja resgatado  */
             DO:
                 glb_cdcritic = 672.

                 NEXT CMC-7.
             END.
        ELSE
        IF   crapcdb.insitchq = 2   AND    /*  Processado em dias anteriores  */
             crapcdb.dtlibera <= glb_dtmvtoan   THEN
             DO:
                 glb_cdcritic = 670.
                      
                 NEXT CMC-7.
             END.        

        IF   CAN-FIND(crapcdb WHERE  crapcdb.cdcooper = glb_cdcooper   AND 
                                     crapcdb.cdcmpchq = tel_cdcmpchq   AND
                                     crapcdb.cdbanchq = tel_cdbanchq   AND
                                     crapcdb.cdagechq = tel_cdagechq   AND
                                     crapcdb.nrctachq = tel_nrctachq   AND
                                     crapcdb.nrcheque = tel_nrcheque   AND
                                     crapcdb.dtdevolu = glb_dtmvtolt)  THEN
             DO:
                 glb_cdcritic = 673.
                 NEXT CMC-7.
             END.
        /*
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           aux_confirma = "N".

           glb_cdcritic = 78.
           RUN fontes/critic.p.
           BELL.
           MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
           glb_cdcritic = 0.
           LEAVE.

        END.

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
             aux_confirma <> "S" THEN
             DO:
                 glb_cdcritic = 79.
                 RUN fontes/critic.p.
                 BELL.
                 MESSAGE glb_dscritic.
                 glb_cdcritic = 0.
                 NEXT CMC-7.
             END.
        */
        PAUSE 0.
        
        DISPLAY SKIP(1)
                " ATENCAO! Esta operacao NAO tem volta! "
                SKIP(1)
                WITH ROW 10 CENTERED OVERLAY color message FRAME f_sem_volta.
    
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           aux_confirma = "N".

           glb_cdcritic = 78.
           RUN fontes/critic.p.
           BELL.
           MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
           glb_cdcritic = 0.
           LEAVE.

        END.

        HIDE FRAME f_sem_volta NO-PAUSE.

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
             aux_confirma <> "S" THEN
             DO:
                 glb_cdcritic = 79.
                 RUN fontes/critic.p.
                 BELL.
                 MESSAGE glb_dscritic.
                 glb_cdcritic = 0.
                 NEXT CMC-7.
             END.

        aux_nrdocmto = INT(STRING(crapcdb.nrcheque,"999999") +
                           STRING(crapcdb.nrddigc3,"9")).

        IF   crapcdb.insitchq = 2   THEN            /*  Cheque ja descontado  */
             DO: 

                 /*  Resgatar cheque com data de Liberacao inferior a D-2  */
                 
                 IF   crapcdb.dtlibera <= glb_dtmvtopr  THEN
                      DO:
                          glb_cdcritic = 677.
                          UNDO, LEAVE.
                      END.
                 
                 IF  (crapcdb.dtlibera >  glb_dtmvtoan   AND
                      crapcdb.dtlibera <= glb_dtmvtolt)  THEN
                      RUN proc_liberado.
                 ELSE
                 IF   crapcdb.dtlibera > glb_dtmvtolt   THEN
                      DO:
                          RUN proc_recalculo.
                      
                          IF   glb_cdcritic = 0   THEN
                               RUN proc_lautom.
                      END.
                 ELSE
                      DO:
                          MESSAGE "ERRO - CHEQUE NAO PODE SER RESGATADO.".
                          glb_cdcritic = 79.
                      END.
                 
                 IF   glb_cdcritic > 0   THEN
                      UNDO, LEAVE.
 
                 IF   crapcdb.vlliqdev = 0   THEN
                      DO:
                          /*** Substituido a pedido da Mirtes (Evandro) ***
                          MESSAGE "ERRO - PROBLEMAS NO RESGATE - AVISE O EDSON".
                          ***/
                        MESSAGE "077 - Tabela sendo alterada p/ outro"
                                  "terminal."
                               
                          glb_cdcritic = 79.
                      END.

                 IF   glb_cdcritic > 0   THEN
                      UNDO, LEAVE.
                 
                 ASSIGN crapcdb.dtdevolu = glb_dtmvtolt 
                        crapcdb.cdopedev = glb_cdoperad
                        crapcdb.insitchq = 1.
             END.
        ELSE
             DO:
                 glb_cdcritic = 79.               /*  Rotina nao disponivel  */
             END.
             
        RELEASE craplot.
        RELEASE crablot.
        
        LEAVE.
        
     END.  /*  Fim do DO WHILE TRUE e da transacao  */

     IF   glb_cdcritic > 0   THEN
          NEXT.

     ASSIGN tel_reganter[2] = tel_reganter[1]

            tel_reganter[1] = STRING(tel_cdcmpchq,"zz9") + " " +
                              STRING(tel_cdbanchq,"zz9") + " " +
                              STRING(tel_cdagechq,"zzz9") + "  " +
                              STRING(tel_nrddigc1,"9") + " " +
                              STRING(tel_nrctachq,"zzz,zzz,zzz,9") + "  " +
                              STRING(tel_nrddigc2,"9") + " " +
                              STRING(tel_nrcheque,"zzz,zz9") + "  " +
                              STRING(tel_nrddigc3,"9") + "    " +
                              STRING(tel_vlcheque,"zzz,zzz,zzz,zz9.99") +
                              "   " +
                              STRING(tel_nrseqdig,"zz,zz9")

            tel_dsdocmc7 = ""
            tel_cdcmpchq = 0
            tel_cdbanchq = 0 
            tel_cdagechq = 0
            tel_nrddigc1 = 0
            tel_nrctachq = 0
            tel_nrddigc2 = 0
            tel_nrcheque = 0
            tel_nrddigc3 = 0
            tel_vlcheque = 0.
         
    DISPLAY tel_cdcmpchq tel_cdbanchq tel_cdagechq
            tel_nrddigc1 tel_nrctachq tel_nrddigc2
            tel_nrcheque tel_nrddigc3 tel_vlcheque
            tel_nrseqdig
            WITH FRAME f_lanbdc.

     HIDE FRAME f_lanctos.

     DISPLAY tel_reganter[1] tel_reganter[2] WITH FRAME f_regant.

END.   /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

{ includes/proc_lanbdc.i }

PROCEDURE proc_liberado:

    DEF VAR aux_flgcopmig AS LOGICAL                            NO-UNDO.

    /*  Tratamento para Migracao da AltoVale */
    aux_flgcopmig = FALSE.

    IF   glb_cdcooper     = 16   AND
         crapcdb.cdbanchq = 85   AND
         crapcdb.cdagechq = 101  THEN
         DO:
            FIND FIRST craptco WHERE 
                       craptco.cdcooper = crapcdb.cdcooper       AND
                       craptco.nrdconta = INT(crapcdb.nrctachq)  AND
                       craptco.tpctatrf = 1                      AND
                       craptco.flgativo = TRUE
                       NO-LOCK NO-ERROR.     
            
            IF   AVAILABLE craptco THEN
                 aux_flgcopmig = TRUE.
         END.


    IF   crapcdb.inchqcop = 1  OR
         aux_flgcopmig = TRUE  THEN               /*  Cheque da Cooperativa  */
         DO:
             ASSIGN aux_nrdconta = crapcdb.nrctachq
                    aux_nrdctabb = crapcdb.nrctachq
                    aux_nrdocmto = INT(STRING(crapcdb.nrcheque,"999999") +
                                       STRING(crapcdb.nrddigc3,"9")).

             RUN fontes/digbbx.p (INPUT  INT(crapcdb.nrctachq),
                                  OUTPUT glb_dsdctitg,
                                  OUTPUT glb_stsnrcal).
                                              
             IF   NOT glb_stsnrcal   THEN
                  DO:
                      glb_cdcritic = 8.
                      RETURN.
                  END.

             ASSIGN glb_nrchqsdv = crapcdb.nrcheque
                    glb_nrchqcdv = aux_nrdocmto.
             
             DO WHILE TRUE:

                FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper      AND
                                   crapfdc.cdbanchq = crapcdb.cdbanchq  AND
                                   crapfdc.cdagechq = crapcdb.cdagechq  AND
                                   crapfdc.nrctachq = crapcdb.nrctachq  AND
                                   crapfdc.nrcheque = crapcdb.nrcheque 
                                   USE-INDEX crapfdc1 
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                         
                IF   NOT AVAILABLE crapfdc  THEN
                     IF   LOCKED crapfdc   THEN
                          DO:
                                RUN sistema/generico/procedures/b1wgen9999.p
                                PERSISTENT SET h-b1wgen9999.
                                
                                RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crapfdc),
                                					 INPUT "banco",
                                					 INPUT "crapfdc",
                                					 OUTPUT par_loginusr,
                                					 OUTPUT par_nmusuari,
                                					 OUTPUT par_dsdevice,
                                					 OUTPUT par_dtconnec,
                                					 OUTPUT par_numipusr).
                                
                                DELETE PROCEDURE h-b1wgen9999.
                                
                                ASSIGN aux_dadosusr = 
                                "077 - Tabela sendo alterada p/ outro terminal.".
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 3 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                			  " - " + par_nmusuari + ".".
                                
                                HIDE MESSAGE NO-PAUSE.
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 5 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                glb_cdcritic = 0.
                                NEXT.
                          END.
                     ELSE
                          DO:
                              glb_cdcritic = 108.
                              RETURN.
                          END.

                ASSIGN glb_cdcritic = 0
                       aux_nrdconta = crapfdc.nrdconta
                       aux_nrdctabb = crapfdc.nrdctabb.
                           
                IF   crapfdc.incheque <> 5   THEN
                     DO:
                         glb_cdcritic = 99.
                         RETURN.
                     END.
                     
                IF   crapfdc.tpcheque = 2   THEN      /*  CHEQUE TB  */
                     DO:
                         glb_cdcritic = 646.
                         RETURN.
                     END.
                ELSE
                IF   crapfdc.tpcheque = 3   THEN      /*  CHEQUE SALARIO  */
                     DO:
                         IF   crapfdc.vlcheque <> crapcdb.vlcheque   THEN
                              DO:
                                  glb_cdcritic = 91.
                                  RETURN. 
                              END.
                     END.

                FIND craplau WHERE craplau.cdcooper = glb_cdcooper       AND
                                   craplau.dtmvtolt = crapcdb.dtmvtolt   AND
                                   craplau.cdagenci = crapcdb.cdagenci   AND
                                   craplau.cdbccxlt = crapcdb.cdbccxlt   AND
                                   craplau.nrdolote = crapcdb.nrdolote   AND
                                   craplau.nrdctabb = INT(crapcdb.nrctachq) AND
                                   craplau.nrdocmto = aux_nrdocmto
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF   NOT AVAILABLE craplau   THEN
                     IF   LOCKED craplau   THEN
                          DO:
                                RUN sistema/generico/procedures/b1wgen9999.p
                                PERSISTENT SET h-b1wgen9999.
                                
                                RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craplau),
                                					 INPUT "banco",
                                					 INPUT "craplau",
                                					 OUTPUT par_loginusr,
                                					 OUTPUT par_nmusuari,
                                					 OUTPUT par_dsdevice,
                                					 OUTPUT par_dtconnec,
                                					 OUTPUT par_numipusr).
                                
                                DELETE PROCEDURE h-b1wgen9999.
                                
                                ASSIGN aux_dadosusr = 
                                "077 - Tabela sendo alterada p/ outro terminal.".
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 3 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                			  " - " + par_nmusuari + ".".
                                
                                HIDE MESSAGE NO-PAUSE.
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 5 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                glb_cdcritic = 0.
                                NEXT.
                          END.
                          
                glb_cdcritic = 0.
                     
                /*  Registro do cheque acolhido  */
                FIND crapchd WHERE crapchd.cdcooper = glb_cdcooper   AND 
                                   crapchd.dtmvtolt = glb_dtmvtolt   AND
                                   crapchd.dsdocmc7 = crapcdb.dsdocmc7
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                   
                IF   NOT AVAILABLE crapchd   THEN
                     IF   LOCKED crapchd   THEN
                          DO:
                                RUN sistema/generico/procedures/b1wgen9999.p
                                PERSISTENT SET h-b1wgen9999.
                                
                                RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crapchd),
                                					 INPUT "banco",
                                					 INPUT "crapchd",
                                					 OUTPUT par_loginusr,
                                					 OUTPUT par_nmusuari,
                                					 OUTPUT par_dsdevice,
                                					 OUTPUT par_dtconnec,
                                					 OUTPUT par_numipusr).
                                
                                DELETE PROCEDURE h-b1wgen9999.
                                
                                ASSIGN aux_dadosusr = 
                                "077 - Tabela sendo alterada p/ outro terminal.".
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 3 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                			  " - " + par_nmusuari + ".".
                                
                                HIDE MESSAGE NO-PAUSE.
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 5 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                glb_cdcritic = 0.
                                NEXT.

                          END.
         
                glb_cdcritic = 0.
                LEAVE.
                
             END.  /*  Fim do DO WHILE TRUE  */
         END.
    ELSE                                        /*  Cheques de outros bancos  */
         DO:
             /*  Verifica o horario de corte  */
             FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND 
                                craptab.nmsistem = "CRED"         AND
                                craptab.tptabela = "GENERI"       AND
                                craptab.cdempres = 0              AND
                                craptab.cdacesso = "HRTRCOMPEL"   AND
                                craptab.tpregist = tel_cdagenci 
                                NO-LOCK NO-ERROR.

             IF   NOT AVAILABLE craptab   THEN
                  DO:
                      glb_cdcritic = 676.
                      RETURN.
                  END.

             IF   INT(SUBSTR(craptab.dstextab,3,5)) <= TIME   THEN
                  DO:
                      glb_cdcritic = 676.
                      RETURN.
                  END.
             
             /*  Registro do cheque acolhido  */
             
             DO WHILE TRUE:
             
                FIND crapchd WHERE crapchd.cdcooper = glb_cdcooper   AND 
                                   crapchd.dtmvtolt = glb_dtmvtolt   AND
                                   crapchd.dsdocmc7 = crapcdb.dsdocmc7
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                   
                IF   NOT AVAILABLE crapchd   THEN
                     IF   LOCKED crapchd   THEN
                          DO:
                                RUN sistema/generico/procedures/b1wgen9999.p
                                PERSISTENT SET h-b1wgen9999.
                                
                                RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crapchd),
                                                     INPUT "banco",
                                                     INPUT "crapchd",
                                                     OUTPUT par_loginusr,
                                                     OUTPUT par_nmusuari,
                                                     OUTPUT par_dsdevice,
                                                     OUTPUT par_dtconnec,
                                                     OUTPUT par_numipusr).
                                
                                DELETE PROCEDURE h-b1wgen9999.
                                
                                ASSIGN aux_dadosusr = 
                                "077 - Tabela sendo alterada p/ outro terminal.".
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 3 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                              " - " + par_nmusuari + ".".
                                
                                HIDE MESSAGE NO-PAUSE.
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 5 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                glb_cdcritic = 0.
                                NEXT.
                          END.
                     ELSE
                          DO:           
                              glb_cdcritic = 244.   
                              RETURN.
                          END.
                ELSE
                IF   crapchd.insitchq = 3   THEN
                     DO:
                         glb_cdcritic = 999.   /*  compe. terceiros  */
                         RETURN.
                     END.
                     
                glb_cdcritic = 0.
                LEAVE.
                
             END.  /*  Fim do DO WHILE TRUE  */
         END.
        
    /*  Recalcula os juros do cheque .......................................  */
    
    RUN proc_recalculo.
   
    IF   glb_cdcritic > 0   THEN
         UNDO, RETURN.
    
    /*  Desfaz os lancamentos da liberacao .................................. */
    
    IF   AVAILABLE crapchd   THEN
         DELETE crapchd.
    
    IF   AVAILABLE craplau   THEN
         DO:
             ASSIGN craplau.dtdebito = glb_dtmvtolt
                    craplau.insitlau = 3.
                
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
                FIND craplot WHERE craplot.cdcooper = glb_cdcooper       AND
                                   craplot.dtmvtolt = glb_dtmvtolt       AND
                                   craplot.cdagenci = 1                  AND
                                   craplot.cdbccxlt = 100                AND
                                   craplot.nrdolote = 4501
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
                IF   NOT AVAILABLE craplot   THEN
                     IF   LOCKED craplot   THEN
                          DO:
                                RUN sistema/generico/procedures/b1wgen9999.p
                                PERSISTENT SET h-b1wgen9999.
                                
                                RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craplot),
                                                     INPUT "banco",
                                                     INPUT "craplot",
                                                     OUTPUT par_loginusr,
                                                     OUTPUT par_nmusuari,
                                                     OUTPUT par_dsdevice,
                                                     OUTPUT par_dtconnec,
                                                     OUTPUT par_numipusr).
                                
                                DELETE PROCEDURE h-b1wgen9999.
                                
                                ASSIGN aux_dadosusr = 
                                "077 - Tabela sendo alterada p/ outro terminal.".
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 3 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                              " - " + par_nmusuari + ".".
                                
                                HIDE MESSAGE NO-PAUSE.
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 5 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                glb_cdcritic = 0.
                                NEXT.
                          END.
                     ELSE
                          DO:
                              glb_cdcritic = 60.
                              RETURN.
                          END.
       
                glb_cdcritic = 0.
                LEAVE.
    
             END.  /*  Fim do DO WHILE TRUE  */
         
             IF   glb_cdcritic > 0   THEN
                  RETURN.
             
             DO WHILE TRUE:
             
                FIND craplcm WHERE craplcm.cdcooper = glb_cdcooper       AND 
                                   craplcm.dtmvtolt = craplot.dtmvtolt   AND
                                   craplcm.cdagenci = craplot.cdagenci   AND
                                   craplcm.cdbccxlt = craplot.cdbccxlt   AND
                                   craplcm.nrdolote = craplot.nrdolote   AND
                                   craplcm.nrdctabb = craplau.nrdctabb   AND
                                   craplcm.nrdocmto = craplau.nrdocmto 
                                   USE-INDEX craplcm1
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                          
                IF   NOT AVAILABLE craplcm   THEN
                     IF   LOCKED craplcm   THEN
                          DO:
                                RUN sistema/generico/procedures/b1wgen9999.p
                                PERSISTENT SET h-b1wgen9999.
                                
                                RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craplcm),
                                                     INPUT "banco",
                                                     INPUT "craplcm",
                                                     OUTPUT par_loginusr,
                                                     OUTPUT par_nmusuari,
                                                     OUTPUT par_dsdevice,
                                                     OUTPUT par_dtconnec,
                                                     OUTPUT par_numipusr).
                                
                                DELETE PROCEDURE h-b1wgen9999.
                                
                                ASSIGN aux_dadosusr = 
                                "077 - Tabela sendo alterada p/ outro terminal.".
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 3 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                              " - " + par_nmusuari + ".".
                                
                                HIDE MESSAGE NO-PAUSE.
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 5 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                glb_cdcritic = 0.
                                NEXT.
                          END.

                glb_cdcritic = 0.
                LEAVE.
             
             END.  /*  Fim do DO WHILE TRUE  */
             
             IF   glb_cdcritic > 0   THEN
                  RETURN.
             
             IF   AVAILABLE craplcm   THEN
                  DO:
                      ASSIGN craplot.qtinfoln = craplot.qtinfoln - 1
                             craplot.qtcompln = craplot.qtcompln - 1

                             craplot.vlinfodb = craplot.vlinfodb -
                                                        crapcdb.vlcheque
                             craplot.vlcompdb = craplot.vlcompdb -
                                                        crapcdb.vlcheque.
 
                      
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
                          ,INPUT craplcm.nrctachq               /* par_nrctachq */
                          ,INPUT craplcm.nrdconta               /* par_nrdconta */
                          ,INPUT craplcm.cdpesqbb               /* par_cdpesqbb */
                          ,OUTPUT aux_cdcritic                  /* Codigo da critica                             */
                          ,OUTPUT aux_dscritic).                /* Descricao da critica                          */
                                          
                      IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                      DO: 
                          glb_cdcritic = aux_cdcritic.
                          glb_dscritic = aux_dscritic.
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          ASSIGN glb_cdcritic = 0.
                          
                          RETURN.
                      END.   
                                
                      IF  VALID-HANDLE(h-b1wgen0200) THEN
                          DELETE PROCEDURE h-b1wgen0200.
                      /* Fim do DELETE */
                      
                  END.
         END.

    IF   AVAILABLE crapfdc   THEN
         ASSIGN crapfdc.incheque = crapfdc.incheque - 5
                crapfdc.dtliqchq = ?
                crapfdc.vlcheque = 0
                crapfdc.vldoipmf = 0.

END PROCEDURE.

PROCEDURE proc_recalculo:

   ASSIGN aux_qtdprazo = IF crapcdb.dtlibera > glb_dtmvtoan AND
                            crapcdb.dtlibera < glb_dtmvtolt 
                            THEN crapcdb.dtlibera - crapbdc.dtlibbdc
                            ELSE glb_dtmvtolt - crapbdc.dtlibbdc
          aux_vlcheque = crapcdb.vlcheque
          aux_dtperiod = crapbdc.dtlibbdc
          aux_vldjuros = 0
          aux_vljurper = 0
          aux_vlliqori = crapcdb.vlliquid.

   IF   aux_qtdprazo > 0 THEN    /* Restituicao nao no mesmo dia da Liberacao */
        DO:
           DO aux_contador = 1 TO aux_qtdprazo:
   
              ASSIGN aux_vldjuros = ROUND(aux_vlcheque * aux_txdiaria,2)
                     aux_vlcheque = aux_vlcheque + aux_vldjuros
              
                     aux_dtperiod = aux_dtperiod + 1
                 
                     aux_dtrefjur = ((DATE(MONTH(aux_dtperiod),28,
                                     YEAR(aux_dtperiod)) + 4) -
                                      DAY(DATE(MONTH(aux_dtperiod),28,
                                     YEAR(aux_dtperiod)) + 4)).
          
              DO WHILE TRUE: 
            
                 FIND crawljd WHERE crawljd.cdcooper = glb_cdcooper       AND
                                    crawljd.nrdconta = crapcdb.nrdconta   AND
                                    crawljd.nrborder = crapcdb.nrborder   AND
                                    crawljd.dtmvtolt = crapcdb.dtlibbdc   AND
                                    crawljd.dtrefere = aux_dtrefjur       AND
                                    crawljd.cdcmpchq = crapcdb.cdcmpchq   AND
                                    crawljd.cdbanchq = crapcdb.cdbanchq   AND
                                    crawljd.cdagechq = crapcdb.cdagechq   AND
                                    crawljd.nrctachq = crapcdb.nrctachq   AND
                                    crawljd.nrcheque = crapcdb.nrcheque
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                
                 IF   NOT AVAILABLE crawljd   THEN
                      IF   LOCKED crawljd   THEN
                           DO:
                                RUN sistema/generico/procedures/b1wgen9999.p
                                PERSISTENT SET h-b1wgen9999.
                                
                                RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crawljd),
                                                     INPUT "banco",
                                                     INPUT "crawljd",
                                                     OUTPUT par_loginusr,
                                                     OUTPUT par_nmusuari,
                                                     OUTPUT par_dsdevice,
                                                     OUTPUT par_dtconnec,
                                                     OUTPUT par_numipusr).
                                
                                DELETE PROCEDURE h-b1wgen9999.
                                
                                ASSIGN aux_dadosusr = 
                                "077 - Tabela sendo alterada p/ outro terminal.".
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 3 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                              " - " + par_nmusuari + ".".
                                
                                HIDE MESSAGE NO-PAUSE.
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 5 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                glb_cdcritic = 0.
                                NEXT.
                           END.
                      ELSE
                           DO:
                              CREATE crawljd.
                              ASSIGN crawljd.nrdconta = crapcdb.nrdconta
                                     crawljd.nrborder = crapcdb.nrborder
                                     crawljd.dtmvtolt = crapcdb.dtlibbdc
                                     crawljd.dtrefere = aux_dtrefjur    
                                     crawljd.cdcmpchq = crapcdb.cdcmpchq   
                                     crawljd.cdbanchq = crapcdb.cdbanchq   
                                     crawljd.cdagechq = crapcdb.cdagechq   
                                     crawljd.nrctachq = crapcdb.nrctachq   
                                     crawljd.nrcheque = crapcdb.nrcheque
                                     crawljd.cdcooper = glb_cdcooper. 
                           END.      
             
                 glb_cdcritic = 0.
                 LEAVE. 
          
              END.   /*  Fim do DO WHILE TRUE  */
           
              IF   glb_cdcritic > 0   THEN
                   RETURN.
              
              crawljd.vldjuros = crawljd.vldjuros + aux_vldjuros.
          
           END.  /*  Fim do DO .. TO  */

           aux_vlliqnov = crapcdb.vlcheque - (aux_vlcheque - crapcdb.vlcheque).

           /*  Atualiza registro de provisao de juros .....................  */

           FOR EACH crawljd WHERE crawljd.cdcooper = glb_cdcooper :

               FIND crapljd WHERE crapljd.cdcooper = glb_cdcooper       AND 
                                  crapljd.nrdconta = crawljd.nrdconta   AND
                                  crapljd.nrborder = crawljd.nrborder   AND
                                  crapljd.dtmvtolt = crawljd.dtmvtolt   AND
                                  crapljd.dtrefere = crawljd.dtrefere   AND
                                  crapljd.cdcmpchq = crawljd.cdcmpchq   AND
                                  crapljd.cdbanchq = crawljd.cdbanchq   AND
                                  crapljd.cdagechq = crawljd.cdagechq   AND
                                  crapljd.nrctachq = crawljd.nrctachq   AND
                                  crapljd.nrcheque = crawljd.nrcheque
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                
               IF   NOT AVAILABLE crapljd   THEN
                    DO:
                        MESSAGE "ERRO - REGISTRO CRAPLJD NAO ENCONTRADO".
                        glb_cdcritic = 79.
                        UNDO, RETURN.
                    END.
       
               IF   crapljd.vldjuros <> crawljd.vldjuros   THEN
                    IF   crapljd.vldjuros > crawljd.vldjuros   THEN
                         ASSIGN crapljd.vlrestit = crapljd.vldjuros - 
                                                   crawljd.vldjuros
                                crapljd.vldjuros = crawljd.vldjuros.
                    ELSE
                         DO:
                             MESSAGE "ERRO - JUROS NEGATIVO:" crapljd.vldjuros.
                             glb_cdcritic = 79.
                             UNDO, RETURN.
                         END.
                     
               aux_dtultdat = crawljd.dtrefere.
       
               DELETE crawljd.
   
           END.  /*  Fim do FOR EACH crawljd  */
        
        END.
   ELSE
        ASSIGN aux_dtultdat = glb_dtmvtolt
               aux_vlliqori = crapcdb.vlliquid
               aux_vlliqnov = crapcdb.vlcheque.

   FOR EACH crapljd WHERE crapljd.cdcooper = glb_cdcooper       AND 
                          crapljd.nrdconta = crapcdb.nrdconta   AND
                          crapljd.nrborder = crapcdb.nrborder   AND
                          crapljd.dtmvtolt = crapcdb.dtlibbdc   AND
                          crapljd.dtrefere > aux_dtultdat       AND
                          crapljd.cdcmpchq = crapcdb.cdcmpchq   AND
                          crapljd.cdbanchq = crapcdb.cdbanchq   AND
                          crapljd.cdagechq = crapcdb.cdagechq   AND
                          crapljd.nrctachq = crapcdb.nrctachq   AND
                          crapljd.nrcheque = crapcdb.nrcheque   EXCLUSIVE-LOCK:
                         
       ASSIGN crapljd.vlrestit = crapljd.vldjuros
              crapljd.vldjuros = 0.
   
   END.  /*  Fim do FOR EACH crapljd  */
       
   /*  Cria lancamento no conta-corrente ...................................  */
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      FIND crablot WHERE crablot.cdcooper = glb_cdcooper   AND 
                         crablot.dtmvtolt = glb_dtmvtolt   AND
                         crablot.cdagenci = 1              AND
                         crablot.cdbccxlt = 100            AND
                         crablot.nrdolote = 8477           
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF   NOT AVAILABLE crablot   THEN
           IF   LOCKED crablot   THEN
                DO:
                    RUN sistema/generico/procedures/b1wgen9999.p
                    PERSISTENT SET h-b1wgen9999.
                    
                    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crablot),
                                         INPUT "banco",
                                         INPUT "crablot",
                                         OUTPUT par_loginusr,
                                         OUTPUT par_nmusuari,
                                         OUTPUT par_dsdevice,
                                         OUTPUT par_dtconnec,
                                         OUTPUT par_numipusr).
                    
                    DELETE PROCEDURE h-b1wgen9999.
                    
                    ASSIGN aux_dadosusr = 
                    "077 - Tabela sendo alterada p/ outro terminal.".
                    
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    MESSAGE aux_dadosusr.
                    PAUSE 3 NO-MESSAGE.
                    LEAVE.
                    END.
                    
                    ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                  " - " + par_nmusuari + ".".
                    
                    HIDE MESSAGE NO-PAUSE.
                    
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    MESSAGE aux_dadosusr.
                    PAUSE 5 NO-MESSAGE.
                    LEAVE.
                    END.
                    
                    glb_cdcritic = 0.
                    NEXT.
                END.
           ELSE
                DO:
                    CREATE crablot.
                    ASSIGN crablot.dtmvtolt = glb_dtmvtolt
                           crablot.cdagenci = 1
                           crablot.cdbccxlt = 100
                           crablot.nrdolote = 8477
                           crablot.tplotmov = 1
                           crablot.cdoperad = glb_cdoperad
                           crablot.cdhistor = 271
                           crablot.cdcooper = glb_cdcooper.
                    VALIDATE crablot.

                END.
 
      glb_cdcritic = 0.
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   glb_cdcritic > 0   THEN
        RETURN.
   
   /* P450 - Regulatório de Crédito */
   /* BLOCO DA INSERÇAO DA CRAPLCM */
   IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
       RUN sistema/generico/procedures/b1wgen0200.p 
       PERSISTENT SET h-b1wgen0200.
      
   /*  Cria lancamento da conta do associado ................................ */
   RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
        (INPUT craplot.dtmvtolt               /* par_dtmvtolt */
        ,INPUT craplot.cdagenci               /* par_cdagenci */
        ,INPUT craplot.cdbccxlt               /* par_cdbccxlt */
        ,INPUT craplot.nrdolote               /* par_nrdolote */
        ,INPUT crapcdb.nrdconta               /* par_nrdconta */
        ,INPUT crablot.nrseqdig + 1           /* par_nrdocmto */
        ,INPUT 271                            /* par_cdhistor */
        ,INPUT crablot.nrseqdig + 1           /* par_nrseqdig */
        ,INPUT crapcdb.vlcheque - (aux_vlliqnov - aux_vlliqori)  /* par_vllanmto */
        ,INPUT crapcdb.nrdconta               /* par_nrdctabb */
        ,INPUT "Resgate de cheque descontado " +
                             crapcdb.dsdocmc7 + " Bordero " +
                             STRING(crapcdb.nrborder)           /* par_cdpesqbb */
        ,INPUT 0                              /* par_vldoipmf */
        ,INPUT 0                              /* par_nrautdoc */
        ,INPUT 0                              /* par_nrsequni */
        ,INPUT crapcdb.cdbanchq               /* par_cdbanchq */
        ,INPUT 0                              /* par_cdcmpchq */
        ,INPUT crapcdb.cdagechq               /* par_cdagechq */
        ,INPUT crapcdb.nrctachq               /* par_nrctachq */
        ,INPUT 0                              /* par_nrlotchq */
        ,INPUT 0                              /* par_sqlotchq */
        ,INPUT ""                             /* par_dtrefere */
        ,INPUT ""                             /* par_hrtransa */
        ,INPUT ""                             /* par_cdoperad */
        ,INPUT ""                             /* par_dsidenti */
        ,INPUT glb_cdcooper                   /* par_cdcooper */
        ,INPUT ""                             /* par_nrdctitg */
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
        MESSAGE aux_dscritic.
        glb_cdcritic = aux_cdcritic.
        UNDO, RETURN.
      END.   
   ELSE 
      DO:
         /* 21/06/2018- Posicionando no registro da craplcm criado acima */
         FIND FIRST tt-ret-lancto.
         FIND FIRST craplcm WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm NO-ERROR.
      END.


   IF  VALID-HANDLE(h-b1wgen0200) THEN
       DELETE PROCEDURE h-b1wgen0200.
   
    ASSIGN 
          crablot.nrseqdig = crablot.nrseqdig + 1 
          crablot.qtinfoln = crablot.qtinfoln + 1
          crablot.qtcompln = crablot.qtcompln + 1
          
          crablot.vlinfodb = crablot.vlinfodb + crapcdb.vlcheque - (aux_vlliqnov - aux_vlliqori) 
          crablot.vlcompdb = crablot.vlcompdb + crapcdb.vlcheque - (aux_vlliqnov - aux_vlliqori) 
          
          crapcdb.vlliqdev = aux_vlliqnov.
END PROCEDURE.

PROCEDURE proc_lautom:

   IF   crapcdb.inchqcop <> 1   THEN            /*  Somente para chqs. CREDI  */
        RETURN.
   
   ASSIGN aux_nrdconta = crapcdb.nrctachq
          aux_nrdctabb = crapcdb.nrctachq
          aux_nrdocmto = INT(STRING(crapcdb.nrcheque,"999999") +
                             STRING(crapcdb.nrddigc3,"9")).

   DO WHILE TRUE:
   
      FIND craplau WHERE craplau.cdcooper = glb_cdcooper          AND 
                         craplau.dtmvtolt = crapcdb.dtmvtolt      AND
                         craplau.cdagenci = crapcdb.cdagenci      AND
                         craplau.cdbccxlt = crapcdb.cdbccxlt      AND
                         craplau.nrdolote = crapcdb.nrdolote      AND
                         craplau.nrdctabb = INT(crapcdb.nrctachq) AND
                         craplau.nrdocmto = aux_nrdocmto
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF   NOT AVAILABLE craplau   THEN
           IF   LOCKED craplau   THEN
                DO:
                    PAUSE 2 NO-MESSAGE.
                    NEXT.
                END.
           ELSE
                LEAVE.
      
      ASSIGN craplau.dtdebito = glb_dtmvtolt
             craplau.insitlau = 3.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

END PROCEDURE.

/* .......................................................................... */
