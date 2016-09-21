/* .............................................................................

   Programa: Fontes/menu00.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91.                        Ultima atualizacao: 12/09/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela MENU00.

   Alteracoes : 04/08/2003 - Alterada a forma de executar os sub-menus (Julio). 
                13/04/2004 - Criadas novas rotinas(de 5 ate 9) (Mirtes)
                18/08/2005 - Criadas novas rotinas(10 ate 14) (Mirtes/Evandro)
                23/12/2005 - alterado para nao buscar as telas que sao
                             excluivas do progrid - busca somente idsistema = 1
                             (Rosangela).
                12/09/2006 - Excluida opcao "TAB" (Diego).

............................................................................. */

{ includes/var_online.i  }

DEF        VAR aux_stimeout AS INT                                   NO-UNDO.

DEF        VAR user-prog    AS CHAR    FORMAT "x(60)"                NO-UNDO.
DEF        VAR choice       AS INT     INIT 1                        NO-UNDO.
DEF        VAR cmdcount     AS INT     INIT 14                       NO-UNDO.
DEF        VAR cmd          AS CHAR    FORMAT "x(40)" EXTENT 14      NO-UNDO.
DEF        VAR proglist     AS CHAR    EXTENT 14                     NO-UNDO.
DEF        VAR cmdlist      AS CHAR    INIT "0123456789"             NO-UNDO.
DEF        VAR lastchoice   AS INT     INIT 1                        NO-UNDO.
DEF        VAR qgo          AS LOGICAL INIT FALSE                    NO-UNDO.
DEF        VAR defstat      AS CHAR                                  NO-UNDO.

ASSIGN proglist[1]  = "MENU01"
       proglist[2]  = "MENU02"
       proglist[3]  = "MENU03"
       proglist[4]  = "MENU04"
       proglist[5]  = "MENU05"
       proglist[6]  = "MENU06"
       proglist[7]  = "MENU07"
       proglist[8]  = "MENU08"
       proglist[9]  = "MENU09"
       proglist[10] = "MENU10"
       proglist[11] = "MENU11"
       proglist[12] = "MENU12"
       proglist[13] = "MENU13"
       proglist[14] = "MENU14".


ASSIGN cmd[1]  = " 1. Conta Corrente - Depositos a Vista ".
       cmd[2]  = " 2. Conta Corrente - Capital           ".
       cmd[3]  = " 3. Conta Corrente - Emprestimos       ".
       cmd[4]  = " 4. Modulo Digitacao                   ".
       cmd[5]  = " 5. Cadastros/Consultas                ".
       cmd[6]  = " 6. Processos                          ".
       cmd[7]  = " 7. Parametrizacao Conta Corrente      ".
       cmd[8]  = " 8. Parametrizacao Operacoes Credito   ".
       cmd[9]  = " 9. Parametrizacao Captacoes           ".
       cmd[10] = "10. Parametrizacao Cobranca            ".
       cmd[11] = "11. Parametrizacao Cartao Cred/Seguro  ".
       cmd[12] = "12. Parametrizacao Outros              ".
       cmd[13] = "13. Solicitacoes/Impressoes            ".
       cmd[14] = "14. Modulo Generico                    ".

FORM SKIP(1)
     cmd[1]  FORMAT "x(38)" AT 21 SKIP
     cmd[2]  FORMAT "x(38)" AT 21 SKIP
     cmd[3]  FORMAT "x(38)" AT 21 SKIP
     cmd[4]  FORMAT "x(38)" AT 21 SKIP
     cmd[5]  FORMAT "x(38)" AT 21 SKIP
     cmd[6]  FORMAT "x(38)" AT 21 SKIP
     cmd[7]  FORMAT "x(38)" AT 21 SKIP
     cmd[8]  FORMAT "x(38)" AT 21 SKIP
     cmd[9]  FORMAT "x(38)" AT 21 SKIP
     cmd[10] FORMAT "x(38)" AT 21 SKIP
     cmd[11] FORMAT "x(38)" AT 21 SKIP
     cmd[12] FORMAT "x(38)" AT 21 SKIP
     cmd[13] FORMAT "x(38)" AT 21 SKIP
     cmd[14] FORMAT "x(38)" AT 21 SKIP(1)
     WITH TITLE glb_tldatela FRAME f-cmd NO-LABELS OVERLAY WIDTH 80.

DISPLAY cmd WITH ROW 4 FRAME f-cmd.
COLOR DISPLAY MESSAGES cmd[choice] WITH FRAME f-cmd.

RUN fontes/verdata.p.


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

        MESSAGE "Use " + KBLABEL("END-ERROR") + " para retornar.".

        aux_stimeout = 0.

        DO WHILE TRUE:

           READKEY PAUSE 1.

           IF   LASTKEY = -1   THEN
                DO:
                    aux_stimeout = aux_stimeout + 1.

                    IF   aux_stimeout > glb_stimeout   THEN
                         QUIT.

                    NEXT.
                END.

           LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */

        HIDE MESSAGE NO-PAUSE.

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
             DO:
                 COLOR DISPLAY NORMAL cmd[choice] WITH FRAME f-cmd.
                 
                 RUN fontes/novatela.p.

                 IF   glb_nmdatela <> "MENU00"   THEN
                      DO:
                          HIDE FRAME f-cmd NO-PAUSE.
                          RETURN.
                      END.
                 ELSE
                      DO:
                          COLOR DISPLAY MESSAGES cmd[choice] WITH FRAME f-cmd.
                          NEXT.
                      END.
             END.
        ELSE
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
                                    choice =
                                      INDEX(cmdlist,KEY-FUNCTION(LASTKEY)) - 1.
   
                                    IF  choice = 1   THEN
                                        DO:
                                           READKEY PAUSE 1.
          
                                           IF  INDEX(cmdlist,
                                               KEY-FUNCTION(LASTKEY)) <> 0 THEN
                                               DO:
                                                  choice = INT(STRING(choice) +
                                                        KEY-FUNCTION(LASTKEY)).

                                                  IF  choice <= 14  THEN
                                                      qgo = TRUE.
                                                  ELSE
                                                      RETURN.
                                               END.
                                        END.
                                    ELSE
                                    IF  choice <> 0  THEN
                                        qgo = TRUE.
                                    ELSE
                                        RETURN.
                                 END.

        IF   LASTKEY = KEYCODE("RETURN")   OR
             KEYFUNCTION(LASTKEY) = "GO"   OR qgo   THEN
             DO:
                 
                 IF   lastchoice NE choice   THEN
                      DO:
                          COLOR DISPLAY NORMAL cmd[lastchoice] WITH FRAME f-cmd.
                          lastchoice = choice.
                          COLOR DISPLAY MESSAGES cmd[choice] WITH FRAME f-cmd.
                          PAUSE 0.
                      END.

                 IF   proglist[choice] <> ""   THEN
                      DO:
                          RUN fontes/ver_menu.p(INPUT choice, 
                                                INPUT cmd[choice]).  

                          RETURN.
                      END.

                 VIEW FRAME f-cmd.
                 qgo = FALSE.
                 NEXT GETCHOICE.
             END.
        ELSE
             DO:
                 BELL.
                 MESSAGE "Escolha invalida, tente novamente!".
             END.
END.  /* GETCHOICE */

/* .......................................................................... */

