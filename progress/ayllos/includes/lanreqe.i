/* .............................................................................

   Programa: Includes/lanreqe.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Fevereiro/92.                   Ultima atualizacao: 08/02/2007

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela LANREQ.

   Alteracoes: 13/06/94 - Alterado para acessar a tabela de contas de convenio

               02/04/98 - Tratamento para milenio e troca para V8 (Magui).

               13/02/2003 - Usar agencia e numero do lote para separar
                            as agencias (Magui).

               17/03/2005 - Verificar se Conta Integracao(Mirtes)
               
               12/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
               
               02/11/2005 - Substituicao da condicao crapfdc.nrdctabb = 
                            tel_nrdctabb por crapfdc.nrdctitg = glb_dsdctitg
                            usando a procedure digbbx.p (SQLWorks - Andre).
                            
               07/12/2005 - Acertar leitura do crapfdc (Magui).            
                  
               04/01/2005 - Registrar operador da liberacao (Magui).     
               
               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               08/02/2007 - Modificacao do uso dos indices, adequacao ao
                            BANCOOB e uso de BOs (Evandro).

............................................................................ */

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      SET tel_nrctachq    tel_tprequis    tel_cdbanchq
          tel_nrinichq    WITH FRAME f_lanreq.

      ASSIGN aux_cddopcao = glb_cddopcao
             aux_nrdctabb = tel_nrctachq
             aux_tprequis = tel_tprequis
             aux_nrinichq = tel_nrinichq
             aux_cdagelot = tel_cdagelot
             aux_nrdolote = tel_nrdolote

             glb_nrcalcul = tel_nrctachq
             glb_cdcritic = 0.

      /* Verifica digito da conta */
      RUN fontes/digfun.p.
      IF   NOT glb_stsnrcal THEN
           DO:
               glb_cdcritic = 8.
               NEXT-PROMPT tel_nrctachq WITH FRAME f_lanreq.
           END.
      ELSE
           IF   tel_nrinichq = 0   THEN
                aux_nrinital = 0.
           ELSE
                DO:
                    /* Pode ser conta integracao */
                    ASSIGN aux_nrdconta = tel_nrctachq.
                    RUN fontes/digbbx.p (INPUT  tel_nrctachq,
                                         OUTPUT glb_dsdctitg,
                                         OUTPUT glb_stsnrcal).
                    IF NOT glb_stsnrcal THEN
                       DO:
                           glb_cdcritic = 8.
                           NEXT-PROMPT tel_nrinichq WITH FRAME f_lanreq.
                       END.

                    /* Verifica digito do cheque inicial */
                    ASSIGN glb_nrcalcul = tel_nrinichq.
                    RUN fontes/digfun.p.
                    IF   NOT glb_stsnrcal   THEN
                         DO:
                             glb_cdcritic = 8.
                             NEXT-PROMPT tel_nrinichq WITH FRAME f_lanreq.
                         END.
                    ELSE
                         DO:
                             /* Verifica se o cheque existe */
                             FIND crapfdc WHERE 
                                  crapfdc.cdcooper = glb_cdcooper   AND
                                  crapfdc.cdbanchq = tel_cdbanchq   AND
                                  crapfdc.cdagechq = tel_cdagechq   AND
                                  crapfdc.nrctachq = tel_nrctachq   AND
                                  crapfdc.nrcheque =
                                          INTE(SUBSTR(STRING(tel_nrinichq,
                                               "99999999"),1,7))
                                  USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
                          
                             IF   NOT AVAILABLE crapfdc   THEN
                                  DO:
                                      glb_cdcritic = 108.
                                      NEXT-PROMPT tel_nrinichq 
                                                      WITH FRAME f_lanreq.
                                  END.
                             ELSE
                             IF   crapfdc.tpcheque <> tel_tprequis   THEN
                                  DO:
                                      glb_cdcritic = 513.
                                      NEXT-PROMPT tel_nrinichq 
                                                  WITH FRAME f_lanreq.
                                  END.
                         END.
                END.

      FIND crapreq WHERE crapreq.cdcooper = glb_cdcooper        AND
                         crapreq.dtmvtolt = glb_dtmvtolt        AND
                         crapreq.cdagelot = tel_cdagelot        AND
                         crapreq.tprequis = tel_tprequis        AND
                         crapreq.nrdolote = tel_nrdolote        AND
                         crapreq.nrdctabb = INT(tel_nrctachq)   AND
                         crapreq.nrinichq = tel_nrinichq
                         USE-INDEX crapreq1 
                         NO-LOCK NO-ERROR.

      IF   NOT AVAILABLE crapreq   THEN
           glb_cdcritic = 066.
      ELSE
           DO:
               ASSIGN tel_qtreqtal = crapreq.qtreqtal
                      tel_nrfinchq = crapreq.nrfinchq
                      tel_nrseqdig = crapreq.nrseqdig.

               DISPLAY tel_qtreqtal   tel_nrfinchq    tel_nrseqdig
                       tel_cdbanchq   tel_nrinichq
                       WITH FRAME f_lanreq.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  ASSIGN glb_cdcritic = 078
                         aux_confirma = "N".
                  RUN fontes/critic.p.
                  glb_cdcritic = 0.
                  BELL.
                  MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                  LEAVE.
               END.

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                    aux_confirma <> "S" THEN
                    DO:
                        glb_cdcritic = 079.
                        RUN fontes/critic.p.
                        BELL.
                        glb_cdcritic = 0.
                        MESSAGE glb_dscritic.
                        NEXT.
                    END.
           END.
           
      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               ASSIGN glb_cddopcao = aux_cddopcao
                      tel_nrctachq = aux_nrdctabb
                      tel_tprequis = aux_tprequis
                      tel_nrinichq = aux_nrinichq
                      tel_cdagelot = aux_cdagelot
                      tel_nrdolote = aux_nrdolote.

               MESSAGE glb_dscritic.
               DISPLAY glb_cddopcao tel_cdagelot tel_nrdolote tel_nrctachq 
                       tel_nrinichq tel_tprequis
                       WITH FRAME f_lanreq.
               NEXT.
           END.
           
      LEAVE.
   END.
  
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        LEAVE.
 
   /* Instancia a BO para executar as procedures */
   RUN siscaixa/web/dbo/b1crap06.p PERSISTENT SET h-b1crap06.

   IF   VALID-HANDLE(h-b1crap06)   THEN
        DO:
            RUN exclui-solicitacao-entrega-talao 
                                       IN h-b1crap06(INPUT glb_nmrescop,
                                                     INPUT tel_cdagelot,
                                                     INPUT tel_nrdolote,
                                                     INPUT tel_nrctachq,
                                                     INPUT tel_tprequis,
                                                     INPUT tel_qtreqtal,
                                                     INPUT tel_cdbanchq,
                                                     INPUT tel_cdagechq,
                                                     INPUT tel_nrinichq,
                                                     INPUT tel_nrfinchq,
                                                     INPUT "AYLLOS").

            /* Elimina a instancia da BO */
            DELETE PROCEDURE h-b1crap06.

            /* Se ocorreu algum erro */
            IF   RETURN-VALUE = "NOK"   THEN
                 DO:
                     FIND FIRST craperr WHERE 
                                craperr.cdcooper = glb_cdcooper   AND
                                craperr.cdagenci = tel_cdagelot   AND
                                craperr.nrdcaixa = tel_nrdolote
                                NO-LOCK NO-ERROR.
                                   
                     IF   AVAILABLE craperr   THEN
                          DO:
                              MESSAGE craperr.dscritic.
                              NEXT.
                          END.
                 END.
        END.

   /* Atualiza os contadores da tela */
   FIND craptrq WHERE craptrq.cdcooper = glb_cdcooper   AND
                      craptrq.cdagelot = tel_cdagelot   AND
                      craptrq.tprequis = 0              AND
                      craptrq.nrdolote = tel_nrdolote   NO-LOCK NO-ERROR.
                      
   IF   AVAILABLE craptrq   THEN
        ASSIGN tel_qtinforq = craptrq.qtinforq
               tel_qtcomprq = craptrq.qtcomprq
               tel_qtinfotl = craptrq.qtinfotl
               tel_qtcomptl = craptrq.qtcomptl
               tel_qtinfoen = craptrq.qtinfoen
               tel_qtcompen = craptrq.qtcompen

               tel_qtdiferq = tel_qtcomprq - tel_qtinforq
               tel_qtdifetl = tel_qtcomptl - tel_qtinfotl
               tel_qtdifeen = tel_qtcompen - tel_qtinfoen.

   IF   tel_qtdiferq = 0  AND  tel_qtdifetl = 0  AND  tel_qtdifeen = 0   THEN
        DO:
            glb_nmdatela = "LOTREQ".
            HIDE FRAME f_lanreq.
            HIDE FRAME f_regant.
            HIDE FRAME f_lanctos.
            HIDE FRAME f_moldura.
            RETURN.
        END.

   ASSIGN tel_reganter[6] = tel_reganter[5]
          tel_reganter[5] = tel_reganter[4]
          tel_reganter[4] = tel_reganter[3]
          tel_reganter[3] = tel_reganter[2]
          tel_reganter[2] = tel_reganter[1]
          tel_reganter[1] = STRING(tel_nrctachq,"zzzz,zzz,9") + "     "    +
                            STRING(tel_tprequis,"9")          + "       "  +
                            STRING(tel_qtreqtal,"z9")         + "        " +
                            STRING(tel_cdbanchq,"z,zz9")      + "     "    +
                            STRING(tel_cdagechq,"zzz9")       + "  "       +
                            STRING(tel_nrinichq,"zzz,zzz,9")  + "  "       +
                            STRING(tel_nrfinchq,"zzz,zzz,9")  + " "        +
                            STRING(tel_nrseqdig,"zz,zz9").

   ASSIGN tel_cdbanchq = 0
          tel_cdagechq = 0
          tel_nrctachq = 0
          tel_tprequis = 1
          tel_qtreqtal = 0
          tel_nrinichq = 0
          tel_nrfinchq = 0
          tel_nrseqdig = tel_nrseqdig + 1.

   DISPLAY tel_cdagelot tel_nrdolote tel_qtinforq tel_qtcomprq
           tel_qtdiferq tel_qtinfotl tel_qtcomptl
           tel_qtdifetl tel_qtinfoen tel_qtcompen
           tel_qtdifeen tel_nrctachq tel_qtreqtal tel_tprequis
           tel_nrinichq tel_nrfinchq tel_nrseqdig
           WITH FRAME f_lanreq.

   PAUSE(0).
   
   HIDE FRAME f_lanctos.

   DISPLAY tel_reganter[1] tel_reganter[2] tel_reganter[3]
           tel_reganter[4] tel_reganter[5] tel_reganter[6]
           WITH FRAME f_regant.

END.

/* .......................................................................... */
