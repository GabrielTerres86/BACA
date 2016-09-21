/* .............................................................................

   Programa: Fontes/sol027.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : dezembro/92                        Ultima atualizacao: 02/02/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela sol027.

   Alteracoes: 09/12/2005 - Comentada opcao "A" e o campo tel_insoltrf (Diego).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
............................................................................. */

{ includes/var_online.i } 

DEF        VAR tel_insolnor AS DECIMAL FORMAT "9"                    NO-UNDO.
DEF        VAR tel_insoltrf AS DECIMAL FORMAT "9"                    NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

FORM SKIP(3)
     glb_cddopcao AT 13 LABEL "Opcao" AUTO-RETURN
                  HELP "Entre com a opcao desejada (C, E ou I)"
                  VALIDATE(CAN-DO("C,E,I",glb_cddopcao),"014 - Opcao errada.")
     SKIP(3)
     tel_insolnor AT 13 LABEL "Executa Pedido de Talonarios Normais" AUTO-RETURN
                  HELP
                 "Entre com o indicador da execucao (0-nao executa, 1-executa)."
                  VALIDATE(tel_insolnor < 2,"014 - Opcao errada.")

     /************************************************************************
     SKIP(1)
     tel_insoltrf AT 13 LABEL "Executa Pedido de Talonarios Transf." AUTO-RETURN
                  HELP
                 "Entre com o indicador da execucao (0-nao executa, 1-executa)."
                  VALIDATE(tel_insoltrf < 2,"014 - Opcao errada.")
     ************************************************************************/
     SKIP(8)
     WITH SIDE-LABELS TITLE " Execucao de Pedido de Talonarios "
          ROW 4 OVERLAY WIDTH 80 FRAME f_sol027.

glb_cddopcao = "C".

