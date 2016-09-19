/* ..........................................................................

   Programa: fontes/crps415.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio          
   Data    : Outubro/2004                       Ultima atualizacao: 04/03/2015
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 097.
               Processar as solicitacoes de geracao dos debitos de emprestimos.
               Emite relatorio 375

   Alteracoes: 16/12/2004 - Correcao do calculo do numero da parcela (Julio)

               09/02/2005 - Se o saldo devedor menor que parcela, mandar
                            somente o valor do saldo devedor e incluir no
                            arquivo somente emprestimos com data de pagamento 
                            para o proximo mes (Julio)

               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               03/10/2005 - Alterado numero de copias para 2 (Diego).

               13/01/2006 - Gerar arquivo de retorno para empresas 9,40 e 41
                            da CREDITEXTIL. (Julio).

               17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               22/05/2006 - Trocado a extencao do arquivo enviado de .txt para
                            .dat, e o parametro de envio do e-mail de 
                            --attach para --binary (Julio)

               30/08/2006 - Nao gerar registro com numero parcela maior do que 
                            a qtd total. Caso for superior entao o numero da
                            parcela sera igual ao "total" (Julio)
                            
               25/03/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)
                            
               07/04/2008 - Alterado formato dos campos "crapepr.qtpreemp" e
                            "aux_qtprepag" de "99" para "zz9". Ajustados os 
                             campos "rel_dsparcel" para 7 posicoes e o campo
                             "crapass.nmprimtl" para 29 posicoes
                          - Kbase IT Solutions - Paulo Ricardo Maciel
                                             
               13/06/2008 - Mover arquivo aux_nmarqimp[aux_contaarq] para
                            diretorio /converte (Diego).

               11/08/2008 - Acerto na geracao de arquivo para o diretorio
                            integra da Creditextil (Julio)

               27/08/2008 - Efetuar output stream str_1 antes de enviar o email
                            pois o relatorio estava sendo enviado incompleto
                            (David).
                            
               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
               
               18/12/2008 - Postar arquivo de retorno da empresa 36-BRANDILI 
                            no diretorio integra;
                          - Excluida mensagem de log no envio de e-mail, pois 
                            ja eh feita na BO 11 (Diego).
               
               14/04/2009 - Validar geracao de arquivo com campo flgarqrt 
                           (Fernando).
               
               09/03/2012 - Declarado variaveis necessarias para utilizacao
                            da include lelem.i (Tiago)
                            
               04/09/2013 - Incluido o CNPJ da empresa no arquivo e 
                            desconsiderados os colaboradores que mudaram de 
                            empresa (Carlos).
                            
               25/06/2014 - Alterando o tamanho do extent da váriavel tab_txdjuros
                            de 999 para 1900. Chamado: 167886 Data: 12/06/2014
                            Jéssica(DB1).
                            
               14/01/2015 - Alterado variavel tab_txdjuros que era um EXTENT
                            para uma temp-table pois estava ocasionando 
                            erros na execucao e estouro do array por ele
                            ter sido indexado pelo cdlcremp 
                            SD 242368 (Tiago/Gielow).
               
               22/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714)
                            
               04/03/2015 - Ajuste na verificacao do dia que o crps ira rodar.
                            (James)
............................................................................. */

DEF STREAM str_1.  /*  Para a opcao de saida como relatorio  */

{ includes/var_batch.i }

{ includes/var_cpmf.i } 

{ includes/var_cnab.i "NEW" }
DEF        VAR b1wgen0011   AS HANDLE                                NO-UNDO.

DEF        VAR rel_nmresemp     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.

DEF        VAR rel_nmempres     AS CHAR                              NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR rel_dsempres AS CHAR                                  NO-UNDO.
DEF        VAR rel_nrcadast AS INT                                   NO-UNDO.
DEF        VAR rel_nrdconta AS INT                                   NO-UNDO.
DEF        VAR rel_nrctremp AS INT                                   NO-UNDO.
DEF        VAR rel_nrdocmto AS INT                                   NO-UNDO.
DEF        VAR rel_cdagenci AS INT                                   NO-UNDO.
DEF        VAR rel_vlpreemp AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vltotpre AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vlprecpm AS DECIMAL                               NO-UNDO.
DEF        VAR rel_nmprimtl AS CHAR                                  NO-UNDO.

DEF        VAR rel_nrseqdeb AS INT                                   NO-UNDO.
DEF        VAR rel_dtultdia AS DATE                                  NO-UNDO.

