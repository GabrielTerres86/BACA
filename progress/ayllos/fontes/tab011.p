/* .............................................................................

   Programa: Fontes/tab011.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Marco/96                           Ultima Atualizacao: 19/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAB011.

   Alteracoes: 26/09/2001 - Alterado layout da tela para manutencao de tarifa
                            de extrato de conta emitido no CASH (Junior).
               19/05/2004 - Alterado programa para possibilitar alterar tambem
                            tabela TRFACTREMP(layout modificado)(Mirtes).

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               13/04/2006 - Inclusao de mais dois campos para configuracao 
                            de tarifa de emprestimo (Julio).
                            
               11/04/2007 - Retirar campo Contrato Chq. Especial, passa para a
                            tela TELAX (Ze).
 
               10/12/2008 - Trata Resolucao 3518 - BACEN, cobrar tarifa de
                            extrato a partir do 3o extrato por mes (Ze).
                            
               04/06/2012 - Incluido mais 5 faixas no "Contrato de emprestimos"
                            (Tiago).
                            
               19/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)             
............................................................................. */

{ includes/var_online.i }

DEFINE TEMP-TABLE ttfaixas          NO-UNDO
                  FIELD vlrefere AS DECIMAL
                  FIELD vltarifa AS DECIMAL.

DEF        VAR tel_vl1ctremp AS DECIMAL FORMAT "z,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_tx1ctremp AS DECIMAL FORMAT "z,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vl2ctremp AS DECIMAL FORMAT "z,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_tx2ctremp AS DECIMAL FORMAT "z,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vl3ctremp AS DECIMAL FORMAT "z,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_tx3ctremp AS DECIMAL FORMAT "z,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vl4ctremp AS DECIMAL FORMAT "z,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_tx4ctremp AS DECIMAL FORMAT "z,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vl5ctremp AS DECIMAL FORMAT "z,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_tx5ctremp AS DECIMAL FORMAT "z,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vl6ctremp AS DECIMAL FORMAT "z,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_tx6ctremp AS DECIMAL FORMAT "z,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vl7ctremp AS DECIMAL FORMAT "z,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_tx7ctremp AS DECIMAL FORMAT "z,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vl8ctremp AS DECIMAL FORMAT "z,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_tx8ctremp AS DECIMAL FORMAT "z,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vl9ctremp AS DECIMAL FORMAT "z,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_tx9ctremp AS DECIMAL FORMAT "z,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vl10ctremp AS DECIMAL FORMAT "z,zzz,zz9.99"       NO-UNDO.
DEF        VAR tel_tx10ctremp AS DECIMAL FORMAT "z,zzz,zz9.99"       NO-UNDO.


DEF        VAR tel_vltalona AS DECIMAL FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF        VAR tel_vlextrat AS DECIMAL FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF        VAR tel_dslitera AS CHAR    FORMAT "x(22)"                NO-UNDO
                                       INIT "CONTRATO DE EMPRESTIMO".
DEF        VAR tel_vltarifa AS DECIMAL FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF        VAR tel_qtextper AS DECIMAL FORMAT "           zz9"       NO-UNDO.


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


FORM SKIP (1)
     glb_cddopcao AT 34 LABEL "Opcao" AUTO-RETURN
                  HELP "Entre com a opcao desejada A,C."
                  VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C",
                            "014 - Opcao errada.")
     SKIP(1)
     tel_vltalona AT 19 LABEL "Talonario de cheques"
     tel_vlextrat AT  7 LABEL "Extrato de conta-corrente BALCAO"
     SKIP(1)
     tel_vltarifa AT  9 LABEL "Extrato de conta-corrente CASH"
     tel_qtextper AT 10 LABEL "Quantidade de extratos no mes"
     SKIP(8)
     WITH ROW 4 SIDE-LABELS TITLE glb_tldatela  WIDTH 80 FRAME f_tab011.

