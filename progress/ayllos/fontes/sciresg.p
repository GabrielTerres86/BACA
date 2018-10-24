/*..............................................................................

   Programa: Fontes/sciresg.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Setembro/2004.                  Ultima atualizacao: 16/12/2013 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Atender a opcao "CONTA INV." (Nao Aplicado Conta Investimento)
               da tela ATENDA.

   Alteracoes: 05/07/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm e craplci (Diego).

               10/12/2005 - Atualizar craplcm.nrdctitg (Magui).
                
               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando    
                
               30/06/2008 - Incluida a chave de acesso 
                            (craphis.cdcooper = glb_cdcooper) no "find".
                            - Kbase IT Solutions - Paulo Ricardo Maciel.
                            
               23/11/2009 - Alteracao Codigo Historico (Kbase).
               
               16/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO) 
                            
               19/10/2018 - PRJ450 - Regulatorios de Credito - centralizacao de 
                            estorno de lançamentos na conta corrente              
                            pc_estorna_lancto_prog (Fabio Adriano - AMcom).              
                                           
..............................................................................*/
{ includes/var_online.i }
{ includes/var_atenda.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/b1wgen0200tt.i }

/* Variáveis de uso da BO 200 */
DEF VAR h-b1wgen0200         AS HANDLE                              NO-UNDO.
DEF VAR aux_incrineg         AS INT                                 NO-UNDO.

DEF VAR aux_cdcritic        AS INTE                                NO-UNDO.
DEF VAR aux_dscritic        AS CHAR                                NO-UNDO.

DEF BUTTON btn-resgates      LABEL "Saque".
DEF BUTTON btn-cancelamento  LABEL "Cancelamento".
DEF BUTTON btn-imprime       LABEL "Imprime Extrato".

DEF VAR aux_vlresgat AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"            NO-UNDO.
DEF VAR aux_nrdocmto AS INT     FORMAT "zz,zzz,zz9"                    NO-UNDO.

DEF TEMP-TABLE cratlci                                                 NO-UNDO
    FIELD dtmvtolt LIKE craplci.dtmvtolt
    FIELD dshistor LIKE craphis.dshistor
    FIELD nrdocmto LIKE craplci.nrdocmto
    FIELD indebcre LIKE craphis.indebcre
    FIELD vllanmto LIKE craplci.vllanmto.

DEF QUERY q-lanctos FOR cratlci.
                        
DEF BROWSE b-lanctos QUERY q-lanctos
    DISPLAY cratlci.dtmvtolt   LABEL "Data"       
            cratlci.dshistor   LABEL "Historico"  FORMAT "x(29)"
            cratlci.nrdocmto   LABEL "Documento"  FORMAT "zzzzzzzz9"
            cratlci.indebcre   LABEL "D/C"
            cratlci.vllanmto   LABEL "Valor"
            WITH 5 DOWN WIDTH 78 CENTERED NO-LABELS OVERLAY
                 TITLE " Extrato Conta Investimento ".

FORM b-lanctos               HELP "Use as SETAS para navegar"
     SKIP
     btn-resgates     AT 10  HELP "Pressione ENTER para selecionar"
     btn-cancelamento AT 28  HELP "Pressione ENTER para selecionar"
     btn-imprime      AT 53  HELP "Pressione ENTER para selecionar"
     SKIP(1)
     WITH ROW 10 WIDTH 78 CENTERED NO-LABELS SIDE-LABELS OVERLAY 
          NO-BOX FRAME f_browse.
          
FORM SKIP(1)
     aux_vlresgat AT  5  LABEL "Valor do saque"
                         HELP  "Entre com o valor "
                         VALIDATE(aux_vlresgat > 0,"269 - Valor errado.")
     SKIP                   
     aux_nrdocmto AT 12  LABEL "Documento"
                         HELP  "Entre com o numero do documento"
     SKIP(1)
     WITH ROW 10 WIDTH 50 CENTERED SIDE-LABELS OVERLAY 
          TITLE COLOR NORMAL " Saque/Cancelamento " FRAME f_resg.

