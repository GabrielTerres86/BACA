/* .............................................................................

   Programa: Fontes/crps156.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Abril/96.                       Ultima atualizacao: 11/03/2014

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Solicitacao: 005 (Finalizacao do processo).
               Efetuar o resgate das poupancas programas e credita-los em conta-
               corrente.
               Emite relatorio 125.

   Alteracoes: 27/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               21/05/1999 - Consistir se a aplicacao esta bloqueada (Deborah).

               04/01/2000 - Nao gerar pedido de impressao (Deborah).

               11/02/2000 - Gerar pedido de impressao (Deborah).  
               
               01/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).
               
               21/08/2001 - Tratamento do saldo antecipado. (Ze Eduardo).

               09/02/2004 - Se resgate total zerar vlabcpmf (Margarete).
               
               12/05/2004 - Quando resgate parcial e tiver vlabcpmf deixar
                            saldo para pagto do IR no aniversario (Margarete).
                            
               13/08/2004 - Se tem vlabcpmf nao deixar resgatar a parte
                            do abono (Margarete). 

               15/09/2004 - Tratamento Conta Investimento(Mirtes)
               
               09/11/2004 - Aumentado tamanho do campo do numero da aplicacao
                            para 7 posicoes, na leitura da tabela (Evandro).
                            
               29/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm, craplpp, craprej, craplci, crapsli e do
                            buffer crablot (Diego).

               10/12/2005 - Atualizar craplcm.nrdctitg (Magui).
               
               15/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               29/04/2008 - Apos gerar lancamento na conta investimento passar
                            a situacao da rpp para 5 (resgate por vencimento)
                            (Guilherme).
               
               12/02/2010 - Quando o resgate da poupança for por vencimento da 
                            mesma e estiver bloqueada, dar a critica 828 e 
                            fazer o resgate da poupança(Guilherme).

               14/06/2011 - Tratar poupanca inexistente.
               
               09/10/2013 - Tratamento para Imunidade Tributaria (Ze).
               
               05/11/2013 - Instanciado h-b1wgen0159 fora da poupanca.i
                            (Lucas R.)
                            
               16/01/2014 - Inclusao de VALIDATE craplot, craplcm, craplpp, 
                            craprej, crablot, craplci e crapsli (Carlos)
                            
               11/03/2014 - Incluido ordenacao por craplrg.tpresgat no for each
                            craplrg. (Reinert)
............................................................................. */

DEF STREAM str_1.   /*  Para o relatorio dos resgates  */

{ includes/var_batch.i }

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "]      NO-UNDO.

DEF        VAR rel_qtdrejln AS INT                                   NO-UNDO.
DEF        VAR rel_vldrejdb AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vldrejcr AS DECIMAL                               NO-UNDO.

DEF        VAR aux_vlresgat AS DECIMAL                               NO-UNDO.
DEF        VAR aux_saldorpp AS DECIMAL                               NO-UNDO.

DEF        VAR aux_vlmoefix AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlorimfx AS DECIMAL DECIMALS 8                    NO-UNDO.

DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgresga AS LOGICAL                               NO-UNDO.
DEF        VAR aux_vlirabap AS DECIMAL                               NO-UNDO.
DEF        VAR aux_dtrefere AS DATE                                  NO-UNDO.
DEF        VAR h-b1wgen0159 AS HANDLE                                NO-UNDO.

DEF TEMP-TABLE tt-erro NO-UNDO LIKE craperr.

DEF        BUFFER crablot FOR craplot.

ASSIGN glb_cdprogra = "crps156"
       glb_cdcritic = 0
       aux_vlmoefix = 0
       aux_regexist = FALSE.

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

FORM craplot.dtmvtolt AT  1 FORMAT "99/99/9999" LABEL "DATA"
     craplot.cdagenci AT 18 FORMAT "zz9"        LABEL "AGENCIA"
     craplot.cdbccxlt AT 33 FORMAT "zz9"        LABEL "BANCO/CAIXA"
     craplot.nrdolote AT 52 FORMAT "zzz,zz9"    LABEL "LOTE"
     craplot.tplotmov AT 66 FORMAT "99"         LABEL "TIPO"
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE SIDE-LABELS NO-LABELS WIDTH 132 FRAME f_resgate.

