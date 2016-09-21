/* ............................................................................

   Programa: Includes/pedmagl.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio         
   Data    : Agosto/2003                         Ultima atualizacao: 31/01/2006 
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de liberacao da tela PEDMAG.

   Alteracoes: 31/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

.............................................................................*/

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   tel_nrpedido = "0".
   
   UPDATE tel_nrpedido WITH FRAME f_pedido.

   CLEAR FRAME f_lanctos ALL NO-PAUSE.

   IF   INT(tel_nrpedido) = 0   THEN
        DO:
            glb_cdcritic = 221.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT.
        END.
        
   DO aux_contador = 1 TO 10:

      glb_cdcritic = 0.
      
      FIND craptab WHERE craptab.cdcooper = glb_cdcooper       AND
                         craptab.nmsistem = "CRED"             AND
                         craptab.tptabela = "AUTOMA"           AND
                         craptab.cdempres = 0                  AND
                         craptab.tpregist = 0                  AND
                         craptab.cdacesso = "CM" + tel_nrpedido
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF   NOT AVAILABLE craptab   THEN
           DO:
              IF   LOCKED craptab   THEN
                   DO:
                       glb_cdcritic = 236.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE glb_dscritic.
                       PAUSE 1 NO-MESSAGE.
                       NEXT.
                   END.
              ELSE
                   DO:
                      glb_cdcritic = 221.
                      LEAVE.
                   END.
           END.
           
      LEAVE.

   END.   /* Fim do DO aux_contador 1 TO 10: */

   HIDE MESSAGE NO-PAUSE.
    
   IF   glb_cdcritic = 0   THEN
        DO:
                                                        
            IF   INT(craptab.dstextab) = 0   THEN
                 tel_dssitped = "SOLICITADO".
            ELSE
            IF   INT(craptab.dstextab) = 1   THEN
                 tel_dssitped = "LIBERADO".
            ELSE
                 tel_dssitped = "".

            tel_dtsolped = DATE(SUBSTR(craptab.cdacesso, 3, 2) + "/" +
                                SUBSTR(craptab.cdacesso, 5, 2) + "/" + 
                                SUBSTR(craptab.cdacesso, 7, 4)).
           
            tel_dspedido = tel_nrpedido.
          
            DISPLAY tel_dspedido tel_dtsolped tel_dssitped
                    WITH FRAME f_lanctos.

            IF   INT(craptab.dstextab) = 0   THEN
                 DO:
   
                    aux_pesquisa = DATE(INT(SUBSTR(tel_nrpedido, 3, 2)),
                                        INT(SUBSTR(tel_nrpedido, 1, 2)),
                                        INT(SUBSTR(tel_nrpedido, 5, 4))).
                    
                    FIND FIRST crapcrm WHERE crapcrm.cdcooper = glb_cdcooper AND
                                             crapcrm.dtemscar = aux_pesquisa AND
                                             crapcrm.cdsitcar <> 1  
                                             NO-LOCK NO-ERROR.

                    IF   AVAILABLE crapcrm   THEN
                         DO:
                             glb_cdcritic = 225.
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE glb_dscritic.
                             LEAVE. 
                         END.
                    
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                       aux_confirma = "N".
                       glb_cdcritic = 78.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                       LEAVE.
                    END.

                    IF   (KEYFUNCTION(LASTKEY) = "END-ERROR") OR
                         (aux_confirma <> "S")   THEN
                         DO:
                             glb_cdcritic = 79.
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE glb_dscritic.
                             NEXT.
                         END.

                    ASSIGN craptab.dstextab = "1"
                           glb_cdcritic = 226
                           tel_dssitped = "LIBERADO".
                        
                    DISPLAY tel_dspedido tel_dtsolped tel_dssitped
                            WITH FRAME f_lanctos.                       
                 END.
            ELSE           
            IF   INT(craptab.dstextab) = 1   THEN
                 glb_cdcritic = 223.
                
        END. /* Fim do  IF   glb_cdcritic = 0   THEN */

   IF   glb_cdcritic <> 236   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
        END.
        
   glb_cdcritic = 0.
        
END.  /*  Fim do DO WHILE TRUE  */

/* ......................................................................... */
