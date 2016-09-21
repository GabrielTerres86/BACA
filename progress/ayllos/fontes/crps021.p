/* ..........................................................................

   Programa: Fontes/crps021.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/92.                           Ultima atualizacao: 06/09/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 014
               Listar os associados que recebem os extratos na secao (23).

   Alteracoes: 30/07/96 - Alterado para listar a tabela de secoes por agencia
                          (Odair).

               29/04/97 - Alterar para listar agencias por solicitacao (Odair)

               22/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               02/02/2000 - Gerar pedido de impressao (Deborah).

               16/10/2000 - Alterar fone para 20 posicoes (Margarete/Planner)
               
               05/08/2002 - Incluir agencia na secao de extrato (Ze Eduardo).
               
               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               06/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
............................................................................. */

DEF STREAM str_1.     /*  Para listagem dos extratos na secao  */
DEF STREAM str_2.     /*  Para entrada/saida do arquivo temporario  */

{ includes/var_batch.i "NEW" }

DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "]      NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR    FORMAT "x(20)" EXTENT 99      NO-UNDO.
DEF        VAR aux_nrdevias AS INT     FORMAT "z9"    EXTENT 99      NO-UNDO.

DEF        VAR aux_cdsecext AS INT                                   NO-UNDO.
DEF        VAR aux_nrdconta AS INT                                   NO-UNDO.
DEF        VAR aux_nmprimtl AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmsecext AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmpesext AS CHAR                                  NO-UNDO.
DEF        VAR aux_dssecext AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrfonext AS CHAR                                  NO-UNDO.

DEF        VAR aux_flgexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_contaarq AS INT                                   NO-UNDO.
DEF        VAR aux_nrsecext AS INT                                   NO-UNDO.
DEF        VAR aux_qtextsec AS INT                                   NO-UNDO.
DEF        VAR aux_cdagenci AS INT                                   NO-UNDO.
DEF        VAR ant_cdagenci AS INT                                   NO-UNDO.

DEF        VAR tot_qtextsec AS INT                                   NO-UNDO.
DEF        VAR aux_cdagesol AS INT                                   NO-UNDO.

glb_cdprogra = "crps021".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

FORM "SECAO:"     AT  1
     aux_cdsecext AT  7 FORMAT "zz9"   NO-LABEL
     "-"          AT 10
     aux_nmsecext AT 11 FORMAT "x(20)" NO-LABEL
     "A/C:"       AT 32
     aux_nmpesext AT 37 FORMAT "x(19)" NO-LABEL
     "TEL."       AT 57
     aux_nrfonext AT 61 FORMAT "x(20)"  NO-LABEL
     WITH NO-BOX NO-ATTR-SPACE DOWN WIDTH 80 FRAME f_extsec.

FORM "CONTA/DV TITULAR" AT 19
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE WIDTH 80 FRAME f_label.

FORM aux_nrdconta AT 17 FORMAT "zzzz,zzz,9"
     aux_nmprimtl AT 28 FORMAT "x(40)"
     WITH NO-BOX NO-ATTR-SPACE NO-LABEL DOWN WIDTH 80 FRAME f_associado.

FORM SKIP(1)
     aux_qtextsec AT 17 FORMAT "zzz,zz9" LABEL "QUANTIDADE DE ASSOCIADOS"
     WITH NO-BOX NO-ATTR-SPACE SIDE-LABELS DOWN WIDTH 80 FRAME f_totalpar.

FORM tot_qtextsec AT 25 FORMAT "zzz,zz9" LABEL "QUANTIDADE GERAL"
     WITH NO-BOX NO-ATTR-SPACE SIDE-LABELS DOWN WIDTH 80 FRAME f_totalger.

FORM crapass.cdagenci AT  1 FORMAT "zz9"       LABEL "PA"
     aux_dssecext     AT  6 FORMAT "x(31)"     LABEL "SECAO PARA EXTRATO"
     crapdes.nmpesext AT 39 FORMAT "x(20)"     LABEL "AOS CUIDADOS DE"
     crapdes.nrfonext AT 61 FORMAT "x(20)"     LABEL "TELEFONE"
     WITH NO-BOX NO-ATTR-SPACE NO-LABEL DOWN WIDTH 80 FRAME f_destino.

ASSIGN aux_regexist = FALSE.

