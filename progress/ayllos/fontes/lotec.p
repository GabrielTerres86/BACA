/* .............................................................................

   Programa: Fontes/lotec.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91.                        Ultima atualizacao: 20/05/2009

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela LOTE.

   Alteracoes: 29/05/95 - Alterado para nao mostrar a data do debito (Deborah).

               14/06/95 - Alterado para mostrar tipo de lote 12 (Odair).

               26/01/96 - Alterado para mostrar tipo de lote 13 (Odair).
                  
               02/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               30/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane. 
               
               20/05/2009 - Alteracao CDOPERAD (Kbase).
............................................................................. */

{ includes/var_online.i }

{ includes/var_lote.i }

FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                   craplot.dtmvtolt = tel_dtmvtolt   AND
                   craplot.cdagenci = tel_cdagenci   AND
                   craplot.cdbccxlt = tel_cdbccxlt   AND
                   craplot.nrdolote = tel_nrdolote   NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craplot   THEN
     DO:
         glb_cdcritic = 60.
         CLEAR FRAME f_lote NO-PAUSE.
         HIDE  FRAME f_debito.
         PAUSE(0).
         NEXT.
     END.

IF   craplot.cdoperad <> ""   THEN
     DO:
      /* FIND crapope OF craplot NO-LOCK NO-ERROR.*/
      
         FIND crapope WHERE crapope.cdcooper = glb_cdcooper       AND
                            crapope.cdoperad = craplot.cdoperad
                            NO-LOCK NO-ERROR.   

         IF   NOT AVAILABLE crapope   THEN
              tel_nmoperad = TRIM(STRING(glb_cdoperad,"x(10)")) + 
                             " - Nao encontrado".
         ELSE
              tel_nmoperad = crapope.nmoperad.
     END.

ASSIGN tel_qtinfoln = craplot.qtinfoln
       tel_vlinfodb = craplot.vlinfodb
       tel_vlinfocr = craplot.vlinfocr
       tel_qtcompln = craplot.qtcompln
       tel_vlcompdb = craplot.vlcompdb
       tel_vlcompcr = craplot.vlcompcr
       tel_tplotmov = craplot.tplotmov
       tel_dtmvtopg = craplot.dtmvtopg
       tel_cdhistor = craplot.cdhistor
       tel_cdbccxpg = craplot.cdbccxpg

       tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
       tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
       tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

DISPLAY tel_dtmvtolt tel_qtinfoln tel_qtcompln tel_qtdifeln
        tel_vlinfodb tel_vlcompdb tel_vldifedb tel_vlinfocr
        tel_vlcompcr tel_vldifecr tel_tplotmov /* tel_dtmvtopg */
        tel_nmoperad WITH FRAME f_lote.

PAUSE(0).

IF   tel_tplotmov = 12 OR tel_tplotmov = 17 THEN
     DISPLAY tel_dtmvtopg tel_cdhistor tel_cdbccxpg WITH FRAME f_debito.

IF   tel_tplotmov = 13 THEN
     DISPLAY tel_dtmvtopg tel_cdhistor  WITH FRAME f_fatura.

pause(0).



/* .......................................................................... */
