/* .............................................................................

   Programa: Fontes/secexte.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela SECEXT.
   
               03/11/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)

............................................................................. */

DEF        VAR aux_temassoc AS LOGICAL                               NO-UNDO.
DEF        VAR aux_contador AS INTEGER                               NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.


DO TRANSACTION ON ENDKEY UNDO, LEAVE:

   DO  aux_contador = 1 TO 10:

       FIND crapdes WHERE crapdes.cdcooper = glb_cdcooper  AND
                          crapdes.cdagenci = tel_cdagenci  AND
                          crapdes.cdsecext = tel_cdsecext
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE crapdes   THEN
            IF   LOCKED crapdes   THEN
                 DO:
                    RUN sistema/generico/procedures/b1wgen9999.p
                    PERSISTENT SET h-b1wgen9999.
                    
                    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crapdes),
                    					 INPUT "banco",
                    					 INPUT "crapdes",
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
                     glb_cdcritic = 19.
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
            PAUSE 5 NO-MESSAGE.
            HIDE FRAME f_secao.
            NEXT.
        END.

   ASSIGN tel_cdsecext  =  crapdes.cdsecext
          tel_nmsecext  =  crapdes.nmsecext
          tel_nmpesext  =  crapdes.nmpesext
          tel_cdagenci  =  crapdes.cdagenci
          tel_nrfonext  =  crapdes.nrfonext
          tel_indespac  =  IF   crapdes.indespac = 0 THEN
                                TRUE
                           ELSE FALSE.
            
   DISPLAY  tel_nmsecext  tel_nmpesext  tel_nrfonext  tel_indespac
            WITH FRAME f_secao.

   FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper AND
                            crapass.cdagenci = tel_cdagenci AND
                            crapass.cdsecext = tel_cdsecext 
                            NO-LOCK NO-ERROR.

   aux_temassoc = (AVAILABLE crapass).

   IF   aux_temassoc THEN
        DO:
            glb_cdcritic = 233.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            PAUSE 5 NO-MESSAGE.
            HIDE FRAME f_secao.
            NEXT.
        END.

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
            PAUSE 5 NO-MESSAGE.
            HIDE FRAME f_secao.
            NEXT.
        END.

   DELETE crapdes.

   HIDE FRAME f_secao.

END. /* Fim da transacao */

/* .......................................................................... */

