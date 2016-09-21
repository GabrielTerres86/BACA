/* .............................................................................

   Programa: Fontes/sol075.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Abril/98

   Dados referentes ao programa:                 Ultima Alteracao : 06/09/2013

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela SOL075.

   Alteracoes: 27/01/2005 - Mudado o LABEL do campo "tel_tpemissa" de
                            "Por agencia/Por conta" para "Por PA/Por conta";
                            HELP de "para toda a agencia" para
                            "para todo o PAC";
                            Mudado o LABEL do campo "tel_nrdconta" de
                            "Agencia ou Conta/dv" para "PAC ou Conta/dv";
                            HELP de "Entre com a agencia" para 
                            "Entre com o PAC" (Evandro).

               05/07/2005 - Alimentado campo cdcooper da tabela crapsol (Diego).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               25/01/2010 - Alterado para poder ordenar as cartas(crps209)
                            por PAC (Diego).
                            
               06/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             

............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_nrdconta LIKE crapass.nrdconta                    NO-UNDO.
DEF        VAR tel_tpemissa AS INTEGER FORMAT "9"                    NO-UNDO.
DEF        VAR tel_dssituac AS CHAR    FORMAT "x(30)"                NO-UNDO.
DEF        VAR tel_nmprimtl LIKE crapass.nmprimtl                    NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.

DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrseqsol AS INT                                   NO-UNDO.
DEF        VAR aux_cdagenci AS INT                                   NO-UNDO.

FORM SPACE(1)
     WITH ROW 4  OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM SKIP (3)
     glb_cddopcao AT  25 LABEL "Opcao" AUTO-RETURN
                        HELP "Entre com a opcao desejada (C,E ou I)"
                        VALIDATE (glb_cddopcao = "C" OR
                                  glb_cddopcao = "E" OR glb_cddopcao = "I",
                                  "014 - Opcao errada.")
     SKIP (1)
     tel_tpemissa AT 14 LABEL "Por PA/Por conta"
                HELP "0 - emite para todo o PA ou 1 - emite para a conta"
                        VALIDATE (tel_tpemissa = 0 OR tel_tpemissa = 1,
                                  "014 - Opcao errada.")

     SKIP(1)
     tel_nrdconta AT 16 LABEL "PA ou Conta/dv"
                        HELP "Entre com o PA ou o numero da conta"
     tel_nmprimtl NO-LABELS FORMAT "x(35)"
     SKIP (1)
     tel_dssituac AT 22 LABEL "Situacao"
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_sol075.

VIEW FRAME f_moldura.

glb_cddopcao = "I".

PAUSE(0).

RUN fontes/inicia.p.

DO WHILE TRUE:

   IF   glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
         END.

   NEXT-PROMPT tel_tpemissa WITH FRAME f_sol075.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao tel_tpemissa tel_nrdconta WITH FRAME f_sol075.
      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "SOL075"   THEN
                 DO:
                     HIDE FRAME f_sol075.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <>  glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao =  glb_cddopcao.
        END.

   IF   tel_tpemissa = 1 THEN     /* Por conta */
        DO:
            glb_nrcalcul = tel_nrdconta.

            RUN fontes/digfun.p.

            IF   NOT glb_stsnrcal   THEN
                 DO:
                     glb_cdcritic = 8.
                     NEXT-PROMPT tel_nrdconta WITH FRAME f_sol075.
                     CLEAR FRAME f_sol075.
                     NEXT.
                 END.

            FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND 
                               crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapass   THEN
                 DO:
                     glb_cdcritic = 9.
                     NEXT-PROMPT tel_nrdconta WITH FRAME f_sol075.
                     CLEAR FRAME f_sol075.
                     NEXT.
                 END.

            tel_nmprimtl = crapass.nmprimtl.
            DISPLAY tel_nmprimtl WITH FRAME f_sol075.
            
            ASSIGN aux_cdagenci = crapass.cdagenci.
        END.
   ELSE                /* Por agencia*/
        DO:
            FIND crapage WHERE crapage.cdcooper = glb_cdcooper AND 
                               crapage.cdagenci = tel_nrdconta NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapage   THEN
                 DO:
                     glb_cdcritic = 15.
                     NEXT-PROMPT tel_nrdconta WITH FRAME f_sol075.
                     CLEAR FRAME f_sol075.
                     NEXT.
                 END.

            tel_nmprimtl = crapage.nmresage.
            DISPLAY tel_nmprimtl WITH FRAME f_sol075.
            
            ASSIGN aux_cdagenci = tel_nrdconta.
        END.

   IF   glb_cddopcao = "C" THEN
        DO:
            FIND FIRST crapsol WHERE crapsol.cdcooper  = glb_cdcooper   AND 
                                     crapsol.nrsolici  = 75             AND
                                     crapsol.dtrefere  = glb_dtmvtolt   AND
                                     crapsol.cdempres  = aux_cdagenci   AND
              INTEGER(SUBSTRING(crapsol.dsparame,1,8)) = tel_nrdconta
                                     NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapsol   THEN
                 DO:
                     glb_cdcritic = 115.
                     NEXT-PROMPT tel_tpemissa WITH FRAME f_sol075.
                     tel_dssituac = "".
                     DISPLAY tel_dssituac WITH FRAME f_sol075.
                     NEXT.
                 END.

            tel_dssituac = IF   crapsol.insitsol = 1
                                THEN "A FAZER"
                                ELSE "PROCESSADA".

            DISPLAY tel_dssituac WITH FRAME f_sol075.

        END.
   ELSE
        IF   glb_cddopcao = "E"   THEN
             DO:
                 DO TRANSACTION ON ENDKEY UNDO, LEAVE:

                    DO  aux_contador = 1 TO 10:

                        FIND FIRST crapsol WHERE
                                   crapsol.cdcooper  = glb_cdcooper  AND 
                                   crapsol.nrsolici  = 75            AND
                                   crapsol.dtrefere  = glb_dtmvtolt  AND
                                   crapsol.cdempres  = aux_cdagenci  AND
            INTEGER(SUBSTRING(crapsol.dsparame,1,8)) = tel_nrdconta
                                   USE-INDEX crapsol1
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                        IF   NOT AVAILABLE crapsol   THEN
                             IF   LOCKED crapsol   THEN
                                  DO:
                                      glb_cdcritic = 120.
                                      PAUSE 1 NO-MESSAGE.
                                      NEXT.
                                  END.
                             ELSE
                                  DO:
                                      ASSIGN glb_cdcritic = 115
                                             tel_dssituac = "".
                                      DISPLAY tel_dssituac WITH FRAME f_sol075.
                                      LEAVE.
                                  END.
                        ELSE
                             DO:
                                 aux_contador = 0.
                                 LEAVE.
                             END.
                    END.

                    IF   glb_cdcritic > 0 THEN
                         NEXT.

                    IF   crapsol.insitsol = 1 THEN
                         tel_dssituac = "A FAZER".
                    ELSE
                         tel_dssituac = "PROCESSADA".

                    DISPLAY tel_dssituac WITH FRAME f_sol075.

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                       ASSIGN aux_confirma = "N"
                              glb_cdcritic = 78.

                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                       glb_cdcritic = 0.
                       LEAVE.

                    END.

                    IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                         aux_confirma <> "S" THEN
                         DO:
                             ASSIGN glb_cdcritic = 79.
                             NEXT.
                         END.

                    DELETE crapsol.
                    CLEAR FRAME f_sol075 NO-PAUSE.

                 END. /* Fim da transacao */

                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                      NEXT.
             END.
        ELSE
             IF   glb_cddopcao = "I"   THEN
                  DO:
                      FIND LAST crapsol WHERE
                                crapsol.cdcooper = glb_cdcooper   AND 
                                crapsol.nrsolici = 75             AND
                                crapsol.dtrefere = glb_dtmvtolt
                                USE-INDEX crapsol1 NO-LOCK NO-ERROR.

                      IF   NOT AVAILABLE crapsol THEN
                           aux_nrseqsol = 1.
                      ELSE
                           aux_nrseqsol = crapsol.nrseqsol + 1.

                      FIND FIRST crapsol WHERE
                                 crapsol.cdcooper  = glb_cdcooper   AND 
                                 crapsol.nrsolici  = 75             AND
                                 crapsol.dtrefere  = glb_dtmvtolt   AND
                                 crapsol.cdempres  = aux_cdagenci   AND
          INTEGER(SUBSTRING(crapsol.dsparame,1,8)) = tel_nrdconta
                                 USE-INDEX crapsol1 NO-LOCK NO-ERROR.

                      tel_dssituac = " ".

                      IF   AVAILABLE crapsol   THEN
                           DO:
                               IF   crapsol.insitsol = 1 THEN
                                    tel_dssituac = "A FAZER".
                               ELSE
                                    tel_dssituac = "PROCESSADA".

                               ASSIGN glb_cdcritic = 118.
                               NEXT-PROMPT tel_nrdconta WITH FRAME f_sol075.
                               NEXT.
                           END.

                      DISPLAY tel_dssituac WITH FRAME f_sol075.

                      DO TRANSACTION ON ENDKEY UNDO, LEAVE:

                         CREATE crapsol.
                         ASSIGN crapsol.nrsolici = 75
                                crapsol.dtrefere = glb_dtmvtolt
                                crapsol.nrseqsol = aux_nrseqsol
                                crapsol.dsparame =
                                        STRING(tel_nrdconta,"99999999") + " " +
                                        STRING(tel_tpemissa,"9")       
                                crapsol.cdempres = aux_cdagenci
                                crapsol.insitsol = 1
                                crapsol.cdcooper = glb_cdcooper.

                      END. /* Fim da transacao */

                      RELEASE crapsol.

                      IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                           NEXT.
                  END.
END.

/* .......................................................................... */
