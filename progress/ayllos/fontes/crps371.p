/* ..........................................................................

   Programa: Fontes/crps371.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo     
   Data    : Novembro/03.                      Ultima atualizacao: 22/01/2015

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 094.
               Processar as solicitacoes de geracao dos debitos de 
               emprestimos da CECRISACRED.
               Emite relatorio 319.

   Alteracoes: 08/06/2004 - Acrescentou 1 centavo no CPMF, diferenca no saldo
                            devedor (Ze Eduardo).
                            
               30/06/2005 - Alimentado campo cdcooper da tabela crapavs (Diego).

               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego)
                            
               17/02/2006 - Unificacao dos bancos - SQLWorks - Eder             

               18/03/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)
                            
               01/09/2008 - Alteracao CDEMPRES (Kbase).
               
               
               12/09/2011 - Alterado e-mail jcc@cecrisa.com.br para 
                            ama@colorminas.com.br e 
                            paulo.ribeiro@colorminas.com.br (Adriano).
                            
               03/01/2012 - Ajuste para encaminhar os arquivos para os e-mails
                            de acordo com crapemp.dsdemail (Adriano).
                            
               09/03/2012 - Declarado variaveis necessarias para utilizacao
                            da include lelem.i (Tiago)
                            
               28/11/2012 - Tratar so os emprestimos do tipo zero Price TR (Oscar).
               
               21/01/2014 - Incluir VALIDATE crapavs (Lucas R.)
               
               30/12/2014 - Alterado EXTENT 9999 -> tab_txdjuros (Diego).
                            
               22/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714)
............................................................................. */

DEF STREAM str_1.  /*  Para exportacao/importacao dos debitos  */
DEF STREAM str_2.  /*  Para a opcao de saida como relatorio  */
DEF STREAM str_3.  /*  Para a opcao de saida como arquivo no formato RHFP  */

{ includes/var_batch.i {1} }  

{ includes/var_cpmf.i } 

DEF   VAR b1wgen0011   AS HANDLE                                     NO-UNDO.

DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_dsintegr AS CHAR                                  NO-UNDO.
DEF        VAR rel_nmempres AS CHAR                                  NO-UNDO.
DEF        VAR rel_qtdifeln AS INT                                   NO-UNDO.
DEF        VAR rel_vldifedb AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vldifecr AS DECIMAL                               NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "]      NO-UNDO.

DEF        VAR rel_dsempres AS CHAR                                  NO-UNDO.
DEF        VAR rel_nrcadast AS INT                                   NO-UNDO.
DEF        VAR rel_nrdconta AS INT                                   NO-UNDO.
DEF        VAR rel_nrctremp AS INT                                   NO-UNDO.
DEF        VAR rel_nrdocmto AS INT                                   NO-UNDO.
DEF        VAR rel_cdsecext AS INT                                   NO-UNDO.
DEF        VAR rel_cdagenci AS INT                                   NO-UNDO.
DEF        VAR rel_vlpreemp AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vltotpre AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vlprecpm AS DECIMAL                               NO-UNDO.
DEF        VAR rel_nmprimtl AS CHAR                                  NO-UNDO.

DEF        VAR rel_dtrefere AS INT     FORMAT "99999999"  /*formato AAAAMMDD*/
                                                                     NO-UNDO.
DEF        VAR rel_dtproces AS INT     FORMAT "99999999"  /*formato AAAAMMDD*/
                                                                     NO-UNDO.
DEF        VAR rel_nrversao AS INT                                   NO-UNDO.
DEF        VAR rel_nrseqdeb AS INT                                   NO-UNDO.

DEF        VAR rel_dtultdia AS DATE                                  NO-UNDO.

DEF        VAR rel_cddescto AS INT     INIT 420                      NO-UNDO.
DEF        VAR rel_cdempres AS INT                                   NO-UNDO.
DEF        VAR rel_espvazio AS CHAR    INIT "          "             NO-UNDO.
DEF        VAR rel_nmsistem AS CHAR    INIT "EM"                     NO-UNDO.

