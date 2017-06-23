/* .............................................................................

   Programa: Includes/lanrqec.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Planner
   Data    : Agosto/2000.                       Ultima alteracao: 18/05/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela LANRQE.

   Alteracoes: 15/07/2003 - Substituido o Nro de conta fixo do Banco do Brasil,
                            pela variavel aux_lsconta3, setada no 
                            lanrqe.p (Julio).

               20/12/2005 - Exclusao dos tratamentos para requisicoes BANCOOB
                            (Julio)

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               15/04/2013 - Retirado tratamento de contas BB "aux_lsconta3"
                            (Adriano).
               
               18/05/2017 - Retirar glb_cddopcao do form f_lanrqe (Lucas Ranghetti #646559)
............................................................................. */

DO WHILE TRUE:

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      SET tel_nrdctabb 
          tel_tprequis 
          WITH FRAME f_lanrqe.

      ASSIGN aux_nrdconta = tel_nrdctabb
             aux_tprequis = tel_tprequis
             glb_nrcalcul = tel_nrdctabb
             glb_cdcritic = 0.
      
      IF tel_nrdctabb = 0 OR tel_tprequis = 0  THEN
         LEAVE.
          
      RUN fontes/digfun.p.

      IF NOT glb_stsnrcal THEN
         DO:
             ASSIGN glb_cdcritic = 8.
             NEXT-PROMPT tel_nrdctabb WITH FRAME f_lanrqe.
         END.
      ELSE 
         DO:
            FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                               crapass.nrdconta = tel_nrdctabb
                               NO-LOCK NO-ERROR.
         
            IF NOT AVAILABLE crapass   THEN
               DO:
                   ASSIGN glb_cdcritic = 9.
                   NEXT-PROMPT tel_nrdctabb WITH FRAME f_lanrqe.
                END.
            
         END.
          
      IF glb_cdcritic > 0 THEN
         DO:
             RUN fontes/critic.p.
             BELL.
             CLEAR FRAME f_lanrqe.
             ASSIGN tel_nrdctabb = aux_nrdconta
                    tel_tprequis = aux_tprequis.

             MESSAGE glb_dscritic.
             DISPLAY tel_nrdctabb 
                     tel_tprequis
                     WITH FRAME f_lanrqe.

             NEXT.

         END.

      LEAVE.

   END.

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
      RETURN.   /* Volta pedir a opcao para o operador */

   FIND craptrq WHERE craptrq.cdcooper = glb_cdcooper AND
                      craptrq.tprequis = 9            AND
                      craptrq.nrdolote = 99  
                      NO-LOCK NO-ERROR.

   IF NOT AVAILABLE craptrq   THEN
      DO:
          ASSIGN glb_cdcritic = 60.
          RUN fontes/critic.p.
          BELL.
          CLEAR FRAME f_lanrqe NO-PAUSE.

          ASSIGN tel_nrdctabb = aux_nrdconta
                 tel_tprequis = aux_tprequis.

          DISPLAY tel_nrdctabb  
                  tel_tprequis
                  WITH FRAME f_lanrqe.

          MESSAGE glb_dscritic.
          NEXT.

      END.

   ASSIGN tel_qtinforq = craptrq.qtinforq
          tel_qtcomprq = craptrq.qtcomprq
          tel_qtinfotl = craptrq.qtinfotl
          tel_qtcomptl = craptrq.qtcomptl.

   IF tel_nrdctabb = 0   THEN
      DO:
          ASSIGN aux_flgerros = FALSE
                 aux_flgretor = FALSE
                 aux_regexist = FALSE
                 aux_contador = 0.

          /* SUBSTITUICAO AO PUT SCREEN */
          CLEAR FRAME f_lanrqe.
          HIDE FRAME f_regant.
          CLEAR FRAME f_lanctos ALL NO-PAUSE.
          /**********/

          DISPLAY tel_qtinforq 
                  tel_qtcomprq 
                  tel_qtinfotl 
                  tel_qtcomptl 
                  WITH FRAME f_lanrqe.
          /****
          PUT SCREEN ROW 13 COLUMN 11 FILL (" ",60).
          HIDE FRAME f_regant.
          CLEAR FRAME f_lanctos ALL NO-PAUSE.
          *****/
          FOR EACH crapreq WHERE crapreq.cdcooper = glb_cdcooper AND
                                 crapreq.dtmvtolt = glb_dtmvtolt AND
                                 crapreq.nrdolote = 99 
                                 NO-LOCK BY crapreq.nrseqdig:

              ASSIGN aux_regexist = TRUE
                     aux_contador = aux_contador + 1.

              IF aux_contador = 1   THEN
                 IF aux_flgretor   THEN
                    DO:
                        PAUSE MESSAGE
                        "Tecle <Entra> para continuar ou <Fim> para encerrar".
                        CLEAR FRAME f_lanctos ALL NO-PAUSE.
                    END.
                 ELSE
                    ASSIGN aux_flgretor = TRUE.

              PAUSE(0).

              DISPLAY crapreq.nrdctabb 
                      crapreq.tprequis 
                      crapreq.qtreqtal  
                      crapreq.nrseqdig
                      WITH FRAME f_lanctos.

              IF aux_contador = 7   THEN
                 aux_contador = 0.
              ELSE
                 DOWN WITH FRAME f_lanctos.

          END.

          IF NOT aux_regexist   THEN
             ASSIGN glb_cdcritic = 11.

          IF glb_cdcritic > 0   THEN
             DO:
                 RUN fontes/critic.p.
                 BELL.
                 CLEAR FRAME f_lanrqe NO-PAUSE.

                 ASSIGN tel_nrdctabb = aux_nrdconta
                        tel_tprequis = aux_tprequis.

                 DISPLAY tel_nrdctabb  
                         tel_tprequis
                         WITH FRAME f_lanrqe.

                 MESSAGE glb_dscritic.
                 NEXT.

             END.

          NEXT.

      END.

   FIND crapreq WHERE crapreq.cdcooper = glb_cdcooper   AND
                      crapreq.dtmvtolt = glb_dtmvtolt   AND
                      crapreq.tprequis = tel_tprequis   AND
                      crapreq.nrdolote = 99             AND
                      crapreq.nrdctabb = tel_nrdctabb   AND
                      crapreq.nrinichq = 0
                      USE-INDEX crapreq1 NO-LOCK NO-ERROR.

   IF NOT AVAILABLE crapreq   THEN
      DO:
          ASSIGN glb_cdcritic = 90.
          RUN fontes/critic.p.
          BELL.
          CLEAR FRAME f_lanrqe NO-PAUSE.

          ASSIGN tel_nrdctabb = aux_nrdconta
                 tel_tprequis = aux_tprequis.

          DISPLAY tel_nrdctabb  
                  tel_tprequis
                  WITH FRAME f_lanrqe.

          MESSAGE glb_dscritic.
          NEXT.

      END.

   ASSIGN tel_nrdctabb = crapreq.nrdctabb
          tel_tprequis = crapreq.tprequis
          tel_qtreqtal = crapreq.qtreqtal
          tel_nrseqdig = crapreq.nrseqdig.

   DISPLAY tel_qtinforq 
           tel_qtcomprq 
           tel_qtinfotl 
           tel_qtcomptl 
           tel_nrdctabb 
           tel_tprequis 
           tel_qtreqtal 
           tel_nrseqdig
           WITH FRAME f_lanrqe.

END.

/* .......................................................................... */