FORM craprej.nrdconta AT  1 FORMAT "zzzz,zzz,9"          LABEL "CONTA/DV"
     craprej.nraplica AT 13 FORMAT "zz,zzz,zz9"          LABEL "POUPANCA"
     craprej.dtdaviso AT 24 FORMAT "99/99/9999"          LABEL "AVISO"
     craprej.vldaviso AT 35 FORMAT "zzz,zzz,zz9.99"      LABEL "RESGATE"
     craprej.vlsdapli AT 50 FORMAT "zzz,zzz,zz9.99"      LABEL "SALDO"
     craprej.vllanmto AT 66 FORMAT "zzz,zzz,zz9.99"      LABEL "CREDITADO"
     glb_dscritic     AT 82 FORMAT "x(40)"               LABEL "CRITICA"
     WITH NO-BOX NO-ATTR-SPACE DOWN NO-LABELS WIDTH 132 FRAME f_rejeitados.

FORM SKIP(1)
     "QTD               DEBITO               CREDITO" AT 26
     SKIP
     "INTEGRADOS: "     AT  9
     craplot.qtcompln   AT 22 FORMAT "zzz,zz9-"
     craplot.vlcompdb   AT 32 FORMAT "zzz,zzz,zzz,zz9.99-"
     craplot.vlcompcr   AT 54 FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP(1)
     "REJEITADOS: "     AT  9
     rel_qtdrejln       AT 22 FORMAT "zzz,zz9-"
     rel_vldrejdb       AT 32 FORMAT "zzz,zzz,zzz,zz9.99-"
     rel_vldrejcr       AT 54 FORMAT "zzz,zzz,zzz,zz9.99-"
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_totais.

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND   
                   craptab.cdempres = 0             AND
                   craptab.tptabela = "CONFIG"      AND   
                   craptab.cdacesso = "PERCIRAPLI"  AND
                   craptab.tpregist = 0             NO-LOCK NO-ERROR.
                   
ASSIGN glb_percenir = IF AVAILABLE craptab THEN
                         DECIMAL(craptab.dstextab) 
                      ELSE 0.   

IF  NOT VALID-HANDLE(h-b1wgen0159) THEN
    RUN sistema/generico/procedures/b1wgen0159.p 
        PERSISTENT SET h-b1wgen0159.

TRANS_POUP:

