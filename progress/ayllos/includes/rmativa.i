/* .............................................................................
   Programa: Includes/rmativa.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Junho/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela RMATIV.
               
               03/11/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)


............................................................................. */
DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.



DO TRANSACTION ON ENDKEY UNDO, LEAVE:

   DO  aux_contador = 1 TO 10:

       FIND gnrativ WHERE gnrativ.cdrmativ = tel_cdrmativ
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE gnrativ   THEN
            IF   LOCKED gnrativ   THEN
                 DO:
                    RUN sistema/generico/procedures/b1wgen9999.p
                    PERSISTENT SET h-b1wgen9999.
                    
                    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(gnrativ),
                    					 INPUT "banco",
                    					 INPUT "gnrativ",
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

                     NEXT.
                 END.
            ELSE
                 DO:
                     glb_cdcritic = 878.
                     CLEAR FRAME f_ramos.
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
            DISPLAY tel_cdrmativ WITH FRAME f_ramos.
            MESSAGE glb_dscritic.
            NEXT.
        END.

   RUN pesq_setor_economico.

   DO WHILE TRUE:

      UPDATE tel_nmrmativ WITH FRAME f_ramos.
            
      RUN lista_setor_economico.
            
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
               LEAVE.
           END.

      /* verifica se setor enconomico existe */
      FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                         craptab.cdacesso = "SETORECONO" AND
                         craptab.tpregist = tel_cdseteco 
                         NO-LOCK NO-ERROR.
           
      IF   AVAILABLE craptab THEN
           ASSIGN gnrativ.nmrmativ = CAPS(tel_nmrmativ)
                  gnrativ.cdseteco = tel_cdseteco.
      ELSE
           DO:
               ASSIGN glb_cdcritic = 879.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               NEXT.
           END.
            
      LEAVE.

   END.

END. /* Fim da transacao */

RELEASE gnrativ.

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     NEXT.

CLEAR FRAME f_ramos NO-PAUSE.

/* .......................................................................... */
