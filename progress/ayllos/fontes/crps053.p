/* ..........................................................................

   Programa: Fontes/crps053.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Junho/93.                         Ultima atualizacao: 20/02/2019

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 033.
               Lista lotes digitados (48).

   Alteracoes: 30/09/94 - Alterado para mostrar a alinea no historico de devo-
                          lucao de cheques (Edson).

               25/10/94 - Alterado para mostrar a alinea na descricao do histo-
                          rico 78 (Odair).

               03/11/94 - Alterado para incluir a comparacao do codigo de his-
                          torico 46 atraves de uma variavel (Odair).

               09/03/95 - Alterado para incluir no relatorio os tipos de lote
                          10 e 11 (Odair).

               28/03/95 - Alterado para incluir na descricao dos tipos de
                          resgate, os tipos 3,4,5,6. (Odair).

               07/07/95 - Alterado para fazer tratamento dos lotes tipo 6 e
                          tipo 12 (Odair).

               16/04/96 - Alterado para fazer tratamento do lote tipo 14 (Edson)

               07/11/96 - Alterado para mudar nome do arquivo de impressao Odair

               24/01/97 - Alterado para tratar o historico 191 da mesma forma
                          que o 47 (Deborah).

               08/08/97 - Alterado para listar tipo 17 (Odair).

               23/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               22/01/99 - Tratar historico 313 (Odair).

               10/06/99 - Tratar lotes do auto-atendimento (Edson).

               24/06/99 - Incluir historicos 338,340 (Odair)

               02/08/99 - Alterado para ler a lista de historicos de uma tabela
                          (Edson).

               07/01/2000 - Nao gerar pedido de impressao (Deborah).

               11/02/2000 - Gerar pedido de impressao (Deborah).

               27/10/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               05/01/2001 - Alterar o nome dos formularios de impressao para
                            132dm. (Eduardo).  

               26/09/2002 - Tratar os historicos 351, 024 e 027 para mostrar
                            o cdpesqbb. (Ze Eduardo).

               07/04/2003 - Incluir tratamento do histor 399 (Margarete).

               27/06/2003 - Incluir 156 na descricao do historico (Ze).

               15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               15/08/2006 - Incluido indice para leitura da tabela craplap
                            (Diego).

               22/05/2007 - Alterado o tipo de lote 9 para utilizar os dados da
                            estrutura craplap (Elton).

               08/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)

               20/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.

               07/06/2009 - Alterado format do campo "DOCUMENTO" (Fernando).

               02/10/2009 - Aumento na numeracao dos lotes: 3200 e 3300
                            (Diego).

               19/10/2009 - Alteracao Codigo Historico (Kbase).

               08/01/2010 - Acrescentar historico 573 no mesmo CAN-DO do 338
                            (Guilherme/Precise)
                            
               18/06/2014 - Exclusao do uso da tabela craplli.
                            (Tiago Castro - Tiago RKAM)
                             
               20/02/2019 - Inclusao de log de fim de execucao do programa 
                            (Belli - Envolti - Chamado REQ0039739)
............................................................................. */
               
DEF STREAM str_1.     /*  Para os lotes listados  */

{ includes/var_batch.i "NEW" }

/* Chamada Oracle - 20/02/2019 - REQ0039739 */
{ sistema/generico/includes/var_oracle.i }

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR rel_dtmvtolt AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rel_cdagenci AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR rel_cdbccxlt AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR rel_nrdolote AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR rel_dslotmov AS CHAR    FORMAT "x(25)"                NO-UNDO.

DEF        VAR rel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR rel_nrdctabb AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR rel_nrdocmto AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_dshistor AS CHAR    FORMAT "x(21)"                NO-UNDO.
DEF        VAR rel_vllanmto AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR rel_indebcre AS CHAR    FORMAT " x"                   NO-UNDO.
DEF        VAR rel_nrseqdig AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR rel_cdpesqbb AS CHAR    FORMAT "x(13)"                NO-UNDO.
DEF        VAR rel_dsmensag AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR rel_nrctrpla AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR rel_nrctrant AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR rel_nrctratu AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR rel_dstpctan AS CHAR    FORMAT "x(21)"                NO-UNDO.
DEF        VAR rel_vllimant AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR rel_dtulcran AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rel_dstpctat AS CHAR    FORMAT "x(21)"                NO-UNDO.
DEF        VAR rel_vllimatu AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR rel_dsaplica AS CHAR    FORMAT "x(19)"                NO-UNDO.
DEF        VAR rel_nraplica AS INT     FORMAT "zzz,zzz,zz9"          NO-UNDO.
DEF        VAR rel_vlaplica AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR rel_txaplica AS DECIMAL FORMAT "zz9.999999"           NO-UNDO.
DEF        VAR rel_dtresgat AS DATE    FORMAT "99/99/9999"           NO-UNDO.

DEF        VAR tot_qtcompdb AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR tot_qtcompcr AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR tot_vlcompdb AS DECIMAL FORMAT "z,zzz,zzz,zzz,zz9.99" NO-UNDO.
DEF        VAR tot_vlcompcr AS DECIMAL FORMAT "z,zzz,zzz,zzz,zz9.99" NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR    FORMAT "x(20)" EXTENT 99      NO-UNDO.
DEF        VAR aux_dslotmov AS CHA     EXTENT 40                     NO-UNDO.

DEF        VAR aux_contaarq AS INT                                   NO-UNDO.
DEF        VAR aux_indclass AS INT                                   NO-UNDO.

DEF        VAR aux_lshistor AS CHAR                                  NO-UNDO.

ASSIGN glb_cdprogra = "crps053"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p. 

IF   glb_cdcritic > 0 THEN
     RETURN. 
    
/*  Historico de cheques  */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "GENERI"       AND
                   craptab.cdempres = 0              AND
                   craptab.cdacesso = "HSTCHEQUES"   AND
                   craptab.tpregist = 0              NO-LOCK NO-ERROR.

IF   AVAILABLE craptab   THEN
     aux_lshistor = craptab.dstextab.
ELSE
     aux_lshistor = "999".

FORM rel_dtmvtolt AT   1 LABEL "DATA DO LOTE"
     rel_cdagenci AT  29 LABEL "AGENCIA"
     rel_cdbccxlt AT  47 LABEL "BANCO/CAIXA"
     rel_nrdolote AT  69 LABEL "LOTE"
     rel_dslotmov AT  86 LABEL "TIPO DO LOTE"
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE SIDE-LABELS NO-LABELS WIDTH 132 FRAME f_lote.

FORM rel_nrdconta AT   7 LABEL "CONTA/DV"
     rel_nrdctabb AT  20 LABEL "CONTA BASE"
     rel_nrdocmto AT  33 LABEL " DOCUMENTO"
     rel_dshistor AT  51 LABEL "HISTORICO"
     rel_vllanmto AT  75 LABEL "VALOR"
     rel_indebcre AT  96 LABEL "D/C"
     rel_nrseqdig AT 100 LABEL "SEQUENCIA"
     rel_cdpesqbb AT 112 LABEL "COD. PESQUISA"
     WITH NO-BOX NO-ATTR-SPACE DOWN WIDTH 132 FRAME f_tipo_1.

