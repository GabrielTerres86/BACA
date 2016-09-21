/* .............................................................................
   Programa: Includes/rmativc.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Junho/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela RMATIV.

............................................................................. */

IF   tel_cdrmativ <> 0   THEN
     DO:
         FIND gnrativ WHERE gnrativ.cdrmativ = tel_cdrmativ
                            NO-LOCK NO-ERROR NO-WAIT.

         IF   AVAILABLE gnrativ   THEN
              RUN pesq_setor_economico.
         ELSE
              DO:
                  ASSIGN glb_cdcritic = 878.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  CLEAR FRAME f_ramos.
                  DISPLAY tel_cdrmativ WITH FRAME f_ramos.
                  NEXT.
              END.
     END.
ELSE
     DO:
         DISPLAY "" @ tel_nmrmativ "" @ tel_cdseteco "" @ tel_nmseteco
                      WITH FRAME f_ramos.
         PAUSE(0).
     END.
     
NEXT-PROMPT tel_cdrmativ WITH FRAME f_ramos.
HIDE FRAME f_ramosc NO-PAUSE.    

/* .......................................................................... */
