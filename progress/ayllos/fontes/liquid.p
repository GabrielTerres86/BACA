/* .............................................................................

   Programa: Fontes/liquid.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Junho/94.                           Ultima atualizacao: 23/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LIQUID.
               Manutencao da tabela de taxa de emprestimos para liquidacoes.

   Alteracoes: 02/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               23/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
............................................................................. */

{ includes/var_online.i } 

DEF        VAR tel_dsliquid AS LOGICAL FORMAT "S/N"                  NO-UNDO.

DEF        VAR aux_dsacesso AS CHAR    FORMAT "x(50)"                NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.

FORM  SKIP (4)
      "Opcao:"     AT 4
      glb_cddopcao AT 11 NO-LABEL
      HELP "Entre com a opcao desejada (A ou C)"
      VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C","014 - Opcao errada.")
      AUTO-RETURN

      SKIP (3)
      tel_dsliquid AT 15 LABEL "Utiliza a taxa do mes corrente? (S/N)"
      HELP
      "S: para usar taxa atual, N: para usar taxa do mes anterior"

      SKIP (7)
      WITH SIDE-LABELS TITLE COLOR MESSAGE
      " Manutencao da taxa de liquidacao dos emprestimos "
      ROW 4 COLUMN 1 OVERLAY WIDTH 80 FRAME f_liquid.

glb_cddopcao = "C".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DISPLAY glb_cddopcao WITH FRAME f_liquid.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      PROMPT-FOR glb_cddopcao WITH FRAME f_liquid.

      LEAVE.
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "LIQUID"   THEN
                 DO:
                     HIDE FRAME f_liquid.
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

   IF   INPUT glb_cddopcao = "A" THEN
        DO:
            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               DO  aux_contador = 1 TO 10:

                   FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                      craptab.nmsistem = "CRED"         AND
                                      craptab.tptabela = "USUARI"       AND
                                      craptab.cdempres = 11             AND
                                      craptab.cdacesso = "TAXATABELA"   AND
                                      craptab.tpregist = 000
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE craptab   THEN
                        IF   LOCKED craptab   THEN
                             DO:
                                RUN sistema/generico/procedures/b1wgen9999.p
                                PERSISTENT SET h-b1wgen9999.
                                
                                RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                                                     INPUT "banco",
                                                     INPUT "craptab",
                                                     OUTPUT par_loginusr,
                                                     OUTPUT par_nmusuari,
                                                     OUTPUT par_dsdevice,
                                                     OUTPUT par_dtconnec,
                                                     OUTPUT par_numipusr).
                                
                                DELETE PROCEDURE h-b1wgen9999.
                                
                                ASSIGN aux_dadosusr = 
                                "077 - Tabela sendo alterada p/ outro terminal.".
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 3 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                              " - " + par_nmusuari + ".".
                                
                                HIDE MESSAGE NO-PAUSE.
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 5 NO-MESSAGE.
                                LEAVE.
                                END.
                                                                
                                NEXT.

                             END.
                        ELSE
                             DO:
                                 glb_cdcritic = 396.
                                 CLEAR FRAME f_liquid.
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

               tel_dsliquid = IF   INTEGER(SUBSTRING
                                   (craptab.dstextab,1,1)) = 0
                                   THEN FALSE
                                   ELSE TRUE.

               DISPLAY tel_dsliquid WITH FRAME f_liquid.

               IF   tel_dsliquid  THEN
                    DO:
                        glb_cdcritic = 397.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT.
                    END.

               DO WHILE TRUE:

                  SET tel_dsliquid WITH FRAME f_liquid.

                  DO WHILE TRUE ON ENDKEY UNDO, LEAVE.

                     ASSIGN aux_confirma = "N"
                            glb_cdcritic = 78.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                     LEAVE.
                  END.

                  IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                       aux_confirma <> "S"   THEN
                       DO:
                           glb_cdcritic = 79.
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic.
                           LEAVE.
                       END.

                  craptab.dstextab = IF   tel_dsliquid THEN "1"
                                                       ELSE "0".

                  IF   tel_dsliquid   THEN
                       DO:
                           glb_nmdatela = "TAXMES".
                           HIDE FRAME f_liquid NO-PAUSE.
                           RETURN.
                       END.

                  LEAVE.

               END.

            END. /* Fim da transacao */

            RELEASE craptab.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                 NEXT.

            CLEAR FRAME f_liquid NO-PAUSE.

        END.
   ELSE
        IF   INPUT glb_cddopcao = "C" THEN
             DO:
                 FIND craptab WHERE craptab.cdcooper  = glb_cdcooper  AND
                                    craptab.nmsistem = "CRED"         AND
                                    craptab.tptabela = "USUARI"       AND
                                    craptab.cdempres = 11             AND
                                    craptab.cdacesso = "TAXATABELA"   AND
                                    craptab.tpregist = 000
                                    NO-LOCK NO-ERROR NO-WAIT.

                 IF   AVAILABLE craptab   THEN
                      DO:
                          tel_dsliquid = IF   INTEGER(SUBSTRING
                                              (craptab.dstextab,1,1)) = 0
                                              THEN FALSE
                                              ELSE TRUE.

                          DISPLAY tel_dsliquid WITH FRAME f_liquid.
                      END.
                 ELSE
                      DO:
                          glb_cdcritic = 396.
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          CLEAR FRAME f_liquid.
                          NEXT.
                      END.
             END.
END.
/* ..........................................................................*/
