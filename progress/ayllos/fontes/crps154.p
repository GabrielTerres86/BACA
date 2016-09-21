/* ..........................................................................

   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ESTE CRPS ESTA INATIVO - POIS AS POUPANCAÇAS SAO EFETIVADAS DIRETAMENTE NA
   ATENDA (27/04/2010) (Gabriel)
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

   Programa: Fontes/crps154.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Abril/96.                     Ultima atualizacao: 15/02/2006

   Dados referentes ao programa:

   Frequencia: Roda Mensalmente no Processo de Limpeza
   Objetivo  : Limpeza dos registros do crawrpp.
               Atende a Solicitacao 013.
               Exclusividade = 2
               Ordem do Programa na Solicitacao = 17

   Alteracao - 10/01/2000 - Padronizar mensagens (Deborah).
   
               15/02/2006 - Unificacao dos bancos - SQLWorks - Eder
............................................................................. */

{ includes/var_batch.i "NEW" }

/* Acumula a quantidade  de crawrpp deletados */

DEF        VAR aux_qtregdel AS INT.
DEF        VAR aux_dtrefere AS DATE.

ASSIGN  glb_cdprogra = "crps154".
        glb_flgbatch = false.

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     QUIT.

/*  Verifica se deve executar  */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "GENERI"      AND
                   craptab.cdempres = 00            AND
                   craptab.cdacesso = "EXELIMPEZA"  AND
                   craptab.tpregist = 001           NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab THEN
     DO:
         glb_cdcritic = 176.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                            " - " + glb_cdprogra + "' --> '" + glb_dscritic +
                            " >> log/proc_batch.log").
         QUIT.
     END.
ELSE
     IF   craptab.dstextab <> "0" THEN
          DO:
              glb_cdcritic = 177.
              RUN fontes/critic.p.
              UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                                 " - " + glb_cdprogra + "' --> '" +
                                 glb_dscritic + " >> log/proc_batch.log").
              QUIT.
          END.

   /*  Procedimentos de limpeza */

ASSIGN aux_dtrefere = glb_dtmvtolt - DAY(glb_dtmvtolt)
       aux_dtrefere = aux_dtrefere - DAY(aux_dtrefere)
       aux_dtrefere = aux_dtrefere - DAY(aux_dtrefere) + 1.

FOR EACH crawrpp WHERE crawrpp.cdcooper = glb_cdcooper  AND
                       crawrpp.dtmvtolt < aux_dtrefere  EXCLUSIVE-LOCK
                       TRANSACTION ON ERROR UNDO, RETRY:

    DELETE crawrpp.
    ASSIGN aux_qtregdel = aux_qtregdel + 1.

END. /* Fim do for each crawrpp */

/*  Imprime no log do processo os totais das exclusoes   */

glb_cdcritic = 661.
RUN fontes/critic.p.

UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                   glb_cdprogra + "' --> '" + glb_dscritic + " WRPP = " +
                   STRING(aux_qtregdel,"z,zzz,zz9") + " >> log/proc_batch.log").

RUN fontes/fimprg.p.

/* .......................................................................... */