FOR EACH craplrg WHERE craplrg.cdcooper  = glb_cdcooper          AND
                       craplrg.dtresgat <= glb_dtmvtopr          AND
                       craplrg.inresgat  = 0                     AND
                       craplrg.tpaplica  = 4                     AND
                       CAN-DO("1,2,3",STRING(craplrg.tpresgat)) 
                       BY craplrg.tpresgat
                       TRANSACTION ON ERROR UNDO TRANS_POUP, RETURN:

    ASSIGN glb_cdcritic = 0
           aux_vlresgat = 0
           aux_saldorpp = 0.
    
    /* While para pegar EXCLUSIVE-LOCK craprpp */
    DO WHILE TRUE:

        FIND craprpp WHERE craprpp.cdcooper = glb_cdcooper      AND
                           craprpp.nrdconta = craplrg.nrdconta  AND
                           craprpp.nrctrrpp = craplrg.nraplica
                           EXCLUSIVE-LOCK USE-INDEX craprpp1 NO-ERROR NO-WAIT.

        IF   NOT AVAIL craprpp   THEN
             DO:
                 IF  LOCKED craprpp   THEN
                     DO:
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                     END.
                 ASSIGN glb_cdcritic = 484.
             END.        
        ELSE
             DO:
                { includes/poupanca.i }

                ASSIGN aux_flgresga = TRUE
                       aux_saldorpp = rpp_vlsdrdpp.
             END.

        LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */
    
    /* Testa se aplicacao esta disponivel para saque */
    IF   glb_cdcritic <> 484   THEN
         DO:
             FIND FIRST craptab WHERE
                  craptab.cdcooper = glb_cdcooper                          AND
                  craptab.nmsistem = "CRED"                                AND
                  craptab.tptabela = "BLQRGT"                              AND
                  craptab.cdempres = 00                                    AND
                  craptab.cdacesso = STRING(craplrg.nrdconta,"9999999999") AND
                  INT(SUBSTR(craptab.dstextab,1,7)) = craplrg.nraplica
                  NO-LOCK NO-ERROR.
         
             IF  AVAILABLE craptab  THEN
                 DO:
                    /* Vencida e Bloqueada faz o resgate */
                    IF  craprpp.dtvctopp <= glb_dtmvtopr  THEN
                        glb_cdcritic = 828.
                    /* caso contrario critica, esta bloqueada e nao venceu */
                 ELSE
                     glb_cdcritic = 640.
                
                 END.
         END.        

    /* Se não houve erro ou é uma bloqueada vencida à ser resgatada */
    IF   glb_cdcritic = 0 OR glb_cdcritic = 828  THEN
         DO:
             IF   aux_saldorpp > 0   THEN
                  DO:
                      ASSIGN aux_vlirabap = 0.
                                    
                      IF   craprpp.vlabcpmf <> 0   THEN
                           DO:
                               RUN sistema/generico/procedures/b1wgen0159.p
                                           PERSISTENT SET h-b1wgen0159.

                               RUN verifica-imunidade-tributaria
                                      IN h-b1wgen0159(
                                         INPUT craplrg.cdcooper,
                                         INPUT craplrg.nrdconta,
                                         INPUT glb_dtmvtolt,
                                         INPUT FALSE,
                                         INPUT 5,
                                         INPUT 0,
                                         OUTPUT aux_flgimune,
                                         OUTPUT TABLE tt-erro).

                               DELETE PROCEDURE h-b1wgen0159.                      
                          
                               IF   NOT aux_flgimune THEN
                                    ASSIGN aux_vlirabap = 
                                            TRUNC((craprpp.vlabcpmf * 
                                                 glb_percenir / 100),2).
                           END.

                      CASE craplrg.tpresgat:
                           WHEN  1  THEN        /*  Parcial  */
                                 DO:
                                    IF   craplrg.vllanmto > 
                                             aux_saldorpp - aux_vlirabap THEN
                                         ASSIGN aux_vlresgat = aux_saldorpp -
                                                               aux_vlirabap
                                                glb_cdcritic = 429.
                                    ELSE
                                         aux_vlresgat = craplrg.vllanmto.
                                 END.
                           WHEN  2  THEN        /*  Total  */
                                 aux_vlresgat = aux_saldorpp - 
                                                    aux_vlirabap.              
                           WHEN  3  THEN        /*  Antecipado  */
                                 DO:
                                     IF   craplrg.vllanmto = 0 THEN
                                          aux_vlresgat = aux_saldorpp -
                                                             aux_vlirabap.
                                     ELSE DO:
                                          IF craplrg.vllanmto > aux_saldorpp -
                                                         aux_vlirabap
                                             THEN
                                             ASSIGN aux_vlresgat = 
                                                        aux_saldorpp -
                                                            aux_vlirabap
                                                    glb_cdcritic = 429.
                                          ELSE
                                             aux_vlresgat = craplrg.vllanmto.
                                     END.
                                 END.
                      END CASE.
                      
                      IF  craplrg.flgcreci = NO THEN /*Resgate Conta Corrente*/
                          DO:
                             /*  Gera lancamento no conta-corrente  */
                             DO WHILE TRUE:

                                FIND craplot WHERE
                                     craplot.cdcooper = glb_cdcooper    AND
                                     craplot.dtmvtolt = glb_dtmvtopr    AND
                                     craplot.cdagenci = 1               AND
                                     craplot.cdbccxlt = 100             AND
                                     craplot.nrdolote = 8473
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                IF   NOT AVAIL craplot   THEN
                                     IF  LOCKED craplot   THEN
                                         DO:
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT.
                                         END.
                                     ELSE
                                         DO:
                                            CREATE craplot.
                                            ASSIGN 
                                              craplot.dtmvtolt =
                                                               glb_dtmvtopr
                                              craplot.cdagenci = 1
                                              craplot.cdbccxlt = 100
                                              craplot.nrdolote = 8473
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
                                    craplcm.nrdconta = craprpp.nrdconta
                                    craplcm.nrdctabb = craprpp.nrdconta
                                    craplcm.nrdctitg = STRING(craprpp.nrdconta,
                                                          "99999999")
                                    craplcm.nrdocmto = craplot.nrseqdig + 1
                                    craplcm.cdhistor = 159
                                    craplcm.vllanmto = aux_vlresgat
                                    craplcm.nrseqdig = craplot.nrseqdig + 1
                                    craplcm.cdcooper = glb_cdcooper.
                            
                             IF  craprpp.flgctain = YES  THEN  
                                 craplcm.cdhistor = 501.

                             VALIDATE craplcm.

                             ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
                                    craplot.qtcompln = craplot.qtcompln + 1
                                    craplot.vlinfocr =
                                            craplot.vlinfocr + aux_vlresgat
                                    craplot.vlcompcr = 
                                            craplot.vlcompcr + aux_vlresgat
                                    craplot.nrseqdig = craplcm.nrseqdig.

                          END.
                      
                      RUN  gera_lancamentos_craplci.
                      
                      /*  Gera lancamento do resgate  */

                      DO WHILE TRUE:

                         FIND craplot WHERE craplot.cdcooper = glb_cdcooper  AND
                                            craplot.dtmvtolt = glb_dtmvtopr  AND
                                            craplot.cdagenci = 1             AND
                                            craplot.cdbccxlt = 100           AND
                                            craplot.nrdolote = 8383
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
                                       ASSIGN craplot.dtmvtolt = glb_dtmvtopr
                                              craplot.cdagenci = 1
                                              craplot.cdbccxlt = 100
                                              craplot.nrdolote = 8383
                                              craplot.tplotmov = 14
                                              craplot.cdcooper = glb_cdcooper.
                                       VALIDATE craplot.
                                   END.

                         LEAVE.

                      END.  /*  Fim do DO WHILE TRUE  */

                      CREATE craplpp.
                      ASSIGN craplpp.dtmvtolt = craplot.dtmvtolt
                             craplpp.cdagenci = craplot.cdagenci
                             craplpp.cdbccxlt = craplot.cdbccxlt
                             craplpp.nrdolote = craplot.nrdolote
                             craplpp.nrdconta = craprpp.nrdconta
                             craplpp.nrctrrpp = craprpp.nrctrrpp
                             craplpp.nrdocmto = craplot.nrseqdig + 1
                             craplpp.txaplmes = rpp_txaplmes
                             craplpp.txaplica = rpp_txaplica
                             craplpp.cdhistor = 158
                             craplpp.nrseqdig = craplot.nrseqdig + 1
                             craplpp.dtrefere = craprpp.dtfimper
                             craplpp.vllanmto = aux_vlresgat
                             craplpp.cdcooper = glb_cdcooper

                             craplot.vlinfodb = craplot.vlinfodb +
                                                        craplpp.vllanmto
                             craplot.vlcompdb = craplot.vlcompdb +
                                                        craplpp.vllanmto
                             craplot.qtinfoln = craplot.qtinfoln + 1
                             craplot.qtcompln = craplot.qtcompln + 1
                             craplot.nrseqdig = craplot.nrseqdig + 1

                             craprpp.vlrgtacu = craprpp.vlrgtacu +
                                                        craplpp.vllanmto
                                                   
                             aux_regexist     = TRUE.
                      VALIDATE craplpp.

                      IF  craprpp.flgctain = YES  THEN  
                          craplpp.cdhistor = 496.
                  
                  END.
             ELSE
                  glb_cdcritic = 494.
         END.

    IF  glb_cdcritic = 0   THEN
        DO:
            IF  craprpp.dtvctopp <= glb_dtmvtopr THEN
                glb_cdcritic = 921.
            ELSE
                glb_cdcritic = 434.
        END.


    IF   glb_cdcritic > 0   THEN
         DO:
             CREATE craprej.
             ASSIGN craprej.dtmvtolt = glb_dtmvtopr
                    craprej.cdagenci = 156
                    craprej.cdbccxlt = 156
                    craprej.nrdolote = 156
                    craprej.nrdconta = craplrg.nrdconta
                    craprej.nraplica = craplrg.nraplica
                    craprej.dtdaviso = craplrg.dtmvtolt
                    craprej.vldaviso = craplrg.vllanmto
                    craprej.vlsdapli = aux_saldorpp
                    craprej.vllanmto = aux_vlresgat
                    craprej.cdcritic = glb_cdcritic
                    craprej.tpintegr = 156
                    craprej.cdcooper = glb_cdcooper
                    glb_cdcritic     = 0.
             VALIDATE craprej.
         END.

    ASSIGN craplrg.inresgat = 1.

    
    /* resgate por vencimento */
    IF   available craprpp   THEN
         DO:
             IF   craprpp.dtvctopp <= glb_dtmvtopr  THEN
                  DO:
                      ASSIGN craprpp.vlsdrdpp = 0
                      craprpp.cdsitrpp = 5.
                  END.
         END.