DEF        VAR tot_qtdassoc AS INT                                   NO-UNDO.
DEF        VAR tot_qtctremp AS INT                                   NO-UNDO.
DEF        VAR tot_vlpreemp AS DECIMAL                               NO-UNDO.
DEF        VAR tot_vlprecpm AS DECIMAL                               NO-UNDO.

DEF        VAR epr_qtctremp AS INT                                   NO-UNDO.
DEF        VAR epr_nrctremp AS INT     EXTENT 99                     NO-UNDO.
DEF        VAR epr_vlpreemp AS DECIMAL EXTENT 99                     NO-UNDO.

DEF        VAR tab_dtcalcul AS DATE                                  NO-UNDO.
DEF        VAR tab_diapagto AS INT                                   NO-UNDO.
DEF        VAR tab_inusatab AS LOGICAL                               NO-UNDO.

DEF        VAR tab_ddpgtohr AS INT                                   NO-UNDO.
DEF        VAR tab_ddpgtoms AS INT                                   NO-UNDO.
DEF        VAR tab_ddmesnov AS INT                                   NO-UNDO.

DEF        VAR arq_nrseqdeb AS INT                                   NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR    FORMAT "x(20)" EXTENT 99      NO-UNDO.
DEF        VAR aux_nrdevias AS INT     FORMAT "z9"    EXTENT 99      NO-UNDO.

DEF        VAR aux_nmarqdeb AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_nmarqtrf AS CHAR                                  NO-UNDO.

DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgarqab AS LOGICAL                               NO-UNDO.

DEF        VAR aux_contaarq AS INT                                   NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_cdtipsfx AS INT                                   NO-UNDO.
DEF        VAR aux_inisipmf AS INT                                   NO-UNDO.

DEF        VAR aux_dtcalcul AS DATE                                  NO-UNDO.
DEF        VAR aux_dtultdia AS DATE                                  NO-UNDO.
DEF        VAR aux_dtmesant AS DATE                                  NO-UNDO.
DEF        VAR aux_dtultpag AS DATE                                  NO-UNDO.
DEF        VAR aux_dtmesnov AS DATE                                  NO-UNDO.
DEF        VAR aux_dtdemiss AS DATE                                  NO-UNDO.

DEF        VAR aux_inliquid AS INT                                   NO-UNDO.
DEF        VAR aux_nrdconta AS INT                                   NO-UNDO.
DEF        VAR aux_nrctremp AS INT                                   NO-UNDO.
DEF        VAR aux_nrultdia AS INT                                   NO-UNDO.
DEF        VAR aux_nrdiacal AS INT                                   NO-UNDO.
DEF        VAR aux_nrdiames AS INT                                   NO-UNDO.
DEF        VAR aux_nrdiamss AS INT                                   NO-UNDO.
DEF        VAR aux_ddlanmto AS INT                                   NO-UNDO.
DEF        VAR aux_qtprepag AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR aux_qtpreapg AS INT     FORMAT "zz9"                  NO-UNDO.
                                                                             
DEF        VAR aux_vlpreemp LIKE crapepr.vlpreemp                    NO-UNDO.
DEF        VAR aux_qtprecal LIKE crapepr.qtprecal                    NO-UNDO.
DEF        VAR aux_qtpreemp LIKE crapepr.qtpreemp                    NO-UNDO.
DEF        VAR aux_qtmesdec LIKE crapepr.qtmesdec                    NO-UNDO.

DEF        VAR aux_vljurmes AS DECIMAL FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF        VAR aux_vljuracu AS DECIMAL FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF        VAR aux_vlsdeved AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF        VAR aux_vlprepag AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR aux_txdjuros AS DECIMAL DECIMALS 7                    NO-UNDO.

DEF        VAR aux_inhst093 AS LOGICAL                               NO-UNDO.

DEF        VAR aux_dtmvtolt AS DATE                                  NO-UNDO.
DEF        VAR aux_hrtransa AS CHARACTER                             NO-UNDO.

DEF        VAR rel_dsparcel   AS CHARACTER FORMAT "x(5)"             NO-UNDO.
DEF        VAR aux_nmarqsai   AS CHARACTER                           NO-UNDO.
DEF        VAR aux_cdempres   AS INTEGER                             NO-UNDO.
DEF        VAR aux_dtpromes   AS DATE                                NO-UNDO.
DEF        VAR aux_cdempres_2 AS INT                                 NO-UNDO.

