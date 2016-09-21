/* ..........................................................................

   Programa: Fontes/crps201.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Junho/97.                       Ultima atualizacao: 16/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch)
   Objetivo  : Atende a solicitacao .
               Gerar estatistica  de talonarios.

   Alteracoes: 03/10/97 - Alterado para utilizar rotina padrao de calculo de
                          talonarios e ler crapreq utilizando o dia do movi-
                          mento e tipo de requisicao igual 1.
                          
               03/09/98 - Alterar para colocar numero de folhas (Odair).        
               14/08/00 - Incluir atualizacao de 2 novos campos
                          .qtrttbc e .qtsltlbc (Margarete)

             22/10/2004 - Tratar conta de integracao (Margarete).

             08/06/2005 - Tratar tipo 17 e 18(Mirtes) 

             30/06/2005 - Alimentado campo cdcooper da tabela crapger (Diego).
             
             16/02/2006 - Unificacao dos bancos - SQLWorks - Eder

             29/08/2008 - Comentar taloes retirados do log (Magui).
             
             22/01/2009 - Alteracao cdempres (Diego).
             
             08/10/2009 - Adaptacoes projeto IF CECRED (Guilherme).
             
             17/05/2010 - Tratar crapger.cdempres com 9999 em vez de 999
                          (Diego).
             
             27/09/2010 - Acertar atuazicoes para IF CECRED (Magui).
             
             16/01/2014 - Inclusao de VALIDATE crapger (Carlos)
............................................................................. */

{ includes/var_batch.i }

DEF   VAR aux_qtretemp_bb   AS INT   EXTENT 999                        NO-UNDO.
DEF   VAR aux_qtsolemp_bb   AS INT   EXTENT 999                        NO-UNDO.
DEF   VAR aux_qtsolpac_bb   AS INT   EXTENT 999                        NO-UNDO.
DEF   VAR aux_qtretpac_bb   AS INT   EXTENT 999                        NO-UNDO.

DEF   VAR aux_qtretemp_bc   AS INT   EXTENT 999                        NO-UNDO.
DEF   VAR aux_qtsolemp_bc   AS INT   EXTENT 999                        NO-UNDO.
DEF   VAR aux_qtsolpac_bc   AS INT   EXTENT 999                        NO-UNDO.
DEF   VAR aux_qtretpac_bc   AS INT   EXTENT 999                        NO-UNDO.

DEF   VAR aux_qtretemp_ct   AS INT   EXTENT 999                        NO-UNDO.
DEF   VAR aux_qtsolemp_ct   AS INT   EXTENT 999                        NO-UNDO.
DEF   VAR aux_qtsolpac_ct   AS INT   EXTENT 999                        NO-UNDO.
DEF   VAR aux_qtretpac_ct   AS INT   EXTENT 999                        NO-UNDO.

DEF   VAR aux_regexist      AS LOGICAL                                 NO-UNDO.
DEF   VAR aux_dtdiault      AS DATE                                    NO-UNDO.
DEF   VAR aux_contador      AS INT                                     NO-UNDO.
DEF   VAR aux_nrinicta      AS INT                                     NO-UNDO.
DEF   VAR aux_nrfincta      AS INT                                     NO-UNDO.
DEF   VAR aux_qttalona      AS INT                                     NO-UNDO.

DEF   VAR aux_cdempres      AS INT                                     NO-UNDO.

glb_cdprogra = "crps201".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

ASSIGN aux_dtdiault = ((DATE(MONTH(glb_dtmvtolt),28,YEAR(glb_dtmvtolt)) + 4) -
                                   DAY(DATE(MONTH(glb_dtmvtolt),28,
                                             YEAR(glb_dtmvtolt)) + 4))

       aux_regexist = FALSE
       glb_nrfolhas = 20.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '" +
                           glb_dscritic + " >> log/proc_batch.log").
         RETURN.
     END.

