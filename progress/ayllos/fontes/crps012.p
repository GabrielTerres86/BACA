/* ..........................................................................

   Programa: Fontes/crps012.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/92.                           Ultima atualizacao: 25/01/2016

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 008.
               Processar as integracoes de credito de pagamento.
               Emite relatorio 16.

   Alteracoes: 20/06/94 - Alterado para transferir automaticamente o credito
                          do liquido de pagamento para a nova conta.

               30/06/94 - Alterado para colocar sempre tipo de debito 1
                          (moeda corrente).

               31/08/94 - Alterado para rejeitar credito para os associados que
                          tenham dtelimin (Deborah).

               31/08/95 - Alterado para fazer a consistencia se o associado foi
                          transferido de conta (Odair).

               16/01/96 - Alterado para tratar empresa 9 (Consumo) onde no ar-
                          quivo vira com cdempres = 1 (Odair).

               05/06/97 - Alterado para tratar empresa LOHESA (Odair).

               11/08/97 - Acessar crapemp pela empresa da solicitacao (Odair).

               20/03/98 - Tratamento para milenio e troca para V8 (Margarete).

               09/11/98 - Tratar situacao em prejuizo (Deborah).

               12/11/98 - Tratar atendimento noturno (Deborah).

             23/10/2000 - Desmembrar a critica 95 conforme a situacao do
                          titular (Eduardo).

             30/10/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

             01/11/2000 - Alterado para utilizar o crapemp.cdempfol (Edson).
             
             24/02/2005 - Nao criticar qdo empresas for diferentes 
                          Credifiesc (Ze Eduardo).

             28/06/2005 - Alimentado campo cdcooper das tabelas craplot,       
                          craprej e craplcm (Diego).
                          
             14/02/2006 - Unificacao dos bancos - SQLWorks - Eder             
             
             11/12/2006 - Verificar se eh Conta Salario - crapccs (Ze).
             
             01/09/2008 - Alteracao CDEMPRES (Kbase).
             
             12/06/2009 - Efetuado acerto na atualizacao do campo
                          craptab.dstextab - NUMLOTEFOL (Diego).
                          
             12/09/2011 - Ajuste no valor recebido pelo campo craplcs.dtmvtolt
                          (Henrique).
                          
             10/10/2013 - Possibilidade de imprimir o relatório direto da tela 
                          SOL008, na hora da solicitacao (N), senao, vai para 
                          batch noturno (Carlos)
                          
             25/10/2013 - Copia o arquivo do dir rl p/ o dir rlnsv (Carlos)
             
             03/01/2014 - Trocar Agencia por PA (Reinert)
             
             14/01/2014 - Inclusao de VALIDATE craplot craprej craplcm craplcs
                          (Carlos)

             05/11/2015 - Alterar a glb_flgresta para TRUE, pois o programa
                          faz a leitura de informações da crapres, com isso 
                          ela sempre deve ser criada (Douglas - Chamado 338053)

             25/01/2016 - Melhoria para alterar proc_batch pelo proc_message
                          na critica 182. (Jaison/Diego - SD: 365978)

             03/07/2018 - PRJ450 - Centralizacao de lancamentos em conta corrente
                          mediante uso de procedure  [gerar_lancamento_conta].
                          (PRJ450 - Teobaldo J. - AMcom)

............................................................................. */

DEF STREAM str_1.  /*  Para relatorio de criticas da integracao  */
DEF STREAM str_2.  /*  Para o arquivo de entrada da integracao  */

{ includes/var_batch.i {1} } 
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/b1wgen0200tt.i }


DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.
DEF        VAR rel_dsintegr AS CHAR                                  NO-UNDO.
DEF        VAR rel_nmempres AS CHAR                                  NO-UNDO.
DEF        VAR rel_qtdifeln AS INT                                   NO-UNDO.
DEF        VAR rel_vldifedb AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vldifecr AS DECIMAL                               NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "]      NO-UNDO.

DEF        VAR aux_nmarqint AS CHAR    FORMAT "x(50)"                NO-UNDO.
DEF        VAR aux_dsintegr AS CHAR                                  NO-UNDO.

DEF        VAR aux_nmarquiv AS CHAR    FORMAT "x(20)" EXTENT 99      NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.

DEF        VAR aux_nrdevias AS INT     FORMAT "z9"    EXTENT 99      NO-UNDO.

DEF        VAR aux_qtdifeln AS INT                                   NO-UNDO.
DEF        VAR aux_vldifedb AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vldifecr AS DECIMAL                               NO-UNDO.

DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgclote AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgdaurv AS LOGICAL                               NO-UNDO.

DEF        VAR aux_dtintegr AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR aux_dtrefere AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR aux_dtmvtolt AS DATE    FORMAT "99/99/9999"           NO-UNDO.

DEF        VAR aux_cdempfol AS INT                                   NO-UNDO.
DEF        VAR aux_contaarq AS INT                                   NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT     INIT 100                      NO-UNDO.
DEF        VAR aux_nrdolote AS INT                                   NO-UNDO.
DEF        VAR aux_nrdocmto AS INT                                   NO-UNDO.
DEF        VAR aux_nrlotccs AS INT                                   NO-UNDO.

DEF        VAR aux_tpregist AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR aux_tpdebito AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR aux_nrdconta AS INT     FORMAT "99999999"             NO-UNDO.
DEF        VAR aux_cdhistor AS INT     FORMAT "9999"                 NO-UNDO.
DEF        VAR aux_dtmvtoin AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR aux_cdempres AS INT     FORMAT "99999"                NO-UNDO.
DEF        VAR aux_nrseqint AS INT     FORMAT "999999"               NO-UNDO.
DEF        VAR aux_vldaurvs AS DECIMAL FORMAT "99999.99"             NO-UNDO.
DEF        VAR aux_vllanmto AS DECIMAL FORMAT "9999999999.99-"       NO-UNDO.

DEF        VAR aux_nrdoclot AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrdocmt2 AS INT                                   NO-UNDO.
DEF        VAR aux_flgctsal AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flfirst2 AS LOGICAL                               NO-UNDO.