FORM rel_nrdconta AT  10 LABEL "CONTA/DV"
     rel_nrctrpla AT  24 LABEL "CONTRATO"
     rel_nrdocmto AT  36 LABEL " DOCUMENTO"
     rel_dshistor AT  55 LABEL "HISTORICO"
     rel_vllanmto AT  80 LABEL "VALOR"
     rel_indebcre AT 102 LABEL "D/C"
     rel_nrseqdig AT 109 LABEL "SEQUENCIA"
     WITH NO-BOX NO-ATTR-SPACE DOWN WIDTH 132 FRAME f_tipo_2-3.

FORM rel_nrdconta AT   2 LABEL "CONTA/DV"
     rel_dstpctan AT  15 LABEL "TIPO DE CONTA ANTERIOR"
     rel_vllimant AT  39 LABEL "LIMITE ANTERIOR"
     rel_dtulcran AT  58 LABEL "ALTERACAO ANTERIOR"
     rel_dstpctat AT  79 LABEL "TIPO DE CONTA ATUAL"
     rel_vllimatu AT 102 LABEL "LIMITE ATUAL"
     rel_nrseqdig AT 122 LABEL "SEQUENCIA"
     WITH NO-BOX NO-ATTR-SPACE DOWN WIDTH 132 FRAME f_tipo_7.

FORM rel_nrdconta AT 32 LABEL "CONTA/DV"
     rel_nrctrant AT 45 LABEL "CONTRATO ANTERIOR"
     rel_nrctratu AT 65 LABEL "CONTRATO ATUAL"
     rel_nrseqdig AT 82 LABEL "SEQUENCIA"
     WITH NO-BOX NO-ATTR-SPACE DOWN WIDTH 132 FRAME f_tipo_8.

/*****************************************
FORM rel_nrdconta AT 15 LABEL "CONTA/DV"
     rel_nraplica AT 31 LABEL "NUMERO"
     rel_dsaplica AT 48 LABEL "TIPO DE APLICACAO"
     rel_vlaplica AT 74 LABEL "VALOR"
     rel_nrseqdig AT 99 LABEL "SEQUENCIA"
     WITH NO-BOX NO-ATTR-SPACE DOWN WIDTH 132 FRAME f_tipo_9.
******************************************/

FORM rel_nrdconta AT 07 LABEL "CONTA/DV"
     rel_nrdocmto AT 20 LABEL "DOCUMENTO"
     rel_nraplica AT 38 LABEL "APLICACAO"
     rel_dsaplica AT 52 LABEL "HISTORICO"
     rel_vllanmto AT 74 LABEL "VALOR"
     rel_indebcre AT 95 LABEL "D/C"
     rel_nrseqdig AT 101 LABEL "SEQUENCIA"
     rel_txaplica AT 113 LABEL "TAXA DE APLIC."
     WITH NO-BOX NO-ATTR-SPACE DOWN WIDTH 132 FRAME f_tipo_10.

FORM rel_nrdconta AT  09 LABEL "CONTA/DV"
     rel_nrdocmto AT  22 LABEL "DOCUMENTO"
     rel_nraplica AT  40 LABEL "APLICACAO"
     rel_dsaplica AT  54 LABEL "TIPO DE RESGATE"
     rel_vllanmto AT  76 LABEL "VALOR"
     rel_dtresgat AT  97 LABEL "RESGATE"
     rel_nrseqdig AT 110 LABEL "SEQUENCIA"
     WITH NO-BOX NO-ATTR-SPACE DOWN WIDTH 132 FRAME f_tipo_11.

FORM rel_nrdconta       AT  11 LABEL "CONTA/DV"
     craplau.nrdctabb   AT  25 LABEL "CONTA BASE"
     rel_nrdocmto       AT  39 LABEL " DOCUMENTO"
     craplau.cdhistor   AT  58 LABEL "HIST."
     rel_vllanmto       AT  67 LABEL "LANCAMENTO"
     rel_nrseqdig       AT  89 LABEL "SEQUENCIA"
     craplau.cdbccxpg   AT 102 LABEL "BANCO/PAGTO"
     craplau.dtmvtopg   AT 117 LABEL "PAGAMENTO" FORMAT "99/99/9999"
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS DOWN WIDTH 132 FRAME f_tipo_6-12.

FORM craplpp.nrdconta
     craplpp.nrctrrpp
     craplpp.nrdocmto
     craplpp.vllanmto
     craplpp.nrseqdig
     craplpp.txaplica
     WITH NO-BOX CENTERED NO-ATTR-SPACE DOWN WIDTH 132 FRAME f_tipo_14_lpp.

FORM craprpp.nrdconta
     craprpp.nrctrrpp
     craprpp.dtdebito FORMAT "99/99/9999"
     craprpp.vlprerpp
     WITH NO-BOX CENTERED NO-ATTR-SPACE DOWN WIDTH 132 FRAME f_tipo_14_rpp.

FORM SKIP(1)
     "QUANTIDADE DE LANCAMENTOS" AT 44
     "VALOR"                     AT 88
     SKIP(1)
     "A DEBITO:"                 AT 33
     tot_qtcompdb                AT 52
     tot_vlcompdb                AT 73
     SKIP
     "A CREDITO:"                AT 32
     tot_qtcompcr                AT 52
     tot_vlcompcr                AT 73
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_total_1.

FORM SKIP(1)
     tot_qtcompcr AT 45 LABEL "QUANTIDADE DE LANCAMENTOS"
     WITH NO-BOX NO-ATTR-SPACE SIDE-LABELS WIDTH 132 FRAME f_total_2.

FORM SKIP(1)
     rel_dsmensag 
     WITH NO-BOX NO-LABELS NO-ATTR-SPACE WIDTH 132 FRAME f_mensagem.

{ includes/cabrel132_1.i }

ASSIGN aux_dslotmov[01] = " 1 - DEPOSITOS A VISTA"
       aux_dslotmov[02] = " 2 - CAPITAL"
       aux_dslotmov[03] = " 3 - PLANOS"
       aux_dslotmov[04] = ""
       aux_dslotmov[05] = ""
       aux_dslotmov[06] = " 6 - CHEQUE CONSUMO"
       aux_dslotmov[07] = " 7 - LIMITES DE CREDITO"
       aux_dslotmov[08] = " 8 - CONTRATOS DE PLANOS"
       aux_dslotmov[09] = " 9 - APLICACAO FINANC."
       aux_dslotmov[10] = "10 - APLICACAO RDCA"
       aux_dslotmov[11] = "11 - RESGATE RDCA "
       aux_dslotmov[12] = "12 - DEBITO AUTOMATICO"
       aux_dslotmov[14] = "14 - POUPANCA PROGRAMADA"
       aux_dslotmov[17] = "17 - CARTAO DE CREDITO".

/*  Leitura das solicitacoes  */

