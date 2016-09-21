/*..............................................................................
   Programa: Fontes/actcta.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Vitor
   Data    : Junho/2010                     Ultima Atualizacao:   

   Dados referentes ao programa:
   Frequencia : Diario (on-line)
   Objetivo   : Mostrar a tela actcta (Alterações de Contas).
   
   Alteracoes : 
..............................................................................*/
{  includes/var_online.i  }

DEF NEW SHARED VAR shr_cdcooper LIKE crapass.cdcooper                   NO-UNDO.

DEF   VAR  tel_cdcooper LIKE crapass.cdcooper                           NO-UNDO.
DEF   VAR  tel_nrdconta LIKE crapass.nrdconta                           NO-UNDO.
DEF   VAR  tel_nmprimtl LIKE crapass.nmprimtl                           NO-UNDO.
DEF   VAR  aux_cddopcao AS CHAR                                         NO-UNDO.
DEF   VAR  aux_confirma AS CHAR FORMAT "S/N" INITIAL YES                NO-UNDO.
DEF   VAR  aux_contador AS INTEGER                                      NO-UNDO.

DEF VAR aux_dadosusr         AS CHAR                            NO-UNDO.
DEF VAR par_loginusr         AS CHAR                            NO-UNDO.
DEF VAR par_nmusuari         AS CHAR                            NO-UNDO.
DEF VAR par_dsdevice         AS CHAR                            NO-UNDO.
DEF VAR par_dtconnec         AS CHAR                            NO-UNDO.
DEF VAR par_numipusr         AS CHAR                            NO-UNDO.

DEF VAR h-b1wgen9999         AS HANDLE                          NO-UNDO.

DEF BUFFER crabeca FOR crapeca.

DEF QUERY q-critica FOR crapeca.

DEF   BROWSE b-critica QUERY q-critica
      DISPLAY tparquiv COLUMN-LABEL "Tipo"
              dtretarq COLUMN-LABEL "Retorno Arquivo" 
              idseqttl COLUMN-LABEL "Titular"
              dscritic COLUMN-LABEL "Descricao" FORMAT "x(30)"
              WITH CENTERED 5  DOWN TITLE " Criticas da Conta ".

FORM WITH ROW 4 COLUMN 1 OVERLAY SIZE 80 BY 18 TITLE glb_tldatela 
     FRAME f_moldura.

FORM glb_cddopcao LABEL "Opcao" AUTO-RETURN
         HELP "Informe a opcao desejada (A/B)."
         VALIDATE (CAN-DO("A,B",glb_cddopcao), "014 - Opcao errada.")
     
     tel_cdcooper AT 11 LABEL "Cooperativa"  FORMAT "zz9" AUTO-RETURN
         HELP "Informe o numero da cooperativa ou F7 para pesquisar"
     
     tel_nrdconta AT 29 LABEL "Conta/dv" AUTO-RETURN
         HELP "Informe o numero da conta"
         WITH ROW 7 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_conta.

FORM SKIP tel_nmprimtl LABEL "Nome" FORMAT "x(25)" AUTO-RETURN
         WITH ROW 8 COLUMN 30 SIDE-LABELS OVERLAY NO-BOX FRAME f_primtl.

FORM crapttl.nmextttl COLUMN-LABEL "Titulares da conta" FORMAT "x(40)"
     crapass.cdtipcta COLUMN-LABEL "Tipo" 
     crapass.dtadmiss COLUMN-LABEL "Admissao"
     crapass.dtdemiss COLUMN-LABEL "Demissao"
     crapass.dtelimin COLUMN-LABEL "Eliminacao" 
     WITH 8 DOWN ROW 10 COLUMN 2 OVERLAY NO-BOX FRAME f_dependentes.

FORM SKIP
     b-critica HELP "Tecle F1 para continuar ou F4 para sair"
     WITH NO-BOX ROW 10 WIDTH 68 SIDE-LABELS OVERLAY CENTERED FRAME f_query.

VIEW FRAME f_moldura.
PAUSE 0.

ASSIGN glb_cddopcao = "B"
       glb_cdcritic =  0.

