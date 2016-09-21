/* .............................................................................

   Programa: Includes/taxesp2i.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Dezembro/96

   Dados referentes ao programa:                        Alteracao : 02/02/2006

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela taxesp para RDCA2.

   Alteracao : 08/02/2001 - Aplicacoes RDCA60 e Poup. Progr. apos o dia 28 do
                            mes. (Eduardo)

               07/07/2005 - Alimentado campo cdcooper da tabela craptrd (Diego).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
............................................................................. */

aux_indpostp = 1.

tel_vlfaixas = 0.

DISPLAY tel_vlfaixas WITH FRAME f_taxesp.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   UPDATE tel_vlfaixas  WITH FRAME f_taxesp.

   ASSIGN aux_flgfaixa = NO.
   DO  aux_qtdtxtab = 1 TO aux_qtfaixas:
       IF   aux_tptaxrda[aux_qtdtxtab] = INPUT FRAME f_taxesp tel_tptaxesp AND
            aux_vlfaixas[aux_qtdtxtab] = INPUT FRAME f_taxesp tel_vlfaixas THEN
            DO:
                ASSIGN aux_flgfaixa = YES.
                LEAVE.
            END.
   END. 
   IF   NOT aux_flgfaixa   THEN 
        DO:
            ASSIGN glb_cdcritic = 773.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
        END.
 
   LEAVE.

END.

IF   CAN-FIND(craptrd WHERE craptrd.cdcooper = glb_cdcooper     AND
                            craptrd.dtiniper = tel_dtiniper     AND
                            craptrd.tptaxrda = tel_tptaxesp     AND
                            craptrd.incarenc = 0                AND
                            craptrd.vlfaixas = tel_vlfaixas
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
            leave.
            
         END.

    tel_dscalcul = "".

    DISPLAY tel_dscalcul WITH FRAME f_taxesp.
                                        
    ASSIGN tel_dtfimper = IF   MONTH(tel_dtiniper) = 12 THEN
                               DATE(1,DAY(tel_dtiniper),
                                    (YEAR(tel_dtiniper) + 1))
                          ELSE       
                               DATE((MONTH(tel_dtiniper) + 1),
                                     DAY(tel_dtiniper),
                                     YEAR(tel_dtiniper))  NO-ERROR.   
    
    IF   ERROR-STATUS:ERROR THEN
         IF   MONTH(tel_dtiniper) = 11 THEN  
              tel_dtfimper = DATE(1, 1, (YEAR(tel_dtiniper) + 1)).
         ELSE
              IF   MONTH(tel_dtiniper) = 12 THEN
                   tel_dtfimper = DATE(2, 1, (YEAR(tel_dtiniper) + 1)).
              ELSE
                   tel_dtfimper = DATE((MONTH(tel_dtiniper) + 2), 1, 
                                        YEAR(tel_dtiniper)).
 
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

    UPDATE  tel_txofimes tel_txofidia tel_txprodia WITH FRAME f_taxesp

            EDITING:
                READKEY.
                IF   FRAME-FIELD = "tel_txofimes"  OR
                     FRAME-FIELD = "tel_txofidia"  OR
                     FRAME-FIELD = "tel_txprodia"  THEN
                     IF   LASTKEY =  KEYCODE(".")   THEN
                          APPLY 44.
                     ELSE
                          APPLY LASTKEY.
                ELSE
                     APPLY LASTKEY.
            END.
    /*
    IF   ((tel_txofimes > 0 AND tel_txofidia = 0) OR
          (tel_txofimes = 0 AND tel_txofidia> 0)) THEN
         DO:
            glb_cdcritic = 185.
            aux_flgerros = TRUE.
            NEXT-PROMPT tel_txofimes WITH FRAME f_taxesp.
            NEXT.
         END.

    IF   tel_txofimes = 0  AND  tel_txprodia = 0 THEN
         DO:
            glb_cdcritic = 185.
            aux_flgerros = TRUE.
            NEXT-PROMPT tel_txofimes WITH FRAME f_taxesp.
            NEXT.
         END.
    */
    LEAVE.

END.  /* Fim do DO WHILE TRUE */

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     DO:
        CLEAR FRAME f_taxesp.
        NEXT.
     END.

DO TRANSACTION ON ENDKEY UNDO, LEAVE:

   CREATE craptrd.
   ASSIGN craptrd.tptaxrda = tel_tptaxesp
          craptrd.dtiniper = tel_dtiniper
          craptrd.dtfimper = tel_dtfimper
          craptrd.qtdiaute = tel_qtdiaute
          craptrd.txofimes = tel_txofimes
          craptrd.vlfaixas = tel_vlfaixas
          craptrd.incarenc = 0
          craptrd.txofidia = tel_txofidia
          craptrd.txprodia = tel_txprodia
          craptrd.incalcul = 0
          craptrd.cdcooper = glb_cdcooper.

END. /* Fim da transacao */

RELEASE craptrd.

CLEAR FRAME f_taxesp.

/* .......................................................................... */