FOR EACH crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND
                       crapsol.dtrefere = glb_dtmvtolt   AND
                       crapsol.nrsolici = 33             AND
                       crapsol.insitsol = 1
                       TRANSACTION ON ERROR UNDO, RETURN:

    ASSIGN aux_contaarq = aux_contaarq + 1
           aux_nmarqimp[aux_contaarq] = "rl/crrl048_" +
                                        STRING(aux_contaarq,"99") + ".lst"
           
           rel_dtmvtolt = DATE(INTEGER(SUBSTRING(crapsol.dsparame,4,2)),
                               INTEGER(SUBSTRING(crapsol.dsparame,1,2)),
                               INTEGER(SUBSTRING(crapsol.dsparame,7,4)))

           rel_cdagenci = INTEGER(SUBSTRING(crapsol.dsparame,12,3))
           rel_cdbccxlt = INTEGER(SUBSTRING(crapsol.dsparame,16,3))
           rel_nrdolote = INTEGER(SUBSTRING(crapsol.dsparame,20,6))

           aux_indclass = INTEGER(SUBSTRING(crapsol.dsparame,27,1))

           rel_dslotmov = ""

           tot_qtcompdb = 0
           tot_qtcompcr = 0
           tot_vlcompdb = 0
           tot_vlcompcr = 0.
           
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp[aux_contaarq]) PAGED PAGE-SIZE 84.

    VIEW STREAM str_1 FRAME f_cabrel132_1.

    FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                       craplot.dtmvtolt = rel_dtmvtolt   AND
                       craplot.cdagenci = rel_cdagenci   AND
                       craplot.cdbccxlt = rel_cdbccxlt   AND
                       craplot.nrdolote = rel_nrdolote   NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE craplot   THEN
         DO:        
             IF  (rel_nrdolote > 320000   AND     
                  rel_nrdolote < 330000)  OR
                 (rel_nrdolote > 3200     AND
                  rel_nrdolote < 3300)    THEN
                  ASSIGN rel_dsmensag = "NAO HOUVERAM LANCAMENTOS NESTE DIA!"
                         rel_dslotmov = aux_dslotmov[1].
             ELSE
                  ASSIGN rel_dsmensag = "LOTE NAO ENCONTRADO!"
                         rel_dslotmov = "".
              
             DISPLAY STREAM str_1
                     rel_dtmvtolt  rel_cdagenci  rel_cdbccxlt
                     rel_nrdolote  rel_dslotmov
                     WITH FRAME f_lote.
                  
             DISPLAY STREAM str_1 rel_dsmensag WITH FRAME f_mensagem.

             OUTPUT STREAM str_1 CLOSE.
             
             crapsol.insitsol = 2.
             
             NEXT. 
         END.
    
    rel_dslotmov = aux_dslotmov[craplot.tplotmov].

    DISPLAY STREAM str_1
            rel_dtmvtolt  rel_cdagenci  rel_cdbccxlt
            rel_nrdolote  rel_dslotmov
            WITH FRAME f_lote.
    
    IF   craplot.tplotmov = 1   THEN
         DO:
             FOR EACH craplcm WHERE craplcm.cdcooper = glb_cdcooper   AND
                                    craplcm.dtmvtolt = rel_dtmvtolt   AND
                                    craplcm.cdagenci = rel_cdagenci   AND
                                    craplcm.cdbccxlt = rel_cdbccxlt   AND
                                    craplcm.nrdolote = rel_nrdolote
                                    NO-LOCK USE-INDEX craplcm3:

                 FIND craphis NO-LOCK WHERE
                              craphis.cdcooper = craplcm.cdcooper AND 
                              craphis.cdhistor = craplcm.cdhistor NO-ERROR.
                      
                 IF   NOT AVAILABLE craphis   THEN
                      ASSIGN rel_dshistor = STRING(craplcm.cdhistor,"zzz9")
                                            + " - " + FILL("*",15)
                             rel_indebcre = "*".
                 ELSE
                      ASSIGN rel_dshistor = STRING(craplcm.cdhistor,"zzz9")
                                            + " - " + craphis.dshistor +
                              (IF CAN-DO("24,27,47,78,156,191,338,351,399,573",
                                              STRING(craplcm.cdhistor))
                                            THEN craplcm.cdpesqbb
                                            ELSE "")

                             rel_indebcre = craphis.indebcre.

                 ASSIGN rel_nrdconta = craplcm.nrdconta
                        rel_nrdctabb = craplcm.nrdctabb
                        rel_nrdocmto = IF   CAN-DO(aux_lshistor,
                                                  STRING(craplcm.cdhistor))
                                            THEN STRING(craplcm.nrdocmto,
                                                      "zzzz,zzz,zzz,z")
                                            ELSE STRING(craplcm.nrdocmto,
                                                      "zzz,zzz,zzz,zzz")
                        rel_vllanmto = craplcm.vllanmto
                        rel_nrseqdig = craplcm.nrseqdig
                        rel_cdpesqbb = craplcm.cdpesqbb.

                 IF   rel_indebcre = "D"   THEN
                      ASSIGN tot_vlcompdb = tot_vlcompdb + craplcm.vllanmto
                             tot_qtcompdb = tot_qtcompdb + 1.
                 ELSE
                 IF   rel_indebcre = "C"   THEN
                      ASSIGN tot_vlcompcr = tot_vlcompcr + craplcm.vllanmto
                             tot_qtcompcr = tot_qtcompcr + 1.
                         
                 DISPLAY STREAM str_1
                         rel_nrdconta  rel_nrdctabb  rel_nrdocmto
                         rel_dshistor  rel_vllanmto  rel_indebcre
                         rel_nrseqdig  rel_cdpesqbb
                         WITH FRAME f_tipo_1.

                 DOWN STREAM str_1 WITH FRAME f_tipo_1.

                 IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                      DO:
                          PAGE STREAM str_1.

                          DISPLAY STREAM str_1
                                  rel_dtmvtolt  rel_cdagenci  rel_cdbccxlt
                                  rel_nrdolote  rel_dslotmov
                                  WITH FRAME f_lote.
                      END.

             END.  /*  Fim do FOR EACH  --  Leitura dos lancamentos  */
             
             IF   LINE-COUNTER(str_1) > 79   THEN
                  DO:
                      PAGE STREAM str_1.

                      DISPLAY STREAM str_1
                              rel_dtmvtolt  rel_cdagenci  rel_cdbccxlt
                              rel_nrdolote  rel_dslotmov
                              WITH FRAME f_lote.
                  END.

             DISPLAY STREAM str_1
                     tot_qtcompdb  tot_vlcompdb
                     tot_qtcompcr  tot_vlcompcr
                     WITH FRAME f_total_1.
         END.
    ELSE
    IF   CAN-DO("2,3",STRING(craplot.tplotmov))   THEN
         DO:
             IF   aux_indclass = 1   THEN 
                  FOR EACH craplct WHERE craplct.cdcooper = glb_cdcooper   AND
                                         craplct.dtmvtolt = rel_dtmvtolt   AND
                                         craplct.cdagenci = rel_cdagenci   AND
                                         craplct.cdbccxlt = rel_cdbccxlt   AND
                                         craplct.nrdolote = rel_nrdolote
                                         NO-LOCK USE-INDEX craplct3:

                      FIND craphis NO-LOCK WHERE
                                   craphis.cdcooper = craplct.cdcooper AND 
                                   craphis.cdhistor = craplct.cdhistor NO-ERROR.
                      
                      IF   NOT AVAILABLE craphis   THEN
                           ASSIGN rel_dshistor = STRING(craplct.cdhistor,"zzz9")
                                                 + " - " + FILL("*",15)

                                  rel_indebcre = "*".
                      ELSE
                           ASSIGN rel_dshistor = STRING(craplct.cdhistor,"zzz9")
                                                 + " - " + craphis.dshistor

                                  rel_indebcre = craphis.indebcre.

                      ASSIGN rel_nrdconta = craplct.nrdconta
                             rel_nrctrpla = craplct.nrctrpla
                             rel_nrdocmto = STRING(craplct.nrdocmto,
                                                   "zz,zzz,zzz")
                             rel_vllanmto = craplct.vllanmto
                             rel_nrseqdig = craplct.nrseqdig.

                      IF   rel_indebcre = "D"   THEN
                           ASSIGN tot_vlcompdb = tot_vlcompdb + craplct.vllanmto
                                  tot_qtcompdb = tot_qtcompdb + 1.
                      ELSE
                      IF   rel_indebcre = "C"   THEN
                           ASSIGN tot_vlcompcr = tot_vlcompcr + craplct.vllanmto
                                  tot_qtcompcr = tot_qtcompcr + 1.

                      DISPLAY STREAM str_1
                              rel_nrdconta  rel_nrctrpla  rel_nrdocmto
                              rel_dshistor  rel_vllanmto  rel_indebcre
                              rel_nrseqdig
                              WITH FRAME f_tipo_2-3.

                      DOWN STREAM str_1 WITH FRAME f_tipo_2-3.

                      IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                           DO:
                               PAGE STREAM str_1.

                               DISPLAY STREAM str_1
                                       rel_dtmvtolt  rel_cdagenci  rel_cdbccxlt
                                       rel_nrdolote  rel_dslotmov
                                       WITH FRAME f_lote.
                           END.

                  END.  /*  Fim do FOR EACH  --  Leitura dos lancamentos  */
             ELSE
                  FOR EACH craplct WHERE craplct.cdcooper = glb_cdcooper   AND
                                         craplct.dtmvtolt = rel_dtmvtolt   AND
                                         craplct.cdagenci = rel_cdagenci   AND
                                         craplct.cdbccxlt = rel_cdbccxlt   AND
                                         craplct.nrdolote = rel_nrdolote
                                         NO-LOCK:

                      FIND craphis NO-LOCK WHERE
                                   craphis.cdcooper = craplct.cdcooper AND 
                                   craphis.cdhistor = craplct.cdhistor NO-ERROR.
                      
                      IF   NOT AVAILABLE craphis   THEN
                           ASSIGN rel_dshistor = STRING(craplct.cdhistor,"zzz9")
                                                 + " - " + FILL("*",15)

                                  rel_indebcre = "*".
                      ELSE
                           ASSIGN rel_dshistor = STRING(craplct.cdhistor,"zzz9")
                                                 + " - " + craphis.dshistor

                                  rel_indebcre = craphis.indebcre.

                      ASSIGN rel_nrdconta = craplct.nrdconta
                             rel_nrctrpla = craplct.nrctrpla
                             rel_nrdocmto = STRING(craplct.nrdocmto,
                                                   "zz,zzz,zzz")
                             rel_vllanmto = craplct.vllanmto
                             rel_nrseqdig = craplct.nrseqdig.

                      IF   rel_indebcre = "D"   THEN
                           ASSIGN tot_vlcompdb = tot_vlcompdb + craplct.vllanmto
                                  tot_qtcompdb = tot_qtcompdb + 1.
                      ELSE
                      IF   rel_indebcre = "C"   THEN
                           ASSIGN tot_vlcompcr = tot_vlcompcr + craplct.vllanmto
                                  tot_qtcompcr = tot_qtcompcr + 1.

                      DISPLAY STREAM str_1
                              rel_nrdconta  rel_nrctrpla  rel_nrdocmto
                              rel_dshistor  rel_vllanmto  rel_indebcre
                              rel_nrseqdig
                              WITH FRAME f_tipo_2-3.

                      DOWN STREAM str_1 WITH FRAME f_tipo_2-3.

                      IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                           DO:
                               PAGE STREAM str_1.

                               DISPLAY STREAM str_1
                                       rel_dtmvtolt  rel_cdagenci  rel_cdbccxlt
                                       rel_nrdolote  rel_dslotmov
                                       WITH FRAME f_lote.
                           END.

                  END.  /*  Fim do FOR EACH  --  Leitura dos lancamentos  */

             IF   LINE-COUNTER(str_1) > 79   THEN
                  DO:
                      PAGE STREAM str_1.

                      DISPLAY STREAM str_1
                              rel_dtmvtolt  rel_cdagenci  rel_cdbccxlt
                              rel_nrdolote  rel_dslotmov
                              WITH FRAME f_lote.
                  END.

             DISPLAY STREAM str_1
                     tot_qtcompdb  tot_vlcompdb
                     tot_qtcompcr  tot_vlcompcr
                     WITH FRAME f_total_1.
         END.
    ELSE    
    IF   craplot.tplotmov = 8   THEN
         DO:

             FOR EACH craplpl WHERE craplpl.cdcooper = glb_cdcooper   AND
                                    craplpl.dtmvtolt = rel_dtmvtolt   AND
                                    craplpl.cdagenci = rel_cdagenci   AND
                                    craplpl.cdbccxlt = rel_cdbccxlt   AND
                                    craplpl.nrdolote = rel_nrdolote
                                    NO-LOCK USE-INDEX craplpl2:

                 ASSIGN rel_nrdconta = craplpl.nrdconta
                        rel_nrctrant = craplpl.nrctrant
                        rel_nrctratu = craplpl.nrctratu
                        rel_nrseqdig = craplpl.nrseqdig

                        tot_qtcompcr = tot_qtcompcr + 1.

                 DISPLAY STREAM str_1
                         rel_nrdconta  rel_nrctrant  rel_nrctratu  rel_nrseqdig
                         WITH FRAME f_tipo_8.

                 DOWN STREAM str_1 WITH FRAME f_tipo_8.

                 IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                      DO:
                          PAGE STREAM str_1.

                          DISPLAY STREAM str_1
                                  rel_dtmvtolt  rel_cdagenci  rel_cdbccxlt
                                  rel_nrdolote  rel_dslotmov
                                  WITH FRAME f_lote.
                      END.

             END.  /*  Fim do FOR EACH  --  Leitura dos lancamentos  */

             IF   LINE-COUNTER(str_1) > 82   THEN
                  DO:
                      PAGE STREAM str_1.

                      DISPLAY STREAM str_1
                              rel_dtmvtolt  rel_cdagenci  rel_cdbccxlt
                              rel_nrdolote  rel_dslotmov
                              WITH FRAME f_lote.
                  END.

             DISPLAY STREAM str_1 tot_qtcompcr WITH FRAME f_total_2.
         END.
    ELSE     
    
    /***** A estrutura crapapl esta em desuso - 
           Tipo de Lote 9 funciona como Tipo de Lote 10 *********
    
    IF   craplot.tplotmov = 9   THEN
         DO: 
             IF   aux_indclass = 1   THEN
      
                  FOR EACH crapapl WHERE crapapl.cdcooper = glb_cdcooper   AND
                                         crapapl.dtmvtolt = rel_dtmvtolt   AND
                                         crapapl.cdagenci = rel_cdagenci   AND
                                         crapapl.cdbccxlt = rel_cdbccxlt   AND
                                         crapapl.nrdolote = rel_nrdolote
                                         NO-LOCK USE-INDEX crapapl3:

                      ASSIGN rel_nrdconta = crapapl.nrdconta
                             rel_nraplica = crapapl.nraplica
                             rel_vlaplica = crapapl.vlaplica
                             rel_nrseqdig = crapapl.nrseqdig
                             rel_dsaplica = IF crapapl.tpaplica = 1
                                               THEN "1 - RDC S/REAPLIC."
                                               ELSE "2 - TAXA + VAR. TR"

                             tot_vlcompcr = tot_vlcompcr + crapapl.vlaplica
                             tot_qtcompcr = tot_qtcompcr + 1.

                      DISPLAY STREAM str_1
                              rel_nrdconta  rel_nraplica  rel_vlaplica
                              rel_dsaplica  rel_nrseqdig
                              WITH FRAME f_tipo_9.

                      DOWN STREAM str_1 WITH FRAME f_tipo_9.

                      IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                           DO:
                               PAGE STREAM str_1.

                               DISPLAY STREAM str_1
                                       rel_dtmvtolt  rel_cdagenci  rel_cdbccxlt
                                       rel_nrdolote  rel_dslotmov
                                       WITH FRAME f_lote.
                           END.

                  END.  /*  Fim do FOR EACH  --  Leitura dos lancamentos  */
             ELSE
   
                  FOR EACH crapapl WHERE crapapl.cdcooper = glb_cdcooper   AND
                                         crapapl.dtmvtolt = rel_dtmvtolt   AND
                                         crapapl.cdagenci = rel_cdagenci   AND
                                         crapapl.cdbccxlt = rel_cdbccxlt   AND
                                         crapapl.nrdolote = rel_nrdolote
                                         NO-LOCK:

                      ASSIGN rel_nrdconta = crapapl.nrdconta
                             rel_nraplica = crapapl.nraplica
                             rel_vlaplica = crapapl.vlaplica
                             rel_nrseqdig = crapapl.nrseqdig
                             rel_dsaplica = IF crapapl.tpaplica = 1
                                               THEN "1 - RDC S/REAPLIC."
                                               ELSE "2 - TAXA + VAR. TR"

                             tot_vlcompcr = tot_vlcompcr + crapapl.vlaplica
                             tot_qtcompcr = tot_qtcompcr + 1.

                      DISPLAY STREAM str_1
                              rel_nrdconta  rel_nraplica  rel_vlaplica
                              rel_dsaplica  rel_nrseqdig
                              WITH FRAME f_tipo_9.

                      DOWN STREAM str_1 WITH FRAME f_tipo_9.

                      IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                           DO:
                               PAGE STREAM str_1.

                               DISPLAY STREAM str_1
                                       rel_dtmvtolt  rel_cdagenci  rel_cdbccxlt
                                       rel_nrdolote  rel_dslotmov
                                       WITH FRAME f_lote.
                           END.

                  END.  /*  Fim do FOR EACH  --  Leitura dos lancamentos  */

             IF   LINE-COUNTER(str_1) > 79   THEN
                  DO:
                      PAGE STREAM str_1.

                      DISPLAY STREAM str_1
                              rel_dtmvtolt  rel_cdagenci  rel_cdbccxlt
                              rel_nrdolote  rel_dslotmov
                              WITH FRAME f_lote.
                  END.

             DISPLAY STREAM str_1
                     tot_qtcompdb  tot_vlcompdb
                     tot_qtcompcr  tot_vlcompcr
                     WITH FRAME f_total_1.      
         END.
                        
    ELSE               
    ************************************/
    
    IF   CAN-DO("9,10",STRING(craplot.tplotmov))  THEN
         DO:
             IF   aux_indclass = 1   THEN 

                  FOR EACH craplap WHERE craplap.cdcooper = glb_cdcooper   AND
                                         craplap.dtmvtolt = rel_dtmvtolt   AND
                                         craplap.cdagenci = rel_cdagenci   AND
                                         craplap.cdbccxlt = rel_cdbccxlt   AND
                                         craplap.nrdolote = rel_nrdolote
                                         NO-LOCK USE-INDEX craplap3:

                      FIND   craphis WHERE craphis.cdcooper = glb_cdcooper AND 
                                           craphis.cdhistor = craplap.cdhistor
                             NO-LOCK NO-ERROR .

                             IF   NOT AVAILABLE craphis THEN
                                  rel_dsaplica = "Histor. nao Cadast".
                             ELSE
                                  rel_dsaplica = STRING(craphis.cdhistor,"zzz9")
                                                 + " - " + craphis.dshistor.

                      ASSIGN rel_nrdconta = craplap.nrdconta
                             rel_nraplica = craplap.nraplica
                             rel_nrdocmto = STRING(craplap.nrdocmto,
                                                   "zz,zzz,zzz")
                             rel_vllanmto = craplap.vllanmto
                             rel_indebcre = craphis.indebcre
                             rel_nrseqdig = craplap.nrseqdig
                             rel_txaplica = craplap.txaplica.

                             IF   craphis.indebcre = "D"  OR
                                  craphis.indebcre = "d"  THEN
                                  DO:
                                     ASSIGN
                                           tot_vlcompdb = tot_vlcompdb +
                                                          craplap.vllanmto
                                           tot_qtcompdb = tot_qtcompdb + 1.
                                  END.
                             ELSE
                                  DO:
                                     ASSIGN
                                           tot_vlcompcr = tot_vlcompcr +
                                                          craplap.vllanmto
                                           tot_qtcompcr = tot_qtcompcr + 1.
                                  END.

                      DISPLAY STREAM str_1
                              rel_nrdconta  rel_nraplica  rel_nrdocmto
                              rel_vllanmto  rel_indebcre  rel_dsaplica
                              rel_nrseqdig  rel_txaplica WHEN rel_txaplica > 0
                              WITH FRAME f_tipo_10.

                      DOWN STREAM str_1 WITH FRAME f_tipo_10.

                      IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                           DO:
                               PAGE STREAM str_1.

                               DISPLAY STREAM str_1
                                       rel_dtmvtolt  rel_cdagenci  rel_cdbccxlt
                                       rel_nrdolote  rel_dslotmov
                                       WITH FRAME f_lote.
                           END.

                  END.  /*  Fim do FOR EACH  --  Leitura dos lancamentos  */
             ELSE

                  FOR EACH craplap WHERE craplap.cdcooper = glb_cdcooper   AND
                                         craplap.dtmvtolt = rel_dtmvtolt   AND
                                         craplap.cdagenci = rel_cdagenci   AND
                                         craplap.cdbccxlt = rel_cdbccxlt   AND
                                         craplap.nrdolote = rel_nrdolote 
                                         NO-LOCK USE-INDEX craplap3:

                      FIND   craphis WHERE craphis.cdcooper = glb_cdcooper AND 
                                           craphis.cdhistor = craplap.cdhistor
                             NO-LOCK NO-ERROR .
  
                             IF   NOT AVAILABLE  craphis THEN
                                  rel_dsaplica = "Histor. nao Cadast".
                             ELSE
                                  rel_dsaplica = STRING(craphis.cdhistor,"zzz9")
                                                 + " - " + craphis.dshistor.

                      ASSIGN rel_nrdconta = craplap.nrdconta
                             rel_nraplica = craplap.nraplica
                             rel_nrdocmto = STRING(craplap.nrdocmto,
                                                   "zz,zzz,zzz")
                             rel_vllanmto = craplap.vllanmto
                             rel_indebcre = craphis.indebcre
                             rel_nrseqdig = craplap.nrseqdig
                             rel_txaplica = craplap.txaplica.

                             IF   craphis.indebcre = "D"  OR
                                  craphis.indebcre = "d"  THEN
                                  DO:
                                     ASSIGN
                                           tot_vlcompdb = tot_vlcompdb +
                                                          craplap.vllanmto
                                           tot_qtcompdb = tot_qtcompdb + 1.
                                  END.
                             ELSE
                                  DO:
                                     ASSIGN
                                           tot_vlcompcr = tot_vlcompcr +
                                                          craplap.vllanmto
                                           tot_qtcompcr = tot_qtcompcr + 1.
                                  END.

                      DISPLAY STREAM str_1
                              rel_nrdconta  rel_nraplica  rel_nrdocmto
                              rel_vllanmto  rel_indebcre  rel_dsaplica
                              rel_nrseqdig  rel_txaplica WHEN rel_txaplica > 0
                              WITH FRAME f_tipo_10.

                      DOWN STREAM str_1 WITH FRAME f_tipo_10.

                      IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                           DO:
                               PAGE STREAM str_1.

                               DISPLAY STREAM str_1
                                       rel_dtmvtolt  rel_cdagenci  rel_cdbccxlt
                                       rel_nrdolote  rel_dslotmov
                                       WITH FRAME f_lote.
                           END.

                  END.  /*  Fim do FOR EACH  --  Leitura dos lancamentos  */

             IF   LINE-COUNTER(str_1) > 79   THEN
                  DO:
                      PAGE STREAM str_1.

                      DISPLAY STREAM str_1
                              rel_dtmvtolt  rel_cdagenci  rel_cdbccxlt
                              rel_nrdolote  rel_dslotmov
                              WITH FRAME f_lote.
                  END.

             DISPLAY STREAM str_1
                     tot_qtcompdb  tot_vlcompdb
                     tot_qtcompcr  tot_vlcompcr
                     WITH FRAME f_total_1.

         END. /* FIM do DO */

    ELSE
    IF   craplot.tplotmov = 11 THEN
         DO:
             IF   aux_indclass = 1   THEN
                  
                  FOR EACH craplrg WHERE craplrg.cdcooper = glb_cdcooper   AND
                                         craplrg.dtmvtolt = rel_dtmvtolt   AND
                                         craplrg.cdagenci = rel_cdagenci   AND
                                         craplrg.cdbccxlt = rel_cdbccxlt   AND
                                         craplrg.nrdolote = rel_nrdolote
                                         NO-LOCK USE-INDEX craplrg3:

                      ASSIGN rel_nrdconta = craplrg.nrdconta
                             rel_nraplica = craplrg.nraplica
                             rel_nrdocmto = STRING(craplrg.nrdocmto,
                                                   "zz,zzz,zzz")
                             rel_dsaplica = IF   craplrg.tpresgat = 1
                                            THEN " 1 - PARCIAL"
                                            ELSE
                                            IF   craplrg.tpresgat = 2
                                            THEN " 2 - TOTAL"
                                            ELSE
                                            IF   craplrg.tpresgat = 3
                                            THEN " 3 - ANTECIPADO"
                                            ELSE
                                            IF   craplrg.tpresgat = 4
                                            THEN " 4 - PARCIAL NO DIA"
                                            ELSE
                                            IF   craplrg.tpresgat = 5
                                            THEN " 5 - TOTAL NO DIA"
                                            ELSE
                                                 " 6 - ANTECIPADO NO DIA"
                             rel_vllanmto = craplrg.vllanmto
                             rel_dtresgat = craplrg.dtresgat
                             rel_nrseqdig = craplrg.nrseqdig

                             tot_vlcompdb = tot_vlcompdb + craplrg.vllanmto
                             tot_qtcompdb = tot_qtcompdb + 1.

                      DISPLAY STREAM str_1
                              rel_nrdconta  rel_nraplica  rel_nrdocmto
                              rel_dsaplica  rel_vllanmto  rel_dtresgat
                              rel_nrseqdig
                              WITH FRAME f_tipo_11.

                      DOWN STREAM str_1 WITH FRAME f_tipo_11.

                      IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                           DO:
                               PAGE STREAM str_1.

                               DISPLAY STREAM str_1
                                       rel_dtmvtolt  rel_cdagenci  rel_cdbccxlt
                                       rel_nrdolote  rel_dslotmov
                                       WITH FRAME f_lote.
                           END.

                  END.  /*  Fim do FOR EACH  --  Leitura dos lancamentos  */
             ELSE
                  FOR EACH craplrg WHERE craplrg.cdcooper = glb_cdcooper   AND
                                         craplrg.dtmvtolt = rel_dtmvtolt   AND
                                         craplrg.cdagenci = rel_cdagenci   AND
                                         craplrg.cdbccxlt = rel_cdbccxlt   AND
                                         craplrg.nrdolote = rel_nrdolote
                                         NO-LOCK:

                      ASSIGN rel_nrdconta = craplrg.nrdconta
                             rel_nraplica = craplrg.nraplica
                             rel_nrdocmto = STRING(craplrg.nrdocmto,
                                                   "zz,zzz,zzz")
                             rel_dsaplica = IF   craplrg.tpresgat = 1  THEN
                                                 " 1 - PARCIAL"
                                            ELSE
                                            IF   craplrg.tpresgat = 2
                                            THEN " 2 - TOTAL"
                                            ELSE
                                            IF   craplrg.tpresgat = 3
                                            THEN " 3 - ANTECIPADO"
                                            ELSE
                                            IF   craplrg.tpresgat = 4
                                            THEN " 4 - PARCIAL NO DIA"
                                            ELSE
                                            IF   craplrg.tpresgat = 5
                                            THEN " 5 - TOTAL NO DIA"
                                            ELSE
                                                 " 6 - ANTECIPADO NO DIA"
                             rel_vllanmto = craplrg.vllanmto
                             rel_dtresgat = craplrg.dtresgat
                             rel_nrseqdig = craplrg.nrseqdig

                             tot_vlcompdb = tot_vlcompdb + craplrg.vllanmto
                             tot_qtcompdb = tot_qtcompdb + 1.

                      DISPLAY STREAM str_1
                              rel_nrdconta  rel_nraplica  rel_nrdocmto
                              rel_dsaplica  rel_vllanmto  rel_dtresgat
                              rel_nrseqdig
                              WITH FRAME f_tipo_11.

                      DOWN STREAM str_1 WITH FRAME f_tipo_11.

                      IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                           DO:
                               PAGE STREAM str_1.

                               DISPLAY STREAM str_1
                                       rel_dtmvtolt  rel_cdagenci  rel_cdbccxlt
                                       rel_nrdolote  rel_dslotmov
                                       WITH FRAME f_lote.
                           END.

                  END.  /*  Fim do FOR EACH  --  Leitura dos lancamentos  */

             IF   LINE-COUNTER(str_1) > 79   THEN
                  DO:
                      PAGE STREAM str_1.

                      DISPLAY STREAM str_1
                              rel_dtmvtolt  rel_cdagenci  rel_cdbccxlt
                              rel_nrdolote  rel_dslotmov
                              WITH FRAME f_lote.
                  END.

             DISPLAY STREAM str_1
                     tot_qtcompdb  tot_vlcompdb
                     tot_qtcompcr  tot_vlcompcr
                     WITH FRAME f_total_1.

         END. /* FIM do DO */
    ELSE
    IF   CAN-DO("6,12,17",STRING(craplot.tplotmov))   THEN
         DO:
             IF   aux_indclass = 1   THEN

                  FOR EACH craplau WHERE craplau.cdcooper = glb_cdcooper   AND
                                         craplau.dtmvtolt = rel_dtmvtolt   AND
                                         craplau.cdagenci = rel_cdagenci   AND
                                         craplau.cdbccxlt = rel_cdbccxlt   AND
                                         craplau.nrdolote = rel_nrdolote   
                                         NO-LOCK USE-INDEX craplau3:

                      ASSIGN rel_nrdconta = craplau.nrdconta
                             rel_nrdocmto = STRING(craplau.nrdocmto,
                                                   "zz,zzz,zzz")
                             rel_vllanmto = craplau.vllanaut
                             rel_nrseqdig = craplau.nrseqdig
                             tot_vlcompdb = tot_vlcompdb + craplau.vllanaut
                             tot_qtcompdb = tot_qtcompdb + 1.

                      DISPLAY STREAM str_1
                              rel_nrdconta      craplau.nrdctabb
                              rel_nrdocmto      craplau.cdhistor
                              rel_vllanmto      rel_nrseqdig
                              craplau.cdbccxpg  craplau.dtmvtopg
                              WITH FRAME f_tipo_6-12.

                      DOWN STREAM str_1 WITH FRAME f_tipo_6-12.

                      IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                           DO:
                               PAGE STREAM str_1.

                               DISPLAY STREAM str_1
                                       rel_dtmvtolt  rel_cdagenci  rel_cdbccxlt
                                       rel_nrdolote  rel_dslotmov
                                       WITH FRAME f_lote.
                           END.

                  END.  /*  Fim do FOR EACH  --  Leitura dos lancamentos  */
             ELSE
                  FOR EACH craplau WHERE craplau.cdcooper = glb_cdcooper   AND
                                         craplau.dtmvtolt = rel_dtmvtolt   AND
                                         craplau.cdagenci = rel_cdagenci   AND
                                         craplau.cdbccxlt = rel_cdbccxlt   AND
                                         craplau.nrdolote = rel_nrdolote   
                                         NO-LOCK:

                      ASSIGN rel_nrdconta = craplau.nrdconta
                             rel_nrdctabb = craplau.nrdctabb
                             rel_nrdocmto = STRING(craplau.nrdocmto,
                                                   "zz,zzz,zzz")
                             rel_vllanmto = craplau.vllanaut
                             rel_nrseqdig = craplau.nrseqdig
                             tot_vlcompdb = tot_vlcompdb + craplau.vllanaut
                             tot_qtcompdb = tot_qtcompdb + 1.

                      DISPLAY STREAM str_1
                              rel_nrdconta        craplau.nrdctabb
                              rel_nrdocmto        craplau.cdhistor
                              rel_vllanmto        rel_nrseqdig
                              craplau.cdbccxpg    craplau.dtmvtopg
                              WITH FRAME f_tipo_6-12.

                      DOWN STREAM str_1 WITH FRAME f_tipo_6-12.

                      IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                           DO:
                               PAGE STREAM str_1.

                               DISPLAY STREAM str_1
                                       rel_dtmvtolt  rel_cdagenci  rel_cdbccxlt
                                       rel_nrdolote  rel_dslotmov
                                       WITH FRAME f_lote.
                           END.

                  END.  /*  Fim do FOR EACH  --  Leitura dos lancamentos  */

             IF   LINE-COUNTER(str_1) > 79   THEN
                  DO:
                      PAGE STREAM str_1.

                      DISPLAY STREAM str_1
                              rel_dtmvtolt  rel_cdagenci  rel_cdbccxlt
                              rel_nrdolote  rel_dslotmov
                              WITH FRAME f_lote.
                  END.

             DISPLAY STREAM str_1
                     tot_qtcompdb  tot_vlcompdb
                     tot_qtcompcr  tot_vlcompcr
                     WITH FRAME f_total_1.
         END.
    ELSE
    IF   craplot.tplotmov = 14   THEN
         DO:
             FIND FIRST  craplpp WHERE craplpp.cdcooper = glb_cdcooper   AND
                                       craplpp.dtmvtolt = rel_dtmvtolt   AND
                                       craplpp.cdagenci = rel_cdagenci   AND
                                       craplpp.cdbccxlt = rel_cdbccxlt   AND
                                       craplpp.nrdolote = rel_nrdolote
                                       USE-INDEX craplpp3 
                                       NO-LOCK NO-ERROR.

             IF   AVAILABLE craplpp   THEN
                  DO:
                      IF   aux_indclass = 1   THEN
                           FOR EACH craplpp WHERE
                                    craplpp.cdcooper = glb_cdcooper   AND
                                    craplpp.dtmvtolt = rel_dtmvtolt   AND
                                    craplpp.cdagenci = rel_cdagenci   AND
                                    craplpp.cdbccxlt = rel_cdbccxlt   AND
                                    craplpp.nrdolote = rel_nrdolote
                                    USE-INDEX craplpp3 NO-LOCK:

                               ASSIGN tot_vlcompcr = tot_vlcompcr +
                                                         craplpp.vllanmto
                                      tot_qtcompcr = tot_qtcompcr + 1.

                               DISPLAY STREAM str_1
                                       craplpp.nrdconta craplpp.nrctrrpp
                                       craplpp.nrdocmto craplpp.vllanmto
                                       craplpp.nrseqdig craplpp.txaplica
                                       WITH FRAME f_tipo_14_lpp.

                               DOWN STREAM str_1 WITH FRAME f_tipo_14_lpp.

                               IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)  THEN
                                    DO:
                                        PAGE STREAM str_1.

                                        DISPLAY STREAM str_1
                                                rel_dtmvtolt  rel_cdagenci
                                                rel_cdbccxlt
                                                rel_nrdolote  rel_dslotmov
                                                WITH FRAME f_lote.
                                    END.

                           END.  /*  Fim do FOR EACH -- Leitura lancamentos */
                      ELSE
                           FOR EACH craplpp WHERE
                                    craplpp.cdcooper = glb_cdcooper   AND
                                    craplpp.dtmvtolt = rel_dtmvtolt   AND
                                    craplpp.cdagenci = rel_cdagenci   AND
                                    craplpp.cdbccxlt = rel_cdbccxlt   AND
                                    craplpp.nrdolote = rel_nrdolote
                                    NO-LOCK:

                               ASSIGN tot_vlcompcr = tot_vlcompcr +
                                                         craplpp.vllanmto
                                      tot_qtcompcr = tot_qtcompcr + 1.

                               DISPLAY STREAM str_1
                                       craplpp.nrdconta craplpp.nrctrrpp
                                       craplpp.nrdocmto craplpp.vllanmto
                                       craplpp.nrseqdig craplpp.txaplica
                                       WITH FRAME f_tipo_14_lpp.

                               DOWN STREAM str_1 WITH FRAME f_tipo_14_lpp.

                               IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)  THEN
                                    DO:
                                        PAGE STREAM str_1.

                                        DISPLAY STREAM str_1
                                                rel_dtmvtolt  rel_cdagenci
                                                rel_cdbccxlt
                                                rel_nrdolote  rel_dslotmov
                                                WITH FRAME f_lote.
                                    END.

                           END.  /*  Fim do FOR EACH -- Leitura lancamentos */

                           IF   LINE-COUNTER(str_1) > 79   THEN
                                DO:
                                    PAGE STREAM str_1.

                                    DISPLAY STREAM str_1
                                            rel_dtmvtolt  rel_cdagenci
                                            rel_cdbccxlt
                                            rel_nrdolote  rel_dslotmov
                                            WITH FRAME f_lote.
                                END.

                           DISPLAY STREAM str_1
                                   tot_qtcompdb  tot_vlcompdb
                                   tot_qtcompcr  tot_vlcompcr
                                   WITH FRAME f_total_1.
                  END.

             ASSIGN tot_qtcompdb = 0
                    tot_qtcompcr = 0
                    tot_vlcompdb = 0
                    tot_vlcompcr = 0.

             FIND FIRST craprpp WHERE craprpp.cdcooper = glb_cdcooper   AND
                                      craprpp.dtmvtolt = rel_dtmvtolt   AND
                                      craprpp.cdagenci = rel_cdagenci   AND
                                      craprpp.cdbccxlt = rel_cdbccxlt   AND
                                      craprpp.nrdolote = rel_nrdolote
                                      USE-INDEX craprpp3 NO-LOCK NO-ERROR.

             IF   AVAILABLE craprpp   THEN
                  DO:
                      FOR EACH craprpp WHERE
                               craprpp.cdcooper = glb_cdcooper   AND
                               craprpp.dtmvtolt = rel_dtmvtolt   AND
                               craprpp.cdagenci = rel_cdagenci   AND
                               craprpp.cdbccxlt = rel_cdbccxlt   AND
                               craprpp.nrdolote = rel_nrdolote
                               USE-INDEX craprpp3 NO-LOCK:

                          ASSIGN tot_vlcompcr = tot_vlcompcr + craprpp.vlprerpp
                                 tot_qtcompcr = tot_qtcompcr + 1.

                          DISPLAY STREAM str_1
                                  craprpp.nrdconta craprpp.nrctrrpp
                                  craprpp.dtdebito craprpp.vlprerpp
                                  WITH FRAME f_tipo_14_rpp.

                          DOWN STREAM str_1 WITH FRAME f_tipo_14_rpp.

                          IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)  THEN
                               DO:
                                   PAGE STREAM str_1.

                                   DISPLAY STREAM str_1
                                           rel_dtmvtolt  rel_cdagenci
                                           rel_cdbccxlt
                                           rel_nrdolote  rel_dslotmov
                                           WITH FRAME f_lote.
                               END.

                      END.  /*  Fim do FOR EACH -- Leitura lancamentos */

                      IF   LINE-COUNTER(str_1) > 79   THEN
                           DO:
                               PAGE STREAM str_1.

                               DISPLAY STREAM str_1
                                       rel_dtmvtolt  rel_cdagenci
                                       rel_cdbccxlt
                                       rel_nrdolote  rel_dslotmov
                                       WITH FRAME f_lote.
                           END.

                      DISPLAY STREAM str_1
                              tot_qtcompdb  tot_vlcompdb
                              tot_qtcompcr  tot_vlcompcr
                              WITH FRAME f_total_1.
                  END.
         END.

    OUTPUT STREAM str_1 CLOSE.

    crapsol.insitsol = 2.

