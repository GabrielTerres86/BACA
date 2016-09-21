/* .............................................................................

   Programa: Fontes/rdcapp.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/96.                       Ultima atualizacao: 04/06/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratamento da poupanca programada para a tela
               ATENDA.
   
   Alteracoes: 25/05/2001 - Permitir que o usuario solicite o resgate de
                            poupancas programadas. (Ze Eduardo).

               17/06/2003 - Critica valor maximo prestacao (Margarete).

               06/09/2004 - Incluido Flag Conta Investimento(Mirtes).
               
               16/09/2004 - Alinhamento dos campo (Evandro).

               31/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando 
               
               19/09/2006 - Alterado nome da rotina e permitir o uso do
                            F2-AJUDA (Evandro).
                            
               07/08/2007 - A partir de 2008 somente podera Cancelar a PPR
                            (Guilherme).

               19/11/2007 - Comentada alteracao 2008 a pedido do Ivo (Magui).
               
               22/04/2008 - Vencimento de poupanca programada (Guilherme).
               
               28/04/2010 - Nao utilizar a tabela temporaria das poupanças.
                            Usar browse dinamico. (Gabriel).
                            
               04/06/2013 - Busca Saldo Bloqueio Judicial
                            (Andre Santos - SUPERO)             
............................................................................. */

{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_rdcapp.i }

DEF INPUT PARAM TABLE FOR tt-dados-rpp.
  

DEF   VAR p_opcao      AS CHAR    EXTENT 8 INIT
                                           ["Alterar","Cancelar","Consultar",
                                            "Imprimir","Incluir","Reativar",
                                            "Resgate","Suspender"]     NO-UNDO.

DEF   VAR tab_cddopcao AS CHAR    EXTENT 8 INIT
                                           ["A","X","C","M","I","R",
                                            "G","S"]                   NO-UNDO.

DEF   VAR opcao        AS INT                                          NO-UNDO.

DEF   VAR tel_vlblqjud AS DECI FORMAT "zz,zzz,zzz,zz9.99"              NO-UNDO.
DEF   VAR aux_vlblqjud AS DECI FORMAT "zz,zzz,zzz,zz9.99"              NO-UNDO.
DEF   VAR aux_vlresblq AS DECI FORMAT "zz,zzz,zzz,zz9.99"              NO-UNDO.

DEF   VAR h-b1wgen0155 AS HANDLE                                       NO-UNDO.

DEF   VAR h-b1wgen0006 AS HANDLE                                       NO-UNDO.

FORM SPACE(4)
     p_opcao[1] FORMAT "x(7)"
     p_opcao[2] FORMAT "x(8)"
     p_opcao[3] FORMAT "x(9)"
     p_opcao[4] FORMAT "x(8)"
     p_opcao[5] FORMAT "x(7)"
     p_opcao[6] FORMAT "x(8)"
     p_opcao[7] FORMAT "x(7)"      
     p_opcao[8] FORMAT "x(9)"
     SPACE(3)
     WITH ROW 20 CENTERED NO-BOX NO-LABELS OVERLAY FRAME f_opcoes.

FORM b_poupanca 
    
    SKIP
    "----------------------------------------------------------------" AT 03
    SPACE(0)
    "----------"
    SKIP
    tel_vlblqjud LABEL "Valor Bloq. Judicial"                          AT 03
    "----------------------------------------------------------------" AT 03
    SPACE(0)
    "----------"
    WITH TITLE " Escolha a Poupanca Programada "

WIDTH 78 OVERLAY ROW 10 COLUMN 2 SIDE-LABELS CENTERED FRAME f_poupanca.