END.  /*  Fim do FOR EACH  --  Leitura dos resgates programados  */

IF  VALID-HANDLE(h-b1wgen0159) THEN
    DELETE PROCEDURE h-b1wgen0159.

IF   glb_cdcritic > 0   THEN            /*  Deu erro na includes/aplicacao.i  */
     DO:
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" + glb_dscritic +
                           " >> log/proc_batch.log").
         RETURN.
     END.

{ includes/cabrel132_1.i }      /*  Monta cabecalho do relatorio  */

OUTPUT STREAM str_1 TO rl/crrl125.lst PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel132_1.

IF   aux_regexist   THEN
     DO:
         FIND craplot WHERE craplot.cdcooper = glb_cdcooper  AND
                            craplot.dtmvtolt = glb_dtmvtopr  AND
                            craplot.cdagenci = 1             AND
                            craplot.cdbccxlt = 100           AND
                            craplot.nrdolote = 8383          NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE craplot   THEN
              DO:
                  glb_cdcritic = 60.
                  RUN fontes/critic.p.
                  UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                    glb_cdprogra + "' --> '" + glb_dscritic +
                                    " Lote dos resgates: " +
                                    STRING(glb_dtmvtopr,"99/99/9999") +
                                    "-001-100-8383" +
                                    " >> log/proc_batch.log").
                  RETURN.
              END.

         DISPLAY STREAM str_1
                 craplot.dtmvtolt  craplot.cdagenci
                 craplot.cdbccxlt  craplot.nrdolote
                 craplot.tplotmov
                 WITH FRAME f_resgate.
     END.