ON CHOOSE OF btn-resgates
   DO:
       DO WHILE TRUE:          
          HIDE aux_nrdocmto IN FRAME f_resg.
          UPDATE aux_vlresgat WITH FRAME f_resg.
       
          FIND crapsli WHERE crapsli.cdcooper  = glb_cdcooper           AND
                             crapsli.nrdconta  = tel_nrdconta           AND
                       MONTH(crapsli.dtrefere) = MONTH(glb_dtmvtolt)    AND
                        YEAR(crapsli.dtrefere) = YEAR(glb_dtmvtolt)     AND
                             crapsli.vlsddisp  > 0                    
                             EXCLUSIVE-LOCK NO-ERROR.
                               
          IF   AVAILABLE crapsli   THEN
               DO:
                   IF   crapsli.vlsddisp >= aux_vlresgat   THEN
                        RUN resgates.
                   ELSE
                        glb_cdcritic = 999.  /* somente para diferenciar de 0*/
               END.
          ELSE
               glb_cdcritic = 999.  /* somente para diferenciar de 0*/
                        
          IF   glb_cdcritic > 0   THEN
               DO:
                   MESSAGE "Nao ha saldo suficiente na Conta de Investimento".
                   glb_cdcritic = 0.
                   PAUSE NO-MESSAGE.
                   NEXT.
               END.
               
          LEAVE.
       END. 
   END.
   
ON CHOOSE OF btn-cancelamento
   DO:
       DO WHILE TRUE: 
          HIDE aux_vlresgat IN FRAME f_resg.
          UPDATE aux_nrdocmto WITH FRAME f_resg.
          
          IF   CAN-FIND(craplcm WHERE craplcm.cdcooper = glb_cdcooper    AND
                                      craplcm.dtmvtolt = glb_dtmvtolt    AND
                                      craplcm.cdagenci = 1               AND
                                      craplcm.cdbccxlt = 100             AND
                                      craplcm.nrdolote = 10005           AND
                                      craplcm.nrdctabb = tel_nrdconta    AND
                                      craplcm.nrdocmto = aux_nrdocmto
                                      USE-INDEX craplcm1)   THEN
               RUN cancelamento.
          ELSE
               DO:
                   glb_cdcritic = 90. 
                   RUN fontes/critic.p.
                   BELL.
                   MESSAGE glb_dscritic.
                   glb_cdcritic = 0.
                   NEXT.
               END.
          
          LEAVE.
       END.
   END.
   
ON CHOOSE OF btn-imprime
   DO:

      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         /*
         HIDE aux_flgtarif 
              aux_flgrlchq IN FRAME f_mesref.
         */
         UPDATE aux_dtpesqui WITH FRAME f_mesref.
                                      
         IF   aux_dtpesqui = ?   THEN
              aux_dtpesqui = glb_dtmvtolt - DAY(glb_dtmvtolt) + 1.
         ELSE
         IF  (MONTH(aux_dtpesqui) < aux_nrmesant  AND
              MONTH(aux_dtpesqui) <> 1)            OR
              aux_dtpesqui > glb_dtmvtolt          THEN
              DO:
                  glb_cdcritic = 13.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  glb_cdcritic = 0.
                  NEXT.
              END.

         HIDE FRAME f_mesref NO-PAUSE.
   
         LEAVE.
     END.
     
     RUN fontes/impextcti.p (tel_nrdconta, 
                             aux_dtpesqui,
                             TRUE,  /* rodar */ 
                             TRUE,  /* first*/
                             NO,    /* aux_flgtarif - Tarifa */
                             NO,    /* aux_flgrlchq - Rel.folhas cheque */
                             OUTPUT aux_flgcance).
   END.   

