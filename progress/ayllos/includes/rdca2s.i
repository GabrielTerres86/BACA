/* .............................................................................

   Programa: Includes/rdca2s.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Novembro/96.                        Ultima atualizacao: 27/07/2007

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina de calculo do saldo RDCA2.

  Alteracoes: 23/09/2004 - Incluido historico 494(CI)(Mirtes)

              13/12/2004 - Ajustes para tratar das novas aliquotas de 
                           IRRF (Margarete).

              06/05/2005 - Utilizar o indice craplap5 na leitura dos 
                           lancamentos (Edson).

              24/10/2005 - Saldo no dia do primeiro aniversario descontando
                           ir sobre a cpmf (Margarete).

              24/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

              27/07/2007 - Alteracao para melhoria de performance (Evandro).

............................................................................. */

ASSIGN aux_vlrgtper = 0
       aux_renrgper = 0
       rd2_vllan178 = 0
       rd2_vlsdrdca = craprda.vlsdrdca
       rd2_dtcalcul = craprda.dtiniper
       rd2_dtrefere = craprda.dtfimper

       rd2_dtmvtolt = glb_dtmvtopr.

/*  Leitura dos lancamentos de resgate da aplicacao  */

rd2_lshistor = "178,494,876".

DO  rd2_contador = 1 TO NUM-ENTRIES(rd2_lshistor,","):

    rd2_cdhistor = INT(ENTRY(rd2_contador,rd2_lshistor,",")).

    FOR EACH craplap WHERE craplap.cdcooper  = glb_cdcooper       AND
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
       aux_dtregapl = glb_dtmvtopr
       rd2_dtrefant = IF craprda.inaniver = 0                  AND
                         craprda.dtmvtolt <> craprda.dtiniper
                         THEN craprda.dtiniper
                      ELSE craprda.dtfimper.

IF   craprda.inaniver = 0              AND
     rd2_dtrefant     = rd2_dtrefere   THEN
     ASSIGN aux_sldpresg = rd2_vlsdrdca.            /*  Primeiro Mes  */
ELSE

     RUN fontes/saldo_rdca_resgate.p.  /* A partir do segundo mes */

/* .......................................................................... */

