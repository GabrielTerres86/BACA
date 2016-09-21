/* .............................................................................
   Programa: Includes/rmativi.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Junho/2006                          Ultima Atualizacao: 12/12/2013  

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela RMATIV.
   
   Alteracoes: 12/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO) 
............................................................................. */

ASSIGN  tel_nmrmativ = ""
        tel_cdseteco = 0
        tel_nmseteco = "".
        
DISPLAY tel_cdrmativ tel_nmrmativ tel_cdseteco tel_nmseteco WITH FRAME f_ramos.

IF   tel_cdrmativ = 0   THEN
     DO:
         ASSIGN glb_cdcritic = 375.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         CLEAR FRAME f_ramos.
         DISPLAY glb_cddopcao tel_cdrmativ WITH FRAME f_ramos.
         NEXT.
     END.

FIND gnrativ WHERE gnrativ.cdrmativ = tel_cdrmativ NO-LOCK NO-ERROR NO-WAIT.

IF   AVAILABLE gnrativ   THEN
     DO:
         glb_cdcritic = 709.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         CLEAR FRAME f_ramos.
         DISPLAY glb_cddopcao tel_cdrmativ WITH FRAME f_ramos.
         NEXT.
     END.

DO TRANSACTION ON ENDKEY UNDO, LEAVE:

   DO WHILE TRUE:

      SET tel_nmrmativ  WITH FRAME f_ramos.
      
      RUN lista_setor_economico.   /* LISTA SETORES <F7> */
     
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         ASSIGN aux_confirma = "N"
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
               LEAVE.
           END.
      
      FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                         craptab.cdacesso = "SETORECONO" AND
                         craptab.tpregist = tel_cdseteco
                         NO-LOCK NO-ERROR.
      
      IF   AVAILABLE craptab THEN
           DO:
               CREATE gnrativ.
               ASSIGN gnrativ.cdrmativ = tel_cdrmativ
                      gnrativ.nmrmativ = CAPS(tel_nmrmativ)
                      gnrativ.cdseteco = tel_cdseteco.
               VALIDATE gnrativ.
           END.           
      ELSE 
           DO:      /* verifica se setor da economia eh valido */
               ASSIGN glb_cdcritic = 878.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_ramos.                                
               DISPLAY tel_cdrmativ tel_nmrmativ WITH FRAME f_ramos.    
               NEXT.
           END.
           
      LEAVE.
      
   END.

END. /* Fim da transacao */

RELEASE gnrativ.

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     NEXT.

CLEAR FRAME f_ramos NO-PAUSE.

/* .......................................................................... */
