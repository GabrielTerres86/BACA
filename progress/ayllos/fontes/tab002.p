/* .............................................................................

   Programa: Fontes/tab002.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91                         Ultima Atualizacao: 22/11/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAB002.

   Alteracoes: 17/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               05/07/2005 - Alimentado campo cdcooper da tabela craptab (Diego).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               22/11/2011 - Adaptações para trabalhar com a B0130. (Lucas).
............................................................................. */

{ includes/var_online.i } 
{ sistema/generico/includes/var_internet.i }

DEF VAR tel_qtfolind AS INT     FORMAT "zz9"                         NO-UNDO.
DEF VAR tel_qtfolcjt AS INT     FORMAT "zz9"                         NO-UNDO.
DEF VAR aux_contador AS INT     FORMAT "z9"                          NO-UNDO.
DEF VAR aux_dsacesso AS CHAR    FORMAT "x(50)"                       NO-UNDO.
DEF VAR aux_confirma AS CHAR    FORMAT "!(1)"                        NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                         NO-UNDO.

DEF VAR h-b1wgen0130  AS HANDLE                                      NO-UNDO.

FORM SKIP (3)
     "Opcao:"     AT 4
     glb_cddopcao AT 11 NO-LABEL AUTO-RETURN
                  HELP "Entre com a opcao desejada (A, C, E ou I)"
                  VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                            glb_cddopcao = "E" OR glb_cddopcao = "I",
                            "014 - Opcao errada.")

     SKIP (3)
     tel_qtfolind AT 13 LABEL "Qtd. Folhas para Contas Individuais" AUTO-RETURN
                  HELP "Entre a quantidade de folhas para contas individuais."
                  VALIDATE(tel_qtfolind > 0,"026 - Quantidade errada.")

     SKIP (1)
     tel_qtfolcjt AT 13 LABEL "Qtd. Folhas para Contas Conjuntas  " AUTO-RETURN
                  HELP "Entre a quantidade de folhas para contas conjuntas."
                  VALIDATE(tel_qtfolcjt > 0,"026 - Quantidade errada.")

     SKIP(6)
     WITH SIDE-LABELS
     TITLE COLOR MESSAGE " Parametros p/Acompanhamento Talonarios "
           ROW 4 COLUMN 1 OVERLAY WIDTH 80 FRAME f_tab002.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

RUN fontes/inicia.p.

