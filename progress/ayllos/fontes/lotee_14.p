/* ............................................................................
   
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ESTE PROGRAMA ESTA DESABILITADO POIS AS POUPANÇAS SAO CRIADAS AUTOMATICAMENTE
   PELA TELA ATENDA - NAO EXISTINDO MAIS A CRICAO DO LOTE DESTE TIPO, NAO EXISTE
   MAIS A EXCLUSAO.   28/04/2010 (Gabriel)
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   
   Programa: Fontes/lotee_14.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Marco/96.                         Ultima atualizacao: 28/04/2009

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao do tipo de lote 14.

   Alteracoes: 02/04/98 - Tratamento para milenio e troca para V8 (Margarete).

              30/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

              28/04/2009 - Quando deletado craprpp, deletar tambem o(s) crapspp
                           (Gabriel).
............................................................................. */

{ includes/var_online.i }

DEF INPUT PARAM par_cdagenci AS INTEGER                             NO-UNDO.
DEF INPUT PARAM par_cdbccxlt AS INTEGER                             NO-UNDO.
DEF INPUT PARAM par_nrdolote AS INTEGER                             NO-UNDO.


{ includes/var_lote.i }

DO WHILE TRUE:

   DO  aux_contador = 1 TO 20:

       FIND FIRST craprpp WHERE
                  craprpp.cdcooper = glb_cdcooper  AND
                  craprpp.dtmvtolt = glb_dtmvtolt  AND
                  craprpp.cdagenci = par_cdagenci  AND
                  craprpp.cdbccxlt = par_cdbccxlt  AND
                  craprpp.nrdolote = par_nrdolote
                  USE-INDEX craprpp3
                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE craprpp   THEN
            IF   LOCKED craprpp   THEN
                 DO:
                     ASSIGN glb_cdcritic = 85
                            par_situacao = FALSE.
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
            ELSE
                 DO:
                     par_situacao = TRUE.
                     LEAVE. /* Sai quando nao ha mais lancamentos */
                 END.

       ASSIGN par_qtexclln = par_qtexclln + 1
              par_vlexclcr = par_vlexclcr + craprpp.vlprerpp
              aux_contador = 0.

       DO WHILE TRUE:

           FIND crawrpp WHERE crawrpp.cdcooper = glb_cdcooper        AND
                              crawrpp.nrdconta = craprpp.nrdconta    AND
                              crawrpp.nrctrrpp = craprpp.nrctrrpp    AND
                              crawrpp.vlprerpp = craprpp.vlprerpp
                              USE-INDEX crawrpp1
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF   NOT AVAILABLE crawrpp THEN
                IF   LOCKED crawrpp   THEN
                     DO:
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                ELSE
                     glb_cdcritic = 484.

           LEAVE.

       END.  /* Fim do DO WHILE TRUE */

       IF   glb_cdcritic > 0 THEN
            LEAVE.

       IF   crawrpp.nrlotant = 0 THEN
            DO:
                FOR EACH crapspp WHERE crapspp.cdcooper = glb_cdcooper       AND
                                       crapspp.nrdconta = craprpp.nrdconta   AND
                                       crapspp.nrctrrpp = craprpp.nrctrrpp   
                                       EXCLUSIVE-LOCK:
                
                    DELETE crapspp.                   
                                       
                END.                       
                                                   
                DELETE craprpp.

            END.    
       ELSE
            ASSIGN craprpp.cdagenci = crawrpp.cdageant
                   craprpp.cdbccxlt = crawrpp.cdbccant
                   craprpp.dtmvtolt = crawrpp.dtlotant
                   craprpp.nrdolote = crawrpp.nrlotant
                   craprpp.nrseqdig = crawrpp.nrseqant
                   craprpp.vlprerpp = crawrpp.vlpreant.

       LEAVE.

   END.  /*  Fim do DO .. TO  */

   IF   par_situacao   THEN
        LEAVE.

   IF   aux_contador <> 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            LEAVE.
        END.

END.  /*  Fim do DO WHILE TRUE  */
