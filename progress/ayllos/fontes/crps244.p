/* ..........................................................................

   Programa: Fontes/crps244.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Julho/98.                           Ultima atualizacao: 16/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Integrar arquivo de faturas BRADESCO.
               Emite relatorio 194.

   Alteracoes: 25/11/98 - Tratar novo layout (Odair)

               15/03/99 - Tratar cartoes com saldo credor (Odair)

               07/10/99 - Tratar o campo D ou C no layout pos 187 (Odair)

               15/10/1999 - Criar numeracao de lote 6870 para os lote de 
                            faturas Visa (Deborah).
                            
               15/03/2000 - Nao descontar valores a credito em real de valores
                            a debito em dolar (Odair).

               03/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               27/04/2004 - Alterado o Historico de 293 para 874 (Julio). 

               26/05/2004 - Consistencia do arquivo e tratamento para a tabela
                            com o valor do dolar (Julio/Junior).

               30/06/2005 - Alimentado campo cdcooper das tabelas craptab,
                            craprej, craplot e craplau (Diego).

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               16/01/2007 - Se o arquivo for integrado apos a data do debito,
                            programar debito para o dia seguinte (Julio).
                            
               05/02/2007 - Nao exigir mais tabela com cadastramento do dolar
                            (Julio)
                            
               15/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
                            
               16/01/2014 - Inclusao de VALIDATE craprej, craplot e craplau 
                            (Carlos)
............................................................................. */

DEF STREAM str_1.   /*  Para relatorio de criticas  */
DEF STREAM str_2.   /*  Para arquivo de trabalho */

{ includes/var_batch.i {1} } 

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR tab_nmarqtel AS CHAR    FORMAT "x(25)" EXTENT 99      NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_contaant AS INT                                   NO-UNDO.
DEF        VAR i            AS INT                                   NO-UNDO.
DEF        VAR u            AS INT                                   NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.

DEF        VAR aux_setlinha AS CHAR    FORMAT "x(300)"               NO-UNDO.

DEF        VAR aux_diarefer AS INT                                   NO-UNDO.
DEF        VAR aux_mesrefer AS INT                                   NO-UNDO.
DEF        VAR aux_anorefer AS INT                                   NO-UNDO.
DEF        VAR aux_dtrefere AS DATE                                  NO-UNDO.
DEF        VAR aux_dscritic AS CHAR                                  NO-UNDO.

DEF        VAR aux_cdagenci AS INT                                   NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT                                   NO-UNDO.
DEF        VAR aux_nrdolote AS INT  INIT 6870                        NO-UNDO.
DEF        VAR aux_tplotmov AS INT                                   NO-UNDO.

DEF        VAR aux_tpregist AS CHAR    FORMAT "x(01)"                NO-UNDO.
DEF        VAR aux_nrdconta AS INTEGER                               NO-UNDO.
DEF        VAR aux_nmarqdeb AS CHAR                                  NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.

DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgrejei AS LOGICAL                               NO-UNDO.

DEF        VAR tot_qtcrdrec AS INT                                   NO-UNDO.
DEF        VAR tot_qtcrdint AS INT                                   NO-UNDO.
DEF        VAR tot_qtcrdrej AS INT                                   NO-UNDO.
DEF        VAR tot_vlnacrec AS DECI                                  NO-UNDO.
DEF        VAR tot_vlnacint AS DECI                                  NO-UNDO.
DEF        VAR tot_vlnacrej AS DECI                                  NO-UNDO.
DEF        VAR tot_vlextrec AS DECI                                  NO-UNDO.
DEF        VAR tot_vlextint AS DECI                                  NO-UNDO.
DEF        VAR tot_vlextrej AS DECI                                  NO-UNDO.
DEF        VAR tot_vltotrec AS DECI                                  NO-UNDO.
DEF        VAR tot_vltotint AS DECI                                  NO-UNDO.
DEF        VAR tot_vltotrej AS DECI                                  NO-UNDO.

DEF        VAR aux_cdacesso AS CHAR                                  NO-UNDO.
DEF        VAR aux_vlemreal AS DECI                                  NO-UNDO.
DEF        VAR aux_vlemdola AS DECI                                  NO-UNDO.
DEF        VAR aux_vldodola AS DECI   FORMAT "zzz,zz9.9999"          NO-UNDO.
DEF        VAR aux_dtmvtopg AS DATE                                  NO-UNDO.
DEF        VAR aux_nrcrcard AS DECI                                  NO-UNDO.
DEF        VAR aux_nrctrcrd AS INT                                   NO-UNDO.
DEF        VAR aux_vllanmto AS DECI                                  NO-UNDO.
DEF        VAR aux_nmtitula AS CHAR                                  NO-UNDO.
DEF        VAR aux_vlfatura AS DECI                                  NO-UNDO.
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_nrseqlan AS INT                                   NO-UNDO.