/* Flag de controle de saida */
ASSIGN aux_flgsaida = FALSE.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   DISPLAY p_opcao[1]
           p_opcao[2]
           p_opcao[3]
           p_opcao[4]
           p_opcao[5]
           p_opcao[6]
           p_opcao[7]
           p_opcao[8] 
           WITH FRAME f_opcoes.

   DO aux_contador = 1 TO 8:

       COLOR DISPLAY NORMAL p_opcao[aux_contador]
                     WITH FRAME f_opcoes.

   END.

   /* Consulta */
   ASSIGN opcao = 3 WHEN opcao = 0.

   /* Destacar opcao em uso */
   COLOR DISPLAY MESSAGE p_opcao[opcao] WITH FRAME f_opcoes.

   OPEN QUERY q_poupanca FOR EACH tt-dados-rpp NO-LOCK.

   DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

       IF   aux_ultlinha <> 0   THEN
            DO:
                OPEN QUERY q_poupanca FOR EACH tt-dados-rpp NO-LOCK.

                REPOSITION q_poupanca TO ROW aux_ultlinha.

                aux_ultlinha = 0.
           
            END.

       ASSIGN aux_vlblqjud = 0
              aux_vlresblq = 0.

       /*** Busca Saldo Bloqueio Judicial ***/
       RUN sistema/generico/procedures/b1wgen0155.p 
                      PERSISTENT SET h-b1wgen0155.
    
       RUN retorna-valor-blqjud IN h-b1wgen0155(INPUT glb_cdcooper,
                                                INPUT tel_nrdconta,
                                                INPUT 0, /* fixo - nrcpfcgc */
                                                INPUT 1, /* Bloqueio        */
                                                INPUT 3, /* 3 - Poup. Prog  */
                                                INPUT glb_dtmvtolt,
                                                OUTPUT aux_vlblqjud,
                                                OUTPUT aux_vlresblq).
    
       DELETE PROCEDURE h-b1wgen0155.
       /*** Fim Busca Saldo Bloqueado Judicial ***/

       DISPLAY aux_vlblqjud @ tel_vlblqjud WITH FRAME f_poupanca.

       ENABLE b_poupanca WITH FRAME f_poupanca.

       APPLY "ENTRY" TO b_poupanca IN FRAME f_poupanca.

       READKEY.

       HIDE MESSAGE NO-PAUSE.

       
       /* Eventos do browse */
       IF  CAN-DO("CURSOR-UP,CURSOR-DOWN,HOME,PAGE-UP,PAGE-DOWN",
                   KEYFUNCTION(LASTKEY))  THEN
           DO:
                   APPLY KEYFUNCTION(LASTKEY) TO b_poupanca 
                                              IN FRAME f_poupanca.
           END.
       IF  CAN-DO("CURSOR-RIGHT,TAB",KEYFUNCTION(LASTKEY))   THEN
           DO:
                   COLOR DISPLAY NORMAL p_opcao[opcao]
                                        WITH FRAME f_opcoes.

                   ASSIGN opcao = IF   opcao = 8   THEN
                                       1
                                  ELSE
                                       opcao + 1.
           END.
       IF  CAN-DO("CURSOR-LEFT,BACK-TAB",KEYFUNCTION(LASTKEY))   THEN
           DO:
                   COLOR DISPLAY NORMAL p_opcao[opcao]
                                        WITH FRAME f_opcoes.

                   ASSIGN opcao = IF   opcao = 1   THEN
                                       8
                                  ELSE
                                       opcao - 1.
           END.
       ELSE
       IF  CAN-DO("GO,RETURN,END-ERROR",KEYFUNCTION(LASTKEY))  THEN
           DO:
               IF   AVAIL tt-dados-rpp   THEN
                    aux_ultlinha = CURRENT-RESULT-ROW("q_poupanca").

               LEAVE.
           END.

       COLOR DISPLAY MESSAGE p_opcao[opcao]
                             WITH FRAME f_opcoes.
       
   END. /* FIM do DO WHILE TRUE */

   /* Volta para a tela ATENDA */
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:
            ASSIGN aux_flgsaida = TRUE.

            HIDE MESSAGE NO-PAUSE.

            HIDE FRAME f_opcoes  NO-PAUSE.
            HIDE FRAME f_poupanca NO-PAUSE.

            LEAVE.

        END.

   ASSIGN glb_cddopcao = tab_cddopcao[opcao]
          glb_nmrotina = "POUP. PROG".

   { includes/acesso.i }


   /* Se nenhum registro e opcao diferente de Incluir */
   IF   NOT AVAIL tt-dados-rpp   THEN
        IF   opcao <> 5   THEN
             NEXT.

   CASE opcao:

       WHEN 1 THEN DO: /* Alteraçao */
           RUN fontes/rdcapp_a.p(INPUT tt-dados-rpp.nrctrrpp).
       END.
       
       WHEN 2 THEN DO: /* Cancelamento */

           HIDE FRAME f_poupanca.

           RUN fontes/rdcapp_x.p (INPUT tt-dados-rpp.nrctrrpp).   

           IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                NEXT.

       END.
       
       WHEN 3 THEN DO: /* Consulta */
           RUN fontes/rdcapp_c.p (INPUT tt-dados-rpp.nrctrrpp).

           NEXT.  /* Nao altera os dados .. */

       END.
       
       WHEN 4 THEN DO: /* Impressao */   
           RUN fontes/rdcapp_n.p 
                 (INPUT tt-dados-rpp.nrdrowid). /* Rowid */         
       END.
       
       WHEN 5 THEN DO: /* Inclusao */
           RUN fontes/rdcapp_i.p.
       END.
       
       WHEN 6 THEN DO: /* Reativaçao */

           HIDE FRAME f_poupanca.

           RUN fontes/rdcapp_r.p (INPUT tt-dados-rpp.nrctrrpp).

           IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                NEXT.

       END.
       
       WHEN 7 THEN DO: /* Resgate*/
           RUN fontes/rdcapp_g.p (INPUT tt-dados-rpp.nrctrrpp).
       END.
       
       WHEN 8 THEN DO: /* Suspensao */

           HIDE FRAME f_poupanca.

           RUN fontes/rdcapp_s.p(INPUT tt-dados-rpp.nrctrrpp).

           IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                NEXT.

       END.

   END CASE.  /* Fim selecao Opcao */
                          
   LEAVE.

END. /* Fim do DO WHILE TRUE */

HIDE FRAME f_opcoes NO-PAUSE.

/* .......................................................................... */
