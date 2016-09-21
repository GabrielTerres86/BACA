/* .............................................................................

   Programa: Fontes/menu01.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91.                        Ultima atualizacao: 12/09/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela MENU01.

   Alteracoes: 10/10/94 - Incluida a tela ESTOUR (Deborah).

               21/11/94 - Incluir a tela NOTJUS (Notificacoes e Justif) (Odair).

               24/11/94 - Alterado para modificar a posicao da tela ESTOUR
                          (Odair).

               06/11/94 - Alterado para incluir telas de aplicacao RDCA (Odair).

               20/06/95 - Incluir a tela Autoriz de Debito em Conta (Odair).

               16/10/95 - Incluir a tela Unific (Odair).

               15/04/96 - Incluir a tela EXTPPR (Deborah).

               10/10/97 - Incluir a tela ANUIDA.

               04/03/98 - Incluir telas CADCOB, NUMCOB e COBRAN (Deborah).

               12/03/98 - Incluir tela NUMMAT (Deborah).

               02/10/98 - Incluir a tela DOLFAT (Deborah).
               
               05/08/99 - Incluir a tela DEVOLU (Odair).

               29/02/00 - Incluir a tela PESQBC (Odair).

             10/04/2000 - Incluir a tela BLQRGT (Deborah).

             06/04/2001 - Incluir a tela Bancos (Margarete/Planner).  
             
             27/12/2001 - Incluir a tela MANCCF (Ze Eduardo).

             22/04/2003 - Incluir a tela GERIMP (Deborah).
             
             12/09/2006 - Excluida opcao "TAB" (Diego).
             
............................................................................. */

{ includes/var_online.i }

DEF      VAR aux_stimeout AS INT                                     NO-UNDO.

DEF      VAR user-prog    AS CHAR    FORMAT "x(60)"                  NO-UNDO.
DEF      VAR choice       AS INT     INIT 1                          NO-UNDO.
DEF      VAR cmdcount     AS INT     INIT 40                         NO-UNDO.
DEF      VAR cmd          AS CHAR    FORMAT "x(40)" EXTENT 40        NO-UNDO.
DEF      VAR proglist     AS CHAR    EXTENT 40                       NO-UNDO.
DEF      VAR lastchoice   AS INT     INIT 1                          NO-UNDO.
DEF      VAR qgo          AS LOGICAL INIT FALSE                      NO-UNDO.
DEF      VAR defstat      AS CHAR                                    NO-UNDO.

ASSIGN proglist[01] = "ANUIDA"
       proglist[02] = "APLICA"
       proglist[03] = "AUTORI"
       proglist[04] = "BANCOS"
       proglist[05] = "BLOQUE"
       proglist[06] = "BLQRGT"
       proglist[07] = "CADCOB"
       proglist[08] = "CANCEL"
       proglist[09] = "CARTAO"
       proglist[10] = "CCTROR"
       proglist[11] = "CHEQUE"
       proglist[12] = "CHQSAL"
       proglist[13] = "CHSAVU"
       proglist[14] = "COBRAN"
       proglist[15] = "CONALT"
       proglist[16] = "CONMAT"
       proglist[17] = "CONTA"
       proglist[18] = "CRIPED"
       
       proglist[19] = "DEVOLU"
       proglist[20] = "DISTRI"
       proglist[21] = "DOLFAT"
       proglist[22] = "ESTOUR"
       proglist[23] = "EXTPPR"
       proglist[24] = "EXTRAT"
       proglist[25] = "EXTRDA"
       proglist[26] = "LAUTOM"
       proglist[27] = "MANCCF"
       proglist[28] = "MANTAL"
       proglist[29] = "NOTJUS"
       proglist[30] = "NUMCHS"
       proglist[31] = "NUMCOB"
       proglist[32] = "NUMERA"
       proglist[33] = "PEDIDO"
       proglist[34] = "PESQBB"
       proglist[35] = "PESQBC"
       proglist[36] = "RESGAT"
       proglist[37] = "SALDOS"
       proglist[38] = "UNIFIC"
       proglist[39] = "VALCHS"
       proglist[40] = "GERIMP"
       
       

       cmd[01] = "ANUIDA Anuidade Credicard"
       cmd[02] = "APLICA Aplic. Financ. RDC"
       cmd[03] = "AUTORI Autoriz. Deb.Conta"
       cmd[04] = "BANCOS Cadastr. Bancos"
       cmd[05] = "BLOQUE Depos. Bloqueados "
       cmd[06] = "BLQRGT Bloqueio Resgates"
       cmd[07] = "CADCOB Cadastr. Cobranca "
       cmd[08] = "CANCEL Canc. Cheq.Salario"
       cmd[09] = "CARTAO Manut. Cartao Esp."   
       cmd[10] = "CCTROR Contra-Ordens     "
       cmd[11] = "CHEQUE Matriz de Cheques "
       cmd[12] = "CHQSAL Cons. Cheq.Salario"
       cmd[13] = "CHSAVU Cad.Chq.Sal.Avulso"
       cmd[14] = "COBRAN Consulta Cobranca "
       cmd[15] = "CONALT Cons. Alt.Tipo Cta"
       cmd[16] = "CONMAT Cons. p/matriculas"
       cmd[17] = "CONTA  Dados da Conta    "
       cmd[18] = "CRIPED Crit. Ped. Taloes "
       
       cmd[19] = "DEVOLU Devol. de Cheques "
       cmd[20] = "DISTRI Distr.Cheq.Salario"
       cmd[21] = "DOLFAT Dolar faturas Visa"
       cmd[22] = "ESTOUR Estouro/Devolucao "
       cmd[23] = "EXTPPR Extr. Poup. Progr."
       cmd[24] = "EXTRAT Extr. Conta-Corr. "
       cmd[25] = "EXTRDA Extr. Aplic. RDCA "
       cmd[26] = "LAUTOM Lanc. Automaticos "
       cmd[27] = "MANCCF Manutencao do CCF "
       cmd[28] = "MANTAL Manut. Talonarios "
       cmd[29] = "NOTJUS Notif./Justificat."
       cmd[30] = "NUMCHS Manut.Chq.Sal.Avul"
       cmd[31] = "NUMCOB Numeracao Cobranca"
       cmd[32] = "NUMERA Manut.Talon.Avulso"
       cmd[33] = "PEDIDO Lib./Bloq. Pedidos"
       cmd[34] = "PESQBB Pesquisa Cheque BB"
       cmd[35] = "PESQBC Lancamenos BANCOOB"
       cmd[36] = "RESGAT Resgate de RDCA   "
       cmd[37] = "SALDOS Saldos            "
       cmd[38] = "UNIFIC Unific. Aplic.RDCA"
       cmd[39] = "VALCHS Cheq.Sal.por Valor"
       cmd[40] = "GERIMP Gerencia impressao".
       