FOR EACH crapreq WHERE crapreq.cdcooper = glb_cdcooper  AND
                       crapreq.tprequis = 1             AND
                       crapreq.dtmvtolt = glb_dtmvtolt  NO-LOCK:

    glb_nrcalcul = crapreq.nrfinchq.

    RUN fontes/numtal.p.

    aux_nrfincta = glb_nrtalchq.

    glb_nrcalcul = crapreq.nrinichq.

    RUN fontes/numtal.p.

    aux_nrinicta = glb_nrtalchq.

    aux_qttalona = (aux_nrfincta - aux_nrinicta) + 1.
    /***************
    if   aux_qttalona > 10 then
         DO:
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '" +
                               "RETIROU MAIS DE 10 TALOES - CTA = " +
                               STRING(crapreq.nrdconta,"zzzz,zz9,9") + 
                               " CHQ. INICIO = " +
                               STRING(crapreq.nrinichq,"zzzz,zz9,9") +
                               " CHQ. FINAL = " +
                               STRING(crapreq.nrfinchq,"zzzz,zz9,9") +
                               " QTD. TALOES = " +
                               STRING(aux_qttalona,"zzzzz9") +
                               " >> log/proc_batch.log").
         END.
    **********************/
    aux_regexist = TRUE.

    FIND crapass WHERE crapass.cdcooper = glb_cdcooper      AND
                       crapass.nrdconta = crapreq.nrdconta  NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapass THEN
         DO:
             glb_cdcritic = 9.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '" +
                               STRING(crapreq.nrdconta,"zzzz,zz9,9") +
                               glb_dscritic + " >> log/proc_batch.log").
             RETURN.
         END.

    IF   crapass.inpessoa = 1   THEN 
         DO:
             FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper       AND
                                crapttl.nrdconta = crapass.nrdconta   AND
                                crapttl.idseqttl = 1 NO-LOCK NO-ERROR.

             IF   AVAIL crapttl  THEN
                  ASSIGN aux_cdempres = crapttl.cdempres.
         END.
    ELSE
         DO:
             FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper  AND
                                crapjur.nrdconta = crapass.nrdconta
                                NO-LOCK NO-ERROR.

             IF   AVAIL crapjur  THEN
                  ASSIGN aux_cdempres = crapjur.cdempres.
         END.
    
    IF  crapreq.cdtipcta < 5    OR 
       (crapreq.cdtipcta > 11   AND
        crapreq.cdtipcta < 16)  THEN
        ASSIGN aux_qtsolemp_bb[aux_cdempres] =
                        aux_qtsolemp_bb[aux_cdempres] + crapreq.qtreqtal
               aux_qtsolpac_bb[crapass.cdagenci] =
                        aux_qtsolpac_bb[crapass.cdagenci] + crapreq.qtreqtal

               aux_qtretemp_bb[aux_cdempres] =
                        aux_qtretemp_bb[aux_cdempres] +
                                     IF crapreq.nrfinchq >  0
                                        THEN aux_qttalona
                                        ELSE 0
               aux_qtretpac_bb[crapass.cdagenci] = 
                        aux_qtretpac_bb[crapass.cdagenci] +
                                     IF crapreq.nrfinchq >  0
                                        THEN aux_qttalona
                                        ELSE 0.
    
    IF  crapreq.cdtipcta > 7    AND
        crapreq.cdtipcta < 12   THEN
        DO:
        IF  crapass.cdbcochq = crapcop.cdbcoctl  THEN /* IF CECRED */
            DO:
            ASSIGN aux_qtsolemp_ct[aux_cdempres] =
                            aux_qtsolemp_ct[aux_cdempres] + crapreq.qtreqtal
                   aux_qtsolpac_ct[crapass.cdagenci] =
                            aux_qtsolpac_ct[crapass.cdagenci] + crapreq.qtreqtal

                   aux_qtretemp_ct[aux_cdempres] =
                            aux_qtretemp_ct[aux_cdempres] +
                                         IF crapreq.nrfinchq >  0
                                            THEN aux_qttalona
                                            ELSE 0
                   aux_qtretpac_ct[crapass.cdagenci] = 
                            aux_qtretpac_ct[crapass.cdagenci] +
                                         IF crapreq.nrfinchq >  0
                                            THEN aux_qttalona
                                            ELSE 0.

            END.
        ELSE /* BANCOOB */
            DO:
            ASSIGN aux_qtsolemp_bc[aux_cdempres] =
                            aux_qtsolemp_bc[aux_cdempres] + crapreq.qtreqtal
                   aux_qtsolpac_bc[crapass.cdagenci] =
                            aux_qtsolpac_bc[crapass.cdagenci] + crapreq.qtreqtal
    
                   aux_qtretemp_bc[aux_cdempres] =
                            aux_qtretemp_bc[aux_cdempres] +
                                         IF crapreq.nrfinchq >  0
                                            THEN aux_qttalona
                                            ELSE 0
                   aux_qtretpac_bc[crapass.cdagenci] = 
                            aux_qtretpac_bc[crapass.cdagenci] +
                                         IF crapreq.nrfinchq >  0
                                            THEN aux_qttalona
                                            ELSE 0.
        
            END.
        END.
END.  /*  Fim do FOR EACH -- Leitura das requisicoes  */

IF   NOT aux_regexist THEN
     DO:
         RUN fontes/fimprg.p.
         RETURN.
     END.

