/* .............................................................................

   Programa: Includes/lotreqe.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/92.                     Ultima alteracao: 30/01/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela LOTREQ.

   Alteracoes: 02/04/98 - Tratamento para milenio e troca para V8 (Magui).
   
               16/11/2004 - Exibir o nome do operador (Evandro).

               12/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
               
               07/12/2005 - Acertar leitura do crapfdc (Magui).

               30/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane. 
............................................................................. */

TRANS_1:

DO TRANSACTION ON ERROR UNDO TRANS_1, LEAVE TRANS_1:

   DO  aux_contador = 1 TO 10:

       FIND craptrq WHERE craptrq.cdcooper = glb_cdcooper         AND
                          craptrq.cdagelot = INPUT tel_cdagelot   AND
                          craptrq.tprequis = 0                    AND
                          craptrq.nrdolote = INPUT tel_nrdolote
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE craptrq   THEN
            IF   LOCKED craptrq   THEN
                 DO:
                     glb_cdcritic = 84.
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
            ELSE
                 DO:
                     glb_cdcritic = 60.
                     CLEAR FRAME f_lotreq NO-PAUSE.
                     LEAVE.
                 END.
       ELSE
            DO:
                aux_contador = 0.
                LEAVE.
            END.
   END.

   IF   aux_contador <> 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            ASSIGN tel_cdagelot = aux_cdagelot
                   tel_nrdolote = aux_nrdolote.

            DISPLAY tel_cdagelot tel_nrdolote WITH FRAME f_lotreq.
            NEXT.
        END.

   ASSIGN tel_qtdiferq = craptrq.qtcomprq - craptrq.qtinforq
          tel_qtdifetl = craptrq.qtcomptl - craptrq.qtinfotl.

   FIND crapope WHERE crapope.cdcooper = glb_cdcooper     AND
                      crapope.cdoperad = craptrq.cdoperad NO-LOCK NO-ERROR.

   IF   AVAILABLE crapope   THEN
        tel_nmoperad = crapope.nmoperad.
   
   DISPLAY craptrq.qtinforq craptrq.qtcomprq tel_qtdiferq
           craptrq.qtinfotl craptrq.qtcomptl tel_qtdifetl
           tel_nmoperad     WITH FRAME f_lotreq.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      aux_confirma = "N".

      glb_cdcritic = 78.
      RUN fontes/critic.p.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
        aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT.
        END.

   ASSIGN glb_cdcritic = 0
          aux_flgerros = FALSE.

   FOR EACH crapreq WHERE crapreq.cdcooper = glb_cdcooper         AND
                          crapreq.dtmvtolt = glb_dtmvtolt         AND
                          crapreq.cdagelot = INPUT tel_cdagelot   AND
                          crapreq.nrdolote = INPUT tel_nrdolote   
                          EXCLUSIVE-LOCK ON ERROR UNDO, RETRY:

       ASSIGN aux_nrseqems = 0
              aux_qttalent = 0.
 
       IF crapreq.nrinichq > 0 AND crapreq.nrfinchq > 0 THEN
          DO:
             RUN fontes/digbbx.p (INPUT  crapreq.nrdctabb,
                                  OUTPUT glb_dsdctitg,
                                  OUTPUT glb_stsnrcal).
             IF NOT glb_stsnrcal   THEN
                DO:
                   glb_cdcritic = 8.
                   NEXT-PROMPT tel_cdagelot WITH FRAME f_lotreq.
                   NEXT.
                END.
             ASSIGN aux_num_cheque_inicial = INT(SUBSTR(STRING(crapreq.nrinichq,
                                                      "9999999"),1,6))
                   aux_num_cheque_final   = INT(SUBSTR(STRING(crapreq.nrfinchq,
                                                      "9999999"),1,6)).
            
             DO aux_nrcheque = aux_num_cheque_inicial TO aux_num_cheque_final 
                BY 1:
                DO WHILE TRUE:
                  
                   aux_flgerros = FALSE.

                   FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper   AND
                                      crapfdc.cdcooper = glb_cdcooper   AND
                                      crapfdc.nrdctitg = glb_dsdctitg   AND
                                      crapfdc.nrcheque = aux_nrcheque
                                      USE-INDEX crapfdc1
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE crapfdc   THEN
                        IF   LOCKED crapfdc   THEN
                             DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                             END.
                        ELSE
                        DO:
                            glb_cdcritic = 108.
                            LEAVE.
                        END.

                   LEAVE.
                END.

                IF   glb_cdcritic = 0   THEN
                     IF   crapfdc.dtretchq = ?   THEN
                          glb_cdcritic = 109.
                     ELSE
                          IF   crapfdc.dtemschq = ?   THEN
                               glb_cdcritic = 108.
                          ELSE
                               IF   crapfdc.tpcheque <> 1 THEN
                                    glb_cdcritic = 646.

                IF   glb_cdcritic > 0   THEN
                     LEAVE.

                ASSIGN crapfdc.dtretchq = ?.
                IF aux_nrseqems <> crapfdc.nrseqems   THEN
                   ASSIGN aux_nrseqems = crapfdc.nrseqems
                          aux_qttalent = aux_qttalent + 1.
             END.

             IF   glb_cdcritic > 0   THEN
                  DO:
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     aux_flgerros = TRUE.
                     UNDO TRANS_1, NEXT.
                  END.
       END.
       ASSIGN craptrq.qtcomprq = craptrq.qtcomprq - 1
              craptrq.qtcomptl = craptrq.qtcomptl - crapreq.qtreqtal
              craptrq.qtcompen = craptrq.qtcompen - aux_qttalent.

       DELETE crapreq.
   END.

   IF   aux_flgerros   THEN
        DO:
            ASSIGN tel_qtdiferq = craptrq.qtcomprq - craptrq.qtinforq
                   tel_qtdifetl = craptrq.qtcomptl - craptrq.qtinfotl
                   tel_qtdifeen = craptrq.qtcompen - craptrq.qtinfoen.

            DISPLAY craptrq.qtinforq craptrq.qtcomprq tel_qtdiferq
                    craptrq.qtinfotl craptrq.qtcomptl tel_qtdifetl
                    craptrq.qtinfoen craptrq.qtcompen tel_qtdifeen
                    WITH FRAME f_lotreq.
        END.
   ELSE
        DO:
            DELETE craptrq.
            CLEAR FRAME f_lotreq NO-PAUSE.
            glb_cddopcao = "E".
        END.

END.   /* Fim da transacao */

/* .......................................................................... */

