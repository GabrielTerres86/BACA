/* ............................................................................

   Programa: Fontes/cadgdc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Vitor
   Data    : Fevereiro/2011                   Ultima Atualizacao: 16/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela CADGDC (Cadastros p/ o GDC)
                                                 
   Alteracoes: 04/03/2011 - Alterada a busca do codigo em caso de inclusao 
                            devido a criacao do codigo fixo '99999' para grupos 
                            ou produtos indefinidos (Henrique).
                            
               10/03/2011 - Incluida as opcoes de consulta, inclusao e 
                            alteracao de Areas de Negocio (Henrique)
                          - Criado vinculo entre o produto e a area de negocio
                            quando um produto e´ criado ou alterado (Henrique).
                            
              13/11/2012 - Incluido format nos campos Áreas de Negócio, Produtos
                           e Grupos (Daniel).  
                           
              29/11/2013 - Inclusao de VALIDATE crapprd, crapagr e crapadn
                           (Carlos)
                           
              16/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
   
.............................................................................*/

{ includes/var_online.i }

DEF   VAR aux_cddopcao     AS CHAR                                   NO-UNDO.
DEF   VAR tel_cdprodut     AS INTE  FORMAT "zzzz9"                   NO-UNDO.
DEF   VAR tel_dsprodut     AS CHAR  FORMAT "x(40)"                   NO-UNDO.
DEF   VAR tel_cdgrupos     AS INTE  FORMAT "zzzz9"                   NO-UNDO.
DEF   VAR tel_dsgrupos     AS CHAR  FORMAT "x(40)"                   NO-UNDO.
DEF   VAR tel_cdarnego     AS INTE  FORMAT "zz9"                     NO-UNDO.
DEF   VAR tel_dsarnego     AS CHAR  FORMAT "x(40)"                   NO-UNDO.


DEF VAR aux_areasneg AS CHAR  FORMAT "x(16) "INIT "Areas de Negocio" NO-UNDO.
DEF   VAR aux_produtos     AS CHAR  INIT "Produtos"                  NO-UNDO.
DEF   VAR aux_grupos       AS CHAR  INIT "Grupos"                    NO-UNDO.

DEF   VAR aux_dsprdant     AS CHAR  FORMAT "x(50)"                   NO-UNDO.
DEF   VAR aux_dsgrpant     AS CHAR  FORMAT "x(50)"                   NO-UNDO.
DEF   VAR aux_dsarnant     AS CHAR  FORMAT "x(50)"                   NO-UNDO.
DEF   VAR aux_confirma     AS CHAR  FORMAT "!(1)"                    NO-UNDO.
DEF   VAR aux_contador     AS INT   FORMAT "z9"                      NO-UNDO.

DEF VAR aux_dadosusr         AS CHAR                            NO-UNDO.
DEF VAR par_loginusr         AS CHAR                            NO-UNDO.
DEF VAR par_nmusuari         AS CHAR                            NO-UNDO.
DEF VAR par_dsdevice         AS CHAR                            NO-UNDO.
DEF VAR par_dtconnec         AS CHAR                            NO-UNDO.
DEF VAR par_numipusr         AS CHAR                            NO-UNDO.
DEF VAR h-b1wgen9999         AS HANDLE                          NO-UNDO.

DEF    QUERY q-produtos   FOR crapprd.
DEF    BROWSE b-produtos  QUERY q-produtos
       DISPLAY crapprd.cdprodut LABEL "Cod"
               crapprd.dsprodut LABEL "Descricao"
       WITH 5 DOWN WIDTH 30 COLUMN 35 NO-LABELS TITLE "Produtos" OVERLAY.

DEF    QUERY q-grupos   FOR crapagr.
DEF    BROWSE b-grupos  QUERY q-grupos
       DISPLAY crapagr.cdagrupa LABEL "Cod"
               crapagr.dsagrupa LABEL "Descricao"
       WITH 5 DOWN WIDTH 30 COLUMN 35 NO-LABELS TITLE "Grupos" OVERLAY.

DEF    QUERY q-areasneg   FOR crapadn.
DEF    BROWSE b-areasneg  QUERY q-areasneg
       DISPLAY crapadn.cdarnego LABEL "Cod"
               crapadn.dsarnego LABEL "Descricao"
       WITH 5 DOWN WIDTH 30 COLUMN 35 NO-LABELS TITLE "Areas de Negocio" OVERLAY.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE "  Cadastros para o GDC  " 
     FRAME f_moldura.

