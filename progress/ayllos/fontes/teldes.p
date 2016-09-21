/*  Alteracao: 17/04/97 - Edson  
               12/09/06 - Excluida opcao "TAB" (Diego) */

DEF VAR tela AS CHAR    FORMAT "x(78)" EXTENT 16                     NO-UNDO.
DEF VAR arq  AS CHAR    FORMAT "x(30)" LABEL " Nome do arquivo"      NO-UNDO.
DEF VAR arqn AS CHAR    FORMAT "x(30)" LABEL " Nome do arquivo"      NO-UNDO.

DEF VAR resp AS LOGICAL FORMAT "SIM/NAO" INIT TRUE
                        LABEL " Arquivo nao existe! Criar? S/N"      NO-UNDO.

DEF VAR alte AS LOGICAL FORMAT "SIM/NAO" LABEL " Alterar? S/N"       NO-UNDO.

DEF VAR aban AS LOGICAL FORMAT "SIM/NAO" LABEL " Abandonar? S/N"     NO-UNDO.

DEF VAR contador AS INT                                              NO-UNDO.
DEF VAR contalin AS INT                                              NO-UNDO.
DEF VAR coluna   AS INT LABEL "Coluna"                               NO-UNDO.

DEF VAR colun_01 AS INT  FORMAT "z9"                                 NO-UNDO.
DEF VAR colun_02 AS INT  FORMAT "z9"                                 NO-UNDO.

DEF VAR texto    AS CHAR FORMAT "x(78)"                              NO-UNDO.
DEF VAR arqsaida AS CHAR                                             NO-UNDO.

DEF NEW SHARED VAR shr_dslistel AS CHAR                              NO-UNDO.

FORM texto AT 1 SKIP(2) WITH NO-BOX NO-LABEL FRAME f_titulo.

FORM "   1   5   10   15   20   25   30   35   40" AT  1
     "   45   50   55   60   65   70   75 78   "   AT 44
     SKIP
     "   I...I....I....I....I....I....I....I....I" AT  1
     "....I....I....I....I....I....I....I..I   "   AT 44
     WITH NO-BOX NO-LABEL WIDTH 84 FRAME f_label_1.

FORM
     "   I...I....I....I....I....I....I....I....I" AT  1
     "....I....I....I....I....I....I....I..I   "   AT 44
     SKIP
     "   1   5   10   15   20   25   30   35   40" AT  1
     "   45   50   55   60   65   70   75 78   "   AT 44
     WITH NO-BOX NO-LABEL WIDTH 84 FRAME f_label_2.