DEF TEMP-TABLE tt-txdjuros    NO-UNDO
    FIELD   cdlcremp    LIKE    craplcr.cdlcremp
    FIELD   txdiaria    LIKE    craplcr.txdiaria.

DEF TEMP-TABLE tt-empresas    NO-UNDO
    FIELD   cdempres    LIKE    crapemp.cdempres.

ASSIGN glb_cdprogra = "crps415".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

FORM rel_dsempres AT  1 FORMAT "x(20)" LABEL "EMPRESA"
     "TIPO DE DEBITO: 1 - EM REAIS" AT 49
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE SIDE-LABELS WIDTH 132 FRAME f_empresa.

FORM rel_nrseqdeb     AT  1 FORMAT "zzz,zz9"            LABEL "ORDEM"
     crapass.nrcadast AT  9 FORMAT "zzzz,zzz,9"         LABEL "CADASTRO/DV"
     crapepr.nrdconta AT 21 FORMAT "zzzzz,zzz,9"        LABEL "CONTA/DV"
     crapepr.nrctremp AT 32 FORMAT "zz,zzz,zz9"          LABEL "CONTRATO"
     crapepr.vlpreemp AT 43 FORMAT "z,zzz,zzz,zz9.99"   LABEL "PRESTACAO"
     aux_vlsdeved     AT 60 FORMAT "zzz,zzz,zz9.99-"    LABEL "SALDO DEVEDOR"
     crapepr.vlemprst AT 76 FORMAT "zzzz,zzz,zz9.99"    LABEL "VALOR EMPRESTIMO"
     rel_dsparcel     AT 94 FORMAT "x(7)"               LABEL "PARC."
     crapass.nmprimtl AT 102 FORMAT "x(29)"             LABEL "ASSOCIADO"
     WITH NO-BOX NO-ATTR-SPACE DOWN NO-LABEL WIDTH 132 FRAME f_consigemprst.

FORM SKIP(1)
     "TOTAIS ==>" AT  1
     tot_qtdassoc AT 13 FORMAT "zzz,zz9"
     tot_qtctremp AT 34 FORMAT "zzz,zz9"
     tot_vlpreemp AT 42 FORMAT "z,zzz,zzz,zz9.99"
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_consigtotais.

{ includes/cpmf.i } 

/* Funcao utilizada para calcular a data do termino do contrato */
FUNCTION f_DataFim RETURN DATE(INPUT par_dtinicio AS DATE,
                               INPUT par_qtpreemp AS INTEGER):

  DEFINE VARIABLE fun_nrmesfim AS INTEGER                       NO-UNDO.   
  DEFINE VARIABLE fun_nranofim AS INTEGER                       NO-UNDO.   
                           
  fun_nrmesfim = MONTH(par_dtinicio) + par_qtpreemp.  
  fun_nranofim = YEAR(par_dtinicio) + TRUNCATE(fun_nrmesfim / 12, 0).

  IF   fun_nrmesfim MODULO 12 > 0   THEN
       fun_nrmesfim = fun_nrmesfim MODULO 12.
  ELSE
       DO:
           fun_nrmesfim = 12.
           fun_nranofim = fun_nranofim - 1.
       END.
       
  RETURN DATE(fun_nrmesfim, DAY(par_dtinicio), fun_nranofim).

END.                               

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         RETURN.
     END.
 
EMPTY TEMP-TABLE tt-empresas.

FOR EACH crapemp FIELDS(cdempres dtfchfol)
                 WHERE crapemp.cdcooper = glb_cdcooper AND 
                       crapemp.indescsg = 2            AND 
                       crapemp.dtfchfol > 0            
                       NO-LOCK:

    IF (crapemp.dtfchfol = DAY(glb_dtmvtolt)) OR
       
       /* Data do fechamento eh meio de mes e nao e dia util OU */
       (crapemp.dtfchfol < DAY(glb_dtmvtopr) AND
        crapemp.dtfchfol > DAY(glb_dtmvtolt)) OR
       
       /* eh virada de mes E */
       (DAY(glb_dtmvtolt) > DAY(glb_dtmvtopr) AND

       /* data do fechamento eh final de mes e nao eh dia util OU */ 
       ((crapemp.dtfchfol > DAY(glb_dtmvtopr) AND
         crapemp.dtfchfol > DAY(glb_dtmvtolt)) OR
       
       /* data fechamento eh inicio do mes e nao eh dia util */   
       (crapemp.dtfchfol < DAY(glb_dtmvtopr) AND
        crapemp.dtfchfol < DAY(glb_dtmvtolt))))  THEN
       DO:  
           CREATE tt-empresas.
           ASSIGN tt-empresas.cdempres = crapemp.cdempres.
           VALIDATE tt-empresas.

       END.