ELSE
     DISPLAY STREAM str_1 "*** NENHUM RESGATE EFETUADO ***" SKIP(1)
             WITH FRAME f_mensagem.

FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper  AND
                       craprej.dtmvtolt = glb_dtmvtopr  AND
                       craprej.cdagenci = 156           AND
                       craprej.cdbccxlt = 156           AND
                       craprej.nrdolote = 156           AND
                       craprej.tpintegr = 156           NO-LOCK
                       BREAK BY craprej.dtmvtolt  
                                BY craprej.cdagenci
                                   BY craprej.cdbccxlt  
                                      BY craprej.nrdolote
                                         BY craprej.nrdconta  
                                            BY craprej.nraplica:

    IF   glb_cdcritic <> craprej.cdcritic   THEN
         DO:
             glb_cdcritic = craprej.cdcritic.
             RUN fontes/critic.p.
         END.

    DISPLAY STREAM str_1
            craprej.nrdconta craprej.nraplica craprej.dtdaviso
            craprej.vldaviso craprej.vlsdapli craprej.vllanmto glb_dscritic
            WITH FRAME f_rejeitados.

    DOWN STREAM str_1 WITH FRAME f_rejeitados.

    IF   craprej.vllanmto = 0   THEN
         ASSIGN rel_qtdrejln = rel_qtdrejln + 1
                rel_vldrejdb = rel_vldrejdb + craprej.vldaviso.

    IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
         DO:
             PAGE STREAM str_1.

             IF   aux_regexist   THEN
                  DISPLAY STREAM str_1
                          craplot.dtmvtolt  craplot.cdagenci
                          craplot.cdbccxlt  craplot.nrdolote
                          craplot.tplotmov
                          WITH FRAME f_resgate.
         END.

END.   /*  Fim do FOR EACH  --  Leitura dos rejeitados  */

IF   aux_regexist   THEN
     DO:
         IF   LINE-COUNTER(str_1) > 78   THEN
              DO:
                  PAGE STREAM str_1.

                  DISPLAY STREAM str_1
                          craplot.dtmvtolt  craplot.cdagenci
                          craplot.cdbccxlt  craplot.nrdolote craplot.tplotmov
                          WITH FRAME f_resgate.
              END.

         DISPLAY STREAM str_1
                 craplot.qtcompln  craplot.vlcompdb  craplot.vlcompcr
                 rel_qtdrejln      rel_vldrejdb      rel_vldrejcr
                 WITH FRAME f_totais.
     END.

