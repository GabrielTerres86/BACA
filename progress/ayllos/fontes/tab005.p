/* .............................................................................

   Programa: Fontes/tab005.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91                             Alteracoes: 03/06/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAB005.

   Alteracoes : 03/05/2004 - Incluido  Dias Credito Liquidacao Risco(Mirtes)
   
                05/07/2005 - Alimentado campo cdcooper da tabela craptab(Diego).

                02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
                
                19/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                             b1wgen9999.p procedure acha-lock, que identifica qual 
                             é o usuario que esta prendendo a transaçao. (Vanessa)
                             
                03/06/2015 - Remover o campo 
                             "Qtd. Dias para Credito Liquidacao Risco". (James)

............................................................................. */

{ includes/var_online.i } 

DEF        VAR tel_qtddsdev AS INT     FORMAT "zz9"                  NO-UNDO.

DEF        VAR aux_dsacesso AS CHAR    FORMAT "x(50)"                NO-UNDO.
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


FORM SKIP (3)
     "Opcao:"     AT 4
     glb_cddopcao AT 11 NO-LABEL AUTO-RETURN
                  HELP "Entre com a opcao desejada"
                  VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                            glb_cddopcao = "E" OR glb_cddopcao = "I",
                            "014 - Opcao errada.")

     SKIP (4)
     tel_qtddsdev AT 13 LABEL "Qtd. Dias para Credito Liquidacao" AUTO-RETURN
                  HELP "Quantidade de dias para credito em liquidacao."
                  VALIDATE(tel_qtddsdev > 0,"026 - Quantidade errada.")
     SKIP(6)
     WITH SIDE-LABELS
     TITLE COLOR MESSAGE " Qtd. Dias para Credito em Liquidacao "
           ROW 4 COLUMN 1 OVERLAY WIDTH 80 FRAME f_tab005.

glb_cddopcao = "C".

DO WHILE TRUE:

        RUN fontes/inicia.p.

        DISPLAY glb_cddopcao WITH FRAME f_tab005.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                 PROMPT-FOR glb_cddopcao
                            WITH FRAME f_tab005.
                 LEAVE.
        END.

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
             DO:
                 RUN fontes/novatela.p.
                 IF   CAPS(glb_nmdatela) <> "TAB005"   THEN
                      DO:
                          HIDE FRAME f_tab005.
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
                                           craptab.cdempres = 00             AND
                                           craptab.cdacesso = "DIASCREDLQ"   AND
                                           craptab.tpregist = 000
                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                        IF   NOT AVAILABLE craptab   THEN
                             IF LOCKED craptab   THEN
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
                                      CLEAR FRAME f_tab005.
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

                   ASSIGN tel_qtddsdev = INT(SUBSTR(craptab.dstextab,1,3)).
                             
                   DISPLAY tel_qtddsdev 
                           WITH FRAME f_tab005.

                   DO WHILE TRUE:

                      SET tel_qtddsdev 
                          WITH FRAME f_tab005.

                      ASSIGN SUBSTR(craptab.dstextab,1,3) =
                                    STRING(tel_qtddsdev,"999").
                      LEAVE.

                   END.


                 END. /* Fim da transacao */

                 RELEASE craptab.

                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                      NEXT.

                 CLEAR FRAME f_tab005 NO-PAUSE.

             END.
        ELSE
        IF   INPUT glb_cddopcao = "C" THEN
             DO:
                 FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND 
                                    craptab.nmsistem = "CRED"         AND
                                    craptab.tptabela = "USUARI"       AND
                                    craptab.cdempres = 00             AND
                                    craptab.cdacesso = "DIASCREDLQ"   AND
                                    craptab.tpregist = 000
                                    NO-LOCK NO-ERROR NO-WAIT.

                 IF   AVAILABLE craptab   THEN
                      DO:
                          ASSIGN tel_qtddsdev = 
                                 INT(SUBSTR(craptab.dstextab,1,3)).
                           
                          DISPLAY tel_qtddsdev 
                                  WITH FRAME f_tab005.
                      END.
                 ELSE
                      DO:
                          glb_cdcritic = 55.
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          CLEAR FRAME f_tab005.
                          NEXT.
                      END.
             END.
        ELSE
        IF   INPUT glb_cddopcao = "E"   THEN
             DO:
                 DO TRANSACTION ON ENDKEY UNDO, LEAVE:

                    DO  aux_contador = 1 TO 10:
                        FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                                           craptab.nmsistem = "CRED"        AND
                                           craptab.tptabela = "USUARI"      AND
                                           craptab.cdempres = 00            AND
                                           craptab.cdacesso = "DIASCREDLQ"  AND
                                           craptab.tpregist = 000
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
                                      CLEAR FRAME f_tab005.
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
                    ASSIGN tel_qtddsdev = 
                           INT(SUBSTR(craptab.dstextab,1,3)).

                    DISPLAY tel_qtddsdev 
                            WITH FRAME f_tab005.

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

                    DELETE craptab.
                    CLEAR FRAME f_tab005 NO-PAUSE.

                 END. /* Fim da transacao */

                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*  F4 OU FIM  */
                      NEXT.
             END.
        ELSE
             IF   INPUT glb_cddopcao = "I"   THEN
                  DO:
                      FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND 
                                         craptab.nmsistem = "CRED"         AND
                                         craptab.tptabela = "USUARI"       AND
                                         craptab.cdempres = 00             AND
                                         craptab.cdacesso = "DIASCREDLQ"   AND
                                         craptab.tpregist = 000
                                         NO-LOCK NO-ERROR NO-WAIT.

                      IF   AVAILABLE craptab   THEN
                           DO:
                               glb_cdcritic = 56.
                               RUN fontes/critic.p.
                               BELL.
                               MESSAGE glb_dscritic.
                               CLEAR FRAME f_tab005.
                               ASSIGN tel_qtddsdev =
                                      INTEGER(SUBSTRING(craptab.dstextab,1,3)).
                               DISPLAY tel_qtddsdev WITH FRAME f_tab005.
                               NEXT.
                           END.

                      DO TRANSACTION ON ENDKEY UNDO, LEAVE:

                         CREATE craptab.

                         ASSIGN craptab.nmsistem = "CRED"
                                craptab.tptabela = "USUARI"
                                craptab.cdempres = 00
                                craptab.cdacesso = "DIASCREDLQ"
                                craptab.tpregist = 000
                                craptab.cdcooper = glb_cdcooper.

                         DO WHILE TRUE:

                            SET tel_qtddsdev  
                                WITH FRAME f_tab005.
                         
                            ASSIGN SUBSTR(craptab.dstextab,1,3) =
                                          STRING(tel_qtddsdev,"999").
                         
                            LEAVE.
                         END.

                      END. /* Fim da transacao */

                      RELEASE craptab.

                      IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4  FIM */
                          NEXT.

                      CLEAR FRAME f_tab005 NO-PAUSE.
                  END.
END.
/* .......................................................................... */