FORM SKIP (1) 
     "Opcao:"     AT 4
     glb_cddopcao AT 11 NO-LABEL AUTO-RETURN
                  HELP "Entre com a opcao desejada (C)onsulta,(A)lteracao,(I)nclusao."
                  VALIDATE (CAN-DO("C,A,I",glb_cddopcao), "014 - Opcao errada.") 
     aux_areasneg AT 20 NO-LABEL AUTO-RETURN
                  HELP "Informe a opcao desejada (Areas de Negocio/Produtos/Grupos)"
     aux_produtos AT 45 NO-LABEL
                  HELP "Informe a opcao desejada (Areas de Negocio/Produtos/Grupos)"
     aux_grupos   AT 65 NO-LABEL
                  HELP "Informe a opcao desejada (Areas de Negocio/Produtos/Grupos)"
     WITH WIDTH 75 ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_opcao.

FORM SKIP(3)
    tel_cdprodut AT 12 LABEL "Codigo do Produto"
    HELP "Informe o codigo do produto ou F7 para listar."
    SKIP(1)
    tel_dsprodut AT 9 LABEL "Descricao do Produto"
    HELP "Entre com a descricao desejada ou F4 para sair."
    SKIP(1)
    tel_dsarnego AT 1 LABEL "Descricao da Area de Negocio"
    HELP "Aperte F7 para listar."
    WITH WIDTH 70 ROW 9 COLUMN 3 NO-BOX NO-LABELS SIDE-LABELS OVERLAY 
    FRAME f_produtos.

FORM SKIP(3)
    tel_cdgrupos AT 8 LABEL "Codigo do Grupo"
    HELP "Informe o codigo do grupo ou F7 para listar."
    SKIP(1)
    tel_dsgrupos AT 5 LABEL "Descricao do Grupo"
    HELP "Entre com a descricao desejada ou F4 para sair."
    WITH WIDTH 70 ROW 9 COLUMN 3 NO-BOX NO-LABELS SIDE-LABELS OVERLAY 
    FRAME f_grupos.

FORM SKIP(3)
    tel_cdarnego AT 4 LABEL "Codigo da Area de Negocio"
    HELP "Informe o codigo da area de negocio ou F7 para listar."
    SKIP(1)
    tel_dsarnego AT 1 LABEL "Descricao da Area de Negocio"
    HELP "Entre com a descricao desejada ou F4 para sair."
    WITH WIDTH 70 ROW 9 COLUMN 3 NO-BOX NO-LABELS SIDE-LABELS OVERLAY 
    FRAME f_areasneg.

FORM b-produtos  
     HELP "Use as SETAS para navegar <F4> para sair."
     WITH ROW 10 NO-LABELS NO-BOX CENTERED OVERLAY 
     FRAME f_browse_prd.

FORM b-grupos  
     HELP "Use as SETAS para navegar <F4> para sair."
     WITH ROW 10 NO-LABELS NO-BOX CENTERED OVERLAY 
     FRAME f_browse_grp.

FORM b-areasneg  
     HELP "Use as SETAS para navegar <F4> para sair."
     WITH ROW 10 NO-LABELS NO-BOX CENTERED OVERLAY 
     FRAME f_browse_arn.

ON  RETURN OF b-produtos 
    DO:
        FIND crapadn WHERE crapadn.cdarnego = crapprd.cdarnego
                            NO-LOCK NO-ERROR.
                                       
        IF NOT AVAIL crapadn THEN
           DO:
               MESSAGE "O produto possui uma area de negocio invalida".
               NEXT.
           END.
        
        ASSIGN tel_cdprodut = crapprd.cdprodut
               tel_dsprodut = crapprd.dsprodut
               tel_dsarnego = crapadn.dsarnego.

        HIDE BROWSE b-produtos.
        HIDE FRAME f_browse_prd.
               
        DISPLAY tel_cdprodut tel_dsprodut tel_dsarnego WITH FRAME f_produtos.
        APPLY "GO".

    END. 

ON  RETURN OF b-grupos 
    DO:
        ASSIGN tel_cdgrupos = crapagr.cdagrupa
               tel_dsgrupos = crapagr.dsagrupa.

        HIDE BROWSE b-grupos.
        HIDE FRAME f_browse_grp.
               
        DISPLAY tel_cdgrupos tel_dsgrupos WITH FRAME f_grupos.
        APPLY "GO".

    END.

ON  RETURN OF b-areasneg 
    DO:
        ASSIGN tel_cdarnego = crapadn.cdarnego
               tel_dsarnego = crapadn.dsarnego.

        HIDE BROWSE b-areasneg.
        HIDE FRAME f_browse_arn.
               
        DISPLAY tel_cdarnego tel_dsarnego WITH FRAME f_areasneg.
        APPLY "GO".

    END.

