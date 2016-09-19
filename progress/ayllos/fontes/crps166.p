/* ..........................................................................

   Programa: Fontes/crps166.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Julho/96                          Ultima atualizacao: 09/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 013.
               Fazer limpeza mensal dos lancamentos de faturas da telesc.
               Rodara na primeira sexta-feira apos o processo mensal.

   Alteracoes: 10/01/2000 - Padronizar mensagens (Deborah).

               15/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               09/12/2013 - Alterado indice leitura craplot (Daniel)

............................................................................. */

{ includes/var_batch.i "NEW" }

DEF        VAR aux_dtlimite AS DATE                                  NO-UNDO.

DEF        VAR aux_flgdelet AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR aux_flgfinal AS LOGICAL                               NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.

DEF        VAR aux_qtlftdel AS INT                                          .
DEF        VAR aux_qtlotdel AS INT                                          .

glb_cdprogra = "crps166".

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

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 176.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                            " - " + glb_cdprogra + "' --> '" + glb_dscritic +
                            " >> log/proc_batch.log").
         QUIT.
     END.
ELSE
     IF   craptab.dstextab = "1"   THEN
          DO:
              glb_cdcritic = 177.
              RUN fontes/critic.p.
              UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                                 " - " + glb_cdprogra + "' --> '" +
                                 glb_dscritic + " >> log/proc_batch.log").
              QUIT.
          END.

/*  Monta data limite para efetuar a limpeza  */

ASSIGN aux_dtlimite = glb_dtmvtolt - DAY(glb_dtmvtolt)
       aux_dtlimite = aux_dtlimite - DAY(aux_dtlimite)
       aux_dtlimite = aux_dtlimite - DAY(aux_dtlimite)
       aux_dtlimite = aux_dtlimite - DAY(aux_dtlimite)
       aux_dtlimite = aux_dtlimite + 1.

/*  Le os lotes a serem excluidos  */

FIND FIRST craplot WHERE craplot.cdcooper = glb_cdcooper    AND
                         craplot.dtmvtopg < aux_dtlimite    AND
                         craplot.tplotmov = 13              
                         USE-INDEX craplot2 NO-ERROR.

IF   AVAILABLE craplot   THEN

     DO WHILE TRUE:

        FIND FIRST craplft WHERE craplft.cdcooper = glb_cdcooper        AND
                                 craplft.dtmvtolt = craplot.dtmvtolt    AND
                                 craplft.cdagenci = craplot.cdagenci    AND
                                 craplft.cdbccxlt = craplot.cdbccxlt    AND
                                 craplft.nrdolote = craplot.nrdolote
                                 USE-INDEX craplft2 NO-ERROR.

        IF   AVAILABLE craplft   THEN
             DO:
                 REPEAT TRANSACTION ON ERROR UNDO, RETRY:

                   DO aux_contador = 1 TO 50:

                      IF   craplft.insitfat = 2 THEN
                           DO:
                               DELETE craplft.
                               aux_qtlftdel = aux_qtlftdel + 1.
                           END.
                      ELSE
                           aux_flgdelet = FALSE.

                      FIND NEXT craplft WHERE
                                craplft.cdcooper = glb_cdcooper      AND
                                craplft.dtmvtolt = craplot.dtmvtolt  AND
                                craplft.cdagenci = craplot.cdagenci  AND
                                craplft.cdbccxlt = craplot.cdbccxlt  AND
                                craplft.nrdolote = craplot.nrdolote
                                USE-INDEX craplft2 NO-ERROR.

                      IF   NOT AVAILABLE craplft   THEN
                           DO:
                               aux_flgfinal = TRUE.
                               LEAVE.
                           END.
                   END.

                   IF   aux_flgfinal   THEN
                        DO:
                            aux_flgfinal = FALSE.
                            LEAVE.
                        END.

                 END.
             END.

        IF   aux_flgdelet   THEN
             DO  TRANSACTION ON ERROR UNDO, RETRY:

                 DELETE craplot.
                 ASSIGN aux_qtlotdel = aux_qtlotdel + 1.

             END.  /*  Fim da transacao  */
        ELSE
             aux_flgdelet = TRUE.

        FIND NEXT craplot WHERE craplot.cdcooper = glb_cdcooper  AND
                                craplot.dtmvtopg < aux_dtlimite  AND
                                craplot.tplotmov = 13            
                                USE-INDEX craplot2 NO-ERROR.

        IF   NOT AVAILABLE craplot   THEN
             LEAVE.

     END.  /*  Fim do DO WHILE TRUE  */

/*  Imprime no log do processo os totais das exclusoes   */

glb_cdcritic = 661.
RUN fontes/critic.p.

UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                   glb_cdprogra + "' --> '" + glb_dscritic + " LFT = " +
                   STRING(aux_qtlftdel,"z,zzz,zz9") + " >> log/proc_batch.log").

UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                   glb_cdprogra + "' --> '" + glb_dscritic + " LOT = " +
                   STRING(aux_qtlotdel,"z,zzz,zz9") + " >> log/proc_batch.log").

RUN fontes/fimprg.p.

/* .......................................................................... */

