/* ..........................................................................

   Programa: Fontes/crps268.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah
   Data    : Julho/1999                      Ultima atualizacao: 12/06/2015

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 001.
               Efetuar os debitos referentes a seguros de vida em grupo.

   Alteracoes: 30/06/2005 - Alimentado campo cdcooper das tabelas craplot
                            craplcm e crapavs (Diego).

               10/12/2005 - Atualizar craplcm.nrdctitg (Magui).
                
               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando     
               
               20/01/2014 - Incluir VALIDATE craplot, craplcm, crapavs (Lucas R)
               
               04/02/2015 - Ajuste para debitar a primeira parcela conforme a 
                            a data dtprideb SD-235552 (Odirlei-AMcom).
                            
               04/03/2015 - Alterado validação para alterar a data de debito
                            caso a data atual de bedito seja menor ou igual a
                            data do movimento para garatir não será debitdo duas
                            vezes (Odirlei-AMcom)
                         
               12/06/2015 - Ajuste para debitar na renovacao do seguro de vida.
                            (James/Thiago)
............................................................................. */

{ includes/var_batch.i {1} }

DEF        VAR aux_cdhistor AS INT                                  NO-UNDO.
DEF        VAR aux_nrctrseg AS INT                                  NO-UNDO.

DEF        VAR aux_dtmvtolt AS DATE                                 NO-UNDO.
DEF        VAR aux_qtmesano AS INTE                                 NO-UNDO.
DEF        VAR aux_tpmesano AS CHAR                                 NO-UNDO.
DEF        VAR aux_dtcalcul AS DATE                                 NO-UNDO.
DEF        VAR aux_dtdebito AS DATE                                 NO-UNDO.
DEF        VAR aux_flgdebta AS LOG                                  NO-UNDO.

glb_cdprogra = "crps268".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

ASSIGN aux_nrctrseg = INTEGER(glb_dsrestar).

