/* .............................................................................

   Programa: Fontes/cadura.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Diego
   Data    : Dezembro/2005.                     Ultima atualizacao: 24/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratar acesso senha Ura.

   Alteracoes: 23/02/2006 - Modificado o status ATIVO de 0 para 1 (Evandro).
   
               24/01/2014 - Programa convertido para poder ser chamado pela WEB.
                            As regras de negocio foram retiradas e colocadas
                            todas na procedure b1wgen0015.p. (Reinert)

 ............................................................................ */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_atenda.i }
{ sistema/generico/includes/b1wgen0015tt.i }
                                                  
DEF VAR tel_opcadsen AS CHAR INIT "Alterar Senha"                     NO-UNDO.
DEF VAR tel_cddsenha AS CHAR  FORMAT "x(8)"                           NO-UNDO.
DEF VAR tel_nmopeura AS CHAR  FORMAT "x(15)"                          NO-UNDO.
DEF VAR tel_dtaltsnh AS CHAR  FORMAT "x(10)"                          NO-UNDO.

DEF VAR aux_cdsenha1 AS CHAR  FORMAT "x(8)"                           NO-UNDO.
DEF VAR aux_cdsenha2 AS CHAR  FORMAT "x(8)"                           NO-UNDO.
DEF VAR aux_cdcooper AS CHAR  FORMAT "x(2)"                           NO-UNDO.
DEF VAR aux_flgsnura AS LOGI                                          NO-UNDO.

DEF VAR h-b1wgen0015 AS HANDLE                                        NO-UNDO.

FORM SKIP(2) 
     "        Operador:"  tel_nmopeura     FORMAT "x(14)"
     SPACE(8) SKIP SPACE(3)
     "  Dt.Alt.Sen.:"  tel_dtaltsnh
     SKIP(2)SPACE(12)
     tel_opcadsen                          FORMAT "x(14)"  NO-LABEL
         HELP "Altera a senha numerica para acesso a Ura."
     WITH ROW 10 CENTERED SIDE-LABELS NO-LABELS OVERLAY TITLE COLOR NORMAL
          " ACESSO A SENHA - TELE ATENDIMENTO " FRAME f_ura.

FORM SKIP(2) 
     "        Operador:"  tel_nmopeura     FORMAT "x(14)"
     SKIP(2)SPACE(10)
     tel_opcadsen                          FORMAT "x(15)"  NO-LABEL
         HELP "Cadastra a senha numerica para acesso a Ura."
     WITH ROW 10 CENTERED SIDE-LABELS NO-LABELS OVERLAY TITLE COLOR NORMAL
          " ACESSO A SENHA - TELE ATENDIMENTO " FRAME f_ura2.

FORM SPACE(3)

     aux_cdsenha1  LABEL "    Nova Senha" BLANK AUTO-RETURN                 
     HELP "Senha c/ 8 posicoes numericas"  
     SKIP(1) SPACE(3)
     aux_cdsenha2  LABEL "Confirme Senha" BLANK AUTO-RETURN
     HELP "Repita a nova senha"
     SPACE(3)
     WITH COLUMN 25 ROW 11 SIDE-LABELS OVERLAY FRAME f_alt_senha.

