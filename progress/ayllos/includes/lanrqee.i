/* .............................................................................

   Programa: Includes/lanrqee.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Planner
   Data    : Agosto/2000.                       Ultima atualizacao: 15/04/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela LANRQE.

   Alteracoes: 041/087/2003 - Buscar da tabela a c/c do Bco. do Brasil (Edson)

               20/12/2005   - Exclusao dos tratamentos para requisicoes BANCOOB
                              (Julio)
               01/02/2006   - Unificacao dos Bancos - SQLWorks - Fernando.
               
               15/04/2013 - Retirado o tratamento de contas BB "aux_lsconta3"
                            (Adriano).
                            
............................................................................. */

INICIO:

DO WHILE TRUE:

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      SET tel_nrdctabb 
          tel_tprequis 
          WITH FRAME f_lanrqe.

      ASSIGN aux_cddopcao = glb_cddopcao
             aux_nrdctabb = tel_nrdctabb
             aux_tprequis = tel_tprequis
             glb_nrcalcul = tel_nrdctabb
             glb_cdcritic = 0.

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
             ASSIGN glb_cddopcao = aux_cddopcao
                    tel_nrdctabb = aux_nrdctabb
                    tel_tprequis = aux_tprequis.

             MESSAGE glb_dscritic.
             DISPLAY glb_cddopcao 
                     tel_nrdctabb 
                     tel_tprequis
                     WITH FRAME f_lanrqe.

             NEXT.

         END.

      LEAVE.

   END.

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
      LEAVE.   /* Volta pedir a opcao para o operador */

   TRANS_1:

   DO TRANSACTION ON ERROR UNDO TRANS_1, NEXT INICIO:

      ASSIGN glb_cdcritic = 0.

      DO WHILE TRUE:

         FIND craptrq WHERE craptrq.cdcooper = glb_cdcooper AND
                            craptrq.tprequis = 9            AND
                            craptrq.nrdolote = 99
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF NOT AVAILABLE craptrq   THEN
            IF LOCKED craptrq   THEN
               DO:
                   PAUSE 1 NO-MESSAGE.
                   NEXT.
               END.
            ELSE
               DO:
                   ASSIGN glb_cdcritic = 63.
                   LEAVE.
               END.

         LEAVE.

      END.

      IF glb_cdcritic > 0 THEN
         DO:
             RUN fontes/critic.p.
             BELL.
             CLEAR FRAME f_lanrqe.
             ASSIGN glb_cddopcao = aux_cddopcao
                    tel_nrdctabb = aux_nrdctabb
                    tel_tprequis = aux_tprequis.

             MESSAGE glb_dscritic.
             DISPLAY glb_cddopcao 
                     tel_nrdctabb 
                     tel_tprequis
                     WITH FRAME f_lanrqe.

             NEXT.

         END.

      DO WHILE TRUE:

         FIND crapreq WHERE crapreq.cdcooper = glb_cdcooper   AND
                            crapreq.dtmvtolt = glb_dtmvtolt   AND
                            crapreq.tprequis = tel_tprequis   AND
                            crapreq.nrdolote = 99             AND
                            crapreq.nrdctabb = tel_nrdctabb   AND
                            crapreq.nrinichq = 0
                            USE-INDEX crapreq1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF NOT AVAILABLE crapreq   THEN
            IF LOCKED crapreq   THEN
               DO:
                   PAUSE 1 NO-MESSAGE.
                   NEXT.
               END.
            ELSE
               DO:
                   ASSIGN glb_cdcritic = 066.
                   LEAVE.

               END.

         LEAVE.

      END.

      IF glb_cdcritic = 0   THEN
         IF crapreq.insitreq <> 1 THEN
            glb_cdcritic = 113.

      IF glb_cdcritic > 0 THEN
         DO:
             RUN fontes/critic.p.
             BELL.
             CLEAR FRAME f_lanrqe.
             ASSIGN glb_cddopcao = aux_cddopcao
                    tel_nrdctabb = aux_nrdctabb
                    tel_tprequis = aux_tprequis.

             MESSAGE glb_dscritic.
             DISPLAY glb_cddopcao 
                     tel_nrdctabb 
                     tel_tprequis
                     WITH FRAME f_lanrqe.

             NEXT.

         END.

      ASSIGN tel_qtreqtal = crapreq.qtreqtal
             tel_nrseqdig = crapreq.nrseqdig.

      DISPLAY tel_tprequis 
              tel_qtreqtal 
              tel_nrseqdig 
              WITH FRAME f_lanrqe.

      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         ASSIGN glb_cdcritic = 078
                aux_confirma = "N".

         RUN fontes/critic.p.
         BELL.
         MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
         LEAVE.

      END.

      IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
         aux_confirma <> "S" THEN
         DO:
             ASSIGN glb_cdcritic = 079.
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             NEXT.

         END.

      ASSIGN glb_cdcritic = 0

             craptrq.qtinfotl = craptrq.qtinfotl - crapreq.qtreqtal
             craptrq.qtcomptl = craptrq.qtcomptl - crapreq.qtreqtal
             craptrq.qtcomprq = craptrq.qtcomprq - 1       
             craptrq.qtinforq = craptrq.qtinforq - 1
             craptrq.qtcompen = 0
             craptrq.qtinfoen = 0
             tel_qtinforq = craptrq.qtinforq
             tel_qtcomprq = craptrq.qtcomprq
             tel_qtinfotl = craptrq.qtinfotl
             tel_qtcomptl = craptrq.qtcomptl.

      DELETE crapreq.
     
      IF craptrq.qtinforq = 0   AND
         craptrq.qtcomprq = 0   AND
         craptrq.qtinfotl = 0   AND
         craptrq.qtcomptl = 0   AND
         craptrq.qtinfoen = 0   AND
         craptrq.qtcompen = 0   THEN
         DELETE craptrq.

   END.    /* Fim da transacao */

   RELEASE craptrq.

   IF glb_cdcritic <> 0   THEN
      NEXT.

   ASSIGN tel_reganter[6] = tel_reganter[5]
          tel_reganter[5] = tel_reganter[4]
          tel_reganter[4] = tel_reganter[3]
          tel_reganter[3] = tel_reganter[2]
          tel_reganter[2] = tel_reganter[1]
          tel_reganter[1] =
              STRING(tel_nrdctabb,"zzzz,zzz,9") + "        "      +
              STRING(tel_tprequis,"9")          + "            "  +
              STRING(tel_qtreqtal,"zz9")         + "      "       +
              STRING(tel_nrseqdig,"zz,zz9")
          tel_nrdctabb = 0
          tel_tprequis = 0
          tel_qtreqtal = 0
          tel_nrseqdig = 0.

   DISPLAY tel_qtinforq 
           tel_qtcomprq
           tel_qtinfotl 
           tel_qtcomptl
           tel_nrdctabb 
           tel_tprequis 
           tel_qtreqtal 
           tel_nrseqdig
           WITH FRAME f_lanrqe.

   HIDE FRAME f_lanctos.

   DISPLAY tel_reganter[1] 
           tel_reganter[2] 
           tel_reganter[3]
           tel_reganter[4] 
           tel_reganter[5] 
           tel_reganter[6]
           WITH FRAME f_regant.

END.

/* .......................................................................... */

