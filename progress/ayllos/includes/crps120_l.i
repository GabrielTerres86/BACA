/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | includes/crps120_l.i            | Incorporado ao pc_crps120         |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/











/* ..........................................................................

   Programa: Includes/crps120_l.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Maio/95.                            Ultima atualizacao: 05/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Leitura e criacao dos lotes utilizados.

   Alteracao : 24/02/97 - Quando criado crps120_3.p criada a variavel
                          aux_cdempres (Odair).

             06/07/2005 - Alimentado campo cdcooper da tabela craplot (Diego).
             
             16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
             
             01/09/2008 - Alteracao cdempres (Kbase IT).
             
             16/06/2009 - Efetuado acerto na atualizacao do campo
                          craptab.dstextab - NUMLOTEFOL, NUMLOTECOT, NUMLOTEEMP
                          (Diego).
             
             05/12/2013 - Alteracao referente a integracao Progress X 
                          Dataserver Oracle 
                          Inclusao do VALIDATE ( André Euzébio / SUPERO)   
............................................................................. */

DO WHILE TRUE:           /*  Lote do Credito Folha/Debito  */

   FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "GENERI"       AND
                      craptab.cdempres = 0              AND
                      craptab.cdacesso = "NUMLOTEFOL"   AND
                      craptab.tpregist = aux_cdempsol
                      USE-INDEX craptab1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

   IF   NOT AVAILABLE craptab   THEN
        IF   LOCKED craptab   THEN
             DO:
                 PAUSE 2 NO-MESSAGE.
                 NEXT.
             END.
        ELSE
             DO:
                 glb_cdcritic = 175.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                   glb_cdprogra + "' --> '" + glb_dscritic +
                                   " EMPRESA = " +
                                   STRING(aux_cdempsol,"99999") +
                                   " >> log/proc_batch.log").
                 UNDO TRANS_1, RETURN.
             END.
   ELSE
        aux_nrlotfol = INTEGER(craptab.dstextab).

   IF   aux_flgclote   THEN
        DO:
            aux_nrlotfol = aux_nrlotfol + 1.

            IF   CAN-FIND(craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                                        craplot.dtmvtolt = aux_dtintegr   AND
                                        craplot.cdagenci = aux_cdagenci   AND
                                        craplot.cdbccxlt = aux_cdbccxlt   AND
                                        craplot.nrdolote = aux_nrlotfol
                                        USE-INDEX craplot1)   THEN
                 DO:
                     glb_cdcritic = 59.
                     RUN fontes/critic.p.
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '" +
                                       glb_dscritic + " EMPRESA = " +
                                       STRING(aux_cdempsol,"99999") +
                                       " LOTE = " +
                                       STRING(aux_nrlotfol,"9,99999") +
                                       " >> log/proc_batch.log").
                     UNDO TRANS_1, RETURN.
                 END.

            CREATE craplot.
            ASSIGN craplot.dtmvtolt = aux_dtintegr
                   craplot.cdagenci = aux_cdagenci
                   craplot.cdbccxlt = aux_cdbccxlt
                   craplot.nrdolote = aux_nrlotfol
                   craplot.tplotmov = 1
                   craplot.cdcooper = glb_cdcooper
                   craptab.dstextab = "9" + STRING(INT(SUBSTR(
                                                   STRING(aux_nrlotfol),2)),
                                                   "99999").
            VALIDATE craplot.
        END.

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

