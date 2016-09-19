/* ..........................................................................

   Programa: Fontes/crps090.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/94.                           Ultima atualizacao: 25/04/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 047.
               Emite relatorio com os coeficientes das prestacao (76).

   Alteracoes: 16/11/94 - Alterado para distribuir dinamicamente os coeficientes
                          das prestacoes dentro do frame (Edson).

               15/08/95 - Alterado para enviar para a impressora mais perto do
                          usuario (Edson).

               31/08/95 - Alterado para imprimir as linhas de credito passadas
                          na glb_dsparame ou todas se a variavel estiver vazia
                          (Edson).

               21/02/97 - Alterado para permitir o tratamento de ate 100 par-
                          celas (Edson).

               15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
               
               03/06/2008 - Utilizar a tabela crapccp para armazenar o
                            coeficiente da linhas de credito, no lugar do
                            extende atributo craplcr.incalpre(Sidnei - Precise).

               13/03/2009 - Correcao na exibicao dos coeficientes, parcelas que
                            nao iniciam no mes 1(Guilherme).
                            
               25/04/2014 - Aumentado format do campo cdlcremp de 3 para 4
                            posicoes (Tiago/Gielow SD137074).
............................................................................. */

DEF STREAM str_1.     /*  Para listagem dos coeficientes de prestacao  */
DEF STREAM str_2.     /*  Para arquivo temporario  */

DEF BUFFER crabtab FOR craptab.

{ includes/var_batch.i }

DEF        VAR rel_nmresemp     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR rel_dsindice AS CHAR    FORMAT "x(96)"                NO-UNDO.
DEF        VAR rel_dslcremp AS CHAR    FORMAT "x(29)"                NO-UNDO.
DEF        VAR rel_nrgrplcr AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR rel_qtdcasas AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR rel_nrinipre AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR rel_nrfimpre AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR rel_txbaspre AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR rel_txjurfix AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR rel_txjurvar AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR rel_txpresta AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR rel_txcalcul AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR rel_txminima AS DECIMAL FORMAT "zz9.99"               NO-UNDO.

DEF        VAR set_cdlcremp AS INT     FORMAT "9999"                  NO-UNDO.
DEF        VAR set_qtpresta AS INT     FORMAT "999"                  NO-UNDO.
DEF        VAR set_incalpre AS DECIMAL DECIMALS 6 FORMAT "999.999999" NO-UNDO.

DEF        VAR par_flgfirst AS LOGICAL      INIT TRUE                NO-UNDO.
DEF        VAR par_flgrodar AS LOGICAL      INIT TRUE                NO-UNDO.
DEF        VAR par_flgcance AS LOGICAL                               NO-UNDO.

DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.

DEF        VAR aux_flgescra AS LOGICAL                               NO-UNDO.

DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF        VAR aux_dsparame AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmendter AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqtmp AS CHAR    INIT "arq/crps090.tmp"        NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_contacoe AS INT                                   NO-UNDO.
DEF        VAR aux_contapre AS INT                                   NO-UNDO.
DEF        VAR aux_nrdlinha AS INT                                   NO-UNDO.
DEF        VAR aux_nrlcremp AS INT                                   NO-UNDO.
DEF        VAR aux_nrpresta AS INT                                   NO-UNDO.

DEF        VAR aux_qtpresta AS INT     EXTENT 100                    NO-UNDO.
DEF        VAR aux_incalpre AS CHAR    EXTENT 100                    NO-UNDO.

DEF        VAR aux_dslcremp AS CHAR    FORMAT "x(31)" EXTENT 999     NO-UNDO.
DEF        VAR aux_dsfinemp AS CHAR    FORMAT "x(31)" EXTENT 999     NO-UNDO.
DEF        VAR aux_cont     AS INTE                                  NO-UNDO.

DEF        VAR aux_flgfirst AS LOGICAL INIT TRUE                     NO-UNDO.

ASSIGN glb_cdprogra = "crps090"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

FORM "LINHA DE CREDITO"                                  AT  1
     "GR   CALCULO      T.R.     FIXA   MINIMA   MARGEM" AT 32
     WITH NO-BOX NO-ATTR-SPACE NO-LABEL WIDTH 80 FRAME f_label.

FORM SKIP(2)
     "LINHAS DE CREDITO" AT  8
     "FINALIDADES"       AT 43
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE WIDTH 80 FRAME f_label_2.

FORM SKIP(1)
     rel_dslcremp AT  1
     rel_nrgrplcr AT 32
     rel_txbaspre AT 37
     "%"          AT 43
     rel_txjurvar AT 47
     "%"          AT 53
     rel_txjurfix AT 56
     "%"          AT 62
     rel_txminima AT 65
     "%"          AT 71
     rel_txpresta AT 74
     "%"          AT 80
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABEL WIDTH 80 FRAME f_linha.

FORM SKIP(1) WITH NO-BOX NO-ATTR-SPACE WIDTH 80 FRAME f_espaco.