glb_nrctares = glb_nrctares + 1.

DO aux_contador = glb_nrctares TO 998:

   ASSIGN aux_qtsolemp_bb[999] =
                       aux_qtsolemp_bb[999] + aux_qtsolemp_bb[aux_contador]
          aux_qtsolpac_bb[999] = 
                       aux_qtsolpac_bb[999] + aux_qtsolpac_bb[aux_contador]
          aux_qtretemp_bb[999] =
                       aux_qtretemp_bb[999] + aux_qtretemp_bb[aux_contador]
          aux_qtretpac_bb[999] = 
                       aux_qtretpac_bb[999] + aux_qtretpac_bb[aux_contador]
          
          aux_qtsolemp_bc[999] =
                       aux_qtsolemp_bc[999] + aux_qtsolemp_bc[aux_contador]
          aux_qtsolpac_bc[999] = 
                       aux_qtsolpac_bc[999] + aux_qtsolpac_bc[aux_contador]
          aux_qtretemp_bc[999] =
                       aux_qtretemp_bc[999] + aux_qtretemp_bc[aux_contador]
          aux_qtretpac_bc[999] = 
                       aux_qtretpac_bc[999] + aux_qtretpac_bc[aux_contador]

          aux_qtsolemp_ct[999] =
                       aux_qtsolemp_ct[999] + aux_qtsolemp_ct[aux_contador]
          aux_qtsolpac_ct[999] = 
                       aux_qtsolpac_ct[999] + aux_qtsolpac_ct[aux_contador]
          aux_qtretemp_ct[999] =
                       aux_qtretemp_ct[999] + aux_qtretemp_ct[aux_contador]
          aux_qtretpac_ct[999] = 
                       aux_qtretpac_ct[999] + aux_qtretpac_ct[aux_contador].

   IF   aux_qtsolpac_bb[aux_contador] > 0   OR
        aux_qtretpac_bb[aux_contador] > 0   OR

        aux_qtsolpac_bc[aux_contador] > 0   OR
        aux_qtretpac_bc[aux_contador] > 0   OR

        aux_qtsolpac_ct[aux_contador] > 0   OR
        aux_qtretpac_ct[aux_contador] > 0   THEN
        DO:
            DO  WHILE TRUE:

                FIND crapger WHERE crapger.cdcooper = glb_cdcooper  AND
                                   crapger.dtrefere = aux_dtdiault  AND
                                   crapger.cdempres = 0             AND
                                   crapger.cdagenci = aux_contador
                                   EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

                IF   NOT AVAILABLE crapger THEN
                     IF  LOCKED crapger THEN
                         DO:
                             PAUSE 1 NO-MESSAGE.
                             NEXT.
                         END.
                     ELSE
                         DO:
                             CREATE crapger.
                             ASSIGN crapger.dtrefere = aux_dtdiault
                                    crapger.cdagenci = aux_contador
                                    crapger.cdempres = 0
                                    crapger.cdcooper = glb_cdcooper.
                             VALIDATE crapger.
                         END.
                LEAVE.
            END. /* FIM DO WHILE */

            ASSIGN crapger.qtrettal = crapger.qtrettal +
                                      aux_qtretpac_bb[aux_contador]
                   crapger.qtsoltal = crapger.qtsoltal +
                                      aux_qtsolpac_bb[aux_contador]
                   
                   crapger.qtrttlbc = crapger.qtrttlbc +
                                      aux_qtretpac_bc[aux_contador]
                   crapger.qtsltlbc = crapger.qtsltlbc +
                                      aux_qtsolpac_bc[aux_contador]
                   
                   crapger.qtrttlct = crapger.qtrttlct +
                                      aux_qtretpac_ct[aux_contador]
                   crapger.qtsltlct = crapger.qtsltlct +
                                      aux_qtsolpac_ct[aux_contador].


        END.

   IF   aux_qtsolemp_bb[aux_contador] > 0   OR
        aux_qtretemp_bb[aux_contador] > 0   OR   
        
        aux_qtsolemp_bc[aux_contador] > 0   OR   
        aux_qtretemp_bc[aux_contador] > 0   OR
        
        aux_qtsolemp_ct[aux_contador] > 0   OR   
        aux_qtretemp_ct[aux_contador] > 0   THEN
        DO:
            DO  WHILE TRUE:

                FIND crapger WHERE crapger.cdcooper = glb_cdcooper  AND
                                   crapger.dtrefere = aux_dtdiault  AND
                                   crapger.cdempres = aux_contador  AND
                                   crapger.cdagenci = 0
                                   EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

                IF   NOT AVAILABLE crapger THEN
                     IF  LOCKED crapger THEN
                         DO:
                             PAUSE 1 NO-MESSAGE.
                             NEXT.
                         END.
                     ELSE
                         DO:
                             CREATE crapger.
                             ASSIGN crapger.dtrefere = aux_dtdiault
                                    crapger.cdagenci = 0
                                    crapger.cdempres = aux_contador
                                    crapger.cdcooper = glb_cdcooper.
                             VALIDATE crapger.
                         END.
                LEAVE.
            END. /* DO WHILE TRUE */

            ASSIGN crapger.qtrettal = crapger.qtrettal +
                                      aux_qtretemp_bb[aux_contador]
                   crapger.qtsoltal = crapger.qtsoltal +
                                      aux_qtsolemp_bb[aux_contador]
                   
                   crapger.qtrttlbc = crapger.qtrttlbc +
                                      aux_qtretemp_bc[aux_contador]
                   crapger.qtsltlbc = crapger.qtsltlbc +
                                      aux_qtsolemp_bc[aux_contador]
                   
                   crapger.qtrttlct = crapger.qtrttlct +
                                      aux_qtretemp_ct[aux_contador]
                   crapger.qtsltlct = crapger.qtsltlct +
                                      aux_qtsolemp_ct[aux_contador].

        END.

   DO WHILE TRUE:

      FIND crapres WHERE crapres.cdcooper = glb_cdcooper    AND 
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
                                       glb_dscritic +
                                       " >> log/proc_batch.log").
                    UNDO, RETURN.
                END.
           ELSE
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   crapres.nrdconta = aux_contador.