FORM SKIP(1)
     cmd[01] FORMAT "x(25)" AT 01 cmd[16] FORMAT "x(25)" AT 27
     cmd[31] FORMAT "x(25)" AT 53
     cmd[02] FORMAT "X(25)" AT 01 cmd[17] FORMAT "x(25)" AT 27
     cmd[32] FORMAT "x(25)" AT 53
     cmd[03] FORMAT "x(25)" AT 01 cmd[18] FORMAT "X(25)" AT 27
     cmd[33] FORMAT "x(25)" AT 53
     cmd[04] FORMAT "x(25)" AT 01 cmd[19] FORMAT "x(25)" AT 27
     cmd[34] FORMAT "x(25)" AT 53 
     cmd[05] FORMAT "X(25)" AT 01 cmd[20] FORMAT "x(25)" AT 27
     cmd[35] FORMAT "x(25)" AT 53
     cmd[06] FORMAT "x(25)" AT 01 cmd[21] FORMAT "X(25)" AT 27
     cmd[36] FORMAT "X(25)" AT 53
     cmd[07] FORMAT "x(25)" AT 01 cmd[22] FORMAT "x(25)" AT 27
     cmd[37] FORMAT "x(25)" AT 53
     cmd[08] FORMAT "X(25)" AT 01 cmd[23] FORMAT "x(25)" AT 27
     cmd[38] FORMAT "X(25)" AT 53
     cmd[09] FORMAT "x(25)" AT 01 cmd[24] FORMAT "X(25)" AT 27
     cmd[39] FORMAT "x(25)" AT 53
     cmd[10] FORMAT "x(25)" AT 01 cmd[25] FORMAT "x(25)" AT 27
     cmd[40] FORMAT "x(25)" AT 53 
     cmd[11] FORMAT "X(25)" AT 01 cmd[26] FORMAT "x(25)" AT 27
     cmd[12] FORMAT "x(25)" AT 01 cmd[27] FORMAT "X(25)" AT 27
     cmd[13] FORMAT "x(25)" AT 01 cmd[28] FORMAT "x(25)" AT 27
     cmd[14] FORMAT "X(25)" AT 01 cmd[29] FORMAT "x(25)" AT 27
     cmd[15] FORMAT "x(25)" AT 01 cmd[30] FORMAT "X(25)" AT 27
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
                 IF   glb_nmdatela <> "MENU01"   THEN
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
             IF   LASTKEY = KEYCODE("UP")    OR
                  LASTKEY = KEYCODE("LEFT")  THEN
                  DO:
                      IF   choice = 1 THEN
                           choice = 40.
                      ELSE
                           IF   choice = 16 THEN
                                choice = 15.
                           ELSE
                                IF   choice = 31 THEN
                                     choice = 30.
                                ELSE
                                     choice = choice - 1.

                     NEXT GETCHOICE.
                  END.
             ELSE
                  IF  (LASTKEY = KEYCODE("DOWN")    OR
                       LASTKEY = KEYCODE(" ")       OR
                       LASTKEY = KEYCODE("RIGHT"))  THEN
                       DO:
                           choice = choice + 1.
                           IF   choice > 40 THEN
                                choice = choice - 40.

                           NEXT GETCHOICE.
                       END.
                  ELSE
                       IF   KEYFUNCTION(LASTKEY) = "HOME"   THEN
                            DO:
                                choice = 1.
                                NEXT GETCHOICE.
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
