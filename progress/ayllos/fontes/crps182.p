/* ..........................................................................

   Programa: Fontes/crps182.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Dezembro/96                     Ultima atualizacao: 16/01/2014

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 001.
               Lanca diariamente abono de CPMF.

   Alteracoes: 27/11/97 - Alterado para tratar historicos do RDCA30 (Deborah).

               16/02/98 - Alterar a data final da CPMF (Odair)

               28/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               04/06/1999 - Tratar CPMF (Deborah)

               14/03/2000 - Tratar contas isentas (Deborah).

               29/08/2000 - Acerto da alteracao anterior: zerar a variavel
                            (Deborah).

               26/03/2003 - Incluir tratamento da Concredi (Margarete).

               14/11/2003 - Selecionar movimento dia anterior(Mirtes).

               10/12/2003 - Prever geracao de lancamentos separadamente, devido
                            a necessidade do novo lancamento de IR sobre abono
                            de CPMF(Mirtes).
                                                
               26/01/2004 - Voltar a selecionar registro do dia (dtmvtolt)
                            e nao gerar mais IR das aplicacoes. Substituir
                            histor 188 por 865 e histor 189 por 867 (Margarete).

               16/08/2004 - Nao trata mais abono sobre o historico 127
                            (este abono tem tratamento especifico no programa
                             crps404.p) - Edson.
 
               22/09/2004 - Incluidos historicos 498/500(CI)(Mirtes)

               29/06/2005 - Alimentado campo cdcooper das tabelas craplot e 
                            do buffer crablcm (Diego).

               15/07/2005 - Calculo do abono da cpmf deve enxergar a data
                            de inicio, tab_dtiniabo. Usa craplcm.dtrefere
                            com craprda.dtmvtolt para pegar se lancamento com
                            abono ou nao (Margarete).
                            
               15/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               28/03/2007 - Inserida clausula NO-LOCK na leitura do 
                            craplcm(Mirtes)
                            
               22/10/2011 - Alterado a mascara do histor no FOR EACH (Ze).
               
               21/12/2011 - Aumentado o format do campo cdhistor
                            de "999" para "9999" (Tiago).
                            
               16/01/2014 - Inclusao de VALIDATE craplot e craplcm (Carlos)
.............................................................................*/

{ includes/var_batch.i } 

{ includes/var_cpmf.i } 

DEF        VAR    aux_vldebcre_127 AS DECIMAL  DECIMALS 2             NO-UNDO.
DEF        VAR    aux_vldebcre_865 AS DECIMAL  DECIMALS 2             NO-UNDO.
DEF        VAR    aux_vldebcre_867 AS DECIMAL  DECIMALS 2             NO-UNDO.

DEF        BUFFER crablcm  FOR craplcm.
 
glb_cdprogra = "crps182".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

IF   glb_inrestar > 0   AND   glb_nrctares = 0   THEN
     glb_inrestar = 0.

{ includes/cpmf.i } 

IF   tab_txcpmfcc = 0   OR
     tab_indabono = 1   THEN  /* Nao abona o Cpmf das aplicacoes */
     DO:
         RUN fontes/fimprg.p.
         RETURN.
     END.