END.  /*  Fim do DO .. TO  */

DO  WHILE TRUE:

    FIND crapger WHERE crapger.cdcooper = glb_cdcooper  AND
                       crapger.dtrefere = aux_dtdiault  AND
                       crapger.cdempres = 9999          AND
                       crapger.cdagenci = 0
                       EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

    IF   NOT AVAILABLE crapger THEN
         IF  LOCKED crapger THEN
             DO:
                 PAUSE 1 NO-MESSAGE.
                 NEXT.
             END.
         ELSE
             DO:
                 CREATE crapger.
                 ASSIGN crapger.dtrefere = aux_dtdiault
                        crapger.cdagenci = 0
                        crapger.cdempres = 9999
                        crapger.cdcooper = glb_cdcooper.
                 VALIDATE crapger.
             END.
    LEAVE.

END. /* DO WHILE TRUE */

ASSIGN crapger.qtrettal = crapger.qtrettal + aux_qtretemp_bb[999]
       crapger.qtsoltal = crapger.qtsoltal + aux_qtsolemp_bb[999]
       
       crapger.qtrttlbc = crapger.qtrttlbc + aux_qtretemp_bc[999]
       crapger.qtsltlbc = crapger.qtsltlbc + aux_qtsolemp_bc[999]
       
       crapger.qtrttlct = crapger.qtrttlct + aux_qtretemp_ct[999]
       crapger.qtsltlct = crapger.qtsltlct + aux_qtsolemp_ct[999].

DO  WHILE TRUE:

    FIND crapger WHERE crapger.cdcooper = glb_cdcooper  AND
                       crapger.dtrefere = aux_dtdiault  AND
                       crapger.cdempres = 0             AND
                       crapger.cdagenci = 0
                       EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

    IF   NOT AVAILABLE crapger THEN
         IF  LOCKED crapger THEN
             DO:
                 PAUSE 1 NO-MESSAGE.
                 NEXT.
             END.
         ELSE
             DO:
                 CREATE crapger.
                 ASSIGN crapger.dtrefere = aux_dtdiault
                        crapger.cdagenci = 0
                        crapger.cdempres = 0
                        crapger.cdcooper = glb_cdcooper.
                 VALIDATE crapger.
             END.
    LEAVE.

END. /* DO WHILE TRUE */

ASSIGN crapger.qtrettal = crapger.qtrettal + aux_qtretemp_bb[999]
       crapger.qtsoltal = crapger.qtsoltal + aux_qtsolemp_bb[999]
       
       crapger.qtrttlbc = crapger.qtrttlbc + aux_qtretemp_bc[999]
       crapger.qtsltlbc = crapger.qtsltlbc + aux_qtsolemp_bc[999]
       
       crapger.qtrttlct = crapger.qtrttlct + aux_qtretemp_ct[999]
       crapger.qtsltlct = crapger.qtsltlct + aux_qtsolemp_ct[999].

RUN fontes/fimprg.p.

/* .......................................................................... */

