/* ............................................................................

   Programa: Fontes/codgps.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Setembro/2008                     Ultima Atualizacao: 30/11/2016

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line).
   Objetivo  : Tela CODGPS. Cadastro de codigos validos de GPS.

   Alteracoes: 09/10/2008 - Quando desabilitado codigo de pagamento desabilitar
                            a(s) guia(s) na crapcgp do codigo (Gabriel).

               19/11/2008 - Incluir campo cdforcap (Forma de captacao)(Gabriel).

               19/03/2009 - Ajustes para unificacao dos bancos de dados
                            (Evandro).
               
               11/05/2009 - Alteracao CDOPERAD (Kbase).
               
               03/12/2013 - Inclusao de VALIDATE crapgps (Carlos)
               
               22/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                           
               30/11/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
            
..............................................................................*/

{ includes/var_online.i }

DEF VAR tel_cddpagto LIKE crapgps.cddpagto                             NO-UNDO.
DEF VAR tel_dsdpagto AS CHARACTER  EXTENT 3     FORMAT "x(49)"         NO-UNDO.
DEF VAR tel_flgativo AS LOGICAL                 FORMAT "Sim/Nao"       NO-UNDO.
DEF VAR tel_cdforcap AS INTEGER                 FORMAT "zz9"           NO-UNDO. 

DEF VAR aux_confirma AS LOGICAL                 FORMAT "S/N"           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_stimeout AS INT                                            NO-UNDO.
DEF VAR aux_contador AS INT                                            NO-UNDO.

DEF VAR aux_dadosusr AS CHAR                                           NO-UNDO.
DEF VAR par_loginusr AS CHAR                                           NO-UNDO.
DEF VAR par_nmusuari AS CHAR                                           NO-UNDO.
DEF VAR par_dsdevice AS CHAR                                           NO-UNDO.
DEF VAR par_dtconnec AS CHAR                                           NO-UNDO.
DEF VAR par_numipusr AS CHAR                                           NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                         NO-UNDO.

DEF QUERY q-codigo FOR crapgps.

DEF BROWSE b-codigo QUERY q-codigo
    DISPLAY crapgps.cddpagto
            crapgps.dsdpagto COLUMN-LABEL "Descricao"  FORMAT "x(60)"
            WITH 5 DOWN TITLE " Codigos de pagamento ".

FORM SKIP(1)
     glb_cddopcao    AT 03  LABEL "Opcao"          AUTO-RETURN
                     HELP "Informe a opcao desejada (A,C ou I)."
                     VALIDATE(CAN-DO("A,C,I",glb_cddopcao),
                              "014 - Opcao errada.")
     SKIP (14)
     WITH ROW 4 SIDE-LABELS TITLE glb_tldatela WIDTH 80 FRAME f_opcao.

FORM tel_cddpagto    AT 03  LABEL "Codigo pgto"    AUTO-RETURN
     SKIP(1)
     tel_dsdpagto[1] AT 03 LABEL "Descricao"       AUTO-RETURN
                     HELP "Informe a descricao do codigo da GPS."
     tel_dsdpagto[2] AT 14 NO-LABEL                AUTO-RETURN
                     HELP "Informe a descricao do codigo da GPS."
     tel_dsdpagto[3] AT 14 NO-LABEL                AUTO-RETURN
                     HELP "Informe a descricao do codigo da GPS."
     SKIP(2)
     tel_cdforcap    AT 03 LABEL "Captacao "       AUTO-RETURN
     HELP "1- Boca de caixa, 4- Boca de caixa com cod. de captacao."
                     VALIDATE(CAN-DO("1,4",STRING(tel_cdforcap)),
                          "Codigo de forma de captacao invalido.")
     SKIP(2)
     tel_flgativo    AT 03 LABEL "Ativo    "       AUTO-RETURN
                     HELP "Informe se o codigo esta ativo para recebimento."
     SKIP(1)
     WITH NO-BOX ROW 08 SIDE-LABELS OVERLAY WIDTH 78 CENTERED FRAME f_codgps.

FORM b-codigo
     HELP "Use as setas p/navegar e <ENTER> para entrar com os dados."
     WITH NO-BOX ROW 10 WIDTH 76 SIDE-LABELS OVERLAY CENTERED FRAME f_codigo.

                        
ON RETURN OF b-codigo IN FRAME f_codigo DO:

    IF   NOT NUM-RESULTS("q-codigo") = 0   THEN
         DO:
             tel_cddpagto = crapgps.cddpagto.
         END.             
   
    APPLY "GO".

