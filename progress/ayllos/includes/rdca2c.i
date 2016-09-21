/* .............................................................................

   Programa: Includes/rdca2c.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Dezembro/97.                    Ultima atualizacao: 14/06/2007

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina de calculo do aniversario do RDCA2 - Deve ser chamada
               dentro de um FOR EACH ou DO WHILE e com label TRANS_1.

   Alteracoes: 23/09/2004 - Incluido historico 494(CI)(Mirtes)

               06/05/2005 - Utilizar o indice craplap5 na leitura dos 
                            lancamentos (Edson).

               03/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
                
               13/03/2006 - Incluir historico 876, ajuste ir (Margarete).  
 
               14/06/2007 - Alteracao para melhoria de performance (Evandro).

............................................................................. */

ASSIGN rd2_vllan178 = 0
       rd2_vllan180 = 0

       rd2_vlsdrdca = craprda.vlsdrdca

       rd2_dtcalcul = IF craprda.inaniver = 0
                         THEN craprda.dtmvtolt
                         ELSE craprda.dtiniper

       rd2_dtrefant = IF craprda.inaniver = 0                  AND
                         craprda.dtmvtolt <> craprda.dtiniper
                         THEN craprda.dtiniper
                         ELSE craprda.dtfimper

       rd2_dtrefere = craprda.dtfimper

       rd2_dtmvtolt = glb_dtmvtolt.

/*  Leitura dos lancamentos de resgate e/ou provisao da aplicacao  */

rd2_lshistor = "178,180,181,182,494,876".

DO  rd2_contador = 1 TO NUM-ENTRIES(rd2_lshistor,","):

    rd2_cdhistor = INT(ENTRY(rd2_contador,rd2_lshistor,",")).
    
    FOR EACH craplap WHERE (craplap.cdcooper  = glb_cdcooper       AND
                            craplap.nrdconta  = craprda.nrdconta   AND
                            craplap.nraplica  = craprda.nraplica   AND
                            craplap.dtrefere  = rd2_dtrefant       AND
                            craplap.cdhistor  = rd2_cdhistor       AND
                            craplap.dtmvtolt >= rd2_dtcalcul       AND
                            craplap.dtmvtolt <= rd2_dtmvtolt)            OR
                            
                           (craplap.cdcooper  = glb_cdcooper       AND
                            craplap.nrdconta  = craprda.nrdconta   AND
                            craplap.nraplica  = craprda.nraplica   AND
                            craplap.dtrefere  = rd2_dtrefere       AND
                            craplap.cdhistor  = rd2_cdhistor       AND
                            craplap.dtmvtolt >= rd2_dtcalcul       AND
                            craplap.dtmvtolt <= rd2_dtmvtolt)
                            NO-LOCK:

        IF   craplap.cdhistor = 180   OR     /*  Provisao  */
             craplap.cdhistor = 181   THEN   /*  Ajuste Provisao +  */
             rd2_vllan180 = rd2_vllan180 + craplap.vllanmto.
        ELSE
        IF   craplap.cdhistor = 182   THEN   /*  Ajuste Provisao -  */
             rd2_vllan180 = rd2_vllan180 - craplap.vllanmto.
        ELSE
        IF   craplap.cdhistor = 178 OR
             craplap.cdhistor = 494 THEN                /* Resgate */
             rd2_vllan178 = rd2_vllan178 + craplap.vllanmto.

    END.  /*  Fim do FOR EACH -- Leitura dos lancamentos da aplicacao  */

END.

rd2_vlsdrdca = rd2_vlsdrdca - rd2_vllan178 + rd2_vllan180.

/* .......................................................................... */