ASSIGN glb_cddopcao = "C"
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
               CLEAR FRAME f_opcao NO-PAUSE.
               HIDE FRAME f_produtos.
               HIDE FRAME f_grupos.
               HIDE FRAME f_areasneg.
               HIDE aux_areasneg IN FRAME f_opcao.
               HIDE aux_produtos IN FRAME f_opcao.
               HIDE aux_grupos IN FRAME f_opcao.
               
               RUN limpa_campos.
               glb_cdcritic = 0.
           END.

      ASSIGN glb_cddopcao = "C".
                                   
          UPDATE glb_cddopcao WITH FRAME f_opcao.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF   CAPS(glb_nmdatela) <> "CADGDC"   THEN
                 DO:
                     HIDE FRAME f_opcao.
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
   
   RUN limpa_campos.

   IF  glb_cddopcao = "C" THEN
       DO:
          DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

             DISPLAY aux_areasneg aux_produtos aux_grupos WITH FRAME f_opcao.
             CHOOSE FIELD aux_areasneg aux_produtos aux_grupos
             PAUSE 60 WITH FRAME f_opcao.

             HIDE MESSAGE NO-PAUSE.
            
             IF FRAME-VALUE = aux_produtos THEN
                DO:
                   RUN busca_produtos.
                   RUN limpa_campos.
                   LEAVE.
                END.
             ELSE
             IF FRAME-VALUE = aux_grupos THEN                
                 DO:
                   RUN busca_grupos.
                   RUN limpa_campos.
                   LEAVE.
                END.
             ELSE
             IF FRAME-VALUE = aux_areasneg THEN
                DO:
                   RUN busca_areasneg.
                   RUN limpa_campos.
                   LEAVE.
                END.
          END. 
       END.  /* OPCAO "C" */
   ELSE
       IF  glb_cddopcao = "A" THEN
           DO:
              DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                  IF   glb_cdcooper <> 3   THEN  
                       DO:
                           MESSAGE "Opcao permitida apenas para a CECRED.".
                           PAUSE(2) NO-MESSAGE.
                           LEAVE.
                       END. 

                  DISPLAY aux_areasneg aux_produtos aux_grupos WITH FRAME f_opcao.
                  CHOOSE FIELD aux_areasneg aux_produtos aux_grupos                      
                  PAUSE 60 WITH FRAME f_opcao. 
                 
                  IF FRAME-VALUE = aux_produtos THEN
                     DO:                            
                         DO  WHILE TRUE ON ENDKEY UNDO, LEAVE: 
                             HIDE tel_dsprodut IN FRAME f_produtos.
                             HIDE tel_dsarnego IN FRAME f_produtos.
                                                                                       
                             UPDATE tel_cdprodut WITH FRAME f_produtos                    
                             EDITING:                                                     
                                READKEY.                                                  
                                  IF  LASTKEY = KEYCODE("F7")  THEN                       
                                      DO:                                                 
                                        OPEN QUERY q-produtos                             
                                            FOR EACH crapprd NO-LOCK.                     
                                                                                          
                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:              
                                            UPDATE b-produtos WITH FRAME f_browse_prd.    
                                            LEAVE.                                        
                                        END.                                              
                                        
                                        HIDE FRAME f_browse_prd.                          
                                        NEXT.                                             
                                                                                          
                                      END.                                                
                                  ELSE                                                    
                                      APPLY LASTKEY.                                      
                             END.                                                        
                                                                                          
                             DO  aux_contador = 1 TO 10:                                 
                                                                                         
                                 FIND crapprd WHERE crapprd.cdprodut = tel_cdprodut      
                                                                 EXCLUSIVE-LOCK NO-ERROR.
                                                                                      
                                 IF  NOT AVAIL crapprd THEN                              
                                     IF   LOCKED crapprd THEN                            
                                          DO:                                            
                                              glb_cdcritic = 77.                         
                                              PAUSE 1 NO-MESSAGE.                        
                                              NEXT.                                      
                                          END.                                           
                                     ELSE                                                
                                          DO:                                            
                                             glb_cdcritic = 893.                         
                                             LEAVE.                                      
                                          END.       
                                 ELSE
                                     DO:
                                       FIND crapadn WHERE crapadn.cdarnego = crapprd.cdarnego
                                                          NO-LOCK NO-ERROR.
                                       
                                       IF NOT AVAIL crapadn THEN
                                          DO:
                                              MESSAGE "O produto possui uma area de negocio invalida".
                                              NEXT.
                                          END.
                                       
                                       ASSIGN tel_dsprodut = crapprd.dsprodut
                                              tel_dsarnego = crapadn.dsarnego. 

                                       LEAVE.
                                    END.
                             END. /*aux_contador*/ 
                            

                             IF   glb_cdcritic = 77   THEN
	                            DO:
                                    
                            		RUN sistema/generico/procedures/b1wgen9999.p
                            			PERSISTENT SET h-b1wgen9999.
                            
                            		RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crapadn),
                            									   INPUT "banco",
                            									   INPUT "crapadn",
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
                            
                            	    NEXT-PROMPT tel_cdprodut WITH FRAME f_produtos.
                            		UNDO.
                            
                            END.
                            ELSE
                             DISPLAY tel_cdprodut tel_dsprodut tel_dsarnego WITH FRAME f_produtos.
                             
                             IF  glb_cdcritic > 0 THEN
                                 LEAVE.
                             
                             UPDATE tel_dsprodut 
                                    tel_dsarnego WITH FRAME f_produtos
                             EDITING:
                                READKEY.
                                IF  FRAME-FIELD = "tel_dsarnego"  THEN
                                    DO:
                                        IF  KEYFUNCTION(LASTKEY) = "TAB" OR
                                            KEYFUNCTION(LASTKEY) = "BACK-TAB" OR
                                            KEYFUNCTION(LASTKEY) = "RETURN" OR
                                            KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                            APPLY LASTKEY.
                                        ELSE
                                        IF  LASTKEY = KEYCODE("F7")  THEN
                                            DO:

                                                OPEN QUERY q-areasneg                             
                                                    FOR EACH crapadn NO-LOCK.                     
                                                                                                  
                                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:              
                                                    UPDATE b-areasneg WITH FRAME f_browse_arn.    
                                                    LEAVE.                                        
                                                END.                                            
                                                
                                                HIDE FRAME f_browse_arn.
                                                
                                                ASSIGN tel_dsarnego = crapadn.dsarnego.
                                                
                                                PAUSE 0.
                                                DISPLAY tel_dsarnego WITH FRAME f_produtos.
                                            END.
                                    END.
                                ELSE
                                    APPLY LASTKEY.
                            END.

                             ASSIGN aux_confirma = "N".
                             
                             RUN fontes/confirma.p                                             
                                 (INPUT "Confirma alteracao? (S/N)",OUTPUT aux_confirma).       
                                                                                               
                             IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR  /*F4 OU FIM*/ 
                                 aux_confirma <> "S"                THEN                      
                                 DO:            
                                    PAUSE(3) NO-MESSAGE.
                                    LEAVE.
                                 END.
                             ELSE
                                 DO:
                                    ASSIGN aux_dsprdant = crapprd.dsprodut
                                           crapprd.dsprodut = tel_dsprodut
                                           crapprd.cdarnego = crapadn.cdarnego.
                                 END.
                             
                             FIND FIRST crapprd WHERE crapprd.cdprodut = tel_cdprodut AND
                                                      crapprd.dsprodut = tel_dsprodut
                                                                         NO-LOCK NO-ERROR.
                             
                             IF  AVAIL crapprd THEN
                                 DO:
                                    MESSAGE "Descricao alterada com sucesso!".
                             
                                    UNIX SILENT VALUE("echo " +
                                                STRING(glb_dtmvtolt,"99/99/9999") +
                                                "' - '" + STRING(TIME,"HH:MM:SS") + 
                                                " 'Operador '" + glb_cdoperad +     
                                                "' alterou a descricao '" +         
                                                aux_dsprdant + "' para '" +         
                                                crapprd.dsprodut +                  
                                                ", referente ao produto " +         
                                                STRING(crapprd.cdprodut)  +         
                                                " >> log/cadgdc.log").
                                 END.
                         END. /* do while true*/

                         RUN limpa_campos.
                         
                         LEAVE.
                       
                     END.
                  ELSE
                  IF FRAME-VALUE = aux_grupos THEN
                     DO:
                         DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                             HIDE tel_dsgrupos IN FRAME f_grupos.                          
                                                                                           
                             UPDATE tel_cdgrupos WITH FRAME f_grupos  
                             EDITING:                                                      
                                READKEY.                                                   
                                  IF  LASTKEY = KEYCODE("F7")  THEN                        
                                      DO:                                                  
                                        OPEN QUERY q-grupos
                                            FOR EACH crapagr NO-LOCK.                      
                                                                                           
                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:       

                                            UPDATE b-grupos WITH FRAME f_browse_grp.       
                                            LEAVE.                                         
                                        END.                                               
                                                                                           
                                        HIDE FRAME f_browse_grp.                           
                                        NEXT.                                              
                                                                                           
                                      END.                                                 
                                  ELSE                                                     
                                      APPLY LASTKEY.                                       
                             END.                                                          
                                                                                          
                             DO  aux_contador = 1 TO 10:                                   
                                                                                           
                                 FIND crapagr WHERE crapagr.cdagrupa = tel_cdgrupos
                                                              EXCLUSIVE-LOCK NO-ERROR.     
                                                                                           
                                 IF  NOT AVAIL crapagr THEN                                
                                     IF   LOCKED crapagr THEN                              
                                          DO:                                              
                                              glb_cdcritic = 77.                           
                                              PAUSE 1 NO-MESSAGE.                          
                                              NEXT.                                        
                                          END.                                             
                                     ELSE                                                  
                                          DO:                                              
                                             glb_cdcritic = 893.                           
                                             LEAVE.                                        
                                          END.                                             
                                                                                           
                                     ASSIGN tel_dsgrupos = crapagr.dsagrupa.               
                                                                                           
                                     DISPLAY tel_cdgrupos tel_dsgrupos WITH FRAME f_grupos.
                                                                                           
                             END. /*aux_contador*/                                                         
                             IF   glb_cdcritic = 77   THEN
	                            DO:
                                    
                            		RUN sistema/generico/procedures/b1wgen9999.p
                            			PERSISTENT SET h-b1wgen9999.
                            
                            		RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crapagr),
                            									   INPUT "banco",
                            									   INPUT "crapagr",
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
                            		
                            		NEXT-PROMPT tel_cdprodut WITH FRAME f_produtos.
                            		UNDO.
                            
                            END.
                             IF  glb_cdcritic > 0 THEN
                                 LEAVE.
                             
                             UPDATE tel_dsgrupos WITH FRAME f_grupos.
                             
                             ASSIGN aux_confirma = "N".
                             
                             RUN fontes/confirma.p                                             
                                 (INPUT "Confirma alteracao? (S/N)",OUTPUT aux_confirma).       
                                                                                               
                             IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR  /*F4 OU FIM*/ 
                                 aux_confirma <> "S"                THEN                      
                                 DO:            
                                    PAUSE(3) NO-MESSAGE.
                                    LEAVE.
                                 END.
                             ELSE
                                 DO:
                                    ASSIGN aux_dsgrpant = crapagr.dsagrupa
                                           crapagr.dsagrupa = tel_dsgrupos.
                                 END.
                             
                             FIND FIRST crapagr WHERE crapagr.cdagrupa = tel_cdgrupos AND
                                                      crapagr.dsagrupa = tel_dsgrupos
                                                                          NO-LOCK NO-ERROR.
                        
                             IF  AVAIL crapagr THEN
                                 DO:
                                    MESSAGE "Descricao alterada com sucesso!".
                             
                                    UNIX SILENT VALUE("echo " + 
                                                STRING(glb_dtmvtolt,"99/99/9999") + 
                                                STRING(glb_dtmvtolt,"99/99/9999") +
                                                "' - '" + STRING(TIME,"HH:MM:SS") + 
                                                " 'Operador '" + glb_cdoperad +     
                                                "' alterou a descricao '" +         
                                                aux_dsgrpant + "' para '" +         
                                                crapagr.dsagrupa +                  
                                                ", referente o grupo "  +           
                                                STRING(crapagr.cdagrupa) +         
                                                " >> log/cadgdc.log").
                                 END.
                             END. /*do while true*/  
    
                         RUN limpa_campos. 
                         LEAVE.
                     END.
                  ELSE
                  IF FRAME-VALUE = aux_areasneg THEN
                     DO:
                         DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                             HIDE tel_dsarnego IN FRAME f_areasneg.                          
                                                                                           
                             UPDATE tel_cdarnego WITH FRAME f_areasneg                       
                             EDITING:                                                      
                                READKEY.                                                   
                                  IF  LASTKEY = KEYCODE("F7")  THEN                        
                                      DO:                                                  
                                        OPEN QUERY q-areasneg                                
                                            FOR EACH crapadn NO-LOCK.                      
                                                                                           
                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:               
                                            UPDATE b-areasneg WITH FRAME f_browse_arn.       
                                            LEAVE.                                         
                                        END.                                               
                                                                                           
                                        HIDE FRAME f_browse_arn.                           
                                        NEXT.                                              
                                                                                           
                                      END.                                                 
                                  ELSE                                                     
                                      APPLY LASTKEY.                                       
                             END.                                                          
                                                                                          
                             DO  aux_contador = 1 TO 10:                                   
                                                                                           
                                 FIND crapadn WHERE crapadn.cdarnego = tel_cdarnego      
                                                              EXCLUSIVE-LOCK NO-ERROR.     
                                                                                           
                                 IF  NOT AVAIL crapadn THEN                                
                                     IF   LOCKED crapadn THEN                              
                                          DO:                                              
                                              glb_cdcritic = 77.                           
                                              PAUSE 1 NO-MESSAGE.                          
                                              NEXT.                                        
                                          END.                                             
                                     ELSE                                                  
                                          DO:                                              
                                             glb_cdcritic = 893.                           
                                             LEAVE.                                        
                                          END.                                             
                                                                                           
                                     ASSIGN tel_dsarnego = crapadn.dsarnego.               
                                                                                           
                                     DISPLAY tel_cdarnego tel_dsarnego WITH FRAME f_areasneg.
                                                                                           
                             END. /*aux_contador*/                                                         
                        
                             IF  glb_cdcritic > 0 THEN
                                 LEAVE.
                             
                             UPDATE tel_dsarnego WITH FRAME f_areasneg.
                             
                             ASSIGN aux_confirma = "N".
                             
                             RUN fontes/confirma.p                                             
                                 (INPUT "Confirma alteracao? (S/N)",OUTPUT aux_confirma).       
                                                                                               
                             IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR  /*F4 OU FIM*/ 
                                 aux_confirma <> "S"                THEN                      
                                 DO:            
                                    PAUSE(3) NO-MESSAGE.
                                    LEAVE.
                                 END.
                             ELSE
                                 DO:
                                    ASSIGN aux_dsarnant = crapadn.dsarnego
                                           crapadn.dsarnego = tel_dsarnego.
                                 END.
                             
                             FIND FIRST crapadn WHERE crapadn.cdarnego = tel_cdarnego AND
                                                      crapadn.dsarnego = tel_dsarnego
                                                                          NO-LOCK NO-ERROR.
                        
                             IF  AVAIL crapadn THEN
                                 DO:
                                    MESSAGE "Descricao alterada com sucesso!".
                             
                                    UNIX SILENT VALUE("echo " + 
                                                STRING(glb_dtmvtolt,"99/99/9999") + 
                                                STRING(glb_dtmvtolt,"99/99/9999") +
                                                "' - '" + STRING(TIME,"HH:MM:SS") + 
                                                " 'Operador '" + glb_cdoperad +     
                                                "' alterou a descricao '" +         
                                                aux_dsarnant + "' para '" +         
                                                crapadn.dsarnego +                  
                                                ", referente a area de negocio "  +           
                                                STRING(crapadn.cdarnego) +         
                                                " >> log/cadgdc.log").
                                 END.
                             END. /*do while true*/  
    
                         RUN limpa_campos.    
                         LEAVE.
                     END.
              END. /* do while true*/
           END.  /* OPCAO "A" */
       ELSE
           IF glb_cddopcao = "I" THEN
              DO:
                 DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                     IF   glb_cdcooper <> 3   THEN  
                          DO:
                              MESSAGE "Opcao permitida apenas para a CECRED.".
                              PAUSE(2) NO-MESSAGE.
                              LEAVE.
                          END. 

                     DISPLAY aux_areasneg aux_produtos aux_grupos WITH FRAME f_opcao.
                     CHOOSE FIELD aux_areasneg aux_produtos aux_grupos                      
                     PAUSE 60 WITH FRAME f_opcao. 
                     
                     IF  FRAME-VALUE = aux_produtos THEN
                         DO:
                            FIND LAST crapprd WHERE crapprd.cdprodut <> 99999
                                 NO-LOCK NO-ERROR.
                        
                            ASSIGN tel_cdprodut = crapprd.cdprodut + 1
                                   tel_dsarnego = "".
                     
                            DISPLAY tel_cdprodut WITH FRAME f_produtos.
                        
                            UPDATE tel_dsprodut 
                                   tel_dsarnego WITH FRAME f_produtos
                             EDITING:
                                READKEY.
                                IF  FRAME-FIELD = "tel_dsarnego"  THEN
                                    DO:
                                        IF  KEYFUNCTION(LASTKEY) = "TAB" OR
                                            KEYFUNCTION(LASTKEY) = "BACK-TAB" OR
                                            KEYFUNCTION(LASTKEY) = "RETURN" OR
                                            KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                            APPLY LASTKEY.
                                        ELSE
                                        IF  LASTKEY = KEYCODE("F7")  THEN
                                            DO:

                                                OPEN QUERY q-areasneg                             
                                                    FOR EACH crapadn NO-LOCK.                     
                                                                                                  
                                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:              
                                                    UPDATE b-areasneg WITH FRAME f_browse_arn.    
                                                    LEAVE.                                        
                                                END.                                            
                                                
                                                HIDE FRAME f_browse_arn.
                                                
                                                ASSIGN tel_dsarnego = crapadn.dsarnego.
                                                
                                                PAUSE 0.
                                                DISPLAY tel_dsarnego WITH FRAME f_produtos.
                                            END.
                                    END.
                                ELSE
                                    APPLY LASTKEY.
                            END.
                        
                            IF tel_dsarnego = "" THEN
                                ASSIGN tel_cdarnego = 999.
                            ELSE
                                ASSIGN tel_cdarnego = crapadn.cdarnego.
                                        
                            RUN fontes/confirma.p                                             
                                (INPUT "Confirma inclusao? (S/N)",OUTPUT aux_confirma).       
                                                                                              
                            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR  /*F4 OU FIM*/ 
                                aux_confirma <> "S"                THEN                      
                                DO:            
                                   PAUSE(3) NO-MESSAGE.
                                   LEAVE.
                                END.
                            ELSE
                                DO:
                                   CREATE crapprd.
                                   ASSIGN crapprd.cdprodut = tel_cdprodut
                                          crapprd.dsprodut = tel_dsprodut
                                          crapprd.cdarnego = tel_cdarnego.

                                   VALIDATE crapprd.
                                END.
                     
                            FIND FIRST crapprd WHERE crapprd.cdprodut = tel_cdprodut AND
                                                     crapprd.dsprodut = tel_dsprodut
                                                                        NO-LOCK NO-ERROR.
                     
                            IF  AVAIL crapprd THEN
                                DO:
                                   MESSAGE "Inclusao feita com sucesso!".
                           
                                   UNIX SILENT VALUE("echo " + 
                                               STRING(glb_dtmvtolt,"99/99/9999")  + 
                                               "' - '" + STRING(TIME,"HH:MM:SS") +
                                               " 'Operador '" + glb_cdoperad +
                                               "' incluiu o produto '" + 
                                               STRING(crapprd.cdprodut) +  
                                               "' com a descricao '" + crapprd.dsprodut + 
                                               " >> log/cadgdc.log").
                                END.
                            
                            RUN limpa_campos.
                            
                            LEAVE.
                         END.
                     ELSE
                     IF  FRAME-VALUE = aux_grupos THEN
                         DO:
                            FIND LAST crapagr WHERE crapagr.cdagrupa <> 99999
                                      NO-LOCK NO-ERROR.                            
                                                                                       
                            ASSIGN tel_cdgrupos = crapagr.cdagrupa + 1.  
                        
                            DISPLAY tel_cdgrupos WITH FRAME f_grupos.
                                                                                       
                            UPDATE tel_dsgrupos WITH FRAME f_grupos.                                       
                                                                                       
                            RUN fontes/confirma.p                                      
                                (INPUT "Confirma inclusao? (S/N)",OUTPUT aux_confirma).
                                                                                       
                            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR  /*F4 OU FIM*/   
                                aux_confirma <> "S"                THEN                
                                DO:                                                    
                                   PAUSE(3) NO-MESSAGE.                                
                                   LEAVE.                                              
                                END.                                                   
                            ELSE
                                DO:
                                   CREATE crapagr.
                                   ASSIGN crapagr.cdagrupa = tel_cdgrupos                     
                                          crapagr.dsagrupa = tel_dsgrupos.

                                   VALIDATE crapagr.
                                END.
                        
                            FIND FIRST crapagr WHERE crapagr.cdagrupa = tel_cdgrupos AND
                                                     crapagr.dsagrupa = tel_dsgrupos
                                                                        NO-LOCK NO-ERROR.
                        
                            IF  AVAIL crapagr THEN
                                DO:
                                   MESSAGE "Inclusao feita com sucesso!".
                            
                                   UNIX SILENT VALUE("echo " + 
                                               STRING(glb_dtmvtolt,"99/99/9999")  + 
                                               "' - '" + STRING(TIME,"HH:MM:SS") +
                                               " 'Operador '" + glb_cdoperad +
                                               "' incluiu o grupo '" +
                                               STRING(crapagr.cdagrupa) +  
                                               "' com a descricao '" + 
                                               crapagr.dsagrupa + " >> log/cadgdc.log").
                                END.
                        
                             RUN limpa_campos.
                             LEAVE.
                         END.
                    ELSE
                    IF  FRAME-VALUE = aux_areasneg THEN
                        DO:
                            FIND LAST crapadn WHERE crapadn.cdarnego <> 999 
                                              NO-LOCK NO-ERROR.

                            ASSIGN tel_cdarnego = crapadn.cdarnego + 1.

                            DISPLAY tel_cdarnego WITH FRAME f_areasneg.
                        
                            UPDATE tel_dsarnego WITH FRAME f_areasneg.
                        
                            RUN fontes/confirma.p                                             
                                (INPUT "Confirma inclusao? (S/N)",OUTPUT aux_confirma).       
                                                                                              
                            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR  /*F4 OU FIM*/ 
                                aux_confirma <> "S"                THEN                      
                                DO:            
                                   PAUSE(3) NO-MESSAGE.
                                   LEAVE.
                                END.
                            ELSE
                                DO:
                                   CREATE crapadn.
                                   ASSIGN crapadn.cdarnego = tel_cdarnego
                                          crapadn.dsarnego = tel_dsarnego.

                                   VALIDATE crapadn.
                                END.
                     
                            FIND FIRST crapadn WHERE crapadn.cdarnego = tel_cdarnego AND
                                                     crapadn.dsarnego = tel_dsarnego
                                                                        NO-LOCK NO-ERROR.
                     
                            IF  AVAIL crapadm THEN
                                DO:
                                   MESSAGE "Inclusao feita com sucesso!".
                           
                                   UNIX SILENT VALUE("echo " + 
                                               STRING(glb_dtmvtolt,"99/99/9999")  + 
                                               "' - '" + STRING(TIME,"HH:MM:SS") +
                                               " 'Operador '" + glb_cdoperad +
                                               "' incluiu a area de negocio '" + 
                                               STRING(crapadn.cdarnego) +  
                                               "' com a descricao '" + crapadn.dsarnego + 
                                               " >> log/cadgdc.log").
                                END.
                            
                            RUN limpa_campos.
                            LEAVE.
                        END.

                 END. /*do while true*/
              END.  /* OPCAO "I" */
