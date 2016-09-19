/* .............................................................................

   Programa: Includes/lrotatc.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Abril/2007.                         Ultima atualizacao: 23/04/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela LROTAT.

   Alteracoes: 18/10/2010 - Alteracoes para implementacao de limites de credito
                            com taxas diferenciadas:
                            - Alteracao da exibicao do campo Tipo de limite;
                            - Inclusao das colunas 'Operacional' e 'CECRED'.
                            (GATI - Eder)
                            
               29/12/2010 - Inclusao do terceiro campo dsencfin (Adriano).
               
               17/06/2011 - Controlar tarifas das linhas de credito através
                            da tabela CRATLR (Adriano).             

               23/04/2014 - Remover a parte de tarifas da tela, e incluir
                            Central de Risco com campos Origem do Recurso,
                            Modalidade e Submodalidade (Guilherme/SUPERO)
............................................................................. */
   
FIND craplrt WHERE craplrt.cdcooper = glb_cdcooper  AND
                   craplrt.cddlinha = tel_cddlinha  NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craplrt   THEN
     DO:
         glb_cdcritic = 363.
         NEXT-PROMPT tel_cddlinha WITH FRAME f_descricao.
         NEXT.
     END.


ASSIGN tel_dsdlinha    = craplrt.dsdlinha
       tel_tpdlinha    = IF   craplrt.tpdlinha = 1   THEN
                              "F"
                         ELSE "J"
       tel_dsdtplin    = IF   craplrt.tpdlinha = 1   THEN
                              "Limite de Credito PF"
                         ELSE "Limite de Credito PJ"
       tel_flgstlcr    = craplrt.flgstlcr
       tel_qtdiavig    = craplrt.qtdiavig
       tel_qtvezcap    = craplrt.qtvezcap
       tel_qtvcapce    = craplrt.qtvcapce
       tel_txjurfix    = craplrt.txjurfix
       tel_txjurvar    = craplrt.txjurvar
       tel_txmensal    = craplrt.txmensal
       tel_vllimmax    = craplrt.vllimmax
       tel_vllmaxce    = craplrt.vllmaxce
       tel_dsencfin[1] = craplrt.dsencfin[1]
       tel_dsencfin[2] = craplrt.dsencfin[2]
       tel_dsencfin[3] = craplrt.dsencfin[3]
       tel_origrecu    = craplrt.dsorgrec
       .                      



FIND gnmodal WHERE gnmodal.cdmodali = craplrt.cdmodali NO-LOCK NO-ERROR.

IF   AVAIL gnmodal    THEN
     ASSIGN tel_cdmodali = gnmodal.cdmodali + "-" + gnmodal.dsmodali.
ELSE
     ASSIGN tel_cdmodali = "".

FIND gnsbmod WHERE gnsbmod.cdmodali = craplrt.cdmodali AND
                   gnsbmod.cdsubmod = craplrt.cdsubmod
                   NO-LOCK NO-ERROR.

IF   AVAIL gnsbmod   THEN
     ASSIGN tel_cdsubmod = gnsbmod.cdsubmod + "-" + gnsbmod.dssubmod.
ELSE
     ASSIGN tel_cdsubmod = "".




DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   DISPLAY tel_cddlinha    tel_dsdlinha    WITH FRAME f_descricao.
   
   DISPLAY tel_tpdlinha    tel_dsdtplin    tel_flgstlcr    tel_qtvezcap
           tel_qtvcapce    tel_vllimmax    tel_vllmaxce    tel_qtdiavig
           tel_txjurfix    tel_txjurvar    tel_txmensal
           tel_dsencfin[1] tel_dsencfin[2] tel_dsencfin[3] WITH FRAME f_lrotat.
           
   
   MESSAGE "Tecle <Enter> para continuar ou <End> para encerrar.".

   WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
      DO:
          HIDE MESSAGE NO-PAUSE.
          LEAVE.
      END.
                

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       
      DISPLAY tel_origrecu   tel_cdmodali
              tel_cdsubmod
         WITH FRAME f_lrotat2.

      MESSAGE "Tecle <Enter> para continuar ou <End> para voltar.".

      WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
      
      LEAVE.

   END.
              
   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
      DO:
         HIDE MESSAGE NO-PAUSE.
         HIDE FRAME f_lrotat2. 
         LEAVE.

      END.

   HIDE MESSAGE NO-PAUSE.
   HIDE FRAME f_lrotat2.
   

   LEAVE.

END.

/* .......................................................................... */
