/* .............................................................................

   Programa: Includes/taxesp6e.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/97

   Dados referentes ao programa:                Ultima Atualizacao: 09/02/2006

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela taxesp para RDCA6.
   
   Alteracoes: 06/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

............................................................................. */

DO TRANSACTION ON ENDKEY UNDO, LEAVE:

   DO  aux_contador = 1 TO 5:

       FIND craptrd WHERE craptrd.cdcooper = glb_cdcooper AND
                          craptrd.dtiniper = tel_dtiniper AND
                          craptrd.tptaxrda = tel_tptaxesp AND
                          craptrd.incarenc = 0            AND
                          craptrd.vlfaixas = 0
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE craptrd   THEN
            IF   LOCKED craptrd   THEN
                 DO:
                     glb_cdcritic = 77.
                      PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
           ELSE
                 DO:
                     glb_cdcritic = 347.
                     CLEAR FRAME f_taxesp.
                     LEAVE.
                 END.
       ELSE
            DO:
                aux_contador = 0.
                IF   craptrd.incalcul > 0   THEN
                     glb_cdcritic = 424.
                ASSIGN tel_dtfimper = craptrd.dtfimper
                       tel_qtdiaute = craptrd.qtdiaute
                       tel_txofimes = craptrd.txofimes
                       tel_txofidia = craptrd.txofidia
                       tel_txprodia = craptrd.txprodia
                       tel_dscalcul = IF   craptrd.incalcul = 0  THEN
                                           "NAO"
                                      ELSE
                                           "SIM".

                DISPLAY tel_dtfimper tel_qtdiaute 
                        tel_txofimes tel_txofidia tel_txprodia tel_dscalcul
                        WITH FRAME f_taxesp.

                LEAVE.
            END.
   END.

   IF   (aux_contador <> 0 OR glb_cdcritic <> 0 )  THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
        END.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.

      RUN fontes/critic.p.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      glb_cdcritic = 0.
      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
        aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
        END.

   DELETE craptrd.

END. /* Fim da transacao */

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     NEXT.

CLEAR FRAME f_taxesp NO-PAUSE.

/* .......................................................................... */