DEF        VAR tot_qtinfoln AS INT                                   NO-UNDO.
DEF        VAR tot_vlinfodb AS DECIMAL                               NO-UNDO.
DEF        VAR tot_vlinfocr AS DECIMAL                               NO-UNDO.
DEF        VAR tot_qtcompln AS INT                                   NO-UNDO.
DEF        VAR tot_vlcompdb AS DECIMAL                               NO-UNDO.
DEF        VAR tot_vlcompcr AS DECIMAL                               NO-UNDO.
DEF        VAR tot_qtdifeln AS INT                                   NO-UNDO.
DEF        VAR tot_vldifedb AS DECIMAL                               NO-UNDO.
DEF        VAR tot_vldifecr AS DECIMAL                               NO-UNDO.

/* vars para impressao.i */
DEF    VAR aux_nmendter AS CHAR    FORMAT "x(20)"                     NO-UNDO.
DEF    VAR par_flgrodar AS LOGICAL INIT TRUE                          NO-UNDO.
DEF    VAR aux_flgescra AS LOGICAL                                    NO-UNDO.
DEF    VAR aux_dscomand AS CHAR                                       NO-UNDO.
DEF    VAR par_flgfirst AS LOGICAL INIT TRUE                          NO-UNDO.
DEF    VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF    VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.
DEF    VAR par_flgcance AS LOGICAL                                    NO-UNDO.

/* Variaveis para rotina de lancamento craplcm */
DEF VAR h-b1wgen0200    AS HANDLE  NO-UNDO.
DEF VAR aux_incrineg    AS INT     NO-UNDO.
DEF VAR aux_cdcritic    AS INT     NO-UNDO.
DEF VAR aux_dscritic    AS CHAR    NO-UNDO.

FORM SKIP(1)
     rel_dsintegr     AT  1 FORMAT "x(20)"      LABEL "TIPO"
     rel_nmempres     AT 33 FORMAT "x(15)"      LABEL "EMPRESA"
     SKIP(1)
     craplot.dtmvtolt AT  1 FORMAT "99/99/9999" LABEL "DATA"
     craplot.cdagenci AT 20 FORMAT "zz9"        LABEL "PA"
     craplot.cdbccxlt AT 35 FORMAT "zz9"        LABEL "BANCO/CAIXA"
     craplot.nrdolote AT 54 FORMAT "zzz,zz9"    LABEL "LOTE"
     craplot.tplotmov AT 70 FORMAT "99"         LABEL "TIPO"
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE SIDE-LABELS NO-LABELS
                 WIDTH 80 FRAME f_integracao.

FORM craprej.nrdconta AT  1 FORMAT "zzzz,zzz,9"          LABEL "CONTA/DV"
     craprej.cdhistor AT 14 FORMAT "zzz9"                LABEL "HST"
     craprej.vllanmto AT 19 FORMAT "zzz,zzz,zzz,zzz.99-" LABEL "VALOR "
     glb_dscritic     AT 40 FORMAT "x(40)"               LABEL "CRITICA"
     WITH NO-BOX NO-ATTR-SPACE DOWN NO-LABELS WIDTH 80 FRAME f_rejeitados.

FORM SKIP(1)
     "QTD               DEBITO               CREDITO" AT 26
     SKIP
     "A INTEGRAR: "     AT  9
     craplot.qtinfoln   AT 22 FORMAT "zzz,zz9-"
     craplot.vlinfodb   AT 32 FORMAT "zzz,zzz,zzz,zz9.99-"
     craplot.vlinfocr   AT 54 FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP
     "INTEGRADOS: "     AT  9
     craplot.qtcompln   AT 22 FORMAT "zzz,zz9-"
     craplot.vlcompdb   AT 32 FORMAT "zzz,zzz,zzz,zz9.99-"
     craplot.vlcompcr   AT 54 FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP(1)
     "REJEITADOS: "     AT  9
     rel_qtdifeln       AT 22 FORMAT "zzz,zz9-"
     rel_vldifedb       AT 32 FORMAT "zzz,zzz,zzz,zz9.99-"
     rel_vldifecr       AT 54 FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP(4)
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 80 FRAME f_totais.


FORM SKIP(3)
     "TOTAL GERAL DO ARQUIVO DA FOLHA" AT 30
     SKIP(1)
     "QTD               DEBITO               CREDITO" AT 26
     SKIP
     "A INTEGRAR: " AT  9
     tot_qtinfoln   AT 22 FORMAT "zzz,zz9-"
     tot_vlinfodb   AT 32 FORMAT "zzz,zzz,zzz,zz9.99-"
     tot_vlinfocr   AT 54 FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP
     "INTEGRADOS: " AT  9
     tot_qtcompln   AT 22 FORMAT "zzz,zz9-"
     tot_vlcompdb   AT 32 FORMAT "zzz,zzz,zzz,zz9.99-"
     tot_vlcompcr   AT 54 FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP(1)
     "REJEITADOS: " AT  9
     tot_qtdifeln   AT 22 FORMAT "zzz,zz9-"
     tot_vldifedb   AT 32 FORMAT "zzz,zzz,zzz,zz9.99-"
     tot_vldifecr   AT 54 FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP(4)
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 80 FRAME f_total_geral.



ASSIGN glb_cdprogra = "crps012"
       glb_flgbatch = FALSE
       glb_flgresta = TRUE.

RUN fontes/iniprg.p.

IF   glb_inrestar > 0   AND   glb_nrctares = 0   THEN
     glb_inrestar = 0.

ASSIGN aux_regexist = FALSE
       aux_dtintegr = IF   glb_inproces > 2 THEN
                           glb_dtmvtopr
                      ELSE
                           IF   glb_inproces = 1 THEN
                                glb_dtmvtolt
                           ELSE
                                ?
                                
       aux_dtmvtolt = aux_dtintegr.

IF   aux_dtintegr = ? THEN
     glb_cdcritic = 138.
 
IF   glb_cdcritic > 0 THEN
     DO:
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                            " - " + glb_cdprogra + "' --> '" +
                            glb_dscritic + " >> log/proc_batch.log").
        RETURN.
     END.
     
