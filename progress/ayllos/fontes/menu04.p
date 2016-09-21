/* .............................................................................

   Programa: Fontes/menu04.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91.                        Ultima atualizacao: 12/09/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela MENU04.

   Alteracoes: 21/09/94 - Inclusao da tela RELLOT (Edson/Odair).

               06/12/94 - Inclusao das telas LANRDA e LANRGT (Odair).

               15/12/95 - Inclusao das telas LANAUT e LANFAT (Odair).

               11/04/96 - Inclusao da tela LANPPR (Odair).

               18/03/97 - Inclusao da LANSEG e LANCRD (Deborah).

               08/10/97 - Inclusao da tela LANCAR (Odair).

               04/03/98 - Incluir a tela LANCOB (Deborah).

               29/06/99 - Acertar letras de menu apos opcao 5 (Odair)

             06/04/2001 - Incluir a tela BCAIXA (Margarete/Planner).
             
             12/09/2006 - Excluida opcao "TAB" (Diego).
             
............................................................................. */

{ includes/var_online.i }

DEF        VAR aux_stimeout AS INT                                    NO-UNDO.

DEF        VAR user-prog    AS CHAR    FORMAT "x(60)"                 NO-UNDO.
DEF        VAR choice       AS INT     INIT 1                         NO-UNDO.
DEF        VAR cmdcount     as INT     INIT 28                        NO-UNDO.
DEF        VAR cmd          as CHAR    FORMAT "x(40)" EXTENT 28       NO-UNDO.
DEF        VAR proglist     as CHAR    EXTENT 28                      NO-UNDO.
DEF        VAR cmdlist      as CHAR INIT "123456789ABCDEFGHIJKLMNOPQRS"
                                                                      NO-UNDO.
DEF        VAR lastchoice   as INT     INIT 1                         NO-UNDO.
DEF        VAR qgo          as LOGICAL INIT FALSE                     NO-UNDO.
DEF        VAR defstat      as CHAR                                   NO-UNDO.

ASSIGN proglist[1]  = "BCAIXA"    proglist[2]  = "LANAPL" 
       proglist[3]  = "LANAUT"    proglist[4]  = "LANCAP"
       proglist[5]  = "LANCAR"    proglist[6]  = "LANCOB"
       proglist[7]  = "LANCON"    proglist[8]  = "LANCPL"
       proglist[9]  = "LANCRD"    proglist[10] = "LANCTR"
       proglist[11] = "LANDPV"    proglist[12] = "LANEMP"
       proglist[13] = "LANFAT"    proglist[14] = "LANLCR"
       proglist[15] = "LANPLA"    proglist[16] = "LANPPR"
       proglist[17] = "LANRDA"    proglist[18] = "LANRGT"
       proglist[19] = "LANSEG"    proglist[20] = "LOTE"
      
       proglist[21] = "DCTROR" proglist[22] = "PROCES"
       proglist[23] = "SUMLOT" proglist[24] = "LANREQ"
       proglist[25] = "LANRTR" proglist[26] = "LOTREQ"
       proglist[27] = "LOTRTR" proglist[28] = "RELLOT"

       cmd[1]  = "1. BCAIXA - Boletim de Caixa          "
       cmd[2]  = "2. LANAPL - Lancamentos de Aplicacoes "
       cmd[3]  = "3. LANAUT - Lancamentos Automaticos   "
       cmd[4]  = "4. LANCAP - Lancamentos de Capital    "
       cmd[5]  = "5. LANCAR - Lancamentos Credicard     "
       cmd[6]  = "6. LANCOB - Lancamentos de Cobranca   "
       cmd[7]  = "7. LANCON - Lanc. Cheques da Consumo  "
       cmd[8]  = "8. LANCPL - Lanc. Contratos de Planos "
       cmd[9]  = "9. LANCRD - Lanc. Propostas Credicard "
       cmd[10] = "A. LANCTR - Lanc. Contratos Emprestimo"
       cmd[11] = "B. LANDPV - Lancamentos Dep. a Vista  "
       cmd[12] = "C. LANEMP - Lancamentos de Emprestimos"
       cmd[13] = "D. LANFAT - Lancamentos de Faturas    "
       cmd[14] = "E. LANLCR - Lanc. de Limite de Credito"
       cmd[15] = "F. LANPLA - Lancamentos de Planos     "
       cmd[16] = "G. LANPPR - Lanc. de Poupanca Program."
       cmd[17] = "H. LANRDA - Lanc. de Aplicacoes RDCA  "
       cmd[18] = "I. LANRGT - Lanc. de Resgates RDCA    "
       cmd[19] = "J. LANSEG - Lanc. de Seguro Casa      "
       cmd[20] = "K. LOTE   - Capa de Lote              "
       cmd[21] = "L. DCTROR - Contra-Ordens             "
       cmd[22] = "M. PROCES - Solicitacao de Processo   "
       cmd[23] = "N. SUMLOT - Sumario de Lotes          "
       cmd[24] = "O. LANREQ - Lancamento de Requisicoes "
       cmd[25] = "P. LANRTR - Lanc. Req. Chq. Transfer. "
       cmd[26] = "Q. LOTREQ - Lotes de Requisicoes      "
       cmd[27] = "R. LOTRTR - Lotes Req. Chq. Transfer. "
       cmd[28] = "S. RELLOT - Lotes Digitados no Dia    ".

