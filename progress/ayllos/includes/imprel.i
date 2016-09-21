/* .............................................................................

   Programa: Includes/imprel.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Fevereiro/96.                       Ultima atualizacao: 02/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina de impressao dos relatorios do sistema.

   Alteracoes: 26/07/1999 - Tratar tamanho do formulario (Odair)
               
               10/09/2003 - Se o usuario escolher a opcao "D", o PAC e o nro.
                            de vias e' solicitado apenas uma vez (Fernando).

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               02/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
............................................................................. */

DEF VAR aux_server   AS CHAR                                    NO-UNDO.

ASSIGN glb_nrdevias = 1
       glb_nmformul = "132col".

IF   pac[choice]   THEN
     DO:
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            IF   aux_flgfirst = FALSE THEN
                 DO:
                     UPDATE tel_cdagenci tel_qtdevias WITH FRAME f_imprel.
                     IF   glb_cddopcao = "C" THEN
                          aux_flgfirst = FALSE.
                     ELSE
                          aux_flgfirst = TRUE.
                 END.

            rel_nmarqimp = "rl/" + proglist[choice] + "_" +
                           STRING(tel_cdagenci,"99") + ".lst".

            IF   SEARCH(rel_nmarqimp) = ?   THEN
                 IF   glb_cddopcao = "C"      THEN
                      DO:
                          glb_cdcritic = 182.
                          RUN fontes/critic.p.
                          BELL.
                          HIDE MESSAGE NO-PAUSE.
                          MESSAGE glb_dscritic rel_nmarqimp.
                          glb_cdcritic = 0.
                          NEXT.
                      END.
                 ELSE
                      glb_cdcritic = 999.           /*  Relatorio nao existe  */
                                                    /*  passa para o proximo  */
            IF   tel_qtdevias = 0   THEN
                 glb_nrdevias = 1.
            ELSE 
                 glb_nrdevias = tel_qtdevias.

            LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

         HIDE FRAME f_imprel NO-PAUSE.

         IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
              NEXT.
     END.
ELSE
     DO:
         rel_nmarqimp = "rl/" + proglist[choice] + ".lst".

         IF   SEARCH(rel_nmarqimp) = ? AND
              glb_cddopcao = "C"       THEN
              DO:
                  glb_cdcritic = 182.
                  RUN fontes/critic.p.
                  BELL.
                  HIDE MESSAGE NO-PAUSE.
                  MESSAGE glb_dscritic rel_nmarqimp.
                  glb_cdcritic = 0.
                  NEXT.
              END.
     END.

IF   glb_cdcritic = 0   THEN
     DO:
         /*  Gerenciamento da impressao  */

         INPUT THROUGH basename `tty` NO-ECHO.

         SET aux_nmendter WITH FRAME f_terminal.

         INPUT CLOSE.

         INPUT THROUGH basename `hostname -s` NO-ECHO.
         IMPORT UNFORMATTED aux_server.
         INPUT CLOSE.
         
         aux_nmendter = substr(aux_server,length(aux_server) - 1) +
                               aux_nmendter.

         UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

         aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME).

         OUTPUT TO VALUE(aux_nmarqimp).

         /*  Configura a impressora para 1/8" e 17 cpi  */

         IF   formu[choice] = 132 THEN
              PUT CONTROL "\0330\033x0\033\017" NULL.
         ELSE
              PUT CONTROL "\022\024\033\120" NULL.

         PUT CONTROL "\0330\033x0" NULL.

         OUTPUT CLOSE.

         /*  Monta o arquivo para impressao  */

         UNIX SILENT VALUE("cat " + aux_nmarqimp + " " + rel_nmarqimp + " > " +
                           aux_nmarqimp + ".rl 2> /dev/null").

         ASSIGN aux_flgescra = FALSE
                par_flgcance = FALSE
                aux_nmarqimp = aux_nmarqimp + ".rl".

         FIND crapter WHERE crapter.cdcooper = glb_cdcooper AND
                            crapter.nmendter = aux_nmendter NO-LOCK NO-ERROR.

         IF   AVAILABLE crapter   THEN
              IF   crapter.nmdafila = "escrava"   THEN
                   aux_flgescra = TRUE.
              ELSE
              IF   crapter.nmdafila <> "Limbo"    THEN
                   DO:
                       aux_dscomand = "lp -d" + crapter.nmdafila + " -n " +
                                      STRING(glb_nrdevias) + " " +
                                      aux_nmarqimp + " > /dev/null".

                       UNIX SILENT VALUE(aux_dscomand).
                   END.
              ELSE .
         ELSE
         IF   glb_flgimpre   THEN
              aux_flgescra = TRUE.
         ELSE
         IF   glb_flgmicro   THEN
              DO:
                  aux_dscomand = "lp -d" + glb_nmdafila +
                                 " -n" + STRING(glb_nrdevias) +   
                                 " -oMTl88 " + " -oMTf" + glb_nmformul + " " +
                                 aux_nmarqimp +
                                 " > /dev/null".

                  UNIX SILENT VALUE(aux_dscomand).
              END.

         IF   aux_flgescra   THEN
              DO:
                  DISPLAY tel_dsimprim tel_dscancel WITH FRAME f_atencao.

                  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                     CHOOSE FIELD tel_dscancel tel_dsimprim 
                                  WITH FRAME f_atencao.

                     IF   FRAME-VALUE = tel_dscancel   THEN
                          DO:
                              par_flgcance = TRUE.
                              LEAVE.
                          END.

                     HIDE FRAME f_atencao NO-PAUSE.

                     DO aux_contador = 1 TO glb_nrdevias:

                        UNIX SILENT VALUE("script/escrava " + aux_nmarqimp).
                        PAUSE 2 NO-MESSAGE.

                     END.  /*  Fim do DO .. TO  */

                     UNIX SILENT VALUE("rm " + aux_nmarqimp + " 2> /dev/null").

                     LEAVE.

                  END.  /*  Fim do DO WHILE TRUE  */

                  HIDE FRAME f_atencao NO-PAUSE.
              END.
         ELSE
         IF   NOT AVAILABLE crapter   AND   NOT glb_flgmicro   THEN
              DO:
                  glb_cdcritic = 458.
                  RUN fontes/critic.p.
                  BELL.
                  HIDE MESSAGE NO-PAUSE.
                  MESSAGE glb_dscritic.
                  glb_cdcritic = 0.
                  PAUSE 2 NO-MESSAGE.
              END.
     END.
ELSE
     glb_cdcritic = 0.
     
/* .......................................................................... */

