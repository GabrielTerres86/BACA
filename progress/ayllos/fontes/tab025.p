/* .............................................................................

   Programa: Fontes/tab025.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Fevereiro/2004                        Ultima alteracao: 25/03/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Tab025 -  Limites para microfilmagem
   
   Alteracao : 08/06/2004 - Corrigido acesso a craptab.dstextab (Evandro).

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               02/05/2008 - critica para permitir somente os operadores: 1, 799
                            996, 997 na opcao "A" (Guilherme).

               23/01/2009 - Retirar permissao do operador 799 e liberar 
                            o 979 (Gabriel).

               25/05/2009 - Alteracao CDOPERAD (Kbase).
               
               02/12/2009 - Correcao de formato na gravacao do valor de
                            tel_vllimepr no campo craptab.dstextab - Formato
                            de tela estava diferente da gravacao (GATI - Eder)
                            
               18/03/2013 - Alterado format na hora de gravar o campo 
                            vllimepr na craptab (David Kruger).
                            
               19/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)

               25/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).             
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_vllimepr AS DECIMAL                               NO-UNDO.
DEF        VAR tel_vllimctr AS DECIMAL                               NO-UNDO.

DEF        VAR aux_vllimepr AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vllimctr AS DECIMAL                               NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!"                    NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.

FORM SKIP(2)
     glb_cddopcao AT 29 LABEL "Opcao" AUTO-RETURN FORMAT "!"
                        HELP "Entre com a opcao desejada (A,C)."
                        VALIDATE(CAN-DO("A,C",glb_cddopcao),
                                 "014 - Opcao errada.")
     SKIP(3)                                      
     tel_vllimepr AT 17 LABEL "Para Emprestimos"            FORMAT ">,>>9.99"
         HELP "Entre com o valor minimo para microfilmar os emprestimos."
     SKIP(1)                                         
     tel_vllimctr AT 5 LABEL "Para Limite Credito/Desconto" FORMAT ">>>,>>9.99"
         HELP "Entre com o valor minimo para microfilmagem."
     SKIP(6)
     WITH ROW 4 OVERLAY SIDE-LABELS WIDTH 80 TITLE glb_tldatela FRAME f_tab025.

glb_cddopcao = "C". 
glb_cdcritic = 0.

VIEW FRAME f_moldura.
PAUSE(0).

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_tab025 NO-PAUSE.  
               glb_cdcritic = 0.
           END.

      UPDATE glb_cddopcao  WITH FRAME f_tab025.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF   CAPS(glb_nmdatela) <> "tab025"   THEN
                 DO:
                     HIDE FRAME f_tab025.
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
        
   /*** Tabela com o limite dos contratos de limite de credito e
        desconto de cheques ***/

   FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "GENERI"       AND
                      craptab.cdempres = 0              AND
                      craptab.cdacesso = "VLMICFLIMI"   AND
                      craptab.tpregist = 0              NO-LOCK NO-ERROR.
                   
   IF   NOT AVAILABLE craptab   THEN                   
        ASSIGN tel_vllimctr = 0
               aux_vllimctr = 0.
   ELSE
        ASSIGN tel_vllimctr = DECIMAL(craptab.dstextab)
               aux_vllimctr = tel_vllimctr.
               
   /*** Tabela com o limite dos contratos de emprestimos ***/

   FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "GENERI"       AND
                      craptab.cdempres = 0              AND
                      craptab.cdacesso = "VLMICFEMPR"   AND
                      craptab.tpregist = 0              NO-LOCK NO-ERROR.
                   
   IF   NOT AVAILABLE craptab   THEN                   
        ASSIGN tel_vllimepr = 0
               aux_vllimepr = 0.
   ELSE
        ASSIGN tel_vllimepr = DECIMAL(SUBSTRING(craptab.dstextab,1,7))
               aux_vllimepr = tel_vllimepr.
             
   DISPLAY tel_vllimepr tel_vllimctr WITH FRAME f_tab025.
      
   IF   glb_cddopcao = "A" THEN
        DO:
            IF   glb_dsdepart <> "TI"                   AND
                 glb_dsdepart <> "COORD.ADM/FINANCEIRO" AND
                 glb_dsdepart <> "COORD.PRODUTOS"       THEN
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
               
                  UPDATE tel_vllimepr tel_vllimctr  WITH FRAME f_tab025.
                  
                  LEAVE.
                  
               END.
                  
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                    NEXT.

               IF   tel_vllimctr <> aux_vllimctr   THEN
                    DO:
                        DO aux_contador = 1 TO 10:
                        
                           FIND craptab WHERE 
                                craptab.cdcooper = glb_cdcooper   AND
                                craptab.nmsistem = "CRED"         AND
                                craptab.tptabela = "GENERI"       AND
                                craptab.cdempres = 0              AND
                                craptab.cdacesso = "VLMICFLIMI"   AND
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
                                                                	
                                		NEXT.
                                    END.
                               ELSE
                                    DO:
                                        glb_cdcritic = 55.
                                        LEAVE.
                                    END.    
                            
                          ELSE
                               glb_cdcritic = 0.

                          LEAVE.

                        END.  /*  Fim do DO .. TO  */

                        IF   glb_cdcritic > 0 THEN
                             NEXT.

                        ASSIGN craptab.dstextab = 
                                      TRIM(STRING(tel_vllimctr,"zzz,zz9.99")).
                    
                    END.
                    
               IF   tel_vllimepr <> aux_vllimepr   THEN
                    DO:
                        DO aux_contador = 1 TO 10:
                        
                          FIND craptab WHERE 
                               craptab.cdcooper = glb_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "GENERI"       AND
                               craptab.cdempres = 0              AND
                               craptab.cdacesso = "VLMICFEMPR"   AND
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
                                
                                		NEXT.
                                    END.
                               ELSE
                                    DO:
                                        glb_cdcritic = 55.
                                        LEAVE.
                                    END.    
                            
                          ELSE
                               glb_cdcritic = 0.

                          LEAVE.

                        END.  /*  Fim do DO .. TO  */

                        IF   glb_cdcritic > 0 THEN
                             NEXT.
                                                            
                        ASSIGN craptab.dstextab =
                                       STRING(tel_vllimepr,"9999.99") +
                                       SUBSTRING(craptab.dstextab,8,41). 
                        
                    END.
                    
            END. /* Fim da transacao */

            RELEASE craptab.

            CLEAR FRAME f_tab025 NO-PAUSE.

        END.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

