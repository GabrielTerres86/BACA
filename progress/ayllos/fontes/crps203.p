/* ..........................................................................

   Programa: Fontes/crps203.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Maio/97                         Ultima atualizacao: 16/01/2014

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 061.
               Creditar em conta corrente referente aos convenios
               Emite relatorio 160.

   Alteracoes: 27/08/97 - Alterar crapavs.flgproce para true (Deborah).

               25/09/97 - Listar o tipo de conta (Odair).

               19/07/99 - Alterado para chamar a rotina de impressao (Edson).

               07/02/2000 - Gerar pedido de impressao (Deborah).

               30/06/2005 - Alimentado campo cdcooper das tabelas craplot
                            e craplcm (Diego).

               10/12/2005 - Atualizar craplcm.nrdctitg (Magui).
               
               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               09/06/2008 - Incluída a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               01/09/2008 - Alteracao CDEMPRES (Kbase).
               
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               15/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               16/01/2014 - Inclusao de VALIDATE craplot e craplcm (Carlos)
               
               05/07/2018 - PRJ450 - Chamada de rotina para consistir lançamentos em conta 
                            corrente (LANC0001) na tabela CRAPLCM  (Teobaldo J. - AMcom)
               
............................................................................. */

DEF STREAM str_1.      /*  Para relatorio de rejeitados  */

{ includes/var_batch.i {1} }
{ sistema/generico/includes/b1wgen0200tt.i }

DEF        VAR rel_nrmodulo AS INT    FORMAT "9"                      NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR   FORMAT "x(15)" EXTENT 5
                                      INIT ["DEP. A VISTA   ",
                                            "CAPITAL        ",
                                            "EMPRESTIMOS    ",
                                            "DIGITACAO      ",
                                            "GENERICO       "]        NO-UNDO.
                                             
DEF        VAR rel_nmresemp AS CHAR   FORMAT "x(15)"                  NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR   FORMAT "x(40)" EXTENT 5         NO-UNDO.

DEF        VAR aux_vltarifa AS DECI   EXTENT  35                      NO-UNDO.
DEF        VAR aux_dshistor AS CHAR   EXTENT  35                      NO-UNDO.
DEF        VAR tot_vlhistor AS DECI   EXTENT  35                      NO-UNDO.
DEF        VAR tot_qthistor AS INT    EXTENT  35                      NO-UNDO.
DEF        VAR tot_vlhispac AS DEC    EXTENT  35                      NO-UNDO.
DEF        VAR tot_qthispac AS INT    EXTENT  35                      NO-UNDO.
DEF        VAR tot_vlcobrar AS DECI   EXTENT  35                      NO-UNDO.

DEF        VAR rel_vltarifa AS DECI                                   NO-UNDO.
DEF        VAR tot_vltarifa AS DECI                                   NO-UNDO.

DEF        VAR aux_dtrefere AS DATE   FORMAT "99/99/9999"             NO-UNDO.

DEF        VAR aux_dstarifa AS CHAR                                   NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR                                   NO-UNDO.

DEF        VAR i            AS INTEGER                                NO-UNDO.
DEF        VAR n            AS INTEGER                                NO-UNDO.

DEF        VAR rel_dsempres AS CHAR   FORMAT "x(40)"                  NO-UNDO.
DEF        VAR rel_dsagenci AS CHAR   FORMAT "x(40)"                  NO-UNDO.

DEF        VAR rel_dsconven AS CHAR   FORMAT "x(30)"                  NO-UNDO.
DEF        VAR rel_flgfolha AS LOGI   FORMAT "FOLHA/CONTA"            NO-UNDO.
DEF        VAR aux_contaarq AS INT                                    NO-UNDO.

DEF        VAR aux_dsfimarq AS CHAR   FORMAT "x(80)"                  NO-UNDO.
DEF        VAR aux_dstithis AS CHAR   FORMAT "x(11)"                  NO-UNDO.
DEF        VAR aux_cdacesso AS CHAR                                   NO-UNDO.

/* Variaveis para rotina de lancamento craplcm */
DEF        VAR h-b1wgen0200 AS HANDLE  NO-UNDO.
DEF        VAR aux_incrineg AS INT     NO-UNDO.
DEF        VAR aux_cdcritic AS INT     NO-UNDO.
DEF        VAR aux_dscritic AS CHAR    NO-UNDO.


