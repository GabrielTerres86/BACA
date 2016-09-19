/* ...........................................................................

   Programa: Fontes/crps079.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/94.                         Ultima atualizacao: 25/04/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 042.
               Processar o reajuste das prestacoes variaveis (linhas de credito
               com tipo igual a 2). Emite relatorio 64.

   Alteracoes: 29/09/94 - Alterado para permanecer os centavos na prestacao
                          (Edson).

               01/11/95 - Alterado para tratar os reajustes somente das agencias
                          solicitadas (Odair).

               19/11/96 - Alterada a mascara do campo nrctremp (Odair).

               21/11/96 - Alterado para acessar craplcr e testar o tipo de
                          linha de credito. Deve ser igual a 2 (Edson).

               05/12/97 - Alterado para verificar a data da solicitacao para
                          aumentos a apartir daquela data (Odair)

               15/02/2006 - Unificacao dos Campos - SQLWorks - Fernando.
               
               01/09/2008 - Alteracao CDEMPRES (Kbase).
               
               01/11/2012 - Tratar so os emprestimos do tipo zero Price TR (Oscar).
               
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               25/04/2014 - Aumentado format do campo cdlcremp de 3 para 4
                            posicoes (Tiago/Gielow SD137074).             
............................................................................. */

DEF STREAM str_1.  /*  Para relatorio do reajuste das prestacoes variaveis  */

{ includes/var_batch.i {1} }

DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR rel_cdempres AS INT                                   NO-UNDO.
DEF        VAR rel_inreajus AS DECIMAL                               NO-UNDO.
DEF        VAR rel_cdagenci AS INT                                   NO-UNDO.

DEF        VAR res_nrseqsol AS INT                                   NO-UNDO.
DEF        VAR res_nrctremp AS INT                                   NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_dtrefere AS DATE  FORMAT "99/99/9999"             NO-UNDO.

ASSIGN glb_cdprogra = "crps079"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

FORM rel_cdempres AT 13 FORMAT "zzzz9"              LABEL "EMPRESA"
     rel_cdagenci AT 24 FORMAT "zz9"                LABEL "PA"
     rel_inreajus AT 32 FORMAT "zz9.99"             LABEL "% DO REAJUSTE"
     aux_dtrefere AT 50 FORMAT "99/99/9999"         LABEL "DATA LIMITE"
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS DOWN WIDTH 80 FRAME f_resumo.

ASSIGN res_nrseqsol = INTEGER(SUBSTRING(glb_dsrestar,1,3))
       res_nrctremp = INTEGER(SUBSTRING(glb_dsrestar,5,7)).

IF   glb_inrestar > 0   AND   glb_nrctares = 0   THEN
     glb_inrestar = 0.

