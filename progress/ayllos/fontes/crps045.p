/* .............................................................................

   Programa: Fontes/crps045.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Fevereiro/93.                   Ultima atualizacao: 18/09/2014

   Dados referentes ao programa:

   Frequencia: Anual (Batch)
   Objetivo  : Listar demitidos de determinado periodo e baixar os talonarios
               nao utilizados.
               Atende a solicitacao 028. Emite relatorio 41.

   Alteracao : 06/07/95 - Em vez de atualizar os registros no crapchq ou crapcht
                          com 5 no indicador, colocar 8 (Odair).

               05/09/95 - Alterado para flegar os registros dos demitidos para
                          3 meses atras. (Odair).

               14/01/98 - Alterado para 2 vias (Deborah).

               17/02/98 - Ajustar layout (Odair).

               23/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               04/01/2000 - Nao gerar pedido de impressao (Deborah).

               11/02/2000 - Gerar pedido de impressao (Deborah).
               
               15/07/2003 - Alterar a conta do convenio do BB de fixo para   
                            variavel (Fernando).
                            
               14/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
               
               01/11/2005 - Uso da procedure digbbx.p para conversao de campo
                            inteiro para caracter (SQLWorks - Andre).

               09/11/2005 - Eliminacao cheques passou a ser por folhas (Magui).

               14/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               03/04/2007 - Alteracao da chave crapfdc1 (Ze).

               07/02/2008 - Alterada para uma via somente para a  Viacredi
                            (Gabriel).
                           
               28/02/2012 - Alterado o format do campo nrctachq para 8 
                            posicoes (Adriano).             
                            
               10/06/2014 - Ajustado para trazer os talonarios baixados de cooperados
                            demitidos do mes que passou e nao do mes retrasado.
                            (Douglas - Chamado 110216)
                            
               18/09/2014 - Ajustado relatorio para listar os demitidos no mes
                            anterior (Softdesk 123378 - Lucas R.)
............................................................................. */

DEF STREAM str_1.  /*  Para relatorio dos demitidos  */
DEF STREAM str_2.  /*  Para entrada/saida do arquivo auxiliar  */

{ includes/var_batch.i }

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR rel_nmmesref AS CHAR                                  NO-UNDO.
DEF        VAR rel_dsagenci AS CHAR                                  NO-UNDO.
DEF        VAR rel_nrseqage AS INT                                   NO-UNDO.
DEF        VAR rel_nrinital AS INT                                   NO-UNDO.
DEF        VAR rel_nrfintal AS INT                                   NO-UNDO.
DEF        VAR rel_literalA AS CHAR    INIT "A"                      NO-UNDO.
DEF        VAR rel_dsobserv AS CHAR INIT "________________"          NO-UNDO.

DEF        VAR tot_qtassdem AS INT                                   NO-UNDO.
DEF        VAR tot_qttalbai AS INT                                   NO-UNDO.

DEF        VAR ger_qtassdem AS INT                                   NO-UNDO.
DEF        VAR ger_qttalbai AS INT                                   NO-UNDO.

DEF        VAR aux_cdagenci AS INT                                   NO-UNDO.
DEF        VAR aux_cdbanchq AS INT                                   NO-UNDO.
DEF        VAR aux_cdagechq AS INT                                   NO-UNDO.
DEF        VAR aux_nrctachq AS DEC                                   NO-UNDO.
DEF        VAR aux_nrcheque AS INT                                   NO-UNDO.
DEF        VAR aux_nrseqint AS INT                                   NO-UNDO.

DEF        VAR aux_dtultdma AS DATE                                  NO-UNDO.
DEF        VAR aux_dtultdia AS DATE                                  NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR    INIT "rl/crrl041.lst"         NO-UNDO.
DEF        VAR aux_nmarqsai AS CHAR    INIT "arq/crps045.tmp"        NO-UNDO.