DEF        VAR tot_qtdassoc AS INT                                   NO-UNDO.
DEF        VAR tot_qtctremp AS INT                                   NO-UNDO.
DEF        VAR tot_vlpreemp AS DECIMAL                               NO-UNDO.
DEF        VAR tot_vlprecpm AS DECIMAL                               NO-UNDO.

DEF        VAR epr_qtctremp AS INT                                   NO-UNDO.
DEF        VAR epr_nrctremp AS INT     EXTENT 99                     NO-UNDO.
DEF        VAR epr_vlpreemp AS DECIMAL EXTENT 99                     NO-UNDO.

DEF        VAR tab_txdjuros AS DECIMAL EXTENT 9999                   NO-UNDO.

DEF        VAR tab_diapagto AS INT                                   NO-UNDO.
DEF        VAR tab_cdempres AS INT                                   NO-UNDO.
DEF        VAR tab_dtcalcul AS DATE                                  NO-UNDO.
DEF        VAR tab_inusatab AS LOGICAL                               NO-UNDO.

DEF        VAR tab_ddpgtohr AS INT                                   NO-UNDO.
DEF        VAR tab_ddpgtoms AS INT                                   NO-UNDO.
DEF        VAR tab_ddmesnov AS INT                                   NO-UNDO.

DEF        VAR arq_nrseqdeb AS INT                                   NO-UNDO.
DEF        VAR ass_nrseqdeb AS INT                                   NO-UNDO.

DEF        VAR con_nrcadast AS INT                                   NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR    FORMAT "x(20)" EXTENT 99      NO-UNDO.
DEF        VAR aux_nrdevias AS INT     FORMAT "z9"    EXTENT 99      NO-UNDO.

DEF        VAR aux_nmarqdeb AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_nmarqtrf AS CHAR                                  NO-UNDO.
DEF        VAR aux_intipsai AS CHAR                                  NO-UNDO.

DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgarqab AS LOGICAL                               NO-UNDO.

DEF        VAR aux_contaarq AS INT                                   NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_cdtipsfx AS INT                                   NO-UNDO.
DEF        VAR aux_cdcalcul AS INT                                   NO-UNDO.
DEF        VAR aux_inisipmf AS INT                                   NO-UNDO.

DEF        VAR aux_nrseqsol AS CHAR                                  NO-UNDO.

DEF        VAR aux_dtcalcul AS DATE                                  NO-UNDO.
DEF        VAR aux_dtultdia AS DATE                                  NO-UNDO.
DEF        VAR aux_dtmesant AS DATE                                  NO-UNDO.
DEF        VAR aux_dtultpag AS DATE                                  NO-UNDO.
DEF        VAR aux_dtmesnov AS DATE                                  NO-UNDO.
DEF        VAR aux_dtdemiss AS DATE                                  NO-UNDO.

DEF        VAR aux_inliquid AS INT                                   NO-UNDO.
DEF        VAR aux_nrdconta AS INT                                   NO-UNDO.
DEF        VAR aux_nrctatos AS INT                                   NO-UNDO.
DEF        VAR aux_nrctremp AS INT                                   NO-UNDO.
DEF        VAR aux_nrultdia AS INT                                   NO-UNDO.
DEF        VAR aux_nrdiacal AS INT                                   NO-UNDO.
DEF        VAR aux_nrdiames AS INT                                   NO-UNDO.
DEF        VAR aux_nrdiamss AS INT                                   NO-UNDO.
DEF        VAR aux_ddlanmto AS INT                                   NO-UNDO.
DEF        VAR aux_qtprepag AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR aux_qtpreapg AS INT     FORMAT "zz9"                  NO-UNDO.
                                                                        
DEF        VAR aux_qtprecal LIKE crapepr.qtprecal                    NO-UNDO.
DEF        VAR aux_qtpreemp LIKE crapepr.qtpreemp                    NO-UNDO.
DEF        VAR aux_qtmesdec LIKE crapepr.qtmesdec                    NO-UNDO.

DEF        VAR aux_vljurmes AS DECIMAL FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF        VAR aux_vljuracu AS DECIMAL FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF        VAR aux_vlsdeved AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF        VAR aux_vlprepag AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR aux_txdjuros AS DECIMAL DECIMALS 7                    NO-UNDO.

DEF        VAR aux_inhst093 AS LOGICAL                               NO-UNDO.

