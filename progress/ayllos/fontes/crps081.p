/* ..........................................................................

   Programa: Fontes/crps081.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/94.                         Ultima atualizacao: 22/01/2015

   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Atende a solicitacao 066.
               Emite: Emprestimos com prestacao variavel (66).

   Alteracoes: 02/02/96 - Alterado para tratar as linhas 89 e 91 (Edson).

               07/02/95 - Alterado para atender solicitacao do usuario (Edson).

               19/11/96 - Alterar a mascara do campo nrctremp (Odair).

               24/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               09/04/2008 - Alterado o formato da variável "rel_qtpreapg" para
                            visualização no FORM "f_emprestimos" de "z9-" para
                            "zz9-".
                            
               01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
               
               09/03/2012 - Declarado novas variaveis da include lelem.i (Tiago)
               
               30/04/2012 - Utilizar qtprecal ao inves de qtprepag no calculo 
                            das prestacoes a pagar para exibir no relatorio
                            (Irlan)
               
               28/10/2013 - Alterado totalizador de 99 para 999. (Reinert)     
               
               25/04/2014 - Aumentado format campo cdlcremp de 3 para 4 
                            posicoes (Tiago/Gielow SD137074).
                            
               22/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714)
............................................................................. */

DEF STREAM str_1.     /* Para relatorio dos emprestimos  */

{ includes/var_batch.i "NEW" }

DEF            VAR rel_nrmodulo AS INT     FORMAT "9"                NO-UNDO.
DEF            VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                   INIT ["DEP. A VISTA   ","CAPITAL        ",
                                         "EMPRESTIMOS    ","DIGITACAO      ",
                                         "GENERICO       "]          NO-UNDO.

DEF        VAR rel_dsagenci     AS CHAR    FORMAT "x(21)"            NO-UNDO.
DEF        VAR rel_dslimcre     AS CHAR    FORMAT "x(2)"             NO-UNDO.
DEF        VAR rel_nmempres     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nmresemp     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.

DEF        VAR rel_qtpreapg     AS INT                               NO-UNDO.

DEF        VAR tot_nmtitulo     AS CHAR                              NO-UNDO.
DEF        VAR tot_nmresage     AS CHAR                              NO-UNDO.

DEF        VAR tot_qtdassag     AS INT     EXTENT 999                NO-UNDO.
DEF        VAR tot_qtdctrag     AS INT     EXTENT 999                NO-UNDO.
DEF        VAR tot_vldjurag     AS DECIMAL EXTENT 999                NO-UNDO.
DEF        VAR tot_vldempag     AS DECIMAL EXTENT 999                NO-UNDO.
DEF        VAR tot_vldpreag     AS DECIMAL EXTENT 999                NO-UNDO.
DEF        VAR tot_vldsdvag     AS DECIMAL EXTENT 999                NO-UNDO.

DEF        VAR ger_qtdassag     AS INT                               NO-UNDO.
DEF        VAR ger_qtdctrag     AS INT                               NO-UNDO.
DEF        VAR ger_vldjurag     AS DECIMAL                           NO-UNDO.
DEF        VAR ger_vldempag     AS DECIMAL                           NO-UNDO.
DEF        VAR ger_vldpreag     AS DECIMAL                           NO-UNDO.
DEF        VAR ger_vldsdvag     AS DECIMAL                           NO-UNDO.

DEF        VAR par_cdagenci     AS INT                               NO-UNDO.

DEF        VAR tab_inusatab     AS LOGICAL                           NO-UNDO.
DEF        VAR tab_diapagto     AS INT                               NO-UNDO.
DEF        VAR tab_dtcalcul     AS DATE                              NO-UNDO.


DEF        VAR aux_vlpreemp LIKE crapepr.vlpreemp                    NO-UNDO.
DEF        VAR aux_qtprecal LIKE crapepr.qtprecal                    NO-UNDO.
DEF        VAR aux_qtpreemp LIKE crapepr.qtpreemp                    NO-UNDO.
DEF        VAR aux_qtmesdec LIKE crapepr.qtmesdec                    NO-UNDO.

DEF        VAR aux_vljurmes AS DECIMAL FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF        VAR aux_vljuracu AS DECIMAL FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF        VAR aux_vlsdeved AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF        VAR aux_vlprepag AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR aux_txdjuros AS DECIMAL DECIMALS 7                    NO-UNDO.