END. /* END FOR EACH crapemp */
     
/* Verifica se possui empresa para gerar arquivo */
IF NOT TEMP-TABLE tt-empresas:HAS-RECORDS THEN
   DO:
        RUN fontes/fimprg.p.
        RETURN.

   END. /* END IF TEMP-TABLE tt-empresas:HAS-RECORDS */
      
/*  Carrega tabela das taxas de juros para as linhas de credito  */
FOR EACH craplcr WHERE craplcr.cdcooper = glb_cdcooper NO-LOCK:

    CREATE tt-txdjuros.
    ASSIGN tt-txdjuros.cdlcremp = craplcr.cdlcremp
           tt-txdjuros.txdiaria = craplcr.txdiaria.

    VALIDATE tt-txdjuros.

END.  /*  Fim do FOR EACH  --  Leitura das taxas de juros para as LC's  */

ASSIGN aux_regexist = FALSE
       aux_dtultdia = ((DATE(MONTH(glb_dtmvtolt),28,YEAR(glb_dtmvtolt)) + 4) -
                                   DAY(DATE(MONTH(glb_dtmvtolt),28,
                                            YEAR(glb_dtmvtolt)) + 4))
       rel_dtultdia = aux_dtultdia
       aux_dtpromes = DATE(MONTH(glb_dtmvtolt), 01, YEAR(glb_dtmvtolt)) + 32
       aux_dtpromes = ((DATE(MONTH(aux_dtpromes),28,YEAR(aux_dtpromes)) + 4) -
                                   DAY(DATE(MONTH(aux_dtpromes),28,
                                            YEAR(aux_dtpromes)) + 4)).

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

