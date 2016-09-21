/* ..........................................................................

   Programa: Fontes/crps023.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Abril/92.                           Ultima atualizacao: 18/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 015.
               Processar o reajuste dos limites de credito.
               Emite relatorio 24.

   Alteracoes: 13/07/94 - Alterado para arredondar somente os centavos (Edson).

               22/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               09/11/98 - Tratar situacao em prejuizo (Deborah). 

               05/10/1999 - Aumentado o numero de casas decimais na taxa
                            (Edson).

               30/10/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner)

               30/07/2002 - Incluir nova situacao da conta (Margarete).

               28/06/2005 - Alimenatdo campo cdcooper das tabelas craplot e 
                            craplli (Diego).
                            
               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               30/11/2010 - 001 / Alterado Format "x(40)" para Format "x(50)" 
                            (Danielle/Kbase)
                            
               14/01/2014 - Inclusao de VALIDATE craplot e craplli (Carlos)
               
               18/06/2014 - Exclusao do uso da tabela craplli.
                            (Tiago Castro - Tiago RKAM)
............................................................................. */

DEF BUFFER crabtab FOR craptab.

DEF STREAM str_1.  /*  Para relatorio do reajuste dos limites de credito  */
DEF STREAM str_2.  /*  Para arquivo auxiliar - limites nao reajustados  */

{ includes/var_batch.i }

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "]      NO-UNDO.

DEF        VAR rel_inreajus AS DECIMAL DECIMALS 6                    NO-UNDO.

DEF        VAR tot_vllimcre AS DECIMAL                               NO-UNDO.
DEF        VAR tot_qtassoci AS INT                                   NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR    FORMAT "x(20)" EXTENT 99      NO-UNDO.
DEF        VAR aux_nrdevias AS INT     FORMAT "z9"    EXTENT 99      NO-UNDO.

DEF        VAR aux_nrdconta AS INT     FORMAT "99999999"             NO-UNDO.

DEF        VAR aux_inreajus AS DECIMAL DECIMALS 6                    NO-UNDO.

DEF        VAR aux_vllimcre AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlarrend AS DECIMAL                               NO-UNDO.

DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgclote AS LOGICAL                               NO-UNDO.

DEF        VAR aux_dtrefere AS DATE                                  NO-UNDO.
DEF        VAR aux_dtmvtolt AS DATE                                  NO-UNDO.

DEF        VAR aux_contaarq AS INT                                   NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT     INIT 100                      NO-UNDO.
DEF        VAR aux_nrdolote AS INT                                   NO-UNDO.
DEF        VAR aux_nrseqdig AS INT                                   NO-UNDO.

glb_cdprogra = "crps023".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

FORM "CONTAS REAJUSTADAS (LIMITE SOBRE O CAPITAL):" AT 1
     SKIP(1)
     WITH NO-BOX WIDTH 132 FRAME f_reajustados.

FORM "CONTAS NAO REAJUSTADAS (LIMITE SOBRE O SALDO MEDIO):" AT 1
     SKIP(1)
     WITH NO-BOX WIDTH 132 FRAME f_nreajustados.

FORM crapass.nrdconta AT  9 FORMAT "zzzz,zzz,9"         LABEL "CONTA/DV"
     crapass.nmprimtl AT 25 FORMAT "x(50)"              LABEL "TITULAR" /*001*/
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS DOWN WIDTH 142 FRAME f_reajuste.

FORM crapass.nrdconta AT  9 FORMAT "zzzz,zzz,9"         LABEL "CONTA/DV"
     crapass.nmprimtl AT 25 FORMAT "x(50)"              LABEL "TITULAR" /*001*/
     crapass.vllimcre AT 79 FORMAT "zzz,zzz,zzz,zz9.99" LABEL "LIM. DE CREDITO"
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS DOWN WIDTH 142 FRAME f_nreajuste.

FORM "TOTAIS ==>"     AT   1
     rel_inreajus     AT  13 FORMAT "zz9.999999"          LABEL "% APL."
     craplot.qtcompln AT  25 FORMAT "zzz,zz9"             LABEL "ASSOCIADOS"
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 142 FRAME f_totais.

FORM "TOTAIS ==>"     AT   1
     tot_qtassoci     AT  25 FORMAT "zzz,zz9"            LABEL "ASSOCIADOS"
     tot_vllimcre     AT  79 FORMAT "zzz,zzz,zzz,zz9.99" LABEL "LIM. DE CREDITO"
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 142 FRAME f_totais_2.

{ includes/cabrel132_1.i }               /* Monta cabecalho do relatorio */

IF   glb_inrestar > 0   AND   glb_nrctares = 0   THEN
     glb_inrestar = 0.

/*  Le numero de lote a ser usado na integracao  */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "GENERI"      AND
                   craptab.cdempres = 0             AND
                   craptab.cdacesso = "NUMLOTELIM"  AND
                   craptab.tpregist = 1             USE-INDEX craptab1 NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 175.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                            " - " + glb_cdprogra + "' --> '" +
                            glb_dscritic + " >> log/proc_batch.log").
         RETURN.
     END.