FORM       aux_dstithis     NO-LABELS  AT  17
           aux_dshistor[n]  NO-LABELS  FORMAT "x(29)" AT  29
           "TARIFA:"
           aux_vltarifa[n]  NO-LABELS FORMAT "zz9.99"
           WITH DOWN NO-BOX NO-LABELS FRAME f_historicos.

FORM    rel_dsempres LABEL "EMPRESA"    FORMAT "x(20)" AT 2
        aux_dtrefere LABEL "REFERENCIA" FORMAT "99/99/9999" AT 35
        rel_flgfolha LABEL "PROCESSO"   AT 61
        SKIP(1)
        rel_dsconven LABEL "CONVENIO"   FORMAT "x(45)"      AT  1
        glb_dtmvtopr LABEL "CREDITO EM" FORMAT "99/99/9999" AT 59
        SKIP(1)
        WITH DOWN NO-BOX SIDE-LABELS WIDTH 80 FRAME f_empresa.

FORM    SKIP(1)
        rel_dsagenci        LABEL "PA"
        SKIP(1)
        WITH NO-BOX SIDE-LABELS WIDTH 80 FRAME f_pac.

FORM    "CONTA/DV"          AT  04
        "TIP"               AT  13
        "VALOR CREDITADO"   AT  17
        "HIST"              AT  34
        "NOME"              AT  40
        SKIP(1)
        WITH NO-BOX SIDE-LABELS WIDTH 80 FRAME f_titulo.

FORM    crapavs.nrdconta  NO-LABEL   AT 2
        crapass.cdtipcta  NO-LABEL   FORMAT "z9"             AT 14
        crapavs.vllanmto  NO-LABEL   FORMAT "zzz,zzz,zz9.99" AT 18
        crapavs.cdhistor  NO-LABEL   FORMAT "9999"           AT 35
        crapass.nmprimtl  NO-LABEL   FORMAT "x(40)"          AT 40
        SKIP(1)
        WITH NO-BOX NO-ATTR-SPACE NO-LABEL WIDTH 80 FRAME f_lancto.

FORM    "RESUMO GERAL :"
        WITH NO-BOX NO-ATTR-SPACE NO-LABEL WIDTH 080 FRAME f_resumo.

FORM    SKIP(1)
        "HISTORICO"       AT  01
        "QTD"             AT  57
        "VALOR"           AT  76
        SKIP(1)
        WITH NO-BOX NO-ATTR-SPACE NO-LABEL WIDTH 080 FRAME f_titres.

FORM    aux_dshistor[i]   AT  01  FORMAT "x(25)"         NO-LABEL
        tot_qthistor[i]   AT  31  FORMAT "zzzzz,zz9" LABEL "CREDITOS A EFETUAR"
        tot_vlhistor[i]   AT  63  FORMAT "zzz,zzz,zzz,zz9.99" NO-LABEL
        SKIP
        aux_dstarifa      AT  34  FORMAT "x(16)"     NO-LABEL
        rel_vltarifa      AT  63  FORMAT "zzz,zzz,zzz,zz9.99" NO-LABEL
        tot_vlcobrar[i]   AT  35  FORMAT "            zzz,zzz,zzz,zz9.99"
                                                     LABEL "VALOR A COBRAR"
        SKIP(1)
        WITH DOWN NO-BOX NO-ATTR-SPACE SIDE-LABELS WIDTH 80 FRAME f_geral.

FORM    aux_dshistor[i]   AT  01  FORMAT "x(25)"         NO-LABEL
        tot_qthispac[i]   AT  31  FORMAT "zzzzz,zz9" LABEL "CREDITOS A EFETUAR"
        tot_vlhispac[i]   AT  63  FORMAT "zzz,zzz,zzz,zz9.99" NO-LABEL
        SKIP
        aux_dstarifa      AT  34  FORMAT "x(16)"     NO-LABEL
        rel_vltarifa      AT  63  FORMAT "zzz,zzz,zzz,zz9.99" NO-LABEL
        tot_vlcobrar[i]   AT  35  FORMAT "            zzz,zzz,zzz,zz9.99"
                                                     LABEL "VALOR A COBRAR"
        SKIP(1)
        WITH DOWN NO-BOX NO-ATTR-SPACE SIDE-LABELS WIDTH 80 FRAME f_geralpac.