END.  /*do while true*/ 

PROCEDURE busca_produtos.

    HIDE tel_dsprodut IN FRAME f_produtos.
    HIDE tel_dsarnego IN FRAME f_produtos.

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
        UPDATE tel_cdprodut WITH FRAME f_produtos 
        EDITING:
           READKEY.
             IF  LASTKEY = KEYCODE("F7")  THEN
                 DO:
                   OPEN QUERY q-produtos
                       FOR EACH crapprd NO-LOCK.
                       
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                       UPDATE b-produtos WITH FRAME f_browse_prd.
                       LEAVE.   
                   END.
      
                   HIDE FRAME f_browse_prd.
                   NEXT.
        
                 END.
             ELSE
                 APPLY LASTKEY.
         END. 
      
         FIND crapprd WHERE crapprd.cdprodut = tel_cdprodut 
                                             NO-LOCK NO-ERROR.
                                                                             
         IF  NOT AVAIL crapprd THEN                                          
             DO:                                                             
                MESSAGE "Codigo nao cadastrado".                             
                NEXT.                                                        
             END.                                                            
                                                                             
         FIND crapadn WHERE crapadn.cdarnego = crapprd.cdarnego
                             NO-LOCK NO-ERROR.
         
         IF NOT AVAIL crapadn THEN
            DO:
                MESSAGE "O produto possui uma area de negocio invalida".
                NEXT.
            END.

         ASSIGN tel_dsprodut = crapprd.dsprodut
                tel_dsarnego = crapadn.dsarnego.
                                                                             
         DISPLAY tel_cdprodut tel_dsprodut tel_dsarnego WITH FRAME f_produtos.
    END.