DO WHILE TRUE:

    CLEAR FRAME f_tab002.

    ASSIGN tel_qtfolind = 0
           tel_qtfolcjt = 0.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE glb_cddopcao WITH FRAME f_tab002.
        LEAVE.

    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF  CAPS(glb_nmdatela) <> "TAB002"   THEN
                DO:
                    HIDE FRAME f_tab002.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> INPUT glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = INPUT glb_cddopcao.
        END.

    IF  glb_cddopcao = "C" THEN
        DO:
            RUN sistema/generico/procedures/b1wgen0130.p 
                PERSISTENT SET h-b1wgen0130.
                    
            RUN busca_tab002 IN h-b1wgen0130 (INPUT glb_cdcooper,
                                              INPUT 0, /* Agencia*/
                                              INPUT 0, /* Caixa  */
                                              INPUT glb_cdoperad,
                                              INPUT glb_cddopcao,
                                              OUTPUT tel_qtfolind,
                                              OUTPUT tel_qtfolcjt,
                                              OUTPUT TABLE tt-erro).
                
            DELETE PROCEDURE h-b1wgen0130.
                
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  AVAILABLE tt-erro  THEN
                        MESSAGE tt-erro.dscritic.

                    NEXT.
                END.

            DISPLAY tel_qtfolind tel_qtfolcjt WITH FRAME f_tab002.
        END.
    ELSE
    IF  glb_cddopcao = "A" THEN
        DO:
            RUN sistema/generico/procedures/b1wgen0130.p 
                PERSISTENT SET h-b1wgen0130.
                            
            RUN busca_tab002 IN h-b1wgen0130 (INPUT glb_cdcooper,
                                              INPUT 0, /* Agencia*/
                                              INPUT 0, /* Caixa  */
                                              INPUT glb_cdoperad,
                                              INPUT glb_cddopcao,
                                              OUTPUT tel_qtfolind,
                                              OUTPUT tel_qtfolcjt,
                                              OUTPUT TABLE tt-erro).
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    IF  AVAILABLE tt-erro  THEN
                        MESSAGE tt-erro.dscritic.

                    DELETE PROCEDURE h-b1wgen0130.
                    NEXT.
                END. 

            UPDATE tel_qtfolind tel_qtfolcjt WITH FRAME f_tab002
                
                EDITING:
                     READKEY PAUSE 1.
             
                    IF (KEYFUNCTION(LASTKEY) = "END-ERROR") THEN
                        DELETE PROCEDURE h-b1wgen0130.

                    APPLY LASTKEY.
                END. 

            ASSIGN aux_confirma = "N".
            RUN fontes/confirma.p (INPUT  "",
                                   OUTPUT aux_confirma).

            IF  aux_confirma = "S" THEN
                DO:
                    RUN altera_tab002 IN h-b1wgen0130 (INPUT glb_cdcooper,
                                                       INPUT 0, /* Agencia*/
                                                       INPUT 0, /* Caixa  */
                                                       INPUT glb_cdoperad,
                                                       INPUT "tab002",
                                                       INPUT 1, /* Ayllos */
                                                       INPUT glb_dtmvtolt, 
                                                       INPUT TRUE, /* Gerar log */
                                                       INPUT glb_dsdepart,
                                                       INPUT tel_qtfolind,
                                                       INPUT tel_qtfolcjt,
                                                       OUTPUT TABLE tt-erro).
                    DELETE PROCEDURE h-b1wgen0130.
             
                    IF  RETURN-VALUE = "NOK"  THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                      
                            IF  AVAILABLE tt-erro  THEN
                                MESSAGE tt-erro.dscritic.
                            NEXT.
                        END.
                END.
            ELSE
                DO:
                    DELETE PROCEDURE h-b1wgen0130.
                    NEXT.
                END.

        END. 
    ELSE
    IF  glb_cddopcao = "E"   THEN
        DO:
            RUN sistema/generico/procedures/b1wgen0130.p 
                PERSISTENT SET h-b1wgen0130.
                            
            RUN busca_tab002 IN h-b1wgen0130 (INPUT glb_cdcooper,
                                              INPUT 0, /* Agencia*/
                                              INPUT 0, /* Caixa  */
                                              INPUT glb_cdoperad,
                                              INPUT glb_cddopcao,
                                              OUTPUT tel_qtfolind,
                                              OUTPUT tel_qtfolcjt,
                                              OUTPUT TABLE tt-erro).
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  AVAILABLE tt-erro  THEN
                        MESSAGE tt-erro.dscritic.

                    DELETE PROCEDURE h-b1wgen0130.
                    NEXT.
                END.

            DISPLAY tel_qtfolind tel_qtfolcjt WITH FRAME f_tab002.

            ASSIGN aux_confirma = "N".
            RUN fontes/confirma.p (INPUT  "",
                                   OUTPUT aux_confirma).

            IF  aux_confirma = "S" THEN
                DO:
                    RUN deleta_tab002 IN h-b1wgen0130 (INPUT glb_cdcooper,
                                                       INPUT 0, /* Agencia*/
                                                       INPUT 0, /* Caixa  */
                                                       INPUT glb_cdoperad,
                                                       INPUT "tab002",
                                                       INPUT 1, /* Ayllos */
                                                       INPUT glb_dtmvtolt, 
                                                       INPUT TRUE, /* Gerar log */
                                                       INPUT glb_dsdepart,
                                                       OUTPUT TABLE tt-erro).
                    
                    DELETE PROCEDURE h-b1wgen0130.
                    
                    IF  RETURN-VALUE = "NOK"  THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    
                            IF  AVAILABLE tt-erro  THEN
                                MESSAGE tt-erro.dscritic.
                            NEXT.
                    
                        END.

                    CLEAR FRAME f_tab002.
                END.
            ELSE
                DO:
                    DELETE PROCEDURE h-b1wgen0130.
                    NEXT.
                END.
        END. 
    ELSE
    IF  glb_cddopcao = "I"  THEN
        DO:  
            UPDATE tel_qtfolind tel_qtfolcjt WITH FRAME f_tab002. 

            ASSIGN aux_confirma = "N".
            RUN fontes/confirma.p (INPUT  "",
                                    OUTPUT aux_confirma).
             
            IF  aux_confirma = "S" THEN
                DO:
                    RUN sistema/generico/procedures/b1wgen0130.p 
                        PERSISTENT SET h-b1wgen0130.
                           
                    RUN cria_tab002 IN h-b1wgen0130 (INPUT glb_cdcooper,
                                                     INPUT 0, /* Agencia*/
                                                     INPUT 0, /* Caixa  */
                                                     INPUT glb_cdoperad,
                                                     INPUT "tab002",
                                                     INPUT 1, /* Ayllos */
                                                     INPUT glb_dtmvtolt, 
                                                     INPUT TRUE, /* Gerar log */
                                                     INPUT glb_dsdepart,
                                                     INPUT tel_qtfolind,
                                                     INPUT tel_qtfolcjt,
                                                     OUTPUT TABLE tt-erro).
                       
                    DELETE PROCEDURE h-b1wgen0130.
                    
                    IF  RETURN-VALUE = "NOK"  THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    
                            IF  AVAILABLE tt-erro  THEN
                                 MESSAGE tt-erro.dscritic.
                            NEXT.
                    
                        END.
                END. 
        END.

END. /* DO WHILE TRUE ON ENDKEY UNDO */

/* .......................................................................... */
