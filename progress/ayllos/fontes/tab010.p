/* .............................................................................

   Programa: Fontes/tab010.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Marco/96                            Ultima atualizacao: 19/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAB010.

   Alteracoes: 01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
   
              19/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)

............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_qtddsdev AS INT     FORMAT "zz9"                  NO-UNDO.

DEF        VAR aux_dsacesso AS CHAR    FORMAT "x(50)"                NO-UNDO.
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

FORM SKIP (4)
     "Opcao:"     AT 6
     glb_cddopcao AT 13 NO-LABEL AUTO-RETURN
                  HELP "Entre com a opcao desejada A,C."
                  VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C",
                            "014 - Opcao errada.")

     SKIP (3)
     tel_qtddsdev AT 15 LABEL "Periodo minimo para aviso de resgate"
                  VALIDATE(tel_qtddsdev > 0,"026 - Quantidade errada.")
     "dias."      AT 57
     SKIP(7)
     WITH  SIDE-LABELS ROW 4 TITLE glb_tldatela  WIDTH 80 FRAME f_tab010.

glb_cddopcao = "C".

DO WHILE TRUE:

        RUN fontes/inicia.p.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                 UPDATE glb_cddopcao WITH FRAME f_tab010.
                 LEAVE.
        END.

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
             DO:
                 RUN fontes/novatela.p.
                 IF   CAPS(glb_nmdatela) <> "TAB010"   THEN
                      DO:
                          HIDE FRAME f_tab010.
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
                                           craptab.cdacesso = "DIARESGATE"   AND
                                           craptab.tpregist = 001
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
                                                                	
                                		NEXT.

                                  END.
                             ELSE
                                  DO:
                                      glb_cdcritic = 55.
                                      CLEAR FRAME f_tab010.
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
                             INTEGER(SUBSTRING(craptab.dstextab,1,3)).
                   DISPLAY tel_qtddsdev WITH FRAME f_tab010.

                   DO WHILE TRUE:

                      UPDATE tel_qtddsdev WITH FRAME f_tab010.
                      craptab.dstextab = STRING(tel_qtddsdev,"999").
                      LEAVE.

                   END.

                 END. /* Fim da transacao */

                 RELEASE craptab.

                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                      NEXT.

             END.
        ELSE
        IF   INPUT glb_cddopcao = "C" THEN
             DO:

                 FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                    craptab.nmsistem = "CRED"         AND
                                    craptab.tptabela = "USUARI"       AND
                                    craptab.cdempres = 11             AND
                                    craptab.cdacesso = "DIARESGATE"   AND
                                    craptab.tpregist = 001
                                    NO-LOCK NO-ERROR NO-WAIT.

                 IF   AVAILABLE craptab   THEN
                      DO:
                          ASSIGN tel_qtddsdev =
                                    INTEGER(SUBSTRING(craptab.dstextab,1,3)).
                          DISPLAY tel_qtddsdev WITH FRAME f_tab010.
                      END.
                 ELSE
                      DO:
                          glb_cdcritic = 55.
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          CLEAR FRAME f_tab010.
                          NEXT.
                      END.
             END.
END.
/* .......................................................................... */