FORM aux_setlinha  FORMAT "x(300)"
     WITH FRAME AA WIDTH 300 NO-BOX NO-LABELS.

FORM SKIP(1)
     "ARQUIVO:"         AT 01
     aux_nmarquiv       AT 10 FORMAT "x(35)"    NO-LABEL
     aux_dtmvtopg       AT 45 LABEL "DATA DO DEBITO" FORMAT "99/99/9999"
     aux_vldodola       AT 81 LABEL "VALOR DO DOLAR" FORMAT "zzz,zz9.9999"
     SKIP(1)
     glb_dtmvtolt       AT 01 FORMAT "99/99/9999" LABEL "DATA"
     aux_cdagenci       AT 18 FORMAT "zz9"        LABEL "PA"
     aux_cdbccxlt       AT 30 FORMAT "zz9"        LABEL "BANCO/CAIXA"
     aux_nrdolote       AT 49 FORMAT "zzz,zz9"    LABEL "LOTE"
     aux_tplotmov       AT 63 FORMAT "99"         LABEL "TIPO"
     SKIP(1)
     WITH NO-BOX SIDE-LABELS DOWN WIDTH 132 FRAME f_cab.

FORM craprej.cdpesqbb AT 01 FORMAT "x(19)"            LABEL "CARTAO"
     craprej.nrdconta AT 21                           LABEL "CONTA/DV"
     craprej.dshistor AT 32 FORMAT "x(30)"            LABEL "NOME"
     craprej.vlsdapli AT 63 FORMAT "zzzz,zzz,zz9.99-" LABEL "TOTAL NACIONAL"
     craprej.vldaviso AT 80 FORMAT "zzzz,zzz,zz9.99-" LABEL "TOTAL EXTERIOR"
     aux_dscritic     AT 97 FORMAT "x(36)"            LABEL "CRITICA"
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_lanctos.

FORM SKIP(1)
     "RECEBIDOS      INTEGRADOS      REJEITADOS"   AT  28
     SKIP(1)
     "QTD.CARTOES:"       AT 10
     tot_qtcrdrec         AT 30 FORMAT "zzz,zz9"
     tot_qtcrdint         AT 46 FORMAT "zzz,zz9"
     tot_qtcrdrej         AT 62 FORMAT "zzz,zz9"
     SKIP
     "TOTAL NACIONAL:"    AT 07
     tot_vlnacrec         AT 23 FORMAT "zzz,zzz,zz9.99-"
     tot_vlnacint         AT 39 FORMAT "zzz,zzz,zz9.99-"
     tot_vlnacrej         AT 55 FORMAT "zzz,zzz,zz9.99-"
     "TOTAL EXTERIOR:"    AT 07
     tot_vlextrec         AT 23 FORMAT "zzz,zzz,zz9.99-"
     tot_vlextint         AT 39 FORMAT "zzz,zzz,zz9.99-"
     tot_vlextrej         AT 55 FORMAT "zzz,zzz,zz9.99-"
     "TOTAL EM REAIS:"    AT 07
     tot_vltotrec         AT 23 FORMAT "zzz,zzz,zz9.99-"
     tot_vltotint         AT 39 FORMAT "zzz,zzz,zz9.99-"
     tot_vltotrej         AT 55 FORMAT "zzz,zzz,zz9.99-"
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_total.

glb_cdprogra = "crps244".
RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

RUN p_consistearq(OUTPUT aux_contador).

aux_contaant = aux_contador.

DO  i = 1 TO aux_contador:

    ASSIGN aux_flgrejei = FALSE
           aux_flgfirst = TRUE
           aux_vlemreal = 0
           aux_nmtitula = "".
    
    INPUT STREAM str_2 FROM VALUE("integra/" + tab_nmarqtel[i] + ".q") NO-ECHO.

    DO WHILE TRUE:
    
       SET STREAM str_2 aux_setlinha  WITH FRAME AA WIDTH 300.

       aux_tpregist = SUBSTR(aux_setlinha,1,1).
    
       IF   aux_tpregist <> "0" THEN
            NEXT.
       
       LEAVE.     
            
    END.
    
    IF   aux_tpregist <> "0" THEN
         NEXT.
           
    ASSIGN aux_diarefer = INTEGER(SUBSTR(aux_setlinha,118,2))
           aux_mesrefer = INTEGER(SUBSTR(aux_setlinha,116,2))
           aux_anorefer = INTEGER(SUBSTR(aux_setlinha,112,4))
           aux_cdacesso = "DC" + STRING(aux_anorefer,"9999") + 
                                 STRING(aux_mesrefer,"99") + 
                                 STRING(aux_diarefer,"99")
           aux_dtmvtopg = DATE(aux_mesrefer,aux_diarefer,aux_anorefer).

