/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | includes/crps032.i              | pc_crps032                        |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/



/* ..........................................................................

   Programa: Includes/crps032.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/95.                       Ultima atualizacao: 12/12/2013

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Calculo trimestral da correcao monetaria do capital.

   Alteracao : 17/03/98 - Verificar troca de versao (Odair).

               06/07/2005 - Alimentado campo cdcooper das tabelas craplot e
                            craplct (Diego).
                            
               03/01/2006 - Nao mostrar a mensagem de capital em moeda fixa
                            negativa (Edson).
                            
               14/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               08/03/2010 - Alteracao Historico (Gati)               

               25/08/2011 - Nao cobrar C.M que nao existe mais (Magui).
               
               12/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO) 
............................................................................. */

ASSIGN aux_qtcotmfx = IF MONTH(glb_dtmvtolt) = 3
                         THEN crapcot.qtantmfx
                         ELSE crapcot.qtcotmfx
        
       crapcot.vlcmecot = 0.


/*  Calcula C.M. do primeiro mes ............................................ */
 
ASSIGN aux_dtliminf = aux_dtprimes - DAY(aux_dtprimes)
       aux_dtlimsup = aux_dtsegmes
       aux_nrmescal = MONTH(aux_dtprimes)
       aux_vlcaptal = crapcot.vlcapmes[aux_nrmescal].

FOR EACH craplct WHERE  craplct.cdcooper = glb_cdcooper   AND
                       (craplct.dtmvtolt > aux_dtliminf   AND
                        craplct.dtmvtolt < aux_dtlimsup)  AND
                        craplct.nrdconta =  crapcot.nrdconta 
                        EXCLUSIVE-LOCK:
                                        
    craplct.qtlanmfx = TRUNCATE(craplct.vllanmto /
                                tb1_vlmoefix[DAY(craplct.dtmvtolt)],4).

    FIND FIRST tt-hist NO-LOCK
         WHERE tt-hist.codigo = craplct.cdhistor NO-ERROR.

    IF  AVAIL tt-hist THEN DO:
        IF   tt-hist.tab_inhistor = 6   THEN
             aux_qtcotmfx = aux_qtcotmfx + craplct.qtlanmfx.
        ELSE
        IF   tt-hist.tab_inhistor = 16   THEN
             aux_qtcotmfx = aux_qtcotmfx - craplct.qtlanmfx.
    END.

END.  /*  Fim do FOR EACH -- Leitura dos lancamentos de capital  */


ASSIGN /***
       aux_vlcmmcot = TRUNCATE(aux_qtcotmfx * aux_vlmoefix[1],2)

       aux_vlcmmcot = IF aux_vlcmmcot > aux_vlcaptal
                         THEN aux_vlcmmcot - aux_vlcaptal
                         ELSE 0
       ***/
       aux_vlcmmcot = 0  /*** Magui nao existe C.M ***/
       crapcot.vldcotas = crapcot.vldcotas + aux_vlcmmcot
       crapcot.vlcmecot = crapcot.vlcmecot + aux_vlcmmcot
       crapcot.vlcmmcot = crapcot.vlcmmcot + aux_vlcmmcot
       crapcot.vlcmicot = crapcot.vlcmicot + aux_vlcmmcot

       crapcot.vlcapmes[aux_nrmescal] =
               crapcot.vlcapmes[aux_nrmescal] + aux_vlcmmcot

       crapcot.vlcapmes[aux_nrmescal + 1] =
               crapcot.vlcapmes[aux_nrmescal + 1] + aux_vlcmmcot

       crapcot.vlcapmes[aux_nrmescal + 2] =
               crapcot.vlcapmes[aux_nrmescal + 2] + aux_vlcmmcot

       aux_vlcmdmes[1] = aux_vlcmmcot.


/*  Calcula C.M. do segundo mes ............................................. */

ASSIGN aux_dtliminf = aux_dtsegmes - DAY(aux_dtsegmes)
       aux_dtlimsup = aux_dttermes
       aux_nrmescal = MONTH(aux_dtsegmes)
       aux_vlcaptal = crapcot.vlcapmes[aux_nrmescal].