FORM SKIP (1)
    tel_dslitera AT 30 NO-LABEL
    SKIP(1)
    tel_vl1ctremp AT 12 LABEL "Ate valor "
    tel_tx1ctremp AT 42 LABEL "Tarifa"
    tel_vl2ctremp AT 12 LABEL "Ate Valor "
    tel_tx2ctremp AT 42 LABEL "Tarifa"
    tel_vl3ctremp AT 12 LABEL "Ate Valor "              
    tel_tx3ctremp AT 42 LABEL "Tarifa"
    tel_vl4ctremp AT 12 LABEL "Ate Valor "
    tel_tx4ctremp AT 42 LABEL "Tarifa"
    tel_vl5ctremp AT 12 LABEL "Ate Valor "              
    tel_tx5ctremp AT 42 LABEL "Tarifa"
    tel_vl6ctremp AT 12 LABEL "Ate valor "
    tel_tx6ctremp AT 42 LABEL "Tarifa"
    tel_vl7ctremp AT 12 LABEL "Ate Valor "
    tel_tx7ctremp AT 42 LABEL "Tarifa"
    tel_vl8ctremp AT 12 LABEL "Ate Valor "              
    tel_tx8ctremp AT 42 LABEL "Tarifa"
    tel_vl9ctremp AT 12 LABEL "Ate Valor "
    tel_tx9ctremp AT 42 LABEL "Tarifa"
    tel_vl10ctremp AT 12 LABEL "Ate Valor "              
    tel_tx10ctremp AT 42 LABEL "Tarifa"
    SKIP(3)
    WITH  SIDE-LABELS OVERLAY ROW 4 TITLE glb_tldatela WIDTH 80 FRAME f_tabemp.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic =  0.

RUN fontes/inicia.p.

