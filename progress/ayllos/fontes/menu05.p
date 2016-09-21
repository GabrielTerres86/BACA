/* .............................................................................

   Programa: Fontes/menu05.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91.                        Ultima atualizacao: 12/09/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela MENU05.

   Alteracoes: 21/06/94 - Alterado para incluir a tela LIQUID.
               29/07/94 - Alterado para incluir a tela ALTERA.
               19/08/94 - Alterado para incluir a tela ELIMIN e MENEXT.
               29/11/94 - Alterado para incluir a tela TAXRDA (Odair).
               20/02/95 - Alterado para incluir a tela PESSOA (Odair).
               06/03/95 - Alterado para incluir a tela NOME e a inclusao
                          da tela TAXAS (Odair).
               04/04/95 - Alterado para incluir a tela IRPF (Odair).
               28/04/95 - Alterado para incluir a tela ACESSO (Odair).
               14/07/95 - Alterado para incluir a tela MENAVS (Odair).
               27/09/95 - Alterado para incluir a tela MENAPL (Odair).
               23/02/96 - Alterado para retirar a tela IMPRES e colocar a tela
                          IMPLIS (Odair).
               29/04/96 - Alterado para incluir a tela TAXRDC (Deborah).
               09/12/96 - Alterado para incluir a tela TABSEG (Odair).
               12/09/06 - Excluida opcao "TAB" (Diego).
               
............................................................................. */

{ includes/var_online.i }

DEF        VAR aux_stimeout AS INT                                   NO-UNDO.

DEF        VAR user-prog    AS CHAR    FORMAT "x(60)"                NO-UNDO.
DEF        VAR choice       AS INT     INIT 1                        NO-UNDO.
DEF        VAR cmdcount     AS INT     INIT 32                       NO-UNDO.
DEF        VAR cmd          AS CHAR    FORMAT "x(40)" EXTENT 32      NO-UNDO.
DEF        VAR proglist     AS CHAR    EXTENT 32                     NO-UNDO.
DEF        VAR cmdlist      AS CHAR    INIT "123456789ABCDEFGHIJLMNOPQRSTUVXY"
                                                                     NO-UNDO.
DEF        VAR lastchoice   AS INT     INIT 1                        NO-UNDO.
DEF        VAR qgo          AS LOGICAL INIT FALSE                    NO-UNDO.
DEF        VAR defstat      AS CHAR                                  NO-UNDO.