DEF        VAR aux_nmmesano AS CHAR    EXTENT 12 INIT
                                       ["JANEIRO/","FEVEREIRO/",
                                        "MARCO/","ABRIL/",
                                        "MAIO/","JUNHO/",
                                        "JULHO/","AGOSTO/",
                                        "SETEMBRO/","OUTUBRO/",
                                        "NOVEMBRO/","DEZEMBRO/"]     NO-UNDO.

DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgexchq AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgpagin AS LOGICAL                               NO-UNDO.

DEF        VAR aux_lsconta2 AS CHAR                                  NO-UNDO.

glb_cdprogra = "crps045".

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0   THEN
    RETURN.

FORM rel_nmmesref AT 1 FORMAT "x(14)" LABEL "MES DE REFERENCIA"
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE SIDE-LABELS WIDTH 132 FRAME f_mesrefere.

FORM rel_dsagenci AT   1 FORMAT "x(21)" LABEL "AGENCIA"
     rel_nrseqage AT 123 FORMAT "zzz9" LABEL "SEQ."
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE SIDE-LABELS WIDTH 132 FRAME f_agencia.

FORM tot_qtassdem AT 15 FORMAT "zzz,zz9" LABEL "QUANTIDADE DE DEMISSOES"
     tot_qttalbai AT 52 FORMAT "zzz,zz9" LABEL "QUANTIDADE DE CHEQUES"
     "____/____/____  ________________________" AT 90 SKIP
     "     DATA           CADASTRO E VISTO"     AT 90
     WITH NO-BOX NO-ATTR-SPACE SIDE-LABELS WIDTH 132 FRAME f_total.

FORM "CONTA/DV  MATRICULA TITULAR" AT   3
     "DEMISSAO   CONTA BASE"       AT  66
     "CHEQUE  DV  OBSERVACAO"      AT  90
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE WIDTH 132 FRAME f_label.

FORM crapass.nrdconta AT   1 FORMAT "zzzz,zz9,9"
     crapass.nrmatric AT  15 FORMAT "zzz,zz9"
     crapass.nmprimtl AT  23 FORMAT "x(40)"
     crapass.dtdemiss AT  64 FORMAT "99/99/9999"
     crapfdc.nrctachq AT  76 FORMAT "zzzz,zz9,9"
     SPACE(2)
     crapfdc.nrcheque        FORMAT "zzz,zz9"
     SPACE(3)
     crapfdc.nrdigchq        FORMAT "9"
     SPACE(2)
     rel_dsobserv            FORMAT "x(16)"
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS DOWN WIDTH 132 FRAME f_demitidos.

IF   glb_inrestar > 0   AND   glb_nrctares = 0   THEN
     glb_inrestar = 0.

{ includes/cabrel132_1.i }
                                                
FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "GENERI"       AND
                   craptab.cdempres = 0              AND
                   craptab.cdacesso = "EXEBAIXCHQ"   AND
                   craptab.tpregist = 1              
                   NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 267.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                            glb_cdprogra + "' --> '" + glb_dscritic +
                            " >> log/proc_batch.log").

         RETURN.

     END.

