/*.............................................................................

   Programa: Fontes/tab048.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Dezembro/2007.                   Ultima atualizacao:  19/09/2014 

   Dados referentes ao programa:

   Frequencia : Diario (on-line)
   Objetivo   : Mostrar a tela tab048 (Valores contratados cartoes Bradesco/BB).

   Alteracoes : 18/12/2007 - Alterados os campos valor Bradesco, para valor    
                             Bradesco credito, e valor BB, para valor BB
                             credito. Incluidos os  campos valor Bradesco
                             debito e valor BB debito (Gabriel).
    
                11/02/2009 - Permissao pros op. 997 e 979, retirada barra de
                             rolagem  (Gabriel).
                             
                25/05/2009 - Alteracao CDOPERAD (Kbase).
                
                19/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
..............................................................................*/

   { includes/var_online.i }

/* valor bradesco credito e valor bb credito */
DEF VAR  tel_valorbra   AS DEC   FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF VAR  tel_valordbb   AS DEC   FORMAT "zzz,zzz,zz9.99"                NO-UNDO.

/* valor bradesco debito e valor bb debito */
DEF VAR  tel_debitbra   AS DEC   FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF VAR  tel_debitabb   AS DEC   FORMAT "zzz,zzz,zz9.99"                NO-UNDO.

DEF VAR aux_cddopcao    AS CHAR                                         NO-UNDO.
DEF VAR aux_contador    AS INT                                          NO-UNDO.

DEF VAR aux_dadosusr    AS CHAR                                         NO-UNDO.
DEF VAR par_loginusr    AS CHAR                                         NO-UNDO.
DEF VAR par_nmusuari    AS CHAR                                         NO-UNDO.
DEF VAR par_dsdevice    AS CHAR                                         NO-UNDO.
DEF VAR par_dtconnec    AS CHAR                                         NO-UNDO.
DEF VAR par_numipusr    AS CHAR                                         NO-UNDO.
DEF VAR h-b1wgen9999    AS HANDLE                                       NO-UNDO.

FORM SKIP (4)
     glb_cddopcao   AT 34 LABEL "Opcao" AUTO-RETURN
                    HELP  "Entre com a opcao desejada (A ou C)"
                    VALIDATE(glb_cddopcao = "A" OR 
                             glb_cddopcao = "C", "014 - Opcao errada.")
     SKIP (2)
     tel_valorbra   AT 17 LABEL "Valor Bradesco credito" AUTO-RETURN
                    HELP "Entre com o valor contratado do cartao Bradesco."
                    VALIDATE (tel_valorbra > 0, "026 - Quantidade errada.")
     SKIP
     tel_debitbra   AT 17 LABEL "Valor Bradesco debito "  AUTO-RETURN
                    HELP "Entre com o valor contratado debito Bradesco."
                    VALIDATE (tel_debitbra > 0, "026 - Quantidade errada.")
     SKIP(1)
     tel_valordbb   AT 23 LABEL "Valor BB credito" AUTO-RETURN
                    HELP "Entre com o valor contratado do cartao BB."
                    VALIDATE (tel_valordbb > 0, "026 - Quantidade errada.")
     SKIP 
     tel_debitabb   AT 23 LABEL "Valor BB debito "  AUTO-RETURN
                    HELP "Entre com o valor contratado debito BB."
                    VALIDATE (tel_debitabb > 0, "026 - Quantidade errada.")
     SKIP (4)
     WITH SIDE-LABELS
     TITLE COLOR MESSAGE "Valores contratados cartoes Bradesco/BB"
            ROW 4 COLUMN 1 OVERLAY WIDTH 80 FRAME f_tab048.

glb_cddopcao = "C".
            