DEF        VAR aux_nrdconta AS INT                                   NO-UNDO.
DEF        VAR aux_nrctremp AS INT                                   NO-UNDO.
DEF        VAR aux_nrdiacal AS INT                                   NO-UNDO.
DEF        VAR aux_nrdiames AS INT                                   NO-UNDO.
DEF        VAR aux_nrdiamss AS INT                                   NO-UNDO.
DEF        VAR aux_qtprepag AS INT                                   NO-UNDO.
DEF        VAR aux_cdagenci AS INT                                   NO-UNDO.
DEF        VAR aux_ddlanmto AS INT                                   NO-UNDO.

DEF        VAR aux_inhst093 AS LOGICAL                               NO-UNDO.

DEF        VAR aux_dtmvtolt AS DATE                                  NO-UNDO.
DEF        VAR aux_dtcalcul AS DATE                                  NO-UNDO.
DEF        VAR aux_dtultdia AS DATE                                  NO-UNDO.
DEF        VAR aux_dtultpag AS DATE                                  NO-UNDO.
DEF        VAR aux_dtmesant AS DATE                                  NO-UNDO.

DEF        VAR aux_nmresage AS CHAR    EXTENT 999                    NO-UNDO.

DEF        VAR aux_contador AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR aux_nmformul AS CHAR    FORMAT "x(005)" INIT ""       NO-UNDO.

DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.

DEF        VAR aux_cdempres AS INT                                   NO-UNDO.

ASSIGN glb_cdprogra = "crps081"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

{ includes/cabrel132_1.i }

FORM rel_dsagenci AT 1 FORMAT "x(21)" LABEL "AGENCIA"
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE SIDE-LABELS WIDTH 132 FRAME f_agencia.

FORM "CONTA/DV TITULAR"                                               AT   3
     "EMP  CONTRATO FIN LCR DAT.EMP.    TAXA DE JUROS     EMPRESTADO" AT  35
     "PRESTACAO   SALDO DEVEDOR PPG"                                  AT 104
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABEL WIDTH 132 FRAME f_label.

FORM crapepr.nrdconta AT   1 FORMAT "zzzz,zzz,9"
     crapass.nmprimtl AT  12 FORMAT "x(18)"
     crapepr.cdempres AT  31 FORMAT "zzzz9"       
     crapepr.nrctremp AT  37 FORMAT "zz,zzz,zz9"
     crapepr.cdfinemp AT  48 FORMAT "zz9"
     crapepr.cdlcremp AT  52 FORMAT "zzz9"
     crapepr.dtmvtolt AT  57 FORMAT "99/99/9999"
     crapepr.txjuremp AT  68 FORMAT "zz,zz9.9999999"
     crapepr.vlemprst AT  83 FORMAT "zzz,zzz,zz9.99"
     crapepr.vlpreemp AT  98 FORMAT "zzz,zzz,zz9.99"
     aux_vlsdeved     AT 113 FORMAT "zzzz,zzz,zz9.99-"
     rel_qtpreapg     AT 129 FORMAT "zz9-"
     WITH NO-BOX NO-ATTR-SPACE DOWN NO-LABEL WIDTH 132 FRAME f_emprestimos.

FORM SKIP(1)
     "TOTAIS:"
     tot_qtdassag[aux_cdagenci] AT   9 FORMAT "zzz,zz9" LABEL "ASSOCIADOS"
     tot_qtdctrag[aux_cdagenci] AT  31 FORMAT "zzz,zz9" LABEL "CONTRATOS"
     tot_vldjurag[aux_cdagenci] AT  50 FORMAT "zzz,zzz,zzz,zz9.99"
                                       LABEL "JUROS DO MES"
     tot_vldempag[aux_cdagenci] AT  83 FORMAT "zzzz,zzz,zz9.99" NO-LABEL
     tot_vldpreag[aux_cdagenci] AT  99 FORMAT "zzz,zzz,zz9.99"  NO-LABEL
     tot_vldsdvag[aux_cdagenci] AT 114 FORMAT "zzzz,zzz,zz9.99" NO-LABEL
     WITH NO-BOX NO-ATTR-SPACE SIDE-LABEL WIDTH 132 FRAME f_total_agencia.