FORM colun_01 AT  1 "." AT  3
     texto    AT  4 "." AT 82
     colun_02 AT 83
     WITH NO-BOX NO-LABEL WIDTH 84 DOWN FRAME f_texto.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   PAUSE(0).

   UPDATE arq VALIDATE(arq <> "","O nome do arquivo deve ser infomado!")
          WITH ROW 1 OVERLAY SIDE-LABELS WIDTH 80 FRAME f_arq

   EDITING:

          READKEY.

          IF   LASTKEY = KEYCODE("F7")   THEN
               DO:
                   shr_dslistel = arq.
                   RUN fontes/listatel.p.
                   IF   shr_dslistel <> "" THEN
                         DO:
                             arq = shr_dslistel.
                             DISPLAY arq WITH FRAME f_arq.
                         END.
               END.

          APPLY LASTKEY.
   END.

   IF   SEARCH(arq) = ?   THEN
        DO:
            BELL.
            UPDATE resp WITH ROW 1 OVERLAY SIDE-LABELS WIDTH 80 FRAME f_resp.
            IF   NOT resp   THEN
                 NEXT.
            DO contador = 1 TO 16:
               tela[contador] = "".
            END.
            CLEAR FRAME f_tela ALL NO-PAUSE.
            HIDE FRAME f_resp.
        END.
   ELSE
        DO:
            ASSIGN resp = TRUE
                   alte = FALSE
                   aban = FALSE.

            INPUT FROM VALUE(arq) NO-ECHO.
            DO contador = 1 TO 16:
               SET tela[contador].
            END.
            INPUT CLOSE.
            DISPLAY tela WITH FRAME f_tela.
            PAUSE(0).
            UPDATE alte WITH ROW 2 COLUMN 61 NO-BOX OVERLAY
                   SIDE-LABELS FRAME f_alte.
            IF   NOT alte   THEN
                 DO:
                     HIDE FRAME f_tela.
                     HIDE FRAME f_alte.
                     NEXT.
                 END.

            HIDE FRAME f_alte.
        END.

   coluna = 1.
   DISPLAY coluna FORMAT "z9"
           WITH ROW 2 COLUMN 69 SIDE-LABELS OVERLAY NO-BOX FRAME f_coluna.

   SET tela HELP "Tecle F12 para imprimir o lay-out da tela"
       WITH FRAME f_tela ROW 4 TITLE " LAY-OUT DE TELAS " NO-LABELS

   EDITING:
            READKEY.

            IF   LASTKEY = KEYCODE("LEFT")        OR
                 LASTKEY = KEYCODE("BACKSPACE")   THEN
                 IF   coluna = 1   THEN
                      DO:
                          BELL.
                          NEXT.
                      END.
                 ELSE
                      coluna = coluna - 1.
            ELSE
            IF   LASTKEY = KEYCODE("BACK-TAB")   OR
                 LASTKEY = KEYCODE("RETURN")     THEN
                 coluna = 1.
            ELSE
            IF   LASTKEY = KEYCODE("F12")   THEN
                 DO:
                     assign coluna   = 1
                            contador = 0
                            arqsaida = "rl/layout" + STRING(TIME) + ".lst".

                     MESSAGE "Imprimindo" arq.

                     OUTPUT TO VALUE(arqsaida) PAGED.

                     texto = "TELA: " + arq.

                     PUT CONTROL "\0332\033x0\022\033\115" NULL.

                     DISPLAY texto WITH FRAME f_titulo.

                     VIEW FRAME f_label_1.

                     DO contalin = 5 TO 20:

                        assign contador = contador + 1
                               colun_01 = contalin
                               colun_02 = contalin
                               texto    = tela[contador].

                        DISPLAY colun_01 texto colun_02 WITH FRAME f_texto.

                        DOWN WITH FRAME f_texto.

                     END.  /*  Fim do DO .. TO  */

                     VIEW FRAME f_label_2.

                     PUT CONTROL "\0332\033x0\022\033\120" NULL.

                     OUTPUT CLOSE.

                     UNIX SILENT VALUE("lx " + arqsaida + " > /dev/null").

                     HIDE MESSAGE NO-PAUSE.
                 END.
            ELSE
            IF   LASTKEY = KEYCODE("F13")   THEN
                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    UPDATE arqn VALIDATE(arqn <> "",
                                     "O nome do arquivo deve ser infomado!")
                        WITH ROW 1 OVERLAY SIDE-LABELS WIDTH 80
                             TITLE " SALVAR COMO " FRAME f_arqn.

                    IF   SEARCH(arqn) <> ?   THEN
                         DO:
                             MESSAGE "ARQUIVO JA EXISTE ->" arqn.
                             NEXT.
                         END.

                    arq = arqn.

                    LEAVE.

                 END.  /*  Fim do DO WHILE TRUE  */
            ELSE
            IF   LASTKEY = KEYCODE("DEL-CHAR")   OR
                 LASTKEY = KEYCODE("INS")        THEN
                 DO:
                     APPLY LASTKEY.
                     NEXT.
                 END.
            ELSE
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 DO:
                     BELL.
                     UPDATE aban WITH ROW 2 COLUMN 59 NO-BOX OVERLAY
                                      SIDE-LABELS FRAME f_aban.
                     HIDE FRAME f_aban.
                     coluna = 1.

                     IF   aban   THEN
                          APPLY KEYCODE("F4").
                 END.
            ELSE
            IF   LASTKEY <> KEYCODE("CURSOR-UP")     AND
                 LASTKEY <> KEYCODE("CURSOR-DOWN")   THEN
                 coluna = coluna + 1.

            IF   coluna > 78   THEN
                 coluna = 79.

            APPLY LASTKEY.

            DISPLAY coluna FORMAT "z9"
                    WITH ROW 2 COLUMN 69 SIDE-LABELS
                         OVERLAY NO-BOX FRAME f_coluna.

   END.

   OUTPUT TO VALUE(arq).

   DO contador = 1 TO 16:

      EXPORT tela[contador].

   END.

   OUTPUT CLOSE.

   HIDE FRAME f_tela NO-PAUSE.

END.

HIDE ALL NO-PAUSE.