FOR EACH crapsol WHERE crapsol.cdcooper = glb_cdcooper  AND
                       crapsol.dtrefere = glb_dtmvtolt  AND
                       crapsol.nrsolici = 14            AND
                       crapsol.insitsol = 1
                       USE-INDEX crapsol2 TRANSACTION ON ERROR UNDO, RETRY:

    aux_cdagesol = INTEGER(crapsol.dsparame).

    OUTPUT STREAM str_2 TO arq/crrl023.tmp.

    IF   aux_cdagesol = 999 THEN
         FOR EACH crapass WHERE crapass.cdcooper  = glb_cdcooper    AND
                                crapass.cdsecext <> 0               AND
                                crapass.cdsecext <> 999             AND
                                crapass.dtdemiss  =  ?              NO-LOCK:

             PUT STREAM str_2
                    crapass.cdagenci FORMAT "999"      " "
                    crapass.cdsecext FORMAT "9999"     " "
                    crapass.nrdconta FORMAT "99999999" ' "'
                    crapass.nmprimtl FORMAT "x(40)"    '"' SKIP.

         END.
    ELSE
         FOR EACH crapass WHERE crapass.cdcooper  = glb_cdcooper    AND
                                crapass.cdsecext <> 0               AND
                                crapass.cdsecext <> 999             AND
                                crapass.dtdemiss  =  ?              AND
                                crapass.cdagenci = aux_cdagesol     NO-LOCK:

             PUT STREAM str_2
                        crapass.cdagenci FORMAT "999"      " "
                        crapass.cdsecext FORMAT "9999"     " "
                        crapass.nrdconta FORMAT "99999999" ' "'
                        crapass.nmprimtl FORMAT "x(40)"    '"' SKIP.

         END.

    PUT STREAM str_2 '999 9999 99999999 FIM DO ARQUIVO"' SKIP.

    OUTPUT STREAM str_2 CLOSE.

    UNIX SILENT VALUE("sort +0.0 -0.17 -o arq/crrl023.tmp " +
                                                  "arq/crrl023.tmp").
    glb_nrdevias = crapsol.nrdevias.

    { includes/cabrel080_1.i }               /* Monta cabecalho do relatorio */

    ASSIGN aux_regexist = TRUE
           aux_contaarq = aux_contaarq + 1
           aux_nmarqimp[aux_contaarq] = "rl/crrl023_" +
                                        STRING(crapsol.nrseqsol,"99") + ".lst"
           aux_nrdevias[aux_contaarq] = crapsol.nrdevias

           aux_cdsecext = 0

           aux_qtextsec = 0
           tot_qtextsec = 0.

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp[aux_contaarq]) PAGED PAGE-SIZE 84.

    VIEW STREAM str_1 FRAME f_cabrel080_1.

    IF  aux_cdagesol <> 999 THEN

        FOR EACH crapage WHERE crapage.cdcooper = glb_cdcooper  AND
                               crapage.cdagenci = aux_cdagesol  NO-LOCK:

            aux_flgexist = false.

            FOR EACH crapdes WHERE crapdes.cdcooper = glb_cdcooper      AND
                                   crapdes.cdagenci = crapage.cdagenci  NO-LOCK
                                   BY crapdes.nmsecext:

                FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                                         crapass.cdsecext = crapdes.cdsecext AND
                                         crapass.dtdemiss = ?                AND
                                         crapass.cdagenci = crapage.cdagenci
                                         NO-LOCK NO-ERROR.

                IF  AVAILABLE crapass THEN
                    DO:
                        ASSIGN aux_dssecext = STRING(crapdes.cdsecext,"zz9") +
                                              " - " + crapdes.nmsecext.

                        DISPLAY STREAM str_1
                             crapass.cdagenci  aux_dssecext
                             crapdes.nmpesext  crapdes.nrfonext
                             WITH FRAME f_destino.

                        DOWN STREAM str_1 WITH FRAME f_destino.

                        IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                             PAGE STREAM str_1.

                        aux_flgexist = TRUE.

                    END.
            END.  /* FOR EACH crapdes */

            PAGE STREAM str_1.

        END.   /* FOR EACH crapage */
    ELSE    /* Para todas as agencias. */
        FOR EACH crapage WHERE crapage.cdcooper = glb_cdcooper NO-LOCK:

            aux_flgexist = false.

            FOR EACH crapdes WHERE crapdes.cdcooper = glb_cdcooper      AND
                                   crapdes.cdagenci = crapage.cdagenci  NO-LOCK
                                   BY crapdes.nmsecext:

                FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                                         crapass.cdsecext = crapdes.cdsecext AND
                                         crapass.dtdemiss = ?                AND
                                         crapass.cdagenci = crapage.cdagenci
                                         NO-LOCK NO-ERROR.

                IF  AVAILABLE crapass THEN
                    DO:
                        ASSIGN aux_dssecext = STRING(crapdes.cdsecext,"zz9") +
                                              " - " + crapdes.nmsecext.

                        DISPLAY STREAM str_1
                             crapass.cdagenci  aux_dssecext
                             crapdes.nmpesext  crapdes.nrfonext
                             WITH FRAME f_destino.

                        DOWN STREAM str_1 WITH FRAME f_destino.

                        IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                             PAGE STREAM str_1.

                        aux_flgexist = TRUE.

                    END.
            END.  /* FOR EACH crapdes */

            IF  aux_flgexist THEN
                PAGE STREAM str_1.

        END.   /* FOR EACH crapage */

    IF  NOT aux_flgexist THEN
        PAGE STREAM str_1.

    ant_cdagenci = 1.
    aux_flgfirst = TRUE.

    INPUT STREAM str_2 FROM arq/crrl023.tmp NO-ECHO.

    REPEAT:

        SET STREAM str_2
            aux_cdagenci FORMAT "999"
            aux_nrsecext FORMAT "9999"
            aux_nrdconta FORMAT "99999999"
            aux_nmprimtl FORMAT "x(40)".

        IF   aux_cdsecext <> aux_nrsecext   THEN
             DO:
                 IF   aux_cdsecext > 0   THEN
                      DO:

                          IF  (LINE-COUNTER(str_1) + 1) > PAGE-SIZE(str_1)  THEN
                               DO:
                                   PAGE STREAM str_1.
                                   DISPLAY STREAM str_1
                                           aux_cdsecext  aux_nmsecext
                                           aux_nmpesext  aux_nrfonext
                                           WITH FRAME f_extsec.

                                   DOWN STREAM str_1 WITH FRAME f_extsec.
                               END.

                          DISPLAY STREAM str_1
                                  aux_qtextsec WITH FRAME f_totalpar.

                          IF   aux_cdagenci <> ant_cdagenci AND
                                               NOT aux_flgfirst THEN
                               DO:
                                   PAGE STREAM str_1.
                                   ant_cdagenci = aux_cdagenci.
                               END.
                          ELSE
                               DOWN 2 STREAM str_1 WITH FRAME f_totalpar.

                          IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                               PAGE STREAM str_1.

                          ASSIGN aux_qtextsec = 0
                                 aux_flgfirst = FALSE.

                      END.

                 aux_cdsecext = aux_nrsecext.

                 FIND crapdes WHERE crapdes.cdcooper = glb_cdcooper  AND
                                    crapdes.cdagenci = aux_cdagenci  AND
                                    crapdes.cdsecext = aux_cdsecext
                                    USE-INDEX crapdes1 NO-LOCK NO-ERROR.

                 IF   NOT AVAILABLE crapdes   THEN
                      IF   aux_cdsecext < 1000   THEN
                           DO:
                               glb_cdcritic = 19.
                               RUN fontes/critic.p.

                               UNIX SILENT VALUE ("echo " +
                                           STRING(TIME,"HH:MM:SS") + " - " +
                                           glb_cdprogra + "' --> '" +
                                           glb_dscritic + " SECAO = " +
                                           STRING(aux_cdsecext) +
                                           " CONTA = " + STRING(aux_nrdconta) +
                                           " >> log/proc_batch.log").

                               ASSIGN aux_nmsecext = "NAO CADASTRADA"
                                      aux_nmpesext = "NAO CADASTRADA"
                                      aux_nrfonext = "".
                           END.
                      ELSE
                           LEAVE.   /*  Sai do REPEAT  */
                 ELSE
                      DO:
                          ASSIGN aux_nmsecext = crapdes.nmsecext
                                 aux_nmpesext = crapdes.nmpesext
                                 aux_nrfonext = crapdes.nrfonext.

                          RELEASE crapdes.
                      END.

                 IF  (LINE-COUNTER(str_1) + 4) > PAGE-SIZE(str_1)   THEN
                      PAGE STREAM str_1.

                 DISPLAY STREAM str_1
                         aux_cdsecext  aux_nmsecext
                         aux_nmpesext  aux_nrfonext
                         WITH FRAME f_extsec.

                 DOWN 2 STREAM str_1 WITH FRAME f_extsec.

                 VIEW STREAM str_1 FRAME f_label.

             END.

        ASSIGN aux_qtextsec = aux_qtextsec + 1
               tot_qtextsec = tot_qtextsec + 1.

        DISPLAY STREAM str_1
                aux_nrdconta  aux_nmprimtl WITH FRAME f_associado.

        DOWN STREAM str_1 WITH FRAME f_associado.

        IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
             DO:
                 PAGE STREAM str_1.
                 DISPLAY STREAM str_1
                         aux_cdsecext  aux_nmsecext
                         aux_nmpesext  aux_nrfonext
                         WITH FRAME f_extsec.

                 DOWN 2 STREAM str_1 WITH FRAME f_extsec.

                 VIEW STREAM str_1 FRAME f_label.
             END.

    END.   /*  Fim do REPEAT  */

    DISPLAY STREAM str_1
            tot_qtextsec WITH FRAME f_totalger.

    OUTPUT STREAM str_1 CLOSE.
    INPUT  STREAM str_2 CLOSE.

    crapsol.insitsol = 2.

END.  /* Fim do FOR EACH e da transacao */

IF   NOT aux_regexist   THEN
     DO:
         glb_cdcritic = 157.
         RUN fontes/critic.p.

         UNIX SILENT VALUE ("echo " +
                             STRING(TIME,"HH:MM:SS") + " - " +
                             glb_cdprogra + "' --> '" +
                             glb_dscritic + " - SOL014"
                             + " >> log/proc_batch.log").
     END.

UNIX SILENT "rm arq/crrl023.tmp 2> /dev/null".

RUN fontes/fimprg.p.

IF   glb_cdcritic > 0   THEN
     RETURN.

IF   aux_regexist   THEN
     DO aux_contador = 1 TO 99:

        IF   aux_nmarqimp[aux_contador] = ""   THEN
             LEAVE.

        ASSIGN glb_nmformul = "80col"
               glb_nrcopias = aux_nrdevias[aux_contador]
               glb_nmarqimp = aux_nmarqimp[aux_contador].

        RUN fontes/imprim.p.
     END.

/* .......................................................................... */