UPDATE aux_dtpesqui WITH FRAME f_data.
IF   aux_dtpesqui = ?   THEN
     aux_dtpesqui = glb_dtmvtolt.
 
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   /* limpeza da tabela do browse */
   /*FOR EACH cratlci.
       DELETE cratlci.
   END.*/
   
   EMPTY TEMP-TABLE cratlci.

   /* leitura dos lancamentos */
   FOR EACH craplci WHERE craplci.cdcooper = glb_cdcooper   AND
                          craplci.nrdconta = tel_nrdconta   AND
                          craplci.dtmvtolt >= aux_dtpesqui  NO-LOCK:
   
       FIND craphis WHERE craphis.cdcooper = glb_cdcooper AND
                          craphis.cdhistor = craplci.cdhistor NO-LOCK NO-ERROR.
                       
       /* criacao da tabela ( para o browse ) */
       CREATE cratlci.
       ASSIGN cratlci.dtmvtolt = craplci.dtmvtolt
              cratlci.dshistor = STRING(craplci.cdhistor,"9999") + "-" +
                                        craphis.dshistor
              cratlci.nrdocmto = craplci.nrdocmto
              cratlci.indebcre = craphis.indebcre
              cratlci.vllanmto = craplci.vllanmto.
   END.   

   OPEN QUERY q-lanctos FOR EACH cratlci BY cratlci.dtmvtolt
                                         BY cratlci.nrdocmto
                                         BY cratlci.indebcre.

   ENABLE b-lanctos  btn-resgates  btn-cancelamento  
          btn-imprime  WITH FRAME f_browse.

   WAIT-FOR CHOOSE OF btn-resgates       OR
            CHOOSE OF btn-cancelamento   OR
            CHOOSE OF btn-imprime.
   
END.

PROCEDURE resgates:

   /* Gera lancamentos Conta-Corrente - CRAPLCM */
   DO WHILE TRUE:
      FIND craplot WHERE craplot.cdcooper = glb_cdcooper    AND
                         craplot.dtmvtolt = glb_dtmvtolt    AND
                         craplot.cdagenci = 1               AND
                         craplot.cdbccxlt = 100             AND
                         craplot.nrdolote = 10005          
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
                           craplot.nrdolote = 10005
                           craplot.tplotmov = 1
                           craplot.cdcooper = glb_cdcooper.
                    VALIDATE craplot.
                END.

      LEAVE.
   END. /* fim do DO WHILE TRUE */
   
   CREATE craplcm.
   ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
          craplcm.cdagenci = craplot.cdagenci
          craplcm.cdbccxlt = craplot.cdbccxlt
          craplcm.nrdolote = craplot.nrdolote
          craplcm.nrdconta = tel_nrdconta
          craplcm.nrdctabb = tel_nrdconta
          craplcm.nrdctitg = STRING(tel_nrdconta,"99999999")
          craplcm.nrdocmto = craplot.nrseqdig + 1
          craplcm.cdhistor = 483
          craplcm.vllanmto = aux_vlresgat
          craplcm.nrseqdig = craplot.nrseqdig + 1
          craplcm.cdcooper = glb_cdcooper
          
          /* Credito */
          craplot.qtinfoln = craplot.qtinfoln + 1
          craplot.qtcompln = craplot.qtcompln + 1
          craplot.vlinfocr = craplot.vlinfocr + aux_vlresgat
          craplot.vlcompcr = craplot.vlcompcr + aux_vlresgat
          craplot.nrseqdig = craplcm.nrseqdig.
   VALIDATE craplcm.
   
   /* Gera lancamentos para a conta Investimento - CRAPLCI */   
   DO WHILE TRUE:
      
      FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                         craplot.dtmvtolt = glb_dtmvtolt   AND
                         craplot.cdagenci = 1              AND
                         craplot.cdbccxlt = 100            AND
                         craplot.nrdolote = 10004 
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                         
      IF   NOT AVAIL craplot   THEN
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
                           craplot.nrdolote = 10004
                           craplot.tplotmov = 29
                           craplot.cdcooper = glb_cdcooper.
                    VALIDATE craplot.
                END.

           LEAVE.
   END. /* Fim do DO WHILE TRUE */
   
   CREATE craplci.
   ASSIGN craplci.dtmvtolt = craplot.dtmvtolt
          craplci.cdagenci = craplot.cdagenci
          craplci.cdbccxlt = craplot.cdbccxlt
          craplci.nrdolote = craplot.nrdolote
          craplci.nrdconta = tel_nrdconta
          craplci.nrdocmto = craplot.nrseqdig + 1
          craplci.cdhistor = 484
          craplci.vllanmto = aux_vlresgat
          craplci.nrseqdig = craplot.nrseqdig + 1
          craplci.cdcooper = glb_cdcooper
          
          craplcm.cdpesqbb = STRING(craplci.nrdocmto)
          
          /* Debito */
          craplot.qtinfoln = craplot.qtinfoln + 1
          craplot.qtcompln = craplot.qtcompln + 1
          craplot.vlinfodb = craplot.vlinfodb + aux_vlresgat
          craplot.vlcompdb = craplot.vlcompdb + aux_vlresgat
          craplot.nrseqdig = craplcm.nrseqdig.
   VALIDATE craplci.
          
   /* Atualizacao CRAPSLI */
   ASSIGN crapsli.vlsddisp = crapsli.vlsddisp - aux_vlresgat.
          
