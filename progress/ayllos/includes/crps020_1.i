/* ..........................................................................

   Programa: Includes/crps020_1.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/92.                       Ultima atualizacao: 06/12/2011
   
   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 013.
               Rotina de exclusao dos lancamentos do tipo de lote 1.

   Alteracoes: 16/08/1999 - Tratar incheque = 6 (Deborah).
   
               19/07/2000 - Somente acessar chs se indicador = 12 (Odair)

               15/07/2003 - Substituido o Nro de conta fixo do Banco do Brasil,
                            pela variavel aux_lsconta3, setada no 
                            CRPS020.p (Julio).

               09/12/2005 - Cheque salario nao existe mais (Magui).
               
               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               05/04/2010 - Alteracao Historico (Gati)
               
               06/12/2011 - Sustagco provissria (Andri R./Supero).             
............................................................................. */
glb_cdcritic = 0.

FIND FIRST craplcm WHERE craplcm.cdcooper = glb_cdcooper       AND
                         craplcm.dtmvtolt = craplot.dtmvtolt   AND
                         craplcm.cdagenci = craplot.cdagenci   AND
                         craplcm.cdbccxlt = craplot.cdbccxlt   AND
                         craplcm.nrdolote = craplot.nrdolote
                         USE-INDEX craplcm3 NO-ERROR.

IF   AVAILABLE craplcm   THEN
     REPEAT TRANSACTION ON ERROR UNDO, RETRY:
     FIND FIRST tt-hist NO-LOCK
          WHERE tt-hist.codigo = craplcm.cdhistor NO-ERROR.
     IF AVAIL tt-hist THEN DO:                                                                      

        DO aux_contador = 1 TO 50:
           IF tt-hist.aux_inhistor = 3 OR tt-hist.aux_inhistor = 4 OR tt-hist.aux_inhistor = 5 THEN DO:
               FIND crapdpb WHERE crapdpb.cdcooper = glb_cdcooper     AND
                                  crapdpb.dtmvtolt = craplcm.dtmvtolt AND
                                  crapdpb.cdagenci = craplcm.cdagenci AND
                                  crapdpb.cdbccxlt = craplcm.cdbccxlt AND
                                  crapdpb.nrdolote = craplcm.nrdolote AND
                                  crapdpb.nrdconta = craplcm.nrdconta AND
                                  crapdpb.nrdocmto = craplcm.nrdocmto
                                  EXCLUSIVE-LOCK
                                  USE-INDEX crapdpb1 NO-ERROR.

               IF   NOT AVAILABLE crapdpb   THEN
                    DO:
                        glb_cdcritic = 82.
                        RUN fontes/critic.p.
                        UNIX SILENT VALUE("echo " +
                                          STRING(TIME,"HH:MM:SS") + " - " +
                                          glb_cdprogra + "' --> '" +
                                          glb_dscritic + " Conta = " +
                                          STRING(craplcm.nrdconta) +
                                          " >> log/proc_batch.log").
                        aux_flgdelet = FALSE.
                    END.
               ELSE
                    DO:
                        IF   crapdpb.dtliblan > glb_dtmvtolt   THEN
                             aux_flgdelet = FALSE.
                        ELSE
                             DO:
                                 DELETE crapdpb.
                                 aux_qtdpbdel = aux_qtdpbdel + 1.
                                 DELETE craplcm.
                                 aux_qtlcmdel = aux_qtlcmdel + 1.
                             END.
                    END.
           END.
           ELSE
           IF   CAN-DO(aux_lsconta3,STRING(craplcm.nrdctabb))       AND
                tt-hist.aux_inhistor = 12  THEN
                DO:
                    /*** Magui desativado em 09/12/2005
                    FIND crapchs WHERE crapchs.cdcooper = glb_cdcooper     AND
                                       crapchs.nrdctabb = craplcm.nrdctabb AND
                                       crapchs.nrdocmto = craplcm.nrdocmto
                                       EXCLUSIVE-LOCK
                                       USE-INDEX crapchs1 NO-ERROR.

                    IF   NOT AVAILABLE crapchs   THEN
                         glb_cdcritic = 241.
                    ELSE
                    IF   CAN-DO("0,1,2",STRING(crapchs.incheque)) THEN
                         glb_cdcritic = 240.
                    ELSE
                    IF   crapchs.incheque = 5   THEN
                         DO:
                             DELETE crapchs.
                             aux_qtchsdel = aux_qtchsdel + 1.
                         END.
                    ELSE
                    IF   crapchs.incheque = 7   OR
                         crapchs.incheque = 6   THEN
                         DO:
                             FIND crapcor WHERE
                                  crapcor.cdcooper     =  glb_cdcooper     AND
                                  crapcor.nrdconta     =  craplcm.nrdconta AND
                                  crapcor.nrdctabb     =  craplcm.nrdctabb AND
                                  DEC(crapcor.nrcheque)=  craplcm.nrdocmto AND
                                  crapcor.flgativo     =  TRUE
                                  EXCLUSIVE-LOCK
                                  USE-INDEX crapcor1 NO-ERROR.

                             IF   NOT AVAILABLE crapcor   THEN
                                  glb_cdcritic = 179.
                             ELSE
                                  DO:
                                      DELETE crapcor.
                                      DELETE crapchs.
                                      aux_qtchsdel = aux_qtchsdel + 1.
                                  END.
                         END.
                    IF   glb_cdcritic > 0   THEN
                         DO:
                             RUN fontes/critic.p.
                             UNIX SILENT VALUE("echo " +
                                               STRING(TIME,"HH:MM:SS") + " - " +
                                               glb_cdprogra + "' --> '" +
                                               glb_dscritic + " Conta = " +
                                               STRING(craplcm.nrdconta) +
                                               " >> log/proc_batch.log").
                             aux_flgdelet = FALSE.
                         END.
                    ELSE
                         DO:
                    ***********************************/     
                    FIND crapavu WHERE
                         crapavu.cdcooper = glb_cdcooper        AND
                         crapavu.nrdctabb = craplcm.nrdctabb    AND
                 DECIMAL(crapavu.nrtalchq) = craplcm.nrdocmto
                         EXCLUSIVE-LOCK
                         USE-INDEX crapavu1 NO-ERROR.

                    IF   AVAILABLE crapavu   THEN
                         DO:
                             DELETE crapavu.
                             aux_qtavudel = aux_qtavudel + 1.
                         END.

                    DELETE craplcm.
                    aux_qtlcmdel = aux_qtlcmdel + 1.
                END.
           ELSE
                DO:
                    DELETE craplcm.
                    aux_qtlcmdel = aux_qtlcmdel + 1.
                END.

           glb_cdcritic = 0.

           FIND NEXT craplcm WHERE craplcm.cdcooper = glb_cdcooper      AND
                                   craplcm.dtmvtolt = craplot.dtmvtolt  AND
                                   craplcm.cdagenci = craplot.cdagenci  AND
                                   craplcm.cdbccxlt = craplot.cdbccxlt  AND
                                   craplcm.nrdolote = craplot.nrdolote
                                   USE-INDEX craplcm3 NO-ERROR.

           IF   NOT AVAILABLE craplcm   THEN
                DO:
                    aux_flgfinal = TRUE.
                    LEAVE.
                END.

        END.  /*  Fim do DO .. TO  */
     END.
     IF   aux_flgfinal   THEN
          DO:
              aux_flgfinal = FALSE.
              LEAVE.
          END.

END.  /*  Fim do REPEAT e da transacao  */

/* .......................................................................... */


