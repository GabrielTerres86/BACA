/* .............................................................................
   
   Programa: Includes/cadpacx.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Daniel(Gati)
   Data    : Junho/2010                        Ultima Atualizacao: 15/01/2014
   
   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Alterar o campo "Valor de Aprovacao do Comite Local". 
   
   Alteracao : 15/01/2014 - Alterada critica "15 - Agencia nao cadastrada" para
                            "962 - PA nao cadastrado". (Reinert)
 
............................................................................. */

ASSIGN tel_vllimapv    = 0.

ASSIGN glb_cdcritic = 0.

FIND crapage WHERE crapage.cdcooper = glb_cdcooper    AND
                   crapage.cdagenci = tel_cdagenci    NO-LOCK NO-ERROR NO-WAIT.

IF   NOT AVAILABLE crapage   THEN
     DO:
         glb_cdcritic = 962.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         CLEAR FRAME f_pac.
         DISPLAY  tel_cdagenci WITH FRAME f_pac.
         NEXT.
     END.
                             
DO  TRANSACTION ON ENDKEY UNDO, LEAVE:

    ASSIGN tel_nrdcaixa = 0
           tel_cdopecxa = " "
           tel_dtmvtolt = ?
           tel_vllimapv = crapage.vllimapv
           log_vllimapv = crapage.vllimapv.
   
    DISPLAY tel_vllimapv
            WITH FRAME f_aprova.
   
    SET tel_vllimapv
        WITH FRAME f_aprova.

    FIND crapage WHERE crapage.cdcooper = glb_cdcooper    AND
                       crapage.cdagenci = tel_cdagenci    
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF   AVAIL crapage THEN
         DO: 
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
                 ASSIGN aux_confirma = "N"
                        glb_cdcritic = 78.
                 RUN fontes/critic.p.
                 ASSIGN glb_cdcritic = 0.
         
                 BELL.
                 MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
         
                 LEAVE.
          
             END. /** Fim do DO WHILE TRUE **/
                   
             IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR aux_confirma <> "S"  THEN
                 DO:
                     ASSIGN glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     ASSIGN glb_cdcritic = 0.
                
                     BELL.
                     MESSAGE glb_dscritic.
                   
                     UNDO, LEAVE.
                 END.
             
                 ASSIGN crapage.vllimapv = tel_vllimapv.
                 RUN gera_log_cadpac.
         END.
END.