DEF        VAR aux_vldifere AS DECIMAL                               NO-UNDO.

DEF        VAR aux_vlpreemp AS DECIMAL FORMAT "99999999999999.99"    NO-UNDO.
DEF        VAR aux_vldacpmf AS DECIMAL                               NO-UNDO.

DEF        VAR aux_dtmvtolt AS DATE                                  NO-UNDO.

ASSIGN glb_cdprogra = "crps371".

RUN fontes/iniprg.p.
                            
IF   glb_cdcritic > 0 THEN
     RETURN.                  

/* Busca dados da cooperativa */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         QUIT.
     END.

FORM rel_dsempres AT  1 FORMAT "x(20)" LABEL "EMPRESA"
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE SIDE-LABELS WIDTH 132 FRAME f_empresa.

FORM rel_nrseqdeb AT  1 FORMAT "zzz,zz9"            LABEL "ORDEM"
     rel_nrcadast AT  9 FORMAT "zzzz,zzz,9"         LABEL "CADASTRO/DV"
     rel_nrdconta AT 21 FORMAT "zzzz,zzz,9"         LABEL "CONTA/DV"
     rel_nrctremp AT 32 FORMAT "zz,zzz,zz9"         LABEL "CONTRATO"
     rel_nrdocmto AT 43 FORMAT "z,zzz,zz9"          LABEL "DOCUMENTO"
     rel_vlpreemp AT 53 FORMAT "zzzzzzz,zz9.99"     LABEL "PRESTACAO"
     rel_vlprecpm AT 68 FORMAT "z,zzz,zz9.99"       LABEL "PREST + CPMF"
     rel_vltotpre AT 81 FORMAT "zzzz,zzz,zz9.99"    LABEL "VALOR TOTAL"
     rel_nmprimtl AT 97 FORMAT "x(35)"              LABEL "ASSOCIADO"
     WITH NO-BOX NO-ATTR-SPACE DOWN WIDTH 132 FRAME f_emprestimos.

FORM SKIP(1)
     "TOTAIS ==>" AT  1
     tot_qtdassoc AT 13 FORMAT "zzz,zz9"
     tot_qtctremp AT 34 FORMAT "zzz,zz9"
     tot_vlpreemp AT 48 FORMAT "zzz,zzz,zzz,zz9.99"
     tot_vlprecpm AT 77 FORMAT "zzz,zzz,zzz,zz9.99"
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_totais.

{ includes/cpmf.i } 

/*  Carrega tabela das taxas de juros para as linhas de credito  */

FOR EACH craplcr WHERE craplcr.cdcooper = glb_cdcooper  NO-LOCK:

    tab_txdjuros[craplcr.cdlcremp] = craplcr.txdiaria.

END.  /*  Fim do FOR EACH  --  Leitura das taxas de juros para as LC's  */

ASSIGN aux_regexist = FALSE

       rel_dtrefere = INTEGER(STRING(YEAR(glb_dtmvtolt),"9999") +
                              STRING(MONTH(glb_dtmvtolt),"99") +
                              STRING(DAY(glb_dtmvtolt),"99"))

       rel_dtproces = rel_dtrefere

       aux_dtultdia = ((DATE(MONTH(glb_dtmvtolt),28,YEAR(glb_dtmvtolt)) + 4) -
                                   DAY(DATE(MONTH(glb_dtmvtolt),28,
                                            YEAR(glb_dtmvtolt)) + 4))

       rel_dtultdia = aux_dtultdia.

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