FORM    aux_dsfimarq WITH NO-BOX NO-LABELS WITH FRAME f_fim.

ASSIGN glb_cdprogra = "crps203"
       aux_dstithis = "HISTORICOS:"
       aux_dstarifa = "TOTAL DA TARIFA:"
       aux_dsfimarq = " ==================================   " +
                      "FIM   ==================================".

RUN fontes/iniprg.p.

{ includes/cabrel080_1.i }      /*  Monta cabecalho do relatorio  */

IF   glb_cdcritic > 0 THEN
     RETURN.

/* HANDLE PARA INSERÇAO DA CRAPLCM */
IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
    RUN sistema/generico/procedures/b1wgen0200.p 
    PERSISTENT SET h-b1wgen0200.


FOR EACH crapepc WHERE crapepc.cdcooper  = glb_cdcooper  AND
                       crapepc.incvcta1  = 1             AND
                       crapepc.dtcvcta1 <= glb_dtmvtopr:

    FIND crapcnv WHERE crapcnv.cdcooper  = glb_cdcooper     AND
                       crapcnv.nrconven = crapepc.nrconven  NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapcnv THEN
         DO:
             glb_cdcritic = 563.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                glb_cdprogra + "' --> '" +
                                glb_dscritic + STRING(crapepc.nrconven,"999") +
                                " >> log/proc_batch.log").
             glb_cdcritic = 0.
             RETURN.
         END.

    IF   crapcnv.indebcre <> "C" THEN
         NEXT.

    FOR EACH crapavs WHERE crapavs.cdcooper = glb_cdcooper      AND
                           crapavs.nrconven = crapepc.nrconven  AND
                           crapavs.cdempcnv = crapepc.cdempres  AND
                           crapavs.dtrefere = crapepc.dtrefere  AND
                           crapavs.insitavs = 0                 AND
                           crapavs.tpdaviso = 3                 TRANSACTION:

        FIND craplot WHERE craplot.cdcooper = glb_cdcooper  AND
                           craplot.dtmvtolt = glb_dtmvtopr  AND
                           craplot.cdagenci = 1             AND
                           craplot.cdbccxlt = 100           AND
                           craplot.nrdolote = 8462
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF   NOT AVAILABLE craplot   THEN
             DO:

                 CREATE craplot.
                 ASSIGN craplot.dtmvtolt = glb_dtmvtopr
                        craplot.cdagenci = 1
                        craplot.cdbccxlt = 100
                        craplot.nrdolote = 8462
                        craplot.tplotmov = 1
                        craplot.nrseqdig = 0
                        craplot.vlcompcr = 0
                        craplot.vlinfocr = 0
                        craplot.cdhistor = 0
                        craplot.cdoperad = "1"
                        craplot.dtmvtopg = ?
                        craplot.cdcooper = glb_cdcooper.
                 VALIDATE craplot.

             END.

        ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
               craplot.qtcompln = craplot.qtcompln + 1
               craplot.qtinfoln = craplot.qtcompln
               craplot.vlcompcr = craplot.vlcompcr + crapavs.vllanmto
               craplot.vlinfocr = craplot.vlcompcr.

        RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
          (INPUT glb_dtmvtopr                   /* par_dtmvtolt */
          ,INPUT craplot.cdagenci               /* par_cdagenci */
          ,INPUT craplot.cdbccxlt               /* par_cdbccxlt */
          ,INPUT craplot.nrdolote               /* par_nrdolote */
          ,INPUT crapavs.nrdconta               /* par_nrdconta */
          ,INPUT crapavs.nrdocmto               /* par_nrdocmto */
          ,INPUT crapavs.cdhistor               /* par_cdhistor */
          ,INPUT craplot.nrseqdig               /* par_nrseqdig */
          ,INPUT crapavs.vllanmto               /* par_vllanmto */
          ,INPUT crapavs.nrdconta               /* par_nrdctabb */
          ,INPUT ""                             /* par_cdpesqbb */
          ,INPUT 0                              /* par_vldoipmf */
          ,INPUT 0                              /* par_nrautdoc */
          ,INPUT 0                              /* par_nrsequni */
          ,INPUT 0                              /* par_cdbanchq */
          ,INPUT 0                              /* par_cdcmpchq */
          ,INPUT 0                              /* par_cdagechq */
          ,INPUT 0                              /* par_nrctachq */
          ,INPUT 0                              /* par_nrlotchq */
          ,INPUT 0                              /* par_sqlotchq */
          ,INPUT ""                             /* par_dtrefere */
          ,INPUT ""                             /* par_hrtransa */
          ,INPUT ""                             /* par_cdoperad */
          ,INPUT ""                             /* par_dsidenti */
          ,INPUT glb_cdcooper                   /* par_cdcooper */
          ,INPUT STRING(crapavs.nrdconta,"99999999") /* par_nrdctitg */
          ,INPUT ""                             /* par_dscedent */
          ,INPUT 0                              /* par_cdcoptfn */
          ,INPUT 0                              /* par_cdagetfn */
          ,INPUT 0                              /* par_nrterfin */
          ,INPUT 0                              /* par_nrparepr */
          ,INPUT 0                              /* par_nrseqava */
          ,INPUT 0                              /* par_nraplica */
          ,INPUT 0                              /* par_cdorigem */
          ,INPUT 0                              /* par_idlautom */
          /* CAMPOS OPCIONAIS DO LOTE                                                            */ 
          ,INPUT 0                              /* Processa lote                                 */
          ,INPUT 0                              /* Tipo de lote a movimentar                     */
          /* CAMPOS DE SAIDA                                                                     */                                            
          ,OUTPUT TABLE tt-ret-lancto           /* Collection que contem o retorno do lancamento */
          ,OUTPUT aux_incrineg                  /* Indicador de critica de negocio               */
          ,OUTPUT aux_cdcritic                  /* Codigo da critica                             */
          ,OUTPUT aux_dscritic).                /* Descricao da critica                          */
          
        IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
           DO: 
             /* Tratamento caso retorne erro */
             glb_dscritic = aux_dscritic.

             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                glb_cdprogra + "' --> '" +
                                glb_dscritic + STRING(crapepc.nrconven,"999") +
                                " >> log/proc_batch.log").
             glb_cdcritic = 0.
             RETURN.
           END.   
        ELSE 
           DO:
             /* Posicionando no registro da craplcm criado acima */
             FIND FIRST tt-ret-lancto.
             FIND FIRST craplcm WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm NO-ERROR.
           END.                
        

        ASSIGN crapavs.vldebito = crapavs.vllanmto
               crapavs.insitavs = 1
               crapavs.vlestdif = 0
               crapavs.flgproce = TRUE.

    END.  /* FOR EACH crapavs TRANSACTION */

    DO TRANSACTION:

       ASSIGN crapepc.dtcvcta1 = glb_dtmvtopr
              crapepc.incvcta1 = 2.

    END.

