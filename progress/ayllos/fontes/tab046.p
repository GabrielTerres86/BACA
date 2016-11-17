/* .............................................................................

   Programa: Fontes/tab046.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : GATI (Eder)        
   Data    : Julho/2010                            Ultima alteracao: 19/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAB046 - Motivos de Devolução de mensagens no SPB.

   Alteracoes: 28/07/2010 - Operar tela somente na CECRED (Diego).
               
               19/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_cddoerro AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_dsdoerro AS CHAR    FORMAT "x(59)"                NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.



FORM  "Opcao:"     AT  4
      glb_cddopcao AT 11 NO-LABEL
                   HELP "Informe a opcao desejada (A, C, E ou I). "
                   VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                             glb_cddopcao = "E" OR glb_cddopcao = "I",
                             "014 - Opcao errada.")
      WITH NO-BOX ROW 6 COLUMN 2 OVERLAY  FRAME f_opcao.

FORM "Codigo   :"    AT 8  
     tel_cddoerro    HELP "Informe o codigo do erro ou F7 para listar."
     SKIP(1)
     "Descricao:"    AT 8  
     tel_dsdoerro    HELP "Informe a descricao do erro."
     WITH NO-LABEL   NO-BOX ROW 8 COLUMN 2 OVERLAY FRAME f_dados.
        
FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.


DEF QUERY  mensag-q FOR craptab.
DEF BROWSE mensag-b QUERY mensag-q
      DISP SPACE(5)
           craptab.tpregist                  COLUMN-LABEL "Codigo"
           SPACE(3)
           craptab.dstextab   FORMAT "x(59)" COLUMN-LABEL "Motivo devolucao"
           SPACE(5)
           WITH  9 DOWN OVERLAY TITLE "Motivos de devolucao TED/TEC".

DEF FRAME f_mensag
          mensag-b HELP "Use as SETAS para navegar e <F4> para sair" SKIP
          WITH NO-BOX CENTERED OVERLAY ROW 8 .


ON  RETURN OF mensag-b 
    DO:
        ASSIGN tel_cddoerro = craptab.tpregist
               tel_dsdoerro = craptab.dstextab.
               
        DISPLAY tel_cddoerro tel_dsdoerro WITH FRAME f_dados.    
        APPLY "GO".
    END.    
    
    
glb_cddopcao = "C".

VIEW FRAME f_moldura.

PAUSE 0.

DO WHILE TRUE:
              
   RUN fontes/inicia.p.

   ASSIGN  tel_cddoerro = INT(" ")
           tel_dsdoerro = "".
   DISPLAY tel_cddoerro 
           tel_dsdoerro WITH frame f_dados.
   CLEAR FRAME f_dados NO-PAUSE.  
          
   DISPLAY glb_cddopcao WITH FRAME f_opcao.
        
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      PROMPT-FOR glb_cddopcao WITH FRAME f_opcao.
      LEAVE.
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "TAB046"   THEN
                 DO:
                     HIDE FRAME f_opcao.
                     HIDE FRAME f_dados.   
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> INPUT glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = INPUT glb_cddopcao.
        END.
                       
   ASSIGN glb_cddopcao = INPUT glb_cddopcao.
   
   /* Opera tela somente na CECRED */
   IF   glb_cdcooper <> 3  THEN
        DO:
            MESSAGE "Opcao disponivel somente para CECRED".
            NEXT.
        END.
   
   IF   INPUT glb_cddopcao = "A" THEN
        DO:
            DISPLAY tel_dsdoerro WITH FRAME f_dados. /**Limpa campo**/
            DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:
                          
               UPDATE tel_cddoerro  WITH FRAME f_dados
                         
               EDITING:
                   READKEY.

                   IF  LASTKEY = KEYCODE("F7") THEN              
                       DO:
                           IF FRAME-FIELD = "tel_cddoerro" THEN  
                              DO:
                                 OPEN QUERY mensag-q 
                                      FOR EACH craptab WHERE 
                                               craptab.cdcooper = 0        AND
                                               craptab.nmsistem = "CRED"   AND
                                               craptab.tptabela = "GENERI" AND
                                               craptab.cdempres = 0        AND
                                               craptab.cdacesso = "CDERROSSPB"
                                               NO-LOCK.

                                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                    UPDATE mensag-b WITH FRAME f_mensag.
                                    LEAVE.   
                                 END. 
                         
                                 HIDE FRAME f_mensag.
                                 NEXT.   
                              END.
                       END. 
                   ELSE 
                       APPLY LASTKEY.
               END.  /*** fim EDITING */
                         
               DO  aux_contador = 1 TO 10:
                         
                   FIND craptab WHERE craptab.cdcooper = 0              AND 
                                      craptab.nmsistem = "CRED"         AND
                                      craptab.tptabela = "GENERI"       AND
                                      craptab.cdempres = 0              AND
                                      craptab.cdacesso = "CDERROSSPB"   AND
                                      craptab.tpregist = tel_cddoerro
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
                                     
                        NEXT.
                         END.
                        ELSE
                             DO:
                                 MESSAGE "Codigo de erro nao cadastrado.".    
                                 ASSIGN  tel_dsdoerro = "".
                                 DISPLAY tel_dsdoerro WITH frame f_dados.
                                 CLEAR FRAME f_dados NO-PAUSE.  
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
                        NEXT.
                    END.
                         
               ASSIGN  tel_dsdoerro = craptab.dstextab.
               DISPLAY tel_dsdoerro WITH FRAME f_dados.

               UPDATE tel_dsdoerro WITH FRAME f_dados.
                  
               DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

                   ASSIGN aux_confirma = "N"
                          glb_cdcritic = 78.
                   RUN fontes/critic.p.
                   BELL.
                   MESSAGE COLOR NORMAL glb_dscritic
                   UPDATE aux_confirma.
                   LEAVE.

               END.

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                    aux_confirma <> "S" THEN
                    DO:
                        glb_cdcritic = 79.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        /**Desfaz alteracao***/
                        ASSIGN  tel_dsdoerro = craptab.dstextab.
                        DISPLAY tel_cddoerro tel_dsdoerro WITH FRAME f_dados.
                        NEXT.
                    END.

               ASSIGN craptab.dstextab = tel_dsdoerro.
               MESSAGE "Alteracao efetuada com sucesso!".
               LEAVE.   
            
            END. /* Fim da transacao */

            RELEASE craptab.
 
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                 DO:                               
                    ASSIGN tel_cddoerro = INT("")
                    tel_dsdoerro = "".
                    display tel_cddoerro tel_dsdoerro with frame f_dados.
                    NEXT.
                 END.   
   
        END. /* IF   INPUT glb_cddopcao = "A" THEN */
   ELSE   
   IF   INPUT glb_cddopcao = "C" THEN
        DO:
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
              UPDATE tel_cddoerro  WITH FRAME f_dados
                     
              EDITING:
                 READKEY.
             
                 IF LASTKEY = KEYCODE("F7") THEN              
                    DO:
                       IF FRAME-FIELD = "tel_cddoerro" THEN  
                          DO:
                             OPEN QUERY mensag-q 
                                  FOR EACH craptab WHERE 
                                           craptab.cdcooper = 0         AND
                                           craptab.nmsistem = "CRED"    AND
                                           craptab.tptabela = "GENERI"  AND
                                           craptab.cdempres = 0         AND
                                           craptab.cdacesso = "CDERROSSPB"
                                           NO-LOCK.
           
                             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                UPDATE mensag-b WITH FRAME f_mensag.
                                LEAVE.   
                             END. 
                         
                             HIDE FRAME f_mensag.
                             NEXT.   
                          END.
                    END. 
                 ELSE 
                    APPLY LASTKEY.
              END.  /*** fim EDITING */

              FIND craptab WHERE
                   craptab.cdcooper = 0              AND 
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "GENERI"       AND
                   craptab.cdempres = 0              AND
                   craptab.cdacesso = "CDERROSSPB"   AND
                   craptab.tpregist = tel_cddoerro
                   NO-LOCK NO-ERROR.
              
              IF   NOT AVAILABLE craptab   THEN
                   DO:
                        MESSAGE "Codigo de erro nao cadastrado.".
                        ASSIGN  tel_dsdoerro = "".
                        DISPLAY tel_dsdoerro WITH FRAME f_dados.
                        NEXT.
                   END.
              
              ASSIGN  tel_dsdoerro = craptab.dstextab.
              DISPLAY tel_dsdoerro WITH FRAME f_dados.
           
           END. /* Fim do DO WHILE TRUE */
        END. /* IF   INPUT glb_cddopcao = "C" THEN */
   ELSE
   IF   INPUT glb_cddopcao = "E"   THEN
        DO:            
            DISPLAY tel_dsdoerro        /* Mostra campo limpo*/
                    WITH FRAME f_dados.  
            DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

               UPDATE tel_cddoerro WITH FRAME f_dados
               
               EDITING:
                  READKEY.

                  IF LASTKEY = KEYCODE("F7") THEN              
                     DO:
                        IF FRAME-FIELD = "tel_cddoerro" THEN  
                           DO:
                              OPEN QUERY mensag-q 
                                   FOR EACH craptab WHERE 
                                            craptab.cdcooper = 0            AND
                                            craptab.nmsistem = "CRED"       AND
                                            craptab.tptabela = "GENERI"     AND
                                            craptab.cdempres = 0            AND
                                            craptab.cdacesso = "CDERROSSPB"
                                            NO-LOCK.

                              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                 UPDATE mensag-b WITH FRAME f_mensag.
                                 LEAVE.   
                             END. 
                   
                             HIDE FRAME f_mensag.
                             NEXT.   
                           END.
                     END. 
                  ELSE 
                      APPLY LASTKEY.
               END.  /*** fim EDITING */

               DO  aux_contador = 1 TO 10:
                   FIND craptab WHERE
                        craptab.cdcooper = 0              AND 
                        craptab.nmsistem = "CRED"         AND
                        craptab.tptabela = "GENERI"       AND
                        craptab.cdempres = 0              AND
                        craptab.cdacesso = "CDERROSSPB"   AND
                        craptab.tpregist = tel_cddoerro
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
                            MESSAGE "Codigo de erro nao cadastrado.".
                            ASSIGN  tel_dsdoerro = "".
                            DISPLAY tel_dsdoerro WITH FRAME f_dados.
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
                        NEXT.
                    END.

               ASSIGN  tel_dsdoerro = craptab.dstextab.
               DISPLAY tel_dsdoerro WITH FRAME f_dados.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  ASSIGN aux_confirma = "N"
                         glb_cdcritic = 78.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE COLOR NORMAL glb_dscritic
                          UPDATE aux_confirma.
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

               DELETE craptab.
               /***limpa frame***/
               ASSIGN tel_cddoerro = INT("")
                      tel_dsdoerro = "".
               DISPLAY tel_cddoerro tel_dsdoerro WITH FRAME f_dados.
               MESSAGE "Exclusao efetuada com sucesso!".
               LEAVE.
            
            END. /* Fim da transacao */

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                 /*  F4 OU FIM  */
                 NEXT.
        END. /* IF   INPUT glb_cddopcao = "E" */
   ELSE     
   IF   INPUT glb_cddopcao = "I"   THEN
        DO WHILE TRUE:
            
           UPDATE tel_cddoerro tel_dsdoerro WITH FRAME f_dados
           
           EDITING:
              READKEY.
              
              IF   LASTKEY = KEYCODE("F7") THEN              
                   DO:
                       IF FRAME-FIELD = "tel_cddoerro" THEN  
                          DO:
                            OPEN QUERY mensag-q 
                                 FOR EACH craptab WHERE 
                                          craptab.cdcooper = 0              AND
                                          craptab.nmsistem = "CRED"         AND
                                          craptab.tptabela = "GENERI"       AND
                                          craptab.cdempres = 0              AND
                                          craptab.cdacesso = "CDERROSSPB"
                                          NO-LOCK.
                       
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                               UPDATE mensag-b WITH FRAME f_mensag.
                               LEAVE.   
                            END. 
                       
                            HIDE FRAME f_mensag.
                            NEXT.   
                          END.
                   END. 
              ELSE 
                   APPLY LASTKEY.
           END.  /* Fim EDITING */

           FIND craptab WHERE
                craptab.cdcooper = 0              AND 
                craptab.nmsistem = "CRED"         AND
                craptab.tptabela = "GENERI"       AND
                craptab.cdempres = 0              AND
                craptab.cdacesso = "CDERROSSPB"   AND
                craptab.tpregist = tel_cddoerro  
                NO-LOCK NO-ERROR NO-WAIT.
           
           IF   AVAILABLE craptab   THEN
                DO:
                  MESSAGE "Codigo de erro ja cadastrado.".
                  NEXT.       
                END.
           
           IF   tel_cddoerro = 0 THEN
                DO:
                   MESSAGE "Codigo do erro deve ser maior que '0'.".
                   NEXT.
                END.
           
           DO   WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                ASSIGN aux_confirma = "N"
                       glb_cdcritic = 78.
                RUN fontes/critic.p.
                BELL.
                MESSAGE COLOR NORMAL glb_dscritic
                        UPDATE aux_confirma.
                LEAVE.
           END.
           
           IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                aux_confirma <> "S" THEN
                DO:
                    glb_cdcritic = 79.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    ASSIGN tel_cddoerro = INT("")
                           tel_dsdoerro = "".
                    DISPLAY tel_cddoerro
                            tel_dsdoerro WITH FRAME f_dados.
                    NEXT.
                END.
           
           
           DO   TRANSACTION ON ENDKEY UNDO, LEAVE:
                
                CREATE craptab.
                ASSIGN craptab.nmsistem = "CRED"
                       craptab.tptabela = "GENERI"
                       craptab.cdempres = 0
                       craptab.cdacesso = "CDERROSSPB"
                       craptab.tpregist = tel_cddoerro
                       craptab.dstextab = tel_dsdoerro
                       craptab.cdcooper = 0.

           END. /* Fim da transacao */
           
           RELEASE craptab.
           
           IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                /* F4  FIM */
                NEXT.

           MESSAGE "Inclusao efetuada com sucesso!".
           
           CLEAR FRAME f_dados NO-PAUSE.
           ASSIGN tel_cddoerro = INT("")
                  tel_dsdoerro = "".
        END. /* IF   INPUT glb_cddopcao = "I"   THEN */
END.  /* Fim DO WHILE TRUE: (bloco principal) */
         
/* .......................................................................... */
