/* .............................................................................

   Programa: Includes/lanreqc.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Fevereiro/92.                   Ultima alteracao: 08/02/2007

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de conulsta da tela LANREQ.

   Alteracoes: 13/06/94 - Alterado para acessar a tabela de contas de convenio

               02/04/98 - Tratamento para milenio e troca para V8 (Magui).
               
             13/02/2003 - Usar agencia e numero do lote para separar 
                          as agencias (Magui).
             
             17/03/2005 - Verificar se Conta Integracao(Mirtes)

             07/12/2005 - Acertar leitura do crapfdc (Magui).

             01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando
             
             08/02/2007 - Modificacao do uso dos indices e adequacao ao
                          BANCOOB (Evandro).

............................................................................. */

DO WHILE TRUE:

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      SET tel_nrctachq    tel_tprequis    tel_cdbanchq
          tel_nrinichq    WITH FRAME f_lanreq.

      ASSIGN aux_cddopcao = glb_cddopcao
             aux_nrdconta = tel_nrctachq
             aux_tprequis = tel_tprequis
             aux_nrinichq = tel_nrinichq
             aux_cdagelot = tel_cdagelot
             aux_nrdolote = tel_nrdolote
             glb_nrcalcul = tel_nrctachq
             glb_cdcritic = 0.

      IF   tel_nrctachq = 0   AND   tel_nrinichq = 0   THEN
           LEAVE.
     
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
                    glb_nrcalcul = tel_nrinichq.
                    RUN fontes/digfun.p.
                    IF   NOT glb_stsnrcal   THEN
                         DO:
                             glb_cdcritic = 8.
                             NEXT-PROMPT tel_nrinichq WITH FRAME f_lanreq.
                         END.
                    ELSE
                         DO:
                             FIND crapfdc WHERE 
                                  crapfdc.cdcooper = glb_cdcooper   AND
                                  crapfdc.cdbanchq = tel_cdbanchq   AND
                                  crapfdc.cdagechq = tel_cdagechq   AND
                                  crapfdc.nrctachq = tel_nrctachq   AND
                                  crapfdc.nrcheque =
                                          INTE(SUBSTR(STRING(tel_nrinichq,
                                               "99999999"),1,7))
                                  USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
                                       
                             IF NOT AVAILABLE crapfdc   THEN
                                DO:
                                    glb_cdcritic = 108.
                                    NEXT-PROMPT tel_nrinichq 
                                                    WITH FRAME f_lanreq.
                                END.
                             ELSE
                                IF crapfdc.tpcheque <> tel_tprequis   THEN
                                   DO:
                                       glb_cdcritic = 513.
                                       NEXT-PROMPT tel_nrinichq 
                                                       WITH FRAME f_lanreq.
                                   END.
                         END.
                END.

      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               ASSIGN glb_cddopcao = aux_cddopcao
                      tel_nrctachq = aux_nrdconta
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

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        LEAVE.   /* Volta pedir a opcao para o operador */

   FIND craptrq WHERE craptrq.cdcooper = glb_cdcooper AND
                      craptrq.cdagelot = tel_cdagelot AND
                      craptrq.tprequis = 0            AND
                      craptrq.nrdolote = tel_nrdolote NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craptrq   THEN
        DO:
            glb_cdcritic = 60.
            RUN fontes/critic.p.
            BELL.
            ASSIGN glb_cddopcao = aux_cddopcao
                   tel_cdagelot = aux_cdagelot
                   tel_nrdolote = aux_nrdolote
                   tel_nrctachq = aux_nrdconta
                   tel_tprequis = aux_tprequis
                   tel_nrinichq = aux_nrinichq.
            DISPLAY glb_cddopcao  tel_cdagelot tel_nrdolote  tel_nrctachq  
                    tel_nrinichq  tel_tprequis
                    WITH FRAME f_lanreq.
            MESSAGE glb_dscritic.
            NEXT.
        END.

   ASSIGN tel_qtinforq = craptrq.qtinforq
          tel_qtcomprq = craptrq.qtcomprq
          tel_qtinfotl = craptrq.qtinfotl
          tel_qtcomptl = craptrq.qtcomptl
          tel_qtinfoen = craptrq.qtinfoen
          tel_qtcompen = craptrq.qtcompen
          tel_qtdiferq = tel_qtcomprq - tel_qtinforq
          tel_qtdifetl = tel_qtcomptl - tel_qtinfotl
          tel_qtdifeen = tel_qtcompen - tel_qtinfoen.

   IF   tel_nrctachq = 0   THEN
        DO:
            ASSIGN aux_flgerros = FALSE
                   aux_flgretor = FALSE
                   aux_regexist = FALSE
                   aux_contador = 0.

            /* SUBSTITUICAO AO PUT SCREEN */
            CLEAR FRAME f_lanreq.
            HIDE FRAME f_regant.
            CLEAR FRAME f_lanctos ALL NO-PAUSE.
            /**********/

            DISPLAY glb_cddopcao tel_cdagelot tel_nrdolote
                    tel_qtinforq tel_qtcomprq tel_qtdiferq
                    tel_qtinfotl tel_qtcomptl tel_qtdifetl
                    tel_qtinfoen tel_qtcompen tel_qtdifeen
                    WITH FRAME f_lanreq.
            
            FOR EACH crapreq WHERE crapreq.cdcooper = glb_cdcooper AND
                                   crapreq.dtmvtolt = glb_dtmvtolt AND
                                   crapreq.cdagelot = tel_cdagelot AND
                                   crapreq.nrdolote = tel_nrdolote NO-LOCK
                                   USE-INDEX crapreq3:
                                   
                ASSIGN aux_regexist = TRUE
                       aux_contador = aux_contador + 1.

                IF   aux_contador = 1   THEN
                     IF   aux_flgretor   THEN
                          DO:
                              PAUSE MESSAGE
                          "Tecle <Entra> para continuar ou <Fim> para encerrar".
                              CLEAR FRAME f_lanctos ALL NO-PAUSE.
                          END.
                     ELSE
                          aux_flgretor = TRUE.

                PAUSE(0).

                DISPLAY crapreq.nrdctabb  crapreq.qtreqtal  crapreq.nrinichq
                        crapreq.nrfinchq  crapreq.nrseqdig  crapreq.tprequis
                        WITH FRAME f_lanctos.
                
                IF   aux_contador = 6   THEN
                     aux_contador = 0.
                ELSE
                     DOWN WITH FRAME f_lanctos.
            END.

            IF   NOT aux_regexist   THEN
                 glb_cdcritic = 11.

            IF   glb_cdcritic > 0   THEN
                 DO:
                     RUN fontes/critic.p.
                     BELL.
                     ASSIGN glb_cddopcao = aux_cddopcao
                            tel_cdagelot = aux_cdagelot
                            tel_nrdolote = aux_nrdolote
                            tel_nrctachq = aux_nrdconta
                            tel_tprequis = aux_tprequis
                            tel_nrinichq = aux_nrinichq.
                            DISPLAY glb_cddopcao  tel_cdagelot tel_nrdolote
                                    tel_nrctachq  tel_nrinichq tel_tprequis
                                    WITH FRAME f_lanreq.
                     MESSAGE glb_dscritic.
                     NEXT.
                 END.
            NEXT.
        END.

   FIND crapreq WHERE crapreq.cdcooper = glb_cdcooper        AND
                      crapreq.dtmvtolt = glb_dtmvtolt        AND
                      crapreq.cdagelot = tel_cdagelot        AND
                      crapreq.tprequis = tel_tprequis        AND
                      crapreq.nrdolote = tel_nrdolote        AND
                      crapreq.nrdctabb = INT(tel_nrctachq)   AND
                      crapreq.nrinichq = tel_nrinichq        NO-LOCK
                      USE-INDEX crapreq1 NO-ERROR.

   IF   NOT AVAILABLE crapreq   THEN
        DO:
            glb_cdcritic = 90.
            RUN fontes/critic.p.
            BELL.
            ASSIGN glb_cddopcao = aux_cddopcao
                   tel_cdagelot = aux_cdagelot
                   tel_nrdolote = aux_nrdolote
                   tel_nrctachq = aux_nrdconta
                   tel_tprequis = aux_tprequis
                   tel_nrinichq = aux_nrinichq.
            DISPLAY glb_cddopcao  tel_cdagelot tel_nrdolote  tel_nrctachq  
                    tel_nrinichq  tel_tprequis
                    WITH FRAME f_lanreq.
            MESSAGE glb_dscritic.
            NEXT.
        END.

   ASSIGN tel_nrctachq = crapreq.nrdctabb
          tel_qtreqtal = crapreq.qtreqtal
          tel_tprequis = crapreq.tprequis
          tel_nrinichq = crapreq.nrinichq
          tel_nrfinchq = crapreq.nrfinchq
          tel_nrseqdig = crapreq.nrseqdig.

   DISPLAY tel_qtinforq tel_qtcomprq tel_qtdiferq
           tel_qtinfotl tel_qtcomptl tel_qtdifetl
           tel_qtinfoen tel_qtcompen tel_qtdifeen
           tel_nrctachq tel_qtreqtal tel_nrinichq
           tel_nrfinchq tel_nrseqdig tel_tprequis
           WITH FRAME f_lanreq.

END.

/* .......................................................................... */

