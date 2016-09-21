/* .............................................................................

   Programa: Fontes/solic2.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah
   Data    : Junho/97                          Ultima Atualizacao: 12/09/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela SOLIC2.

   Alteracoes - 22/08/97 - Criar a solicitacao 75 (Odair).

                25/08/98 - Modificar o nome da solicitacao 71 (Deborah).
                
                08/05/2000 - Incluir solicitacao 77 (Odair).
                                 
                12/09/2006 - Excluida opcao "TAB" (Diego).
                
............................................................................. */

DEF SHARED VAR glb_nmdatela AS CHAR    FORMAT "x(6)"                 NO-UNDO.
DEF SHARED VAR glb_nmtelant AS CHAR    FORMAT "x(6)"                 NO-UNDO.

DEF        VAR user-prog    AS CHAR    FORMAT "x(60)"                NO-UNDO.
DEF        VAR choice       AS INT                    INIT 1         NO-UNDO.
DEF        VAR cmdcount     AS INT                    INIT 4         NO-UNDO.
DEF        VAR cmd          AS CHAR    FORMAT "x(37)" EXTENT 4       NO-UNDO.
DEF        VAR proglist     AS CHAR                   EXTENT 4       NO-UNDO.
DEF        VAR cmdlist      AS CHAR  INIT "1234"
                                                                     NO-UNDO.
DEF        VAR lastchoice   AS INT                    INIT 1         NO-UNDO.
DEF        VAR qgo          AS LOGICAL                INIT FALSE     NO-UNDO.
DEF        VAR defstat      AS CHAR                                  NO-UNDO.

ASSIGN proglist[1]  = "SOL071"
       proglist[2]  = "SOL073"
       proglist[3]  = "SOL075"
       proglist[4]  = "SOL077"
  /*
       proglist[5]  = "SOL010"
       proglist[6]  = "SOL011"
       proglist[7]  = "SOL012"
       proglist[8]  = "SOL014"
       proglist[9]  = "SOL015"
       proglist[10] = "SOL019"
       proglist[11] = "SOL020"
       proglist[12] = "SOL021"  */

       cmd[1]  = "1 SOL071 Emissao cartoes de credito "
       cmd[2]  = "2 SOL073 Fichas para recadastramento"
       cmd[3]  = "3 SOL075 Emissao de Senhas de Conta "
       cmd[4]  = "4 SOL077 Emissao de etiquetas       ".
    
    /* cmd[5]  = "5 SOL010 Relat. Geral de Associados "
       cmd[6]  = "6 SOL011 Totais por Tipo de Conta   "
       cmd[7]  = "7 SOL012 Tabelas do Sistema         "
       cmd[8]  = "8 SOL014 Associados p/Secao Extrato "
       cmd[9]  = "9 SOL015 Reaj. de Limites de Credito"
       cmd[10] = "A SOL019 Reaj. dos Planos de Capital"
       cmd[11] = "B SOL020 Cem Maiores Cotistas       "
       cmd[12] = "C SOL021 Integr. Cred.Planos  Cotas "
       cmd[13] = "D SOL022 Relat. de Associados p/Empr"
       cmd[14] = "E SOL023 Geracao dos Debitos Capital"
       cmd[15] = "F SOL026 Calculo Juros sobre Capital"
       cmd[16] = "G SOL027 Exec. Pedido de Talonarios "
       cmd[17] = "H SOL030 Incorp. C.M. e Calc.Retorno"
       cmd[18] = "I SOL031 Integr de Cheque de Salario"
       cmd[19] = "J SOL033 Impressao de lotes         "
       cmd[20] = "K SOL038 Impressao de Moedas Fixas  "
       cmd[21] = "L SOL042 Reaj. das Prestac.Variaveis"
       cmd[22] = "M SOL043 Geracao Debitos Emprestimos"
       cmd[23] = "N SOL044 Cem Maiores Devedores      "
       cmd[24] = "O SOL045 Integracao Cred.Emprestimos"
       cmd[25] = "P SOL054 Taxas de RDC e Poupanca    "
       cmd[26] = "Q SOL060 Pagamentos/Liberacoes Empr "
       cmd[27] = "R SOL062 Integr. Folha c/Debito C/C "
       cmd[28] = "S SOL064 Ger. Cheque Salario Ceval  "
       cmd[29] = "T SOL066 Impr. Emprest. Prest. Var. "
       cmd[30] = "U SOLIC2 Demais telas de solcitacao ". */

FORM SKIP(1)
     cmd[1]  FORMAT "x(37)" AT 2    /*   cmd[16]  FORMAT "x(37)" AT 42 */
     cmd[2]  FORMAT "x(37)" AT 2    /*   cmd[17]  FORMAT "x(37)" AT 42 */
     cmd[3]  FORMAT "x(37)" AT 2    /*   cmd[18]  FORMAT "x(37)" AT 42 */
     cmd[4]  FORMAT "x(37)" AT 2    /*   cmd[19]  FORMAT "x(37)" AT 42
     cmd[5]  FORMAT "x(37)" AT 2       cmd[20]  FORMAT "x(37)" AT 42
     cmd[6]  FORMAT "x(37)" AT 2       cmd[21]  FORMAT "x(37)" AT 42
     cmd[7]  FORMAT "x(37)" AT 2       cmd[22]  FORMAT "x(37)" AT 42
     cmd[8]  FORMAT "x(37)" AT 2       cmd[23]  FORMAT "x(37)" AT 42
     cmd[9]  FORMAT "x(37)" AT 2       cmd[24]  FORMAT "x(37)" AT 42
     cmd[10] FORMAT "x(37)" AT 2       cmd[25]  FORMAT "x(37)" AT 42
     cmd[11] FORMAT "x(37)" AT 2       cmd[26]  FORMAT "x(37)" AT 42
     cmd[12] FORMAT "x(37)" AT 2       cmd[27]  FORMAT "x(37)" AT 42
     cmd[13] FORMAT "x(37)" AT 2       cmd[28]  FORMAT "x(37)" AT 42
     cmd[14] FORMAT "x(37)" AT 2       cmd[29]  FORMAT "x(37)" AT 42
     cmd[15] FORMAT "x(37)" AT 2       cmd[30]  FORMAT "x(37)" AT 42 */
     SKIP(12)
     WITH TITLE " S O L I C I T A C O E S " FRAME f-cmd NO-LABELS
          OVERLAY WIDTH 80.

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

        READKEY.
        HIDE MESSAGE NO-PAUSE.
        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
             DO:
                 COLOR DISPLAY NORMAL cmd[choice] WITH FRAME f-cmd.
                 RUN fontes/novatela.p.
                 IF   glb_nmdatela <> "SOLIC2"   THEN
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
