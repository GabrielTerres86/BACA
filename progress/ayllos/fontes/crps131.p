/* ..........................................................................

   Programa: Fontes/crps131.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson                                                    
   Data    : Agosto/95.                          Ultima atualizacao: 28/05/2009
                                                                          
   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 002.
               Lista tabela bimestral das taxas do RDC e RDCA (108).

   Alteracoes: 25/09/95 - Nao atualizar mais a solicitacao como proces. (Odair).

               13/03/97 - Alterado layout para listar RDCA60 no lugar do RDC
                          (Edson).

               04/12/97 - Listar Aplicacoes RDCA 30 ESPECIAL (Odair).

               19/05/98 - Alterado para emitir 10 copias do relatorio (Edson).
               
               21/07/99 - Nao gerar pedido de impressao no mtspool (Odair)

               01/12/1999 - Tratar somente carencia 0 (Deborah).

               03/05/2000 - Diminuir os dias listados e nao listar dias que 
                            nao tenham taxas (Deborah).
                            
               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               24/01/2007 - Alterado formato das variaveis do tipo DATE de
                            "99/99/99" para "99/99/9999" (Elton).
                            
               28/05/2009 - Substituido comando WORKFILE por TEMP-TABLE
                            (Diego).
                            
............................................................................. */

DEF STREAM str_1.     /*  Para taxas do RDCA e RDCA 60  */

{ includes/var_batch.i "NEW" }

DEF TEMP-TABLE crawtax                                               NO-UNDO
         FIELD dtaplica         AS DATE    FORMAT "99/99/9999"
         FIELD dtresgat         AS DATE    FORMAT "99/99/9999"
         FIELD qtdiaute         AS INT     FORMAT "z9"
         FIELD tpaplica         AS INT     FORMAT "9"
         FIELD txaplica         AS DECIMAL DECIMALS 8 FORMAT "zz9.999999"
         FIELD vlfaixas         AS DECIMAL FORMAT "zzz,zz9"
         FIELD indespec         AS INT     FORMAT "9".

DEF        VAR rel_nmempres     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.


DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR rel_dtaplica AS DATE    FORMAT "99/99/9999" EXTENT 2  NO-UNDO.
DEF        VAR rel_dtresgat AS DATE    FORMAT "99/99/9999" EXTENT 2  NO-UNDO.
DEF        VAR rel_qtdiaute AS INT     FORMAT "z9"         EXTENT 2  NO-UNDO.
DEF        VAR rel_txaplica AS DECIMAL FORMAT "zz9.999999" EXTENT 2  NO-UNDO.
DEF        VAR rel_vlfaixas AS DECIMAL FORMAT "zzz,zz9"    EXTENT 2  NO-UNDO.


DEF        VAR rel_indespec AS CHAR    FORMAT "x(01)"                NO-UNDO.

DEF        VAR aux_qtdiaute AS INT                                   NO-UNDO.
DEF        VAR aux_nrmesant AS INT                                   NO-UNDO.
DEF        VAR aux_vlfaixas AS DECIMAL                               NO-UNDO.

DEF        VAR aux_dtrefere AS DATE                                  NO-UNDO.
DEF        VAR aux_dtresgat AS DATE                                  NO-UNDO.
DEF        VAR aux_dtaplica AS DATE                                  NO-UNDO.

glb_cdprogra = "crps131".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     QUIT.

FORM SKIP(7)
     "APLICACOES RDCA"    AT 14
     "APLICACOES RDCA 60 E 30 ESPECIAL (*)" AT 53
     SKIP(1)
     "DE          ATE         DIAS        TAXA"            AT  1
     "DE          ATE            FAIXA   DIAS        TAXA" AT 46
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_titulo.

FORM rel_dtaplica[1] AT  1
     rel_dtresgat[1] AT 13
     rel_qtdiaute[1] AT 27
     rel_txaplica[1] AT 31
     rel_indespec    AT 44
     rel_dtaplica[2] AT 46
     rel_dtresgat[2] AT 58
     rel_vlfaixas[2] AT 71
     rel_qtdiaute[2] AT 83
     rel_txaplica[2] AT 87
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_taxas.

{ includes/cabrel132_1.i }

/* Leitura da tabela com valor da faixa de RDCA 30 Especial */
          
FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "USUARI"      AND
                   craptab.cdempres = 11            AND
                   craptab.cdacesso = "VLREFERDCA"  AND
                   craptab.tpregist = 001 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab THEN
     DO:
         glb_cdcritic = 596.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" + glb_dscritic +
                           " >> log/proc_batch.log").
         glb_cdcritic = 0.
         QUIT.
     END.

ASSIGN aux_vlfaixas = DECIMAL(craptab.dstextab)

       aux_dtrefere = glb_dtmvtolt - 30.    
       
/* Leitura das taxas do RDCA */
                     