OUTPUT STREAM str_1 CLOSE.
                      
ASSIGN glb_nrcopias = 1
       glb_nmformul = ""
       glb_nmarqimp = "rl/crrl125.lst".

RUN fontes/imprim.p. 

TRANS_2:

FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper  AND
                       craprej.dtmvtolt = glb_dtmvtopr  AND
                       craprej.cdagenci = 156           AND
                       craprej.cdbccxlt = 156           AND
                       craprej.nrdolote = 156           AND
                       craprej.tpintegr = 156           EXCLUSIVE-LOCK
                       TRANSACTION ON ERROR UNDO TRANS_2, RETURN:

    DELETE craprej.

END.   /*  Fim do FOR EACH e da transacao  */

RUN fontes/fimprg.p.

PROCEDURE gera_lancamentos_craplci:
     
     IF  craprpp.flgctain = YES AND  /* Nova aplicacao  */    
         craplrg.flgcreci =  NO THEN  /* Somente Transferencia */
         DO:
            
            /*  Gera lancamentos Conta Investimento  - Debito Transf */
            DO  WHILE TRUE:
        
                FIND crablot WHERE crablot.cdcooper = glb_cdcooper  AND
                                   crablot.dtmvtolt = glb_dtmvtopr  AND
                                   crablot.cdagenci = 1             AND
                                   crablot.cdbccxlt = 100           AND
                                   crablot.nrdolote = 10105
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF   NOT AVAILABLE crablot   THEN
                     IF   LOCKED crablot   THEN
                          DO:
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                     END.
                     ELSE
                          DO:
                             CREATE crablot.
                             ASSIGN crablot.dtmvtolt = glb_dtmvtopr
                                    crablot.cdagenci = 1
                                    crablot.cdbccxlt = 100
                                    crablot.nrdolote = 10105  
                                    crablot.tplotmov = 29
                                    crablot.cdcooper = glb_cdcooper.
                             VALIDATE crablot.
                          END.
                LEAVE.
         END.  /*  Fim do DO WHILE TRUE  */

         CREATE craplci.
         ASSIGN craplci.dtmvtolt = crablot.dtmvtolt
                craplci.cdagenci = crablot.cdagenci
                craplci.cdbccxlt = crablot.cdbccxlt
                craplci.nrdolote = crablot.nrdolote
                craplci.nrdconta = craprpp.nrdconta
                craplci.nrdocmto = crablot.nrseqdig + 1
                craplci.cdhistor = 496
                craplci.vllanmto = aux_vlresgat
                craplci.nrseqdig = crablot.nrseqdig + 1
                craplci.cdcooper = glb_cdcooper.
         VALIDATE craplci.
                              
         ASSIGN crablot.qtinfoln = crablot.qtinfoln + 1
                crablot.qtcompln = crablot.qtcompln + 1
                crablot.vlinfodb = crablot.vlinfodb + aux_vlresgat
                crablot.vlcompdb = crablot.vlcompdb + aux_vlresgat
                crablot.nrseqdig = craplci.nrseqdig.

         /*  Gera lancamentos Conta Investmento  - Credito Transf.    */
         DO  WHILE TRUE:
        
             FIND crablot WHERE crablot.cdcooper = glb_cdcooper  AND
                                crablot.dtmvtolt = glb_dtmvtopr  AND
                                crablot.cdagenci = 1             AND
                                crablot.cdbccxlt = 100           AND
                                crablot.nrdolote = 10104
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

             IF   NOT AVAIL   crablot   THEN
                  IF   LOCKED crablot   THEN
                       DO:
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                       END.
                  ELSE
                       DO:
                          CREATE crablot.
                          ASSIGN crablot.dtmvtolt = glb_dtmvtopr
                                 crablot.cdagenci = 1
                                 crablot.cdbccxlt = 100
                                 crablot.nrdolote = 10104 
                                 crablot.tplotmov = 29
                                 crablot.cdcooper = glb_cdcooper.
                          VALIDATE crablot.
                       END.
             LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

         CREATE craplci.
         ASSIGN craplci.dtmvtolt = crablot.dtmvtolt
                craplci.cdagenci = crablot.cdagenci
                craplci.cdbccxlt = crablot.cdbccxlt
                craplci.nrdolote = crablot.nrdolote
                craplci.nrdconta = craprpp.nrdconta
                craplci.nrdocmto = crablot.nrseqdig + 1
                craplci.cdhistor = 489       /* Credito */
                craplci.vllanmto = aux_vlresgat
                craplci.nrseqdig = crablot.nrseqdig + 1
                craplci.cdcooper = glb_cdcooper.
         VALIDATE craplci.
                              
         ASSIGN crablot.qtinfoln = crablot.qtinfoln + 1
                crablot.qtcompln = crablot.qtcompln + 1
                crablot.vlinfocr = crablot.vlinfocr + aux_vlresgat
                crablot.vlcompcr = crablot.vlcompcr + aux_vlresgat
                crablot.nrseqdig = craplci.nrseqdig.

     END.

     IF  craplrg.flgcreci = YES THEN  /* Resgatar para Conta Investimento */
         DO:   

            /*  Gera lancamentos Credito Saldo Conta Investimento     */
            DO  WHILE TRUE:
        
                 FIND crablot WHERE crablot.cdcooper = glb_cdcooper  AND
                                    crablot.dtmvtolt = glb_dtmvtopr  AND
                                    crablot.cdagenci = 1             AND
                                    crablot.cdbccxlt = 100           AND
                                    crablot.nrdolote = 10106
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                 IF   NOT AVAIL   crablot   THEN
                      IF   LOCKED crablot   THEN
                           DO:
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                           END.
                      ELSE
                           DO:
                              CREATE crablot.
                              ASSIGN crablot.dtmvtolt = glb_dtmvtopr
                                     crablot.cdagenci = 1
                                     crablot.cdbccxlt = 100
                                     crablot.nrdolote = 10106
                                     crablot.tplotmov = 29
                                     crablot.cdcooper = glb_cdcooper.
                              VALIDATE crablot.
                           END.
                 LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            CREATE craplci.
            ASSIGN craplci.dtmvtolt = crablot.dtmvtolt
                   craplci.cdagenci = crablot.cdagenci
                   craplci.cdbccxlt = crablot.cdbccxlt
                   craplci.nrdolote = crablot.nrdolote
                   craplci.nrdconta = craprpp.nrdconta
                   craplci.nrdocmto = crablot.nrseqdig + 1
                   craplci.cdhistor = 490   /* Credito Proveniente Aplicacao*/
                   craplci.vllanmto = aux_vlresgat
                   craplci.nrseqdig = crablot.nrseqdig + 1
                   craplci.cdcooper = glb_cdcooper.
            VALIDATE craplci.
                              
            ASSIGN crablot.qtinfoln = crablot.qtinfoln + 1
                   crablot.qtcompln = crablot.qtcompln + 1
                   crablot.vlinfocr = crablot.vlinfocr + aux_vlresgat
                   crablot.vlcompcr = crablot.vlcompcr + aux_vlresgat
                   crablot.nrseqdig = craplci.nrseqdig.
             
             /*--- Atualizar Saldo Conta Investimento */
             FIND crapsli WHERE crapsli.cdcooper  = glb_cdcooper         AND
                                crapsli.nrdconta  = craprpp.nrdconta     AND
                          MONTH(crapsli.dtrefere) = MONTH(glb_dtmvtopr)  AND
                           YEAR(crapsli.dtrefere) = YEAR(glb_dtmvtopr)
                                EXCLUSIVE-LOCK NO-ERROR.
                                
             IF  NOT AVAIL crapsli THEN
                 DO:
                    ASSIGN aux_dtrefere = 
                   ((DATE(MONTH(glb_dtmvtopr),28,YEAR(glb_dtmvtopr)) + 4) -
                     DAY(DATE(MONTH(glb_dtmvtopr),28,
                     YEAR(glb_dtmvtopr)) + 4)).
           
                    CREATE crapsli.
                    ASSIGN crapsli.dtrefere = aux_dtrefere
                           crapsli.nrdconta = craprpp.nrdconta
                           crapsli.cdcooper = glb_cdcooper.
                    VALIDATE crapsli.
                 END.

             ASSIGN crapsli.vlsddisp = crapsli.vlsddisp +  aux_vlresgat.
         END.
         
END PROCEDURE.
                        
/* .......................................................................... */

