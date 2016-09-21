/* .............................................................................

   Programa: Fontes/menu03.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/94                          Ultima atualizacao: 12/06/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela MENU03.

   Alteracoes: 28/06/2001 - Inclusao da opcao 9 - RISCO no menu principal.
                            Alteracao da opcao 9 - TAB016 para opcao
                            A - TAB016 (Junior).
                            
               12/06/2006 - Excluida opcao "TAB" (Diego).
                            
............................................................................. */

{ includes/var_online.i }

DEF        VAR aux_stimeout AS INT                                   NO-UNDO.

DEF        VAR user-prog    AS CHAR    FORMAT "x(60)"                NO-UNDO.
DEF        VAR choice       AS INT     INIT 1                        NO-UNDO.
DEF        VAR cmdcount     AS INT     INIT 10                       NO-UNDO.
DEF        VAR cmd          AS CHAR    FORMAT "x(40)" EXTENT 10      NO-UNDO.
DEF        VAR proglist     AS CHAR    EXTENT 10                     NO-UNDO.
DEF        VAR cmdlist      AS CHAR    INIT "123456789A"             NO-UNDO.
DEF        VAR lastchoice   AS INT     INIT 1                        NO-UNDO.
DEF        VAR qgo          AS LOGICAL INIT FALSE                    NO-UNDO.
DEF        VAR defstat      AS CHAR                                  NO-UNDO.

ASSIGN proglist[1]  = "AVALIS"
       proglist[2]  = "EMPRES"
       proglist[3]  = "EXTEMP"
       proglist[4]  = "ALTAVA"
       proglist[5]  = "CALPRE"
       proglist[6]  = "FINALI"
       proglist[7]  = "LCREDI"
       proglist[8]  = "PRESTA"
       proglist[9]  = "RISCO"
       proglist[10] = "TAB016"

       cmd[1]  = "1. AVALIS - Contratos Avalisados      "
       cmd[2]  = "2. EMPRES - Saldos de Emprestimo      "
       cmd[3]  = "3. EXTEMP - Extrato de Emprestimo     "
       cmd[4]  = "4. ALTAVA - Alteracao de Avalistas    "
       cmd[5]  = "5. CALPRE - Calculo de Prestacoes     "
       cmd[6]  = "6. FINALI - Finalidades               "
       cmd[7]  = "7. LCREDI - Linhas de Credito         "
       cmd[8]  = "8. PRESTA - Alteracao de Prestacoes   "
       cmd[9]  = "9. RISCO  - Risco de Pessoa Juridica  " 
       cmd[10] = "A. TAB016 - Emissao de Proposta Empr. " 
       .

FORM SKIP(1)
     "CONSULTAS"           AT 35 SKIP(1)
     cmd[1]  FORMAT "x(38)" AT 21 SKIP
     cmd[2]  FORMAT "x(38)" AT 21 SKIP
     cmd[3]  FORMAT "x(38)" AT 21 SKIP(1)
     "MANUTENCOES"         AT 34 SKIP(1)
     cmd[4]  FORMAT "x(38)" AT 21 SKIP
     cmd[5]  FORMAT "x(38)" AT 21 SKIP
     cmd[6]  FORMAT "x(38)" AT 21 SKIP
     cmd[7]  FORMAT "x(38)" AT 21 SKIP
     cmd[8]  FORMAT "x(38)" AT 21 SKIP
     cmd[9]  FORMAT "x(38)" AT 21 SKIP
     cmd[10] FORMAT "x(38)" AT 21 SKIP
     WITH TITLE glb_tldatela FRAME f-cmd NO-LABELS OVERLAY WIDTH 80.

DISPLAY cmd WITH ROW 4 FRAME f-cmd.
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
                 IF   glb_nmdatela <> "MENU03"   THEN
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

                 IF   proglist[choice] <> ""   THEN
                      DO:
                          glb_nmtelant = glb_nmdatela.
                          glb_nmdatela = proglist[choice].
                          HIDE FRAME f-cmd NO-PAUSE.
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