FOR EACH crapsol WHERE crapsol.cdcooper = glb_cdcooper     AND
                       crapsol.dtrefere = glb_dtmvtolt     AND
                       crapsol.nrsolici = 42               AND
                       crapsol.insitsol = 1 ON ERROR UNDO, RETURN.

    IF   glb_inrestar > 0   THEN
         IF   crapsol.nrseqsol <> res_nrseqsol   THEN
              NEXT.

    ASSIGN rel_inreajus = 1 + (DECIMAL(SUBSTRING(crapsol.dsparame,1,6)) / 100)
           rel_cdagenci = INTEGER(SUBSTRING(crapsol.dsparame,8,3))
           aux_dtrefere = DATE(INT(SUBSTR(crapsol.dsparame,15,2)),
                               INT(SUBSTR(crapsol.dsparame,12,2)),
                               INT(SUBSTR(crapsol.dsparame,18,4))).

    TRANS_1:

    FOR EACH crapepr WHERE crapepr.cdcooper  = glb_cdcooper       AND
                           crapepr.cdempres  = crapsol.cdempres   AND
                           crapepr.dtmvtolt <= aux_dtrefere       AND
                           crapepr.nrdconta >= glb_nrctares       AND
                           crapepr.tpemprst  = 0
                           USE-INDEX crapepr3
                           TRANSACTION ON ERROR UNDO TRANS_1, RETURN:

        IF   glb_inrestar > 0    THEN
             IF   crapepr.nrdconta = glb_nrctares   THEN
                  IF   crapepr.nrctremp <= res_nrctremp   THEN
                       NEXT.

        /*FIND craplcr OF crapepr NO-LOCK NO-ERROR.*/
        FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper   AND
                           craplcr.cdlcremp = crapepr.cdlcremp
                           NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE craplcr   THEN
             DO:
                 glb_cdcritic = 363.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                   glb_cdprogra + "' --> '" + glb_dscritic +
                                   " " + STRING(crapepr.cdlcremp,"9999") +
                                   " >> log/proc_batch.log").
                 UNDO TRANS_1, RETURN.
             END.

        IF   craplcr.tplcremp <> 2   THEN          /*   2 = EQUIV. SALARIAL   */
             NEXT.

        IF   rel_cdagenci <> 0 THEN
             DO:
                 /*FIND crapass OF crapepr NO-LOCK NO-ERROR.*/
                 FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                    crapass.nrdconta = crapepr.nrdconta
                                    NO-LOCK NO-ERROR.
                
                 IF   NOT AVAILABLE crapass THEN
                      DO:
                          glb_cdcritic = 251.
                          RUN fontes/critic.p.
                          UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                            " - " + glb_cdprogra + "' --> '" +
                                            glb_dscritic +
                                            " >> log/proc_batch.log").
                          UNDO TRANS_1, RETURN.
                      END.

                 IF   crapass.cdagenci <> rel_cdagenci THEN
                      NEXT.
             END.

        crapepr.vlpreemp = ROUND(crapepr.vlpreemp * rel_inreajus,2).

        DO WHILE TRUE:

           FIND crapres WHERE crapres.cdcooper = glb_cdcooper    AND
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

        END.   /*  Fim do DO WHILE TRUE  */

        ASSIGN crapres.nrdconta = crapepr.nrdconta
               crapres.dsrestar = STRING(crapsol.nrseqsol,"999") + " " +
                                  STRING(crapepr.nrctremp,"9999999").

    END.  /*  Fim do FOR EACH e da transacao -- Leitura dos emprestimos  */

    DO TRANSACTION:

       ASSIGN crapsol.insitsol = 2
              glb_inrestar     = 0.

    END.

END.   /*  Fim do FOR EACH e da Transacao --  Leitura das solicitacoes  */

/*  Gera relatorio das solicitacoes atendidas  */

glb_cdempres = 11.

{ includes/cabrel080_1.i }               /* Monta cabecalho do relatorio */

OUTPUT STREAM str_1 TO rl/crrl064.lst PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel080_1.

FOR EACH crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                       crapsol.dtrefere = glb_dtmvtolt   AND
                       crapsol.nrsolici = 42             AND
                       crapsol.insitsol = 2 NO-LOCK
                       BY crapsol.cdempres:

    ASSIGN rel_inreajus = DECIMAL(SUBSTRING(crapsol.dsparame,1,06))
           rel_cdempres = crapsol.cdempres
           rel_cdagenci = INTEGER(SUBSTRING(crapsol.dsparame,8,3)).

    DISPLAY STREAM str_1 rel_cdempres  rel_cdagenci rel_inreajus aux_dtrefere
                         WITH FRAME f_resumo.

    DOWN STREAM str_1 2 WITH FRAME f_resumo.

    IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
         PAGE STREAM str_1.

END.  /*  Fim do FOR EACH -- Leitura das solicitacoes  */

OUTPUT STREAM str_1 CLOSE.

glb_infimsol = TRUE.

RUN fontes/fimprg.p.

IF   glb_cdcritic > 0   THEN
     RETURN.

ASSIGN glb_nrcopias = 1
       glb_nmarqimp = "rl/crrl064.lst"
       glb_nmformul = "".

RUN fontes/imprim.p.

/* .......................................................................... */