DO WHILE TRUE:               /*  Lote do Credito de COTAS  */

   FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "GENERI"       AND
                      craptab.cdempres = 0              AND
                      craptab.cdacesso = "NUMLOTECOT"   AND
                      craptab.tpregist = aux_cdempsol
                      USE-INDEX craptab1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

   IF   NOT AVAILABLE craptab   THEN
        IF   LOCKED craptab   THEN
             DO:
                 PAUSE 2 NO-MESSAGE.
                 NEXT.
             END.
        ELSE
             DO:
                 glb_cdcritic = 175.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                   glb_cdprogra + "' --> '" + glb_dscritic +
                                   " EMPRESA = " +
                                   STRING(aux_cdempsol,"99999") +
                                   " >> log/proc_batch.log").
                 UNDO TRANS_1, RETURN.
             END.
   ELSE
        aux_nrlotcot = INTEGER(craptab.dstextab).

   IF   aux_flgclote   THEN
        DO:
            aux_nrlotcot = aux_nrlotcot + 1.

            IF   CAN-FIND(craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                                        craplot.dtmvtolt = aux_dtintegr   AND
                                        craplot.cdagenci = aux_cdagenci   AND
                                        craplot.cdbccxlt = aux_cdbccxlt   AND
                                        craplot.nrdolote = aux_nrlotcot
                                        USE-INDEX craplot1)   THEN
                 DO:
                     glb_cdcritic = 59.
                     RUN fontes/critic.p.
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '" +
                                       glb_dscritic + " EMPRESA = " +
                                       STRING(aux_cdempsol,"99999") +
                                       " LOTE = " +
                                       STRING(aux_nrlotcot,"9,99999") +
                                       " >> log/proc_batch.log").
                     UNDO TRANS_1, RETURN.
                 END.

            CREATE craplot.
            ASSIGN craplot.dtmvtolt = aux_dtintegr
                   craplot.cdagenci = aux_cdagenci
                   craplot.cdbccxlt = aux_cdbccxlt
                   craplot.nrdolote = aux_nrlotcot
                   craplot.tplotmov = 3
                   craplot.cdcooper = glb_cdcooper
                   craptab.dstextab = "8" + STRING(INT(SUBSTR(
                                                   STRING(aux_nrlotcot),2)),
                                                   "99999").
            VALIDATE craplot.
        END.

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

DO WHILE TRUE:         /*  Lote do Credito de EMPRESTIMOS  */

   FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "GENERI"       AND
                      craptab.cdempres = 0              AND
                      craptab.cdacesso = "NUMLOTEEMP"   AND
                      craptab.tpregist = aux_cdempsol
                      USE-INDEX craptab1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

   IF   NOT AVAILABLE craptab   THEN
        IF   LOCKED craptab   THEN
             DO:
                 PAUSE 2 NO-MESSAGE.
                 NEXT.
             END.
        ELSE
             DO:
                 glb_cdcritic = 175.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                   glb_cdprogra + "' --> '" + glb_dscritic +
                                   " EMPRESA = " +
                                   STRING(aux_cdempsol,"99999") +
                                   " >> log/proc_batch.log").
                 UNDO TRANS_1, RETURN.
             END.
   ELSE
        aux_nrlotemp = INTEGER(craptab.dstextab).

   IF   aux_flgclote   THEN
        DO:
            aux_nrlotemp = aux_nrlotemp + 1.

            IF   CAN-FIND(craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                                        craplot.dtmvtolt = aux_dtintegr   AND
                                        craplot.cdagenci = aux_cdagenci   AND
                                        craplot.cdbccxlt = aux_cdbccxlt   AND
                                        craplot.nrdolote = aux_nrlotemp
                                        USE-INDEX craplot1)   THEN
                 DO:
                     glb_cdcritic = 59.
                     RUN fontes/critic.p.
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '" +
                                       glb_dscritic + " EMPRESA = " +
                                       STRING(aux_cdempsol,"99999") +
                                       " LOTE = " +
                                       STRING(aux_nrlotemp,"9,99999") +
                                       " >> log/proc_batch.log").
                     UNDO TRANS_1, RETURN.
                 END.

            CREATE craplot.
            ASSIGN craplot.dtmvtolt = aux_dtintegr
                   craplot.cdagenci = aux_cdagenci
                   craplot.cdbccxlt = aux_cdbccxlt
                   craplot.nrdolote = aux_nrlotemp
                   craplot.tplotmov = 5
                   craplot.cdcooper = glb_cdcooper
                   craptab.dstextab = "5" + STRING(INT(SUBSTR(
                                                   STRING(aux_nrlotemp),2)),
                                                   "99999").
            VALIDATE craplot.
        END.

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

aux_flgclote = FALSE.

/* .......................................................................... */