FOR EACH tt-empresas NO-LOCK:

    ASSIGN aux_cdempres = tt-empresas.cdempres.
    
    FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                       craptab.nmsistem = "CRED"        AND
                       craptab.tptabela = "GENERI"      AND
                       craptab.cdempres = 0             AND
                       craptab.cdacesso = "DIADOPAGTO"  AND
                       craptab.tpregist = aux_cdempres  NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craptab   THEN
         DO:
             glb_cdcritic = 55.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                               glb_cdprogra + "' --> '" + glb_dscritic +
                               " DIA DO PAGAMENTO DA EMPRESA " +
                               STRING(aux_cdempres) +
                               " >> log/proc_batch.log").
             NEXT.  /*  Le proxima solicitacao  */
         END.
    ELSE
         ASSIGN tab_ddpgtoms = INTEGER(SUBSTRING(craptab.dstextab,4,2))
                tab_ddpgtohr = INTEGER(SUBSTRING(craptab.dstextab,7,2)).

    ASSIGN glb_cdcritic = 0
           glb_cdempres = aux_cdempres
           glb_nrdevias = 1.

    { includes/cabrel132_1.i }               /* Monta cabecalho do relatorio */

    ASSIGN aux_regexist = TRUE
           aux_flgfirst = TRUE
           aux_flgarqab = FALSE

           aux_contaarq = aux_contaarq + 1
           aux_nmarqimp[aux_contaarq] = "rl/crrl375_" +
                                        STRING(aux_cdempres,"99999") + ".lst"
           aux_nrdevias[aux_contaarq] = glb_nrdevias

           aux_nmarqdeb = "arq/emp" +
                          STRING(MONTH(glb_dtmvtolt),"99") +
                          STRING(YEAR(glb_dtmvtolt),"9999") + "." +
                          STRING(aux_cdempres,"99999")

           aux_nmarqtrf = SUBSTRING(aux_nmarqdeb,5,20)

           tot_vlpreemp = 0
           tot_vlprecpm = 0
           tot_qtdassoc = 0
           tot_qtctremp = 0
           rel_nrseqdeb = 0
           arq_nrseqdeb = 0.

    /*  Leitura do cadastro da empresa  */

    FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper  AND
                       crapemp.cdempres = aux_cdempres  NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapemp   THEN
         DO:
             glb_cdcritic = 40.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                               glb_cdprogra + "' --> '" + glb_dscritic +
                               " Empresa: " + STRING(aux_cdempres,"99999") +
                               " >> log/proc_batch.log").
             RETURN.
         END.

    ASSIGN rel_dsempres = STRING(crapemp.cdempres,"99999") + "-" +
                          crapemp.nmresemp
           aux_dtmesnov = DATE(MONTH(glb_dtmvtolt), crapemp.dtfchfol,
                               YEAR(glb_dtmvtolt)).

     IF   crapemp.tpconven = 2 THEN
          DO:
               aux_dtmvtolt = aux_dtultdia.

               DO WHILE TRUE:

                  aux_dtmvtolt = aux_dtmvtolt + 1.

                  IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtmvtolt))) OR
                       CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper
                                          AND crapfer.dtferiad = aux_dtmvtolt)
                       THEN
                       NEXT.

                  LEAVE.
               END.  /* DO WHILE TRUE */
          END.
     ELSE
          aux_dtmvtolt = glb_dtmvtolt.

    /*  Leitura dos emprestimos  */

    FOR EACH crapepr WHERE crapepr.cdcooper  = glb_cdcooper   AND
                           crapepr.cdempres  = aux_cdempres   AND
                           crapepr.dtmvtolt <= aux_dtmesnov   AND
                           crapepr.dtdpagto <= aux_dtpromes   AND
                           crapepr.inliquid  = 0              AND
                           crapepr.tpdescto  = 2              NO-LOCK
                           BREAK BY crapepr.cdempres
                                    BY crapepr.nrdconta:

        /*FIND crapass OF crapepr NO-LOCK NO-ERROR.*/     
        FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                           crapass.nrdconta = crapepr.nrdconta
                           NO-LOCK NO-ERROR.

        IF   AVAILABLE crapass  THEN
             DO:
                 IF   crapass.inpessoa = 1   THEN 
                      DO:
                          FIND crapttl WHERE 
                               crapttl.cdcooper = glb_cdcooper       AND
                               crapttl.nrdconta = crapass.nrdconta   AND
                               crapttl.idseqttl = 1 NO-LOCK NO-ERROR.
                     
                          IF   AVAIL crapttl  THEN
                               ASSIGN aux_cdempres_2 = crapttl.cdempres.
                      END.
                 ELSE
                      DO:
                          FIND crapjur WHERE 
                               crapjur.cdcooper = glb_cdcooper  AND
                               crapjur.nrdconta = crapass.nrdconta
                               NO-LOCK NO-ERROR.
                    
                          IF   AVAIL crapjur  THEN
                               ASSIGN aux_cdempres_2 = crapjur.cdempres.
                      END.
             END.

        IF   NOT AVAILABLE crapass   THEN
             DO:
                 glb_cdcritic = 251.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                   " - " + glb_cdprogra + "' --> '" +
                                   glb_dscritic + " - CONTA = " +
                                   STRING(crapepr.nrdconta, "zzzz,zzz,9") +
                                   " >> log/proc_batch.log").
                 RETURN.  /*  Retorna para o crps000  */
             END.

        FIND crawepr WHERE crawepr.cdcooper = glb_cdcooper      AND
                           crawepr.nrctremp = crapepr.nrctremp  AND
                           crawepr.nrdconta = crapepr.nrdconta         
                           NO-LOCK NO-ERROR.
                 
        IF   NOT AVAILABLE crawepr   THEN
             DO:
                 glb_cdcritic = 510.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                   " - " + glb_cdprogra + "' --> '" +
                                   glb_dscritic + " - CONTA = " +
                                   STRING(crapepr.nrdconta, "zzzz,zzz,9") +
                                   " >> log/proc_batch.log").
                 RETURN.  /*  Retorna para o crps000  */
             END.
 
         /* Desconsiderar os colaboradores que mudaram de empresa */
         IF  crapepr.cdempres <> aux_cdempres_2 THEN
             NEXT.

         IF   FIRST-OF(crapepr.nrdconta)   THEN
             DO:                    
                 ASSIGN aux_cdtipsfx = crapass.cdtipsfx
                        aux_inisipmf = crapass.inisipmf
                        aux_dtdemiss = crapass.dtdemiss
                        rel_nmprimtl = crapass.nmprimtl
                        rel_nrcadast = crapass.nrcadast
                        rel_nrdconta = crapass.nrdconta
                        rel_cdagenci = crapass.cdagenci
                        rel_vltotpre = 0
                        epr_qtctremp = 0
                        epr_nrctremp = 0
                        epr_vlpreemp = 0.

             END.

        IF  aux_dtdemiss <> ?   THEN
            NEXT.
             
        IF  tab_inusatab   AND   crapepr.inliquid = 0   THEN
            DO:
                FIND   tt-txdjuros 
                 WHERE tt-txdjuros.cdlcremp = crapepr.cdlcremp
                       NO-LOCK NO-ERROR.

                IF AVAIL(tt-txdjuros) THEN
                   aux_txdjuros = tt-txdjuros.txdiaria.
                ELSE
                    DO:
                        glb_cdcritic = 347.
                        RUN fontes/critic.p.
                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                          " - " + glb_cdprogra + "' --> '" +
                                          glb_dscritic + " - CONTA = " +
                                          STRING(crapepr.nrdconta, "zzzz,zzz,9") +
                                          " >> log/proc_batch.log").
                        RETURN.  /*  Retorna para o crps000  */
                    END.
            END.                                               
        ELSE
             aux_txdjuros = crapepr.txjuremp.

        /*  Inicialiazacao das variaves para a rotina de calculo - parte 2  */

        ASSIGN aux_nrdconta = crapepr.nrdconta
               aux_nrctremp = crapepr.nrctremp
               aux_vlsdeved = crapepr.vlsdeved
               aux_vljuracu = crapepr.vljuracu
               aux_dtultpag = crapepr.dtultpag
               tab_diapagto = IF CAN-DO("1,3,4",STRING(aux_cdtipsfx)) THEN 
                                 tab_ddpgtoms
                              ELSE 
                                 tab_ddpgtohr
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

           FIND crapfer WHERE crapfer.cdcooper = glb_cdcooper  AND
                              crapfer.dtferiad = aux_dtcalcul  NO-LOCK NO-ERROR.

           IF   AVAILABLE crapfer   THEN
                DO:
                    aux_dtcalcul = aux_dtcalcul + 1.
                    NEXT.
                END.

           LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */

        /*  Verifica se a data do pagamento da empresa cai num dia util  */

        tab_dtcalcul = DATE(MONTH(glb_dtmvtolt), tab_diapagto,
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

        IF   aux_vlsdeved > crapepr.vlpreemp   THEN
             ASSIGN epr_qtctremp               = epr_qtctremp + 1
                    epr_nrctremp[epr_qtctremp] = crapepr.nrctremp
                    epr_vlpreemp[epr_qtctremp] = crapepr.vlpreemp.
        ELSE
        IF   aux_vlsdeved > 0   THEN
             ASSIGN epr_qtctremp               = epr_qtctremp + 1
                    epr_nrctremp[epr_qtctremp] = crapepr.nrctremp
                    epr_vlpreemp[epr_qtctremp] = aux_vlsdeved.
        ELSE
        IF   aux_vlsdeved <= 0   THEN
             NEXT.

        IF   aux_flgfirst   THEN
             DO:
                 OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp[aux_contaarq])
                                        PAGED PAGE-SIZE 84.

                 VIEW STREAM str_1 FRAME f_cabrel132_1.

                 DISPLAY STREAM str_1 rel_dsempres WITH FRAME f_empresa.
             END.

        ASSIGN rel_nrseqdeb = rel_nrseqdeb + 1
               aux_qtprepag = INT(TRUNC(lem_qtprecal,0)) + 
                              INT(TRUNC(crapepr.qtprecal,0)) 
               rel_dsparcel = STRING(aux_qtprepag + 1, "zz9") + "/" +
                              STRING(crapepr.qtpreemp, "zz9").
                          
        DISPLAY STREAM str_1 rel_nrseqdeb     crapass.nrcadast 
                             crapepr.nrdconta
                             crapepr.nrctremp 
                             epr_vlpreemp[epr_qtctremp] @ crapepr.vlpreemp
                             aux_vlsdeved     crapepr.vlemprst 
                             rel_dsparcel     crapass.nmprimtl 
                             WITH FRAME f_consigemprst.

        DOWN STREAM str_1 WITH FRAME f_consigemprst.

        IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
             DO:
                 PAGE STREAM str_1.

                 DISPLAY STREAM str_1 rel_dsempres WITH FRAME f_empresa.
             END.

        ASSIGN tot_vlpreemp = tot_vlpreemp + epr_vlpreemp[epr_qtctremp]
               tot_qtctremp = tot_qtctremp + 1
               tot_qtdassoc = IF   FIRST-OF(crapepr.nrdconta)   THEN 
                                   tot_qtdassoc + 1
                              ELSE 
                                   tot_qtdassoc.

        IF   aux_flgfirst   THEN  /*  Formato Padrao CNAB  */
             DO:
                 aux_flgarqab = TRUE.

                 /* Atualiza Sequencia do Arquivo no crapemp */
                 
                 FIND CURRENT crapemp EXCLUSIVE-LOCK.         

                 ASSIGN crapemp.nrarqepr = crapemp.nrarqepr + 1.
                 
                 FIND CURRENT crapemp NO-LOCK.                   
                        
                 CREATE cratarq. /*registro 0*/
                 ASSIGN cratarq.cdbccxlt = 997 
                        cratarq.nrdolote = 0
                        cratarq.tpregist = 0
                        cratarq.inpessoa = 2 
                        cratarq.nrcpfcgc = crapemp.nrdocnpj
                        cratarq.cdagenci = 0
                        cratarq.nrdconta = 0
                        cratarq.nrdigcta = 0
                        cratarq.nmprimtl = crapemp.nmresemp
                        cratarq.nmrescop = crapcop.nmrescop
                        cratarq.cdremess = 2
                        cratarq.dtmvtolt = glb_dtmvtolt
                        aux_hrtransa = STRING(TIME,"HH:MM:SS")
                        aux_hrtransa = REPLACE(aux_hrtransa,":","")
                        cratarq.hrtransa = INTEGER(aux_hrtransa)
                        cratarq.nrseqarq = crapemp.nrarqepr. 

                 CREATE cratarq.             /* registro 1 */
                 ASSIGN cratarq.cdbccxlt = 997 
                        cratarq.nrdolote = 1 
                        cratarq.tpregist = 1
                        cratarq.tpservco = 12
                        cratarq.dtmesref = MONTH(glb_dtmvtolt)
                        cratarq.dtanoref = YEAR(glb_dtmvtolt)
                        cratarq.inpessoa = 2
                        cratarq.nrcpfcgc = crapemp.nrdocnpj
                        cratarq.cdempres = crapemp.cdempres
                        cratarq.cdconven = "1"
                        cratarq.cdagenci = 0
                        cratarq.nrdconta = 0
                        cratarq.nrdigcta = 0
                        cratarq.nmresemp = crapemp.nmresemp
                        cratarq.nrseqarq = 1. 
                         
                 aux_flgfirst = FALSE.
             END.

        arq_nrseqdeb = arq_nrseqdeb + 1.

        CREATE cratarq.
        ASSIGN cratarq.cdbccxlt = 997
               cratarq.nrdolote = 1
               cratarq.tpregist = 3
               cratarq.cdsegmto = "H"
               cratarq.tpmovmto = 0
               cratarq.nmprimtl = crapass.nmprimtl
               cratarq.cdempres = aux_cdempres_2
               cratarq.nrcpfcgc = crapass.nrcpfcgc
               cratarq.nrcadast = crapass.nrcadast
               cratarq.tpoperac = 2
               cratarq.dtdiavec = DAY(crapepr.dtdpagto)
               cratarq.dtmesvec = IF MONTH(glb_dtmvtolt) = 12 THEN
                                     1
                                  ELSE
                                     MONTH(glb_dtmvtolt) + 1
               cratarq.dtanovec = IF MONTH(glb_dtmvtolt) = 12 THEN
                                     YEAR(glb_dtmvtolt) + 1
                                  ELSE
                                     YEAR(glb_dtmvtolt)
               cratarq.qtprepag = IF (aux_qtprepag + 1) > crapepr.qtpreemp THEN
                                     crapepr.qtpreemp
                                  ELSE
                                     (aux_qtprepag + 1)
               cratarq.qtpreemp = crapepr.qtpreemp
               cratarq.dtdpagto = crawepr.dtdpagto
               cratarq.dtultpag = f_DataFim(crawepr.dtdpagto, crapepr.qtpreemp)
               cratarq.vlemprst = crapepr.vlemprst
               cratarq.vlpreemp = epr_vlpreemp[epr_qtctremp]
               cratarq.vlsdeved = IF   aux_vlsdeved >= 0   THEN
                                       aux_vlsdeved
                                  ELSE
                                       0
               cratarq.nrctremp = crapepr.nrctremp.            

    END.  /*  Fim do FOR EACH -- Leitura dos emprestimos  */

    IF   aux_flgarqab   THEN
         DO:
             IF   LINE-COUNTER(str_1) > 82   THEN
                  DO:
                      PAGE STREAM str_1.
 
                      DISPLAY STREAM str_1 rel_dsempres WITH FRAME f_empresa.
                   END.

             DISPLAY STREAM str_1 tot_qtdassoc tot_qtctremp tot_vlpreemp
                                  WITH FRAME f_consigtotais.

             OUTPUT STREAM str_1 CLOSE.
             
             ASSIGN glb_nrcopias = 2
                    glb_nmformul = IF   aux_nrdevias[aux_contaarq] > 1   THEN 
                                        STRING(aux_nrdevias[aux_contaarq]) + 
                                        "vias"
                                   ELSE 
                                        " "
                    glb_nmarqimp = aux_nmarqimp[aux_contaarq].
                           
             RUN fontes/imprim.p.
             
             CREATE cratarq.
             ASSIGN cratarq.cdbccxlt = 997
                    cratarq.nrdolote = 1
                    cratarq.tpregist = 5.

             CREATE cratarq.
             ASSIGN cratarq.cdbccxlt = 997
                    cratarq.nrdolote = 1
                    cratarq.tpregist = 9.
                      
             aux_nmarqsai = "emp" + STRING(MONTH(glb_dtmvtolt), "99") +
                                    STRING(YEAR(glb_dtmvtolt), "9999") +
                                    "_" + STRING(crapemp.cdempres, "99999") +
                                    ".dat".
                                       
             RUN fontes/crps_cnab.p(aux_nmarqsai, "H").
                      
             /* envio do relatorio por e-mail */
             RUN sistema/generico/procedures/b1wgen0011.p
                 PERSISTENT SET b1wgen0011.
             
             RUN converte_arquivo IN b1wgen0011
                                  (INPUT glb_cdcooper,
                                   INPUT "arq/"  + aux_nmarqsai,
                                   INPUT aux_nmarqsai).
                                   
             RUN converte_arquivo IN b1wgen0011
                              (INPUT glb_cdcooper,
                               INPUT aux_nmarqimp[aux_contaarq],
                               INPUT SUBSTRING(aux_nmarqimp[aux_contaarq],4)).
                        
             UNIX SILENT VALUE("cp /usr/coop/" + crapcop.dsdircop + 
                               "/converte/" + aux_nmarqsai +
                               " salvar" +
                               " 2> /dev/null").
                                   
             RUN enviar_email IN b1wgen0011
                          (INPUT glb_cdcooper,
                           INPUT glb_cdprogra,
                           INPUT crapemp.dsdemail,
                           INPUT '"ARQUIVO PARA CONSIGNACAO DE ' +
                                 'EMPRESTIMO" - ' + crapcop.nmrescop,
                           INPUT aux_nmarqsai + ";" +
                                 SUBSTRING(aux_nmarqimp[aux_contaarq], 4),
                           INPUT TRUE).

             DELETE PROCEDURE b1wgen0011.
                                         
             UNIX SILENT VALUE("rm arq/" + aux_nmarqsai + 
                                        " 2>/dev/null").

             IF   crapemp.flgarqrt = TRUE   THEN  
                  DO:
                      FOR EACH cratarq WHERE cratarq.tpregist = 0:
                       
                          ASSIGN cratarq.cdremess = 1
                                 cratarq.dtmvtolt = 
                                             IF MONTH(glb_dtmvtolt) = 12 THEN 
                                                DATE(01,10,
                                                     YEAR(glb_dtmvtolt) + 1)
                                             ELSE
                                                DATE(MONTH(glb_dtmvtolt) + 1,
                                                     10,
                                                     YEAR(glb_dtmvtolt)).
                                                      
                      END.

                      FIND FIRST cratarq WHERE cratarq.tpregist = 0 NO-LOCK.
                       
                      aux_nmarqsai = "e" + STRING(crapemp.cdempres, "99999") + 
                                     STRING(DAY(cratarq.dtmvtolt), "99") + 
                                     STRING(MONTH(cratarq.dtmvtolt), "99") + 
                                     STRING(YEAR(cratarq.dtmvtolt), "9999"). 
                                       
                      RUN fontes/crps_cnab.p(aux_nmarqsai, "H").
                       
                      UNIX SILENT VALUE("mv arq/" + aux_nmarqsai + 
                                        " integra 2>/dev/null").
                       
                  END.                  

               FOR EACH cratarq:
                   DELETE cratarq.
               END.  
         END.

END.  /*  Fim do DO TO para as empresas  */

RUN fontes/fimprg.p.

/* .......................................................................... */