FORM tot_nmresage               AT   1 FORMAT "x(21)"   LABEL "AGENCIA"
     tot_qtdassag[aux_cdagenci] AT  25 FORMAT "zzz,zz9" LABEL "ASSOCIADOS"
     tot_qtdctrag[aux_cdagenci] AT  38 FORMAT "zzz,zz9" LABEL "CONTRATOS"
     tot_vldjurag[aux_cdagenci] AT  50 FORMAT "zzz,zzz,zzz,zz9.99"
                                       LABEL "JUROS DO MES"
     tot_vldempag[aux_cdagenci] AT  72 FORMAT "zzz,zzz,zzz,zz9.99"
                                       LABEL "EMPRESTADO"
     tot_vldpreag[aux_cdagenci] AT  93 FORMAT "zzz,zzz,zzz,zz9.99"
                                       LABEL "PRESTACAO"
     tot_vldsdvag[aux_cdagenci] AT 114 FORMAT "zzz,zzz,zzz,zz9.99"
                                       LABEL "SALDO DEVEDOR"
     WITH NO-BOX NO-ATTR-SPACE DOWN WIDTH 132 FRAME f_total_geral.

FORM SKIP(1)
     ger_qtdassag AT  28 FORMAT "zzz,zz9"
     ger_qtdctrag AT  40 FORMAT "zzz,zz9"
     ger_vldjurag AT  50 FORMAT "zzz,zzz,zzz,zz9.99"
     ger_vldempag AT  72 FORMAT "zzz,zzz,zzz,zz9.99"
     ger_vldpreag AT  93 FORMAT "zzz,zzz,zzz,zz9.99"
     ger_vldsdvag AT 114 FORMAT "zzz,zzz,zzz,zz9.99"
     WITH NO-BOX NO-ATTR-SPACE NO-LABEL WIDTH 132 FRAME f_total.

FORM "RESUMO GERAL"
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE WIDTH 132 FRAME f_labelres.

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "USUARI"      AND
                   craptab.cdempres = 11            AND
                   craptab.cdacesso = "TAXATABELA"  AND
                   craptab.tpregist = 0             NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     tab_inusatab = FALSE.
ELSE
     tab_inusatab = IF SUBSTRING(craptab.dstextab,1,1) = "0"
                       THEN FALSE
                       ELSE TRUE.

ASSIGN tot_nmresage = ""
       par_cdagenci = INT(glb_dsparame).

/*  Le cadastro de agencias  */