END PROCEDURE.  /* busca_produtos */

PROCEDURE busca_grupos.

    HIDE tel_dsgrupos IN FRAME f_grupos.

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
        UPDATE tel_cdgrupos WITH FRAME f_grupos
        EDITING:
           READKEY.
             IF  LASTKEY = KEYCODE("F7")  THEN
                 DO:
                   OPEN QUERY q-grupos
                       FOR EACH crapagr NO-LOCK.
                       
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                       UPDATE b-grupos WITH FRAME f_browse_grp.
                       LEAVE.   
                   END.
      
                   HIDE FRAME f_browse_grp.
                   NEXT.
      
                 END.
             ELSE
                 APPLY LASTKEY.
        END.
      
        FIND crapagr WHERE crapagr.cdagrupa = tel_cdgrupos
                                               NO-LOCK NO-ERROR.
      
        IF  NOT AVAIL crapagr THEN
            DO:
               MESSAGE "Codigo " + STRING(tel_cdgrupos) + 
                       " nao cadastrado".
               NEXT.     
            END.
      
        ASSIGN tel_dsgrupos = crapagr.dsagrupa.
      
        DISPLAY tel_cdgrupos tel_dsgrupos WITH FRAME f_grupos.
    END.

END PROCEDURE.  /* busca_grupos */