DO WHILE TRUE:
    
    RUN fontes/inicia.p.

    CLEAR FRAME f_dependentes ALL NO-PAUSE.

    HIDE FRAME f_dependentes.
    HIDE FRAME f_primtl.
    HIDE FRAME f_query NO-PAUSE. 

    IF   glb_cdcritic > 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       UPDATE glb_cddopcao WITH FRAME f_conta.
       LEAVE.
    END.

    IF   KEYFUNCTION (LASTKEY) = "END-ERROR"   THEN      /* F4 ou Fim  */
         DO:          
             RUN fontes/novatela.p.
             
             IF CAPS(glb_nmdatela) <> "ACTCTA"   THEN
                 DO:
                   HIDE FRAME f_opcao.
                   RETURN.
                 END.
             ELSE 
                 NEXT.
         END.
      
    IF   aux_cddopcao <> glb_cddopcao   THEN
         DO:
              { includes/acesso.i }
               aux_cddopcao = glb_cddopcao.
         END.
         
    IF  glb_cdcooper <> 3 THEN 
        DO:
           ASSIGN glb_cdcritic = 327.
           NEXT.
        END.

     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
     
         ASSIGN tel_cdcooper = 0
                tel_nrdconta = 0
                tel_nmprimtl = "".
     
         UPDATE tel_cdcooper  
                tel_nrdconta  WITH FRAME f_conta
     
         EDITING:
           READKEY.
            IF   FRAME-FIELD = "tel_cdcooper"  THEN
                DO:
                  IF   LASTKEY = KEYCODE("F7")  THEN
                      DO:
                        RUN fontes/zoom_cooper.p (OUTPUT tel_cdcooper).
                        DISPLAY tel_cdcooper WITH FRAME f_conta.
                      END.
                  ELSE
                      APPLY LASTKEY.
                END.
            ELSE
                APPLY LASTKEY.
         END.
       LEAVE.
     END.
     
     FIND crapass WHERE crapass.cdcooper = tel_cdcooper AND
                        crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.
     
     IF NOT AVAILABLE crapass THEN
         DO:
           glb_cdcritic = 9.
           NEXT.
         END.
     
/*OPÇÃO "A":*/
     IF   glb_cddopcao =  "A"   THEN 
         DO:
            IF crapass.dtelimin = ? THEN
       DO:
          MESSAGE "Conta" tel_nrdconta "ja e' ativa".
          NEXT.
       END.

            ASSIGN tel_nmprimtl = crapass.nmprimtl.
     
            DISPLAY tel_nmprimtl WITH FRAME f_primtl.
            
                IF crapass.inpessoa = 1 THEN
                   DO:
                       FOR EACH crapttl WHERE crapttl.cdcooper = tel_cdcooper AND 
                                              crapttl.nrdconta = tel_nrdconta NO-LOCK:
        
                        DISPLAY crapttl.nmextttl 
                                crapass.cdtipcta
                                crapass.dtadmiss
                                crapass.dtdemiss 
                                crapass.dtelimin WITH FRAME f_dependentes.
                        
                        DOWN WITH FRAME f_dependentes.
                        END.
                   END.
     
                RUN fontes/confirma.p (INPUT "Confirma ativacao de conta?",OUTPUT aux_confirma).
                
                IF aux_confirma <> "S" THEN 
                    DO:
                       NEXT.
                    END.
        
                DO TRANSACTION:
                    DO aux_contador = 1 TO 10:
                        FIND crapass WHERE crapass.cdcooper = tel_cdcooper AND
                                           crapass.nrdconta = tel_nrdconta EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
     
                        IF NOT AVAILABLE crapass THEN
                            IF LOCKED crapass THEN
                                DO:
                                   glb_cdcritic = 77.
                                   PAUSE 1 NO-MESSAGE.
                                   NEXT.
                                END.
                        ELSE 
                            DO:
                               glb_cdcritic = 55.
                               LEAVE.
                            END.
        
                            glb_cdcritic = 0.
                            LEAVE.
                    END. /*DO aux_contador*/       

                 IF glb_cdcritic <> 0 THEN
                   NEXT.
     
                   ASSIGN crapass.dtelimin = ?.
                   MESSAGE "Ativacao da conta" tel_nrdconta "efetuada".
        
                   DO aux_contador = 1 TO 10:
                        FIND crapalt WHERE crapalt.cdcooper = tel_cdcooper  AND
                                           crapalt.nrdconta = tel_nrdconta  AND
                                           crapalt.dtaltera = glb_dtmvtolt
                                           USE-INDEX crapalt1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                        IF   NOT AVAILABLE crapalt   THEN
                            IF   LOCKED crapalt   THEN
                                DO:
                                   glb_cdcritic = 77.
                                   PAUSE 1 NO-MESSAGE.
                                   NEXT.
                                END.
                        ELSE
                            DO:
                               CREATE crapalt.
                               ASSIGN crapalt.cdcooper = tel_cdcooper
                                      crapalt.nrdconta = tel_nrdconta
                                      crapalt.dtaltera = glb_dtmvtolt.
                            END.
                        LEAVE.
                   END. /*DO aux_contador*/
                    
                   IF   glb_cdcritic <> 0   THEN
                    DO:
                       
                        RUN sistema/generico/procedures/b1wgen9999.p
                            PERSISTENT SET h-b1wgen9999.

                        RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crapalt),
                                                       INPUT "banco",
                                                       INPUT "crapalt",
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
                       
                    END.
        
                   IF NOT CAN-DO(crapalt.dsaltera,"Ativacao de conta efetuada")   THEN
                         ASSIGN crapalt.tpaltera = 2 /* alteracoes diversas */
                                crapalt.dsaltera = crapalt.dsaltera + "Ativacao de conta efetuada" + ","
                                crapalt.cdoperad = "996". /* fixo CECRED */
                END. /* DO TRANSACTION */
         END. /*  Fim OPÇÃO "A":  */
     ELSE