END.
                          

ON ITERATION-CHANGED , ENTRY OF b-codigo DO:
    
    PAUSE 0.

    IF   NOT NUM-RESULTS("q-codigo") = 0   THEN
         DO:
             ASSIGN tel_cddpagto = crapgps.cddpagto.
                      
             DISPLAY tel_cddpagto WITH FRAME f_codgps.
         END.
END.
                                                    
ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.
   
   CLEAR FRAME f_codgps.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      UPDATE glb_cddopcao WITH FRAME f_opcao.
      LEAVE.
   END.
      
   IF   glb_cddepart <> 20   AND   /* TI                   */
        glb_cddepart <> 18   AND   /* SUPORTE              */
        glb_cddepart <>  8   AND   /* COORD.ADM/FINANCEIRO */
        glb_cddepart <>  4   AND   /* COMPE                */
        glb_cddopcao <> "C"  THEN
        DO:
            glb_cdcritic = 36.
            RUN fontes/critic.p.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            LEAVE.
        END.
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN   
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "CODGPS"   THEN
                 DO:
                     HIDE FRAME f_opcao
                          FRAME f_codgps.
                     RETURN.
                 END.
            NEXT.
        END.
        
   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.    
   
   IF   glb_cddopcao = "C"   THEN
        tel_cddpagto:HELP = "Informe o codigo de pagamento ou F7 para listar.".
   ELSE
        DO:
            tel_cddpagto:HELP = "Informe o codigo de pagamento.".
            tel_cddpagto = 0.
        END.
        
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:        
           
      UPDATE tel_cddpagto WITH FRAME f_codgps 
   
        EDITING:
            
            aux_stimeout = 0.
            
            DO WHILE TRUE: 
                
                READKEY PAUSE 1.
               
                IF   LASTKEY = -1   THEN
                     DO:
                         aux_stimeout = aux_stimeout + 1.
                       
                         IF   aux_stimeout > glb_stimeout   THEN
                              QUIT.
                        
                         NEXT.
                     END.
                ELSE      
                IF   LASTKEY = KEYCODE("F7")   AND   glb_cddopcao = "C"   THEN
                     DO:
                         OPEN QUERY q-codigo FOR EACH crapgps NO-LOCK.
                                                             
                         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            UPDATE b-codigo WITH FRAME f_codigo.
                            LEAVE.
                         END.   

                         IF   KEYFUNCTION(LASTKEY) = "END-ERROR"    THEN
                              DO:
                                  tel_cddpagto = 0.
                                  LEAVE.
                              END.

                         APPLY "RETURN". 

                     END.
                ELSE
                     APPLY LASTKEY.

                LEAVE.
            
            END.  /* Fim do DO WHILE TRUE */
            
        END. /* Fim do EDITING */
        
      LEAVE.  

   END.    /* Fim do DO WHILE TRUE */
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        NEXT.

   IF   glb_cddopcao = "C"   THEN
        DO:
            FIND crapgps WHERE crapgps.cddpagto = tel_cddpagto NO-LOCK NO-ERROR.
                               
            IF   NOT AVAILABLE crapgps   THEN
                 DO:
                     glb_cdcritic = 893.
                     RUN fontes/critic.p.
                     MESSAGE glb_dscritic.
                     ASSIGN glb_cdcritic = 0
                            tel_cddpagto = 0.
                     PAUSE 1 NO-MESSAGE.
                     LEAVE.
                 END.
                
            ASSIGN tel_dsdpagto[1] = SUBSTR(crapgps.dsdpagto,1,49)
                   tel_dsdpagto[2] = SUBSTR(crapgps.dsdpagto,50,49)
                   tel_dsdpagto[3] = SUBSTR(crapgps.dsdpagto,99,49)
                   tel_flgativo    = crapgps.flgativo
                   tel_cdforcap    = crapgps.cdforcap.
                   
            DISPLAY tel_cddpagto tel_dsdpagto tel_flgativo tel_cdforcap 
                    WITH FRAME f_codgps.

            HIDE FRAME f_codigo.  
            
            ASSIGN tel_cddpagto = 0.
            
        END. /* Fim opcao "C" */
   ELSE
   IF   glb_cddopcao = "A"   THEN 
        DO:
            DO aux_contador = 1 TO 10:
            
               FIND crapgps WHERE crapgps.cddpagto = tel_cddpagto 
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                  
               IF   NOT AVAILABLE crapgps   THEN
                    IF  LOCKED crapgps   THEN
                        DO:
                            RUN sistema/generico/procedures/b1wgen9999.p
                            PERSISTENT SET h-b1wgen9999.
                            
                            RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crapgps),
                            					 INPUT "banco",
                            					 INPUT "crapgps",
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
                            glb_cdcritic = 893.
                            LEAVE.
                        END. 

               glb_cdcritic = 0.                   
               LEAVE.
  
            END.

            IF   glb_cdcritic > 0   THEN
                 DO:
                     RUN fontes/critic.p.
                     MESSAGE glb_dscritic.
                     ASSIGN glb_cdcritic = 0
                            tel_cddpagto = 0.
                     PAUSE 2 NO-MESSAGE.
                     LEAVE.
                 END.
            
            ASSIGN tel_dsdpagto[1] = SUBSTR(crapgps.dsdpagto,1,49)
                   tel_dsdpagto[2] = SUBSTR(crapgps.dsdpagto,50,49)
                   tel_dsdpagto[3] = SUBSTR(crapgps.dsdpagto,99,49)
                   tel_flgativo    = crapgps.flgativo
                   tel_cdforcap    = crapgps.cdforcap.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                UPDATE tel_dsdpagto tel_cdforcap tel_flgativo 
                       WITH FRAME f_codgps.
                LEAVE. 
            END.
                        
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 DO:
                     tel_cddpagto = 0.
                     LEAVE.
                 END.

            RUN p_confirma.   

            IF   NOT aux_confirma   THEN   LEAVE. 
            
            ASSIGN crapgps.dsdpagto = tel_dsdpagto[1] +
                                      tel_dsdpagto[2] +
                                      tel_dsdpagto[3]
                   crapgps.flgativo = tel_flgativo
                   crapgps.cdforcap = tel_cdforcap.
                   
            IF   tel_flgativo   THEN   LEAVE.    
                     
            /* Desabilita guias ligadas ao codigo desativado*/
            FOR EACH crapcgp WHERE crapcgp.cdcooper = glb_cdcooper   AND
                                   crapcgp.cddpagto = tel_cddpagto   
                                   EXCLUSIVE-LOCK:
        
                crapcgp.flgrgatv = NO.
            END.

            tel_cddpagto = 0.
        
        END. /*  Fim da opcao "A"  */               
   ELSE 
        DO:
            IF   CAN-FIND(crapgps WHERE 
                          crapgps.cddpagto = tel_cddpagto NO-LOCK)   THEN
                 DO:
                     glb_cdcritic = 873.      
                     RUN fontes/critic.p.
                     MESSAGE glb_dscritic.
                     ASSIGN glb_cdcritic = 0
                            tel_cddpagto = 0.
                     PAUSE 1 NO-MESSAGE.
                     LEAVE.
                 END.         
         
            ASSIGN tel_dsdpagto = ""
                   tel_cdforcap = 0
                   tel_flgativo = YES.
            
            DISPLAY tel_flgativo WITH FRAME f_codgps. 

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                UPDATE tel_dsdpagto tel_cdforcap WITH FRAME f_codgps.
                LEAVE.
            END.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 DO:
                     tel_cddpagto = 0.
                     LEAVE.
                 END.

            RUN p_confirma.

            IF   aux_confirma  THEN     
                 DO:        
                     CREATE crapgps.
                     ASSIGN crapgps.cddpagto = tel_cddpagto
                            crapgps.dsdpagto = tel_dsdpagto [1] +
                                               tel_dsdpagto [2] +
                                               tel_dsdpagto [3] 
                            crapgps.cdforcap = tel_cdforcap
                            crapgps.flgativo = YES.

                     VALIDATE crapgps.

                 END.
            ELSE
                 tel_cddpagto = 0.       
             
        END. /* Fim da opcao "I" */
                                    
END.  /* Fim do DO WHILE TRUE */


PROCEDURE p_confirma:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       ASSIGN aux_confirma = NO
              glb_cdcritic = 78.
       RUN fontes/critic.p.
       MESSAGE glb_dscritic UPDATE aux_confirma.
       glb_cdcritic = 0.
       LEAVE.
    END.
    
    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma = NO   THEN
         DO:
             glb_cdcritic = 79.
             RUN fontes/critic.p.
             MESSAGE glb_dscritic.
             glb_cdcritic = 0.
             PAUSE 1 NO-MESSAGE.
         END.
END.

/*............................................................................*/
 