/*  Leitura do valor da URV para o dia da integracao  */

/* Rotina eliminada apos a conversao para reais */

/*
FIND crapmfx WHERE crapmfx.cdcooper = glb_cdcooper  AND
                   crapmfx.dtmvtolt = aux_dtintegr  AND
                   crapmfx.tpmoefix = 9             NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapmfx   THEN
     aux_flgdaurv = FALSE.
ELSE
     aux_flgdaurv = TRUE.
*/

/*  Leitura das solicitacoes de integracao  */

FOR EACH crapsol WHERE crapsol.cdcooper = glb_cdcooper  AND
                       crapsol.dtrefere = glb_dtmvtolt  AND
                       crapsol.nrsolici = 8             AND
                       crapsol.insitsol = 1             USE-INDEX crapsol2
                       ON ERROR UNDO, RETURN:

    IF   glb_dtmvtolt = aux_dtintegr   THEN     /* Testa integ. por fora */
         IF   SUBSTRING(crapsol.dsparame,15,1) = "1"   THEN
              NEXT.

    ASSIGN  glb_cdcritic = 0
            glb_cdempres = 11
            glb_nrdevias = crapsol.nrdevias.

    { includes/cabrel080_1.i }               /* Monta cabecalho do relatorio */

    ASSIGN aux_regexist = TRUE
           aux_flgfirst = TRUE
           aux_flfirst2 = TRUE
           aux_flgclote = IF glb_inrestar = 0
                             THEN TRUE
                             ELSE FALSE

           aux_contaarq = aux_contaarq + 1
           aux_nmarquiv[aux_contaarq] = "rl/crrl016_" +
                                        STRING(crapsol.nrseqsol,"99") + ".lst"
           aux_nrdevias[aux_contaarq] = crapsol.nrdevias

           aux_dtrefere = DATE(INTEGER(SUBSTRING(crapsol.dsparame,4,2)),
                               INTEGER(SUBSTRING(crapsol.dsparame,1,2)),
                               INTEGER(SUBSTRING(crapsol.dsparame,7,4)))

           aux_nmarqint = "integra/f" +
                          STRING(crapsol.cdempres,"99999") + 
                          STRING(DAY(aux_dtrefere),"99") +
                          STRING(MONTH(aux_dtrefere),"99") +
                          STRING(YEAR(aux_dtrefere),"9999") + "." +
                          SUBSTRING(crapsol.dsparame,12,2).
                             
    /* FIND crapemp OF crapsol NO-LOCK NO-ERROR. */
    FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper      AND
                       crapemp.cdempres = crapsol.cdempres  NO-LOCK NO-ERROR.


    IF   NOT AVAILABLE crapemp   THEN
         ASSIGN aux_cdempfol = 0.
    ELSE
         ASSIGN aux_cdempfol = crapemp.cdempfol.


    /*  Verifica se o arquivo a ser integrado existe em disco  */
    IF   SEARCH(aux_nmarqint) = ?   THEN
         DO:
             ASSIGN aux_nmarqint = "integra/f" +
                                   TRIM(STRING(crapsol.cdempres,"z99")) + 
                                   STRING(DAY(aux_dtrefere),"99") +
                                   STRING(MONTH(aux_dtrefere),"99") +
                                   STRING(YEAR(aux_dtrefere),"9999") + "." +
                                   SUBSTRING(crapsol.dsparame,12,2).

             IF   SEARCH(aux_nmarqint) = ?   THEN
                  DO:
                      glb_cdcritic = 182.
                      RUN fontes/critic.p.
                      UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                                         " - " + glb_cdprogra + "' --> '" +
                                         glb_dscritic + "' --> '" + 
                                         aux_nmarqint + 
                                         " >> log/proc_message.log").
                      NEXT.  /* Le proxima solicitacao */
                  END.
         END.

    /*  Le numero de lote a ser usado na integracao  */

    FIND craptab WHERE craptab.cdcooper = glb_cdcooper      AND
                       craptab.nmsistem = "CRED"            AND
                       craptab.tptabela = "GENERI"          AND
                       craptab.cdempres = 0                 AND
                       craptab.cdacesso = "NUMLOTEFOL"      AND
                       craptab.tpregist = crapsol.cdempres
                       USE-INDEX craptab1 NO-ERROR.


    IF   NOT AVAILABLE craptab   THEN
         DO:
             glb_cdcritic = 175.
             RUN fontes/critic.p.
             UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                                " - " + glb_cdprogra + "' --> '" +
                                glb_dscritic + " EMPRESA = " +
                                STRING(crapsol.cdempres,"99999") +
                                " >> log/proc_batch.log").
             NEXT.  /* Le proxima solicitacao */
         END.
    ELSE
         aux_nrdolote = INTEGER(craptab.dstextab).


    /* BLOCO DA INSERÇAO DA CRAPLCM */
    IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
        RUN sistema/generico/procedures/b1wgen0200.p 
        PERSISTENT SET h-b1wgen0200.


    INPUT  STREAM str_2 FROM VALUE(aux_nmarqint) NO-ECHO.

    DO WHILE TRUE ON ERROR UNDO, RETURN:

       glb_cdcritic = 0.

       IF   aux_flgfirst   THEN
            IF   glb_inrestar = 0   THEN
                 DO:
                     glb_cdcritic = 219.
                     RUN fontes/critic.p.
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '" +
                                       glb_dscritic + "' --> '" + aux_nmarqint +
									   " - Empresa: " + 
                                       STRING(crapsol.cdempres) +
                                       " >> log/proc_batch.log").

                     glb_cdcritic = 0.

                     SET STREAM str_2       /*  Registro de controle  */
                         aux_tpregist  aux_dtmvtoin  aux_cdempres
                         aux_tpdebito  aux_vldaurvs.

                     IF  ((crapsol.cdempres = 9 OR  crapsol.cdempres = 10 OR
                           crapsol.cdempres = 5 ) AND aux_cdempres = 1) THEN
                          aux_cdempres = crapsol.cdempres.
                     ELSE
                          IF  (crapsol.cdempres = 13 AND aux_cdempres = 10) THEN
                              aux_cdempres = crapsol.cdempres.

                     /* Coloca sempre tipo de debito 1 (moeda corrente) */

                     aux_tpdebito = 1.

                     IF   aux_tpregist <> 1   THEN
                          glb_cdcritic = 181.
                     ELSE
                     IF   aux_dtmvtoin <> aux_dtrefere   THEN
                         glb_cdcritic = 173.
                     ELSE
                     IF   aux_cdempres <> aux_cdempfol   THEN
                         glb_cdcritic = 173.
                     ELSE
                     IF   NOT CAN-DO("1,2",STRING(aux_tpdebito))   THEN
                          glb_cdcritic = 379.

                     IF   glb_cdcritic > 0   THEN
                          DO:
                              RUN fontes/critic.p.
                              UNIX SILENT VALUE ("echo " +
                                          STRING(TIME,"HH:MM:SS") +
                                          " - " + glb_cdprogra + "' --> '" +
                                          glb_dscritic + " EMPRESA = " +
                                          STRING(crapsol.cdempres,"99999") +
                                          " >> log/proc_batch.log").
                              LEAVE.      /* Le proxima solicitacao */
                          END.

                     aux_flgfirst = FALSE.

                 END.
            ELSE
                 DO:
                     SET STREAM str_2       /*  Registro de controle  */
                         ^ ^ aux_cdempres aux_tpdebito aux_vldaurvs.

                     IF  ((crapsol.cdempres = 9 OR  crapsol.cdempres = 10 OR
                           crapsol.cdempres = 5 ) AND aux_cdempres = 1) THEN
                          aux_cdempres = crapsol.cdempres.
                     ELSE
                          IF  (crapsol.cdempres = 13 AND aux_cdempres = 10) THEN
                              aux_cdempres = crapsol.cdempres.

                     /* Coloca sempre tipo de debito 1 (moeda corrente) */

                     aux_tpdebito = 1.

                     DO WHILE aux_nrseqint <> glb_nrctares:

                        SET STREAM str_2
                            aux_tpregist  aux_nrseqint ^ ^ ^.

                     END.

                     IF   aux_tpregist = 9   THEN
                          LEAVE.

                     aux_flgfirst = FALSE.
                 END.

       SET STREAM str_2
           aux_tpregist  aux_nrseqint  aux_nrdconta
           aux_vllanmto  aux_cdhistor.

       IF   aux_tpregist = 9   THEN
            LEAVE.

       IF   aux_vllanmto = 0   THEN     /*  Ignora registro com valor zerado  */
            NEXT.

       ASSIGN aux_flgctsal = FALSE.

       DO WHILE TRUE:

          FIND crapass WHERE crapass.cdcooper = glb_cdcooper    AND
                             crapass.nrdconta = aux_nrdconta
                             USE-INDEX crapass1 NO-LOCK NO-ERROR.

          IF   NOT AVAILABLE crapass   THEN
               DO:
                   FIND crapccs WHERE crapccs.cdcooper = glb_cdcooper AND
                                      crapccs.nrdconta = aux_nrdconta
                                      NO-LOCK NO-ERROR.
                                      
                   IF   AVAILABLE crapccs THEN
                        DO:
                             RUN p_trata_crapccs.
                             ASSIGN aux_flgctsal = TRUE.
                             LEAVE.
                        END.
                   ELSE
                        glb_cdcritic = 9.
               END.
          ELSE
          IF   crapass.dtelimin <> ? THEN
               glb_cdcritic = 410.
          ELSE
          IF   CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))   THEN
               glb_cdcritic = 695.
          ELSE  
          IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN
               DO:
                   FIND FIRST craptrf WHERE
                              craptrf.cdcooper = glb_cdcooper       AND
                              craptrf.nrdconta = crapass.nrdconta   AND
                              craptrf.tptransa = 1                  AND
                              craptrf.insittrs = 2
                              USE-INDEX craptrf1 NO-LOCK NO-ERROR.

                   IF   AVAILABLE craptrf THEN
                        DO:
                           aux_nrdconta = craptrf.nrsconta.
                           NEXT.
                        END.
                   ELSE
                        glb_cdcritic = 95.
               END.
          LEAVE.
       END.

       IF   aux_flgctsal THEN
            NEXT.
       
       TRANS_1:
       
       DO TRANSACTION ON ERROR UNDO TRANS_1, RETURN:

          IF   aux_flgclote   THEN
               DO:
                   aux_nrdolote = aux_nrdolote + 1.

                   IF   CAN-FIND(craplot WHERE
                                 craplot.cdcooper = glb_cdcooper    AND
                                 craplot.dtmvtolt = aux_dtintegr    AND
                                 craplot.cdagenci = aux_cdagenci    AND
                                 craplot.cdbccxlt = aux_cdbccxlt    AND
                                 craplot.nrdolote = aux_nrdolote
                                 USE-INDEX craplot1)                THEN
                        DO:
                            glb_cdcritic = 59.
                            RUN fontes/critic.p.
                            UNIX SILENT VALUE ("echo " +
                                        STRING(TIME,"HH:MM:SS") +
                                        " - " + glb_cdprogra + "' --> '" +
                                        glb_dscritic + " EMPRESA = " +
                                        STRING(crapsol.cdempres,"99999") +
                                        " LOTE = " +
                                        STRING(aux_nrdolote,"999,999") +
                                        " >> log/proc_batch.log").
                            LEAVE.      /* Le proxima solicitacao */
                        END.

                   CREATE craplot.
                   ASSIGN craplot.dtmvtolt = aux_dtintegr
                          craplot.cdagenci = aux_cdagenci
                          craplot.cdbccxlt = aux_cdbccxlt
                          craplot.nrdolote = aux_nrdolote
                          craplot.tplotmov = 1
                          craptab.dstextab = "9" + STRING(INT(SUBSTR(
                                                   STRING(aux_nrdolote),2)),
                                                   "99999")
                          aux_flgclote     = FALSE
                          craplot.cdcooper = glb_cdcooper.

                   VALIDATE craplot.
               END.
          ELSE
               DO:
                   FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                                      craplot.dtmvtolt = aux_dtintegr   AND
                                      craplot.cdagenci = aux_cdagenci   AND
                                      craplot.cdbccxlt = aux_cdbccxlt   AND
                                      craplot.nrdolote = aux_nrdolote
                                      USE-INDEX craplot1 NO-ERROR.

                   IF   NOT AVAILABLE craplot   THEN
                        DO:
                            glb_cdcritic = 60.
                            RUN fontes/critic.p.
                            UNIX SILENT VALUE ("echo " +
                                        STRING(TIME,"HH:MM:SS") +
                                        " - " + glb_cdprogra + "' --> '" +
                                        glb_dscritic + " EMPRESA = " +
                                        STRING(crapsol.cdempres,"99999") +
                                        " LOTE = " +
                                        STRING(aux_nrdolote,"999,999") +
                                        " >> log/proc_batch.log").
                            LEAVE.      /* Le proxima solicitacao */
                        END.
               END.

          ASSIGN aux_nrdoclot = SUBSTRING(STRING(aux_nrdolote,"999999"),2,5)
                 aux_nrdocmto = INTEGER(aux_nrdoclot + STRING(aux_nrseqint,
                                                              "99999")).

          /* Rotina eliminada apos a conversao para reais */

          /*
          IF   aux_tpdebito = 2   THEN
               IF   aux_vldaurvs > 0   THEN
                    aux_vllanmto = TRUNCATE(aux_vllanmto * aux_vldaurvs,2).
               ELSE
               IF   aux_flgdaurv   THEN
                    aux_vllanmto = TRUNCATE(aux_vllanmto * crapmfx.vlmoefix,2).
               ELSE
                    glb_cdcritic = 211.
          */

          IF   glb_cdcritic = 0   AND
               aux_cdempres = 4   THEN
               IF   CAN-FIND(craplcm WHERE
                             craplcm.cdcooper = glb_cdcooper        AND
                             craplcm.nrdconta = aux_nrdconta        AND
                             craplcm.dtmvtolt = craplot.dtmvtolt    AND
                             craplcm.cdhistor = aux_cdhistor        AND
                             craplcm.nrdocmto = aux_nrdocmto
                             USE-INDEX craplcm2)                    THEN
                    DO:
                        glb_cdcritic = 285.
                        RUN fontes/critic.p.
                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                          " - " + glb_cdprogra + "' --> '" +
                                          glb_dscritic +
                                          " EMP = " + STRING(aux_cdempres) +
                                          " SEQ = " + STRING(aux_nrseqint) +
                                          " CONTA = " + STRING(aux_nrdconta) +
                                          " >> log/proc_batch.log").
                    END.

          IF   glb_cdcritic > 0   THEN
               DO:
                   CREATE craprej.
                   ASSIGN craprej.dtmvtolt = craplot.dtmvtolt
                          craprej.cdagenci = craplot.cdagenci
                          craprej.cdbccxlt = craplot.cdbccxlt
                          craprej.nrdolote = craplot.nrdolote
                          craprej.tplotmov = craplot.tplotmov
                          craprej.nrdconta = aux_nrdconta
                          craprej.cdempres = aux_cdempres
                          craprej.cdhistor = aux_cdhistor
                          craprej.vllanmto = aux_vllanmto
                          craprej.cdcritic = glb_cdcritic
                          craprej.tpintegr = 1
                          craprej.cdcooper = glb_cdcooper

                          craplot.qtinfoln = craplot.qtinfoln + 1
                          craplot.vlinfocr = craplot.vlinfocr + aux_vllanmto

                          glb_cdcritic     = 0.
                   VALIDATE craprej.
               END.
          ELSE
               DO:
					
             		{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

					/* verifica e eh um dos historicos de folha ou beneficio e deleta tbfolha_lanaut
						caso nao for um dos historicos parametrizados deixa seguir o processo normalmente */
					RUN STORED-PROCEDURE pc_inserir_lanaut
					aux_handproc = PROC-HANDLE NO-ERROR (INPUT glb_cdcooper
														,INPUT aux_nrdconta
														,INPUT craplot.dtmvtolt
														,INPUT aux_cdhistor
														,INPUT aux_vllanmto
														,INPUT craplot.cdagenci
														,INPUT craplot.cdbccxlt
														,INPUT craplot.nrdolote
														,INPUT aux_nrseqint
														,"").
						

					CLOSE STORED-PROC pc_inserir_lanaut
					aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

					{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                  
					ASSIGN glb_dscritic = ""
							glb_dscritic = pc_inserir_lanaut.pr_dscritic
										WHEN pc_inserir_lanaut.pr_dscritic <> ?.


					IF  glb_dscritic = "" OR glb_dscritic = ? THEN
						DO:
                   /* BLOCO DA INSERÇAO DA CRAPLCM */
                   RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
                     (INPUT craplot.dtmvtolt                /* par_dtmvtolt */
                     ,INPUT craplot.cdagenci                /* par_cdagenci */
                     ,INPUT craplot.cdbccxlt                /* par_cdbccxlt */
                     ,INPUT craplot.nrdolote                /* par_nrdolote */
                     ,INPUT aux_nrdconta                    /* par_nrdconta */
                     ,INPUT aux_nrdocmto                    /* par_nrdocmto */
                     ,INPUT aux_cdhistor                    /* par_cdhistor */
                     ,INPUT aux_nrseqint                    /* par_nrseqdig */
                     ,INPUT aux_vllanmto                    /* par_vllanmto */
                     ,INPUT aux_nrdconta                    /* par_nrdctabb */
                     ,INPUT ""                              /* par_cdpesqbb */
                     ,INPUT 0                               /* par_vldoipmf */
                     ,INPUT 0                               /* par_nrautdoc */
                     ,INPUT 0                               /* par_nrsequni */
                     ,INPUT 0                               /* par_cdbanchq */
                     ,INPUT 0                               /* par_cdcmpchq */
                     ,INPUT 0                               /* par_cdagechq */
                     ,INPUT 0                               /* par_nrctachq */
                     ,INPUT 0                               /* par_nrlotchq */
                     ,INPUT 0                               /* par_sqlotchq */
                     ,INPUT ""                              /* par_dtrefere */
                     ,INPUT ""                              /* par_hrtransa */
                     ,INPUT ""                              /* par_cdoperad */
                     ,INPUT ""                              /* par_dsidenti */
                     ,INPUT glb_cdcooper                    /* par_cdcooper */
                     ,INPUT STRING(aux_nrdconta,"99999999") /* par_nrdctitg */
                     ,INPUT ""                              /* par_dscedent */
                     ,INPUT 0                               /* par_cdcoptfn */
                     ,INPUT 0                               /* par_cdagetfn */
                     ,INPUT 0                               /* par_nrterfin */
                     ,INPUT 0                               /* par_nrparepr */
                     ,INPUT 0                               /* par_nrseqava */
                     ,INPUT 0                               /* par_nraplica */
                     ,INPUT 0                               /* par_cdorigem */
                     ,INPUT 0                               /* par_idlautom */
                     /* CAMPOS OPCIONAIS DO LOTE                                                             */ 
                     ,INPUT 0                               /* Processa lote                                 */
                     ,INPUT 0                               /* Tipo de lote a movimentar                     */
                     /* CAMPOS DE SAIDA                                                                      */                                            
                     ,OUTPUT TABLE tt-ret-lancto            /* Collection que contem o retorno do lancamento */
                     ,OUTPUT aux_incrineg                   /* Indicador de critica de negocio               */
                     ,OUTPUT aux_cdcritic                   /* Codigo da critica                             */
                     ,OUTPUT aux_dscritic).                 /* Descricao da critica                          */
                     
                   IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                      DO: 
                          /* Tratamento de erros */
                           glb_cdcritic = aux_cdcritic.
                           RUN fontes/critic.p.
                           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                             " - " + glb_cdprogra + "' --> '" +
                                             aux_dscritic +
                                             " EMP = " + STRING(aux_cdempres) +
                                             " SEQ = " + STRING(aux_nrseqint) +
                                             " CONTA = " + STRING(aux_nrdconta) +
                                             " >> log/proc_batch.log").
                           UNDO TRANS_1, RETURN.
                      END.   
                   ELSE 
                      DO:
                        /* Posicionando no registro da craplcm criado acima */
                        FIND FIRST tt-ret-lancto.
                        FIND FIRST craplcm WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm NO-ERROR.
                      END.                
                   
                   ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
                          craplot.qtcompln = craplot.qtcompln + 1
                          craplot.vlinfocr = craplot.vlinfocr + aux_vllanmto
                          craplot.vlcompcr = craplot.vlcompcr + aux_vllanmto
                          craplot.nrseqdig = craplcm.nrseqdig.
            
               END.
					ELSE
						DO:
						   glb_cdcritic = 0.
                           RUN fontes/critic.p.
                           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                             " - " + glb_cdprogra + "' --> '" +
                                             glb_dscritic +
                                             " >> log/proc_batch.log").
                           UNDO TRANS_1, RETURN.
						END.
               END.

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

          crapres.nrdconta = aux_nrseqint.

       END.  /*  Fim da Transacao  */

    END.   /*  Fim do DO WHILE TRUE  */

    INPUT  STREAM str_2 CLOSE.
    
    /* Liberacao do handle rotina lancamento craplcm*/
    IF  VALID-HANDLE(h-b1wgen0200) THEN
        DELETE PROCEDURE h-b1wgen0200.


    IF   glb_cdcritic = 0   THEN
         DO:
             ASSIGN tot_qtinfoln = 0
                    tot_vlinfodb = 0
                    tot_vlinfocr = 0
                    tot_qtcompln = 0
                    tot_vlcompdb = 0
                    tot_vlcompcr = 0
                    tot_qtdifeln = 0
                    tot_vldifedb = 0
                    tot_vldifecr = 0.
             
             OUTPUT STREAM str_1 TO VALUE(aux_nmarquiv[aux_contaarq])
                    PAGED PAGE-SIZE 84.
             
             VIEW STREAM str_1 FRAME f_cabrel080_1.
 
             ASSIGN rel_dsintegr = "CREDITO DE PAGAMENTO".

             RUN p_imprime_relatorio.

             ASSIGN aux_cdagenci = 1
                    aux_cdbccxlt = 100
                    aux_nrdolote = aux_nrlotccs.

             ASSIGN rel_dsintegr = "CONTA SALARIO".

             RUN p_imprime_relatorio.

             DISPLAY STREAM str_1 tot_qtinfoln  tot_vlinfodb  tot_vlinfocr  
                                  tot_qtcompln  tot_vlcompdb  tot_vlcompcr
                                  tot_qtdifeln  tot_vldifedb  tot_vldifecr      
                                  WITH FRAME f_total_geral.

             OUTPUT STREAM str_1 CLOSE.

             glb_cdcritic = IF tot_qtdifeln = 0 THEN 190 ELSE 191.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '" +
                               glb_dscritic + "' --> '" + aux_nmarqint +
                               " >> log/proc_batch.log").

             ASSIGN glb_nrcopias = 1
                    glb_nmformul = IF aux_nrdevias[aux_contaarq] > 1
                                      THEN STRING(aux_nrdevias[aux_contaarq]) +
                                           "vias"
                                      ELSE " "
                    glb_nmarqimp = aux_nmarquiv[aux_contaarq]
                    aux_nmarqimp = glb_nmarqimp.
                        
             /* Vai para batch noturno ou 
                Imprime na hora da solicitacao SOL008 */
             IF  glb_inproces = 1  THEN
                 RUN gerar_impressao.
             ELSE
                 RUN fontes/imprim.p. 

             /* Copia o arquivo, atualmente no dir rl, p/ o dir rlnsv */
             UNIX SILENT VALUE("cp " + aux_nmarqimp + " rlnsv").

             /*  Move arquivo integrado para o diretorio salvar  */
             UNIX SILENT VALUE("mv " + aux_nmarqint + " salvar").

             /*  Exclui rejeitados apos a impressao  */

             TRANS_2:

             FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper  AND
                                    craprej.dtmvtolt = aux_dtmvtolt  AND
                                    craprej.cdagenci = aux_cdagenci  AND
                                    craprej.cdbccxlt = aux_cdbccxlt  AND
                                    craprej.nrdolote = aux_nrdolote  AND
                                    craprej.cdempres = aux_cdempres  AND
                                    craprej.tpintegr = 1
                                    EXCLUSIVE-LOCK TRANSACTION ON ERROR 
                                    UNDO TRANS_2, RETURN:

                 DELETE craprej.

             END.   /*  Fim do FOR EACH e da transacao  */

             TRANS_3:
             FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper  AND
                                    craprej.dtmvtolt = aux_dtmvtolt  AND
                                    craprej.cdagenci = aux_cdagenci  AND
                                    craprej.cdbccxlt = aux_cdbccxlt  AND
                                    craprej.nrdolote = aux_nrdolote  AND
                                    craprej.cdempres = aux_cdempres  AND
                                    craprej.tpintegr = 1
                                    EXCLUSIVE-LOCK TRANSACTION ON ERROR 
                                    UNDO TRANS_3, RETURN:

                 DELETE craprej.

             END.   /*  Fim do FOR EACH */
             
             TRANS_4:

             DO TRANSACTION ON ERROR UNDO TRANS_4, RETURN:

                DO WHILE TRUE:

                   FIND crapres WHERE crapres.cdcooper = glb_cdcooper   AND
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
                                 UNIX SILENT
                                       VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                             " - " + glb_cdprogra + "' --> '" +
                                             glb_dscritic +
                                             " >> log/proc_batch.log").
                                 UNDO TRANS_4, RETURN.
                             END.

                   LEAVE.

                END.  /*  Fim do DO WHILE TRUE  */

                ASSIGN crapres.nrdconta = 0
                       crapsol.insitsol = 2.

             END.  /*  Fim da transacao  */

         END.  /*  Fim da impressao do relatorio  */

    ASSIGN glb_nrctares = 0
           glb_inrestar = 0.