FOR EACH craplct WHERE (craplct.cdcooper = glb_cdcooper   AND
                        craplct.dtmvtolt > aux_dtliminf   AND
                        craplct.dtmvtolt < aux_dtlimsup)  AND
                        craplct.nrdconta =  crapcot.nrdconta 
                        EXCLUSIVE-LOCK:
                                            
    craplct.qtlanmfx = TRUNCATE(craplct.vllanmto /
                                tb2_vlmoefix[DAY(craplct.dtmvtolt)],4).

    FIND FIRST tt-hist NO-LOCK
         WHERE tt-hist.codigo = craplct.cdhistor NO-ERROR.

    IF  AVAIL tt-hist THEN DO:
        IF   tt-hist.tab_inhistor = 6   THEN
             aux_qtcotmfx = aux_qtcotmfx + craplct.qtlanmfx.
        ELSE
        IF   tt-hist.tab_inhistor = 16  THEN
             aux_qtcotmfx = aux_qtcotmfx - craplct.qtlanmfx.
    END.

END.  /*  Fim do FOR EACH -- Leitura dos lancamentos de capital  */


ASSIGN /***
       aux_vlcmmcot = TRUNCATE(aux_qtcotmfx * aux_vlmoefix[2],2)

       aux_vlcmmcot = IF aux_vlcmmcot > aux_vlcaptal
                         THEN aux_vlcmmcot - aux_vlcaptal
                         ELSE 0
       ***/
       aux_vlcmmcot = 0 /*** Magui nao existe C.M. ***/  
       crapcot.vldcotas = crapcot.vldcotas + aux_vlcmmcot
       crapcot.vlcmecot = crapcot.vlcmecot + aux_vlcmmcot
       crapcot.vlcmmcot = crapcot.vlcmmcot + aux_vlcmmcot
       crapcot.vlcmicot = crapcot.vlcmicot + aux_vlcmmcot

       crapcot.vlcapmes[aux_nrmescal] =
               crapcot.vlcapmes[aux_nrmescal] + aux_vlcmmcot

       crapcot.vlcapmes[aux_nrmescal + 1] =
               crapcot.vlcapmes[aux_nrmescal + 1] + aux_vlcmmcot

       aux_vlcmdmes[2] = aux_vlcmmcot.


/*  Calcula C.M. do terceiro mes ............................................ */

ASSIGN aux_dtliminf = aux_dttermes - DAY(aux_dttermes)
       aux_dtlimsup = glb_dtmvtopr
       aux_nrmescal = MONTH(aux_dttermes)
       aux_vlcaptal = crapcot.vlcapmes[aux_nrmescal].

FOR EACH craplct WHERE (craplct.cdcooper = glb_cdcooper   AND
                        craplct.dtmvtolt > aux_dtliminf   AND
                        craplct.dtmvtolt < aux_dtlimsup)  AND
                        craplct.nrdconta = crapcot.nrdconta 
                        EXCLUSIVE-LOCK:
                                        
    craplct.qtlanmfx = TRUNCATE(craplct.vllanmto /
                                tb3_vlmoefix[DAY(craplct.dtmvtolt)],4).

    FIND FIRST tt-hist NO-LOCK
         WHERE tt-hist.codigo = craplct.cdhistor NO-ERROR.

    IF  AVAIL tt-hist THEN DO:
        IF   tt-hist.tab_inhistor = 6   THEN
             aux_qtcotmfx = aux_qtcotmfx + craplct.qtlanmfx.
        ELSE
        IF   tt-hist.tab_inhistor = 16   THEN
             aux_qtcotmfx = aux_qtcotmfx - craplct.qtlanmfx.
    END.


END.  /*  Fim do FOR EACH -- Leitura dos lancamentos de capital  */