FORM "\033\017"                      /*  Liga modo condensado  */
     rel_dsindice AT 32
     "\022"                          /*  Desliga modo condensado  */
     WITH NO-BOX NO-ATTR-SPACE NO-LABEL DOWN WIDTH 132 FRAME f_indice.

FORM aux_dslcremp[aux_contador] AT  8
     aux_dsfinemp[aux_contador] AT 43
     WITH NO-BOX NO-ATTR-SPACE NO-LABEL DOWN WIDTH 80 FRAME f_descricao.

{ includes/cabrel080_1.i }

aux_dsparame = TRIM(SUBSTRING(glb_dsparame,3,300)).

/*********************
IF   SUBSTRING(glb_dsparame,1,1) = " "   THEN
     DO:
         OUTPUT STREAM str_2 TO VALUE(aux_nmarqtmp).

         FOR EACH craplcr WHERE craplcr.cdcooper = glb_cdcooper  AND
                                craplcr.flgstlcr                 NO-LOCK:

             IF   aux_dsparame <> ""   THEN
                  IF   NOT CAN-DO(aux_dsparame,STRING(craplcr.cdlcremp)) THEN
                       NEXT.

             PUT STREAM str_2
                 craplcr.cdlcremp FORMAT "999" " 000 "
                 craplcr.txbaspre FORMAT "999.999999"
                 SKIP.

             /** 
             DO aux_nrpresta = craplcr.nrinipre TO craplcr.nrfimpre:

                PUT STREAM str_2
                    craplcr.cdlcremp FORMAT "999" " "
                    aux_nrpresta     FORMAT "999" " "
                    craplcr.incalpre[aux_nrpresta] FORMAT "999.999999"
                    SKIP.

             END.  /*  Fim do FOR EACH  --  Leitura do coeficientes  */
             **/

             FOR EACH crapccp WHERE crapccp.cdcooper = craplcr.cdcooper AND
                                    crapccp.cdlcremp = craplcr.cdlcremp
                                    NO-LOCK BY crapccp.nrparcel:
                 PUT STREAM str_2
                     crapccp.cdlcremp FORMAT "999" " "
                     crapccp.nrparcel FORMAT "999" " "
                     crapccp.incalpre FORMAT "999.999999"
                     SKIP.
             END.

         END.  /*  Fim do FOR EACH  --  Leitura das linhas de credito  */

         OUTPUT STREAM str_2 CLOSE.
     END.
ELSE
     DO:
         IF   SEARCH(aux_nmarqtmp) = ?   THEN
              DO:
                  glb_infimsol = TRUE.
                  RUN fontes/fimprg.p.
                  RETURN.
              END.
     END.
************************************/

aux_nmarqimp = "rl/O076_" + STRING(TIME,"99999") + ".lst".

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

VIEW STREAM str_1 FRAME f_cabrel080_1.
VIEW STREAM str_1 FRAME f_label.