/* OPÇÃO "B": */
     IF glb_cddopcao =  "B" THEN
         DO:
            OPEN QUERY q-critica
                FOR EACH crapeca WHERE crapeca.cdcooper = tel_cdcooper AND
                                       crapeca.nrdconta = tel_nrdconta NO-LOCK.
                
                    IF NUM-RESULTS("q-critica") = 0 THEN
                        DO:
                           MESSAGE "Não há registros para esta Conta Integracao".
                           NEXT.
                        END.
                        
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        UPDATE b-critica WITH FRAME f_query.
                        LEAVE.
                    END.
     
                    IF   KEY-FUNCTION(LASTKEY) = "END-ERROR"   THEN 
                    NEXT.
                    
                    RUN fontes/confirma.p (INPUT "",OUTPUT aux_confirma).
                    
                    IF aux_confirma <> "S" THEN 
                        DO: 
                           NEXT.
                        END.

                    DO TRANSACTION:
                        FOR EACH crapeca WHERE crapeca.cdcooper = tel_cdcooper AND
                                               crapeca.nrdconta = tel_nrdconta NO-LOCK.
                            
                            DO aux_contador = 1 TO 10:
                                FIND crabeca WHERE crabeca.cdcooper = crapeca.cdcooper AND 
                                                   crabeca.tparquiv = crapeca.tparquiv AND
                                                   crabeca.nrdconta = crapeca.nrdconta AND
                                                   crabeca.nrseqarq = crapeca.nrseqarq AND
                                                   crabeca.nrdcampo = crapeca.nrdcampo 
                                                        EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                             
                               IF NOT AVAILABLE crabeca THEN
                                  IF LOCKED crabeca THEN
                                      DO:
                                          glb_cdcritic = 77.
                                          PAUSE 1 NO-MESSAGE.
                                          NEXT.
                                      END.
                     
                               glb_cdcritic = 0.
                               LEAVE.
                            END. /* aux_contador*/
          
                            IF glb_cdcritic <> 0 THEN 
                               UNDO,LEAVE.

                            DELETE crabeca.

                    END. /* DO TRANSACTION */
                    
                    MESSAGE "Registros de erro no cadastro da ITG eliminados".
                 
                    DO aux_contador = 1 TO 10:
                        FIND crapalt WHERE crapalt.cdcooper = tel_cdcooper  AND
                                           crapalt.nrdconta = tel_nrdconta  AND
                                           crapalt.dtaltera = glb_dtmvtolt
                                           USE-INDEX crapalt1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                        IF   NOT AVAILABLE crapalt   THEN
                            IF   LOCKED crapalt   THEN
                                DO:
                                   glb_cdcritic = 77.
                                   PAUSE 1 NO-MESSAGE.
                                   NEXT.
                                END.
                            ELSE
                                DO:
                                   CREATE crapalt.
                                   ASSIGN crapalt.cdcooper = tel_cdcooper
                                          crapalt.nrdconta = tel_nrdconta
                                          crapalt.dtaltera = glb_dtmvtolt.
                                END.
                 
                                ASSIGN glb_cdcritic = 0.
                        LEAVE.
                    END. /* aux_contador*/
              
                    IF glb_cdcritic <> 0 THEN
                        NEXT.
               
                    IF NOT CAN-DO(crapalt.dsaltera,"Registros de erro no cadastro da ITG eliminados")   
                       THEN
                         ASSIGN crapalt.tpaltera = 2 /* alteracoes diversas */
                                crapalt.dsaltera = crapalt.dsaltera + 
                                "Registros de erro no cadastro da ITG eliminados" + ","
                                crapalt.cdoperad = "996". /* fixo CECRED */
                END. /*for each crapeca*/
     END.  /* Fim OPÇÃO "B": */
END. /* DO WHILE TRUE */