END.  /*  Fim do FOR EACH e da transacao   --  Leitura das solicitacoes  */

/* Inclusao de log de fim de execucao do programa -  20/02/2019 - Chamado REQ0039739 */

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "O",
    INPUT "CRPS053.P",
    input glb_cdcooper,
    input 1,
    input 4,
    input 0,
    input 912,
    input "912 - FINALIZADO LEGAL",
    input 1,
    INPUT "", /* nmarqlog */
    INPUT 0,  /* flabrechamado */
    INPUT "", /* texto_chamado */
    INPUT "", /* destinatario_email */
    INPUT 0,  /* flreincidente */
    INPUT 0).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "PF",
    INPUT "CRPS053.P",
    input glb_cdcooper,
    input 1,
    input 4,
    input 0,
    input 0,
    input "",
    input 1,
    INPUT "", /* nmarqlog */
    INPUT 0,  /* flabrechamado */
    INPUT "", /* texto_chamado */
    INPUT "", /* destinatario_email */
    INPUT 0,  /* flreincidente */
    INPUT 0).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

RUN fontes/fimprg.p.
      
IF   glb_cdcritic > 0   THEN
     RETURN.

DO aux_contaarq = 1 TO 99:

   IF   aux_nmarqimp[aux_contaarq] = ""   THEN
        LEAVE.

   ASSIGN glb_nrcopias = 1
          glb_nmformul = "132dm"
          glb_nmarqimp = aux_nmarqimp[aux_contaarq].
                    
    RUN fontes/imprim.p.  
                   
END.  /*  Fim do DO .. TO  */

    
/* .......................................................................... */



