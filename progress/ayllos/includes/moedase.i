/* .............................................................................

   Programa: Fontes/moedase.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91                          Ultima atualizacao: 03/11/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela MOEDAS.

   Alteracao : 31/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
   
               25/05/2009 - Alteracao CDOPERAD (Kbase).
               
               03/02/2014 - Inclusão de gravação de log quando houver exclusão
                            (Jean Michel)
                            
               03/11/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
............................................................................. */

DO TRANSACTION ON ENDKEY UNDO, LEAVE:

   DO  aux_contador = 1 TO 10:

       FIND crapmfx WHERE crapmfx.cdcooper = glb_cdcooper   AND
                          crapmfx.dtmvtolt = tel_dtmvtolt   AND
                          crapmfx.tpmoefix = tel_tpmoefix
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE crapmfx   THEN
            IF   LOCKED crapmfx   THEN
                 DO:
                    RUN sistema/generico/procedures/b1wgen9999.p
                    PERSISTENT SET h-b1wgen9999.
                    
                    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crapmfx),
                    					 INPUT "banco",
                    					 INPUT "crapmfx",
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
                    
                    glb_cdcritic = 77.
                    NEXT.
                 END.
           ELSE
                 DO:
                     glb_cdcritic = 211.
                     CLEAR FRAME f_moedas.
                     LEAVE.
                 END.
       ELSE
            DO:
                aux_contador = 0.
                LEAVE.
            END.
   END.

   IF   aux_contador <> 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT.
        END.

   IF   tel_dtmvtolt < glb_dtmvtolt   AND
        glb_dsdepart <> "TI"          THEN
        DO:
            ASSIGN glb_cdcritic = 212.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT.
        END.

   ASSIGN tel_vlmoefix = crapmfx.vlmoefix.

   DISPLAY tel_vlmoefix WITH FRAME f_moedas.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.

      RUN fontes/critic.p.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
        aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT.
        END.
    
   /* Grava log de exclusão */
   ASSIGN aux_msgdolog = "Excluida moeda tipo " + STRING(tel_tpmoefix) + " para data: " + STRING(tel_dtmvtolt,"99/99/9999") +  ", com valor de: " + STRING(crapmfx.vlmoefix).

   UNIX SILENT VALUE ("echo "      +   STRING(glb_dtmvtolt,"99/99/9999")     +
                      " - "        +   STRING(TIME,"HH:MM:SS")               +
                      " Operador: " + glb_cdoperad + " --- "                 +
                      aux_msgdolog                                           +
                      " >> /usr/coop/" + TRIM(crapcop.dsdircop)              + "/log/moedas.log").

   DELETE crapmfx.
   tel_vlmoefix = 0.
END. /* Fim da transacao */

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     NEXT.

CLEAR FRAME f_moedas NO-PAUSE.

/* .......................................................................... */