FOR EACH crapseg WHERE crapseg.cdcooper  = glb_cdcooper  AND
                       crapseg.nrdconta >= glb_nrctares  AND
                       crapseg.nrctrseg > aux_nrctrseg   AND
                       crapseg.tpseguro = 3              AND
                       crapseg.cdsitseg = 1              AND
                       crapseg.indebito = 0
                       USE-INDEX crapseg2 
                       TRANSACTION ON ERROR UNDO, RETURN:

    ASSIGN aux_flgdebta = FALSE.

    /* Condicoes para verificar se ocorre o debito do seguro de vida */
    /* Contratacao do Seguro de Vida */
    IF crapseg.dtprideb = glb_dtmvtolt THEN
       ASSIGN aux_flgdebta = TRUE.
    ELSE
    /* Renovacao do Seguro de Vida */
    IF MONTH(crapseg.dtrenova) = MONTH(glb_dtmvtolt) THEN
       DO:
           /* Mensal */
           IF MONTH(glb_dtmvtolt) <> MONTH(glb_dtmvtopr) THEN
              DO:
                  /* Antecipa o debito da parcela */
                  IF DAY(crapseg.dtrenova) <= DAY(glb_dtultdia) THEN
                     ASSIGN aux_flgdebta = TRUE.
              END.
           ELSE
           /* Diario */
           IF DAY(crapseg.dtrenova) <= DAY(glb_dtmvtolt) THEN
              ASSIGN aux_flgdebta = TRUE.
       END.
    ELSE
    /* Mensal */
    IF MONTH(glb_dtmvtolt) <> MONTH(glb_dtmvtopr) THEN
       DO:
           IF crapseg.dtdebito <= glb_dtultdia THEN
              ASSIGN aux_flgdebta = TRUE.
       END.
    ELSE
    /* Diario - Vencimento da parcela */
    IF crapseg.dtdebito <= glb_dtmvtolt THEN
       ASSIGN aux_flgdebta = TRUE.

    /* Condicao para verificar se debita */
    IF NOT aux_flgdebta THEN
       NEXT.
    
    /*FIND crapass OF crapseg NO-LOCK NO-ERROR.*/
    FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                       crapass.nrdconta = crapseg.nrdconta 
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapass THEN
         DO:
             glb_cdcritic = 251.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                " - " + glb_cdprogra + "' --> '" +
                                glb_dscritic + " Conta: " +
                                STRING(crapseg.nrdconta,"zzzz,zzz,9") +
                                " >> log/proc_batch.log").
             glb_cdcritic = 0.
             UNDO, RETURN.
         END.

    /*FIND crapcsg OF crapseg NO-LOCK NO-ERROR.*/
    FIND crapcsg WHERE crapcsg.cdcooper = glb_cdcooper AND
                       crapcsg.cdsegura = crapseg.cdsegura
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapcsg   THEN
         DO:
             glb_cdcritic = 556.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                               glb_cdprogra + "' --> '" + glb_dscritic +
                               " Conta: " +
                               STRING(crapseg.nrdconta,"zzzz,zzz,9") + "/" +
                               STRING(crapseg.nrctrseg,"zzzzz,zz9") +
                               " Seguradora: " +
                               STRING(crapseg.cdsegura) +
                               " >> log/proc_batch.log").
             glb_cdcritic = 0.
             UNDO, RETURN.
         END.

    aux_cdhistor = crapcsg.cdhstaut[2].

    IF   aux_cdhistor = 0   THEN                     /*  Parcela Mensal  */
         DO:
             glb_cdcritic = 581.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                               glb_cdprogra + "' --> '" + glb_dscritic +
                               " PARCELA MENSAL - Seguradora " +
                               STRING(crapseg.cdsegura) +
                               " CONTA = " + STRING(crapseg.nrdconta) +
                               " CTRO = " + STRING(crapseg.nrctrseg) +
                               " >> log/proc_batch.log").
             glb_cdcritic = 0.
             UNDO, RETURN.
         END.

    /*  Efetua o lancamento a debito do valor do seguro  */

    FIND craplot WHERE craplot.cdcooper = glb_cdcooper  AND
                       craplot.dtmvtolt = glb_dtmvtolt  AND
                       craplot.cdagenci = 1             AND
                       craplot.cdbccxlt = 100           AND
                       craplot.nrdolote = 4154
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF   NOT AVAILABLE craplot   THEN
         DO:
             CREATE craplot.
             ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                    craplot.cdagenci = 1
                    craplot.cdbccxlt = 100
                    craplot.nrdolote = 4154
                    craplot.tplotmov = 1
                    craplot.nrseqdig = 0
                    craplot.vlcompcr = 0
                    craplot.vlinfocr = 0
                    craplot.cdcooper = glb_cdcooper.
         END.

    CREATE craplcm.
    ASSIGN craplcm.cdagenci = craplot.cdagenci
           craplcm.cdbccxlt = craplot.cdbccxlt
           craplcm.cdhistor = aux_cdhistor
           craplcm.dtmvtolt = glb_dtmvtolt
           craplcm.cdpesqbb = STRING(crapseg.cdsegura)
           craplcm.nrdconta = crapseg.nrdconta
           craplcm.nrdctabb = crapseg.nrdconta
           craplcm.nrdctitg = STRING(crapseg.nrdconta,"99999999")
           craplcm.nrdocmto = crapseg.nrctrseg
           craplcm.nrdolote = craplot.nrdolote
           craplcm.nrseqdig = craplot.nrseqdig + 1
           craplcm.vllanmto = crapseg.vlpreseg
           craplcm.cdcooper = glb_cdcooper
 
           crapseg.dtultpag = glb_dtmvtolt
           crapseg.qtprepag = crapseg.qtprepag + 1
           crapseg.qtprevig = crapseg.qtprevig + 1
           crapseg.vlprepag = crapseg.vlprepag + crapseg.vlpreseg
           crapseg.indebito = 1
 
           craplot.nrseqdig = craplot.nrseqdig + 1
           craplot.qtcompln = craplot.qtcompln + 1
           craplot.qtinfoln = craplot.qtcompln
           craplot.vlcompdb = craplot.vlcompdb + craplcm.vllanmto
           craplot.vlinfodb = craplot.vlcompdb.
           
    VALIDATE craplot.
    VALIDATE craplcm.

    /* não é necessario validar e mudar a data de debito se for o debito
       da primeira parcela ou se a data do debito já esteja menor ou igual 
       a data de movimento para garantir que não irá debitar duas vezes */
    IF crapseg.dtprideb <> glb_dtmvtolt THEN
       DO:
           /* Se o debito for dias 29, 30 ou 31, debitara sempre no dia 28 */    
           IF   DAY(crapseg.dtdebito) > 28 THEN
                crapseg.dtdebito =
                        DATE(MONTH(crapseg.dtdebito),28,YEAR(crapseg.dtdebito)).
                  
           RUN fontes/calcdata.p (crapseg.dtdebito,1,"M", 0, OUTPUT crapseg.dtdebito).
       END.
        
    CREATE crapavs.
    ASSIGN crapavs.cdagenci = crapass.cdagenci
           crapavs.cdempres = 0
           crapavs.cdhistor = craplcm.cdhistor
           crapavs.cdsecext = crapass.cdsecext
           crapavs.dtdebito = glb_dtmvtolt
           crapavs.dtmvtolt = glb_dtmvtolt
           crapavs.dtrefere = glb_dtmvtolt
           crapavs.insitavs = 0
           crapavs.nrdconta = crapseg.nrdconta
           crapavs.nrdocmto = craplcm.nrdocmto 
           crapavs.nrseqdig = craplcm.nrseqdig 
           crapavs.tpdaviso = 2
           crapavs.vldebito = 0
           crapavs.vlestdif = 0
           crapavs.vllanmto = craplcm.vllanmto
           crapavs.flgproce = FALSE
           crapavs.cdcooper = glb_cdcooper.

    VALIDATE crapavs.

    DO WHILE TRUE:

       FIND crapres WHERE crapres.cdcooper = glb_cdcooper  AND
                          crapres.cdprogra = glb_cdprogra
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE crapres   THEN
            IF   LOCKED crapres   THEN
                 DO:
                     PAUSE 2 NO-MESSAGE.
                     NEXT.
                 END.
            ELSE
                 DO:
                     glb_cdcritic = 151.
                     RUN fontes/critic.p.
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '" +
                                      glb_dscritic + " >> log/proc_batch.log").
                     UNDO, RETURN.
                END.
       LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    ASSIGN crapres.nrdconta = crapseg.nrdconta
           crapres.dsrestar = STRING(crapseg.nrctrseg,"99999999").

END. /* FOR EACH crapseg */

RUN fontes/fimprg.p.

/* .......................................................................... */

