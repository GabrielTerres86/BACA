/* .............................................................................

   Programa: Fontes/tab086.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Abril/2010                           Ultima alteracao: 13/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : tab086 - Execucao da Compensacao ABBC
   
   Alteracao : 23/08/2010 - Incluir arquivo com a hora p/ script (Ze).
   
               13/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)
                            
               19/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
 
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_execabbc AS LOG FORMAT "SIM/NAO"                  NO-UNDO.
DEF        VAR tel_nrdhhini AS INT                                   NO-UNDO.
DEF        VAR tel_nrdmmini AS INT                                   NO-UNDO.

DEF        VAR aux_execabbc AS LOG FORMAT "SIM/NAO"                  NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrdahora AS INT                                   NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!"                    NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.

FORM SKIP(2)
     glb_cddopcao AT 14 LABEL "Opcao" AUTO-RETURN FORMAT "!"
                           HELP "Entre com a opcao desejada (A,C)."
                           VALIDATE(CAN-DO("A,C",glb_cddopcao),
                                    "014 - Opcao errada.")
     SKIP(1)
     tel_execabbc AT 26  LABEL "Executar Compensacao ABBC?" 
         HELP "Informe se a Cooperativa executará Compensacao ABBC"
     SKIP(1)
     tel_nrdhhini AT  4  
                  LABEL "Horario limite para aguardar a Nossa COMPE(ABBC)"
                  FORMAT "99" AUTO-RETURN
                  HELP "Informe o horario limite (4 a 9)."
     ":"          AT 56 
     tel_nrdmmini AT 57  NO-LABEL FORMAT "99" 
                         HELP "Informe os minutos limite (0 a 59)."
     "Horas"
     SKIP(2)
     "IMPORTANTE: Esta modific. altera tambem no horario de execucao do script."
     AT 03
     SKIP(2)
     "  ATENCAO! A partir do horario informado acima, o sistema continuara" SKIP
     "           o processamento diario independentemente do recebimento"   SKIP
     "           dos arquivos de compensacao da ABBC."
     SKIP(1)
     WITH ROW 4 OVERLAY SIDE-LABELS WIDTH 80 TITLE glb_tldatela FRAME f_tab086.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       glb_cdprogra = "tab086"
       aux_nmarquiv = "arquivos/.executaabbc".

VIEW FRAME f_moldura.
PAUSE(0).

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao WITH FRAME f_tab086.
      LEAVE.
      
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "TAB086"   THEN
                 DO:
                     HIDE FRAME f_tab086.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.


   /*** Tabela com os valores VLB para Titulos e Cheques ***/
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "GENERI"       AND
                      craptab.cdempres = 0              AND
                      craptab.cdacesso = "EXECUTAABBC"  AND
                      craptab.tpregist = 0              NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craptab   THEN
        ASSIGN tel_execabbc = NO
               aux_execabbc = NO.
   ELSE
        ASSIGN tel_execabbc = IF craptab.dstextab = "SIM" THEN YES ELSE NO
               aux_execabbc = tel_execabbc.

   FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "GENERI"       AND
                      craptab.cdempres = 0              AND
                      craptab.cdacesso = "HORLIMABBC"   AND
                      craptab.tpregist = 0              NO-LOCK NO-ERROR.

   IF AVAILABLE craptab   THEN
      ASSIGN aux_nrdahora = INT(SUBSTR(craptab.dstextab,1,5))
             tel_nrdhhini = INT(SUBSTR(STRING(aux_nrdahora,
                                              "HH:MM:SS"),1,2))
             tel_nrdmmini = INT(SUBSTR(STRING(aux_nrdahora,
                                              "HH:MM:SS"),4,2)).

   DISPLAY tel_execabbc tel_nrdhhini tel_nrdmmini WITH FRAME f_tab086.
   

   IF   glb_cddopcao = "A" THEN
        DO:
            IF   glb_dsdepart <> "TI" THEN
                 DO:
                     glb_cdcritic = 36.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     NEXT.
                 END.

            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               DO WHILE TRUE:

                  UPDATE tel_execabbc
                         tel_nrdhhini
                         tel_nrdmmini
                         WITH FRAME f_tab086.

                  IF   tel_nrdhhini < 4   OR
                       tel_nrdhhini > 9   OR
                      (tel_nrdhhini = 9   AND
                       tel_nrdmmini > 0)  THEN DO:

                        glb_cdcritic = 687.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                  END.

                  IF   tel_nrdmmini > 59  THEN DO:

                        glb_cdcritic = 687.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                  END.  

                  LEAVE.

               END.

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                    NEXT.

               IF   tel_execabbc <> aux_execabbc 
               OR   aux_nrdahora <> ((tel_nrdhhini * 3600) + 
                                     (tel_nrdmmini * 60)) THEN DO:

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                       aux_confirma = "N".
                       glb_cdcritic = 78.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE COLOR NORMAL glb_dscritic 
                               UPDATE aux_confirma.
                       glb_cdcritic = 0.
                       LEAVE.
                    END.

                    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                         aux_confirma <> "S" THEN
                         DO:
                             glb_cdcritic = 79.
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE glb_dscritic.
                             glb_cdcritic = 0.
                             NEXT.
                         END.

                    /* Atualizando EXECUTAABBC */
                    DO aux_contador = 1 TO 10:

                       FIND craptab WHERE 
                            craptab.cdcooper = glb_cdcooper   AND
                            craptab.nmsistem = "CRED"         AND
                            craptab.tptabela = "GENERI"       AND
                            craptab.cdempres = 0              AND
                            craptab.cdacesso = "EXECUTAABBC"  AND
                            craptab.tpregist = 0            
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
                                    CREATE craptab.
                                    ASSIGN craptab.cdcooper = glb_cdcooper
                                           craptab.nmsistem = "CRED"
                                           craptab.tptabela = "GENERI"
                                           craptab.cdempres = 0
                                           craptab.cdacesso = "EXECUTAABBC"
                                           craptab.tpregist = 0
                                           craptab.dstextab = "NAO".

                                    VALIDATE craptab.
                                    LEAVE.
                                 END.    

                       ELSE
                            glb_cdcritic = 0.

                       LEAVE.

                    END.  /*  Fim do DO .. TO  */

                    IF   glb_cdcritic > 0 THEN
                         NEXT.


                    IF  tel_execabbc THEN DO:
                        ASSIGN craptab.dstextab = "SIM".
                        OUTPUT TO VALUE(aux_nmarquiv).
                        PUT UNFORM " ".
                        OUTPUT CLOSE.
                    END.
                    ELSE DO:
                        ASSIGN craptab.dstextab = "NAO".
                        IF  SEARCH(aux_nmarquiv) <> ?  THEN
                            UNIX SILENT VALUE("rm " + aux_nmarquiv + 
                                              " 2>/dev/null").

                    END.
                    /* FIM - Atualizando EXECUTAABBC */



                    /* Atualizando HORLIMABBC */
                    DO aux_contador = 1 TO 10:

                       FIND craptab WHERE 
                            craptab.cdcooper = glb_cdcooper   AND
                            craptab.nmsistem = "CRED"         AND
                            craptab.tptabela = "GENERI"       AND
                            craptab.cdempres = 0              AND
                            craptab.cdacesso = "HORLIMABBC"   AND
                            craptab.tpregist = 0            
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
                                    CREATE craptab.
                                    ASSIGN craptab.cdcooper = glb_cdcooper
                                           craptab.nmsistem = "CRED"
                                           craptab.tptabela = "GENERI"
                                           craptab.cdempres = 0
                                           craptab.cdacesso = "HORLIMABBC"
                                           craptab.tpregist = 0
                                           craptab.dstextab = "14700".

                                    VALIDATE craptab. 
                                    LEAVE.
                                 END.    

                       ELSE
                            glb_cdcritic = 0.

                       LEAVE.

                    END.  /*  Fim do DO .. TO  */

                    IF   glb_cdcritic > 0 THEN
                         NEXT.
                    
                    ASSIGN aux_nrdahora     = (tel_nrdhhini * 3600) + 
                                              (tel_nrdmmini * 60)
                           craptab.dstextab = STRING(aux_nrdahora,"99999").

                    /* FIM - Atualizando HORLIMABBC */

                    RUN p_altera_horalimiteABBC.
                    
               END. /* END do IF   tel_execabbc <> aux_execabbc */



            END. /* Fim da transacao */

            RELEASE craptab.

            CLEAR FRAME f_tab086 NO-PAUSE.

        END.

END.  /*  Fim do DO WHILE TRUE  */

PROCEDURE p_altera_horalimiteABBC:

   DEF VAR aux_menorhor AS INT                          NO-UNDO.

   aux_menorhor = 999999.

   FOR EACH crapcop NO-LOCK:

       FOR EACH craptab WHERE craptab.cdcooper = crapcop.cdcooper AND
                              craptab.nmsistem = "CRED"           AND
                              craptab.tptabela = "GENERI"         AND
                              craptab.cdempres = 0                AND
                              craptab.cdacesso = "HORLIMABBC"     AND
                              craptab.tpregist = 0 
                              NO-LOCK:

           IF  aux_menorhor > 
                  INT(STRING(SUBSTR(craptab.dstextab,1,5),"99999")) THEN
              aux_menorhor = INT(STRING(SUBSTR(craptab.dstextab,1,5),"99999")).
       END.
   END.
   
   UNIX SILENT VALUE("echo " + STRING(aux_menorhor,"HH:MM") +
                     " > /usr/coop/cecred/arquivos/horalimiteABBC.par " + 
                     " 2> /dev/null").
END.

/* .......................................................................... */

