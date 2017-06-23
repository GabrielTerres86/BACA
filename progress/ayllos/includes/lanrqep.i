/* .............................................................................

   Programa: Includes/lanrqep.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Ranghetti
   Data    : Maio/2017.                       Ultima alteracao: 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de Requisicoes Pendentes da tela LANRQE.

   Alteracoes: 
               
............................................................................. */

DO WHILE TRUE:
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      CLEAR FRAME f_lanrqe_p.
      CLEAR FRAME f_lanctos_p.
      HIDE FRAME f_lanrqe_p.
      HIDE FRAME f_lanctos_p.
      
      ASSIGN tel_nrdctabb = 0 
             tel_tprequis = 0.
      
      SET tel_nrdctabb 
          tel_tprequis 
          WITH FRAME f_lanrqe_p.

      ASSIGN aux_nrdconta = tel_nrdctabb
             aux_tprequis = tel_tprequis
             glb_nrcalcul = tel_nrdctabb
             glb_cdcritic = 0.
      
      IF  tel_nrdctabb = 0 OR tel_tprequis = 0  THEN
          LEAVE.
          
      RUN fontes/digfun.p.

      IF NOT glb_stsnrcal THEN
         DO:
             ASSIGN glb_cdcritic = 8.
             NEXT-PROMPT tel_nrdctabb WITH FRAME f_lanrqe_p.
         END.
      ELSE 
         DO:
            FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                               crapass.nrdconta = tel_nrdctabb
                               NO-LOCK NO-ERROR.
         
            IF NOT AVAILABLE crapass   THEN
               DO:
                   ASSIGN glb_cdcritic = 9.
                   NEXT-PROMPT tel_nrdctabb WITH FRAME f_lanrqe_p.
                END.
            
         END.
          
      IF glb_cdcritic > 0 THEN
         DO:
             RUN fontes/critic.p.
             BELL.
             CLEAR FRAME f_lanrqe_p.
             ASSIGN tel_nrdctabb = aux_nrdconta
                    tel_tprequis = aux_tprequis.

             MESSAGE glb_dscritic.
             DISPLAY tel_nrdctabb 
                     tel_tprequis
                     WITH FRAME f_lanrqe_p.

             NEXT.
         END.
      LEAVE.
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */        
        RETURN. 
    
   IF tel_nrdctabb = 0   THEN
      DO:
          ASSIGN aux_flgerros = FALSE
                 aux_flgretor = FALSE
                 aux_regexist = FALSE
                 aux_contador = 0.
          
           /* SUBSTITUICAO AO PUT SCREEN */
          CLEAR FRAME f_lanrqe_p.          
          CLEAR FRAME f_lanctos_p ALL NO-PAUSE.
          /**********/
          
          FOR EACH crapreq WHERE crapreq.cdcooper = glb_cdcooper AND
                                 crapreq.insitreq = 1            AND
                                 crapreq.nrdolote = 99 
                                 NO-LOCK BY crapreq.nrseqdig:

              ASSIGN aux_regexist = TRUE
                     aux_contador = aux_contador + 1.

              IF aux_contador = 1   THEN
                 IF aux_flgretor   THEN
                    DO: 
                        PAUSE MESSAGE
                        "Tecle <Entra> para continuar ou <Fim> para encerrar".
                        CLEAR FRAME f_lanctos_p ALL NO-PAUSE.                        
                    END.
                 ELSE
                    ASSIGN aux_flgretor = TRUE. 

              PAUSE(0).

              DISPLAY crapreq.nrdctabb 
                      crapreq.tprequis 
                      crapreq.qtreqtal  
                      crapreq.nrseqdig
                      crapreq.dtmvtolt
                      WITH FRAME f_lanctos_p.

              IF aux_contador = 7   THEN
                 aux_contador = 0.
              ELSE 
                 DOWN WITH FRAME f_lanctos_p.

          END.

          IF NOT aux_regexist   THEN
             ASSIGN glb_cdcritic = 11.

          IF glb_cdcritic > 0   THEN
             DO:
                 RUN fontes/critic.p.
                 BELL.
                 CLEAR FRAME f_lanrqe_p NO-PAUSE.

                 ASSIGN tel_nrdctabb = aux_nrdconta
                        tel_tprequis = aux_tprequis.

                 DISPLAY tel_nrdctabb  
                         tel_tprequis
                         WITH FRAME f_lanrqe_p.

                 MESSAGE glb_dscritic.
                 NEXT.
             END.
          NEXT.
      END.

   FIND crapreq WHERE crapreq.cdcooper = glb_cdcooper   AND
                      crapreq.insitreq = 1              AND                      
                      crapreq.nrdolote = 99             AND
                      crapreq.tprequis = tel_tprequis   AND 
                      crapreq.nrdctabb = tel_nrdctabb   AND
                      crapreq.nrinichq = 0
                      USE-INDEX crapreq1 NO-LOCK NO-ERROR.

   IF NOT AVAILABLE crapreq   THEN
      DO:
          ASSIGN glb_cdcritic = 90.
          RUN fontes/critic.p.
          BELL.
          CLEAR FRAME f_lanrqe_p NO-PAUSE.

          ASSIGN tel_nrdctabb = aux_nrdconta
                 tel_tprequis = aux_tprequis.

          DISPLAY tel_nrdctabb  
                  tel_tprequis
                  WITH FRAME f_lanrqe_p.

          MESSAGE glb_dscritic.
          NEXT.
      END.

   ASSIGN tel_nrdctabb = crapreq.nrdctabb
          tel_tprequis = crapreq.tprequis
          tel_qtreqtal = crapreq.qtreqtal
          tel_nrseqdig = crapreq.nrseqdig
          tel_dtsolici = crapreq.dtmvtolt.

   DISPLAY tel_nrdctabb 
           tel_tprequis 
           tel_qtreqtal 
           tel_nrseqdig
           tel_dtsolici
           WITH FRAME f_lanrqe_p.
  RETURN.
END.

/* .......................................................................... */

