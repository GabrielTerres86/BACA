/* .............................................................................

   Programa: Fontes/tab088.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Vitor
   Data    : Novembro/2010                           Ultima alteracao: 19/09/2014   

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAB088 (Solicita o envio de informativos no dia)
   
   Alteracao : 
              19/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
............................................................................. */

{ includes/var_online.i }

DEF  VAR tel_enviainf       AS LOGICAL FORMAT "Sim/Nao"            NO-UNDO.
DEF  VAR tel_ultenvio       AS CHAR FORMAT "x(10)"                 NO-UNDO.

DEF  VAR aux_confirma       AS CHAR                                NO-UNDO.
DEF  VAR aux_cddopcao       AS CHAR                                NO-UNDO.
DEF  VAR aux_contador       AS INT     FORMAT "z9"                 NO-UNDO.
DEF  VAR aux_dssimnao       AS CHAR                                NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.


FORM SKIP (1)
     "Opcao:"     AT 4
     glb_cddopcao AT 11 NO-LABEL AUTO-RETURN
                  HELP "Entre com a opcao desejada (A,C)."
                  VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C",
                            "014 - Opcao errada.")

    SKIP(4)
    tel_enviainf AT 15 LABEL "ENVIAR INFORMATIVO"
                       VALIDATE(tel_enviainf = "Sim" OR tel_enviainf = "Nao",
                                "014 - Opcao errada.")
                       HELP "Enviar Informativo? Sim/Nao"
    SKIP(1)
    tel_ultenvio AT 11 LABEL "ULTIMO ENVIO PERIODICO"
    SKIP(7)
    WITH  SIDE-LABELS ROW 4 TITLE glb_tldatela  WIDTH 80
    FRAME f_tab088.


ASSIGN glb_cddopcao = "C".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       UPDATE glb_cddopcao WITH FRAME f_tab088.
       LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "TAB088"   THEN
                 DO:
                     HIDE FRAME f_tab088.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <>  glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao =  glb_cddopcao.
        END.

   IF   glb_cddopcao = "A" THEN
        DO:
            DO TRANSACTION ON ENDKEY UNDO, LEAVE: 

               DO  aux_contador = 1 TO 10:

                   FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                      craptab.nmsistem = "CRED"         AND
                                      craptab.tptabela = "USUARI"       AND
                                      craptab.cdempres = 11             AND
                                      craptab.cdacesso = "ENVINFORMA"   AND
                                      craptab.tpregist = 001            
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE craptab   THEN
                        IF   LOCKED craptab   THEN
                             DO:
                                  RUN sistema/generico/procedures/b1wgen9999.p
                                  PERSISTENT SET h-b1wgen9999.

                                  RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                                                                 INPUT "banco",
                                                                 INPUT "craptab",
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
                                 glb_cdcritic = 55.
                                 CLEAR FRAME f_tab088.
                                 LEAVE.
                             END.
                   ELSE
                        DO:
                            aux_contador = 0.
                            LEAVE.
                        END.

               END. /*aux_contador*/

               IF   aux_contador <> 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT.
                    END.
                                
               DO WHILE TRUE:

                   ASSIGN tel_ultenvio = SUBSTRING(craptab.dstextab,5,10)
                          aux_confirma = SUBSTRING(craptab.dstextab,1,3)
                          aux_dssimnao = aux_confirma.  

                   IF aux_confirma = "Nao" THEN
                      tel_enviainf =  FALSE.
                   ELSE 
                      tel_enviainf =  TRUE.

                   DISPLAY tel_enviainf
                           tel_ultenvio WITH FRAME f_tab088.
                    
                   UPDATE tel_enviainf WITH FRAME f_tab088.

                   ASSIGN aux_confirma = INPUT tel_enviainf
                          SUBSTR(craptab.dstextab,1,3) = aux_confirma.

                   IF aux_confirma = "Nao" THEN
                       tel_enviainf = FALSE.
                   ELSE 
                       tel_enviainf = TRUE.        

                   IF tel_enviainf = TRUE AND 
                      aux_dssimnao <> aux_confirma THEN
                       DO:
                           UNIX SILENT VALUE("echo " +  
                                      STRING(glb_dtmvtolt,"99/99/9999") + 
                                      " - " + STRING(TIME,"HH:MM:SS") +
                                      " - SOLICITACAO ' --> '"  +
                                      " Operador: " + glb_cdoperad +
                                      " solicitou envio de informativo " +
                                      " >> log/tab088.log").
                       END.
                   ELSE
                       IF tel_enviainf = FALSE AND 
                          aux_dssimnao <> aux_confirma THEN
                            DO:
                                UNIX SILENT VALUE("echo " +  
                                           STRING(glb_dtmvtolt,"99/99/9999") + 
                                           " - " + STRING(TIME,"HH:MM:SS") +
                                           " - SOLICITACAO ' --> '"  +
                                           " Operador: " + glb_cdoperad +
                                           " desfez solicitacao de envio de informativo " +
                                           " >> log/tab088.log").
                            END.

                   LEAVE.

               END. /*DO WHILE TRUE*/
            END. /*DO TRANSACTION*/  
        END. /*glb_cddopcao = "A"*/
   ELSE
       IF   glb_cddopcao = "C" THEN
           DO:
               FIND craptab WHERE
                    craptab.cdcooper = glb_cdcooper   AND
                    craptab.nmsistem = "CRED"         AND
                    craptab.tptabela = "USUARI"       AND
                    craptab.cdempres = 11             AND
                    craptab.cdacesso = "ENVINFORMA"   AND
                    craptab.tpregist = 001             
                    NO-LOCK NO-ERROR NO-WAIT.
          
               IF   AVAILABLE craptab   THEN
                     DO:
                        ASSIGN tel_ultenvio = SUBSTRING(craptab.dstextab,5,10).
                               aux_confirma = SUBSTRING(craptab.dstextab,1,3).
          
                        IF aux_confirma = "Nao" THEN
                           tel_enviainf =  FALSE.
                        ELSE 
                           tel_enviainf =  TRUE.
                    
                        DISPLAY tel_enviainf
                                tel_ultenvio WITH FRAME f_tab088.
          
                     END.
               ELSE
                   DO:
                       glb_cdcritic = 55.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE glb_dscritic.
                       CLEAR FRAME f_tab088.
                       NEXT.
                   END.
           END.
END. /*DO WHILE TRUE*/