FOR EACH craplcr WHERE craplcr.cdcooper = glb_cdcooper  AND
                       craplcr.flgstlcr                 NO-LOCK:

   IF   aux_dsparame <> ""   THEN
        IF   NOT CAN-DO(aux_dsparame,STRING(craplcr.cdlcremp)) THEN
             NEXT.

   ASSIGN rel_dslcremp = STRING(craplcr.cdlcremp,"9999") + "-" + craplcr.dslcremp
          rel_txbaspre = craplcr.txbaspre

          rel_nrgrplcr = craplcr.nrgrplcr
          rel_txjurfix = craplcr.txjurfix
          rel_txjurvar = craplcr.txjurvar
          rel_txpresta = craplcr.txpresta
          rel_qtdcasas = craplcr.qtdcasas
          rel_nrinipre = craplcr.nrinipre
          rel_nrfimpre = craplcr.nrfimpre
          rel_txminima = craplcr.txminima

          rel_txcalcul = ROUND((rel_txbaspre * (rel_txjurvar / 100)) +
                                rel_txjurfix,2)

          aux_nrpresta = rel_nrfimpre - rel_nrinipre + 1

          aux_nrdlinha = TRUNCATE(aux_nrpresta / 6,0) +
                         (IF (aux_nrpresta MOD 6) > 0
                              THEN 1
                              ELSE 0).

   IF  (LINE-COUNTER(str_1) + 4) > PAGE-SIZE(str_1)   THEN
        DO:
            PAGE STREAM str_1.
            VIEW STREAM str_1 FRAME f_label.
        END.
   ELSE
   IF   NOT aux_flgfirst   THEN
        VIEW STREAM str_1 FRAME f_espaco.
   ELSE
        aux_flgfirst = FALSE.

   DISPLAY STREAM str_1
           rel_dslcremp rel_nrgrplcr rel_txbaspre rel_txjurfix
           rel_txjurvar rel_txminima rel_txpresta
           WITH FRAME f_linha.

   ASSIGN aux_contador = 0
          aux_incalpre = ""
          aux_qtpresta = 0
          rel_dsindice = ""
          aux_cont     = 0.

   IF   aux_nrpresta > 0    THEN
        DO aux_contador = rel_nrinipre TO rel_nrfimpre:

           ASSIGN aux_cont = aux_cont + 1.
           
           IF   aux_cont > aux_nrdlinha   THEN
                LEAVE.
                
           ASSIGN aux_contapre = aux_contador.

           FIND FIRST crapccp WHERE crapccp.cdcooper = craplcr.cdcooper AND
                                    crapccp.cdlcremp = craplcr.cdlcremp AND
                                    crapccp.nrparcel = aux_contapre
                                    NO-LOCK NO-ERROR.
           
           IF AVAIL crapccp THEN
                 rel_dsindice = STRING(crapccp.nrparcel,"zz9") + " " +
                                STRING(SUBSTRING(STRING(crapccp.incalpre,
                                                        "9.999999"),
                                                 1,2 + rel_qtdcasas),"x(12)").
           ELSE
                 rel_dsindice = "            ".
           
           DO aux_contacoe = 2 TO 6:

              aux_contapre = aux_contapre + aux_nrdlinha.
 
              FIND FIRST crapccp WHERE crapccp.cdcooper = craplcr.cdcooper AND
                                       crapccp.cdlcremp = craplcr.cdlcremp AND
                                       crapccp.nrparcel = aux_contapre
                                       NO-LOCK NO-ERROR.
              IF AVAIL crapccp THEN
                       rel_dsindice = rel_dsindice +
                                      STRING(crapccp.nrparcel,"zz9") + " " +                                      STRING(SUBSTRING(STRING(crapccp.incalpre,
                                                          "9.999999"), 
                                                  1,2 + rel_qtdcasas),"x(12)").
              ELSE
                       rel_dsindice = rel_dsindice + "            ".

           END.  /*  Fim do DO .. TO  */

           IF   rel_dsindice = ""    THEN
                NEXT.

           DISPLAY STREAM str_1 rel_dsindice WITH FRAME f_indice.

           DOWN STREAM str_1 WITH FRAME f_indice.

           IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                DO:
                    PAGE STREAM str_1.
                    VIEW STREAM str_1 FRAME f_label.

                    DISPLAY STREAM str_1
                            rel_dslcremp rel_nrgrplcr rel_txbaspre rel_txjurfix
                            rel_txjurvar rel_txminima rel_txpresta
                            WITH FRAME f_linha.
                END.

        END.  /*  Fim do DO .. TO  */

END.  /*  Fim do DO WHILE TRUE  --  Leitura do arquivo temporario  */

rel_dsindice = "".

aux_contador = 0.

FOR EACH craplcr WHERE craplcr.cdcooper = glb_cdcooper   AND
                       craplcr.flgstlcr                  NO-LOCK:

    IF   aux_dsparame <> ""   THEN
         IF   NOT CAN-DO(aux_dsparame,STRING(craplcr.cdlcremp)) THEN
              NEXT.

    ASSIGN aux_contador = aux_contador + 1
           aux_dslcremp[aux_contador] = STRING(craplcr.cdlcremp,"9999") +
                                        " - " + craplcr.dslcremp.

END.  /*  Fim do FOR EACH  */

aux_contador = 0.

FOR EACH crapfin WHERE crapfin.cdcooper = glb_cdcooper  AND
                       crapfin.flgstfin                 NO-LOCK:

    ASSIGN aux_contador = aux_contador + 1
           aux_dsfinemp[aux_contador] = STRING(crapfin.cdfinemp,"999") +
                                        " - " + crapfin.dsfinemp.

END.  /*  Fim do FOR EACH  */

IF  (LINE-COUNTER(str_1) + 5) > PAGE-SIZE(str_1)   THEN
     PAGE STREAM str_1.

VIEW STREAM str_1 FRAME f_label_2.

DO aux_contador = 1 TO 999:

   IF   aux_dslcremp[aux_contador] = ""   AND
        aux_dsfinemp[aux_contador] = ""   THEN
        LEAVE.

   DISPLAY STREAM str_1
           aux_dslcremp[aux_contador]   aux_dsfinemp[aux_contador]
           WITH FRAME f_descricao.

   DOWN STREAM str_1 WITH FRAME f_descricao.

   IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
        DO:
            PAGE STREAM str_1.
            VIEW STREAM str_1 FRAME f_label_2.
        END.

END.  /*  Fim do DO .. TO  */

OUTPUT STREAM str_1 CLOSE.
INPUT  STREAM str_2 CLOSE.

glb_infimsol = TRUE.

RUN fontes/fimprg.p.

IF   glb_cdcritic > 0   THEN
     RETURN.

FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK.

{ includes/impressao.i }

/***** UNIX SILENT VALUE("rm " + aux_nmarqtmp + " 2> /dev/null"). ****/


/* .......................................................................... */