FOR EACH craplcm NO-LOCK WHERE
         craplcm.cdcooper = glb_cdcooper          AND
         craplcm.nrdconta > glb_nrctares          AND
         craplcm.dtmvtolt = glb_dtmvtolt          AND
                       CAN-DO("0114,0160,0177,0186,0187,0498,0500",
                              STRING(craplcm.cdhistor,"9999"))
                       USE-INDEX craplcm4  BREAK BY craplcm.nrdconta:

    /*
    IF   CAN-DO("127",STRING(craplcm.cdhistor,"999")) THEN
         aux_vldebcre_127 = aux_vldebcre_127 +
                        (TRUNCATE(tab_txcpmfcc * craplcm.vllanmto,2)).

    */
    IF   CAN-DO("0114,0160,0177",STRING(craplcm.cdhistor,"9999")) THEN
         aux_vldebcre_865 = aux_vldebcre_865 +
                        (TRUNCATE(tab_txcpmfcc * craplcm.vllanmto,2)).

    IF   CAN-DO("0186,0187,0498,0500",STRING(craplcm.cdhistor,"9999"))  AND
         tab_dtiniabo <= craplcm.dtrefere THEN
         DO:
            IF  craplcm.cdpesqbb = " " THEN
                aux_vldebcre_867 = aux_vldebcre_867 +
                            (TRUNCATE(tab_txcpmfcc * craplcm.vllanmto,2)).
         END.

    IF   NOT LAST-OF(craplcm.nrdconta) THEN
         NEXT.
    
    TRANS_1:
    DO TRANSACTION ON ERROR UNDO TRANS_1, RETURN:

       FIND crapass WHERE crapass.cdcooper = glb_cdcooper       AND
                          crapass.nrdconta = craplcm.nrdconta 
                          NO-LOCK NO-ERROR.
                          
       IF   NOT AVAILABLE crapass THEN
            DO:
                glb_cdcritic = 251.
                RUN fontes/critic.p.
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                  " - " + glb_cdprogra + "' --> '" +
                                  glb_dscritic + " >> log/proc_batch.log").
                UNDO TRANS_1, RETURN.
            END.
       /*
       /* Credito Capital*/
       IF   aux_vldebcre_127  <> 0 AND crapass.iniscpmf = 0 THEN
            DO:      
                FIND craplot WHERE craplot.cdcooper = glb_cdcooper  AND
                                   craplot.dtmvtolt = glb_dtmvtolt  AND
                                   craplot.cdagenci = 1             AND
                                   craplot.cdbccxlt = 100           AND
                                   craplot.nrdolote = 8461
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF   NOT AVAILABLE craplot   THEN
                     DO:

                         CREATE craplot.
                         ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                                craplot.cdagenci = 1
                                craplot.cdbccxlt = 100
                                craplot.nrdolote = 8461
                                craplot.tplotmov = 1
                                craplot.nrseqdig = 0
                                craplot.vlcompcr = 0
                                craplot.vlinfocr = 0
                                craplot.vlcompdb = 0
                                craplot.vlinfodb = 0
                                craplot.cdhistor = 0
                                craplot.cdoperad = "1"
                                craplot.dtmvtopg = ?
                                craplot.cdcooper = glb_cdcooper.

                     END.

                CREATE crablcm.
                ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
                       craplot.qtcompln = craplot.qtcompln + 1
                       craplot.qtinfoln = craplot.qtcompln
                       craplot.vlcompdb = craplot.vlcompdb + 0
                       craplot.vlinfodb = craplot.vlcompdb
                       craplot.vlcompcr = craplot.vlcompcr +
                                          aux_vldebcre_127 
                       craplot.vlinfocr = craplot.vlcompcr 
                      
                       crablcm.cdagenci = craplot.cdagenci
                       crablcm.cdbccxlt = craplot.cdbccxlt
                       crablcm.cdhistor = 588  /* Abono Capital */
                       crablcm.dtmvtolt = glb_dtmvtolt
                       crablcm.cdpesqbb = ""
                       crablcm.nrdconta = craplcm.nrdconta
                       crablcm.nrdctabb = craplcm.nrdconta
                       crablcm.nrdocmto = craplot.nrseqdig                                            crablcm.nrdolote = craplot.nrdolote
                       crablcm.nrseqdig = craplot.nrseqdig
                       crablcm.vllanmto = aux_vldebcre_127
                       crablcm.cdcooper = glb_cdcooper.
            END.       
       */
       /* Credito Aplicacao */
       IF   aux_vldebcre_865  <> 0 AND crapass.iniscpmf = 0 THEN
            DO:
                FIND craplot WHERE craplot.cdcooper = glb_cdcooper  AND
                                   craplot.dtmvtolt = glb_dtmvtolt  AND
                                   craplot.cdagenci = 1             AND
                                   craplot.cdbccxlt = 100           AND
                                   craplot.nrdolote = 8461
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF   NOT AVAILABLE craplot   THEN
                     DO:

                         CREATE craplot.
                         ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                                craplot.cdagenci = 1
                                craplot.cdbccxlt = 100
                                craplot.nrdolote = 8461
                                craplot.tplotmov = 1
                                craplot.nrseqdig = 0
                                craplot.vlcompcr = 0
                                craplot.vlinfocr = 0
                                craplot.vlcompdb = 0
                                craplot.vlinfodb = 0
                                craplot.cdhistor = 0
                                craplot.cdoperad = "1"
                                craplot.dtmvtopg = ?
                                craplot.cdcooper = glb_cdcooper.
                         VALIDATE craplot.

                     END.

                CREATE crablcm.
                ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
                       craplot.qtcompln = craplot.qtcompln + 1
                       craplot.qtinfoln = craplot.qtcompln
                       craplot.vlcompdb = craplot.vlcompdb + 0
                       craplot.vlinfodb = craplot.vlcompdb
                       craplot.vlcompcr = craplot.vlcompcr +
                                          aux_vldebcre_865 
                       craplot.vlinfocr = craplot.vlcompcr 
                      
                       crablcm.cdagenci = craplot.cdagenci
                       crablcm.cdbccxlt = craplot.cdbccxlt
                       crablcm.cdhistor = 865
                       crablcm.dtmvtolt = glb_dtmvtolt
                       crablcm.cdpesqbb = ""
                       crablcm.nrdconta = craplcm.nrdconta
                       crablcm.nrdctabb = craplcm.nrdconta
                       crablcm.nrdocmto = craplot.nrseqdig
                       crablcm.nrdolote = craplot.nrdolote
                       crablcm.nrseqdig = craplot.nrseqdig
                       crablcm.vllanmto = aux_vldebcre_865
                       crablcm.cdcooper = glb_cdcooper.
                VALIDATE crablcm.
            END.
       
       /* Debito  Aplicacao */
       IF   aux_vldebcre_867  <> 0 AND crapass.iniscpmf = 0 THEN
            DO:
                FIND craplot WHERE craplot.cdcooper = glb_cdcooper  AND
                                   craplot.dtmvtolt = glb_dtmvtolt  AND
                                   craplot.cdagenci = 1             AND
                                   craplot.cdbccxlt = 100           AND
                                   craplot.nrdolote = 8461
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF   NOT AVAILABLE craplot   THEN
                     DO:

                         CREATE craplot.
                         ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                                craplot.cdagenci = 1
                                craplot.cdbccxlt = 100
                                craplot.nrdolote = 8461
                                craplot.tplotmov = 1
                                craplot.nrseqdig = 0
                                craplot.vlcompcr = 0
                                craplot.vlinfocr = 0
                                craplot.vlcompdb = 0
                                craplot.vlinfodb = 0
                                craplot.cdhistor = 0
                                craplot.cdoperad = "1"
                                craplot.dtmvtopg = ?
                                craplot.cdcooper = glb_cdcooper.
                         VALIDATE craplot.

                     END.

                CREATE crablcm.
                ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
                       craplot.qtcompln = craplot.qtcompln + 1
                       craplot.qtinfoln = craplot.qtcompln
                       craplot.vlcompdb = craplot.vlcompdb +
                                          aux_vldebcre_867 
                       craplot.vlinfodb = craplot.vlcompdb
                       craplot.vlcompcr = craplot.vlcompcr + 0
                       craplot.vlinfocr = craplot.vlcompcr 
                      
                       crablcm.cdagenci = craplot.cdagenci
                       crablcm.cdbccxlt = craplot.cdbccxlt
                       crablcm.cdhistor = 867
                       crablcm.dtmvtolt = glb_dtmvtolt
                       crablcm.cdpesqbb = ""
                       crablcm.nrdconta = craplcm.nrdconta
                       crablcm.nrdctabb = craplcm.nrdconta
                       crablcm.nrdocmto = craplot.nrseqdig
                       crablcm.nrdolote = craplot.nrdolote
                       crablcm.nrseqdig = craplot.nrseqdig
                       crablcm.vllanmto = aux_vldebcre_867
                       crablcm.cdcooper = glb_cdcooper.
                VALIDATE crablcm.
            END.
       
       ASSIGN  aux_vldebcre_865 = 0
               aux_vldebcre_867 = 0
               aux_vldebcre_127 = 0.

       FIND crapres WHERE crapres.cdcooper = glb_cdcooper   AND
                          crapres.cdprogra = glb_cdprogra
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE crapres   THEN
            DO:
                glb_cdcritic = 151.
                RUN fontes/critic.p.
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                  " - " + glb_cdprogra + "' --> '" +
                                  glb_dscritic + " >> log/proc_batch.log").
                UNDO TRANS_1, RETURN.
            END.

       crapres.nrdconta = craplcm.nrdconta.

    END. /* END TRANSACTION */

END. /* FOR EACH craplcm */

RUN fontes/fimprg.p.

/* .......................................................................... */

