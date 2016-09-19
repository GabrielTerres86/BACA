/* .............................................................................

   Programa: Fontes/anuida.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Outubro/97                         Ultima atualizacao: 25/01/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela ANUIDA.

   Alteracao - 11/08/1998 - Alterado para nao permitir que seja digitado a 
                            segunda anuidade cobrada pela Credicard. (Deborah)
                            /*  TEMPORARIO */

               15/01/2001 - Substituir CCOH por COOP (Margarete/Planner). 

               25/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
............................................................................. */

{ includes/var_online.i }

DEF VAR aux_cddopcao AS CHAR                                          NO-UNDO.
DEF VAR aux_tentaler AS INT                                           NO-UNDO.
DEF VAR tel_nrcartao AS DECIMAL FORMAT "9999,9999,9999,9999"          NO-UNDO.
DEF VAR tel_nmtitcrd AS CHAR    FORMAT "x(40)"                        NO-UNDO.
DEF VAR tel_nrdconta AS INT     FORMAT "zzzz,zz9,9"                   NO-UNDO.
DEF VAR tel_dtcobran AS DATE    FORMAT "99/99/9999"                   NO-UNDO.
DEF VAR tel_vlanuida AS DECIMAL FORMAT "zzz,zzz,zz9.99"               NO-UNDO.
DEF VAR tel_indpagto AS INT     FORMAT "9"                            NO-UNDO.
DEF VAR tel_dsdpagto AS CHAR    FORMAT "x(30)"                        NO-UNDO.

DEF VAR aux_confirma AS CHAR    FORMAT "!(1)"                         NO-UNDO.