DO WHILE TRUE:

        RUN fontes/inicia.p.

        DISPLAY glb_cddopcao WITH FRAME f_sol027.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                 PROMPT-FOR glb_cddopcao
                            WITH FRAME f_sol027.
                 LEAVE.
        END.

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
             DO:
                 RUN fontes/novatela.p.
                 IF   CAPS(glb_nmdatela) <> "sol027"   THEN
                      DO:
                          HIDE FRAME f_sol027.
                          RETURN.
                      END.
                 ELSE
                      NEXT.
             END.

        IF   aux_cddopcao <> INPUT glb_cddopcao THEN
             DO:
                 { includes/acesso.i }
                 aux_cddopcao = INPUT glb_cddopcao.
             END.

        ASSIGN glb_cddopcao = INPUT glb_cddopcao.

    /**********************************************************************
        IF   INPUT glb_cddopcao = "A" THEN
             DO:
                 DO TRANSACTION ON ENDKEY UNDO, LEAVE:

                    DO  aux_contador = 1 TO 10:

                        FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                           craptab.nmsistem = "CRED"         AND
                                           craptab.tptabela = "USUARI"       AND
                                           craptab.cdempres = 11             AND
                                           craptab.cdacesso = "EXECPEDTAL"   AND
                                           craptab.tpregist = 001
                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                        IF   NOT AVAILABLE craptab   THEN
                             IF   LOCKED craptab   THEN
                                  DO:
                                      glb_cdcritic = 120.
                                      PAUSE 1 NO-MESSAGE.
                                      NEXT.
                                  END.
                             ELSE
                                  DO:
                                      glb_cdcritic = 115.
                                      CLEAR FRAME f_sol027.
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
                             NEXT.
                         END.

                   ASSIGN  tel_insolnor =
                           DECIMAL(SUBSTRING(craptab.dstextab,1,1)).

                           /****************************************
                           tel_insoltrf =
                           DECIMAL(SUBSTRING(craptab.dstextab,3,1)).
                           *****************************************/

                   DISPLAY tel_insolnor /* tel_insoltrf */ WITH FRAME f_sol027.

                   DO WHILE TRUE:

                      SET tel_insolnor /* tel_insoltrf */ WITH FRAME f_sol027.

                   /* tel_insoltrf = 0. */

                      craptab.dstextab = STRING(tel_insolnor,"9").
                                         /* + " " + STRING(tel_insoltrf,"9"). */

                      LEAVE.

                   END.


                 END. /* Fim da transacao */

                 RELEASE craptab.

                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                      NEXT.

                 CLEAR FRAME f_sol027 NO-PAUSE.

             END.
        ELSE
    **********************************************************************/
     
        IF   INPUT glb_cddopcao = "C" THEN
             DO:
                 FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                    craptab.nmsistem = "CRED"         AND
                                    craptab.tptabela = "USUARI"       AND
                                    craptab.cdempres = 11             AND
                                    craptab.cdacesso = "EXECPEDTAL"   AND
                                    craptab.tpregist = 001
                                    NO-LOCK NO-ERROR NO-WAIT.

                 IF   AVAILABLE craptab   THEN
                      DO:
                          ASSIGN  tel_insolnor =
                                  DECIMAL(SUBSTRING(craptab.dstextab,1,1)).
                                  
                                  /**************************************
                                  tel_insoltrf =
                                  DECIMAL(SUBSTRING(craptab.dstextab,3,1)).
                                  ***************************************/
                          DISPLAY tel_insolnor /* tel_insoltrf */
                                  WITH FRAME f_sol027.
                      END.
                 ELSE
                      DO:
                          glb_cdcritic = 115.
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          CLEAR FRAME f_sol027.
                          NEXT.
                      END.
             END.
        ELSE
        IF   INPUT glb_cddopcao = "E"   THEN
             DO:
                 DO TRANSACTION ON ENDKEY UNDO, LEAVE:

                    DO  aux_contador = 1 TO 10:
                        FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                                           craptab.nmsistem = "CRED"        AND
                                           craptab.tptabela = "USUARI"      AND
                                           craptab.cdempres = 11            AND
                                           craptab.cdacesso = "EXECPEDTAL"  AND
                                           craptab.tpregist = 001
                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                        IF   NOT AVAILABLE craptab   THEN
                             IF   LOCKED craptab   THEN
                                  DO:
                                      glb_cdcritic = 120.
                                      PAUSE 1 NO-MESSAGE.
                                      NEXT.
                                  END.
                             ELSE
                                  DO:
                                      glb_cdcritic = 115.
                                      CLEAR FRAME f_sol027.
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
                             NEXT.
                         END.

                    ASSIGN  tel_insolnor =
                            DECIMAL(SUBSTRING(craptab.dstextab,1,1)).
                            
                            /***************************************
                            tel_insoltrf =
                            DECIMAL(SUBSTRING(craptab.dstextab,3,1)).
                            ****************************************/

                    DISPLAY tel_insolnor /* tel_insoltrf */ WITH FRAME f_sol027.

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
                             NEXT.
                         END.

                    ASSIGN craptab.dstextab = "0 0".

                    CLEAR FRAME f_sol027 NO-PAUSE.

                 END. /* Fim da transacao */

                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*  F4 OU FIM  */
                      NEXT.
             END.
        ELSE
             IF   INPUT glb_cddopcao = "I"   THEN
                  DO:
                      DO TRANSACTION ON ENDKEY UNDO, LEAVE:

                         DO  aux_contador = 1 TO 10:

                             FIND craptab WHERE 
                                  craptab.cdcooper = glb_cdcooper   AND
                                  craptab.nmsistem = "CRED"         AND
                                  craptab.tptabela = "USUARI"       AND
                                  craptab.cdempres = 11             AND
                                  craptab.cdacesso = "EXECPEDTAL"   AND
                                  craptab.tpregist = 001
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                             IF   NOT AVAILABLE craptab   THEN
                                  IF   LOCKED craptab   THEN
                                       DO:
                                           glb_cdcritic = 120.
                                           PAUSE 1 NO-MESSAGE.
                                           NEXT.
                                       END.
                                  ELSE
                                       DO:
                                           glb_cdcritic = 115.
                                           CLEAR FRAME f_sol027.
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
                                  NEXT.
                              END.

                        ASSIGN  tel_insolnor = 0.
                             /* tel_insoltrf = 0. */

                        DISPLAY tel_insolnor /* tel_insoltrf */
                                WITH FRAME f_sol027.

                        DO WHILE TRUE:

                           SET tel_insolnor /* tel_insoltrf */
                               WITH FRAME f_sol027.

                        /* tel_insoltrf = 0. */

                           craptab.dstextab = STRING(tel_insolnor,"9").
                                        /* + " " + STRING(tel_insoltrf,"9"). */

                           LEAVE.

                        END.


                      END. /* Fim da transacao */

                      RELEASE craptab.

                      IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                           /* F4 OU FIM */
                           NEXT.

                      CLEAR FRAME f_sol027 NO-PAUSE.

                  END.
END.
/* .......................................................................... */