END.  /* FOR each crapepc */

/* Liberar handle alocado */
IF  VALID-HANDLE(h-b1wgen0200) THEN
    DELETE PROCEDURE h-b1wgen0200.


FOR EACH crapepc WHERE crapepc.cdcooper = glb_cdcooper  AND
                       crapepc.incvcta1 = 2             AND
                       crapepc.dtcvcta1 = glb_dtmvtopr  NO-LOCK:

    ASSIGN tot_vlhistor = 0
           tot_qthistor = 0
           tot_qthispac = 0
           tot_vlhispac = 0
           tot_vlcobrar = 0
           aux_dshistor = ""
           aux_dtrefere = crapepc.dtrefere.

    FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper      AND
                       crapemp.cdempres = crapepc.cdempres  NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapemp THEN
         ASSIGN  rel_dsempres = STRING(crapepc.cdempres,"99999") +
                                " - Nao encontrada".
    ELSE
         ASSIGN  rel_dsempres = STRING(crapepc.cdempres,"99999") + " - " +
                                crapemp.nmresemp.

    FIND crapcnv WHERE crapcnv.cdcooper = glb_cdcooper      AND
                       crapcnv.nrconven = crapepc.nrconven  NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapcnv THEN
         DO:
             glb_cdcritic = 563.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                glb_cdprogra + "' --> '" +
                                glb_dscritic + STRING(crapepc.nrconven,"999") +
                                " >> log/proc_batch.log").
             glb_cdcritic = 0.
             RETURN.
         END.

    IF   crapcnv.indebcre <> "C" THEN
         NEXT.

    DO   i = 1 TO NUM-ENTRIES(crapcnv.lshistor):

         FIND craphis WHERE craphis.cdcooper = glb_cdcooper    AND
                            craphis.cdhistor = 
                            INTEGER(ENTRY(i,crapcnv.lshistor)) NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE craphis THEN
              aux_dshistor[i] = ENTRY(i,crapcnv.lshistor) + " - Nao encontrado".
         ELSE
              DO:
                  aux_dshistor[i] = STRING(craphis.cdhistor,"9999") + " - " +
                                    craphis.dshistor.
                                    
                  ASSIGN aux_cdacesso = "".
                  IF   craphis.cdhistor  > 999  THEN
                       ASSIGN aux_cdacesso = "VLTARIF" + 
                                             STRING(craphis.cdhistor,"9999").
                  ELSE
                       ASSIGN aux_cdacesso = "VLTARIF" +
                                             STRING(craphis.cdhistor,"999").
              END.
         
         FIND craptab WHERE 
              craptab.cdcooper = glb_cdcooper      AND
              craptab.nmsistem = "CRED"            AND
              craptab.tptabela = "USUARI"          AND
              craptab.cdempres = crapepc.cdempres  AND
              craptab.cdacesso = aux_cdacesso      AND
              craptab.tpregist = 1 
              NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE craptab THEN
              aux_vltarifa[i] = 0.
         ELSE
              aux_vltarifa[i] = DECIMAL(craptab.dstextab).

    END.

    ASSIGN rel_flgfolha = FALSE
           rel_dsconven = SUBSTR(STRING(crapepc.nrconven,"999999"),4,3) +
                          " - " + crapcnv.dsconven

           aux_contaarq = aux_contaarq + 1
           aux_nmarqimp = "rl/crrl160_" +
                          STRING(aux_contaarq,"99") + ".lst".

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

    VIEW STREAM str_1 FRAME f_cabrel080_1.

    FOR EACH crapavs WHERE crapavs.cdcooper = glb_cdcooper      AND
                           crapavs.nrconven = crapepc.nrconven  AND
                           crapavs.cdempcnv = crapepc.cdempres  AND
                           crapavs.dtrefere = crapepc.dtrefere  AND
                           crapavs.tpdaviso = 3                 NO-LOCK, 
        /* EACH crapass OF crapavs NO-LOCK */
        EACH crapass WHERE crapass.cdcooper = glb_cdcooper      AND
                           crapass.nrdconta = crapavs.nrdconta  NO-LOCK
                           BREAK BY crapass.cdagenci
                                    BY crapavs.nrdconta:

        IF   FIRST-OF(crapass.cdagenci)  OR LINE-COUNTER(str_1) >= 82 THEN
             DO:

                 IF   LINE-COUNTER(str_1) >= 82 THEN
                      DO:
                          PAGE STREAM str_1.
                      END.
                 ELSE
                      DO:
                          /* FIND crapage OF crapavs NO-LOCK NO-ERROR. */
                          FIND crapage WHERE 
                               crapage.cdcooper = glb_cdcooper      AND
                               crapage.cdagenci = crapavs.cdagenci  
                               NO-LOCK NO-ERROR.

                          IF  NOT AVAILABLE crapage THEN
                              rel_dsagenci = STRING(crapavs.cdagenci,"999") +
                                             " - " + "NAO CADASTRADA".
                          ELSE
                              rel_dsagenci = STRING(crapavs.cdagenci,"999") +
                                             " - " + crapage.nmresage.
                      END.

                 DISPLAY STREAM str_1 rel_dsempres aux_dtrefere
                                      rel_flgfolha rel_dsconven
                                      glb_dtmvtopr
                                      WITH FRAME f_empresa.

                 DOWN STREAM str_1 WITH frame f_empresa.

                 DO  n = 1 TO NUM-ENTRIES(crapcnv.lshistor):

                     DISPLAY STREAM str_1 aux_dstithis WHEN n = 1
                                          aux_dshistor[n]
                                          aux_vltarifa[n]
                                          WITH FRAME f_historicos.

                     DOWN STREAM str_1 WITH FRAME f_historicos.

                 END.

                 DISPLAY STREAM str_1 rel_dsagenci WITH FRAME f_pac.

                 DOWN STREAM str_1 WITH FRAME f_pac.

                 VIEW STREAM str_1 FRAME f_titulo.

             END. /* FIRST-OF */

        ASSIGN i           = LOOKUP(STRING(crapavs.cdhistor),crapcnv.lshistor)
               tot_vlhistor[i] = tot_vlhistor[i] + crapavs.vllanmto
               tot_qthistor[i] = tot_qthistor[i] + 1
               tot_vlhispac[i] = tot_vlhispac[i] + crapavs.vllanmto
               tot_qthispac[i] = tot_qthispac[i] + 1.

        DISPLAY STREAM str_1 crapavs.nrdconta crapass.cdtipcta
                             crapavs.vllanmto crapavs.cdhistor
                             crapass.nmprimtl
                             WITH FRAME f_lancto.

        DOWN STREAM str_1 WITH FRAME f_lancto.

        IF   LAST-OF(crapass.cdagenci) THEN
             DO:

                 DISPLAY STREAM str_1 aux_dsfimarq WITH FRAME f_fim.

                 PAGE STREAM str_1.

                 DISPLAY STREAM str_1 rel_dsempres aux_dtrefere
                                      rel_flgfolha rel_dsconven
                                      glb_dtmvtopr
                                      WITH FRAME f_empresa.

                 DOWN STREAM str_1 WITH frame f_empresa.

                 DO  n = 1 TO NUM-ENTRIES(crapcnv.lshistor):

                     DISPLAY STREAM str_1 aux_dstithis WHEN n = 1
                                          aux_dshistor[n]
                                          aux_vltarifa[n]
                                          WITH FRAME f_historicos.

                     DOWN STREAM str_1 WITH FRAME f_historicos.

                 END.

                 DISPLAY STREAM str_1 rel_dsagenci WITH FRAME f_pac.

                 DOWN STREAM str_1 WITH FRAME f_pac.

                 VIEW STREAM str_1 FRAME f_titres.

                 DO i = 1 TO NUM-ENTRIES(crapcnv.lshistor):

                    IF   tot_qthispac[i]  > 0 THEN
                       DO:
                          ASSIGN tot_vlhispac[35] = tot_vlhispac[35]
                                                    + tot_vlhispac[i]
                                 tot_qthispac[35] = tot_qthispac[35] +
                                                    tot_qthispac[i].

                          IF   LINE-COUNTER(str_1) >= 80 THEN
                               DO:
                                   PAGE STREAM str_1.

                                  DISPLAY STREAM str_1 rel_dsempres aux_dtrefere
                                                       rel_flgfolha rel_dsconven
                                                       glb_dtmvtopr
                                                       WITH FRAME f_empresa.

                                   DOWN STREAM str_1 WITH frame f_empresa.

                                   DO  n = 1 TO NUM-ENTRIES(crapcnv.lshistor):

                                       DISPLAY STREAM str_1 aux_dstithis
                                                            WHEN n = 1
                                               aux_dshistor[n]
                                               aux_vltarifa[n]
                                               WITH FRAME f_historicos.

                                      DOWN STREAM str_1 WITH FRAME f_historicos.

                                   END.

                                   DISPLAY STREAM str_1 rel_dsagenci
                                                        WITH FRAME f_pac.

                                   DOWN STREAM str_1 WITH FRAME f_pac.

                                   VIEW STREAM str_1 FRAME f_titres.

                               END.

                          ASSIGN rel_vltarifa     = tot_qthispac[i] *
                                                    aux_vltarifa[i]
                                 tot_vltarifa     = tot_vltarifa + rel_vltarifa
                                 tot_vlcobrar[i]  = tot_vlhispac[i] +
                                                    rel_vltarifa
                                 tot_vlcobrar[35] = tot_vlcobrar[35] +
                                                    tot_vlcobrar[i].

                          DISPLAY STREAM str_1
                                         aux_dshistor[i]
                                         tot_qthispac[i]   tot_vlhispac[i]
                                         aux_dstarifa      rel_vltarifa
                                         tot_vlcobrar[i]  WITH FRAME f_geralpac.

                          DOWN STREAM str_1 WITH FRAME f_geralpac.

                       END.

                 END.  /* DO i = 1 TO */

                 ASSIGN aux_dshistor[35] = "TOTAL DO PA  ==>"
                        i                = 35
                        rel_vltarifa     = tot_vltarifa.

                 DISPLAY STREAM str_1  aux_dshistor[i]
                                tot_qthispac[i]   tot_vlhispac[i]
                                aux_dstarifa      rel_vltarifa
                                tot_vlcobrar[i]
                                WITH FRAME f_geralpac.

                 ASSIGN tot_qthispac = 0
                        tot_vlhispac = 0
                        tot_vlcobrar = 0
                        tot_vltarifa = 0.

                 PAGE STREAM str_1.

             END.  /* IF LAST-OF */

    END. /* FOR EACH crapavs */

    DISPLAY STREAM str_1 rel_dsempres aux_dtrefere
                         rel_flgfolha rel_dsconven
                         glb_dtmvtopr WITH FRAME f_empresa.

    DOWN STREAM str_1 WITH FRAME f_empresa.

    VIEW STREAM str_1 FRAME f_resumo.

    VIEW STREAM str_1 FRAME f_titres.

    ASSIGN
           tot_vlcobrar = 0.

    DO   i = 1 TO NUM-ENTRIES(crapcnv.lshistor):

         IF   tot_vlhistor[i]  > 0 THEN
              DO:
                  ASSIGN tot_vlhistor[35] = tot_vlhistor[35] + tot_vlhistor[i]
                         tot_qthistor[35] = tot_qthistor[35] + tot_qthistor[i]
                         rel_vltarifa     = tot_qthistor[i] * aux_vltarifa[i]
                         tot_vltarifa     = tot_vltarifa + rel_vltarifa
                         tot_vlcobrar[i]  = tot_vlhistor[i] + rel_vltarifa
                         tot_vlcobrar[35] = tot_vlcobrar[35] + tot_vlcobrar[i].

                  IF   LINE-COUNTER(str_1) >= 80 THEN
                       DO:
                           PAGE STREAM str_1.

                           DISPLAY STREAM str_1 rel_dsempres aux_dtrefere
                                                rel_dsconven rel_flgfolha
                                                WITH FRAME f_empresa.

                           DOWN STREAM str_1 WITH frame f_empresa.

                           VIEW STREAM str_1 FRAME f_resumo.

                       END.

                  DISPLAY STREAM str_1  aux_dshistor[i]
                                        tot_qthistor[i]   tot_vlhistor[i]
                                        aux_dstarifa      rel_vltarifa
                                        tot_vlcobrar[i]
                                        WITH FRAME f_geral.

                  DOWN STREAM str_1 WITH FRAME f_geral.

              END.
    END.    /* DO i = 1 TO */

    ASSIGN aux_dshistor[35] = "TOTAL GERAL ==>"
           i                = 35
           rel_vltarifa     = tot_vltarifa
           tot_vltarifa     = 0.

    IF   LINE-COUNTER(str_1) >= 80 THEN
         DO:
             PAGE STREAM str_1.

             DISPLAY STREAM str_1 rel_dsempres aux_dtrefere rel_dsconven
                                  rel_flgfolha WITH FRAME f_empresa.

             DOWN STREAM str_1 WITH frame f_empresa.

             VIEW STREAM str_1 FRAME f_resumo.

         END.

    DISPLAY STREAM str_1  aux_dshistor[i]
                          tot_qthistor[i]   tot_vlhistor[i]
                          aux_dstarifa      rel_vltarifa
                          tot_vlcobrar[i]
                          WITH FRAME f_geral.

    OUTPUT STREAM str_1 CLOSE.

    ASSIGN glb_nmformul = "80col"
           glb_nmarqimp = aux_nmarqimp
           glb_nrcopias = 1.
                      
    RUN fontes/imprim.p.
   
END.    /* FOR EACH crapepc */

RUN fontes/fimprg.p.

/* .......................................................................... */