IF   glb_inrestar = 0   THEN
     DO:
         /* Calcular data do mes anterior */
         ASSIGN aux_dtultdma = glb_dtultdma - DAY(glb_dtultdma)
                aux_dtultdia = glb_dtultdia - DAY(glb_dtultdia).

         ASSIGN aux_flgfirst = TRUE
                aux_flgpagin = FALSE
                aux_cdagenci = 0
                aux_nrseqint = 0

         rel_nmmesref = aux_nmmesano[MONTH(aux_dtultdia)] +
                        STRING(YEAR(aux_dtultdia),"9999").

         OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
         OUTPUT STREAM str_2 TO VALUE(aux_nmarqsai).

         VIEW STREAM str_1 FRAME f_cabrel132_1.

         DISPLAY STREAM str_1 rel_nmmesref 
                              WITH FRAME f_mesrefere.
                                                             
         /*  Leitura dos associados com data de demissao .................... */

         FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper   AND
                                crapass.dtdemiss > aux_dtultdma   AND
                                crapass.dtdemiss <= aux_dtultdia
                                NO-LOCK USE-INDEX crapass2:

             IF   crapass.cdagenci <> aux_cdagenci   THEN
                  DO:
                      IF   aux_flgfirst   THEN
                           ASSIGN aux_cdagenci = crapass.cdagenci
                                  aux_flgfirst = FALSE.
                      ELSE
                           DO:
                               IF   LINE-COUNTER(str_1) > 83   THEN
                                    DO:
                                        PAGE STREAM str_1.

                                        DISPLAY STREAM str_1 
                                                rel_nmmesref
                                                WITH FRAME f_mesrefere.

                                        rel_nrseqage = rel_nrseqage + 1.

                                        DISPLAY STREAM str_1
                                                rel_dsagenci  rel_nrseqage
                                                WITH FRAME f_agencia.
                                    END.

                               DISPLAY STREAM str_1 tot_qtassdem  
                                                    tot_qttalbai
                                                    WITH FRAME f_total.

                               PAGE STREAM str_1.

                               ASSIGN ger_qtassdem = ger_qtassdem + tot_qtassdem
                                      ger_qttalbai = ger_qttalbai + tot_qttalbai
                                      tot_qtassdem = 0
                                      tot_qttalbai = 0
                                      rel_nrseqage = 0
                                      aux_cdagenci = crapass.cdagenci.

                           END.

                      /*FIND crapage OF crapass NO-LOCK NO-ERROR.*/
                      FIND crapage WHERE crapage.cdcooper = glb_cdcooper     AND
                                         crapage.cdagenci = crapass.cdagenci
                                         NO-LOCK NO-ERROR.

                      IF   NOT AVAILABLE crapage   THEN
                           ASSIGN rel_dsagenci = STRING(crapass.cdagenci,
                                                 "zz9") + " - " + FILL("*",15)
                                  rel_nrseqage = rel_nrseqage + 1.
                      ELSE
                           ASSIGN rel_dsagenci = STRING(crapass.cdagenci,
                                                 "zz9") + " - " +
                                                 crapage.nmresage
                                  rel_nrseqage = rel_nrseqage + 1.

                      DISPLAY STREAM str_1 rel_nmmesref 
                                           WITH FRAME f_mesrefere.

                      DISPLAY STREAM str_1 rel_dsagenci  
                                           rel_nrseqage 
                                           WITH FRAME f_agencia.

                      VIEW STREAM str_1 FRAME f_label.

                  END.

             DISPLAY STREAM str_1 crapass.nrdconta 
                                  crapass.nrmatric
                                  crapass.nmprimtl 
                                  crapass.dtdemiss
                                  rel_dsobserv
                                  WITH FRAME f_demitidos.

             ASSIGN tot_qtassdem = tot_qtassdem + 1
                    aux_flgexchq = FALSE.

             FOR EACH crapfdc WHERE crapfdc.cdcooper = glb_cdcooper     AND
                                    crapfdc.nrdconta = crapass.nrdconta AND
                                    crapfdc.dtretchq = ?
                                    NO-LOCK BREAK BY crapfdc.nrdconta:

                 aux_nrseqint = aux_nrseqint + 1.

                 PUT STREAM str_2
                     aux_nrseqint     FORMAT "999999"    " "    /*SEQ. INTEG.*/
                     crapfdc.cdbanchq FORMAT "9999"      " "    /*NR BANCO   */
                     crapfdc.cdagechq FORMAT "9999"      " "    /*NR AGENCIA */
                     crapfdc.nrctachq FORMAT "99999999"  " "    /*CONTA CHQ  */
                     crapfdc.nrcheque FORMAT "9999999"   SKIP.  /* NUM.CHEQUE*/

                 ASSIGN tot_qttalbai = tot_qttalbai + 1
                        aux_flgexchq = TRUE
                        aux_flgpagin = FALSE.

                 DISPLAY STREAM str_1 crapfdc.nrcheque
                                      crapfdc.nrctachq
                                      crapfdc.nrdigchq 
                                      rel_dsobserv
                                      WITH FRAME f_demitidos.

                 DOWN STREAM str_1 WITH FRAME f_demitidos.

                 IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                      DO:
                          PAGE STREAM str_1.

                          DISPLAY STREAM str_1 rel_nmmesref 
                                               WITH FRAME f_mesrefere.

                          rel_nrseqage = rel_nrseqage + 1.

                          DISPLAY STREAM str_1 rel_dsagenci 
                                               rel_nrseqage
                                               WITH FRAME f_agencia.

                          VIEW STREAM str_1 FRAME f_label.

                          IF   NOT LAST(crapfdc.nrdconta)   THEN
                               DISPLAY STREAM str_1 crapass.nrdconta
                                                    crapass.nrmatric
                                                    crapass.nmprimtl
                                                    crapass.dtdemiss
                                                    rel_dsobserv
                                                    WITH FRAME f_demitidos.

                          aux_flgpagin = TRUE.

                      END.

             END.  /*  Fim do FOR EACH -- Leitura dos talonarios  */

             IF   NOT aux_flgexchq   THEN
                  DOWN STREAM str_1 WITH FRAME f_demitidos.

             IF   LINE-COUNTER(str_1) >= PAGE-SIZE(str_1)   THEN
                  DO:
                      PAGE STREAM str_1.

                      DISPLAY STREAM str_1
                              rel_nmmesref WITH FRAME f_mesrefere.

                      rel_nrseqage = rel_nrseqage + 1.

                      DISPLAY STREAM str_1 rel_dsagenci
                                           rel_nrseqage
                                           WITH FRAME f_agencia.

                      VIEW STREAM str_1 FRAME f_label.

                  END.
             ELSE
                  IF   NOT aux_flgpagin   THEN
                       DISPLAY STREAM str_1 SKIP WITH FRAME f_linha.

         END.  /*  Fim do FOR EACH  --  Leitura do cadastro de assoc. dem.  */

         IF   LINE-COUNTER(str_1) > 83   THEN
              DO:
                  PAGE STREAM str_1.

                  DISPLAY STREAM str_1 rel_nmmesref 
                                       WITH FRAME f_mesrefere.

                  rel_nrseqage = rel_nrseqage + 1.

                  DISPLAY STREAM str_1 rel_dsagenci
                                       rel_nrseqage
                                       WITH FRAME f_agencia.

              END.

         DISPLAY STREAM str_1 tot_qtassdem
                              tot_qttalbai 
                              WITH FRAME f_total.

         ASSIGN ger_qtassdem = ger_qtassdem + tot_qtassdem
                ger_qttalbai = ger_qttalbai + tot_qttalbai
                tot_qtassdem = 0
                tot_qttalbai = 0
                rel_dsagenci = "TOTAL GERAL"
                rel_nrseqage = 1.

         PAGE STREAM str_1.

         DISPLAY STREAM str_1 rel_nmmesref 
                              WITH FRAME f_mesrefere.

         DISPLAY STREAM str_1 rel_dsagenci  
                              rel_nrseqage 
                              WITH FRAME f_agencia.

         DISPLAY STREAM str_1 ger_qtassdem @ tot_qtassdem
                              ger_qttalbai @ tot_qttalbai
                              WITH FRAME f_total.

         PUT STREAM str_2
             "999999 9999 9999 99999999 9999999" SKIP.

         OUTPUT STREAM str_1 CLOSE.
         OUTPUT STREAM str_2 CLOSE.

     END.

