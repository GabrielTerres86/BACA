/* .............................................................................

   Programa: Includes/taxesp2d.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Janeiro/97

   Dados referentes ao programa:                    Alteracao : 11/12/2013

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela taxesp para RDCA2.
               Cadastra as taxas COM e SEM carencia na mesma inclusao.

   Alteracao : 07/07/2005 - Alimentado campo cdcooper da tabela craptrd (Diego).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               14/09/2006 - Excluida opcao "TAB" (Diego).
               
               11/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO) 
............................................................................. */

aux_indpostp = 1.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   UPDATE tel_vlfaixas  WITH FRAME f_taxesp

   EDITING:
   
      READKEY.
      
      IF   FRAME-FIELD = "tel_vlfaixas"   THEN
           DO:
               IF   KEYFUNCTION(LASTKEY) = "CURSOR-UP"      OR
                    KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN
                    DO:
                        IF   aux_indpostp > NUM-ENTRIES(aux_dsfaixas) THEN
                             aux_indpostp = NUM-ENTRIES(aux_dsfaixas).
                    
                        aux_indpostp = aux_indpostp - 1.

                        IF   aux_indpostp = 0   THEN
                             aux_indpostp = NUM-ENTRIES(aux_dsfaixas).

                        tel_vlfaixas = ENTRY(aux_indpostp,aux_dsfaixas).

                        DISPLAY tel_vlfaixas WITH FRAME f_taxesp.    
                    END.
               ELSE
                IF   KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"   OR
                     KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
                     DO:
                         aux_indpostp = aux_indpostp + 1.
 
                         IF   aux_indpostp > NUM-ENTRIES(aux_dsfaixas)   THEN
                              aux_indpostp = 1.
 
                         tel_vlfaixas = TRIM(ENTRY(aux_indpostp,aux_dsfaixas)).
 
                         DISPLAY tel_vlfaixas WITH FRAME f_taxesp.
                     END.
                ELSE
                 IF   KEYFUNCTION(LASTKEY) = "RETURN"   OR
                      KEYFUNCTION(LASTKEY) = "BACK-TAB" OR
                      KEYFUNCTION(LASTKEY) = "GO"       THEN
                      DO: 
                          APPLY LASTKEY.
                          LEAVE.
                      END.
                 ELSE
                  IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                       APPLY LASTKEY.
           END.  
      ELSE     
           APPLY LASTKEY.
   END.   
 
   LEAVE.

END.

tel_incarenc = TRUE.

IF   CAN-FIND(craptrd WHERE craptrd.cdcooper = glb_cdcooper AND
                            craptrd.dtiniper = tel_dtiniper AND
                            craptrd.tptaxesp = tel_tptaxesp AND
                            craptrd.incarenc = (IF tel_incarenc
                                                   THEN 1
                                                   ELSE 0)  AND
                            craptrd.vlfaixas = DEC(TRIM(ENTRY(
                                               aux_indpostp,aux_dsfaixas)))
                            USE-INDEX craptrd1) THEN
     DO:
         glb_cdcritic = 349.
         CLEAR FRAME f_taxesp.
         NEXT.
     END.

tel_incarenc = FALSE.

IF   CAN-FIND(craptrd WHERE craptrd.cdcooper = glb_cdcooper     AND
                            craptrd.dtiniper = tel_dtiniper     AND
                            craptrd.tptaxesp = tel_tptaxesp     AND
                            craptrd.incarenc = (IF tel_incarenc
                                                   THEN 1
                                                   ELSE 0)      AND
                            craptrd.vlfaixas = DEC(TRIM(ENTRY(
                                               aux_indpostp,aux_dsfaixas)))
                            USE-INDEX craptrd1) THEN
     DO:
         glb_cdcritic = 349.
         CLEAR FRAME f_taxesp.
         NEXT.
     END.

ASSIGN aux_flgerros = FALSE
       tel_txprodia = 0
       tel_txofidia = 0
       tel_txofimes = 0.

DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

    IF   glb_cdcritic > 0 THEN
         DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
         END.

    tel_dscalcul = "".

    DISPLAY tel_dscalcul WITH FRAME f_taxesp.

    tel_dtfimper = IF   MONTH(tel_dtiniper) = 12   THEN
                        DATE(1,DAY(tel_dtiniper),
                        YEAR(tel_dtiniper) + 1)
                   ELSE
                        DATE(MONTH(tel_dtiniper) + 1,
                        DAY(tel_dtiniper),YEAR(tel_dtiniper)).

    ASSIGN aux_dtmvtolt = tel_dtiniper
           tel_qtdiaute = 0.

    DO WHILE aux_dtmvtolt < tel_dtfimper:

       IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtmvtolt))) OR

            CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper    AND
                                   crapfer.dtferiad = aux_dtmvtolt)   THEN
            .
       ELSE
            tel_qtdiaute = tel_qtdiaute + 1.

       aux_dtmvtolt = aux_dtmvtolt + 1.

    END.  /*  Fim do DO WHILE TRUE  */

    DISPLAY tel_dtfimper tel_qtdiaute WITH FRAME f_taxesp.

    IF   (tel_dtfimper - tel_dtiniper) < 28 THEN
         DO:
             glb_cdcritic = 13.
             NEXT-PROMPT tel_dtfimper WITH FRAME f_taxesp.
             NEXT.
         END.

    UPDATE  tel_txofimes WITH FRAME f_taxesp

            EDITING:
                READKEY.
                IF   FRAME-FIELD = "tel_txofimes"  THEN
                     IF   LASTKEY =  KEYCODE(".")   THEN
                          APPLY 44.
                     ELSE
                          APPLY LASTKEY.
                ELSE
                     APPLY LASTKEY.
            END.

    IF   tel_txofimes = 0  THEN
         DO:
            glb_cdcritic = 185.
            aux_flgerros = TRUE.
            NEXT-PROMPT tel_txofimes WITH FRAME f_taxesp.
            NEXT.
         END.

    LEAVE.

END.  /* Fim do DO WHILE TRUE */

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     DO:
        CLEAR FRAME f_taxesp.
        NEXT.
     END.

DO TRANSACTION ON ENDKEY UNDO, LEAVE:

   CREATE craptrd.

   ASSIGN tel_incarenc = TRUE
          craptrd.tptaxesp = tel_tptaxesp
          craptrd.dtiniper = tel_dtiniper
          craptrd.dtfimper = tel_dtfimper
          craptrd.qtdiaute = tel_qtdiaute
          craptrd.txofimes = tel_txofimes
          craptrd.vlfaixas = DEC(TRIM(ENTRY(aux_indpostp,aux_dsfaixas)))
          craptrd.incarenc = IF tel_incarenc
                                THEN 1
                                ELSE 0
          craptrd.txofidia = 0
          craptrd.txprodia = 0
          craptrd.incalcul = 0
          craptrd.cdcooper = glb_cdcooper.
   VALIDATE craptrd.

   CREATE craptrd.

   ASSIGN tel_incarenc = FALSE
          craptrd.tptaxesp = tel_tptaxesp
          craptrd.dtiniper = tel_dtiniper
          craptrd.dtfimper = tel_dtfimper
          craptrd.qtdiaute = tel_qtdiaute
          craptrd.txofimes = tel_txofimes
          craptrd.vlfaixas = DEC(TRIM(ENTRY(aux_indpostp,aux_dsfaixas)))
          craptrd.incarenc = IF tel_incarenc
                                THEN 1
                                ELSE 0
          craptrd.txofidia = 0
          craptrd.txprodia = 0
          craptrd.incalcul = 0
          craptrd.cdcooper = glb_cdcooper.
   VALIDATE craptrd.

END. /* Fim da transacao */

RELEASE craptrd.

CLEAR FRAME f_taxesp.

/* .......................................................................... */