ASSIGN proglist[1]  = "ACESSO"
       proglist[2]  = "ADMISS"
       proglist[3]  = "ALTERA"
       proglist[4]  = "ALTRAM"
       proglist[5]  = "ATENDA"
       proglist[6]  = "AVULSO"
       proglist[7]  = "CADAST"
       proglist[8]  = "ELIMIN"
       proglist[9]  = "IDENTI"
       proglist[10] = "IMPLIS"
       proglist[11] = "CPMF"
       proglist[12] = "IRPF"
       proglist[13] = "LIQUID"
       proglist[14] = "MATRIC"
       proglist[15] = "MENAPL"
       proglist[16] = "MENAVS"
       proglist[17] = "MENEXT"
       proglist[18] = "MOEDAS"
       proglist[19] = "MUDSEN"
       proglist[20] = "NOME"
       proglist[21] = "PERMIS"
       proglist[22] = "PESSOA"
       proglist[23] = "SECEXT"
       proglist[24] = "SOLICI"
       proglist[25] = "TABELA"
       proglist[26] = "TABSEG"
       proglist[27] = "TAXAPL"
       proglist[28] = "TAXAS"
       proglist[29] = "TAXMES"
       proglist[30] = "TAXRDA"
       proglist[31] = "TAXRDC"
       proglist[32] = "TRANSF"

       cmd[1]  = "1. ACESSO - Consulta Senha de Acesso  "
       cmd[2]  = "2. ADMISS - Admissoes no Mes          "
       cmd[3]  = "3. ALTERA - Mostra Alteracoes Cadastro"
       cmd[4]  = "4. ALTRAM - Alteracao de Ramal        "
       cmd[5]  = "5. ATENDA - Atendimento Geral         "
       cmd[6]  = "6. AVULSO - Requis. Talonarios Avulsos"
       cmd[7]  = "7. CADAST - Cadastro                  "
       cmd[8]  = "8. ELIMIN - Contas Eliminadas do Sist."
       cmd[9]  = "9. IDENTI - Identificacao do Usuario  "
       cmd[10] = "A. IMPLIS - Impressoes de Listagens   "
       cmd[11] = "B. CPMF   - Calcula Valor da CPMF     "
       cmd[12] = "C. IRPF   - Dados para Imposto Renda  "
       cmd[13] = "D. LIQUID - Manut. Taxa Liquid. Empr. "
       cmd[14] = "E. MATRIC - Matricula de Socio        "
       cmd[15] = "F. MENAPL - Mensagem Extrato Aplicacao"
       cmd[16] = "G. MENAVS - Mensagem Aviso de Debito  "
       cmd[17] = "H. MENEXT - Mensagem do Extrato Mensal"
       cmd[18] = "I. MOEDAS - Manutencao de Moedas Fixas"
       cmd[19] = "J. MUDSEN - Mudanca de Senha          "
       cmd[20] = "L. NOME   - Consulta por Nome         "
       cmd[21] = "M. PERMIS - Permissoes                "
       cmd[22] = "N. PESSOA - Altera Tipo de Pessoa     "
       cmd[23] = "O. SECEXT - Manut. Secoes para Extrato"
       cmd[24] = "P. SOLICI - Solicitacoes              "
       cmd[25] = "Q. TABELA - Tabelas                   "
       cmd[26] = "R. TABSEG - Manut. Tabela de Seguros  "
       cmd[27] = "S. TAXAPL - Taxa para Aplicacoes      "
       cmd[28] = "T. TAXAS  - Historico de Taxas        "
       cmd[29] = "U. TAXMES - Taxas de juros do Mes     "
       cmd[30] = "V. TAXRDA - Taxas de RDCA             "
       cmd[31] = "X. TAXRDC - Taxas de RDC              "
       cmd[32] = "Y. TRANSF - Transf./duplic. Matriculas".

FORM cmd[1]  FORMAT "x(38)" AT  1
     cmd[2]  FORMAT "x(38)" AT 41
     cmd[3]  FORMAT "x(38)" AT  1
     cmd[4]  FORMAT "x(38)" AT 41
     cmd[5]  FORMAT "x(38)" AT  1
     cmd[6]  FORMAT "x(38)" AT 41
     cmd[7]  FORMAT "x(38)" AT  1
     cmd[8]  FORMAT "x(38)" AT 41
     cmd[9]  FORMAT "x(38)" AT  1
     cmd[10] FORMAT "x(38)" AT 41
     cmd[11] FORMAT "x(38)" AT  1
     cmd[12] FORMAT "x(38)" AT 41
     cmd[13] FORMAT "x(38)" AT  1
     cmd[14] FORMAT "x(38)" AT 41
     cmd[15] FORMAT "x(38)" AT  1
     cmd[16] FORMAT "x(38)" AT 41
     cmd[17] FORMAT "x(38)" AT  1
     cmd[18] FORMAT "x(38)" AT 41
     cmd[19] FORMAT "x(38)" AT  1
     cmd[20] FORMAT "x(38)" AT 41
     cmd[21] FORMAT "x(38)" AT  1
     cmd[22] FORMAT "x(38)" AT 41
     cmd[23] FORMAT "x(38)" AT  1
     cmd[24] FORMAT "x(38)" AT 41
     cmd[25] FORMAT "x(38)" AT  1
     cmd[26] FORMAT "x(38)" AT 41
     cmd[27] FORMAT "x(38)" AT  1
     cmd[28] FORMAT "x(38)" AT 41
     cmd[29] FORMAT "x(38)" AT  1
     cmd[30] FORMAT "x(38)" AT 41
     cmd[31] FORMAT "x(38)" AT  1
     cmd[32] FORMAT "x(38)" AT 41
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
                 IF   glb_nmdatela <> "MENU05"   THEN
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
                          IF   glb_nmdatela = glb_nmtelant   THEN
                               glb_nmtelant = "MENU05".
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
