/* ...........................................................................

   Programa: Fontes/crps028.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Julho/92.                          Ultima atualizacao: 15/08/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 019.
               Processar o reajuste dos planos.
               Emite relatorio 29.

   Alteracoes: 29/09/94 - Alterado para permanecer os centavos na prestacao
                          (Edson).

               31/10/95 - Alterado para reajustar somente os associados de uma
                          determinada agencia. (Odair).

               22/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
             15/02/2006 - Unificacao dos bancos - SQLWorks - Eder
             
             01/09/2008 - Alteracao CDEMPRES (Kbase).
             
             15/08/2013 - Nova forma de chamar as agências, de PAC agora 
                          a escrita será PA (André Euzébio - Supero).
............................................................................. */

DEF STREAM str_1.  /*  Para relatorio do reajuste dos planos  */

{ includes/var_batch.i {1} }

DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "]      NO-UNDO.

DEF        VAR rel_cdempres AS INT                                   NO-UNDO.
DEF        VAR rel_inreajus AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vlminpre AS DECIMAL                               NO-UNDO.
DEF        VAR rel_cdagenci AS INT                                   NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_nrdconta AS INT                                   NO-UNDO.
DEF        VAR aux_nrseqsol AS INT                                   NO-UNDO.
DEF        VAR aux_nrctrpla AS INT                                   NO-UNDO.

DEF        VAR aux_dtrefere AS DATE                                  NO-UNDO.

ASSIGN glb_cdprogra = "crps028"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

FORM rel_cdempres AT 13 FORMAT "zzzz9"              LABEL "EMPRESA"
     rel_cdagenci AT 23 FORMAT "zz9"                LABEL "PA"
     rel_inreajus AT 30 FORMAT "zz9.99"             LABEL "% DO REAJUSTE"
     rel_vlminpre AT 50 FORMAT "zzz,zzz,zzz,zz9.99" LABEL "VALOR MINIMO"
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS DOWN WIDTH 80 FRAME f_resumo.

ASSIGN  aux_nrseqsol = INTEGER(SUBSTRING(glb_dsrestar,01,3))
        aux_nrdconta = INTEGER(SUBSTRING(glb_dsrestar,05,8))
        aux_nrctrpla = INTEGER(SUBSTRING(glb_dsrestar,14,6))

        aux_dtrefere = DATE(MONTH(glb_dtmvtolt),01,YEAR(glb_dtmvtolt)).

IF   glb_inrestar > 0   AND   glb_nrctares = 0   THEN
     glb_inrestar = 0.

FOR EACH crapsol WHERE crapsol.cdcooper = glb_cdcooper  AND
                       crapsol.dtrefere = glb_dtmvtolt  AND
                       crapsol.nrsolici = 19            AND
                       crapsol.insitsol = 1             ON ERROR UNDO, RETURN:

    IF   glb_inrestar > 0   THEN
         IF   crapsol.nrseqsol = aux_nrseqsol   THEN
              glb_inrestar = 0.
         ELSE
              NEXT.
    ELSE
         aux_nrdconta = 0.

    ASSIGN rel_inreajus = 1 + (DECIMAL(SUBSTRING(crapsol.dsparame,1,6)) / 100)
           rel_vlminpre = DECIMAL(SUBSTRING(crapsol.dsparame,8,15))
           rel_cdagenci = INTEGER(SUBSTRING(crapsol.dsparame,24,3)).

    TRANS_1:

    FOR EACH crappla WHERE crappla.cdcooper = glb_cdcooper      AND
                           crappla.cdempres = crapsol.cdempres  AND
                           crappla.nrdconta > aux_nrdconta      AND
                           crappla.tpdplano = 1                 AND
                           crappla.cdsitpla = 1                 AND
                           crappla.dtinipla < aux_dtrefere
                           TRANSACTION ON ERROR UNDO TRANS_1, RETURN:

        IF   rel_cdagenci <> 0 THEN
             DO:
                 FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                                    crapass.nrdconta = crappla.nrdconta
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

        crappla.vlprepla = ROUND(crappla.vlprepla * rel_inreajus,2).

        IF   crappla.vlprepla < rel_vlminpre   THEN
             crappla.vlprepla = rel_vlminpre.

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
                         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                           " - " + glb_cdprogra + "' --> '" +
                                           glb_dscritic +
                                           " >> log/proc_batch.log").
                         UNDO TRANS_1, RETURN.
                     END.

           LEAVE.

        END.   /*  Fim do DO WHILE TRUE  */

        ASSIGN crapres.nrdconta = crapsol.nrseqsol
               crapres.dsrestar = STRING(crapsol.nrseqsol,"999") + " " +
                                  STRING(crappla.nrdconta,"99999999") + " " +
                                  STRING(crappla.nrctrpla,"999999").

    END.  /* Fim do FOR EACH e da transacao -- Leitura do cadastro de planos */

    DO TRANSACTION:

       crapsol.insitsol = 2.

    END.

END.   /*  Fim do FOR EACH e da Transacao --  Leitura das solicitacoes  */

/*  Gera relatorio das solicitacoes atendidas  */

glb_cdempres = 11.

{ includes/cabrel080_1.i }               /* Monta cabecalho do relatorio */

OUTPUT STREAM str_1 TO rl/crrl029.lst PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel080_1.

FOR EACH crapsol WHERE crapsol.cdcooper = glb_cdcooper  AND
                       crapsol.dtrefere = glb_dtmvtolt  AND
                       crapsol.nrsolici = 19            AND
                       crapsol.insitsol = 2             NO-LOCK:

    ASSIGN rel_inreajus = DECIMAL(SUBSTRING(crapsol.dsparame,1,06))
           rel_vlminpre = DECIMAL(SUBSTRING(crapsol.dsparame,8,15))
           rel_cdempres = crapsol.cdempres
           rel_cdagenci = INTEGER(SUBSTRING(crapsol.dsparame,24,3)).

    DISPLAY STREAM str_1
            rel_cdempres  rel_cdagenci rel_inreajus  rel_vlminpre
            WITH FRAME f_resumo.

    DOWN STREAM str_1 2 WITH FRAME f_resumo.

    IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
         PAGE STREAM str_1.

END.  /*  Fim do FOR EACH -- Leitura das solicitacoes  */

OUTPUT STREAM str_1 CLOSE.

RUN fontes/fimprg.p.

IF   glb_cdcritic > 0   THEN
     RETURN.

ASSIGN glb_nrcopias = 1
       glb_nmarqimp = "rl/crrl029.lst"
       glb_nmformul = "".

RUN fontes/imprim.p.

/* .......................................................................... */

