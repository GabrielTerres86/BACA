/* .............................................................................

   Programa: Fontes/tab054.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : GATI - Eder
   Data    : Dezembro/2009                        Ultima alteracao: 07/12/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Tab054 -  Valores VLB e Pre-Truncado
   
   Alteracao : 13/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)
                            
               19/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                           
               25/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).             
               
               07/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
                            
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_vlvlbtit AS DECIMAL                               NO-UNDO.
DEF        VAR tel_vlvlbchq AS DECIMAL                               NO-UNDO.
DEF        VAR tel_vlprtruc AS DECIMAL                               NO-UNDO.

DEF        VAR aux_vlvlbtit AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlvlbchq AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlprtruc AS DECIMAL                               NO-UNDO.

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
     glb_cddopcao COLON 35 LABEL "Opcao" AUTO-RETURN FORMAT "!"
                           HELP "Entre com a opcao desejada (A,C)."
                           VALIDATE(CAN-DO("A,C",glb_cddopcao),
                                    "014 - Opcao errada.")
     SKIP(3)
     tel_vlvlbtit COLON 35 LABEL "VLB Para Titulos/Cobranca" 
         FORMAT "zzz,zzz,zz9.99"
         HELP "Entre com o valor VLB pra titulos."
     SKIP(1)                                         
     tel_vlvlbchq COLON 35 LABEL "VLB Para Cheques"          
         FORMAT "zzz,zzz,zz9.99"
         HELP "Entre com o valor VLB para Cheques"
     SKIP(1)
     tel_vlprtruc COLON 35 LABEL "Valor para Pre-Truncados"
         FORMAT "zzz,zzz,zz9.99"
         HELP "Entre com o valor para Pre-Truncados"
     SKIP(5)
     WITH ROW 4 OVERLAY SIDE-LABELS WIDTH 80 TITLE glb_tldatela FRAME f_tab054.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       glb_cdprogra = "TAB054".

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
               CLEAR FRAME f_tab054 NO-PAUSE.  
               glb_cdcritic = 0.
           END.

      UPDATE glb_cddopcao  WITH FRAME f_tab054.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF   CAPS(glb_nmdatela) <> "tab054"   THEN
                 DO:
                     HIDE FRAME f_tab054.
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
                      craptab.cdacesso = "VALORESVLB"   AND
                      craptab.tpregist = 0              NO-LOCK NO-ERROR.
                   
   IF   NOT AVAILABLE craptab   THEN                   
        ASSIGN tel_vlvlbtit = 0
               aux_vlvlbtit = 0
               tel_vlvlbchq = 0
               aux_vlvlbchq = 0
               tel_vlprtruc = 0
               aux_vlprtruc = 0.
   ELSE
        ASSIGN tel_vlvlbtit = DECIMAL(ENTRY(1,craptab.dstextab,";"))
               aux_vlvlbtit = tel_vlvlbtit
               tel_vlvlbchq = DECIMAL(ENTRY(2,craptab.dstextab,";"))
               aux_vlvlbchq = tel_vlvlbchq
               tel_vlprtruc = DECIMAL(ENTRY(3,craptab.dstextab,";"))
               aux_vlprtruc = tel_vlprtruc.
               
   DISPLAY tel_vlvlbtit tel_vlvlbchq tel_vlprtruc WITH FRAME f_tab054.
      
   IF   glb_cddopcao = "A" THEN
        DO:
            IF  glb_cddepart <> 20 AND   /* TI                   */                
                glb_cddepart <>  8 AND   /* COORD.ADM/FINANCEIRO */
                glb_cddepart <>  9 AND   /* COORD.PRODUTOS       */
                glb_cddepart <>  4 THEN  /* COMPE                */
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
               
                  UPDATE tel_vlvlbtit tel_vlvlbchq tel_vlprtruc 
                         WITH FRAME f_tab054.
                  
                  LEAVE.
                  
               END.
                  
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                    NEXT.

               IF   tel_vlvlbchq <> aux_vlvlbchq   OR
                    tel_vlvlbtit <> aux_vlvlbtit   OR
                    tel_vlprtruc <> aux_vlprtruc   THEN
                    DO:
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
                        
                        DO aux_contador = 1 TO 10:
                        
                           FIND craptab WHERE 
                                craptab.cdcooper = glb_cdcooper   AND
                                craptab.nmsistem = "CRED"         AND
                                craptab.tptabela = "GENERI"       AND
                                craptab.cdempres = 0              AND
                                craptab.cdacesso = "VALORESVLB"   AND
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
                                        CREATE craptab.
                                        ASSIGN craptab.cdcooper = glb_cdcooper
                                               craptab.nmsistem = "CRED"
                                               craptab.tptabela = "GENERI"
                                               craptab.cdempres = 0
                                               craptab.cdacesso = "VALORESVLB"
                                               craptab.tpregist = 0
                                               craptab.dstextab = "0;0;0".
                                        VALIDATE craptab.
                                        LEAVE.
                                     END.    
                            
                           ELSE
                                glb_cdcritic = 0.

                           LEAVE.

                        END.  /*  Fim do DO .. TO  */

                        IF   glb_cdcritic > 0 THEN
                             NEXT.

                        ASSIGN craptab.dstextab =
                                      TRIM(STRING(tel_vlvlbtit,"zzz,zz9.99")) +
                                      ";" +
                                      TRIM(STRING(tel_vlvlbchq,"zzz,zz9.99")) +
                                      ";" +
                                      TRIM(STRING(tel_vlprtruc,"zzz,zz9.99")).
                    END.
                    
            END. /* Fim da transacao */

            RELEASE craptab.

            CLEAR FRAME f_tab054 NO-PAUSE.

        END.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