FOR EACH crapage WHERE crapage.cdcooper = glb_cdcooper  
                       USE-INDEX crapage2 NO-LOCK:

    IF   par_cdagenci > 0   THEN
         IF   crapage.cdagenci <> par_cdagenci   THEN
              NEXT.

    ASSIGN glb_nmarqimp = "rl/crrl066_" + STRING(crapage.cdagenci,"999") + ".lst"

           aux_flgfirst = TRUE

           aux_cdagenci = crapage.cdagenci

           rel_dsagenci = STRING(crapage.cdagenci,"zz9") + " - " +
                          crapage.nmresage

           aux_nmresage[crapage.cdagenci] = crapage.nmresage.

    FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper      AND
                           crapass.cdagenci = crapage.cdagenci
                           USE-INDEX crapass2 NO-LOCK:

        IF   crapass.inpessoa = 1   THEN
             DO:
                 FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper       AND
                                    crapttl.nrdconta = crapass.nrdconta   AND
                                    crapttl.idseqttl = 1 NO-LOCK NO-ERROR.

                 IF   AVAIL crapttl  THEN
                      ASSIGN aux_cdempres = crapttl.cdempres.
             END.
        ELSE
             DO:
                 FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper  AND
                                    crapjur.nrdconta = crapass.nrdconta
                                    NO-LOCK NO-ERROR.

                 IF   AVAIL crapjur  THEN
                      ASSIGN aux_cdempres = crapjur.cdempres.
             END.

        aux_regexist = FALSE.

        /*  Leitura do dia do pagamento da empresa  */

        FIND craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                           craptab.nmsistem = "CRED"           AND
                           craptab.tptabela = "GENERI"         AND
                           craptab.cdempres = 00               AND
                           craptab.cdacesso = "DIADOPAGTO"     AND
                           craptab.tpregist = aux_cdempres     NO-LOCK NO-ERROR.
        
        IF   NOT AVAILABLE craptab   THEN
             DO:
                 glb_cdcritic = 55.

                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                   " - " + glb_cdprogra + "' --> '" +
                                   glb_dscritic + " DIA DO PAGTO DA EMPRESA " +
                                   STRING(aux_cdempres,"99999") +  
                                   " >> log/proc_batch.log").
                 QUIT.  /*  Retorna para o crps000  */
             END.

        IF   CAN-DO("1,3,4",STRING(crapass.cdtipsfx))   THEN
             tab_diapagto = INTEGER(SUBSTRING(craptab.dstextab,4,2)).
        ELSE
             tab_diapagto = INTEGER(SUBSTRING(craptab.dstextab,7,2)).
        
        /*  Verifica se a data do pagamento da empresa cai num dia util  */

        tab_dtcalcul = DATE(MONTH(glb_dtmvtolt),tab_diapagto,
                             YEAR(glb_dtmvtolt)).

        DO WHILE TRUE:

           IF   WEEKDAY(tab_dtcalcul) = 1   OR
                WEEKDAY(tab_dtcalcul) = 7   THEN
                DO:
                    tab_dtcalcul = tab_dtcalcul + 1.
                    NEXT.
                END.

           FIND crapfer WHERE crapfer.cdcooper = glb_cdcooper  AND 
                              crapfer.dtferiad = tab_dtcalcul  NO-LOCK NO-ERROR.

           IF   AVAILABLE crapfer   THEN
                DO:
                    tab_dtcalcul = tab_dtcalcul + 1.
                    NEXT.
                END.

           tab_diapagto = DAY(tab_dtcalcul).

           LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */

        FOR EACH crapepr WHERE crapepr.cdcooper = glb_cdcooper            AND
                               crapepr.nrdconta = crapass.nrdconta        AND
                               crapepr.vlsdeved > 0
                               USE-INDEX crapepr2 NO-LOCK:

            /*FIND craplcr OF crapepr NO-LOCK NO-ERROR.*/
            FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper AND
                               craplcr.cdlcremp = crapepr.cdlcremp
                               NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE craplcr   THEN
                 DO:
                     glb_cdcritic = 363.
                     RUN fontes/critic.p.
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '" +
                                       glb_dscritic + " " +
                                       STRING(crapepr.cdlcremp,"9999") +
                                       " >> log/proc_batch.log").
                     QUIT.  /*  Retorna para o crps000  */
                 END.

            IF   craplcr.tplcremp <> 2   THEN        /*  2 = EQUIV. SALARIAL  */
                 NEXT.

            IF   tab_inusatab           AND
                 crapepr.inliquid = 0   THEN
                 aux_txdjuros = craplcr.txdiaria.
            ELSE
                 aux_txdjuros = crapepr.txjuremp.

            /*  Inicialiazacao das variaves para a rotina de calculo  */

            ASSIGN aux_nrdconta = crapepr.nrdconta
                   aux_nrctremp = crapepr.nrctremp
                   aux_vlsdeved = crapepr.vlsdeved
                   aux_vljuracu = crapepr.vljuracu
                   aux_qtprepag = crapepr.qtprepag

                   aux_dtcalcul = ?

                   aux_dtultdia = ((DATE(MONTH(glb_dtmvtolt),28,
                                         YEAR(glb_dtmvtolt)) + 4) -
                                         DAY(DATE(MONTH(glb_dtmvtolt),28,
                                         YEAR(glb_dtmvtolt)) + 4)).


            IF   MONTH(glb_dtmvtolt) = MONTH(glb_dtmvtopr)   THEN
                 { includes/lelem.i } /*  Rotina p/ calculo do saldo devedor  */

            IF   aux_vlsdeved <= 0    THEN
                 NEXT.

            ASSIGN aux_regexist = TRUE

                   /* rel_qtpreapg = crapepr.qtpreemp - aux_qtprepag */
                   rel_qtpreapg = crapepr.qtpreemp - crapepr.qtprecal

                   tot_qtdctrag[aux_cdagenci] = tot_qtdctrag[aux_cdagenci] + 1
                   tot_vldjurag[aux_cdagenci] = tot_vldjurag[aux_cdagenci] +
                                                             aux_vljurmes
                   tot_vldempag[aux_cdagenci] = tot_vldempag[aux_cdagenci] +
                                                             crapepr.vlemprst
                   tot_vldpreag[aux_cdagenci] = tot_vldpreag[aux_cdagenci] +
                                                             crapepr.vlpreemp
                   tot_vldsdvag[aux_cdagenci] = tot_vldsdvag[aux_cdagenci] +
                                                             aux_vlsdeved.

            IF   aux_flgfirst   THEN
                 DO:
                     aux_flgfirst = FALSE.

                     OUTPUT STREAM str_1 TO VALUE(glb_nmarqimp)
                            PAGED PAGE-SIZE 84.

                     VIEW STREAM str_1 FRAME f_cabrel132_1.

                     DISPLAY STREAM str_1 rel_dsagenci WITH FRAME f_agencia.

                     VIEW STREAM str_1 FRAME f_label.
                 END.

            DISPLAY STREAM str_1
                    crapepr.nrdconta crapass.nmprimtl crapepr.cdempres
                    crapepr.nrctremp crapepr.cdfinemp crapepr.cdlcremp
                    crapepr.dtmvtolt crapepr.txjuremp crapepr.vlemprst
                    crapepr.vlpreemp aux_vlsdeved rel_qtpreapg
                    WITH FRAME f_emprestimos.

            DOWN STREAM str_1 WITH FRAME f_emprestimos.

            IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                 DO:
                     PAGE STREAM str_1.

                     DISPLAY STREAM str_1 rel_dsagenci WITH FRAME f_agencia.

                     VIEW STREAM str_1 FRAME f_label.
                 END.

        END.  /*  Fim do FOR EACH  --  Leitura dos emprestimos  */

        IF   aux_regexist   THEN
             tot_qtdassag[aux_cdagenci] = tot_qtdassag[aux_cdagenci] + 1.

    END.  /*  Fim do FOR EACH  --  Leitura do cadastro de associados  */

    IF   aux_flgfirst   THEN   /*  Verifica se entrou no FOR EACH crapass  */
         NEXT.

    /*  Imprime total da agencia  */

    IF  (LINE-COUNTER(str_1) + 1) > PAGE-SIZE(str_1)   THEN
         DO:
             PAGE STREAM str_1.

             DISPLAY STREAM str_1 rel_dsagenci WITH FRAME f_agencia.
         END.

    DISPLAY STREAM str_1
            tot_qtdassag[aux_cdagenci] tot_qtdctrag[aux_cdagenci]
            tot_vldjurag[aux_cdagenci] tot_vldempag[aux_cdagenci]
            tot_vldpreag[aux_cdagenci] tot_vldsdvag[aux_cdagenci]
            WITH FRAME f_total_agencia.

    OUTPUT STREAM str_1 CLOSE.

    ASSIGN glb_nmformul = ""
           glb_nrcopias = glb_nrdevias.
     
    RUN fontes/imprim.p.
    
