/*..............................................................................

   Programa: Fontes/contas_bens.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Junho/2009                         Ultima Atualizacao: 30/07/2014

   Dados referentes ao programa:

   Frequencia: Diario(on-line).
   Objetivo  : Mostrar/Alterar os bens do cooperado.(Item BENS da tela CONTAS).

   Alteracoes: 02/03/2010 - Adaptacao para usar BO (Jose Luis, DB1).
   
               23/07/2010 - Utilizar a includes dos bens (Gabriel).
               
               25/10/2010 - Bloqueia edição em conta filha (Gabriel, DB1).
               
               08/08/2013 - Bloqueio do char ";" no cadastro dos bens 
                            (Carlos) SD 79803 e 84539
               
               08/04/2014 - Ajuste "WHOLE-INDEX" na leitura da tt-crapbem
                           (Adriano).

               30/07/2014 - Bloqueio do char "|" no cadastro dos bens 
                            (Jorge) - SD 183551
..............................................................................*/

{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_contas.i }
{ includes/var_bens.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }


ASSIGN glb_cddopcao = "I".

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   IF  NOT VALID-HANDLE(h-b1wgen0056) THEN
       RUN sistema/generico/procedures/b1wgen0056.p 
           PERSISTENT SET h-b1wgen0056.

   ASSIGN glb_nmrotina = "BENS".
   
   DISPLAY reg_dsdopcao WITH FRAME f_regua.

   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.

   ASSIGN aux_nrdrowid = ?
          aux_idseqbem = 0
          glb_cddopcao = "C".

   RUN Busca-Dados.

   IF  RETURN-VALUE <> "OK" THEN
       NEXT.

   OPEN QUERY q-crapbem FOR EACH tt-crapbem 
                            WHERE tt-crapbem.cdcooper = glb_cdcooper NO-LOCK.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE b-crapbem WITH FRAME f_crapbem.  
      LEAVE.

   END.

   IF   KEY-FUNCTION(LASTKEY) = "END-ERROR"   OR
        KEY-FUNCTION(LASTKEY) = "GO"          THEN
        DO:
            HIDE FRAME f_crapbem.
            LEAVE.
        END.

   /* Deixa o browse visivel e marca a linha que tinha sido selecionada */
   VIEW FRAME f_crapbem.

   IF   aux_nrdlinha > 0   THEN
        REPOSITION q-crapbem TO ROW(aux_nrdlinha).

   /*Alteração: Mostra critica se usuario titular em outra conta 
    (Gabriel/DB1)*/
   IF  par_msgconta <> "" THEN
       DO:
          MESSAGE par_msgconta.
          NEXT.
       END.

   { includes/acesso.i }

   IF   glb_cddopcao = "I"   THEN
        DO:
           ASSIGN tel_dsrelbem = ""
                  tel_persemon = 0 
                  tel_qtprebem = 0
                  tel_vlprebem = 0
                  tel_vlrdobem = 0
                  aux_idseqbem = 0.

           FIND LAST tt-crapbem NO-ERROR.

           IF  AVAILABLE tt-crapbem   THEN
               ASSIGN aux_idseqbem = tt-crapbem.idseqbem + 1.
           
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE: 
              
              UPDATE tel_dsrelbem
                     tel_persemon
                     tel_qtprebem
                     tel_vlprebem
                     tel_vlrdobem WITH FRAME f_altera

              EDITING:

                READKEY.
                
                IF LASTKEY = KEYCODE(";") OR
                   LASTKEY = KEYCODE("|") THEN
                    NEXT.

                HIDE MESSAGE NO-PAUSE.

                APPLY LASTKEY.

              END.

              RUN Valida_Dados.

              IF  RETURN-VALUE <> "OK" THEN
                  NEXT.
              
              LEAVE.
                   
           END.        

           ASSIGN tel_dsrelbem = CAPS(tel_dsrelbem).
            
           DISPLAY tel_dsrelbem WITH FRAME f_altera. 

           PAUSE 0.
           
           IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                NEXT.
                
           RUN fontes/confirma.p (INPUT "",
                                  OUTPUT aux_confirma).
            
           IF  aux_confirma <> "S"   THEN
               NEXT.

           IF  VALID-HANDLE (h-b1wgen0056)  THEN
               DELETE OBJECT h-b1wgen0056.

           RUN sistema/generico/procedures/b1wgen0056.p 
               PERSISTENT SET h-b1wgen0056.

           IF   VALID-HANDLE (h-b1wgen0056)  THEN
                DO:
                    ASSIGN aux_msgalert = "".
                    RUN inclui-registro IN h-b1wgen0056 
                        ( INPUT glb_cdcooper,
                          INPUT glb_cdagenci,
                          INPUT 0,
                          INPUT tel_nrdconta,
                          INPUT tel_idseqttl,
                          INPUT glb_cdoperad,
                          INPUT glb_nmdatela,
                          INPUT 1,
                          INPUT YES,
                          INPUT tel_dsrelbem,
                          INPUT ?,
                          INPUT glb_dtmvtolt,
                          INPUT glb_cddopcao,
                          INPUT tel_persemon,
                          INPUT tel_qtprebem,
                          INPUT tel_vlprebem,
                          INPUT tel_vlrdobem,
                         OUTPUT aux_msgalert,
                         OUTPUT aux_tpatlcad,
                         OUTPUT aux_msgatcad,
                         OUTPUT aux_chavealt,
                         OUTPUT aux_msgrvcad,
                         OUTPUT TABLE tt-erro).
                    
                    IF   RETURN-VALUE <> "OK"   THEN
                         DO:
                             RUN Mostra_Erro.
                             NEXT.
                         END.
                
                    IF   aux_msgalert <> "" THEN
                         DO:
                            MESSAGE aux_msgalert.
                            PAUSE 3 NO-MESSAGE.
                            HIDE MESSAGE NO-PAUSE.
                         END.

                    /* verificar se é necessario registrar o crapalt */
                    RUN proc_altcad (INPUT "b1wgen0056.p").
                    
                    DELETE OBJECT h-b1wgen0056.

                    IF  aux_msgrvcad <> "" THEN
                        MESSAGE aux_msgrvcad.

                    IF  RETURN-VALUE <> "OK" THEN
                        NEXT.

                END.

        END. /* Fim da opcao I */
   ELSE
   IF   glb_cddopcao = "A"   THEN
        DO:
           IF   NOT AVAILABLE tt-crapbem   THEN
                NEXT.

           ASSIGN tel_dsrelbem = tt-crapbem.dsrelbem
                  tel_persemon = tt-crapbem.persemon
                  tel_qtprebem = tt-crapbem.qtprebem
                  tel_vlprebem = tt-crapbem.vlprebem
                  tel_vlrdobem = tt-crapbem.vlrdobem
                  aux_idseqbem = tt-crapbem.idseqbem
                  aux_nrdrowid = tt-crapbem.nrdrowid.
                
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE: 
              
            UPDATE tel_dsrelbem 
                   tel_persemon
                   tel_qtprebem
                   tel_vlprebem
                   tel_vlrdobem 
                   WITH FRAME f_altera
            EDITING:
                
                READKEY.
                
                IF LASTKEY = KEYCODE(";") OR
                   LASTKEY = KEYCODE("|") THEN
                    NEXT.

                HIDE MESSAGE NO-PAUSE.

                APPLY LASTKEY.
            END.
             
             ASSIGN tel_dsrelbem = REPLACE(tel_dsrelbem, ";", ",")
                    tel_dsrelbem = REPLACE(tel_dsrelbem, "|", "-").

             RUN Valida_Dados.

             IF  RETURN-VALUE <> "OK"  THEN
                 NEXT.

             LEAVE.
                  
           END.        

           IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                NEXT.
                
           tel_dsrelbem = CAPS(tel_dsrelbem).
           
           DISPLAY tel_dsrelbem WITH FRAME f_altera.
           
           RUN fontes/confirma.p (INPUT "",
                                  OUTPUT aux_confirma).
            
           IF   aux_confirma <> "S"   THEN
                NEXT.

           IF  VALID-HANDLE (h-b1wgen0056)  THEN
               DELETE OBJECT h-b1wgen0056.

           RUN sistema/generico/procedures/b1wgen0056.p 
               PERSISTENT SET h-b1wgen0056.

           IF   VALID-HANDLE(h-b1wgen0056)  THEN
                DO: 
                    ASSIGN aux_msgalert = "".
                    RUN altera-registro IN h-b1wgen0056 
                        ( INPUT glb_cdcooper,
                          INPUT glb_cdagenci,
                          INPUT 0,
                          INPUT tel_nrdconta,
                          INPUT tel_idseqttl,
                          INPUT glb_cdoperad,
                          INPUT glb_nmdatela,
                          INPUT 1,
                          INPUT YES,
                          INPUT aux_nrdrowid,
                          INPUT tel_dsrelbem,
                          INPUT glb_dtmvtolt,
                          INPUT glb_dtmvtolt,
                          INPUT glb_cddopcao,
                          INPUT tel_persemon,
                          INPUT tel_qtprebem,
                          INPUT tel_vlprebem,
                          INPUT tel_vlrdobem,
                          INPUT aux_idseqbem,
                         OUTPUT aux_msgalert,
                         OUTPUT aux_tpatlcad,
                         OUTPUT aux_msgatcad,
                         OUTPUT aux_chavealt,
                         OUTPUT aux_msgrvcad,
                         OUTPUT TABLE tt-erro).
                    
                    IF   RETURN-VALUE <> "OK"   THEN
                         DO:
                             RUN Mostra_Erro.
                             NEXT.
                         END.

                    IF   aux_msgalert <> "" THEN
                         DO:
                            MESSAGE aux_msgalert.
                            PAUSE 3 NO-MESSAGE.
                            HIDE MESSAGE NO-PAUSE.
                         END.

                    /* verificar se é necessario registrar o crapalt */
                    RUN proc_altcad (INPUT "b1wgen0056.p").

                    DELETE OBJECT h-b1wgen0056.
                    
                    IF  aux_msgrvcad <> "" THEN
                        MESSAGE aux_msgrvcad.

                    IF  RETURN-VALUE <> "OK" THEN
                        NEXT.
                END.

        END. /* Fim da Opcao A */
   ELSE
   IF   glb_cddopcao = "E"   THEN
        DO:
            IF  NOT AVAILABLE tt-crapbem   THEN
                NEXT.

            ASSIGN 
                aux_nrdrowid = tt-crapbem.nrdrowid
                aux_idseqbem = tt-crapbem.idseqbem.

            /* mostrar os dados antes da exclusao */
            DISPLAY 
                tt-crapbem.dsrelbem @ tel_dsrelbem
                tt-crapbem.persemon @ tel_persemon
                tt-crapbem.qtprebem @ tel_qtprebem
                tt-crapbem.vlprebem @ tel_vlprebem
                tt-crapbem.vlrdobem @ tel_vlrdobem
                WITH FRAME f_altera.

            RUN Valida_Dados.

            IF  RETURN-VALUE <> "OK" THEN
                NEXT.
            
            RUN fontes/confirma.p (INPUT "",
                                   OUTPUT aux_confirma).
            
            IF  aux_confirma <> "S" THEN
                NEXT.
            
            IF  VALID-HANDLE (h-b1wgen0056)  THEN
                DELETE OBJECT h-b1wgen0056.

            RUN sistema/generico/procedures/b1wgen0056.p 
                PERSISTENT SET h-b1wgen0056.

            IF   VALID-HANDLE(h-b1wgen0056)  THEN
                 DO:
                     RUN exclui-registro IN h-b1wgen0056 
                         ( INPUT glb_cdcooper,
                           INPUT glb_cdagenci,  
                           INPUT 0,
                           INPUT glb_cdoperad,
                           INPUT tel_nrdconta,
                           INPUT tel_idseqttl,
                           INPUT aux_nrdrowid,
                           INPUT aux_idseqbem,
                           INPUT glb_nmdatela,
                           INPUT 1,
                           INPUT YES,
                           INPUT glb_dtmvtolt,
                           INPUT glb_cddopcao,
                          OUTPUT aux_msgalert,
                          OUTPUT aux_tpatlcad,
                          OUTPUT aux_msgatcad,
                          OUTPUT aux_chavealt,
                          OUTPUT aux_msgrvcad,
                          OUTPUT TABLE tt-erro).
                     
                     IF   RETURN-VALUE <> "OK"   THEN
                          DO:
                              RUN Mostra_Erro.
                              NEXT.
                          END.

                     IF   aux_msgalert <> "" THEN
                          DO:
                             MESSAGE aux_msgalert.
                             PAUSE 3 NO-MESSAGE.
                             HIDE MESSAGE NO-PAUSE.
                          END.

                     /* verificar se é necessario registrar o crapalt */
                     RUN proc_altcad (INPUT "b1wgen0056.p").

                     DELETE OBJECT h-b1wgen0056.

                     IF  aux_msgrvcad <> "" THEN
                         MESSAGE aux_msgrvcad.

                     IF  RETURN-VALUE <> "OK" THEN
                         NEXT.
                 END.

        END. /* Fim da Opcao E */