FORM SKIP(3)
     glb_cddopcao AT 22 LABEL "Opcao" AUTO-RETURN
                        HELP "Entre com a opcao desejada (A ou C )"
                        VALIDATE(CAN-DO("A,C,",glb_cddopcao),
                                 "014 - Opcao errada.")
     SKIP(1)
     tel_nrcartao AT 21 LABEL "Cartao " AUTO-RETURN
                        HELP "Entre com o numero do cartao."
                        VALIDATE (tel_nrcartao > 0,"380 - Numero errado.")
     SKIP(1)
     tel_nrdconta AT 20 LABEL "Titular"
     tel_nmtitcrd NO-LABEL  FORMAT "x(30)"
     SKIP(1)
     tel_dtcobran AT 11 LABEL "Data da cobranca" AUTO-RETURN
                        HELP "Entre com a data da cobranca."
     SKIP(1)
     tel_vlanuida AT 10 LABEL "Valor da anuidade" AUTO-RETURN
                        HELP "Entre com o valor da anuidade."
     SKIP(1)
     tel_indpagto AT 05 LABEL "Indicador de pagamento" AUTO-RETURN
                        HELP "1 pela COOP  -  2 pelo associado"
                        VALIDATE(CAN-DO("0,1,2",STRING(tel_indpagto)),
                                "513 - Tipo errado.")
     tel_dsdpagto AT 30 NO-LABEL
     SKIP(2)
     WITH ROW 4 OVERLAY WIDTH 80 TITLE COLOR MESSAGE glb_tldatela
          SIDE-LABELS FRAME f_anuida.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   ASSIGN glb_cdcritic = 0.

   NEXT-PROMPT tel_nrcartao WITH FRAME f_anuida.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao tel_nrcartao WITH FRAME f_anuida.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "ANUIDA"   THEN
                 DO:
                     HIDE FRAME f_anuida.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF   glb_cddopcao = "A"   THEN
        DO:
            FIND crapcrd WHERE crapcrd.cdcooper = glb_cdcooper  AND
                               crapcrd.nrcrcard = tel_nrcartao  NO-LOCK
                               USE-INDEX crapcrd3 NO-ERROR.

            IF   NOT AVAILABLE crapcrd   THEN
                 DO:
                     glb_cdcritic = 546.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     CLEAR FRAME f_anuida NO-PAUSE.
                     NEXT.
                 END.

            ASSIGN tel_dtcobran = crapcrd.dtanucrd
                   tel_nmtitcrd = crapcrd.nmtitcrd
                   tel_nrdconta = crapcrd.nrdconta
                   tel_vlanuida = crapcrd.vlanucrd
                   tel_indpagto = crapcrd.inanucrd
                   tel_dsdpagto = IF crapcrd.inanucrd = 0
                                     THEN  " "
                                  ELSE IF crapcrd.inanucrd = 1 THEN
                                       " - pela COOP"
                                  ELSE " - pelo associado".

            DISPLAY tel_nrdconta tel_nmtitcrd tel_dtcobran tel_vlanuida
                    tel_indpagto tel_dsdpagto WITH FRAME f_anuida.

            IF   crapcrd.inanucrd = 1 THEN
                 DO:
                     glb_cdcritic = 603.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     /* CLEAR FRAME f_anuida NO-PAUSE. */
                     NEXT.
                 END.    
            
            FIND crawcrd WHERE crawcrd.cdcooper = glb_cdcooper      AND 
                               crawcrd.nrdconta = crapcrd.nrdconta  AND
                               crawcrd.nrctrcrd = crapcrd.nrctrcrd  NO-LOCK
                               USE-INDEX crawcrd1 NO-ERROR.

            IF   NOT AVAILABLE crawcrd   THEN
                 DO:
                     glb_cdcritic = 546.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic +  "crawcrd ".
                     CLEAR FRAME f_anuida NO-PAUSE.
                     NEXT.
                 END.

            IF   crawcrd.insitcrd <> 4 THEN
                 DO:
                     glb_cdcritic = 555.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     CLEAR FRAME f_anuida NO-PAUSE.
                     NEXT.
                 END.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               UPDATE tel_dtcobran tel_vlanuida tel_indpagto
                      WITH FRAME f_anuida.

               tel_dsdpagto = IF tel_indpagto = 0
                                 THEN " "
                                 ELSE  IF tel_indpagto = 1
                                 THEN " - pela COOP"
                                 ELSE " - pelo associado".

               DISPLAY tel_dsdpagto WITH FRAME f_anuida.

               IF   tel_dtcobran = ? AND tel_vlanuida = 0 AND tel_indpagto = 0
                    THEN
                    LEAVE.

               IF   (tel_dtcobran = ?) OR
                    (tel_dtcobran <= crawcrd.dtentreg) OR
                    (YEAR(tel_dtcobran) < 96 OR tel_dtcobran > glb_dtmvtolt)
                    THEN
                    DO:
                        glb_cdcritic = 13.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.

               IF   tel_vlanuida <= 0 THEN
                    DO:
                        glb_cdcritic = 269.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT-PROMPT tel_vlanuida WITH FRAME f_anuida.
                        NEXT.
                    END.

               IF   tel_indpagto <> 1 AND tel_indpagto <> 2 THEN
                    DO:
                        glb_cdcritic = 513.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT-PROMPT tel_indpagto WITH FRAME f_anuida.
                        NEXT.
                    END.

               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                 NEXT.

            IF   tel_dtcobran = ? AND tel_vlanuida = 0 AND tel_indpagto = 0 AND
                 crapcrd.vlanucrd <> 0 THEN
                 DO:
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE.

                        aux_confirma = "N".

                        glb_cdcritic = 78.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE COLOR NORMAL "ZERANDO ANUIDADE -->"
                        glb_dscritic UPDATE aux_confirma.
                        glb_cdcritic = 0.
                        LEAVE.

                     END.

                     IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                          aux_confirma <> "S"   THEN
                          DO:
                              glb_cdcritic = 79.
                              RUN fontes/critic.p.
                              BELL.
                              MESSAGE glb_dscritic.
                              glb_cdcritic = 0.
                              NEXT.
                          END.
                 END.
            ELSE
            IF   tel_dtcobran = ? AND tel_vlanuida = 0 AND tel_indpagto = 0 AND
                 crapcrd.vlanucrd = 0 THEN
                 DO:
                     glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     NEXT.
                 END.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE.

               aux_confirma = "N".

               glb_cdcritic = 78.
               RUN fontes/critic.p.
               BELL.
               MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
               glb_cdcritic = 0.
               LEAVE.

            END.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                 aux_confirma <> "S"   THEN
                 DO:
                     glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     NEXT.
                 END.

            DO TRANSACTION ON ERROR UNDO, LEAVE:

               DO aux_tentaler = 1 TO 5:

                  FIND crapcrd WHERE crapcrd.cdcooper = glb_cdcooper  AND
                                     crapcrd.nrcrcard = tel_nrcartao
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF   NOT AVAILABLE crapcrd   THEN
                       IF   LOCKED crapcrd   THEN
                            DO:
                                glb_cdcritic = 120.
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                       ELSE
                            glb_cdcritic = 546.

                  LEAVE.

               END.  /*  Fim do DO .. TO  --  Tenta ler crapcrd  */

               IF   glb_cdcritic > 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        CLEAR FRAME f_anuida NO-PAUSE.
                        NEXT.
                    END.

               ASSIGN crapcrd.dtanucrd = tel_dtcobran
                      crapcrd.vlanucrd = tel_vlanuida
                      crapcrd.inanucrd = tel_indpagto.

               RELEASE crapcrd.

               CLEAR FRAME f_anuida NO-PAUSE.

            END. /* Fim da transacao */

        END.
   ELSE
   IF   glb_cddopcao = "C"   THEN
        DO:
            FIND crapcrd WHERE crapcrd.cdcooper = glb_cdcooper  AND
                               crapcrd.nrcrcard = tel_nrcartao
                               USE-INDEX crapcrd3 NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapcrd   THEN
                 DO:
                     glb_cdcritic = 546.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     CLEAR FRAME f_anuida NO-PAUSE.
                     NEXT.
                 END.

            ASSIGN tel_dtcobran = crapcrd.dtanucrd
                   tel_nmtitcrd = crapcrd.nmtitcrd
                   tel_nrdconta = crapcrd.nrdconta
                   tel_vlanuida = crapcrd.vlanucrd
                   tel_indpagto = crapcrd.inanucrd
                   tel_dsdpagto = IF crapcrd.inanucrd = 0
                                     THEN " "
                                     ELSE IF crapcrd.inanucrd = 1
                                     THEN " - pela COOP"
                                     ELSE " - pelo associado".

            DISPLAY tel_nrdconta tel_nmtitcrd tel_dtcobran tel_vlanuida
                    tel_indpagto tel_dsdpagto WITH FRAME f_anuida.
        END.

END.  /*  Fim do DO WHILE TRUE  */
/* .......................................................................... */