END.  /*  Fim do FOR EACH  -- Leitura das solicitacoes --  */

IF   NOT aux_regexist   THEN
     DO:
         glb_cdcritic = 157.
         RUN fontes/critic.p.

         UNIX SILENT VALUE ("echo " +
                             STRING(TIME,"HH:MM:SS") + " - " +
                             glb_cdprogra + "' --> '" +
                             glb_dscritic + " - SOL008"
                             + " >> log/proc_batch.log").
         RETURN.
     END.

RUN fontes/fimprg.p.



PROCEDURE p_trata_crapccs:
       
    aux_nrdocmto = INTEGER(STRING(aux_nrseqint,"99999")).
    
    DO WHILE TRUE:

       IF   crapccs.cdsitcta = 2 THEN
            glb_cdcritic = 444.
       ELSE
       IF   crapccs.dtcantrf <> ? THEN
            glb_cdcritic = 890.
          
       LEAVE.
    END.

    TRANS_5:

    DO TRANSACTION ON ERROR UNDO TRANS_5, RETURN:

       IF   aux_flfirst2 THEN
            aux_nrlotccs = 10201.

       DO WHILE TRUE:
         
          FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                             craplot.dtmvtolt = aux_dtintegr   AND
                             craplot.cdagenci = 1              AND
                             craplot.cdbccxlt = 100            AND
                             craplot.nrdolote = aux_nrlotccs
                             USE-INDEX craplot1 NO-ERROR NO-WAIT.

          IF   NOT AVAILABLE craplot  THEN
               DO:
                   IF   NOT LOCKED craplot   THEN
                        DO:
                            CREATE craplot.
                            ASSIGN craplot.cdcooper = glb_cdcooper
                                   craplot.dtmvtolt = aux_dtintegr
                                   craplot.cdagenci = 1
                                   craplot.cdbccxlt = 100
                                   craplot.nrdolote = aux_nrlotccs
                                   craplot.tplotmov = 32
                                   aux_flfirst2     = FALSE.
                            VALIDATE craplot.
                            LEAVE.
                        END.
                   ELSE
                        DO:
                            IF   NOT aux_flfirst2 THEN
                                 DO:
                                     PAUSE 1 NO-MESSAGE.
                                     NEXT.
                                 END.
                        END.
               END.         
          ELSE
               IF   aux_flfirst2 THEN
                    aux_nrlotccs = aux_nrlotccs + 1.
               ELSE
                    LEAVE.
       END.
          
       IF   glb_cdcritic > 0   THEN
            DO:
                CREATE craprej.
                ASSIGN craprej.dtmvtolt = craplot.dtmvtolt
                       craprej.cdagenci = craplot.cdagenci
                       craprej.cdbccxlt = craplot.cdbccxlt
                       craprej.nrdolote = craplot.nrdolote
                       craprej.tplotmov = craplot.tplotmov
                       craprej.nrdconta = aux_nrdconta
                       craprej.cdempres = aux_cdempres
                       craprej.cdhistor = aux_cdhistor
                       craprej.vllanmto = aux_vllanmto
                       craprej.cdcritic = glb_cdcritic
                       craprej.tpintegr = 1
                       craprej.cdcooper = glb_cdcooper
                      
                       craplot.qtinfoln = craplot.qtinfoln + 1
                       craplot.vlinfocr = craplot.vlinfocr + aux_vllanmto

                       glb_cdcritic     = 0.
                VALIDATE craprej.
            END.
       ELSE
            DO:
                aux_nrdocmt2 = aux_nrdocmto.
                
                DO WHILE TRUE:
                                
                   FIND craplcs WHERE craplcs.cdcooper = glb_cdcooper   AND
                                      craplcs.dtmvtolt = glb_dtmvtolt   AND
                                      craplcs.nrdconta = aux_nrdconta   AND
                                      craplcs.cdhistor = 560            AND
                                      craplcs.nrdocmto = aux_nrdocmt2
                                      NO-LOCK NO-ERROR NO-WAIT.

                   IF   AVAILABLE craplcs THEN
                        aux_nrdocmt2 = (aux_nrdocmt2 + 1000000).
                   ELSE
                        LEAVE.
          
                END.  /*  Fim do DO WHILE TRUE  */

                aux_nrdocmto = aux_nrdocmt2.
          
                CREATE craplcs.
                ASSIGN craplcs.cdcooper = glb_cdcooper
                       craplcs.cdopecrd = glb_cdoperad
                       craplcs.dtmvtolt = aux_dtintegr
                       craplcs.nrdconta = aux_nrdconta
                       craplcs.nrdocmto = aux_nrdocmto
                       craplcs.vllanmto = aux_vllanmto
                       craplcs.cdhistor = 560
                       craplcs.nrdolote = craplot.nrdolote 
                       craplcs.cdbccxlt = craplot.cdbccxlt
                       craplcs.cdagenci = craplot.cdagenci

                       craplcs.flgenvio = FALSE
                       craplcs.cdopetrf = ""
                       craplcs.dttransf = ?
                       craplcs.hrtransf = 0
                       craplcs.nmarqenv = ""
                          
                       craplot.qtinfoln = craplot.qtinfoln + 1
                       craplot.qtcompln = craplot.qtcompln + 1
                       craplot.vlinfocr = craplot.vlinfocr + aux_vllanmto
                       craplot.vlcompcr = craplot.vlcompcr + aux_vllanmto
                       craplot.nrseqdig = aux_nrseqint.
                VALIDATE craplcs.
            END.
                              
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
                        UNDO TRANS_5, RETURN.
                    END.
          LEAVE.

       END.  /*  Fim do DO WHILE TRUE  */

       crapres.nrdconta = aux_nrseqint.

    END.  /*  Fim da Transacao  */

