/* .............................................................................

   Programa: b1wgen0004a.i                  
   Autora  : Junior.
   Data    : 31/10/2005                     Ultima atualizacao: 18/06/2012

   Dados referentes ao programa:

   Objetivo  : INCLUDE CONSULTA SALDO APLICACAO RDCA60

   Alteracoes: 19/05/2006 - Incluido codigo da cooperativa na leitura da
                            tabela (Diego).
                            
               13/11/2006 - Atualizado de acordo com a rotina fontes/rdca2s.i,
                            utilizada para mostrar os saldos no Ayllos (Jr).

               03/10/2007 - Igualar esta include a includes/rdca2s.i (Evandro).
               
               04/11/2009 - Incluir parametros de saida para procedure
                            saldo-rdca-resgate (David).
                            
               18/06/2012 - Incluir tratamento para resgate de RDCA menor que
                            R$ 1,00 (Ze).
............................................................................ */

ASSIGN aux_vlrgtper = 0
       aux_renrgper = 0
       rd2_vllan178 = 0
       rd2_vlsdrdca = craprda.vlsdrdca
       rd2_dtcalcul = craprda.dtiniper
       rd2_dtrefere = craprda.dtfimper

       rd2_dtmvtolt = crapdat.dtmvtopr.

/*  Leitura dos lancamentos de resgate da aplicacao  */

rd2_lshistor = "178,494,876".
     
DO  rd2_contador = 1 TO NUM-ENTRIES(rd2_lshistor,","):
         
    rd2_cdhistor = INT(ENTRY(rd2_contador,rd2_lshistor,",")).
    
    FOR EACH craplap WHERE craplap.cdcooper  = p-cdcooper         AND
                           craplap.nrdconta  = craprda.nrdconta   AND
                           craplap.nraplica  = craprda.nraplica   AND
                           craplap.dtrefere  = rd2_dtrefere       AND
                           craplap.cdhistor  = rd2_cdhistor       AND
                           craplap.dtmvtolt >= rd2_dtcalcul       AND
                           craplap.dtmvtolt <= rd2_dtmvtolt
                           NO-LOCK USE-INDEX craplap6:

        ASSIGN rd2_vllan178 = rd2_vllan178 + craplap.vllanmto.
    
        IF   craplap.cdhistor <> 876   THEN
             ASSIGN aux_vlrgtper = aux_vlrgtper + craplap.vllanmto
                    aux_renrgper = aux_renrgper + craplap.vlrenreg.

    END.  /*  Fim do FOR EACH -- Leitura dos lancamentos da aplicacao  */

END.

rd2_vlsdrdca = rd2_vlsdrdca - rd2_vllan178.

/*** Calcular saldo para resgate enxergando as novas faixas de percentual de
     imposto de renda e o ajuste necessario ***/
ASSIGN aux_nrctaapl = craprda.nrdconta
       aux_nraplres = craprda.nraplica
       aux_vlsldapl = rd2_vlsdrdca
       aux_vlrenper = 0
       aux_sldpresg = 0
       aux_dtregapl = crapdat.dtmvtopr
       rd2_dtrefant = IF craprda.inaniver = 0 AND
                         craprda.dtmvtolt <> craprda.dtiniper
                         THEN craprda.dtiniper
                      ELSE craprda.dtfimper.
                      
IF   craprda.inaniver = 0              AND
     rd2_dtrefant     = rd2_dtrefere   THEN
     ASSIGN aux_sldpresg = rd2_vlsdrdca.     /*  Primeiro Mes  */ 
ELSE
     DO: 
         RUN sistema/generico/procedures/b1wgen0005.p PERSISTENT SET h-b1wgen05.
    
         RUN saldo-rdca-resgate IN h-b1wgen05 (INPUT crapcop.cdcooper,       
                                               INPUT 1,       
                                               INPUT 999,       
                                               INPUT "996",       
                                               INPUT 3,       
                                               INPUT "InternetBank",       
                                               INPUT aux_nrctaapl,       
                                               INPUT aux_dtregapl,       
                                               INPUT aux_nraplres,       
                                               INPUT aux_vlsldapl,       
                                               INPUT aux_vlrenper,       
                                              OUTPUT aux_pcajsren,       
                                              OUTPUT aux_vlrenreg, 
                                              OUTPUT aux_vldajtir, 
                                              OUTPUT aux_sldrgttt, 
                                              OUTPUT aux_vlslajir, 
                                              OUTPUT aux_vlrenacu, 
                                              OUTPUT aux_nrmeses,       
                                              OUTPUT aux_nrdias,       
                                              OUTPUT aux_dtiniapl,       
                                              OUTPUT aux_cdhisren,       
                                              OUTPUT aux_cdhisajt,       
                                              OUTPUT aux_perirapl,
                                              INPUT-OUTPUT aux_sldpresg, 
                                              OUTPUT TABLE tt-erro).
    
         DELETE PROCEDURE h-b1wgen05.
    
         IF   RETURN-VALUE = "NOK" THEN
              DO:
                  FOR EACH tt-erro NO-LOCK.
                               
                      ASSIGN aux_dsmsgerr = "<dsmsgerr>" +
                                            TRIM(tt-erro.dscritic) +
                                            "</dsmsgerr>".
                  END.
                  
                  {&out} aux_dsmsgerr.
                  
                  LEAVE.
              END.
     END.

IF   p-cdprogra = "crps117"  OR
     p-cdprogra = "crps177"  OR
     p-cdprogra = "atenda"   THEN
     DO:
         IF   craprda.vlsdrdca <= 1 AND
              aux_sldpresg      = 0 THEN
              DO:
                  FIND LAST craplap WHERE
                            craplap.cdcooper  = p-cdcooper         AND
                            craplap.nrdconta  = craprda.nrdconta   AND
                            craplap.nraplica  = craprda.nraplica
                            NO-LOCK NO-ERROR.

                  IF   NOT AVAILABLE craplap THEN
                       aux_sldpresg = craprda.vlsdrdca.
                  ELSE
                       DO:
                           IF   YEAR(craplap.dtmvtolt) <
                                YEAR(crapdat.dtmvtolt) THEN
                                aux_sldpresg = craprda.vlsdrdca.
                       END.
              END.
     END.
     
/* ......................................................................... */