FOR EACH craptrd WHERE craptrd.cdcooper = glb_cdcooper AND
                       craptrd.dtiniper > aux_dtrefere NO-LOCK:

    IF   craptrd.tptaxrda = 1  AND 
         craptrd.txofimes > 0  THEN
         DO:
             CREATE crawtax.
             ASSIGN crawtax.dtaplica = craptrd.dtiniper
                    crawtax.dtresgat = craptrd.dtfimper
                    crawtax.qtdiaute = craptrd.qtdiaute
                    crawtax.txaplica = craptrd.txofimes
                    crawtax.tpaplica = 1
                    crawtax.indespec = 0.
         END.
    ELSE
    IF   craptrd.tptaxrda = 3   AND   craptrd.incarenc = 0  AND
         craptrd.txofimes > 0   THEN
         DO:
             CREATE crawtax.
             ASSIGN crawtax.dtaplica = craptrd.dtiniper
                    crawtax.dtresgat = craptrd.dtfimper
                    crawtax.qtdiaute = craptrd.qtdiaute
                    crawtax.txaplica = craptrd.txofimes
                    crawtax.vlfaixas = craptrd.vlfaixas
                    crawtax.tpaplica = 2
                    crawtax.indespec = 0.
         END.
    ELSE
    IF   craptrd.tptaxrda = 6   AND   craptrd.incarenc = 0   AND
         craptrd.txofimes > 0   THEN
         DO:
             CREATE crawtax.
             ASSIGN crawtax.dtaplica = craptrd.dtiniper
                    crawtax.dtresgat = craptrd.dtfimper
                    crawtax.qtdiaute = craptrd.qtdiaute
                    crawtax.txaplica = craptrd.txofimes
                    crawtax.vlfaixas = aux_vlfaixas
                    crawtax.tpaplica = 2
                    crawtax.indespec = 1.
         END.

END.  /*  Fim do FOR EACH -- craptrd  */

OUTPUT STREAM str_1 TO rl/crrl108.lst PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel132_1.

VIEW STREAM str_1 FRAME f_titulo.

FOR EACH crawtax BREAK BY crawtax.dtaplica
                          BY crawtax.tpaplica
                             BY crawtax.indespec
                                BY crawtax.vlfaixas:

    ASSIGN rel_dtaplica[crawtax.tpaplica] = crawtax.dtaplica
           rel_dtresgat[crawtax.tpaplica] = crawtax.dtresgat
           rel_qtdiaute[crawtax.tpaplica] = crawtax.qtdiaute
           rel_txaplica[crawtax.tpaplica] = crawtax.txaplica
           rel_vlfaixas[crawtax.tpaplica] = crawtax.vlfaixas
           rel_indespec                   = IF   crawtax.indespec = 0
                                                 THEN " "
                                                 ELSE "*".     

    IF   crawtax.tpaplica = 2        OR
         LAST-OF(crawtax.dtaplica)   THEN
         DO:
             DISPLAY STREAM str_1
                     rel_dtaplica[1] rel_dtresgat[1]
                     rel_qtdiaute[1] WHEN rel_qtdiaute[1] > 0
                     rel_txaplica[1] WHEN rel_txaplica[1] > 0
                     rel_indespec
                     rel_dtaplica[2] rel_dtresgat[2]
                     rel_vlfaixas[2] WHEN rel_qtdiaute[2] > 0
                     rel_qtdiaute[2] WHEN rel_qtdiaute[2] > 0
                     rel_txaplica[2] WHEN rel_txaplica[2] > 0
                     WITH FRAME f_taxas.

             IF  (rel_dtaplica[1] <> ?    AND   rel_dtaplica[2] =  ?)   THEN
                  IF   MONTH(rel_dtaplica[1] + 1) <> MONTH(rel_dtaplica[1]) THEN
                       DOWN STREAM str_1 2 WITH FRAME f_taxas.
                  ELSE
                       DOWN STREAM str_1 WITH FRAME f_taxas.
             ELSE
             IF ((rel_dtaplica[1] =  ?    AND   rel_dtaplica[2] <> ?)   OR
                 (rel_dtaplica[1] <> ?    AND   rel_dtaplica[2] <> ?))  AND
                  LAST-OF(crawtax.dtaplica)                             THEN
                  IF   MONTH(rel_dtaplica[2] + 1) <> MONTH(rel_dtaplica[2]) THEN
                       DOWN STREAM str_1 2 WITH FRAME f_taxas.
                  ELSE
                       DOWN STREAM str_1 WITH FRAME f_taxas.
             ELSE
                  DOWN STREAM str_1 WITH FRAME f_taxas.

             IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                  DO:
                      PAGE STREAM str_1.
                      VIEW STREAM str_1 FRAME f_titulo.
                  END.

             ASSIGN rel_dtaplica = ?
                    rel_dtresgat = ?
                    rel_qtdiaute = 0
                    rel_txaplica = 0
                    rel_vlfaixas = 0.
         END.

END.  /*  Fim do FOR EACH  */

OUTPUT STREAM str_1 CLOSE.
/*
ASSIGN glb_nrcopias = 10
       glb_nmformul = "132col"
       glb_nmarqimp = "rl/crrl108.lst".

RUN fontes/imprim.p.
*/
RUN fontes/fimprg.p.

/* .......................................................................... */