ELSE
     aux_nrdolote = INTEGER(craptab.dstextab).

/*  Le taxa do reajuste dos limites de credito  */

FIND crabtab WHERE crabtab.cdcooper = glb_cdcooper  AND
                   crabtab.nmsistem = "CRED"        AND
                   crabtab.tptabela = "USUARI"      AND
                   crabtab.cdempres = 11            AND
                   crabtab.cdacesso = "REAJLIMITE"  AND
                   crabtab.tpregist = 1             NO-ERROR.

IF   NOT AVAILABLE crabtab   THEN
     DO:
         glb_cdcritic = 347.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                            " - " + glb_cdprogra + "' --> '" +
                            glb_dscritic + " REAJUSTE DOS LIMITES DE CREDITO" +
                            " >> log/proc_batch.log").
         RETURN.
     END.

ASSIGN aux_inreajus = 1 + (DECIMAL(SUBSTRING(crabtab.dstextab,1,10)) / 100)
       rel_inreajus = DECIMAL(SUBSTRING(crabtab.dstextab,1,10)).

IF   aux_inreajus = 1   THEN
     DO:
         glb_infimsol = TRUE.
         RUN fontes/fimprg.p.
         RETURN.
     END.

IF   glb_inrestar = 0   THEN
     OUTPUT STREAM str_2 TO arq/crps023.dat.
ELSE
     OUTPUT STREAM str_2 TO arq/crps023.dat APPEND.

ASSIGN aux_flgfirst = TRUE
       aux_flgclote = IF glb_inrestar = 0
                         THEN TRUE
                         ELSE FALSE

       aux_dtmvtolt = glb_dtmvtolt
       aux_contaarq = aux_contaarq + 1
       aux_nmarqimp[aux_contaarq] = "rl/crrl024.lst"
       aux_nrdevias[aux_contaarq] = glb_nrdevias.

TRANS_1:

FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper                  AND
                       crapass.nrdconta > glb_nrctares                  AND
                       crapass.vllimcre > 0                             AND
                      (crapass.cdsitdct = 1                             OR 
                       crapass.cdsitdct = 6)                            AND
                   NOT CAN-DO("2,4,5,6,7,8",STRING(crapass.cdsitdtl))
                       TRANSACTION ON ERROR UNDO TRANS_1, RETRY:

    IF   crapass.tplimcre = 2   THEN
         PUT STREAM str_2 crapass.nrdconta FORMAT "99999999" SKIP.
    ELSE
         DO:
             ASSIGN aux_vllimcre = ROUND(crapass.vllimcre * aux_inreajus,0).

             /*  ------  FORA DE USO DESDE A IMPLANTACAO DO REAL  -----------

                    aux_vlarrend = DECIMAL(SUBSTRING(STRING(aux_vllimcre,
                                                 "999999999.99"),7,6)).

             IF   aux_vlarrend < 500   THEN   /*  Efetua os arredondamentos  */
                  aux_vllimcre = aux_vllimcre - aux_vlarrend.
             ELSE
                  IF   aux_vlarrend > 599   THEN
                       aux_vllimcre = aux_vllimcre + 1000 - aux_vlarrend.
                  ELSE
                       aux_vllimcre = aux_vllimcre - DECIMAL(SUBSTRING(STRING(
                           aux_vllimcre,"999999999.99"),8,5)).

             ---------------------------------------------------------------  */

             IF   aux_flgclote   THEN
                  DO:
                      aux_nrdolote = aux_nrdolote + 1.

                      IF   CAN-FIND(craplot WHERE
                                    craplot.cdcooper = glb_cdcooper  AND
                                    craplot.dtmvtolt = aux_dtmvtolt  AND
                                    craplot.cdagenci = aux_cdagenci  AND
                                    craplot.cdbccxlt = aux_cdbccxlt  AND
                                    craplot.nrdolote = aux_nrdolote
                                    USE-INDEX craplot1)              THEN
                           DO:
                               glb_cdcritic = 59.
                               RUN fontes/critic.p.
                               UNIX SILENT VALUE("echo " +
                                                 STRING(TIME,"HH:MM:SS") +
                                                 " - " + glb_cdprogra +
                                                 "' --> '" +
                                                 glb_dscritic + " LOTE = " +
                                               STRING(aux_nrdolote,"999,999") +
                                                 " >> log/proc_batch.log").
                               RETURN.
                           END.
                  END.
             ELSE
                  DO:
                      FIND craplot WHERE craplot.cdcooper = glb_cdcooper    AND
                                         craplot.dtmvtolt = aux_dtmvtolt    AND
                                         craplot.cdagenci = aux_cdagenci    AND
                                         craplot.cdbccxlt = aux_cdbccxlt    AND
                                         craplot.nrdolote = aux_nrdolote
                                         USE-INDEX craplot1 NO-ERROR.

                      IF   NOT AVAILABLE craplot   THEN
                           DO:
                               glb_cdcritic = 60.
                               RUN fontes/critic.p.
                               UNIX SILENT VALUE("echo " +
                                                 STRING(TIME,"HH:MM:SS") +
                                                 " - " + glb_cdprogra +
                                                 "' --> '" + glb_dscritic +
                                                 " LOTE = " +
                                               STRING(aux_nrdolote,"999,999") +
                                                 " >> log/proc_batch.log").
                               RETURN.
                           END.
                  END.

             aux_nrseqdig = craplot.nrseqdig.
             
             ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
                    craplot.qtcompln = craplot.qtcompln + 1
                    craplot.vlinfocr = craplot.vlinfocr + aux_vllimcre
                    craplot.vlcompcr = craplot.vlcompcr + aux_vllimcre
                    craplot.nrseqdig = aux_nrseqdig + 1                    
                    crapass.vllimcre = aux_vllimcre.             
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

         END.   /*  Fim do DO WHILE TRUE  */

         crapres.nrdconta = crapass.nrdconta.