/*  Inicializa o processo de baixa dos talonarios dos associados demitidos .. */

INPUT STREAM str_1 FROM VALUE(aux_nmarqsai) NO-ECHO.

BAIXAS:

DO WHILE TRUE:

   SET STREAM str_1
       aux_nrseqint FORMAT "999999"
       aux_cdbanchq FORMAT "9999"
       aux_cdagechq FORMAT "9999"
       aux_nrctachq FORMAT "99999999"
       aux_nrcheque FORMAT "9999999".

   IF   glb_inrestar > 0   THEN
        DO:
            DO WHILE glb_nrctares >= aux_nrseqint:

               SET STREAM str_1
                   aux_nrseqint FORMAT "999999"
                   aux_cdbanchq FORMAT "9999"
                   aux_cdagechq FORMAT "9999"
                   aux_nrctachq FORMAT "99999999"
                   aux_nrcheque FORMAT "9999999".

               IF   aux_nrseqint = 999999   THEN
                    LEAVE BAIXAS.

            END.  /*  Fim do DO WHILE  */

            glb_inrestar = 0.
        END.

   IF   aux_nrseqint = 999999   THEN
        LEAVE.

   TRANS_1:

   DO TRANSACTION ON ERROR UNDO TRANS_1, RETURN:
     
      DO WHILE TRUE:

         FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper AND
                            crapfdc.cdbanchq = aux_cdbanchq AND
                            crapfdc.cdagechq = aux_cdagechq AND
                            crapfdc.nrctachq = aux_nrctachq AND
                            crapfdc.nrcheque = aux_nrcheque
                            USE-INDEX crapfdc1
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAILABLE crapfdc   THEN
              IF   LOCKED crapfdc   THEN
                   DO:
                       PAUSE 2 NO-MESSAGE.
                       NEXT.
                   END.
              ELSE
                   DO:
                       glb_cdcritic = 268.
                       RUN fontes/critic.p.
                       UNIX SILENT VALUE("echo " +
                            STRING(TIME,"HH:MM:SS") +
                            " - " + glb_cdprogra +
                            "' --> '" + glb_dscritic +
                            "COOP = " + STRING(glb_cdcooper) +
                            " CONTA = " + STRING(glb_dsdctitg) +
                            " CHEQUE = " + STRING(aux_nrcheque) +
                            " >> log/proc_batch.log").

                       NEXT BAIXAS.

                   END.

              LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      ASSIGN crapfdc.dtemschq = IF   crapfdc.dtemschq = ? THEN
                                     01/01/0001
                                ELSE 
                                     crapfdc.dtemschq
             crapfdc.dtretchq = 01/01/0001
             crapfdc.dtliqchq = glb_dtmvtolt
             crapfdc.incheque = 8.

      DO WHILE TRUE:
         FIND crapres WHERE crapres.cdcooper = glb_cdcooper  AND 
                            crapres.cdprogra = glb_cdprogra
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAILABLE crapres   THEN
              IF   LOCKED crapres   THEN
                   DO:
                       PAUSE 1 NO-MESSAGE.
                       NEXT.
                   END.
              ELSE
                   DO:
                       glb_cdcritic = 151.
                       RUN fontes/critic.p.
                       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                         " - " + glb_cdprogra + "' --> '" +
                                         glb_dscritic +
                                         " >> log/proc_batch.log").
                       UNDO TRANS_1, RETURN.
                   END.

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */ 

      ASSIGN crapres.nrdconta = aux_nrseqint
             crapres.cdcooper = glb_cdcooper
             crapres.dsrestar = STRING(aux_cdbanchq,"9999")    + " " +
                                STRING(aux_cdagechq,"9999")    + " " +
                                STRING(aux_nrctachq,"99999999") + " " +
                                STRING(aux_nrcheque,"9999999").

   END.  /*  Fim da transacao  */

END.  /*  Fim do DO WHILE TRUE  */

INPUT STREAM str_1 CLOSE.

/*  Flega tabela de execucao do programa como executada  */

DO TRANSACTION ON ERROR UNDO, RETRY:

   craptab.dstextab = "1".

END.  /*  Fim da transacao  */
                     
glb_infimsol = TRUE.

RUN fontes/fimprg.p.

IF   glb_cdcritic > 0   THEN
     RETURN.

ASSIGN glb_nmformul = ""
       glb_nmarqimp = aux_nmarqimp.
       glb_nrcopias = IF glb_cdcooper = 1
                         THEN 1
                         ELSE 2.


RUN fontes/imprim.p.
                       
UNIX SILENT VALUE("rm " + aux_nmarqsai + " 2> /dev/null").

/* .......................................................................... */

