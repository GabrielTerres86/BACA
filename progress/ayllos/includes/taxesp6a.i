/* .............................................................................

   Programa: Includes/taxesp6a.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/97

   Dados referentes ao programa:                    Alteracao : 22/09/2014

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela taxesp para RDCA6.

   Alteracao : 02/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               22/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)

............................................................................. */

DO TRANSACTION ON ENDKEY UNDO, LEAVE:

   DO  aux_contador = 1 TO 5:

       FIND craptrd WHERE craptrd.cdcooper = glb_cdcooper   AND
                          craptrd.dtiniper = tel_dtiniper   AND
                          craptrd.tptaxrda = tel_tptaxesp   AND
                          craptrd.incarenc = 0              AND
                          craptrd.vlfaixas = 0
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE craptrd   THEN
            IF   LOCKED craptrd   THEN
                 DO:
                    RUN sistema/generico/procedures/b1wgen9999.p
                    PERSISTENT SET h-b1wgen9999.
                    
                    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptrd),
                                         INPUT "banco",
                                         INPUT "craptrd",
                                         OUTPUT par_loginusr,
                                         OUTPUT par_nmusuari,
                                         OUTPUT par_dsdevice,
                                         OUTPUT par_dtconnec,
                                         OUTPUT par_numipusr).
                    
                    DELETE PROCEDURE h-b1wgen9999.
                    
                    ASSIGN aux_dadosusr = 
                    "077 - Tabela sendo alterada p/ outro terminal.".
                    
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    MESSAGE aux_dadosusr.
                    PAUSE 3 NO-MESSAGE.
                    LEAVE.
                    END.
                    
                    ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                  " - " + par_nmusuari + ".".
                    
                    HIDE MESSAGE NO-PAUSE.
                    
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    MESSAGE aux_dadosusr.
                    PAUSE 5 NO-MESSAGE.
                    LEAVE.
                    END.
                    
                    glb_cdcritic = 0.
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

                IF   (craptrd.incalcul > 1)   THEN
                     glb_cdcritic = 424.

                ASSIGN  tel_dtfimper = craptrd.dtfimper
                        tel_qtdiaute = craptrd.qtdiaute
                        tel_txofimes = craptrd.txofimes
                        tel_txofidia = craptrd.txofidia
                        tel_txprodia = craptrd.txprodia
                        tel_dscalcul = IF   craptrd.incalcul > 0 THEN
                                           "SIM"
                                       ELSE
                                           "NAO".

                DISPLAY tel_dtfimper tel_qtdiaute tel_txofimes tel_txofidia
                        tel_txprodia tel_dscalcul WITH FRAME f_taxesp.

                LEAVE.
            END.
   END.

   IF   (aux_contador <> 0  OR glb_cdcritic > 0 ) THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
        END.

   aux_flgerros = FALSE.

   DO  WHILE TRUE :

       IF   glb_cdcritic > 0 THEN
            DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
            END.

       ASSIGN tel_dtfimper =  IF   MONTH(tel_dtiniper) = 12 THEN
                                DATE(1,DAY(tel_dtiniper),YEAR(tel_dtiniper) + 1)
                              ELSE DATE(MONTH(tel_dtiniper) + 1,
                                DAY(tel_dtiniper),YEAR(tel_dtiniper))

              aux_dtmvtolt = tel_dtiniper
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

       UPDATE tel_txofimes WITH FRAME f_taxesp

               EDITING:
                   READKEY.
                   IF   FRAME-FIELD = "tel_txofimes"  THEN
                        IF   LASTKEY =  KEYCODE(".")  THEN
                             APPLY 44.
                        ELSE
                             APPLY LASTKEY.
                   ELSE
                        APPLY LASTKEY.
               END.

       IF   tel_txofimes = 0  THEN
            DO:
                glb_cdcritic = 185.
                NEXT-PROMPT tel_txprodia WITH FRAME f_taxesp.
                NEXT.
            END.

       LEAVE.
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        NEXT.

   ASSIGN craptrd.dtiniper = tel_dtiniper
          craptrd.dtfimper = tel_dtfimper
          craptrd.qtdiaute = tel_qtdiaute
          craptrd.incarenc = 0
          craptrd.vlfaixas = 0
          craptrd.txofimes = tel_txofimes
          craptrd.txofidia = tel_txofidia
          craptrd.txprodia = tel_txprodia.

END.   /* Fim da transacao */

RELEASE craptrd.

CLEAR FRAME f_taxesp.

/* .......................................................................... */