END PROCEDURE.                                         

PROCEDURE cancelamento:

   /* Lancamentos Conta Corrente */
   FIND craplcm WHERE craplcm.cdcooper = glb_cdcooper   AND
                      craplcm.dtmvtolt = glb_dtmvtolt   AND
                      craplcm.cdagenci = 1              AND
                      craplcm.cdbccxlt = 100            AND
                      craplcm.nrdolote = 10005          AND
                      craplcm.nrdctabb = tel_nrdconta   AND
                      craplcm.nrdocmto = aux_nrdocmto   
                      USE-INDEX craplcm1 EXCLUSIVE-LOCK NO-ERROR.
                      
   ASSIGN aux_vlresgat = craplcm.vllanmto.
                      
   FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                      craplot.dtmvtolt = glb_dtmvtolt   AND
                      craplot.cdagenci = 1              AND
                      craplot.cdbccxlt = 100            AND
                      craplot.nrdolote = 10005          EXCLUSIVE-LOCK NO-ERROR.
                      
   ASSIGN craplot.qtcompln = craplot.qtcompln - 1
          craplot.qtinfoln = craplot.qtinfoln - 1
          craplot.vlcompcr = craplot.vlcompcr - craplcm.vllanmto
          craplot.vlinfocr = craplot.vlinfocr - craplcm.vllanmto.
          
   IF   craplot.qtcompln = 0   AND   craplot.qtinfoln = 0   AND
        craplot.vlcompdb = 0   AND   craplot.vlinfodb = 0   AND
        craplot.vlcompcr = 0   AND   craplot.vlinfocr = 0   THEN
        DELETE craplot.
        
   /* Eliminar os lancamentos CI */
   FIND craplci WHERE craplci.cdcooper = glb_cdcooper   AND
                      craplci.dtmvtolt = glb_dtmvtolt   AND
                      craplci.cdagenci = 1              AND
                      craplci.cdbccxlt = 100            AND
                      craplci.nrdolote = 10004          AND
                      craplci.nrdocmto = aux_nrdocmto   EXCLUSIVE-LOCK NO-ERROR. 
                      /*INTEGER(craplcm.cdpesqbb). */
                      
   FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                      craplot.dtmvtolt = glb_dtmvtolt   AND
                      craplot.cdagenci = 1              AND
                      craplot.cdbccxlt = 100            AND
                      craplot.nrdolote = 10004          AND
                      craplot.tplotmov = 29             EXCLUSIVE-LOCK NO-ERROR.
                      
   DELETE craplci.
   
   ASSIGN craplot.qtcompln = craplot.qtcompln - 1
          craplot.qtinfoln = craplot.qtinfoln - 1
          craplot.vlcompdb = craplot.vlcompdb - craplcm.vllanmto
          craplot.vlinfodb = craplot.vlinfodb - craplcm.vllanmto.
          
   IF   craplot.qtcompln = 0   AND   craplot.qtinfoln = 0   AND
        craplot.vlcompdb = 0   AND   craplot.vlinfodb = 0   AND
        craplot.vlcompcr = 0   AND   craplot.vlinfocr = 0   THEN
        DELETE craplot.
   
   /*DELETE craplcm.*/
   
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
    
   IF  VALID-HANDLE(h-b1wgen0200) THEN
       DELETE PROCEDURE h-b1wgen0200.
                      
   
   /* Atualizacao CRAPSLI */
   FIND crapsli WHERE crapsli.cdcooper  = glb_cdcooper          AND
                      crapsli.nrdconta  = tel_nrdconta          AND
                MONTH(crapsli.dtrefere) = MONTH(glb_dtmvtolt)   AND
                 YEAR(crapsli.dtrefere) = YEAR(glb_dtmvtolt)   
                      EXCLUSIVE-LOCK NO-ERROR.
   
   ASSIGN crapsli.vlsddisp = crapsli.vlsddisp + aux_vlresgat.

END PROCEDURE.

/*............................................................................*/

