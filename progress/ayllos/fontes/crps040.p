/* ..........................................................................

   Programa: Fontes/crps040.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/92.                         Ultima atualizacao: 08/03/2010

   Dados referentes ao programa:

   Frequencia: Anual (Batch - Background).
   Objetivo  : Atende a solicitacao 025.
               Fazer limpeza anual dos lancamentos de capital ja microfilmados.
               Rodara na primeira sexta-feira apos o processo mensal de MARCO.

   Alteracoes: 26/09/2005 - Alterado para nao eliminar mais os lancamentos
                            (Edson).

               14/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
               
               09/06/2008 - Incluída a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "for each" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               08/03/2010 - Alteracao Historico (Gati)
............................................................................. */

{ includes/var_batch.i "NEW" }


DEF        VAR aux_dtlimite AS DATE                                  NO-UNDO.

DEF        VAR aux_flgdelet AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR aux_flgfinal AS LOGICAL                               NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.

DEF        VAR aux_qtlctdel AS INT                                          .
DEF        VAR aux_qtlotdel AS INT                                          .
DEF        VAR aux_qtlpldel AS INT                                          .

DEFINE TEMP-TABLE tt-hist
    FIELD codigo       AS INTEGER
    FIELD aux_inhistor AS INTEGER.

glb_cdprogra = "crps040".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     QUIT.

/*  Verifica se deve executar  */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND 
                   craptab.nmsistem = "CRED"       AND
                   craptab.tptabela = "GENERI"     AND
                   craptab.cdempres = 00           AND
                   craptab.cdacesso = "EXELIMPCOT" AND
                   craptab.tpregist = 002
                   NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 178.
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

/*  Carrega tabela de indicadores de historicos  */
EMPTY TEMP-TABLE tt-hist.
FOR EACH craphis WHERE craphis.cdcooper = glb_cdcooper            AND
                       CAN-DO("0,2,3,8",STRING(craphis.tplotmov)) NO-LOCK:

    CREATE tt-hist.
    ASSIGN tt-hist.codigo       = craphis.cdhistor
           tt-hist.aux_inhistor = craphis.inhistor.


    
END.

/*  Monta data limite para efetuar a limpeza  */

/*  aux_dtlimite = DATE(01,01,YEAR(glb_dtmvtolt)).  */

aux_dtlimite = DATE(01,01,01).      /*  Edson - 26/09/2005  */

/*  Le os lotes a serem excluidos  */

FIND FIRST craplot WHERE craplot.cdcooper = glb_cdcooper            AND
                         CAN-DO("2,3,8",STRING(craplot.tplotmov))   AND
                         craplot.dtmvtolt < aux_dtlimite
                         USE-INDEX craplot1 NO-ERROR.

IF   AVAILABLE craplot   THEN
     DO WHILE TRUE:

        IF   CAN-DO("2,3",STRING(craplot.tplotmov))   THEN
             DO:
                 FIND FIRST craplct WHERE
                            craplct.cdcooper = glb_cdcooper       AND
                            craplct.dtmvtolt = craplot.dtmvtolt   AND
                            craplct.cdagenci = craplot.cdagenci   AND
                            craplct.cdbccxlt = craplot.cdbccxlt   AND
                            craplct.nrdolote = craplot.nrdolote
                            USE-INDEX craplct3 NO-ERROR.

                 IF   AVAILABLE craplct   THEN
                      REPEAT TRANSACTION ON ERROR UNDO, RETRY:

                         DO  aux_contador = 1 TO 50:

                             DELETE craplct.
                             aux_qtlctdel = aux_qtlctdel + 1.

                             FIND NEXT craplct WHERE
                                       craplct.cdcooper = glb_cdcooper       AND
                                       craplct.dtmvtolt = craplot.dtmvtolt   AND
                                       craplct.cdagenci = craplot.cdagenci   AND
                                       craplct.cdbccxlt = craplot.cdbccxlt   AND
                                       craplct.nrdolote = craplot.nrdolote
                                       USE-INDEX craplct3 NO-ERROR.

                             IF   NOT AVAILABLE craplct   THEN
                                  DO:
                                      aux_flgfinal = TRUE.
                                      LEAVE.
                                  END.

                         END.  /*  Fim do DO .. TO  */

                         IF   aux_flgfinal   THEN
                              DO:
                                  aux_flgfinal = FALSE.
                                  LEAVE.
                              END.

                      END.  /*  Fim do REPEAT TRANSACTION  */
             END.
        ELSE                /*  Lotes de planos  */
             DO:
                 FIND FIRST craplpl WHERE
                            craplpl.cdcooper = glb_cdcooper       AND
                            craplpl.dtmvtolt = craplot.dtmvtolt   AND
                            craplpl.cdagenci = craplot.cdagenci   AND
                            craplpl.cdbccxlt = craplot.cdbccxlt   AND
                            craplpl.nrdolote = craplot.nrdolote
                            USE-INDEX craplpl2 NO-ERROR.

                 IF   AVAILABLE craplpl   THEN
                      REPEAT TRANSACTION ON ERROR UNDO, RETRY:

                         DO  aux_contador = 1 TO 50:

                             DELETE craplpl.
                             aux_qtlpldel = aux_qtlpldel + 1.

                             FIND NEXT craplpl WHERE
                                       craplpl.cdcooper = glb_cdcooper       AND
                                       craplpl.dtmvtolt = craplot.dtmvtolt   AND
                                       craplpl.cdagenci = craplot.cdagenci   AND
                                       craplpl.cdbccxlt = craplot.cdbccxlt   AND
                                       craplpl.nrdolote = craplot.nrdolote
                                       USE-INDEX craplpl2 NO-ERROR.

                             IF   NOT AVAILABLE craplpl   THEN
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

                      END.  /*  Fim do REPEAT TRANSACTION  */
             END.

        IF   aux_flgdelet   THEN
             DO TRANSACTION ON ERROR UNDO, RETRY:

                 DELETE craplot.
                 ASSIGN aux_qtlotdel = aux_qtlotdel + 1.

             END.  /*  Fim do DO TRANSACTION  */
        ELSE
             aux_flgdelet = TRUE.

        FIND NEXT craplot WHERE craplot.cdcooper = glb_cdcooper            AND
                                CAN-DO("2,3,8",STRING(craplot.tplotmov))   AND
                                craplot.dtmvtolt < aux_dtlimite
                                USE-INDEX craplot1 NO-ERROR.

        IF   NOT AVAILABLE craplot   THEN
             LEAVE.

     END.  /*  Fim do DO WHILE TRUE  */

/*  Imprime no log do processo os totais das exclusoes   */

UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                   glb_cdprogra + "' --> Deletados no LCT = '" +
                   STRING(aux_qtlctdel,"z,zzz,zz9") + " >> log/proc_batch.log").

UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                   glb_cdprogra + "' --> Deletados no LPL = '" +
                   STRING(aux_qtlpldel,"z,zzz,zz9") + " >> log/proc_batch.log").

UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                   glb_cdprogra + "' --> Deletados no LOT = '" +
                   STRING(aux_qtlotdel,"z,zzz,zz9") + " >> log/proc_batch.log").

RUN fontes/fimprg.p.

/* .......................................................................... */


