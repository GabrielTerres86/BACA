/* .............................................................................

   Programa: Fontes/tab003.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91                          Ultima alteracao: 19/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAB003.

   Alteracoes: 19/08/94 - Alterado para dar manutencao na tabela de parametros
                          para baixa de valores dos demitidos.

               05/07/2005 - Alimentado campo cdcooper da tabela craptab (Diego).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               19/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_qtddbxvl AS INT     FORMAT "zzz9"                 NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF VAR aux_dadosusr         AS CHAR                            NO-UNDO.
DEF VAR par_loginusr         AS CHAR                            NO-UNDO.
DEF VAR par_nmusuari         AS CHAR                            NO-UNDO.
DEF VAR par_dsdevice         AS CHAR                            NO-UNDO.
DEF VAR par_dtconnec         AS CHAR                            NO-UNDO.
DEF VAR par_numipusr         AS CHAR                            NO-UNDO.
DEF VAR h-b1wgen9999         AS HANDLE                          NO-UNDO.


FORM  SKIP (3)
      "Opcao:"     AT  4
      glb_cddopcao AT 11 NO-LABEL
        HELP "Entre com a opcao desejada"
        VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                 glb_cddopcao = "E" OR glb_cddopcao = "I","014 - Opcao errada.")
        AUTO-RETURN
      SKIP (3)
      "Quantidade de dias de permanencia dos valores" AT 15
      SKIP (1)
      tel_qtddbxvl AT 35 NO-LABEL
        HELP "Entre com a quantidade de dias (deve ser maior que 364)."
        VALIDATE (tel_qtddbxvl > 364,"026 - Quantidade errada")
        AUTO-RETURN
      SKIP (6)
      WITH SIDE-LABELS TITLE COLOR MESSAGE
      " Parametro de Permanencia dos Valores dos Demitidos "
      ROW 4 COLUMN 1 OVERLAY WIDTH 80 FRAME f_tab003.

glb_cddopcao = "C".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DISPLAY glb_cddopcao WITH FRAME f_tab003.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      PROMPT-FOR glb_cddopcao WITH FRAME f_tab003.
      LEAVE.
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "TAB003"   THEN
                 DO:
                     HIDE FRAME f_tab003.
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

   IF   INPUT glb_cddopcao = "A" THEN
        DO:
            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               DO  aux_contador = 1 TO 10:

                   FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND 
                                      craptab.nmsistem = "CRED"         AND
                                      craptab.tptabela = "USUARI"       AND
                                      craptab.cdempres = 11             AND
                                      craptab.cdacesso = "DIASBAXVAL"   AND
                                      craptab.tpregist = 000
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE craptab   THEN
                        IF  LOCKED craptab   THEN
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
                                                              

                         END.
                        ELSE
                             DO:
                                 glb_cdcritic = 55.
                                 CLEAR FRAME f_tab003.
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

               ASSIGN  tel_qtddbxvl = INTEGER(craptab.dstextab).
               DISPLAY tel_qtddbxvl WITH FRAME f_tab003.

               DO WHILE TRUE:

                  SET tel_qtddbxvl WITH FRAME f_tab003.
                  craptab.dstextab = STRING(tel_qtddbxvl).
                  LEAVE.

               END.

            END. /* Fim da transacao */

            RELEASE craptab.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                 NEXT.

            CLEAR FRAME f_tab003 NO-PAUSE.

        END.
   ELSE
        IF   INPUT glb_cddopcao = "C" THEN
             DO:
                 FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND 
                                    craptab.nmsistem = "CRED"         AND
                                    craptab.tptabela = "USUARI"       AND
                                    craptab.cdempres = 11             AND
                                    craptab.cdacesso = "DIASBAXVAL"   AND
                                    craptab.tpregist = 000
                                    NO-LOCK NO-ERROR NO-WAIT.

                 IF   AVAILABLE craptab   THEN
                      DO:
                          ASSIGN  tel_qtddbxvl = INTEGER(craptab.dstextab).
                          DISPLAY tel_qtddbxvl WITH FRAME f_tab003.
                      END.
                 ELSE
                      DO:
                          glb_cdcritic = 55.
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          CLEAR FRAME f_tab003.
                          NEXT.
                      END.
             END.
        ELSE
             IF   INPUT glb_cddopcao = "E"   THEN
                  DO:
                      DO TRANSACTION ON ENDKEY UNDO, LEAVE:

                         DO  aux_contador = 1 TO 10:
                             FIND craptab WHERE
                                  craptab.cdcooper = glb_cdcooper   AND 
                                  craptab.nmsistem = "CRED"         AND
                                  craptab.tptabela = "USUARI"       AND
                                  craptab.cdempres = 11             AND
                                  craptab.cdacesso = "DIASBAXVAL"   AND
                                  craptab.tpregist = 000
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                             IF   NOT AVAILABLE craptab   THEN
                                  IF   LOCKED craptab   THEN
                                       DO:
                                           glb_cdcritic = 77.
                                           PAUSE 1 NO-MESSAGE.
                                           NEXT.
                                       END.
                                  ELSE
                                       DO:
                                           glb_cdcritic = 55.
                                           CLEAR FRAME f_tab003.
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

                         ASSIGN  tel_qtddbxvl = INTEGER(craptab.dstextab).
                         DISPLAY tel_qtddbxvl WITH FRAME f_tab003.

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
                         CLEAR FRAME f_tab003 NO-PAUSE.

                      END. /* Fim da transacao */

                      IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                           /*  F4 OU FIM  */
                           NEXT.
                  END.
             ELSE
                  IF   INPUT glb_cddopcao = "I"   THEN
                       DO:
                           FIND craptab WHERE
                                craptab.cdcooper = glb_cdcooper   AND 
                                craptab.nmsistem = "CRED"         AND
                                craptab.tptabela = "USUARI"       AND
                                craptab.cdempres = 11             AND
                                craptab.cdacesso = "DIASBAXVAL"   AND
                                craptab.tpregist = 000
                                NO-LOCK NO-ERROR NO-WAIT.

                           IF   AVAILABLE craptab   THEN
                                DO:
                                    glb_cdcritic = 56.
                                    RUN fontes/critic.p.
                                    BELL.
                                    MESSAGE glb_dscritic.
                                    CLEAR FRAME f_tab003.
                                    ASSIGN  tel_qtddbxvl =
                                            INTEGER(craptab.dstextab).
                                    DISPLAY tel_qtddbxvl WITH FRAME f_tab003.
                                    NEXT.
                                END.

                           DO TRANSACTION ON ENDKEY UNDO, LEAVE:

                              CREATE craptab.

                              ASSIGN craptab.nmsistem = "CRED"
                                     craptab.tptabela = "USUARI"
                                     craptab.cdempres = 11
                                     craptab.cdacesso = "DIASBAXVAL"
                                     craptab.tpregist = 000
                                     craptab.cdcooper = glb_cdcooper.

                              DO WHILE TRUE:

                                 SET tel_qtddbxvl WITH FRAME f_tab003.
                                 craptab.dstextab = STRING(tel_qtddbxvl).
                                 LEAVE.
                              END.

                           END. /* Fim da transacao */

                           RELEASE craptab.

                           IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                               /* F4  FIM */
                               NEXT.

                           CLEAR FRAME f_tab003 NO-PAUSE.
                       END.
END.

/* .......................................................................... */