DO WHILE TRUE:
         
   RUN fontes/inicia.p.
         
   DISPLAY glb_cddopcao WITH FRAME f_tab048.
         
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      PROMPT-FOR glb_cddopcao
      WITH FRAME f_tab048.
      LEAVE.
  
   END.
                             
   IF   KEYFUNCTION (LASTKEY) = "END-ERROR"   THEN    /* F4 ou FIM */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "TAB048"    THEN
                 DO:
                     HIDE FRAME f_tab048.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.                     
         
   IF   aux_cddopcao <> INPUT glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = INPUT glb_cddopcao.
        END.
         
   ASSIGN glb_cddopcao = INPUT glb_cddopcao.
   
   IF   INPUT glb_cddopcao = "A"   THEN
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
                  
                         DO aux_contador = 1 TO 10:

                            FIND craptab WHERE 
                                 craptab.cdcooper = glb_cdcooper AND
                                 craptab.nmsistem = "CRED"       AND
                                 craptab.tptabela = "USUARI"     AND
                                 craptab.cdempres = 11           AND
                                 craptab.cdacesso = "VLCONTRCRD" AND
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
                                               CLEAR FRAME f_tab048.
                                               LEAVE.
                                           END.
                                 ELSE
                                      DO:
                                          aux_contador = 0.
                                          LEAVE.
                                      END.
               
                        END.  /*  Fim contador */                          
             
                        IF   aux_contador <> 0   THEN
                             DO:
                                 RUN fontes/critic.p.
                                 BELL.
                                 MESSAGE glb_dscritic.
                                 NEXT.
                             END.
                              
                        ASSIGN  tel_valorbra =
                                DEC(SUBSTR(craptab.dstextab,1,12))
                             
                                tel_valordbb =
                                DEC(SUBSTR(craptab.dstextab,14,12))
                     
                                tel_debitbra =
                                DEC(SUBSTR(craptab.dstextab,27,12))
                                
                                tel_debitabb =
                                DEC(SUBSTR(craptab.dstextab,40,12)).
                        
                        DISPLAY tel_valorbra  
                                tel_valordbb 
                                tel_debitbra
                                tel_debitabb WITH FRAME f_tab048.  

                        DO WHILE TRUE:
                     
                           UPDATE tel_valorbra 
                                  tel_debitbra
                                  tel_valordbb
                                  tel_debitabb  WITH FRAME f_tab048.
                      
                           craptab.dstextab =
                           STRING(tel_valorbra,"999999999.99") +
                           " " +  
                           STRING(tel_valordbb,"999999999.99") +
                           " " +
                           STRING(tel_debitbra,"999999999.99") +
                           " " +
                           STRING(tel_debitabb,"999999999.99").

                           LEAVE.
                        
                        END.      /* Fim do DO WHILE TRUE  */ 

            END.   /* Fim do DO TRANSACTION */

            IF   KEYFUNCTION (LASTKEY) = "END-ERROR" THEN 
                 NEXT.
                  
            CLEAR FRAME f_tab048 NO-PAUSE.
              
        END.    /*   Fim opcao "A"   */
        
   IF   INPUT glb_cddopcao = "C"   THEN
        DO:
            FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND
                               craptab.nmsistem = "CRED"          AND
                               craptab.tptabela = "USUARI"        AND
                               craptab.cdempres = 11              AND
                               craptab.cdacesso = "VLCONTRCRD"    AND
                               craptab.tpregist = 0
                               NO-LOCK NO-ERROR NO-WAIT.
                  
                 IF   AVAILABLE craptab   THEN
                      DO:
                          ASSIGN  tel_valorbra =
                                  DEC(SUBSTR(craptab.dstextab,1,12))
                                  
                                  tel_valordbb =
                                  DEC(SUBSTR(craptab.dstextab,14,12))
                          
                                  tel_debitbra =
                                  DEC(SUBSTR(craptab.dstextab,27,12))

                                  tel_debitabb =
                                  DEC(SUBSTR(craptab.dstextab,40,12)).
                          
                          DISPLAY tel_valorbra  
                                  tel_valordbb
                                  tel_debitbra
                                  tel_debitabb WITH FRAME f_tab048.  
                      END.
                 ELSE
                      DO:
                          glb_cdcritic = 55.
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          CLEAR FRAME f_tab048.
                          NEXT.        
                      END.
           
        END.       /*  Fim opcao "C"  */

END.            /* Fim do DO WHILE TRUE   */                 

/*............................................................................*/