FOR EACH crapsol WHERE crapsol.cdcooper = glb_cdcooper  AND
                       crapsol.dtrefere = glb_dtmvtolt  AND
                       crapsol.nrsolici = 94            AND
                       crapsol.insitsol = 1:

    IF   glb_inproces = 1   THEN
         IF   SUBSTRING(crapsol.dsparame,3,1) = "1"   THEN
              NEXT.

    FIND craptab WHERE craptab.cdcooper = glb_cdcooper      AND
                       craptab.nmsistem = "CRED"            AND
                       craptab.tptabela = "GENERI"          AND
                       craptab.cdempres = 0                 AND
                       craptab.cdacesso = "DIADOPAGTO"      AND
                       craptab.tpregist = crapsol.cdempres  
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craptab   THEN
         DO:
             glb_cdcritic = 55.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                               glb_cdprogra + "' --> '" + glb_dscritic +
                               " DIA DO PAGAMENTO DA EMPRESA " +
                               STRING(crapsol.cdempres) +
                               " >> log/proc_batch.log").
             NEXT.  /*  Le proxima solicitacao  */
         END.
    ELSE
         ASSIGN tab_ddmesnov = INTEGER(SUBSTRING(craptab.dstextab,1,2))
                tab_ddpgtoms = INTEGER(SUBSTRING(craptab.dstextab,4,2))
                tab_ddpgtohr = INTEGER(SUBSTRING(craptab.dstextab,7,2))

                aux_dtmesnov = DATE(MONTH(glb_dtmvtolt),tab_ddmesnov,
                                     YEAR(glb_dtmvtolt)).

    ASSIGN glb_cdcritic = 0
           glb_cdempres = 11
           glb_nrdevias = crapsol.nrdevias.

    { includes/cabrel132_2.i }               /* Monta cabecalho do relatorio */

    ASSIGN aux_regexist = TRUE
           aux_flgfirst = TRUE
           aux_flgarqab = FALSE

           aux_nrseqsol = SUBSTRING(STRING(crapsol.nrseqsol,"9999"),3,2)
           aux_contaarq = aux_contaarq + 1
           aux_nmarqimp[aux_contaarq] = "rl/crrl319_" + aux_nrseqsol + ".lst"
           aux_nrdevias[aux_contaarq] = crapsol.nrdevias

           aux_nmarqdeb = "arq/emp" +
                          STRING(MONTH(glb_dtmvtolt),"99") +
                          STRING(YEAR(glb_dtmvtolt),"9999") + "." +
                          STRING(crapsol.cdempres,"99999")    

           aux_nmarqtrf = SUBSTRING(aux_nmarqdeb,5,20)

           aux_intipsai = SUBSTRING(crapsol.dsparame,1,1)

           aux_cdcalcul = INTEGER(SUBSTRING(crapsol.dsparame,17,3))

           tot_vlpreemp = 0                     
           tot_vlprecpm = 0
           tot_qtdassoc = 0
           tot_qtctremp = 0

           rel_nrseqdeb = 0
           arq_nrseqdeb = 0.

    /*  Leitura do cadastro da empresa  */

    /* FIND crapemp OF crapsol NO-LOCK NO-ERROR. */
    FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper      AND
                       crapemp.cdempres = crapsol.cdempres  
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapemp   THEN
         DO:
             glb_cdcritic = 40.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                               glb_cdprogra + "' --> '" + glb_dscritic +
                               " Empresa: " + STRING(crapsol.cdempres,"99999")
                               + " >> log/proc_batch.log").
             RETURN.
         END.

     rel_dsempres = STRING(crapemp.cdempres,"99999") + "-" + crapemp.nmresemp.

     IF   crapemp.tpconven = 2 THEN
          DO:
               aux_dtmvtolt = aux_dtultdia.

               DO WHILE TRUE:

                  aux_dtmvtolt = aux_dtmvtolt + 1.

                  IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtmvtolt)))  OR
                       CAN-FIND(crapfer WHERE 
                                crapfer.cdcooper = glb_cdcooper     AND
                                crapfer.dtferiad = aux_dtmvtolt)    THEN
                       NEXT.

                  LEAVE.
               END.  /* DO WHILE TRUE */
          END.
     ELSE
          aux_dtmvtolt = glb_dtmvtolt.

    rel_cddescto = crapemp.cddescto[1].
    
    /*  Elimina os avisos criados antes do restart  */

    IF   (crapemp.tpdebemp = 2 OR crapemp.tpdebemp = 3) THEN
         FOR EACH crapavs WHERE crapavs.cdcooper = glb_cdcooper         AND
                                crapavs.dtmvtolt = aux_dtmvtolt         AND
                                crapavs.dtrefere = rel_dtultdia         AND
                                crapavs.cdempres = crapsol.cdempres     AND
                                crapavs.cdhistor = 108                  AND
                                crapavs.dtdebito = ?
                                EXCLUSIVE-LOCK
                                TRANSACTION ON ERROR UNDO, RETURN:

             DELETE crapavs.

         END.  /*  Fim do FOR EACH e da transacao  --  Eliminacao dos avisos  */

    /*  Leitura dos emprestimos  */

    FOR EACH crapepr WHERE crapepr.cdcooper = glb_cdcooper          AND
                           crapepr.cdempres = crapsol.cdempres      AND
                           crapepr.dtmvtolt < aux_dtmesnov          AND
                           crapepr.inliquid = 0                     AND
                           crapepr.tpemprst = 0                     AND
                           crapepr.flgpagto = TRUE              
                           USE-INDEX crapepr4 NO-LOCK
                           BREAK BY crapepr.cdempres
                                    BY crapepr.nrdconta:

        IF   FIRST-OF(crapepr.nrdconta)   THEN
             DO:
                 /* FIND crapass OF crapepr USE-INDEX crapass1 NO-LOCK NO-ERROR.
                    */
                 FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                                    crapass.nrdconta = crapepr.nrdconta
                                    NO-LOCK NO-ERROR.
                                    
                 IF   NOT AVAILABLE crapass   THEN
                      DO:
                          glb_cdcritic = 251.
                          RUN fontes/critic.p.
                          UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                            " - " + glb_cdprogra + "' --> '" +
                                            glb_dscritic + " - CONTA = " +
                                            STRING(crapepr.nrdconta,
                                                   "zzzz,zzz,9") +
                                            " >> log/proc_batch.log").
                          RETURN.  /*  Retorna para o crps000  */
                      END.
                 
                 IF   crapass.inpessoa = 1   THEN 
                      DO:
                          FIND crapttl WHERE 
                               crapttl.cdcooper = glb_cdcooper       AND
                               crapttl.nrdconta = crapass.nrdconta   AND
                               crapttl.idseqttl = 1 NO-LOCK NO-ERROR.     
            
                          IF   AVAIL crapttl  THEN
                               ASSIGN tab_cdempres = crapttl.cdempres.
                      END.
                 ELSE
                      DO:
                          FIND crapjur WHERE 
                               crapjur.cdcooper = glb_cdcooper  AND
                               crapjur.nrdconta = crapass.nrdconta
                               NO-LOCK NO-ERROR.
                               
                          IF   AVAIL crapjur  THEN
                               ASSIGN tab_cdempres = crapjur.cdempres.
                      END.    

                 ASSIGN aux_cdtipsfx = crapass.cdtipsfx
                        aux_inisipmf = crapass.inisipmf
                        aux_dtdemiss = crapass.dtdemiss
                        rel_nmprimtl = crapass.nmprimtl
                        rel_nrcadast = crapass.nrcadast
                        rel_nrdconta = crapass.nrdconta
                        rel_cdsecext = crapass.cdsecext
                        rel_cdagenci = crapass.cdagenci
                        rel_vltotpre = 0

                        ass_nrseqdeb = 0

                        epr_qtctremp = 0
                        epr_nrctremp = 0
                        epr_vlpreemp = 0.
             END.

        IF   aux_dtdemiss <> ?   THEN
             NEXT.
        
        IF   tab_inusatab           AND
             crapepr.inliquid = 0   THEN
             aux_txdjuros = tab_txdjuros[crapepr.cdlcremp].
        ELSE
             aux_txdjuros = crapepr.txjuremp.

        /*  Inicialiazacao das variaves para a rotina de calculo - parte 2  */

        ASSIGN aux_nrdconta = crapepr.nrdconta
               aux_nrctremp = crapepr.nrctremp
               aux_vlsdeved = crapepr.vlsdeved
               aux_vljuracu = crapepr.vljuracu
               aux_dtultpag = crapepr.dtultpag

               tab_diapagto = IF CAN-DO("1,3,4",STRING(aux_cdtipsfx))
                                 THEN tab_ddpgtoms
                                 ELSE tab_ddpgtohr

               aux_dtcalcul = aux_dtultdia + tab_diapagto

               rel_nrctremp = crapepr.nrctremp.

        /*  Verifica se o dia de calculo cai num final de semana ou feriado  */

        DO WHILE TRUE:

           IF   WEEKDAY(aux_dtcalcul) = 1   OR
                WEEKDAY(aux_dtcalcul) = 7   THEN
                DO:
                    aux_dtcalcul = aux_dtcalcul + 1.
                    NEXT.
                END.

           FIND crapfer WHERE crapfer.cdcooper = glb_cdcooper   AND
                              crapfer.dtferiad = aux_dtcalcul 
                              NO-LOCK NO-ERROR.

           IF   AVAILABLE crapfer   THEN
                DO:
                    aux_dtcalcul = aux_dtcalcul + 1.
                    NEXT.
                END.

           LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */

        /*  Verifica se a data do pagamento da empresa cai num dia util  */

        IF   glb_inproces         > 2                     AND
             MONTH(glb_dtmvtolt) <> MONTH(glb_dtmvtopr)   THEN
             tab_diapagto = DAY(aux_dtcalcul).
        ELSE
             DO:
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
                                       crapfer.dtferiad = tab_dtcalcul
                                       NO-LOCK NO-ERROR.

                    IF   AVAILABLE crapfer   THEN
                         DO:
                             tab_dtcalcul = tab_dtcalcul + 1.
                             NEXT.
                         END.

                    tab_diapagto = DAY(tab_dtcalcul).

                    LEAVE.

                 END.  /*  Fim do DO WHILE TRUE  */
             END.

        { includes/lelem.i }    /*  Rotina para calculo do saldo devedor  */

        IF   glb_cdcritic > 0   THEN
             DO:
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                   glb_cdprogra + "' --> '" + glb_dscritic +
                                   " CONTA = " + STRING(crapepr.nrdconta,
                                                        "zzzz,zzz,9") +
                                   " CONTRATO = " + STRING(crapepr.nrctremp,
                                                           "zz,zzz,zz9") +
                                   " >> log/proc_batch.log").
                 RETURN.
             END.

        IF   aux_vlsdeved > crapepr.vlpreemp   AND   crapepr.qtpreemp > 1   THEN
             ASSIGN epr_qtctremp               = epr_qtctremp + 1
                    epr_nrctremp[epr_qtctremp] = crapepr.nrctremp
                    epr_vlpreemp[epr_qtctremp] = crapepr.vlpreemp.
        ELSE
        IF   aux_vlsdeved > 0   THEN
             ASSIGN epr_qtctremp               = epr_qtctremp + 1
                    epr_nrctremp[epr_qtctremp] = crapepr.nrctremp
                    epr_vlpreemp[epr_qtctremp] = aux_vlsdeved.

        IF   NOT LAST-OF(crapepr.nrdconta)   THEN
             NEXT.

        DO aux_contador = 1 TO epr_qtctremp:

           ASSIGN rel_vltotpre = rel_vltotpre + epr_vlpreemp[aux_contador]
                  rel_vltotpre = rel_vltotpre + 
                    ROUND(epr_vlpreemp[aux_contador] * tab_txcpmfcc,2) + 0.01
                  rel_nrseqdeb = rel_nrseqdeb + 1
                  rel_nrctremp = epr_nrctremp[aux_contador]
                  rel_vlpreemp = epr_vlpreemp[aux_contador]
                  rel_nrdocmto = rel_nrctremp.

           IF   CAN-DO("1,4,5",aux_intipsai)  THEN
                DO:                                         
                    IF   aux_flgfirst THEN
                         DO:
                             OUTPUT STREAM str_3 TO VALUE(aux_nmarqdeb).

                             aux_flgarqab = TRUE.

                             PUT STREAM str_3 "DEBEM"
                                 crapemp.sgempres FORMAT "x"
                                 rel_dtproces     FORMAT "99999999"
                                 rel_dtrefere     FORMAT "99999999"
                                 rel_nrversao     FORMAT "999"
                                 crapsol.cdempres FORMAT "99999"  
                                 FILL(" ",61)     FORMAT "x(61)" SKIP.
                         END.

                    IF   aux_contador = epr_qtctremp   THEN
                         DO:
                             arq_nrseqdeb = arq_nrseqdeb + 1.

                             PUT STREAM str_3
                                 crapsol.cdempres   FORMAT "99999" 
                                 rel_nrcadast       FORMAT "9999999"
                                 rel_cddescto       FORMAT "999"
                                 rel_espvazio       FORMAT "x"
                                 rel_dtrefere       FORMAT "99999999"
                                 arq_nrseqdeb       FORMAT "99999"
                                 rel_espvazio       FORMAT "x"
                                 rel_nmsistem       FORMAT "x(2)"
                                 rel_vltotpre * 100 FORMAT "9999999999999999"
                                 rel_espvazio       FORMAT "x(1)" 
                                 '"' 
                                 rel_nmprimtl   FORMAT "x(40)"
                                 '"'
                                 SKIP.
                         END.                   
                END.                                     

           IF   (crapemp.tpdebemp = 2 OR crapemp.tpdebemp = 3) THEN
                DO TRANSACTION ON ERROR UNDO, RETURN:
                   
                   CREATE crapavs.
                   ASSIGN ass_nrseqdeb     = ass_nrseqdeb + 1
                          crapavs.dtmvtolt = aux_dtmvtolt
                          crapavs.nrdconta = rel_nrdconta
                          crapavs.nrdocmto = rel_nrdocmto
                          crapavs.vllanmto = rel_vlpreemp
                          crapavs.cdagenci = rel_cdagenci
                          crapavs.tpdaviso = 1
                          crapavs.cdhistor = 108
                          crapavs.dtdebito = ?
                          crapavs.cdsecext = rel_cdsecext
                          crapavs.cdempres = crapepr.cdempres
                          crapavs.cdempcnv = crapepr.cdempres
                          crapavs.insitavs = 0
                          crapavs.dtrefere = rel_dtultdia
                          crapavs.vldebito = 0
                          crapavs.vlestdif = 0
                          crapavs.nrseqdig = ass_nrseqdeb
                          crapavs.flgproce = false
                          crapavs.cdcooper = glb_cdcooper.
                   VALIDATE crapavs.

                END.  /*  Fim da transacao  */

           IF   CAN-DO("2,3,4,5",aux_intipsai)   THEN
                DO:
                    IF   aux_flgfirst   THEN
                         DO:
                             OUTPUT STREAM str_2 TO
                                    VALUE(aux_nmarqimp[aux_contaarq])
                                          PAGED PAGE-SIZE 84.

                             VIEW STREAM str_2 FRAME f_cabrel132_2.

                             aux_flgarqab = TRUE.

                             DISPLAY STREAM str_2
                                     rel_dsempres WITH FRAME f_empresa.
                         END.

                    /*  Tratamento especial para a CECRISACRED */

                    ASSIGN aux_vldacpmf = 
                              ROUND(rel_vlpreemp * tab_txcpmfcc,2) + 0.01
                           rel_vlprecpm = rel_vlpreemp + aux_vldacpmf
                           rel_vltotpre = rel_vltotpre.

                    DISPLAY STREAM str_2
                            rel_nrseqdeb rel_nrcadast rel_nrdconta
                            rel_nrctremp rel_nrdocmto rel_vlpreemp
                            rel_vlprecpm
                            rel_vltotpre WHEN aux_contador = epr_qtctremp
                            rel_nmprimtl
                            WITH FRAME f_emprestimos.

                    DOWN STREAM str_2 WITH FRAME f_emprestimos.

                    IF   LINE-COUNTER(str_2) > PAGE-SIZE(str_2)   THEN
                         DO:
                             PAGE STREAM str_2.

                             DISPLAY STREAM str_2
                                     rel_dsempres WITH FRAME f_empresa.
                         END.

                    ASSIGN tot_vlpreemp = tot_vlpreemp + rel_vlpreemp
                           tot_vlprecpm = tot_vlprecpm + rel_vlprecpm
                           tot_qtctremp = tot_qtctremp + 1
                           tot_qtdassoc = IF aux_contador = epr_qtctremp
                                             THEN tot_qtdassoc + 1
                                             ELSE tot_qtdassoc.
                END.

           aux_flgfirst = FALSE.

        END.  /*  Fim do DO .. TO  */

    END.  /*  Fim do FOR EACH -- Leitura dos emprestimos  */

    IF   aux_flgarqab   THEN
         DO:                      
             IF   CAN-DO("1,4,5",aux_intipsai) THEN
                  DO:
                      PUT STREAM str_3
                           "9 999999 99999999 999999999,99 99             " 
                           "                                           "
                            SKIP.

                      OUTPUT STREAM str_3 CLOSE.

                      /* Move para diretorio converte para utilizar na BO */
                      UNIX SILENT VALUE 
                                  ("cp " + aux_nmarqdeb + " /usr/coop/" +
                                   crapcop.dsdircop + "/converte" + 
                                   " 2> /dev/null").

                      /* envio de email */ 
                      RUN sistema/generico/procedures/b1wgen0011.p
                          PERSISTENT SET b1wgen0011.
             
                      RUN enviar_email IN b1wgen0011
                                (INPUT glb_cdcooper,
                                 INPUT glb_cdprogra,
                                 INPUT crapemp.dsdemail,
                                 INPUT '"Arquivo de desconto de emprestimos ' +
                                       CAPS(crapcop.nmrescop) + '"', 
                                 INPUT SUBSTRING(aux_nmarqdeb, 5),
                                 INPUT false).
                                   
                      DELETE PROCEDURE b1wgen0011.

                      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                                   " - "                                  +
                                   glb_cdprogra + "' --> '" + "ARQUIVO "  +
                                   " /usr/coop/"                          +
                                   crapcop.dsdircop + "/"                 + 
                                   aux_nmarqdeb + " ENVIADO PARA "        +
                                   crapemp.dsdemail                       +
                                   " >> log/proc_batch.log").

                      UNIX SILENT VALUE("cp " + aux_nmarqdeb + " salvar " +
                                        "2> /dev/null").
                  END.
                                         
             IF   CAN-DO("2,3,4,5",aux_intipsai)   THEN
                  DO:
                      IF   LINE-COUNTER(str_2) > 82   THEN
                           DO:
                               PAGE STREAM str_2.

                               DISPLAY STREAM str_2
                                       rel_dsempres WITH FRAME f_empresa.
                           END.

                      DISPLAY STREAM str_2
                              tot_qtdassoc tot_qtctremp tot_vlpreemp
                              tot_vlprecpm WITH FRAME f_totais.

                      OUTPUT STREAM str_2 CLOSE.

                      ASSIGN glb_nrcopias = 1
                             glb_nmformul = IF aux_nrdevias[aux_contaarq] > 1
                                THEN STRING(aux_nrdevias[aux_contaarq]) + "vias"
                                ELSE " "
                             glb_nmarqimp = aux_nmarqimp[aux_contaarq].

                      RUN fontes/imprim.p.           
                  END.
         END.

    DO TRANSACTION ON ERROR UNDO, RETURN:

       crapsol.insitsol = 2. 

       DO WHILE TRUE:

          /* FIND crapemp OF crapsol EXCLUSIVE-LOCK NO-ERROR NO-WAIT. */
          FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper        AND
                             crapemp.cdempres = crapsol.cdempres
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF   NOT AVAILABLE crapemp   THEN
               IF   LOCKED crapemp   THEN
                    DO:
                        PAUSE 2 NO-MESSAGE.
                        NEXT.
                    END.
               ELSE
                    DO:
                        glb_cdcritic = 40.
                        RUN fontes/critic.p.
                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                          " - " + glb_cdprogra +
                                          "' --> '" + glb_dscritic +
                                          " Empresa: " +
                                          STRING(crapavs.cdempres,"99999") +
                                          " >> log/proc_batch.log").
                        RETURN.
                    END.

          crapemp.inavsemp = 1.

          LEAVE.

       END.  /*  Fim do DO WHILE TRUE   */

    END.  /*  Fim da transacao  */                               

END.  /*  Fim do FOR EACH  -- Leitura das solicitacoes --  */

IF   NOT aux_regexist   THEN
     DO:
         glb_cdcritic = 157.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" + glb_dscritic +
                           " - SOL094" + " >> log/proc_batch.log").
         RETURN.
     END.

RUN fontes/fimprg.p.

/* .......................................................................... */