/************ Nao eh mais necessario cadastrar o dolar - Julio 05/02/2007

    DO TRANSACTION:

       FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                          craptab.nmsistem = "CRED"        AND
                          craptab.tptabela = "USUARI"      AND
                          craptab.cdempres = 11            AND
                          craptab.cdacesso = aux_cdacesso  AND
                          craptab.tpregist = 000           NO-LOCK NO-ERROR.

       IF   NOT AVAILABLE craptab THEN
            DO:
                CREATE craptab.
                ASSIGN craptab.nmsistem = "CRED"       
                       craptab.tptabela = "USUARI"     
                       craptab.cdempres = 11           
                       craptab.cdacesso = aux_cdacesso 
                       craptab.tpregist = 000
                       craptab.dstextab = "0"
                       craptab.cdcooper = glb_cdcooper

                glb_cdcritic = 0.
             
                DO  u = 1 TO aux_contaant :
                    UNIX SILENT
                      VALUE("rm integra/" + 
                            tab_nmarqtel[i] + "*.q 2> /dev/null").
                END.
             
                RUN fontes/fimprg.p.

                RETURN.
            END.
    END.
    
    aux_vldodola = DECI(craptab.dstextab).

    IF   aux_vldodola = 0 THEN
         DO:
             glb_cdcritic = 613.
             RUN fontes/critic.p.
             UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                                " - " + glb_cdprogra + "' --> '" +
                                glb_dscritic + " " +
                                STRING(aux_dtmvtopg,"99/99/9999") +
                                " " +  " >> log/proc_batch.log").
             glb_cdcritic = 0.
             
             INPUT STREAM str_2 CLOSE.

             UNIX SILENT VALUE("rm integra/" + 
                                tab_nmarqtel[i] + "*.q 2> /dev/null").

             IF   aux_dtmvtopg <= glb_dtmvtolt THEN
                  DO:
                      DO  u = 1 TO aux_contaant :
                          UNIX SILENT
                           VALUE("rm " + tab_nmarqtel[u] + ".q 2> /dev/null").
                      END.
                     
                      RUN fontes/fimprg.p.

                      RETURN.
                  END.
             NEXT.     
         END.
    ELSE

******************************** Julio -  05/02/2007 */

    IF   aux_dtmvtopg <= glb_dtmvtolt   THEN
         ASSIGN aux_dtmvtopg = glb_dtmvtopr.
    
    IF   glb_inrestar <> 0 AND glb_nrctares = 0 THEN

         FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper AND
                                craprej.dtrefere = glb_cdprogra AND
                                craprej.dtmvtolt = aux_dtmvtopg 
                                EXCLUSIVE-LOCK TRANSACTION:
             DELETE craprej.
         END.
    
    IF   glb_inrestar <> 0 THEN
         DO:
             ASSIGN aux_nrdolote = INT(glb_dsrestar)
                    glb_inrestar = 0.
                    
             IF   aux_nrdolote = 0 THEN
                  aux_nrdolote = 6870.
         END.         
    ELSE
         DO WHILE TRUE:
               
            IF   CAN-FIND(craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                                        craplot.dtmvtolt = glb_dtmvtolt   AND
                                        craplot.cdagenci = 1              AND
                                        craplot.cdbccxlt = 100            AND
                                        craplot.nrdolote = aux_nrdolote         
                                        USE-INDEX craplot1) THEN
                 DO:
                     aux_nrdolote = aux_nrdolote + 1.
                     NEXT.
                 END.

            LEAVE.
         END.   
    
    DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

       SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 300.

       aux_tpregist = SUBSTR(aux_setlinha,1,1).

       IF   aux_tpregist = "3" THEN
            DO:
                 /* criar o registro do ultimo consultado */

          
          /* quando valores em real < 0 entao gera credito no cartao e debita 
               todos os valores em dolar */
          
                IF  aux_vlemreal > 0 THEN
                    aux_vlfatura = aux_vlemreal + (aux_vlemdola * aux_vldodola).
                ELSE
                    aux_vlfatura = aux_vlemdola * aux_vldodola.

                FIND crapcrd WHERE crapcrd.cdcooper = glb_cdcooper  AND
                                   crapcrd.nrcrcard = aux_nrcrcard 
                                   NO-LOCK NO-ERROR. 

                IF   NOT AVAILABLE crapcrd THEN
                     aux_regexist = FALSE.
                ELSE 
                     aux_regexist = TRUE.

                CREATE craprej.
                ASSIGN aux_nrseqlan = aux_nrseqlan + 1
                
                       craprej.dtrefere = glb_cdprogra
                       craprej.dtmvtolt = aux_dtmvtopg
                       craprej.nrdconta = IF  aux_regexist 
                                              THEN crapcrd.nrdconta 
                                              ELSE aux_nrdconta
                       craprej.dshistor = aux_nmtitula
                       craprej.cdcooper = glb_cdcooper
                       craprej.cdpesqbb = 
                               STRING(aux_nrcrcard,"9999,9999,9999,9999")
                       craprej.vlsdapli = aux_vlemreal                 
                       craprej.vllanmto = aux_vlfatura
                       craprej.vldaviso = aux_vlemdola
                       craprej.nrdocmto = aux_nrseqlan
                       craprej.cdcritic = IF  aux_vlfatura = 0 
                                              THEN 632
                                          ELSE
                                              IF  aux_vlfatura < 0
                                                       THEN 631
                                              ELSE
                                                   IF  NOT aux_regexist 
                                                       THEN 546 
                                                   ELSE 0.
                VALIDATE craprej.
                
                IF   aux_vlemreal < 0 THEN
                     DO:
                         CREATE craprej.
                         ASSIGN aux_nrseqlan = aux_nrseqlan + 1
                                craprej.dtrefere = glb_cdprogra
                                craprej.dtmvtolt = aux_dtmvtopg
                                craprej.cdcooper = glb_cdcooper
                                craprej.nrdconta = IF aux_regexist
                                                      THEN crapcrd.nrdconta
                                                      ELSE aux_nrdconta
                                craprej.dshistor = aux_nmtitula
                                craprej.cdpesqbb = 
                                    STRING(aux_nrcrcard,"9999,9999,9999,9999")
                                craprej.vlsdapli = aux_vlemreal
                                craprej.vllanmto = aux_vlemreal
                                craprej.vldaviso = aux_vlemdola
                                craprej.nrdocmto = aux_nrseqlan
                                craprej.cdcritic = 631.
                         VALIDATE craprej.
                     END.

                CREATE craprej.
                ASSIGN craprej.dtrefere = glb_cdprogra
                       craprej.dtmvtolt = aux_dtmvtopg
                       craprej.nrdconta = 99999999
                       craprej.nrseqdig = INT(SUBSTR(aux_setlinha,42,7))
                       craprej.vldaviso = DECI(SUBSTR(aux_setlinha,82,17)) / 100
                       craprej.vllanmto = DECI(SUBSTR(aux_setlinha,64,17)) / 100
                       craprej.cdcritic = 1
                       craprej.cdcooper = glb_cdcooper.
                VALIDATE craprej.
            END.
       ELSE
       IF   aux_tpregist = "0" THEN
            DO:
                NEXT.
            END.
       ELSE
       IF   aux_tpregist = "1" THEN
            DO:
                /* fechamento do anterior */

      /* quando valores em real < 0 entao gera credito no cartao e debita 
          todos os valores em dolar */
          
                IF  aux_vlemreal > 0 THEN
                    aux_vlfatura = aux_vlemreal + (aux_vlemdola * aux_vldodola).
                ELSE
                    aux_vlfatura = aux_vlemdola * aux_vldodola.

                IF   NOT aux_flgfirst THEN 
                     DO:

                         FIND crapcrd WHERE crapcrd.cdcooper = glb_cdcooper  AND
                                            crapcrd.nrcrcard = aux_nrcrcard 
                                            NO-LOCK NO-ERROR. 

                         IF   NOT AVAILABLE crapcrd THEN
                              aux_regexist = FALSE.
                         ELSE 
                              aux_regexist = TRUE.
                              
                         CREATE craprej.
                         ASSIGN aux_nrseqlan = aux_nrseqlan + 1
                                craprej.dtrefere = glb_cdprogra
                                craprej.dtmvtolt = aux_dtmvtopg
                                craprej.cdcooper = glb_cdcooper
                                craprej.nrdconta = IF aux_regexist
                                                      THEN crapcrd.nrdconta
                                                      ELSE aux_nrdconta
                                craprej.dshistor = aux_nmtitula
                                craprej.cdpesqbb = 
                                    STRING(aux_nrcrcard,"9999,9999,9999,9999")
                                craprej.vlsdapli = aux_vlemreal                 
                                craprej.vllanmto = aux_vlfatura
                                craprej.vldaviso = aux_vlemdola
                                craprej.nrdocmto = aux_nrseqlan
                                craprej.cdcritic = IF  aux_vlfatura = 0 
                                                       THEN 632
                                                   ELSE
                                                   IF  aux_vlfatura < 0
                                                       THEN 631
                                                   ELSE
                                                   IF  NOT aux_regexist 
                                                       THEN 546 
                                                   ELSE 0.
                         VALIDATE craprej.

                         IF   aux_vlemreal < 0 THEN
                              DO:
                                  CREATE craprej.
                                  ASSIGN aux_nrseqlan = aux_nrseqlan + 1
                                         craprej.dtrefere = glb_cdprogra
                                         craprej.dtmvtolt = aux_dtmvtopg
                                         craprej.cdcooper = glb_cdcooper
                                         craprej.nrdconta = IF aux_regexist
                                                      THEN crapcrd.nrdconta
                                                      ELSE aux_nrdconta
                                         craprej.dshistor = aux_nmtitula
                                         craprej.cdpesqbb = 
                                    STRING(aux_nrcrcard,"9999,9999,9999,9999")
                                         craprej.vlsdapli = aux_vlemreal
                                         craprej.vllanmto = aux_vlemreal
                                         craprej.vldaviso = aux_vlemdola
                                         craprej.nrdocmto = aux_nrseqlan
                                         craprej.cdcritic = 631.
                                  VALIDATE craprej.
                              END.
                     END.
                     
                /* tratamento normal do tipo 1 */
                     
                ASSIGN aux_nrdconta = INT(SUBSTR(aux_setlinha,256,15))
                       aux_nrctrcrd = INT(SUBSTR(aux_setlinha,187,7))
                       aux_nrcrcard = DECI(SUBSTR(aux_setlinha,23,19))
                       aux_nmtitula = SUBSTR(aux_setlinha,42,30)
                       aux_vlemdola = 0 
                       aux_vlemreal = 0
                       aux_vlfatura = 0 
                       aux_flgfirst = FALSE.
                    
            END.
       ELSE
       IF   aux_tpregist = "2" THEN
            DO:
                aux_vllanmto = DECIMAL(SUBSTR(aux_setlinha,59,13)) / 100.
                
                IF   CAN-DO("C,c",SUBSTR(aux_setlinha,187,1)) THEN
                     DO:
                         aux_vllanmto = aux_vllanmto * -1.
                     END.          
                                        
                IF  SUBSTR(aux_setlinha,184,3) <> "R$ " THEN
                    DO:

                        UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                                           " - " + glb_cdprogra + "' --> '" +
                                           "ALERTA! Conta: " + 
                                           STRING(aux_nrdconta, "zzzz,zz9,9") +
                                           " Cartao:" + STRING(aux_nrcrcard) + 
                                           " possui valores em DOLAR! " +
                                           ">> log/proc_batch.log").

                        ASSIGN aux_vlemdola = aux_vlemdola + aux_vllanmto.
                    END.
                ELSE
                    aux_vlemreal = aux_vlemreal + aux_vllanmto.

            END.
            
    END. /* FIM do DO WHILE TRUE TRANSACTION */

    INPUT STREAM str_2 CLOSE.

    ASSIGN tot_qtcrdrec = 0
           tot_qtcrdint = 0    tot_qtcrdrej = 0
           tot_vlnacrec = 0    tot_vlnacint = 0
           tot_vlnacrej = 0    tot_vlextrec = 0
           tot_vlextint = 0    tot_vlextrej = 0
           tot_vltotrec = 0    tot_vltotint = 0
           tot_vltotrej = 0 
           glb_cdcritic = 0    aux_flgfirst = TRUE.

    /* CRIACAO DO LAU */
    
    TRANS_2:
    FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper   AND
                           craprej.dtrefere = glb_cdprogra   AND
                           craprej.dtmvtolt = aux_dtmvtopg   AND 
                           craprej.cdcritic = 0 NO-LOCK
                           BY craprej.nrdconta TRANSACTION:

        ASSIGN tot_qtcrdrec = tot_qtcrdrec + 1
               tot_vlnacrec = tot_vlnacrec + craprej.vlsdapli
               tot_vlextrec = tot_vlextrec + craprej.vldaviso
               tot_vltotrec = tot_vltotrec + craprej.vllanmto

               tot_qtcrdint = tot_qtcrdint + 1
               tot_vlnacint = tot_vlnacint + craprej.vlsdapli
               tot_vlextint = tot_vlextint + craprej.vldaviso
               tot_vltotint = tot_vltotint + craprej.vllanmto.
               
        IF   glb_nrctares >= craprej.nrdconta THEN
             NEXT.
        
        DO WHILE TRUE: 
                            
           FIND craplot WHERE  craplot.cdcooper = glb_cdcooper       AND 
                               craplot.dtmvtolt = glb_dtmvtolt       AND
                               craplot.cdagenci = 1                  AND
                               craplot.cdbccxlt = 100                AND
                               craplot.nrdolote = aux_nrdolote
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF   NOT AVAILABLE craplot   THEN
                IF   LOCKED craplot   THEN
                     DO:
                         PAUSE 2 NO-MESSAGE.
                         NEXT.
                     END.
                ELSE
                     DO:
                         CREATE craplot.
                         ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                                craplot.dtmvtopg = aux_dtmvtopg
                                craplot.cdagenci = 1
                                craplot.cdbccxlt = 100
                                craplot.cdbccxpg = 237
                                craplot.cdhistor = 874
                                craplot.cdoperad = "1"
                                craplot.nrdolote = aux_nrdolote
                                craplot.tplotmov = 17
                                craplot.tpdmoeda = 1
                                craplot.cdcooper = glb_cdcooper.
                         VALIDATE craplot.
                     END.

                LEAVE.
        
        END.  /*  Fim do DO WHILE TRUE  */
 
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
                         UNIX SILENT
                              VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                    " - " + glb_cdprogra + "' --> '" +
                                    glb_dscritic +
                                    " >> log/proc_batch.log").
                         UNDO TRANS_2, RETURN.
                     END.
           LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */
  
        CREATE craplau.
        ASSIGN craplau.cdagenci = craplot.cdagenci
               craplau.cdbccxlt = craplot.cdbccxlt
               craplau.cdbccxpg = craplot.cdbccxpg
               craplau.cdcritic = 0               
               craplau.cdhistor = craplot.cdhistor
               craplau.dtdebito = ?               
               craplau.dtmvtolt = craplot.dtmvtolt
               craplau.dtmvtopg = craplot.dtmvtopg
               craplau.cdcooper = glb_cdcooper
               craplau.insitlau = 3               
               craplau.nrcrcard = DECI(craprej.cdpesqbb)
               craplau.nrdconta = craprej.nrdconta    
               craplau.nrdctabb = craprej.nrdconta    
               craplau.nrdocmto = craprej.nrdocmto
               craplau.nrdolote = craplot.nrdolote
               craplau.nrseqdig = craprej.nrdocmto
               craplau.nrseqlan = craprej.nrdocmto                   
               craplau.tpdvalor = 1                   
               craplau.cdseqtel = ""                   
               craplau.vllanaut = craprej.vllanmto
 
               craplot.nrseqdig = craplot.nrseqdig + 1 
               craplot.qtcompln = craplot.qtcompln + 1 
               craplot.qtinfoln = craplot.qtinfoln + 1 
               craplot.vlcompdb = craplot.vlcompdb + craplau.vllanaut
               craplot.vlcompcr = 0
               craplot.vlinfodb = craplot.vlcompdb
               craplot.vlinfocr = 0

               crapres.nrdconta = craprej.nrdconta
               crapres.dsrestar = STRING(aux_nrdolote).
        VALIDATE craplau.

    END.  /* FOR EACH CRAPREJ */  
    
    FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper   AND
                           craprej.dtrefere = glb_cdprogra   AND
                           craprej.dtmvtolt = aux_dtmvtopg   AND
                           craprej.cdcritic = 0 
                           EXCLUSIVE-LOCK TRANSACTION:
        DELETE craprej.
        
    END.    

    { includes/cabrel132_1.i }

    ASSIGN aux_nmarqimp = "rl/crrl194_" + SUBSTR(tab_nmarqtel[i],18,2) + ".lst"
           aux_cdagenci = 1
           aux_cdbccxlt = 100
           aux_tplotmov = 17
           aux_flgrejei = FALSE
           aux_nmarquiv = tab_nmarqtel[i].

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

    VIEW STREAM str_1 FRAME f_cabrel132_1.
 
    DISPLAY STREAM str_1  aux_nmarquiv     aux_dtmvtopg
                          aux_vldodola     glb_dtmvtolt
                          aux_cdagenci     aux_cdbccxlt     
                          aux_nrdolote     aux_tplotmov  
                          WITH FRAME f_cab.

    DOWN STREAM str_1 WITH FRAME f_cab.
 
    /* CRIACAO DO RELATORIO  */

    FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper   AND
                           craprej.dtrefere = glb_cdprogra   AND
                           craprej.dtmvtolt = aux_dtmvtopg   AND 
                           craprej.cdcritic > 0              NO-LOCK
                           BY craprej.nrdconta :

        IF   craprej.nrdconta = 99999999 THEN
             DO:
             
                 IF   LINE-COUNTER(str_1) > 77 THEN
                      DO:
                          PAGE STREAM str_1.
                      
                          DISPLAY STREAM str_1
                                  aux_nmarquiv     aux_dtmvtopg
                                  aux_vldodola     glb_dtmvtolt
                                  aux_cdagenci     aux_cdbccxlt     
                                  aux_nrdolote     aux_tplotmov 
                                  WITH FRAME f_cab.

                          DOWN STREAM str_1 WITH FRAME f_cab.
                      END.
                       
                 DISPLAY STREAM str_1 
                                tot_qtcrdrec tot_qtcrdint tot_qtcrdrej 
                                tot_vlnacrec tot_vlnacint tot_vlnacrej
                                tot_vlextrec tot_vlextint tot_vlextrej
                                tot_vltotrec tot_vltotint tot_vltotrej
                                WITH FRAME f_total.

                 LEAVE.
             END.

        glb_cdcritic = craprej.cdcritic.
        
        RUN fontes/critic.p.
       
        aux_dscritic = glb_dscritic.
 
        ASSIGN tot_qtcrdrec = tot_qtcrdrec + 1
               tot_vlnacrec = tot_vlnacrec + craprej.vlsdapli
               tot_vlextrec = tot_vlextrec + craprej.vldaviso
               tot_vltotrec = tot_vltotrec + craprej.vllanmto
               aux_flgrejei = TRUE.

        IF   LINE-COUNTER(str_1) > 80 THEN
             DO:
                 PAGE STREAM str_1.

                 DISPLAY STREAM str_1
                         aux_nmarquiv     aux_dtmvtopg
                         glb_dtmvtolt     aux_vldodola 
                         aux_cdagenci     aux_cdbccxlt   
                         aux_nrdolote     aux_tplotmov                         
                         WITH FRAME f_cab.

                 DOWN STREAM str_1 WITH FRAME f_cab.

                 aux_flgfirst = FALSE.
             END.

        ASSIGN tot_qtcrdrej = tot_qtcrdrej + 1
               tot_vlnacrej = tot_vlnacrej + craprej.vlsdapli
               tot_vlextrej = tot_vlextrej + craprej.vldaviso
               tot_vltotrej = tot_vltotrej + craprej.vllanmto.
                        
        DISPLAY STREAM str_1
                       craprej.cdpesqbb  craprej.nrdconta 
                       craprej.dshistor  
                       craprej.vlsdapli  WHEN craprej.vlsdapli <> 0 
                       craprej.vldaviso  WHEN craprej.vldaviso <> 0 
                       aux_dscritic
                       WITH FRAME f_lanctos.
                        
        DOWN STREAM str_1 WITH FRAME f_lanctos.       
                 
    END.

    OUTPUT STREAM str_1 CLOSE.

    UNIX SILENT VALUE("rm integra/" + tab_nmarqtel[i] + "*.q 2> /dev/null").
    UNIX SILENT VALUE("mv integra/" + tab_nmarqtel[i] + "* salvar").

    glb_cdcritic = IF aux_flgrejei THEN 191 ELSE 190.
    RUN fontes/critic.p.
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '" +
                      glb_dscritic + "' --> '" +  tab_nmarqtel[i] +
                      " >> log/proc_batch.log").

    FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper  AND
                           craprej.dtrefere = glb_cdprogra  AND
                           craprej.dtmvtolt = aux_dtmvtopg 
                           EXCLUSIVE-LOCK TRANSACTION:
        DELETE craprej.
    END.
    
    DO TRANSACTION:
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
                        UNIX SILENT 
                             VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                   " - " + glb_cdprogra + "' --> '" +
                                   glb_dscritic + " >> log/proc_batch.log").
                        UNDO ,RETURN.
                    END.
              LEAVE.

          END.  /*  Fim do DO WHILE TRUE  */
  
       ASSIGN crapres.nrdconta = 0 
              glb_nrcopias = 2
              glb_nmformul = ""
              glb_nmarqimp = aux_nmarqimp.

    END. /* DO TRANSACTION */
    
    RUN fontes/imprim.p.

