/* .............................................................................

   Programa: Includes/limcxac.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Abril/2004                          Ultima atualizacao: 27/01/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela limcxa.
   
               27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
............................................................................. */

IF   tel_cdoperad <> ""   THEN
     DO:
         FIND crapope WHERE crapope.cdcooper = glb_cdcooper  AND
                            crapope.cdoperad = tel_cdoperad
                            NO-LOCK NO-ERROR NO-WAIT.

         IF   AVAILABLE crapope   THEN
              DO:
                  ASSIGN tel_nmoperad = crapope.nmoperad
                         tel_vlpagchq = crapope.vlpagchq.
                  DISPLAY tel_nmoperad tel_vlpagchq WITH FRAME f_limcxa.
              END.
         ELSE
              DO:
                  ASSIGN glb_cdcritic = 67.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  CLEAR FRAME f_limcxa.
                  DISPLAY tel_cdoperad WITH FRAME f_limcxa.
                  NEXT.
              END.
     END.
ELSE
     DO:
         DISPLAY "" @ tel_nmoperad "" @ tel_vlpagchq
                 WITH FRAME f_limcxa.
         PAUSE(0).
                 
         OPEN QUERY blimcxa-q 
               FOR EACH crapope WHERE crapope.cdcooper = glb_cdcooper AND
                                      crapope.cdsitope = 1
                                      NO-LOCK BY crapope.cdoperad.
              
         ENABLE blimcxa-b    
                WITH FRAME f_limcxac.

         WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.

     END.

HIDE FRAME f_limcxac.
/* .......................................................................... */