END.   /*  Fim do FOR EACH e da transacao  --  TRANS  */

OUTPUT STREAM str_2 CLOSE.

/*  Geracao do relatorio de limites reajustados  */

FIND craplot WHERE craplot.cdcooper = glb_cdcooper  AND
                   craplot.dtmvtolt = aux_dtmvtolt  AND
                   craplot.cdagenci = aux_cdagenci  AND
                   craplot.cdbccxlt = aux_cdbccxlt  AND
                   craplot.nrdolote = aux_nrdolote
                   USE-INDEX craplot1 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craplot   THEN
     DO:
         glb_cdcritic = 60.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                            " - " + glb_cdprogra + "' --> '" +
                            glb_dscritic + " LOTE = " +
                            STRING(aux_nrdolote,"9,999") +
                            " >> log/proc_batch.log").
         RETURN.
     END.

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp[aux_contaarq]) PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel132_1.

VIEW STREAM str_1 FRAME f_reajustados.

IF   LINE-COUNTER(str_1) > 82   THEN
     DO:
         PAGE STREAM str_1.
         VIEW STREAM str_1 FRAME f_reajustados.
     END.
ELSE
     DISPLAY STREAM str_1 SKIP WITH FRAME f_linha.

DISPLAY STREAM str_1
        rel_inreajus  craplot.qtcompln  
        WITH FRAME f_totais.

PAGE STREAM str_1.
VIEW STREAM str_1 FRAME f_nreajustados.

/*  Lista limites nao reajustados  */

INPUT STREAM str_2 FROM arq/crps023.dat NO-ECHO.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_2 aux_nrdconta.

   FIND crapass WHERE crapass.cdcooper = glb_cdcooper   AND
                      crapass.nrdconta = aux_nrdconta   NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapass   THEN
        DO:
            glb_cdcritic = 9.
            RUN fontes/critic.p.
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                              glb_cdprogra + "' --> '" + glb_dscritic +
                              " CONTA = " + STRING(aux_nrdconta) +
                              " >> log/proc_batch.log").
            RETURN.
        END.

   ASSIGN tot_vllimcre = tot_vllimcre + crapass.vllimcre
          tot_qtassoci = tot_qtassoci + 1.

   DISPLAY STREAM str_1
           crapass.nrdconta  crapass.nmprimtl  crapass.vllimcre
           WITH FRAME f_nreajuste.

   DOWN STREAM str_1 WITH FRAME f_nreajuste.

   IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
        DO:
            PAGE STREAM str_1.
            VIEW STREAM str_1 FRAME f_nreajustados.
        END.

END.  /*  Fim do DO WHILE TRUE  */

IF   LINE-COUNTER(str_1) > 82   THEN
     DO:
         PAGE STREAM str_1.
         VIEW STREAM str_1 FRAME f_nreajustados.
     END.
ELSE
     DISPLAY STREAM str_1 SKIP WITH FRAME f_linha.

DISPLAY STREAM str_1 tot_qtassoci  tot_vllimcre WITH FRAME f_totais_2.

OUTPUT STREAM str_1 CLOSE.
INPUT  STREAM str_2 CLOSE.

ASSIGN glb_nrcopias = 1
       glb_nmformul = IF aux_nrdevias[aux_contaarq] > 1
                         THEN STRING(aux_nrdevias[aux_contaarq]) + "vias"
                         ELSE " "
       glb_nmarqimp = aux_nmarqimp[aux_contaarq].

RUN fontes/imprim.p.

/*  Fim da geracao do relatorio  */

/*  Zera a taxa do reajuste dos limites de credito  */

TRANS_1:

DO TRANSACTION ON ERROR UNDO TRANS_1, RETRY:

   crabtab.dstextab = "000,00".

END.  /*  Fim da transacao  --  TRANS_1  */

glb_infimsol = TRUE.

RUN fontes/fimprg.p.

UNIX SILENT rm arq/crps023.dat 2> /dev/null.

/* .......................................................................... */