FORM "MOVIMENTO"            AT 35 SKIP
     cmd[1]  FORMAT "x(38)" AT 1
     cmd[2]  FORMAT "x(38)" AT 41 SKIP
     cmd[3]  FORMAT "x(38)" AT 1
     cmd[4]  FORMAT "x(38)" AT 41 SKIP
     cmd[5]  FORMAT "x(38)" AT 1
     cmd[6]  FORMAT "x(38)" AT 41 SKIP
     cmd[7]  FORMAT "x(38)" AT 1
     cmd[8]  FORMAT "x(38)" AT 41 SKIP
     cmd[9]  FORMAT "x(38)" AT 1
     cmd[10] FORMAT "x(38)" AT 41 SKIP
     cmd[11] FORMAT "x(38)" AT 1
     cmd[12] FORMAT "x(38)" AT 41 SKIP
     cmd[13] FORMAT "x(38)" AT 1
     cmd[14] FORMAT "x(38)" AT 41 SKIP
     cmd[15] FORMAT "x(38)" AT 1
     cmd[16] FORMAT "x(38)" AT 41 SKIP
     cmd[17] FORMAT "x(38)" AT 1
     cmd[18] FORMAT "x(38)" AT 41 SKIP
     cmd[19] FORMAT "x(38)" AT 1  
     CMD[20] FORMAT "x(38)" AT 41 SKIP

     "DIVERSOS"             AT 36 SKIP
     cmd[21] FORMAT "x(38)" AT 1
     cmd[22] FORMAT "x(38)" AT 41
     cmd[23] FORMAT "x(38)" AT 1
     cmd[24] FORMAT "x(38)" AT 41
     cmd[25] FORMAT "x(38)" AT 1
     cmd[26] FORMAT "x(38)" AT 41
     cmd[27] FORMAT "x(38)" AT 1
     cmd[28] FORMAT "x(38)" AT 41
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
                 IF   glb_nmdatela <> "MENU04"   THEN
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
             IF   LASTKEY = KEYCODE("LEFT")  OR
                  LASTKEY = KEYCODE("UP")    THEN
                  DO:
                      choice = choice - 1.
                      IF   choice = 0   THEN
                           choice = cmdcount.
                           NEXT GETCHOICE.
                  END.
             ELSE
                  IF  (LASTKEY = KEYCODE("RIGHT")  OR
                       LASTKEY = KEYCODE(" ")      OR
                       LASTKEY = KEYCODE("DOWN"))  THEN
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