END.

RUN fontes/fimprg.p.

PROCEDURE p_consistearq:

    DEF OUTPUT PARAMETER  par_contaarq   AS INTEGER  INIT 0           NO-UNDO.

    DEF             VAR   pro_nrdconta   AS CHAR                      NO-UNDO.
    DEF             VAR   pro_dtarquiv   AS CHAR                      NO-UNDO.
    DEF             VAR   pro_flgerros   AS LOGICAL                   NO-UNDO.
    DEF             VAR   pro_temdolar   AS LOGICAL  INIT FALSE       NO-UNDO. 
    DEF             VAR   pro_qtregist   AS INTEGER                   NO-UNDO.
    
    ASSIGN aux_nmarqdeb = "carfatvia*"
           pro_qtregist = 0.
           pro_nrdconta = "0333-0138002".
              
    INPUT STREAM str_1 THROUGH VALUE( "ls integra/" + 
                                      aux_nmarqdeb + " 2> /dev/null") NO-ECHO.

    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

       SET STREAM str_1 aux_nmarquiv FORMAT "x(40)".

       IF   LENGTH(TRIM(aux_nmarquiv)) > 37   THEN
            NEXT.
       
       par_contaarq = par_contaarq + 1.

       UNIX SILENT VALUE("dos2ux " + aux_nmarquiv + " > " +
                          aux_nmarquiv + "_ux 2> /dev/null").

       UNIX SILENT VALUE("mv " + aux_nmarquiv + "_ux " + aux_nmarquiv + 
                         " 2> /dev/null").

       UNIX SILENT VALUE("quoter " + aux_nmarquiv + " > " +
                          aux_nmarquiv + ".q 2> /dev/null").

       tab_nmarqtel[par_contaarq] =  SUBSTR(aux_nmarquiv, 
                                            INDEX(aux_nmarquiv, "carfat"),
                                                     LENGTH(aux_nmarquiv)).
                                                                       
       INPUT STREAM str_2 FROM VALUE("integra/" +
                                    tab_nmarqtel[par_contaarq] + ".q") NO-ECHO.

       glb_cdcritic = 0.
       
       DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:
     
          SET STREAM str_2 aux_setlinha WITH FRAME AA.
          
          ASSIGN pro_qtregist = pro_qtregist + 1.
          
          IF   SUBSTR(aux_setlinha, 1, 1) = "0"   THEN
               DO:
                   pro_dtarquiv = SUBSTR(aux_setlinha, 112, 8).

                   IF   TRIM(pro_dtarquiv) = ""   THEN
                        DO:
                            ASSIGN pro_dtarquiv = "err"
                                   pro_flgerros = TRUE
                                   glb_cdcritic = 789.
                        END.
               END.
          ELSE
          IF   SUBSTR(aux_setlinha, 1, 1) = "2"   THEN
               DO:
                   pro_flgerros = (INDEX(aux_setlinha, pro_nrdconta) = 0).
 
                   IF   pro_flgerros   THEN
                        glb_cdcritic = 127.
               END.
          ELSE
          IF   SUBSTR(aux_setlinha, 1, 1) = "3"   THEN
               DO:
                   pro_flgerros = INT(SUBSTR(aux_setlinha, 56, 7)) <> 
                                                    (pro_qtregist - 1).       
                   IF   pro_flgerros   THEN
                        glb_cdcritic = 504.
               END.              
               
          IF   pro_flgerros   THEN
               LEAVE.               
       END.
 
       IF   pro_flgerros   THEN      
            DO:       
                IF   glb_cdcritic > 0   THEN
                     DO:
                         RUN fontes/critic.p.

                         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")
                                            + " - " + glb_cdprogra + "' --> '"
                                            + glb_dscritic + "' --> '" + 
                                            tab_nmarqtel[par_contaarq] +
                                            " >> log/proc_batch.log").
                     END.
                
             
                UNIX SILENT VALUE("mv integra/" +
                         tab_nmarqtel[par_contaarq] + " integra/" +
                         tab_nmarqtel[par_contaarq] + ".err 2> /dev/null").
                UNIX SILENT VALUE("rm integra/" +
                         tab_nmarqtel[par_contaarq] + ".q 2> /dev/null").

                ASSIGN tab_nmarqtel[par_contaarq] = ""
                       par_contaarq = par_contaarq - 1
                       pro_flgerros = FALSE.
            END.
       ELSE
            DO:
                IF   LENGTH(TRIM(aux_nmarquiv)) < 30   THEN
                     UNIX SILENT VALUE("mv integra/" +
                          tab_nmarqtel[par_contaarq] + " integra/" +
                          tab_nmarqtel[par_contaarq] + "." + pro_dtarquiv +
                          " 2> /dev/null"). 
                                  
                ASSIGN aux_diarefer = INT(SUBSTR(pro_dtarquiv, 7, 2))
                       aux_mesrefer = INT(SUBSTR(pro_dtarquiv, 5, 2))
                       aux_anorefer = INT(SUBSTR(pro_dtarquiv, 1, 4))
                       aux_dtrefere = DATE(aux_mesrefer, aux_diarefer,
                                                         aux_anorefer).
                
            END.
      
       ASSIGN pro_qtregist = 0.
       
    END.  /*  Fim do DO WHILE TRUE  */

    INPUT STREAM str_1 CLOSE.
    INPUT STREAM str_2 CLOSE.
    
END. /* PROCEDURE p_consistearq */

/* .......................................................................... */