DO WHILE TRUE:

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                 UPDATE glb_cddopcao WITH FRAME f_tab011.
                 LEAVE.
        END.

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
             DO:
                 RUN fontes/novatela.p.
                 IF   CAPS(glb_nmdatela) <> "TAB011"   THEN
                      DO:
                          HIDE FRAME f_tab011.
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

        FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND
                           craptab.nmsistem = "CRED"          AND
                           craptab.tptabela = "USUARI"        AND
                           craptab.cdempres = 11              AND
                           craptab.cdacesso = "TRFACTREMP"    AND
                           craptab.tpregist = 001             NO-LOCK NO-ERROR .

        IF   NOT AVAILABLE craptab   THEN
             DO:
                glb_cdcritic = 487.
                CLEAR FRAME f_tab011.
                LEAVE.
             END.
        
        ELSE
             
             ASSIGN  tel_vl1ctremp = DEC(SUBSTR(craptab.dstextab,01,10))   
                     tel_tx1ctremp = DEC(SUBSTR(craptab.dstextab,12,10))
                     tel_vl2ctremp = DEC(SUBSTR(craptab.dstextab,23,10))
                     tel_tx2ctremp = DEC(SUBSTR(craptab.dstextab,34,10))
                     tel_vl3ctremp = DEC(SUBSTR(craptab.dstextab,45,10)) 
                     tel_tx3ctremp = DEC(SUBSTR(craptab.dstextab,56,10))
                     tel_vl4ctremp = DEC(SUBSTR(craptab.dstextab,67,10)) 
                     tel_tx4ctremp = DEC(SUBSTR(craptab.dstextab,78,10))
                     tel_vl5ctremp = DEC(SUBSTR(craptab.dstextab,89,10)) 
                     tel_tx5ctremp = DEC(SUBSTR(craptab.dstextab,100,10))

                     tel_vl6ctremp = DEC(SUBSTR(craptab.dstextab,111,10))   
                     tel_tx6ctremp = DEC(SUBSTR(craptab.dstextab,122,10))
                     tel_vl7ctremp = DEC(SUBSTR(craptab.dstextab,133,10))
                     tel_tx7ctremp = DEC(SUBSTR(craptab.dstextab,144,10))
                     tel_vl8ctremp = DEC(SUBSTR(craptab.dstextab,155,10)) 
                     tel_tx8ctremp = DEC(SUBSTR(craptab.dstextab,166,10))
                     tel_vl9ctremp = DEC(SUBSTR(craptab.dstextab,177,10)) 
                     tel_tx9ctremp = DEC(SUBSTR(craptab.dstextab,188,10))
                     tel_vl10ctremp = DEC(SUBSTR(craptab.dstextab,199,10)) 
                     tel_tx10ctremp = DEC(SUBSTR(craptab.dstextab,210,10)).
    
        FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                           craptab.nmsistem = "CRED"         AND
                           craptab.tptabela = "USUARI"       AND
                           craptab.cdempres = 11             AND
                           craptab.cdacesso = "TRFATALONA"   AND
                           craptab.tpregist = 001            NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE craptab   THEN
             DO:
                glb_cdcritic = 489.
                CLEAR FRAME f_tab011.
                LEAVE.
             END.
        ELSE
             tel_vltalona = DECIMAL(craptab.dstextab).

        FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND 
                           craptab.nmsistem = "CRED"         AND
                           craptab.tptabela = "USUARI"       AND
                           craptab.cdempres = 11             AND
                           craptab.cdacesso = "TRFAEXTRCC"   AND
                           craptab.tpregist = 001            NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE craptab   THEN
             DO:
                glb_cdcritic = 490.
                CLEAR FRAME f_tab011.
                LEAVE.
             END.
        ELSE
             tel_vlextrat = DECIMAL(craptab.dstextab).

        FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                           craptab.nmsistem = "CRED"         AND
                           craptab.tptabela = "USUARI"       AND
                           craptab.cdempres = 11             AND
                           craptab.cdacesso = "TRFAEXTRCC"   AND
                           craptab.tpregist = 002            NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE craptab   THEN
             DO:
                glb_cdcritic = 490.
                CLEAR FRAME f_tab011.
                LEAVE.
             END.
        ELSE
             ASSIGN tel_vltarifa = DECIMAL(SUBSTR(craptab.dstextab,01,12))
                    tel_qtextper = DECIMAL(SUBSTR(craptab.dstextab,14,3)).
        
        IF   glb_cddopcao = "A" THEN
             DO:
                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    IF   glb_cdcritic > 0 THEN
                         DO:
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE glb_dscritic.
                             glb_cdcritic = 0.
                             NEXT-PROMPT tel_vl1ctremp WITH FRAME f_tabemp.
                         END.

                    UPDATE tel_vltalona
                           tel_vlextrat 
                           tel_vltarifa
                           tel_qtextper 
                           WITH FRAME f_tab011

                    EDITING:

                        READKEY.

                        IF   LASTKEY =  KEYCODE(".")   THEN
                             APPLY 44.
                        ELSE
                             APPLY LASTKEY.

                    END.  /*  Fim do EDITING  */
                          
                    HIDE FRAME f_tab011.
                            
                    COLOR DISPLAY INPUT tel_dslitera WITH FRAME f_tabemp.
                    DISPLAY tel_dslitera WITH NO-LABELS FRAME f_tabemp. 

                    UPDATE tel_vl1ctremp
                           tel_tx1ctremp
                           tel_vl2ctremp
                           tel_tx2ctremp
                           tel_vl3ctremp
                           tel_tx3ctremp
                           tel_vl4ctremp
                           tel_tx4ctremp
                           tel_vl5ctremp
                           tel_tx5ctremp
                           tel_vl6ctremp
                           tel_tx6ctremp
                           tel_vl7ctremp
                           tel_tx7ctremp
                           tel_vl8ctremp
                           tel_tx8ctremp
                           tel_vl9ctremp
                           tel_tx9ctremp
                           tel_vl10ctremp
                           tel_tx10ctremp
                        WITH FRAME f_tabemp.

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                       aux_confirma = "N".
                
                       glb_cdcritic = 78.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                       glb_cdcritic = 0.

                       IF aux_confirma = "N" THEN
                          UNDO.

                       LEAVE.
                    END.  /*  Fim do DO WHILE TRUE  */

                    HIDE FRAME f_tabemp.              

                    LEAVE.
                 END.

                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                      NEXT.

                 EMPTY TEMP-TABLE ttfaixas NO-ERROR.
                 
                 CREATE ttfaixas.
                 ASSIGN ttfaixas.vlrefere = tel_vl1ctremp
                        ttfaixas.vltarifa = tel_tx1ctremp.
                        
                 CREATE ttfaixas.
                 ASSIGN ttfaixas.vlrefere = tel_vl2ctremp
                        ttfaixas.vltarifa = tel_tx2ctremp.

                 CREATE ttfaixas.
                 ASSIGN ttfaixas.vlrefere = tel_vl3ctremp
                        ttfaixas.vltarifa = tel_tx3ctremp.

                 CREATE ttfaixas.
                 ASSIGN ttfaixas.vlrefere = tel_vl4ctremp
                        ttfaixas.vltarifa = tel_tx4ctremp.

                 CREATE ttfaixas.
                 ASSIGN ttfaixas.vlrefere = tel_vl5ctremp
                        ttfaixas.vltarifa = tel_tx5ctremp.    
                 
                 CREATE ttfaixas.
                 ASSIGN ttfaixas.vlrefere = tel_vl6ctremp
                        ttfaixas.vltarifa = tel_tx6ctremp.
                        
                 CREATE ttfaixas.
                 ASSIGN ttfaixas.vlrefere = tel_vl7ctremp
                        ttfaixas.vltarifa = tel_tx7ctremp.

                 CREATE ttfaixas.
                 ASSIGN ttfaixas.vlrefere = tel_vl8ctremp
                        ttfaixas.vltarifa = tel_tx8ctremp.

                 CREATE ttfaixas.
                 ASSIGN ttfaixas.vlrefere = tel_vl9ctremp
                        ttfaixas.vltarifa = tel_tx9ctremp.

                 CREATE ttfaixas.
                 ASSIGN ttfaixas.vlrefere = tel_vl10ctremp
                        ttfaixas.vltarifa = tel_tx10ctremp.    


                 DO   TRANSACTION ON ERROR UNDO, LEAVE:

                      DO  aux_contador = 1 TO 10:

                          FIND craptab WHERE
                               craptab.cdcooper = glb_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "USUARI"       AND
                               craptab.cdempres = 11             AND
                               craptab.cdacesso = "TRFACTREMP"   AND
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
                                
                                		
                                		NEXT.
                                    END.
                               ELSE
                                    DO:
                                       glb_cdcritic = 487.
                                       CLEAR FRAME f_tab011.
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

                      ASSIGN craptab.dstextab = "".
                      
                      FOR EACH ttfaixas BY ttfaixas.vlrefere:
                          ASSIGN craptab.dstextab = craptab.dstextab +
                                STRING(ttfaixas.vlrefere,"9999999.99") + "#" +
                                STRING(ttfaixas.vltarifa,"9999999.99") + "#".
                      END.

                      DO  aux_contador = 1 TO 10:

                          FIND craptab WHERE 
                               craptab.cdcooper = glb_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "USUARI"       AND
                               craptab.cdempres = 11             AND
                               craptab.cdacesso = "TRFATALONA"   AND
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
                                
                                		
                                		NEXT.
                                    END.
                               ELSE
                                    DO:
                                       glb_cdcritic = 489.
                                       CLEAR FRAME f_tab011.
                                       LEAVE.
                                    END.
                           ELSE
                               DO:
                                   aux_contador = 0.
                                   LEAVE.
                               END.
                      END.
                    
                      IF  aux_contador <> 0   THEN
                          DO:
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE glb_dscritic.
                             NEXT.
                          END.

                      ASSIGN craptab.dstextab =
                             STRING(tel_vltalona,"999999999.99").

                      DO  aux_contador = 1 TO 10:

                          FIND craptab WHERE
                               craptab.cdcooper = glb_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "USUARI"       AND
                               craptab.cdempres = 11             AND
                               craptab.cdacesso = "TRFAEXTRCC"   AND
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
                                
                                		
                                		NEXT.
                                    END.
                               ELSE
                                    DO:
                                        glb_cdcritic = 490.
                                        CLEAR FRAME f_tab011.
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

                      ASSIGN craptab.dstextab =
                                         STRING(tel_vlextrat,"999999999.99").
                         
                      DO  aux_contador = 1 TO 10:

                          FIND craptab WHERE
                               craptab.cdcooper = glb_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "USUARI"       AND
                               craptab.cdempres = 11             AND
                               craptab.cdacesso = "TRFAEXTRCC"   AND
                               craptab.tpregist = 002
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
                                       glb_cdcritic = 490.
                                       CLEAR FRAME f_tab011.
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

                      ASSIGN craptab.dstextab = STRING(tel_vltarifa,
                                                  "999999999.99") + " " +
                                                STRING(tel_qtextper,
                                                  "999").

                 END. /* FIM DA TRANSACAO */

                 CLEAR FRAME f_tabemp.
                 CLEAR FRAME f_tab011.
             
             END.
        ELSE
        IF  glb_cddopcao = "C" THEN
            DO:
            
              DISPLAY   tel_vltalona
                        tel_vlextrat
                        tel_vltarifa
                        tel_qtextper 
                        WITH FRAME f_tab011.
              
              MESSAGE "Tecle <Enter> para continuar ou <End> para encerrar.".

              WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
              
              MESSAGE "".
              IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                  LEAVE.

              HIDE FRAME f_tab011.

              COLOR DISPLAY INPUT tel_dslitera WITH FRAME f_tabemp.
              DISPLAY tel_dslitera WITH NO-LABELS FRAME f_tabemp. 
              
              DISPLAY   tel_vl1ctremp
                        tel_tx1ctremp 
                        tel_vl2ctremp
                        tel_tx2ctremp
                        tel_vl3ctremp
                        tel_tx3ctremp
                        tel_vl4ctremp
                        tel_tx4ctremp 
                        tel_vl5ctremp
                        tel_tx5ctremp
                        tel_vl6ctremp
                        tel_tx6ctremp 
                        tel_vl7ctremp
                        tel_tx7ctremp
                        tel_vl8ctremp
                        tel_tx8ctremp
                        tel_vl9ctremp
                        tel_tx9ctremp 
                        tel_vl10ctremp
                        tel_tx10ctremp
                        WITH FRAME f_tabemp.
              
              HIDE FRAME f_tabemp.

              CLEAR FRAME f_tabemp.
              CLEAR FRAME f_tab011.

            END.

END.

IF   glb_cdcritic > 0 THEN
     DO:
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         glb_nmdatela = "TAB001".
         PAUSE.
         HIDE FRAME f_tab011.
         glb_cdcritic = 0.
         RETURN.
     END.

/* .......................................................................... */