ASSIGN /***
       aux_vlcmmcot = TRUNCATE(aux_qtcotmfx * aux_vlmoefix[3],2)

       aux_vlcmmcot = IF aux_vlcmmcot > aux_vlcaptal
                         THEN aux_vlcmmcot - aux_vlcaptal
                         ELSE 0
       ***/
       aux_vlcmmcot = 0 /*** Magui nao existe C.M. ***/ 
       crapcot.vldcotas = crapcot.vldcotas + aux_vlcmmcot
       crapcot.vlcmecot = crapcot.vlcmecot + aux_vlcmmcot
       crapcot.vlcmmcot = crapcot.vlcmmcot + aux_vlcmmcot
       crapcot.vlcmicot = crapcot.vlcmicot + aux_vlcmmcot

       crapcot.vlcapmes[aux_nrmescal] =
               crapcot.vlcapmes[aux_nrmescal] + aux_vlcmmcot

       aux_vlcmdmes[3]  = aux_vlcmmcot.

/*  Verifica se a quantidade de capital em MFX esta positiva  */

IF   aux_qtcotmfx < 0   THEN
     DO: /*    Edson - 03/01/2006
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" +
                           "Quantidade de capital em MFX negativa. Conta: " +
                           STRING(crapcot.nrdconta,"9999,999,9") + " Qtd.: " +
                           STRING(aux_qtcotmfx,"999,999,999.9999-") +
                           " Valor: " + STRING(crapcot.vldcotas,
                                               "999,999,999.99-") +
                           " >> log/proc_batch.log").
         */
         ASSIGN aux_qtcotmfx = 0.           
         /*** Magui, como nao existe mais C.M nao zerar nada
                crapcot.vldcotas = 0  /*magui*/
                crapcot.vlcapmes[aux_nrmescal] = 0.
        ***/
     END.

crapcot.qtcotmfx = aux_qtcotmfx.      /*  Atualiza saldo em MFX  */   

/*  Gera os lancamentos de C.M. para cada mes do trimestre  */

DO aux_nrmescal = 1 TO 3:

   IF   aux_vlcmdmes[aux_nrmescal] = 0   THEN
        NEXT.

   IF   aux_nrmescal = 1   THEN
        aux_cdhistor = 65.
   ELSE
   IF   aux_nrmescal = 2   THEN
        aux_cdhistor = 70.
   ELSE
        aux_cdhistor = 71.
   
   DO WHILE TRUE:

      FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                         craplot.dtmvtolt = glb_dtmvtolt   AND
                         craplot.cdagenci = aux_cdagenci   AND
                         craplot.cdbccxlt = aux_cdbccxlt   AND
                         craplot.nrdolote = aux_nrdolote
                         USE-INDEX craplot1 NO-ERROR.

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
                           craplot.cdagenci = aux_cdagenci
                           craplot.cdbccxlt = aux_cdbccxlt
                           craplot.nrdolote = aux_nrdolote
                           craplot.tplotmov = aux_tplotmov
                           craplot.cdcooper = glb_cdcooper.
                    VALIDATE craplot.
                END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   CREATE craplct.
   ASSIGN craplct.dtmvtolt = craplot.dtmvtolt
          craplct.cdagenci = craplot.cdagenci
          craplct.cdbccxlt = craplot.cdbccxlt
          craplct.nrdolote = craplot.nrdolote
          craplct.nrdconta = crapcot.nrdconta
          craplct.nrdocmto = craplot.nrseqdig + 1
          craplct.vllanmto = aux_vlcmdmes[aux_nrmescal]
          craplct.cdhistor = aux_cdhistor
          craplct.nrseqdig = craplot.nrseqdig + 1
          craplct.cdcooper = glb_cdcooper

          craplot.nrseqdig = craplot.nrseqdig + 1
          craplot.qtinfoln = craplot.qtinfoln + 1
          craplot.qtcompln = craplot.qtcompln + 1
          craplot.vlinfocr = craplot.vlinfocr + craplct.vllanmto
          craplot.vlcompcr = craplot.vlcompcr + craplct.vllanmto.
   VALIDATE craplct.   
END.  /*  Fim do DO .. TO  */

/* .......................................................................... */

