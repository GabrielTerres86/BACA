/* .............................................................................

   Programa: Fontes/erroexec.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Novembro/91                       Ultima atualizacao: 14/09/2006

   Dados referentes ao programa:

   Frequencia: Diario (Batch)
   Objetivo  : Mostrar a o menu de opcoes ao operador.
   
   Alteracoes: 14/09/2006 - Excluida opcao "TAB" (Diego).

............................................................................. */

DEF SHARED VAR glb_cdopcoes AS INT     FORMAT "z9"                   NO-UNDO.
DEF SHARED VAR glb_cdprogra AS CHAR    FORMAT "x(10)"                NO-UNDO.
DEF SHARED VAR glb_cdcritic AS INT     FORMAT "zz9"                  NO-UNDO.
DEF SHARED VAR glb_dscritic AS CHAR    FORMAT "x(40)"                NO-UNDO.

DEF        VAR aux_dstitulo AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR aux_linhaopc AS CHAR    FORMAT "x(15)"                NO-UNDO.

DEF        VAR user-prog    AS CHAR    FORMAT "x(60)"                NO-UNDO.
DEF        VAR choice       AS INT     INIT 1                        NO-UNDO.
DEF        VAR cmdcount     AS INT     INIT 3                        NO-UNDO.
DEF        VAR cmd          AS CHAR    FORMAT "x(40)" EXTENT 3       NO-UNDO.
DEF        VAR cmdlist      AS CHAR    INIT "123"                    NO-UNDO.
DEF        VAR lastchoice   AS INT     INIT 1                        NO-UNDO.
DEF        VAR qgo          AS LOGICAL INIT FALSE                    NO-UNDO.
DEF        VAR defstat      AS CHAR                                  NO-UNDO.

cmd[1] = "1. Reexecutar ".
cmd[2] = "2. Proximo    ".
cmd[3] = "3. Abortar    ".

FORM    SKIP(1)
        cmd[1] FORMAT "x(14)" AT 9 SKIP
        cmd[2] FORMAT "x(14)" AT 9 SKIP
        cmd[3] FORMAT "x(14)" AT 9 SKIP(1)
WITH TITLE aux_dstitulo FRAME f-cmd NO-LABELS
     OVERLAY WIDTH 33 CENTERED.

aux_dstitulo = " Erro na execucao do " + glb_cdprogra + " ".

DISPLAY cmd WITH ROW 6 FRAME f-cmd.
COLOR DISPLAY MESSAGES cmd[choice] WITH FRAME f-cmd.

GETCHOICE:
REPEAT:
        IF   RETRY    THEN
             DO:
                 DISPLAY cmd WITH FRAME f-cmd.
                 COLOR DISPLAY MESSAGES cmd[choice] WITH FRAME f-cmd.
             END.

        IF   lastchoice NE choice   THEN
             DO:
                 COLOR DISPLAY NORMAL cmd[lastchoice] WITH FRAME f-cmd.
                 lastchoice = choice.
                 COLOR DISPLAY MESSAGES cmd[choice] WITH FRAME f-cmd.
             END.

        READKEY.
        HIDE MESSAGE NO-PAUSE.

        IF   (LASTKEY = KEYCODE("UP")      OR
              LASTKEY = KEYCODE("LEFT"))   THEN
              DO:
                  choice = choice - 1.
                  IF   choice = 0   THEN
                       choice = cmdcount.
                       NEXT GETCHOICE.
              END.
         ELSE
              IF   (LASTKEY = KEYCODE("DOWN")   OR
                    LASTKEY = KEYCODE("RIGHT")  OR
                    LASTKEY = KEYCODE(" "))   THEN
                    DO:
                        choice = choice + 1.
                        IF   choice GT cmdcount   THEN
                             choice = 1.
                        NEXT GETCHOICE.
                    END.
               ELSE
                    IF   KEYFUNCTION(LASTKEY) = "HOME"   THEN
                         DO:
                             choice = 1.
                             NEXT GETCHOICE.
                         END.
                    ELSE
                         IF   INDEX(cmdlist,KEYLABEL(LASTKEY)) GT 0   THEN
                              DO:
                                  choice = INDEX(cmdlist,KEYLABEL(LASTKEY)).
                                  qgo    = TRUE.
                              END.

        IF   LASTKEY = KEYCODE("RETURN")   OR
             KEYFUNCTION(LASTKEY) = "GO"   OR qgo   THEN
             DO:
                 IF   lastchoice NE choice   THEN
                      DO:
                          COLOR DISPLAY NORMAL cmd[lastchoice] WITH FRAME f-cmd.
                          lastchoice = choice.
                          COLOR DISPLAY MESSAGES cmd[choice] WITH FRAME f-cmd.
                      END.

                 glb_cdopcoes = choice.

                 glb_cdcritic = 202.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE ("echo " +
                                    STRING(TIME,"HH:MM:SS") + " - " +
                                    glb_cdprogra + "' --> '" + glb_dscritic +
                                    " " + cmd[choice] +
                                    " >> log/proc_batch.log").

                 HIDE FRAME f-cmd NO-PAUSE.
                 RETURN.

             END.
        ELSE
             DO:
                 BELL.
                 MESSAGE "Escolha invalida, tente novamente!".
             END.
END.  /* GETCHOICE */

/* .......................................................................... */