RUN sistema/generico/procedures/b1wgen0015.p 
    PERSISTENT SET h-b1wgen0015.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   RUN carrega_dados_ura IN h-b1wgen0015(INPUT glb_cdcooper,
                                         INPUT glb_cdagenci,
                                         INPUT 0, /* nrdcaixa */
                                         INPUT glb_cdoperad,
                                         INPUT glb_nmdatela,
                                         INPUT 1, /* idorigem */
                                         INPUT tel_nrdconta,
                                         INPUT 1, /* idseqttl */
                                        OUTPUT aux_flgsnura,
                                        OUTPUT TABLE tt-dados-ura,
                                        OUTPUT TABLE tt-erro).

   FIND FIRST tt-dados-ura NO-ERROR.

   IF   AVAIL tt-dados-ura  THEN
        ASSIGN tel_nmopeura = tt-dados-ura.nmopeura
               tel_dtaltsnh = tt-dados-ura.dtaltsnh.

   IF   aux_flgsnura    THEN
        DO:
            DISPLAY tel_nmopeura 
                    tel_dtaltsnh
                    tel_opcadsen  
                    WITH FRAME f_ura.

           CHOOSE FIELD tel_opcadsen WITH FRAME f_ura.
       END.
   ELSE
       DO:
           ASSIGN tel_opcadsen = "Cadastrar Senha".

           DISPLAY tel_nmopeura tel_opcadsen  
                   WITH FRAME f_ura2.

           CHOOSE FIELD tel_opcadsen WITH FRAME f_ura2.
       END.

   IF   FRAME-VALUE = tel_opcadsen   THEN /* ALTERA SENHA */
        DO:
            IF  tel_opcadsen = "Cadastrar Senha"    THEN
                ASSIGN glb_cddopcao = "I".
            ELSE
                ASSIGN glb_cddopcao = "A".

            { includes/acesso.i }

            HIDE MESSAGE NO-PAUSE.
            ASSIGN glb_cdcritic = 0.
            
            IF  aux_flgsnura    THEN
                DO:
                    IF  tt-dados-ura.cdsitsnh <> 1  THEN  /* ATIVO */
                        DO:
                            glb_cdcritic = 14.
                            RUN fontes/critic.p.
                            BELL.
                            MESSAGE glb_dscritic.
                            NEXT.
                        END.
                END.

            DO WHILE TRUE:

               IF   glb_cdcritic > 0    THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                    END.

               ASSIGN aux_cdcooper = SUBSTR(STRING(glb_cdcooper,
                                                   "99"),1,2).
                 
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               
                  /* Aviso p/ Digitos da Cooperativa */
                  PAUSE 0.
            
                  DISPLAY "DUAS PRIMEIRAS POSICOES NUMERICAS DEVEM SER" aux_cdcooper 
                          WITH ROW 18 NO-LABEL
                          CENTERED OVERLAY COLOR MESSAGE FRAME f_sem_volta.

                  IF    glb_cdcritic > 0    THEN
                        DO:
                            RUN fontes/critic.p.
                            BELL.
                            MESSAGE glb_dscritic.
                            glb_cdcritic = 0.
                        END.
                          
                  FIND FIRST tt-erro NO-LOCK NO-ERROR.

                  IF    AVAILABLE tt-erro   THEN
                        DO:                                                                    
                            MESSAGE tt-erro.dscritic.
                        END.

                  UPDATE aux_cdsenha1 WITH FRAME f_alt_senha
                     
                     EDITING:
          
                         DO WHILE TRUE:
                 
                            READKEY PAUSE 1.
          
                            IF   FRAME-FIELD = "aux_cdsenha1"  THEN
                                 IF   NOT CAN-DO("0,1,2,3,4,5,6,7,8,9,RETURN,TAB,"
                                                  + "BACKSPACE,DELETE-CHARACTER,"
                                                  + "BACK-TAB,CURSOR-LEFT," +
                                                  "END-ERROR,HELP",
                                                  KEYFUNCTION(LASTKEY))  THEN
                                 
                                 LEAVE.
     
                            APPLY LASTKEY.
                
                            LEAVE. 
    
                         END. /* FIM DO WHILE */
          
                     END. /* FIM DO EDITING */
                 
                  UPDATE aux_cdsenha2 WITH FRAME f_alt_senha.

                  RUN valida_senha_ura IN h-b1wgen0015(INPUT glb_cdcooper,
                                                       INPUT glb_cdagenci,
                                                       INPUT 0,
                                                       INPUT aux_cdsenha1,
                                                       INPUT aux_cdsenha2,
                                                      OUTPUT TABLE tt-erro).

                  IF   RETURN-VALUE <> "OK" THEN
                       DO:
                            NEXT-PROMPT aux_cdsenha1 WITH FRAME f_alt_senha.                                    
                            NEXT.
                       END.       
                  
                  LEAVE.
                    
               END. /* end do do while */
                                            
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                    DO:
                        HIDE FRAME f_sem_volta.
                        LEAVE.
                    END.

               HIDE FRAME f_sem_volta.

               LEAVE.
                
            END.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                 NEXT.                      

            IF  aux_flgsnura = FALSE   THEN
                DO:
                    RUN cria_senha_ura IN h-b1wgen0015(INPUT glb_cdcooper,
                                                       INPUT glb_cdagenci,
                                                       INPUT 0, /* nrdcaixa */
                                                       INPUT tel_nrdconta,
                                                       INPUT aux_cdsenha1,
                                                       INPUT glb_dtmvtolt,
                                                       INPUT glb_cdoperad,
                                                      OUTPUT TABLE tt-erro).

                    IF  RETURN-VALUE <> "OK"   THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.

                            IF  AVAILABLE tt-erro   THEN
                                DO:
                                    MESSAGE tt-erro.dscritic.
                                    RETURN.
                                END.
                        END.
                END.
            ELSE
                DO:
                    RUN altera_senha_ura IN h-b1wgen0015(INPUT glb_cdcooper,
                                                         INPUT glb_cdagenci,
                                                         INPUT 0, /* nrdcaixa */
                                                         INPUT glb_cdoperad,
                                                         INPUT glb_nmdatela,
                                                         INPUT 1, /* idorigem */
                                                         INPUT tel_nrdconta,
                                                         INPUT 1, /* idseqttl */
                                                         INPUT aux_cdsenha1,
                                                         INPUT glb_dtmvtolt,
                                                        OUTPUT TABLE tt-erro).
                    IF  RETURN-VALUE <> "OK"   THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.

                            IF  AVAILABLE tt-erro   THEN
                                DO:
                                    MESSAGE tt-erro.dscritic.
                                    RETURN.
                                END.
                        END.
                END.               
        END.

   LEAVE.
                                                      
END.  /*  Fim do DO WHILE TRUE  */

HIDE MESSAGE NO-PAUSE. 
HIDE FRAME f_ura NO-PAUSE.
HIDE FRAME f_alt_senha NO-PAUSE.

DELETE PROCEDURE h-b1wgen0015.

/*...........................................................................*/