END PROCEDURE.




PROCEDURE p_imprime_relatorio:


   FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper      AND
                      crapemp.cdempres = crapsol.cdempres
                      NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapemp   THEN
        rel_nmempres = FILL("*",20).
   ELSE
        rel_nmempres = crapemp.nmresemp.

              
   FIND craplot WHERE craplot.cdcooper = glb_cdcooper  AND
                      craplot.dtmvtolt = aux_dtintegr  AND
                      craplot.cdagenci = aux_cdagenci  AND
                      craplot.cdbccxlt = aux_cdbccxlt  AND
                      craplot.nrdolote = aux_nrdolote
                      USE-INDEX craplot1 NO-LOCK NO-ERROR.

   IF   AVAILABLE craplot   THEN
        ASSIGN rel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
               rel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
               rel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.
   ELSE
        NEXT.

   DISPLAY STREAM str_1 rel_dsintegr       rel_nmempres
                        craplot.dtmvtolt   craplot.cdagenci
                        craplot.cdbccxlt   craplot.nrdolote
                        craplot.tplotmov   WITH FRAME f_integracao.

   FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper  AND
                          craprej.dtmvtolt = aux_dtmvtolt  AND
                          craprej.cdagenci = aux_cdagenci  AND
                          craprej.cdbccxlt = aux_cdbccxlt  AND
                          craprej.nrdolote = aux_nrdolote  AND
                          craprej.cdempres = aux_cdempres  AND
                          craprej.tpintegr = 1             NO-LOCK
                          BREAK BY craprej.dtmvtolt  
                                   BY craprej.cdagenci
                                      BY craprej.cdbccxlt  
                                         BY craprej.nrdolote
                                            BY craprej.cdempres  
                                               BY craprej.tpintegr
                                                  BY craprej.nrdconta:

       IF   glb_cdcritic <> craprej.cdcritic   THEN
            DO:
                glb_cdcritic = craprej.cdcritic.
                RUN fontes/critic.p.
                IF   glb_cdcritic = 211   THEN
                     glb_dscritic = glb_dscritic + " URV do dia " +
                                    STRING(aux_dtintegr,"99/99/9999").
            END.

       DISPLAY STREAM str_1 craprej.nrdconta  craprej.cdhistor
                            craprej.vllanmto  glb_dscritic
                            WITH FRAME f_rejeitados.

       DOWN STREAM str_1 WITH FRAME f_rejeitados.

       IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
            DO:
                PAGE STREAM str_1.

                DISPLAY STREAM str_1 rel_dsintegr      rel_nmempres
                                     craplot.dtmvtolt  craplot.cdagenci
                                     craplot.cdbccxlt  craplot.nrdolote
                                     craplot.tplotmov  WITH FRAME f_integracao.
            END.

   END.   /*  Fim do FOR EACH  --  Leitura dos rejeitados  */

   IF   LINE-COUNTER(str_1) > 78   THEN
        DO:
            PAGE STREAM str_1.

            DISPLAY STREAM str_1 rel_dsintegr      rel_nmempres
                                 craplot.dtmvtolt  craplot.cdagenci
                                 craplot.cdbccxlt  craplot.nrdolote
                                 craplot.tplotmov  WITH FRAME f_integracao.
        END.

   ASSIGN tot_qtinfoln = tot_qtinfoln + craplot.qtinfoln
          tot_vlinfodb = tot_vlinfodb + craplot.vlinfodb
          tot_vlinfocr = tot_vlinfocr + craplot.vlinfocr
          tot_qtcompln = tot_qtcompln + craplot.qtcompln
          tot_vlcompdb = tot_vlcompdb + craplot.vlcompdb
          tot_vlcompcr = tot_vlcompcr + craplot.vlcompcr
          tot_qtdifeln = tot_qtdifeln + rel_qtdifeln
          tot_vldifedb = tot_vldifedb + rel_vldifedb 
          tot_vldifecr = tot_vldifecr + rel_vldifecr. 

   DISPLAY STREAM str_1 craplot.qtinfoln  craplot.vlinfodb
                        craplot.vlinfocr  craplot.qtcompln
                        craplot.vlcompdb  craplot.vlcompcr
                        rel_qtdifeln      rel_vldifedb
                        rel_vldifecr      WITH FRAME f_totais.
                        
END PROCEDURE.             
 

PROCEDURE gerar_impressao.
    { includes/impressao.i }
END.
/* .......................................................................... */