PROCEDURE busca_areasneg.

    HIDE tel_dsarnego IN FRAME f_areasneg.

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
        UPDATE tel_cdarnego WITH FRAME f_areasneg
        EDITING:
           READKEY.
             IF  LASTKEY = KEYCODE("F7")  THEN
                 DO:
                   OPEN QUERY q-areasneg
                       FOR EACH crapadn NO-LOCK.
                       
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                       UPDATE b-areasneg WITH FRAME f_browse_arn.
                       LEAVE.   
                   END.
      
                   HIDE FRAME f_browse_arn.
                   NEXT.
      
                 END.
             ELSE
                 APPLY LASTKEY.
        END.
      
        FIND crapadn WHERE crapadn.cdarnego = tel_cdarnego
                                               NO-LOCK NO-ERROR.
      
        IF  NOT AVAIL crapadn THEN
            DO:
               MESSAGE "Codigo " + STRING(tel_cdarnego) + 
                       " nao cadastrado".
               NEXT.     
            END.
      
        ASSIGN tel_dsarnego = crapadn.dsarnego.
      
        DISPLAY tel_cdarnego tel_dsarnego WITH FRAME f_areasneg.
    END.

END PROCEDURE.  /* busca_areasneg */


PROCEDURE limpa_campos.

    HIDE FRAME f_produtos.
    HIDE FRAME f_areasneg.
    HIDE FRAME f_grupos.
    HIDE aux_areasneg IN FRAME f_opcao.   
    HIDE aux_produtos IN FRAME f_opcao.
    HIDE aux_grupos   IN FRAME f_opcao.

    ASSIGN tel_cdprodut = 0
           tel_dsprodut = " "
           tel_cdgrupos = 0
           tel_dsgrupos = " "
           tel_cdarnego = 0
           tel_dsarnego = " ".

END PROCEDURE. /* limpa_campos */