END.  /*  Fim do FOR EACH  --  Leitura do cadastro de agencias  */

/*  Emite resumo geral  */

glb_nmarqimp = "rl/crrl066_999.lst".

OUTPUT STREAM str_1 TO VALUE(glb_nmarqimp) PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel132_1.

VIEW STREAM str_1 FRAME f_labelres.

DO aux_cdagenci = 1 TO 999:

   IF   tot_qtdassag[aux_cdagenci] = 0   THEN
        NEXT.

   ASSIGN ger_qtdassag = ger_qtdassag + tot_qtdassag[aux_cdagenci]
          ger_qtdctrag = ger_qtdctrag + tot_qtdctrag[aux_cdagenci]
          ger_vldjurag = ger_vldjurag + tot_vldjurag[aux_cdagenci]
          ger_vldempag = ger_vldempag + tot_vldempag[aux_cdagenci]
          ger_vldpreag = ger_vldpreag + tot_vldpreag[aux_cdagenci]
          ger_vldsdvag = ger_vldsdvag + tot_vldsdvag[aux_cdagenci]

          tot_nmresage = aux_nmresage[aux_cdagenci].

   DISPLAY STREAM str_1
           tot_nmresage
           tot_qtdassag[aux_cdagenci] tot_qtdctrag[aux_cdagenci]
           tot_vldjurag[aux_cdagenci] tot_vldempag[aux_cdagenci]
           tot_vldpreag[aux_cdagenci] tot_vldsdvag[aux_cdagenci]
           WITH FRAME f_total_geral.

   DOWN STREAM str_1 WITH FRAME f_total_geral.

   IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
        DO:
            PAGE STREAM str_1.

            VIEW STREAM str_1 FRAME f_labelres.
       END.

END.  /*  Fim do DO .. TO  */

/*  Imprime total geral  */

DISPLAY STREAM str_1
        ger_qtdassag ger_qtdctrag ger_vldjurag
        ger_vldempag ger_vldpreag ger_vldsdvag
        WITH FRAME f_total.

OUTPUT STREAM str_1 CLOSE.

ASSIGN glb_nmformul = ""
       glb_nrcopias = glb_nrdevias.
            
RUN fontes/imprim.p.
     
glb_infimsol = TRUE.

RUN fontes/fimprg.p.

/* .......................................................................... */
