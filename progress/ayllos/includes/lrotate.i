/* .............................................................................

   Programa: Includes/lrotate.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Abril/2007                          Ultima atualizacao: 22/09/2014
      
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela LROTAT.

   Alteracoes: 15/07/2008 - Alterado para gerar log/lrotat.log (Gabriel).
   
               18/10/2010 - Alteracoes para implementacao de limites de credito
                            com taxas diferenciadas:
                            - Alteracao da exibicao do campo Tipo de limite;
                            - Inclusao das colunas 'Operacional' e 'CECRED'.
                            (GATI - Eder)
                            
               29/12/2010 - Inclusao do terceiro campo dsencfin (Adriano).     
               
               17/06/2011 - Controlar tarifas das linhas de credito através
                            da tabela CRATLR (Adriano).
                            
               24/03/2014 - Alterado campo Tipo Contrato de Limite para "1".
                            (Daniele)
               
               22/09/2014 - Alteração da mensagem com critica 77 substituindo
                            pela b1wgen9999.p procedure acha-lock, que identifi-
                            ca qual é o usuario que esta prendendo a transaçao.
                            (Vanessa)        
                           
               24/04/2014 - Removido tratamento para a TLR. Sera tratado na 
                            Central de Risco (Guilherme/SUPERO)

............................................................................. */
TRANS_E:


DO TRANSACTION ON ERROR UNDO TRANS_E, RETRY:

   DO aux_contador = 1 TO 10:

      FIND craplrt WHERE craplrt.cdcooper = glb_cdcooper   AND
                         craplrt.cddlinha = tel_cddlinha
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF   NOT AVAILABLE craplrt   THEN
           IF   LOCKED craplrt   THEN
                DO:
                    glb_cdcritic = 374.
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
           ELSE
                glb_cdcritic = 363.
      ELSE
           glb_cdcritic = 0.

      LEAVE.

   END.  /*  Fim do DO .. TO  */

   IF   glb_cdcritic > 0   THEN
        NEXT.


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
          tel_dsencfin[3] = craplrt.dsencfin[3].

   DISPLAY tel_cddlinha    tel_dsdlinha    WITH FRAME f_descricao.

   DISPLAY tel_tpdlinha    tel_dsdtplin    tel_flgstlcr    tel_qtvezcap
           tel_qtvcapce    tel_vllimmax    tel_vllmaxce    tel_qtdiavig
           tel_txjurfix    tel_txjurvar    tel_txmensal
           tel_dsencfin[1] tel_dsencfin[2] tel_dsencfin[3]
           WITH FRAME f_lrotat.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      aux_confirma = "N".

      glb_cdcritic = 378.
      RUN fontes/critic.p.
      glb_cdcritic = 0.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.

      IF NOT CAN-DO("S,N",aux_confirma) THEN
         NEXT.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        NEXT.

   IF   aux_confirma = "S"   THEN
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               aux_confirma = "N".

               glb_cdcritic = 78.
               RUN fontes/critic.p.
               glb_cdcritic = 0.
               BELL.
               MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */
            
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                 aux_confirma <> "S"   THEN
                 DO:
                     glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     glb_cdcritic = 0.
                     BELL.
                     MESSAGE glb_dscritic.
                     UNDO TRANS_E, NEXT.
                 END.


            /*  Bloqueia a linha para nao ser mais utilizada  */
            ASSIGN craplrt.flgstlcr = FALSE.

            HIDE MESSAGE NO-PAUSE.
            MESSAGE COLOR "Aguarde, pesquisando contratos ...".

            FIND FIRST craplim WHERE craplim.cdcooper = glb_cdcooper   AND
                                     craplim.cddlinha = tel_cddlinha   AND
                                     craplim.tpctrlim = 1
                                     NO-LOCK NO-ERROR.

            IF   AVAILABLE craplim   THEN
                 DO:
                     HIDE MESSAGE NO-PAUSE.

                     ASSIGN glb_cdcritic = 377
                            aux_flgclear = FALSE.
                     UNDO TRANS_E, NEXT.
                 END.

            HIDE MESSAGE NO-PAUSE.


            DELETE craplrt.
            
            CLEAR FRAME f_lrotat NO-PAUSE.
            
            UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt, "99/99/9999") +
                              " " + STRING(TIME,"HH:MM:SS")  + "' --> '"   +
                              " Operador " + glb_cdoperad    + " -"        +
                              " Excluiu a linha " + STRING(tel_cddlinha)   +
                              " - " + tel_dsdlinha  +  "." +
                              " >> log/lrotat.log").
            
            ASSIGN tel_cddlinha = 0.
 
            NEXT.
        END.

   HIDE MESSAGE NO-PAUSE.

   CLEAR FRAME f_lrotat NO-PAUSE.
    
END.  /*  Fim da transacao  */

/* .......................................................................... */
