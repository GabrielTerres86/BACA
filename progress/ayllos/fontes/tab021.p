/* .............................................................................

   Programa: Fontes/tab021.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Dezembro/2003                       Ultima Atualizacao: 19/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAB021 - Numeracao de Cheques Form. Continuo.

   Alteracoes: 08/01/2004 - Tratamento para configurar numero do cheque TB
                            (Julio).

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane
               
               19/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)

............................................................................. */

{ includes/var_online.i } 

DEF        VAR tel_nrultchq AS CHAR    FORMAT "x(9)"                 NO-UNDO.
DEF        VAR tel_tpcheque AS LOGICAL FORMAT "CONTINUO/TB"
                                       INITIAL TRUE                  NO-UNDO.

DEF        VAR aux_cdacesso AS CHAR                                  NO-UNDO.
DEF        VAR aux_dsacesso AS CHAR    FORMAT "x(50)"                NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.

FORM SKIP (3)
     "Opcao:"     AT 4
     glb_cddopcao AT 11 NO-LABEL AUTO-RETURN
                  HELP "Entre com a opcao desejada"
                  VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C",
                            "014 - Opcao errada.")

     SKIP(3)
     tel_tpcheque AT 13 LABEL "Tipo de Cheque" AUTO-RETURN
                  HELP 'Informe "C" para Cheque Continuo e "T" para Cheque TB.'
 
     SKIP (2)
     tel_nrultchq AT 13 LABEL "Numero do ultimo cheque impresso" AUTO-RETURN
                  HELP "Entre o numero da ultima folha de cheque impresso."
                  VALIDATE(INT(STRING(tel_nrultchq, "9999999")) > 0, 
                           "026 - Numeracao errada.")

     SKIP(5)
     WITH SIDE-LABELS
     TITLE COLOR MESSAGE " Numeracao de Cheque Continuo / Cheque TB"
           ROW 4 COLUMN 1 OVERLAY WIDTH 80 FRAME f_tab021.

glb_cddopcao = "C".

DO WHILE TRUE:

        RUN fontes/inicia.p.

        DISPLAY glb_cddopcao WITH FRAME f_tab021.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                 PROMPT-FOR glb_cddopcao
                            WITH FRAME f_tab021.
                 LEAVE.
        END.

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
             DO:
                 RUN fontes/novatela.p.
                 IF   CAPS(glb_nmdatela) <> "TAB021"   THEN
                      DO:
                          HIDE FRAME f_tab021.
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

        DISP tel_tpcheque WITH frame f_tab021.
        SET tel_tpcheque WITH frame f_tab021.
        
        IF   tel_tpcheque   THEN
             aux_cdacesso = "NRCHQCONTN".
        ELSE
             aux_cdacesso = "NRCHEQUETB".

        IF   INPUT glb_cddopcao = "A" THEN
             DO:
                 DO TRANSACTION ON ENDKEY UNDO, LEAVE:

                    DO  aux_contador = 1 TO 10:

                        FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                           craptab.nmsistem = "CRED"         AND
                                           craptab.tptabela = "GENERI"       AND
                                           craptab.cdempres = 00             AND
                                           craptab.cdacesso = aux_cdacesso   AND
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
                                                                		
                                		NEXT.
                                  END.
                             ELSE
                                  DO:
                                      glb_cdcritic = 55.
                                      CLEAR FRAME f_tab021.
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

                   ASSIGN tel_nrultchq = TRIM(SUBSTR(craptab.dstextab, 20, 10)).

                   DISPLAY tel_nrultchq WITH FRAME f_tab021.

                   glb_cdcritic = 999.
                   
                   DO WHILE glb_cdcritic > 0:

                      SET tel_nrultchq WITH FRAME f_tab021.
                      
                      IF   tel_tpcheque   THEN
                           glb_nrfolhas = 20.
                      ELSE
                           glb_nrfolhas = 10.
                           
                      glb_nrcalcul = INT(tel_nrultchq).

                      RUN fontes/numtal.p.
                         
                      IF   tel_tpcheque   THEN
                           glb_nrfolhas = 20.
                      ELSE
                           glb_nrfolhas = 10.

                      IF   glb_nrposchq <> glb_nrfolhas THEN
                           DO:
                               glb_cdcritic = 070.
                               RUN fontes/critic.p.
                               BELL.
                               MESSAGE glb_dscritic.
                               SET tel_nrultchq WITH FRAME f_tab021.
                               NEXT.
                           END.

                      glb_nrcalcul = INT(tel_nrultchq).
                      
                      RUN fontes/digfun.p.
                      
                      IF   glb_stsnrcal   THEN  
                           DO:
                               SUBSTR(craptab.dstextab, 20, 10) =
                                                           STRING(tel_nrultchq).
                               glb_cdcritic = 0.
                           END.
                      ELSE
                           DO:                               
                               glb_cdcritic = 8.
                               RUN fontes/critic.p.
                               MESSAGE glb_dscritic.
                               NEXT.
                           END.
                           
                      LEAVE.

                   END.

                 END. /* Fim da transacao */

                 RELEASE craptab.

                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                      NEXT.

                 CLEAR FRAME f_tab021 NO-PAUSE.

             END.
        ELSE
        IF   INPUT glb_cddopcao = "C" THEN
             DO:
                 FIND craptab WHERE
                      craptab.cdcooper = glb_cdcooper    AND
                      craptab.nmsistem = "CRED"          AND
                      craptab.tptabela = "GENERI"        AND
                      craptab.cdempres = 00              AND
                      craptab.cdacesso = aux_cdacesso    AND
                      craptab.tpregist = 000
                      NO-LOCK NO-ERROR NO-WAIT.

                 IF   AVAILABLE craptab   THEN
                      DO:
                          ASSIGN tel_nrultchq = SUBSTR(craptab.dstextab,20,10).
                          DISPLAY tel_nrultchq WITH FRAME f_tab021.
                      END.
                 ELSE
                      DO:
                          glb_cdcritic = 55.
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          CLEAR FRAME f_tab021.
                          NEXT.
                      END.
             END.
END.
/* .......................................................................... */
                                                          