END. /* Fim do DO WHILE TRUE */

IF  VALID-HANDLE(h-b1wgen0056) THEN
    DELETE PROCEDURE h-b1wgen0056.


PROCEDURE Busca-Dados.

   RUN Busca-Dados IN h-b1wgen0056 
       ( INPUT glb_cdcooper,
         INPUT glb_cdagenci,
         INPUT 0,
         INPUT glb_cdoperad,
         INPUT tel_nrdconta,
         INPUT 1,
         INPUT glb_nmdatela,
         INPUT tel_idseqttl,
         INPUT YES,
         INPUT aux_idseqbem,
         INPUT glb_cddopcao,
         INPUT aux_nrdrowid,
        OUTPUT par_msgconta,
        OUTPUT TABLE tt-crapbem,
        OUTPUT TABLE tt-erro ).

   IF  RETURN-VALUE <> "OK" THEN
       DO:
          FIND FIRST tt-erro NO-ERROR.

          IF  AVAILABLE tt-erro THEN
              DO:
                 MESSAGE tt-erro.dscritic.
                 RETURN "NOK".
              END.
       END.

END PROCEDURE.

PROCEDURE Valida_Dados.

   RUN Valida-Dados IN h-b1wgen0056 
       ( INPUT glb_cdcooper,
         INPUT glb_cdagenci,
         INPUT 0,
         INPUT tel_nrdconta,
         INPUT 1,
         INPUT glb_nmdatela,
         INPUT tel_idseqttl,
         INPUT glb_cdoperad,
         INPUT glb_cddopcao,
         INPUT tel_dsrelbem,
         INPUT tel_persemon,
         INPUT tel_qtprebem,
         INPUT tel_vlprebem,
         INPUT tel_vlrdobem,
         INPUT aux_idseqbem,
        OUTPUT TABLE tt-erro ).

   IF  RETURN-VALUE <> "OK" THEN
       DO:
          FIND FIRST tt-erro NO-ERROR.

          IF  AVAILABLE tt-erro THEN
              DO:
                 MESSAGE tt-erro.dscritic.
                 RETURN "NOK".
              END.
       END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Mostra_Erro.

    FIND FIRST tt-erro NO-ERROR.

    IF   AVAILABLE tt-erro THEN
         DO:
            MESSAGE tt-erro.dscritic.
         END.

END PROCEDURE.

/*............................................................................*/
