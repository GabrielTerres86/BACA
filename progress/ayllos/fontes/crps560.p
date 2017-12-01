/* ............................................................................
   ****************************************************************************
     FONTE UTILIZANDO O ANTIGO RATING - NOVO RATING LIBERADO EM 02/2010
      SERÁ UTILIZADO SOMENTE A PEDIDOS DOS AUDITORES DO BANCO CENTRAL
                        VERIFICAR LEITURAS DA CRAPRIS
   ****************************************************************************
   Programa: Fontes/crps560.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Fernando
   Data    : FEVEREIRO/2010                     Ultima atualizacao: 30/10/2017
   Dados referentes ao programa:

   Frequencia: Diario
   Objetivo  : Gerar arquivos para auditoria do Banco Central.
   
   Alterações: 30/08/2010 - Removido campo crapass.cdempres (Diego).
   
               22/09/2010 - Mudada a estrutura da crawepr para a crapbpr
                            quando bens alienados (Gabriel).
               
               22/06/2012 - Substituido gncoper por crapcop (Tiago).

               30/10/2017 - Passagem do tpctrato. (Jaison/Marcos Martini - PRJ404)

............................................................................. */
{ includes/var_online.i "NEW" }

DEFINE STREAM str_1.
DEFINE STREAM str_2.
DEFINE STREAM str_3.
DEFINE STREAM str_4.
DEFINE STREAM str_5.

DEFINE VARIABLE aux_dsheader AS CHARACTER   NO-UNDO.
DEFINE VARIABLE aux_dsdobody AS CHARACTER   NO-UNDO.

DEFINE VARIABLE aux_nrdconta AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_vlsaldos AS DECIMAL     NO-UNDO.
DEFINE VARIABLE aux_sequence AS INTEGER     NO-UNDO.

DEFINE VARIABLE aux_dtgeneri AS DATE        NO-UNDO.
DEFINE VARIABLE aux_dtgener2 AS DATE        NO-UNDO.
DEFINE VARIABLE aux_dsdfaixa AS CHARACTER   NO-UNDO.
DEFINE VARIABLE aux_vlsalcon AS CHARACTER   NO-UNDO.
DEFINE VARIABLE aux_perdaapl AS DECIMAL     NO-UNDO.
DEFINE VARIABLE aux_dsgarant AS CHARACTER   NO-UNDO.

DEFINE VARIABLE aux_nrcpfcgc AS CHARACTER   NO-UNDO.
DEFINE VARIABLE aux_cdhistor AS INTEGER     NO-UNDO.

DEFINE VARIABLE aux_contador AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_contadap AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_contadav AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_cdempres AS INTEGER     NO-UNDO.

DEFINE BUFFER crabass      FOR crapass.
DEFINE BUFFER crabris      FOR crapris.

DEFINE TEMP-TABLE w_cada01                  NO-UNDO
    FIELD nrasscop  AS INTE  /* Total Ass.   */
    FIELD nrassatv  AS INTE  /* Ass. Ativos  */
    FIELD nrassfun  AS INTE  /* Funcionarios */
    
    FIELD vldpap10  AS DECI  /* ********* 10  maiores */
    FIELD vldpap20  AS DECI  /* Depositos 20  maiores */  
    FIELD vldpap50  AS DECI  /*  a prazo  50  maiores */
    FIELD vldpap100 AS DECI  /* ********* 100 maiores */
    
    FIELD vldpav10  AS DECI  /* ********* 10  maiores */
    FIELD vldpav20  AS DECI  /* Depositos 20  maiores */
    FIELD vldpav50  AS DECI  /*  a vista  50  maiores */
    FIELD vldpav100 AS DECI. /* ********* 100 maiores */

DEFINE TEMP-TABLE w_rass01                  NO-UNDO
    FIELD nrmatric   AS INTE  /* Nr. matricula */
    FIELD tpcpfcgc   AS INTE  /* Indicador CNPJ/CPF */
    FIELD nrcpfcgc   AS DECI  /* CPF - CNPJ */
    FIELD nmprimtl   AS CHAR  /* Nome do Ass. */
    FIELD cdnvlcgo   AS INTE  /* Cod do tipo de atividade/profissao */
    FIELD vlttcota   AS DECI  /* Valor do capital total */
    FIELD vlcotint   AS DECI  /* Valor do capital a integralizar */ 
    FIELD dtadmiss   AS CHAR  /* Data de ingresso */
    FIELD flgrisco   AS LOGI  /* Autorizacao para consulta a central de risco */
    FIELD dsnivris   AS CHAR  /* Risco do Ass. */
    FIELD dtaturat   AS CHAR  /* Data da Classificacao do Ass. */
    INDEX w_rass01_1 AS PRIMARY nrmatric.

DEFINE TEMP-TABLE w_cdpz01                  NO-UNDO
    FIELD tpcpfcgc   AS INTE /* Indicador CNPJ/CPF */
    FIELD nrcpfcgc   AS DECI /* CPF - CNPJ */
    FIELD nrmatric   AS INTE /* Matricula */
    FIELD dtdcapta   AS CHAR /* Data da captacao */
    FIELD dtdovenc   AS CHAR /* Data do vencimento */
    FIELD vldcapta   AS DECI /* Valor da captacao */
    FIELD nrdindex   AS INTE /* Indexador */
    FIELD perindex   AS INTE /* Precentual do indexador  */
    FIELD snoperac   AS CHAR /* Sinal da operacao */
    FIELD txoperac   AS DECI /* Taxa da operacao */
    FIELD nrdctcon   AS INTE /* Conta contabil */
    FIELD vlsalcon   AS DECI /* Saldo contabil */
    INDEX w_cdpz01_1 AS PRIMARY nrmatric.

DEFINE TEMP-TABLE w_cocr01                  NO-UNDO
    FIELD tpcpfcgc   AS INTE /* Indicador CNPJ/CPF */
    FIELD nrcpfcgc   AS DECI /* CPF - CNPJ */
    FIELD nrctremp   AS INTE /* Numero do Contrato */
    FIELD nrdcosif   AS INTE /* COSIF */
    FIELD nrcosif2   AS INTE /* COSIF 2.682 */
    FIELD dsnivris   AS CHAR /* Risco da operacao */
    FIELD dtrisope   AS CHAR /* Data de classificacao do ultimo risco */
    FIELD vlprovis   AS DECI /* Valor da Provisao constituida */
    FIELD cdmodali   AS INTE /* Codigo da modalidade da operacao */
    FIELD dtiniope   AS CHAR /* Data de inicio da operacao */
    FIELD dtfimope   AS CHAR /* Data de vencimento final da operacao */
    FIELD vlctremp   AS DECI /*Valor constante do contrato na data da operacao*/
    FIELD vltaxjur   AS INTE /* Valor de juros nominal da operacao */
    FIELD cdindcor   AS INTE /* Codigo do indice de correcao */
    FIELD tpgaran1   AS CHAR /* Codigo da garantia principal */
    FIELD tpgaran2   AS CHAR /* Codigo da garantia secundaria */
    FIELD tpgaran3   AS CHAR /* Codigo da garantia terciaria */
    FIELD pergara1   AS INTE /* Percentual de garantia principal */
    FIELD pergara2   AS INTE /* Percentual de garantia secundario */
    FIELD pergara3   AS INTE /* Percentual de garantia terciario */
    FIELD dsformpg   AS CHAR /* Forma de pagamento */
    FIELD nrdiacar   AS INTE /* Dias de inicio da amortizacao */
    FIELD qtpresta   AS INTE /* Quantidade total de parcelas da operacao */
    FIELD qtpreabr   AS INTE /* Quantidade de parcelas em aberto */
    FIELD dtpromov   AS CHAR /* Data do proximo vencimento */
    FIELD vldivida   AS DECI /* Saldo contabil */ 
    FIELD cdrenego   AS INTE /* Codigo da renegociacao */
    FIELD cdsitcob   AS INTE /* Codigo de situacao da cobranca */
    FIELD nrmatric   AS INTE /* Numero da matricula */
    FIELD vllimite   AS DECI /* Limite de credito do cheque especial/rotativo */
    FIELD vlrdobem   AS DECI /* Valor do Bem */
    FIELD coddobem   AS INTE /* Codigo do Bem */
    FIELD dtiniorg   AS CHAR /* Data de origem da operacao */
    FIELD qtdiaatr   AS INTE /* Dias de atraso da operacao original */
    FIELD inrisorg   AS CHAR /* Classificacao do risco original */
    FIELD vlsdeved   AS DECI /* Valor do saldo devedor */
    FIELD peramort   AS INTE /* Percentual de amortizacao */
    FIELD vlmaipar   AS DECI /* Valor da maior parcela */
    FIELD dtvenpar   AS CHAR /* Data de vencimento da maior parcela */ 
    INDEX w_cocr01 AS PRIMARY nrmatric.

DEFINE TEMP-TABLE w_cdvt01                  NO-UNDO
    FIELD tpcpfcgc   AS INTE /* Indicador CNPJ/CPF */
    FIELD nrcpfcgc   AS DECI /* CPF - CNPJ */
    FIELD nrmatric   AS INTE /* Matricula */
    FIELD nrdconta   AS INTE /* Numero da Conta/Dv */
    FIELD nrdctcon   AS INTE /* Conta contabil */
    FIELD vlsalcon   AS DECI /* Saldo contabil */
    FIELD vllimite   AS DECI /* Limite de cheque especial ou conta garantida */
    FIELD dtinisal   AS CHAR /* Data de inicial saldo negativo */
    FIELD dtadmiss   AS CHAR /* Data de abertura da conta corrente */
    INDEX w_cdvt01 AS PRIMARY nrmatric.
    
DEFINE TEMP-TABLE w_depositos               NO-UNDO
    FIELD nrdconta  AS INTE /* Conta do Ass. */
    FIELD vlsaldos  AS DECI /* Saldo do Ass. */
    FIELD sequence  AS INTE /* Sequencial para determinar os 100 maiores */
    FIELD tpdepost  AS INTE /* 1 - Dept a vista   2 - Dept a prazo */
    INDEX w_depositos1 AS PRIMARY tpdepost sequence nrdconta.

/* Calculo para as taxas aplicadas - RDC30 - RDC60 - RDPP */
DEFINE TEMP-TABLE w_taxas                   NO-UNDO
    FIELD dsaplica AS CHAR /* Nm. aplicacao */
    FIELD tpaplica AS INTE /* Tipo da aplicacao */
    FIELD vlinifxa AS DECI /* Valor inicial da faixa de uso da taxa */
    FIELD vlfimfxa AS DECI /* Valor final da faixa de uso da taxa */
    FIELD vldataxa AS DECI /* Valor da taxa */
    INDEX w_taxas1 AS PRIMARY tpaplica dsaplica.

DEF BUFFER w_taxas2  FOR w_taxas.
DEF BUFFER b-crapcop FOR crapcop.


/* Taxas das aplicacoes */
FUNCTION f_per_indexador RETURN INTEGER (INPUT par_tpaplica AS INTE,
                                         INPUT par_vlaplica AS DECI):

    DEFINE VARIABLE aux_vlpertax AS INTEGER NO-UNDO.
    
    FOR EACH w_taxas WHERE w_taxas.tpaplica = par_tpaplica:

        IF   w_taxas.vlfimfxa > par_vlaplica    THEN
             DO:
                ASSIGN aux_vlpertax = w_taxas.vldataxa.
                LEAVE.
             END.
    END. /* Fim do FOR EACH - w_taxas */

    RETURN aux_vlpertax.

END. /* Fim da FUNCTION */

FUNCTION f_zeros_direita RETURN CHARACTER (INPUT par_nriterac AS INTE,
                                           INPUT par_nmelemen AS CHAR):

  ASSIGN par_nriterac = par_nriterac - (LENGTH(par_nmelemen) + 1)
         aux_contador = 0.

  DO aux_contador = 0 TO par_nriterac:
     ASSIGN par_nmelemen = par_nmelemen + " ".
  END. /* Fim do DO TO */

  RETURN par_nmelemen.

END. /* Fim da FUNCTION */

ASSIGN glb_cdprogra = "crps560".
       
RUN fontes/iniprg.p.
                             
IF  glb_cdcritic > 0  THEN
    DO:
       RUN fontes/fimprg.p.
       QUIT.
    END.                       

FIND crapdat WHERE crapdat.cdcooper = glb_cdcooper  NO-LOCK NO-ERROR.

IF   NOT AVAIL crapdat THEN
     DO:
        glb_cdcritic = 1.
        RUN fontes/critic.p.
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          glb_dscritic + " >> log/proc_batch.log").
        QUIT.
     END.
    
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
    
IF   NOT AVAILABLE crapcop  THEN
     DO:
        glb_cdcritic = 651.
        RUN fontes/critic.p.
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          glb_dscritic + " >> log/proc_batch.log").
        QUIT.
     END.

/* Pegar o CNPJ da CENTRAL */
FIND b-crapcop WHERE b-crapcop.cdcooper = 3 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE b-crapcop   THEN
     DO:
        glb_cdcritic = 651.
        RUN fontes/critic.p.
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          glb_dscritic + " >> log/proc_batch.log").
        QUIT.
     END.

/* Carrega as taxas - RDCA30 - POUP. PROGR - RDCA60 */
FOR EACH craptab WHERE (craptab.cdcooper = glb_cdcooper  AND
                        craptab.nmsistem = "CRED"        AND
                        craptab.tptabela = "CONFIG"      AND
                        craptab.cdacesso = "TXADIAPLIC"  AND
                        craptab.tpregist = 1                ) OR 
                       (craptab.cdcooper = glb_cdcooper  AND
                        craptab.nmsistem = "CRED"        AND
                        craptab.tptabela = "CONFIG"      AND
                        craptab.cdacesso = "TXADIAPLIC"  AND
                        craptab.tpregist = 2                ) OR 
                       (craptab.cdcooper = glb_cdcooper  AND
                        craptab.nmsistem = "CRED"        AND
                        craptab.tptabela = "CONFIG"      AND
                        craptab.cdacesso = "TXADIAPLIC"  AND
                        craptab.tpregist = 3                )NO-LOCK:

    DO aux_contador = 1 TO NUM-ENTRIES(craptab.dstextab,";"):
            
        CREATE w_taxas.
        ASSIGN aux_dsdfaixa     = ENTRY(aux_contador,craptab.dstextab,";")
               w_taxas.tpaplica = craptab.tpregist
               w_taxas.dsaplica = IF w_taxas.tpaplica = 1 THEN
                                      "RDCA30"
                                   ELSE
                                   IF w_taxas.tpaplica = 2 THEN
                                      "POUP.PROGR."
                                   ELSE
                                      "RDCA60"
               w_taxas.vlinifxa = DECIMAL(ENTRY(1,aux_dsdfaixa,"#"))
               w_taxas.vlfimfxa = 999999999.99
               w_taxas.vldataxa = DECIMAL(ENTRY(2,aux_dsdfaixa,"#")).

    END. /* Fim do DO TO */

    /* Atribuir o valores finais de cada taxa */
    FOR EACH w_taxas:

        FIND FIRST w_taxas2 WHERE w_taxas2.tpaplica = w_taxas.tpaplica AND
                                  w_taxas2.dsaplica = w_taxas.dsaplica AND
                                  w_taxas2.vlinifxa > w_taxas.vlinifxa
                                  NO-LOCK NO-ERROR.

        IF   AVAILABLE w_taxas2   THEN
             w_taxas.vlfimfxa = w_taxas2.vlinifxa - 0.01.

    END. /* Fim do FOR EACH - w_taxas */
END. /* Fim do FOR EACH - craptab */

/* Criar registro para o arquivo CADA01 - Informacoes Resumidas */
CREATE w_cada01.

FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK:

    ASSIGN w_cada01.nrasscop = w_cada01.nrasscop + 1.

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
       
    IF   crapass.dtdemiss = ?   THEN
         DO: 
             /* CADA01*/
             ASSIGN w_cada01.nrassatv = w_cada01.nrassatv + 1.
    
             FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper     AND
                                crapemp.cdempres = aux_cdempres 
                                NO-LOCK NO-ERROR.       

             IF  AVAILABLE crapemp AND
                 crapemp.nmresemp MATCHES "*" + crapcop.nmrescop + "*"   THEN
                 DO:
                    IF  NOT CAN-DO(aux_nrcpfcgc,STRING(crapass.nrcpfcgc)) THEN
                        ASSIGN w_cada01.nrassfun = w_cada01.nrassfun + 1
                               aux_nrcpfcgc     = STRING(crapass.nrcpfcgc) + ",".
                 END.
             
             FIND crapdir WHERE crapdir.cdcooper = glb_cdcooper     AND
                                crapdir.nrdconta = crapass.nrdconta AND
                                crapdir.dtmvtolt = glb_dtmvtolt     NO-LOCK
                                NO-ERROR.
                 
             IF   AVAILABLE crapdir   THEN
                  RUN proc_cria_depositos (INPUT crapdir.nrdconta,
                                           INPUT crapdir.vlsdapli +
                                                 crapdir.vlsdrdpp,
                                           INPUT 2 /* Dept a prazo */ ).
                                            
             /* RASS01 */
             CREATE w_rass01.
             ASSIGN w_rass01.nrmatric = crapass.nrmatric
                    w_rass01.nmprimtl = crapass.nmprimtl
                    w_rass01.dtadmiss = IF  crapass.dtadmiss <> ? THEN
                                            STRING(YEAR(crapass.dtadmiss),"9999")
                                          + STRING(MONTH(crapass.dtadmiss),"99")
                                          + STRING(DAY(crapass.dtadmiss),"99")
                                        ELSE
                                            STRING(YEAR(crapass.dtmvtolt),"9999")
                                          + STRING(MONTH(crapass.dtmvtolt),"99")
                                          + STRING(DAY(crapass.dtmvtolt),"99")
                    w_rass01.flgrisco = YES
                    w_rass01.dsnivris = crapass.dsnivris
                    w_rass01.dtaturat = IF   crapass.dtaturat <> ?  THEN
                                        STRING(YEAR(crapass.dtaturat),"9999") +
                                        STRING(MONTH(crapass.dtaturat),"99") + 
                                        STRING(DAY(crapass.dtaturat),"99")
                                        ELSE
                                             "19010101".
             
             IF   crapass.inpessoa = 1   THEN
                  DO:
                     FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper     AND
                                        crapttl.nrdconta = crapass.nrdconta AND
                                        crapttl.idseqttl = 1 NO-LOCK NO-ERROR.

                     ASSIGN w_rass01.cdnvlcgo = crapttl.cdnatopc.
                  END.
             ELSE
                  DO:
                     FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper     AND
                                        crapjur.nrdconta = crapass.nrdconta
                                        NO-LOCK NO-ERROR.
                     
                     ASSIGN w_rass01.cdnvlcgo = crapjur.cdrmativ.
                  END.

             IF   crapass.nrcpfcgc = 0   THEN
                  ASSIGN w_rass01.tpcpfcgc = 9
                         w_rass01.nrcpfcgc = 0.
             ELSE
                  DO: 
                     IF   crapass.inpessoa = 1   THEN
                          ASSIGN w_rass01.tpcpfcgc = 2.
                     ELSE
                          ASSIGN w_rass01.tpcpfcgc = 1.

                     ASSIGN w_rass01.nrcpfcgc = crapass.nrcpfcgc.
                  END.

             FIND crapcot WHERE crapcot.cdcooper = glb_cdcooper     AND
                                crapcot.nrdconta = crapass.nrdconta NO-LOCK
                                NO-ERROR.

             IF   NOT AVAILABLE crapcot   THEN
                  ASSIGN w_rass01.vlttcota = 0.
             ELSE
                  ASSIGN w_rass01.vlttcota = crapcot.vldcotas.

             FOR EACH crapsdc WHERE crapsdc.cdcooper =  glb_cdcooper     AND
                                    crapsdc.dtrefere >= glb_dtmvtolt     AND
                                    crapsdc.nrdconta =  crapass.nrdconta AND
                                    crapsdc.indebito = 0            NO-LOCK:
                  
                 ASSIGN w_rass01.vlcotint = w_rass01.vlcotint +
                                             crapsdc.vllanmto.
             END. /* Fim do FOR EACH - crapsdc */

             /* CDPZ01 */
             /* RDPP - Poup. Programada - Uma linha de arquivo para cada 
                aplicacao */
             FOR EACH craprpp WHERE craprpp.cdcooper = glb_cdcooper     AND
                                    craprpp.nrdconta = crapass.nrdconta AND
                                    craprpp.dtslfmes = glb_dtmvtolt     AND
                                    craprpp.vlslfmes > 0           NO-LOCK:

                 FIND craplpp WHERE craplpp.cdcooper = glb_cdcooper     AND
                                    craplpp.dtmvtolt = glb_dtmvtolt     AND
                                    craplpp.cdagenci = 1                AND
                                    craplpp.cdbccxlt = 100              AND
                                    craplpp.nrdolote = 8383             AND
                                    craplpp.nrdconta = craprpp.nrdconta AND
                                    craplpp.cdhistor = 152 NO-LOCK NO-ERROR.

                 IF   NOT AVAILABLE craplpp   THEN
                      NEXT.

                 CREATE w_cdpz01.
                 ASSIGN w_cdpz01.tpcpfcgc = w_rass01.tpcpfcgc
                        w_cdpz01.nrcpfcgc = w_rass01.nrcpfcgc
                        w_cdpz01.nrmatric = w_rass01.nrmatric 
                        w_cdpz01.dtdcapta = 
                                 STRING(YEAR(craprpp.dtmvtolt),"9999") +
                                 STRING(MONTH(craprpp.dtmvtolt),"99")  +
                                 STRING(DAY(craprpp.dtmvtolt),"99")
                        w_cdpz01.dtdovenc = 
                                 STRING(YEAR(craprpp.dtvctopp),"9999") +
                                 STRING(MONTH(craprpp.dtvctopp),"99")  +
                                 STRING(DAY(craprpp.dtvctopp),"99")
                        w_cdpz01.vldcapta = craprpp.vlprepag  
                        w_cdpz01.nrdindex = 31           
                        w_cdpz01.perindex = f_per_indexador(2,craprpp.vlslfmes)
                        w_cdpz01.snoperac = "+"
                        w_cdpz01.nrdctcon = 41510205
                        w_cdpz01.vlsalcon = craprpp.vlslfmes
                        w_cdpz01.txoperac = ROUND(((EXP(1 + (craplpp.txaplmes / 
                                                       100), 12) - 1) * 100),6).

             END. /* Fim do FOR EACH - craprpp */

             /* RDCA30 RDCA60 RDCPRE RDCPOS - Uma linha de arquivo para cada
                aplicacao */
             FOR EACH craprda WHERE (craprda.cdcooper = glb_cdcooper     AND
                                     craprda.tpaplica = 3                AND
                                     craprda.insaqtot = 0                AND
                                     craprda.cdageass = crapass.cdagenci AND
                                     craprda.nrdconta = crapass.nrdconta AND
                                     craprda.dtsdfmes = glb_dtmvtolt     AND
                                     craprda.vlslfmes > 0)                   OR
                                    (craprda.cdcooper = glb_cdcooper     AND
                                     craprda.tpaplica = 5                AND
                                     craprda.insaqtot = 0                AND
                                     craprda.cdageass = crapass.cdagenci AND
                                     craprda.nrdconta = crapass.nrdconta AND
                                     craprda.dtsdfmes = glb_dtmvtolt     AND
                                     craprda.vlslfmes > 0)                   OR
                                    (craprda.cdcooper = glb_cdcooper     AND
                                     craprda.tpaplica = 7                AND
                                     craprda.insaqtot = 0                AND
                                     craprda.cdageass = crapass.cdagenci AND
                                     craprda.nrdconta = crapass.nrdconta AND
                                     craprda.dtsdfmes = glb_dtmvtolt     AND
                                     craprda.vlslfmes > 0)                   OR
                                    (craprda.cdcooper = glb_cdcooper     AND
                                     craprda.tpaplica = 8                AND
                                     craprda.insaqtot = 0                AND
                                     craprda.cdageass = crapass.cdagenci AND
                                     craprda.nrdconta = crapass.nrdconta AND
                                     craprda.dtsdfmes = glb_dtmvtolt     AND
                                     craprda.vlslfmes > 0)               NO-LOCK:

                 CREATE w_cdpz01.
                 ASSIGN w_cdpz01.tpcpfcgc = w_rass01.tpcpfcgc
                        w_cdpz01.nrcpfcgc = w_rass01.nrcpfcgc
                        w_cdpz01.nrmatric = w_rass01.nrmatric 
                        w_cdpz01.dtdcapta = 
                                    STRING(YEAR(craprda.dtmvtolt),"9999") +
                                    STRING(MONTH(craprda.dtmvtolt),"99")  +
                                    STRING(DAY(craprda.dtmvtolt),"99")
                        w_cdpz01.dtdovenc = 
                                 IF craprda.tpaplica = 3 THEN
                                    STRING(YEAR(glb_dtmvtopr),"9999") + 
                                    STRING(MONTH(glb_dtmvtopr),"99")  + 
                                    STRING(DAY(glb_dtmvtopr),"99")
                                 ELSE
                                 IF craprda.tpaplica = 5 THEN
                                    STRING(YEAR(craprda.dtfimper),"9999") +
                                    STRING(MONTH(craprda.dtfimper),"99")  +
                                    STRING(DAY(craprda.dtfimper),"99")
                                 ELSE
                                 IF craprda.tpaplica = 7 OR
                                    craprda.tpaplica = 8    THEN
                                    STRING(YEAR(craprda.dtvencto),"9999") +
                                    STRING(MONTH(craprda.dtvencto),"99")  +
                                    STRING(DAY(craprda.dtvencto),"99")
                                 ELSE
                                    "19010101"
                        w_cdpz01.vldcapta = craprda.vlaplica  
                        w_cdpz01.nrdindex = 31             
                        w_cdpz01.snoperac = "+"
                        w_cdpz01.nrdctcon = IF craprda.tpaplica = 3 OR
                                               craprda.tpaplica = 5    THEN
                                               41410006
                                            ELSE
                                               41510205
                        w_cdpz01.vlsalcon = craprda.vlslfmes
                        aux_cdhistor      = IF craprda.tpaplica = 3 THEN
                                               117
                                            ELSE
                                            IF craprda.tpaplica = 5 THEN
                                               180
                                            ELSE 0.

                 IF  craprda.tpaplica = 3 OR craprda.tpaplica = 5   THEN
                     DO:
                        ASSIGN w_cdpz01.perindex = 
                           f_per_indexador(craprda.tpaplica,craprda.vlslfmes).
                       
                       FIND FIRST craplap WHERE 
                                  craplap.cdcooper = glb_cdcooper     AND
                                  craplap.nrdconta = craprda.nrdconta AND
                                  craplap.nraplica = craprda.nraplica AND
                                  craplap.cdhistor = aux_cdhistor
                                  USE-INDEX craplap5 NO-LOCK NO-ERROR.
                       
                        IF  AVAIL craplap  THEN
                            w_cdpz01.txoperac = ROUND(((EXP(1 + 
                              (craplap.txaplmes / 100),12) - 1) * 100),6).
                     END.
                 ELSE
                 IF  craprda.tpaplica = 7 OR craprda.tpaplica = 8   THEN
                     DO:
                        FIND FIRST craplap WHERE 
                                   craplap.cdcooper = glb_cdcooper     AND
                                   craplap.nrdconta = craprda.nrdconta AND
                                   craplap.nraplica = craprda.nraplica
                                   USE-INDEX craplap5 NO-LOCK NO-ERROR.
                        
                        IF  AVAIL craplap  THEN
                            DO:
                               ASSIGN w_cdpz01.perindex = craplap.txaplica.

                               IF  craprda.tpaplica = 7   THEN
                                   w_cdpz01.txoperac = ROUND(((EXP(1 + 
                                 (craplap.txaplica / 100),  252) - 1) * 100),6).
                               ELSE
                               DO:
                                  FIND crapmfx WHERE 
                                       crapmfx.cdcooper = glb_cdcooper     AND
                                       crapmfx.dtmvtolt = glb_dtmvtolt     AND
                                       crapmfx.tpmoefix = 6 NO-LOCK NO-ERROR.

                                  IF AVAIL crapmfx THEN
                                     w_cdpz01.txoperac = (crapmfx.vlmoefix *
                                                          craplap.txaplica) /
                                                          100.
                               END.
                            END.
                      END.
             END. /* Fim do FOR EACH - craprda */

             /* CDVT01 */
             CREATE w_cdvt01.
             ASSIGN w_cdvt01.tpcpfcgc = w_rass01.tpcpfcgc
                    w_cdvt01.nrcpfcgc = w_rass01.nrcpfcgc
                    w_cdvt01.nrmatric = crapass.nrmatric
                    w_cdvt01.nrdconta = crapass.nrdconta
                    w_cdvt01.nrdctcon = IF crapass.inpessoa = 1 THEN
                                            41110007
                                        ELSE
                                            41120004
                    w_cdvt01.vllimite = crapass.vllimcre
                    w_cdvt01.dtadmiss = IF crapass.dtadmiss <> ? THEN
                                           STRING(YEAR(crapass.dtadmiss),"9999")
                                         + STRING(MONTH(crapass.dtadmiss),"99")
                                         + STRING(DAY(crapass.dtadmiss),"99")
                                        ELSE
                                           STRING(YEAR(crapass.dtmvtolt),"9999")
                                         + STRING(MONTH(crapass.dtmvtolt),"99")
                                         + STRING(DAY(crapass.dtmvtolt),"99").    
                                                
            FIND crapsda WHERE crapsda.cdcooper = glb_cdcooper     AND
                               crapsda.dtmvtolt = glb_dtmvtolt     AND
                               crapsda.nrdconta = crapass.nrdconta NO-LOCK
                               NO-ERROR.

            IF   AVAILABLE crapsda   THEN
                 w_cdvt01.vlsalcon = crapsda.vlsddisp + crapsda.vlsdchsl +
                                      crapsda.vlsdbloq + crapsda.vlsdblpr +
                                      crapsda.vlsdblfp + crapsda.vlsdindi.

             IF   w_cdvt01.vlsalcon >= 0   THEN
                  ASSIGN aux_dtgener2 = 01/01/1901.
             ELSE
                 DO:
                    ASSIGN aux_dtgeneri = glb_dtmvtolt
                           aux_dtgener2 = glb_dtmvtolt
                           aux_contador = 0.
                    
                    DO WHILE TRUE ON ERROR UNDO, LEAVE:
                            
                       ASSIGN aux_contador = aux_contador + 1.
                    
                       FIND crapsda WHERE 
                            crapsda.cdcooper = glb_cdcooper     AND
                            crapsda.dtmvtolt = aux_dtgeneri     AND
                            crapsda.nrdconta = crapass.nrdconta
                            NO-LOCK NO-ERROR.
                    
                       IF   AVAILABLE crapsda   THEN
                            DO:
                               aux_vlsaldos = 
                                        crapsda.vlsddisp + crapsda.vlsdchsl +
                                        crapsda.vlsdbloq + crapsda.vlsdblpr +
                                        crapsda.vlsdblfp + crapsda.vlsdindi.
                    
                               IF   aux_vlsaldos >= 0  THEN
                                    LEAVE.
                               ELSE
                                    DO: 
                                   /* Data da criacao da estrutura crapsda */
                                        IF   aux_dtgeneri < 03/08/2005   THEN
                                             LEAVE.
                                    END.
                            END.
                       ELSE
                            DO:
                               IF   aux_dtgeneri < 03/08/2005   THEN
                                    LEAVE.
                            END.
                    
                       ASSIGN  aux_dtgener2 = aux_dtgeneri
                               aux_dtgeneri = aux_dtgeneri - 1.
                    END. /* Fim do DO WHILE TRUE */
                 END.

            ASSIGN w_cdvt01.dtinisal = STRING(YEAR(aux_dtgener2),"9999") +
                                       STRING(MONTH(aux_dtgener2),"99")  +
                                       STRING(DAY(aux_dtgener2),"99").
         END.    
END.

ASSIGN aux_contador = 0.

FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper AND
                       crapass.dtdemiss = ?            NO-LOCK,
    EACH crapsld WHERE crapsld.cdcooper = glb_cdcooper      AND
                       crapsld.nrdconta = crapass.nrdconta  NO-LOCK
                       BREAK BY crapsld.vlsddisp DESCENDING:
                
    RUN proc_cria_depositos (INPUT crapsld.nrdconta,
                             INPUT crapsld.vlsddisp,
                             INPUT 1 /* Dept a vista*/ ).

    /* Listar os 100 maiores saldos */
    IF   RETURN-VALUE = "NOK"   THEN
         LEAVE.

END. /* Fim do FOR EACH - crapsld */

/* COCR01 */
FOR EACH crapris WHERE crapris.cdcooper = glb_cdcooper AND
                       crapris.dtrefere = glb_dtmvtolt AND
                       crapris.inddocto =  1           AND
                       crapris.vldivida <> 0           NO-LOCK:
    
    FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                       crapass.nrdconta = crapris.nrdconta NO-LOCK
                       NO-ERROR.
    
    CREATE w_cocr01.
    
    IF   crapass.nrcpfcgc = 0   THEN
         ASSIGN w_cocr01.tpcpfcgc = 9
                w_cocr01.nrcpfcgc = 0.
    ELSE
         DO: 
            IF   crapass.inpessoa = 1   THEN
                 ASSIGN w_cocr01.tpcpfcgc = 2.
            ELSE
                 ASSIGN w_cocr01.tpcpfcgc = 1.
    
                 ASSIGN w_cocr01.nrcpfcgc = crapass.nrcpfcgc.
         END.
    
    ASSIGN w_cocr01.nrmatric = crapass.nrmatric
           w_cocr01.vllimite = crapass.vllimcre
           w_cocr01.nrctremp = crapris.nrctremp
           w_cocr01.cdmodali = crapris.cdmodali
           w_cocr01.dtiniope = 
                    STRING(YEAR(crapris.dtinictr),"9999") +
                    STRING(MONTH(crapris.dtinictr),"99")  +
                    STRING(DAY(crapris.dtinictr),"99")
           w_cocr01.cdindcor = 21
           w_cocr01.dsformpg = "A"
           w_cocr01.vldivida = crapris.vldivida
           w_cocr01.vlctremp = crapris.vldivida
           w_cocr01.dtvenpar = "19010101"
           w_cocr01.dtiniorg = "19010101"
           w_cocr01.tpgaran1 = "y"
           w_cocr01.tpgaran2 = "y"
           w_cocr01.tpgaran3 = "y".
    
    /* Buscar data da classificação do ultimo risco */
    /* EX: Caso o cooperado tenha risco H, verificar qual é a primeira data que
       ele entrou com esse risco. OBS: Nunca pegar um FIRST na data pois o
       cooperado pode ter tido mais de uma vez o risco H */
    FOR EACH crabris WHERE crabris.cdcooper = glb_cdcooper     AND
                           crabris.nrdconta = crapris.nrdconta AND
                           crabris.dtrefere < crapris.dtrefere AND
                           crabris.cdorigem = crapris.cdorigem AND
                           crabris.nrctremp = crapris.nrctremp AND
                           crabris.inddocto = crapris.inddocto NO-LOCK
                           BY crabris.dtrefere DESCENDING:

        IF   crabris.innivris <> crapris.innivris   THEN
             LEAVE.

        ASSIGN aux_dtgeneri = crabris.dtrefere.
    END. /* Fim do FOR EACH - crabris */

    IF   aux_dtgeneri = ?   THEN
         ASSIGN w_cocr01.dtrisope = STRING(YEAR(crapris.dtrefere),"9999") +
                                    STRING(MONTH(crapris.dtrefere),"99")  +
                                    STRING(DAY(crapris.dtrefere), "99").
    ELSE
         ASSIGN w_cocr01.dtrisope = STRING(YEAR(aux_dtgeneri),"9999") +
                                    STRING(MONTH(aux_dtgeneri),"99")  +
                                    STRING(DAY(aux_dtgeneri), "99").
    

    CASE crapris.cdorigem:
        WHEN 1 THEN DO:
            ASSIGN w_cocr01.nrdcosif = 16110001
                   w_cocr01.dtfimope = 
                         STRING(YEAR(crapris.dtrefere),"9999") +
                         STRING(MONTH(crapris.dtrefere),"99")  +
                         STRING(DAY(crapris.dtrefere), "99").
    
            ASSIGN  w_cocr01.qtpresta = 1
                    w_cocr01.qtpreabr = 1
                    w_cocr01.cdsitcob = 1
                    w_cocr01.dtpromov = w_cocr01.dtfimope.
    
            IF  crapris.cdmodali = 0201  THEN  /*Cheque Especial*/
                DO:
                   FIND craplim WHERE 
                        craplim.cdcooper = glb_cdcooper     AND
                        craplim.nrdconta = crapris.nrdconta AND
                        craplim.tpctrlim = 1                AND
                        craplim.nrctrlim = crapris.nrctremp
                        NO-LOCK NO-ERROR.
    
                   IF  AVAIL craplim  THEN
                       RUN verifica_garantia 
                                   (INPUT craplim.nrctaav1,
                                    INPUT craplim.nrctaav2,
                                    INPUT crapris.cdorigem).
                END.
    
            FIND LAST craplim WHERE 
                      craplim.cdcooper = glb_cdcooper     AND
                      craplim.nrdconta = crapris.nrdconta AND
                      craplim.tpctrlim = 1                AND
                      craplim.insitlim = 2 USE-INDEX craplim2
                      NO-LOCK NO-ERROR.
    
            IF  NOT AVAILABLE craplim   THEN
                DO:
                   FIND LAST craplim WHERE 
                             craplim.cdcooper = glb_cdcooper     AND
                             craplim.nrdconta = crapris.nrdconta AND
                             craplim.tpctrlim = 1                AND
                             craplim.insitlim = 3 USE-INDEX craplim2
                             NO-LOCK NO-ERROR.
                END.
                   
            IF  AVAILABLE craplim  THEN
                DO:
                   FIND craplrt WHERE 
                        craplrt.cdcooper = glb_cdcooper    AND
                        craplrt.cddlinha = craplim.cddlinha   
                        NO-LOCK NO-ERROR.
    
                   IF   AVAILABLE craplrt   THEN
                        ASSIGN w_cocr01.vltaxjur = ROUND(((EXP(1 + 
                              (craplrt.txmensal / 100),  12) - 1) * 100),6).                     
                END.
        END.
    
        WHEN 2 THEN DO:
            ASSIGN w_cocr01.nrdcosif = 16130005
                   w_cocr01.qtpresta = 1
                   w_cocr01.qtpreabr = 1
                   w_cocr01.cdsitcob = 1.
            
            FIND LAST crapcdb WHERE 
                      crapcdb.cdcooper = glb_cdcooper     AND
                      crapcdb.nrdconta = crapris.nrdconta AND
                      crapcdb.nrctrlim = crapris.nrctremp 
                      NO-LOCK NO-ERROR.
    
            IF   AVAILABLE crapcdb   THEN
                 ASSIGN w_cocr01.dtfimope = 
                          STRING(YEAR(crapcdb.dtlibera), "9999") +
                          STRING(MONTH(crapcdb.dtlibera), "99")  +
                          STRING(DAY(crapcdb.dtlibera), "99").
            ELSE
                 ASSIGN w_cocr01.dtfimope = "19010101".
    
            FIND craplim WHERE 
                 craplim.cdcooper = glb_cdcooper     AND
                 craplim.nrdconta = crapris.nrdconta AND
                 craplim.tpctrlim = 2                AND
                 craplim.nrctrlim = crapris.nrctremp NO-LOCK 
                 NO-ERROR.
    
            IF   AVAIL craplim  THEN
                 DO:
                    RUN verifica_garantia (INPUT craplim.nrctaav1,
                                           INPUT craplim.nrctaav2,
                                           INPUT crapris.cdorigem).
                    FIND crapldc WHERE
                         crapldc.cdcooper = glb_cdcooper     AND
                         crapldc.tpdescto = 2                AND
                         crapldc.cddlinha = craplim.cddlinha
                         NO-LOCK NO-ERROR.
                    
                    IF  AVAIL crapldc  THEN
                        ASSIGN w_cocr01.vltaxjur = ROUND(((EXP(1 + 
                              (crapldc.txmensal / 100),  12) - 1) 
                               * 100),6). 
                 END.
    
            FIND FIRST crapcdb WHERE
                       crapcdb.cdcooper =  glb_cdcooper     AND
                       crapcdb.nrdconta =  crapris.nrdconta AND
                       crapcdb.dtlibera >= glb_dtmvtolt     AND
                       crapcdb.nrctrlim =  crapris.nrctremp 
                       NO-LOCK NO-ERROR.
    
            IF   AVAIL crapcdb  THEN
                 DO:
                    IF   crapcdb.dtlibera = ?   THEN
                         ASSIGN w_cocr01.dtpromov = "19010101".
                    ELSE
                         ASSIGN w_cocr01.dtpromov = 
                                STRING(YEAR(crapcdb.dtlibera),"9999") +
                                STRING(MONTH(crapcdb.dtlibera),"99")  +
                                STRING(DAY(crapcdb.dtlibera),"99").
                 END.
            ELSE
                 ASSIGN w_cocr01.dtpromov = "19010101".
    
        END.
    
        WHEN 3 THEN DO:
            ASSIGN w_cocr01.nrdcosif = 16120008
                   w_cocr01.cdsitcob = IF crapris.vlprjano <> 0 OR
                                          crapris.vlprjaan <> 0 OR
                                          crapris.vlprjant <> 0 OR
                                          crapris.vlprjm60 <> 0
                                          THEN 2
                                       ELSE 1.
            
            FIND crawepr WHERE 
                 crawepr.cdcooper = glb_cdcooper     AND
                 crawepr.nrdconta = crapris.nrdconta AND
                 crawepr.nrctremp = crapris.nrctremp NO-LOCK
                 NO-ERROR.
    
            IF   AVAILABLE crawepr   THEN
                 DO:
                    IF   crawepr.dtvencto = ?  OR
                        (crawepr.dtvencto - crapris.dtinictr) < 0  THEN
                         DO: 
                            FOR EACH craplem WHERE
                                    (craplem.cdcooper =  glb_cdcooper     AND
                                     craplem.nrdconta =  crapris.nrdconta AND
                                     craplem.dtmvtolt >= crawepr.dtmvtolt AND
                                     craplem.cdhistor =  91               AND
                                     craplem.nrctremp =  crapris.nrctremp    ) OR
                                    (craplem.cdcooper =  glb_cdcooper     AND
                                     craplem.nrdconta =  crapris.nrdconta AND
                                     craplem.dtmvtolt >= crawepr.dtmvtolt AND
                                     craplem.cdhistor =  92               AND
                                     craplem.nrctremp =  crapris.nrctremp    ) OR
                                    (craplem.cdcooper =  glb_cdcooper     AND
                                     craplem.nrdconta =  crapris.nrdconta AND
                                     craplem.dtmvtolt >= crawepr.dtmvtolt AND
                                     craplem.cdhistor =  93               AND
                                     craplem.nrctremp =  crapris.nrctremp    ) OR
                                    (craplem.cdcooper =  glb_cdcooper     AND
                                     craplem.nrdconta =  crapris.nrdconta AND
                                     craplem.dtmvtolt >= crawepr.dtmvtolt AND
                                     craplem.cdhistor =  95               AND
                                     craplem.nrctremp =  crapris.nrctremp) 
                                     NO-LOCK:

                                     ASSIGN aux_dtgener2 = craplem.dtmvtolt.
                                     LEAVE.

                            END. /* Fim do FOR EACH - craplem */
                         END.
                    ELSE
                         ASSIGN aux_dtgener2 = crawepr.dtvencto.

                    ASSIGN aux_dtgeneri = ADD-INTERVAL(aux_dtgener2, 
                                                       crawepr.qtpreemp,
                                                       "MONTH").
                           w_cocr01.dtfimope = 
                                         STRING(YEAR(aux_dtgeneri),"9999")  +
                                         STRING(MONTH(aux_dtgeneri),"99")   +
                                         STRING(DAY(aux_dtgeneri),"99").
    
                    ASSIGN w_cocr01.nrdiacar = aux_dtgener2 - crapris.dtinictr.
                    
                    /* Quando o contrato eh efetivado e o colaborador
                       não faz os ajustes das datas do emprestimo */
                    IF   w_cocr01.nrdiacar < 0 OR
                         w_cocr01.nrdiacar = ?    THEN
                         DO:
                            IF  w_cocr01.nrdiacar = ? OR
                               (crawepr.dtdpagto - crawepr.dtmvtolt) < 0 OR
                               (crawepr.dtdpagto - crawepr.dtmvtolt) = ?    THEN
                                ASSIGN w_cocr01.nrdiacar = 30.
                            ELSE
                                ASSIGN w_cocr01.nrdiacar = 
                                       crawepr.dtdpagto - crawepr.dtmvtolt.
                         END.
                 END.
            ELSE
                 ASSIGN w_cocr01.dtfimope = "19010101".
           
            FIND crapepr WHERE 
                 crapepr.cdcooper = glb_cdcooper     AND
                 crapepr.nrdconta = crapris.nrdconta AND
                 crapepr.nrctremp = crapris.nrctremp NO-LOCK 
                 NO-ERROR.
    
            IF  AVAIL crapepr  THEN
                DO:  
                   RUN verifica_garantia (INPUT crapepr.nrctaav1,
                                          INPUT crapepr.nrctaav2,
                                          INPUT crapris.cdorigem).

                   ASSIGN w_cocr01.qtpresta = crapepr.qtpreemp
                          w_cocr01.qtpreabr = INT(crapepr.qtprecal).

                   IF  crapris.qtdiaatr <> 0 AND
                       crapris.qtdiaatr <> ?     THEN
                       DO:
                           ASSIGN aux_dtgeneri = glb_dtmvtolt - crapris.qtdiaatr
                                  w_cocr01.dtpromov = 
                                          STRING(YEAR(aux_dtgeneri),"9999") +
                                          STRING(MONTH(aux_dtgeneri), "99") +
                                          STRING(DAY(aux_dtgeneri), "99"). 
                        END.
                   ELSE
                        DO:
                           IF   crapepr.dtdpagto = ?   THEN
                                ASSIGN w_cocr01.dtpromov = "19010101".
                           ELSE
                                ASSIGN w_cocr01.dtpromov = 
                                       STRING(YEAR(crapepr.dtdpagto),"9999") +
                                       STRING(MONTH(crapepr.dtdpagto), "99") +
                                       STRING(DAY(crapepr.dtdpagto), "99").
                        END.
                   
                   FIND craplcr WHERE 
                        craplcr.cdcooper = glb_cdcooper     AND
                        craplcr.cdlcremp = crapepr.cdlcremp
                        NO-LOCK NO-ERROR.
    
                   IF  AVAIL craplcr  THEN
                       ASSIGN w_cocr01.vltaxjur = ROUND(((EXP(1 + 
                              (craplcr.txmensal / 100),  12) - 1) * 100),6).
                END.
            ELSE
                ASSIGN w_cocr01.dtpromov = "19010101".
        END.
    
        WHEN 4 THEN DO:
            ASSIGN w_cocr01.nrdcosif = 16130005
                   w_cocr01.qtpresta = 1
                   w_cocr01.qtpreabr = 1
                   w_cocr01.cdsitcob = 1.
    
            FIND LAST craptdb WHERE
                      craptdb.cdcooper = glb_cdcooper     AND
                      craptdb.nrdconta = crapris.nrdconta AND
                      craptdb.nrctrlim = crapris.nrctremp NO-LOCK
                      NO-ERROR.
    
            IF   AVAILABLE craptdb   THEN
                 ASSIGN w_cocr01.dtfimope = 
                          STRING(YEAR(craptdb.dtvencto), "9999") +
                          STRING(MONTH(craptdb.dtvencto), "99")  +
                          STRING(DAY(craptdb.dtvencto), "99").
            ELSE
                 ASSIGN w_cocr01.dtfimope = "19010101".
    
            FIND craplim WHERE 
                 craplim.cdcooper = glb_cdcooper     AND
                 craplim.nrdconta = crapris.nrdconta AND
                 craplim.tpctrlim = 3                AND
                 craplim.nrctrlim = crapris.nrctremp NO-LOCK 
                 NO-ERROR.
    
            IF   AVAIL craplim  THEN
                 DO:
                    RUN verifica_garantia (INPUT craplim.nrctaav1,
                                           INPUT craplim.nrctaav2,
                                           INPUT crapris.cdorigem).
                 
                    FIND crapldc WHERE 
                         crapldc.cdcooper = glb_cdcooper     AND
                         crapldc.tpdescto = 3                AND
                         crapldc.cddlinha = craplim.cddlinha
                         NO-LOCK NO-ERROR.
    
                    IF  AVAIL crapldc  THEN
                        ASSIGN w_cocr01.vltaxjur = ROUND(((EXP(1 + 
                              (crapldc.txmensal / 100),  12) - 1) * 100),6).
                 END.
    
            FIND FIRST craptdb WHERE
                       craptdb.cdcooper =  glb_cdcooper     AND
                       craptdb.nrdconta =  crapris.nrdconta AND
                       craptdb.dtvencto >= glb_dtmvtolt     AND
                       craptdb.nrctrlim =  crapris.nrctremp 
                       NO-LOCK NO-ERROR.
    
            IF   AVAIL craptdb  THEN
                 DO:
                     IF   craptdb.dtvencto = ?   THEN
                          ASSIGN w_cocr01.dtpromov = "19010101".
                     ELSE
                          ASSIGN w_cocr01.dtpromov = 
                                   STRING(YEAR(craptdb.dtvencto),"9999") +
                                   STRING(MONTH(craptdb.dtvencto),"99")  +
                                   STRING(DAY(craptdb.dtvencto),"99").
                 END.
            ELSE
                 ASSIGN w_cocr01.dtpromov = "19010101".
        END.
    
    END CASE.
           
    CASE crapris.innivris:
         WHEN 1 THEN ASSIGN w_cocr01.nrcosif2 = 31100003
                            w_cocr01.dsnivris = "AA".
         WHEN 2 THEN ASSIGN w_cocr01.nrcosif2 = 31200006
                            w_cocr01.dsnivris = "A".
         WHEN 3 THEN ASSIGN w_cocr01.nrcosif2 = 31300009
                            w_cocr01.dsnivris = "B".
         WHEN 4 THEN ASSIGN w_cocr01.nrcosif2 = 31400002
                            w_cocr01.dsnivris = "C".
         WHEN 5 THEN ASSIGN w_cocr01.nrcosif2 = 31500005
                            w_cocr01.dsnivris = "D".
         WHEN 6 THEN ASSIGN w_cocr01.nrcosif2 = 31600008
                            w_cocr01.dsnivris = "E".
         WHEN 7 THEN ASSIGN w_cocr01.nrcosif2 = 31700001
                            w_cocr01.dsnivris = "F".
         WHEN 8 THEN ASSIGN w_cocr01.nrcosif2 = 31800004
                            w_cocr01.dsnivris = "G".
         OTHERWISE ASSIGN   w_cocr01.nrcosif2 = 31900007
                            w_cocr01.dsnivris = "H".
    END CASE.
    
    FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                           craptab.nmsistem = "CRED"        AND
                           craptab.tptabela = "GENERI"      AND
                           craptab.cdempres = 00            AND
                           craptab.cdacesso = "PROVISAOCL"  
                           NO-LOCK:
        
        IF   TRIM(SUBSTR(craptab.dstextab,8,3)) = 
                                         w_cocr01.dsnivris   THEN
             DO:
                 ASSIGN w_cocr01.vlprovis = 
                         (DECIMAL(SUBSTR(craptab.dstextab,1,6)) *
                          crapris.vldivid ) / 100.
                 LEAVE.
             END.
    END. /* Fim do FOR EACH - craptab */
END. /* Fim do FOR EACH - crapris */

/* Ajusta os 10, 20, 50 e 100 maiores depositos a vista/prazo */
FOR EACH w_depositos BREAK BY w_depositos.vlsaldos DESCENDING:

    IF   w_depositos.tpdepost = 1   THEN
         DO:
            ASSIGN aux_contadav       =  aux_contadav + 1

                   w_cada01.vldpav10  =  IF   aux_contadav <= 10   THEN
                                              w_cada01.vldpav10 + 
                                              w_depositos.vlsaldos
                                         ELSE w_cada01.vldpav10
                   w_cada01.vldpav20  =  IF   aux_contadav <= 20   THEN
                                              w_cada01.vldpav20 + 
                                              w_depositos.vlsaldos
                                         ELSE w_cada01.vldpav20
                   w_cada01.vldpav50  =  IF   aux_contadav <= 50   THEN
                                              w_cada01.vldpav50 + 
                                              w_depositos.vlsaldos
                                         ELSE w_cada01.vldpav50
                   w_cada01.vldpav100 =  w_cada01.vldpav100 + 
                                         w_depositos.vlsaldos.
         END.
    ELSE
         DO:
            ASSIGN aux_contadap       =  aux_contadap + 1
                   
                   w_cada01.vldpap10  =  IF   aux_contadap <= 10   THEN
                                              w_cada01.vldpap10 + 
                                              w_depositos.vlsaldos
                                         ELSE w_cada01.vldpap10
                   w_cada01.vldpap20  =  IF   aux_contadap <= 20   THEN
                                              w_cada01.vldpap20 + 
                                              w_depositos.vlsaldos
                                         ELSE w_cada01.vldpap20
                   w_cada01.vldpap50  =  IF   aux_contadap <= 50   THEN
                                              w_cada01.vldpap50 + 
                                              w_depositos.vlsaldos
                                         ELSE w_cada01.vldpap50
                   w_cada01.vldpap100 =       w_cada01.vldpap100 + 
                                              w_depositos.vlsaldos.
         END.
END.

/* Cria o arquivo CADA01 */
FIND FIRST w_cada01 NO-ERROR.
    
IF   AVAILABLE w_cada01   THEN
     DO:
        IF   w_cada01.nrasscop > 100000  THEN
             w_cada01.nrasscop = 99999.

        IF   w_cada01.nrassatv > 100000  THEN
             w_cada01.nrassatv = 99999.
        
        OUTPUT STREAM str_1 TO VALUE ("/usr/coop/cecred/arq/CADA01.lst") APPEND.
        
        RUN cria_header (INPUT "CADA01",
                         INPUT 71).

        PUT STREAM str_1 aux_dsheader FORMAT "x(400)" SKIP.
        
        PUT STREAM str_1 
               SUBSTRING(STRING(crapcop.nrdocnpj,"99999999"),1,8) 
                                                       FORMAT "x(8)"
                         w_cada01.nrasscop             FORMAT "99999"
                         w_cada01.nrassatv             FORMAT "99999"
                         w_cada01.nrassfun             FORMAT "999"
          REPLACE(STRING(w_cada01.vldpav10,"999999999.99"),",","")
                                                       FORMAT "x(11)"
          REPLACE(STRING(w_cada01.vldpav20,"999999999.99"),",","")
                                                       FORMAT "x(11)"
          REPLACE(STRING(w_cada01.vldpav50,"999999999.99"),",","")
                                                       FORMAT "x(11)"
          REPLACE(STRING(w_cada01.vldpav100,"999999999.99"),",","")
                                                       FORMAT "x(11)"
          REPLACE(STRING(w_cada01.vldpap10,"999999999.99"),",","")
                                                       FORMAT "x(11)"
          REPLACE(STRING(w_cada01.vldpap20,"999999999.99"),",","")
                                                       FORMAT "x(11)"               
          REPLACE(STRING(w_cada01.vldpap50,"999999999.99"),",","")
                                                       FORMAT "x(11)"  
          REPLACE(STRING(w_cada01.vldpap100,"999999999.99"),",","")
                                                       FORMAT "x(11)"  
                         SKIP.
     END.

/* Cria o arquivo RASS01 */
ASSIGN aux_contador = 0.

OUTPUT STREAM str_2 TO VALUE ("/usr/coop/cecred/arq/RASS01.lst") APPEND.

FOR EACH w_rass01:

    ASSIGN aux_contador = aux_contador + 1.

    IF   aux_contador = 1   THEN
         DO:  
            RUN cria_header (INPUT "RASS01",
                             INPUT 89).
            PUT STREAM str_2 aux_dsheader FORMAT "x(400)" SKIP.
         END.

    PUT STREAM str_2 
           SUBSTRING(STRING(crapcop.nrdocnpj,"99999999"),1,8) 
                                                   FORMAT "x(8)"
           SUBSTRING(STRING(b-crapcop.nrdocnpj),1,8) FORMAT "x(8)"
      f_zeros_direita(9,STRING(w_rass01.nrmatric)) FORMAT "x(9)"
                     w_rass01.tpcpfcgc             FORMAT "z"
                     w_rass01.nrcpfcgc             FORMAT "99999999999999"
                     w_rass01.nmprimtl             FORMAT "x(30)"
                     w_rass01.cdnvlcgo             FORMAT "zzzz"
      REPLACE(STRING(w_rass01.vlttcota,"999999999999999.99"),",","")
                                                   FORMAT "x(17)"
      REPLACE(STRING(w_rass01.vlcotint,"999999999999999.99"),",","")
                                                   FORMAT "x(17)"
                     w_rass01.dtadmiss             FORMAT "x(8)"
                     w_rass01.flgrisco             FORMAT "S/N"
                     w_rass01.dsnivris             FORMAT "x(2)"
                     w_rass01.dtaturat             FORMAT "x(8)" 
                     SKIP.

END. /* Fim do FOR EACH - w_rass01 */

/* Cria o arquivo CDPZ01 */
ASSIGN aux_contador = 0.

OUTPUT STREAM str_3 TO VALUE ("/usr/coop/cecred/arq/CDPZ01.lst") APPEND.

FOR EACH w_cdpz01:

    ASSIGN aux_contador = aux_contador + 1.

    IF   aux_contador = 1   THEN
         DO:  
            RUN cria_header (INPUT "CDPZ01",
                             INPUT 100).
            PUT STREAM str_3 aux_dsheader FORMAT "x(400)" SKIP.
         END.

    PUT STREAM str_3 
           SUBSTRING(STRING(crapcop.nrdocnpj,"99999999"),1,8) 
                                                   FORMAT "x(8)"
                     w_cdpz01.tpcpfcgc             FORMAT "z"
                     w_cdpz01.nrcpfcgc             FORMAT "99999999999999"
     f_zeros_direita(9, STRING(w_cdpz01.nrmatric)) FORMAT "x(9)"
                     w_cdpz01.dtdcapta             FORMAT "x(8)"
                     w_cdpz01.dtdovenc             FORMAT "x(8)"
      REPLACE(STRING(w_cdpz01.vldcapta,"999999999999999.99"),",","")
                                                   FORMAT "x(17)"
                     w_cdpz01.nrdindex             FORMAT "9999"
      REPLACE(STRING(w_cdpz01.perindex,"999.99"),",","")
                                                   FORMAT "x(5)"
                     w_cdpz01.snoperac             FORMAT "x(1)"
      REPLACE(STRING(w_cdpz01.txoperac,"999.99999"),",","")
                                                   FORMAT "x(8)"
                     w_cdpz01.nrdctcon             FORMAT "zzzzzzzz"
      REPLACE(STRING(w_cdpz01.vlsalcon,"999999999999999.99"),",","")
                                                   FORMAT "x(17)"
                     SKIP.
END. /* Fim do FOR EACH - w_cdpz01 */

/* Cria o arquivo CDVT01 */
ASSIGN aux_contador = 0.

OUTPUT STREAM str_4 TO VALUE ("/usr/coop/cecred/arq/CDVT01.lst") APPEND.

FOR EACH w_cdvt01:
    
    ASSIGN aux_contador = aux_contador + 1.

    IF   aux_contador = 1   THEN
         DO:  
            RUN cria_header (INPUT "CDVT01",
                             INPUT 97).
            PUT STREAM str_4 aux_dsheader FORMAT "x(400)" SKIP.
         END.

    /* Se for negativo de conter o sinal e 16 posições */
    ASSIGN aux_vlsalcon = IF   w_cdvt01.vlsalcon < 0   THEN
                               REPLACE(STRING(w_cdvt01.vlsalcon,
                                              "-99999999999999.99"),",","")
                          ELSE
                               REPLACE(STRING(w_cdvt01.vlsalcon,
                                              "999999999999999.99"),",","").
    PUT STREAM str_4
           SUBSTRING(STRING(crapcop.nrdocnpj,"99999999"),1,8) 
                                                   FORMAT "x(8)"
                    w_cdvt01.tpcpfcgc              FORMAT "z"
                    w_cdvt01.nrcpfcgc              FORMAT "99999999999999"
     f_zeros_direita(9,STRING(w_cdvt01.nrmatric))  FORMAT "x(9)"
     f_zeros_direita(15,STRING(w_cdvt01.nrdconta)) FORMAT "x(15)"
                    w_cdvt01.nrdctcon              FORMAT "99999999"
                    aux_vlsalcon                   FORMAT "x(17)"
     REPLACE(STRING(w_cdvt01.vllimite,"999999999999999.99"),",","")
                                                   FORMAT "x(17)"  
                    w_cdvt01.dtinisal              FORMAT "x(8)"
                    w_cdvt01.dtadmiss              FORMAT "x(8)"
                    SKIP.

END. /* Fim do FOR EACH - w_cdvt01 */

/* Cria o arquivo COCR01 */
ASSIGN aux_contador = 0.

OUTPUT STREAM str_5 TO VALUE ("/usr/coop/cecred/arq/COCR01.lst") APPEND.

FOR EACH w_cocr01:

    ASSIGN aux_contador = aux_contador + 1.

    IF   aux_contador = 1   THEN
         DO:  
            RUN cria_header (INPUT "COCR01",
                             INPUT 278).
            PUT STREAM str_5 aux_dsheader FORMAT "x(400)" SKIP.
         END.

    PUT STREAM str_5
           SUBSTRING(STRING(crapcop.nrdocnpj,"99999999"),1,8) 
                                                   FORMAT "x(8)"
                     w_cocr01.tpcpfcgc             FORMAT "z"
                     w_cocr01.nrcpfcgc             FORMAT "99999999999999"
     f_zeros_direita(17,STRING(w_cocr01.nrctremp)) FORMAT "x(17)"
                     w_cocr01.nrdcosif             FORMAT "zzzzzzzz"
                     w_cocr01.nrcosif2             FORMAT "zzzzzzzz"
                     w_cocr01.dsnivris             FORMAT "x(2)"
                     w_cocr01.dtrisope             FORMAT "x(8)"
      REPLACE(STRING(w_cocr01.vlprovis,"999999999999999.99"),",","")
                                                   FORMAT "x(17)"  
                     w_cocr01.cdmodali             FORMAT "9999"
                     w_cocr01.dtiniope             FORMAT "x(8)"
                     w_cocr01.dtfimope             FORMAT "x(8)"
      REPLACE(STRING(w_cocr01.vlctremp,"999999999999999.99"),",","")
                                                   FORMAT "x(17)"  
      REPLACE(STRING(w_cocr01.vltaxjur,"999.99999"),",","")
                                                   FORMAT "x(8)"  
                     w_cocr01.cdindcor             FORMAT "999"
                     w_cocr01.tpgaran1             FORMAT "x(1)"
                     w_cocr01.tpgaran2             FORMAT "x(1)"
                     w_cocr01.tpgaran3             FORMAT "x(1)"
                     w_cocr01.pergara1             FORMAT "999"
                     w_cocr01.pergara2             FORMAT "999"
                     w_cocr01.pergara3             FORMAT "999"
                     w_cocr01.dsformpg             FORMAT "x(1)"

                    /* Ver com a Magui */
                     w_cocr01.nrdiacar             FORMAT "99999"     
                     w_cocr01.qtpresta             FORMAT "999"
                     w_cocr01.qtpreabr             FORMAT "999"
                     w_cocr01.dtpromov             FORMAT "x(8)"
      REPLACE(STRING(w_cocr01.vldivida,"999999999999999.99"),",","")
                                                   FORMAT "x(17)"
                     w_cocr01.cdrenego             FORMAT "z"
                     w_cocr01.cdsitcob             FORMAT "z"
      f_zeros_direita(9,STRING(w_cocr01.nrmatric)) FORMAT "x(9)"
      REPLACE(STRING(w_cocr01.vllimite,"999999999999999.99"),",","")
                                                   FORMAT "x(17)"
      REPLACE(STRING(w_cocr01.vlrdobem,"999999999999999.99"),",","")
                                                   FORMAT "x(17)"
                     w_cocr01.coddobem             FORMAT "z"
                     w_cocr01.dtiniorg             FORMAT "x(8)"
                     w_cocr01.qtdiaatr             FORMAT "999"
                     w_cocr01.inrisorg             FORMAT "x(2)"
      REPLACE(STRING(w_cocr01.vlsdeved,"999999999999999.99"),",","")
                                                   FORMAT "x(17)"
                     w_cocr01.peramort             FORMAT "99999"
      REPLACE(STRING(w_cocr01.vlmaipar,"999999999999999.99"),",","")
                                                   FORMAT "x(17)"
                     w_cocr01.dtvenpar             FORMAT "x(8)"
                     SKIP.
END. /* Fim do FOR EACH - w_cocr01 */


RUN fontes/fimprg.p.

/******************************************************************************/
/*                                 PROCEDURES                                 */
/******************************************************************************/
PROCEDURE cria_header:

DEFINE INPUT PARAMETER aux_tparquiv  AS CHAR     NO-UNDO.
/* Colocar zeros em quantidades suficiente para completar este cabecalho com
   o mesmo tamanho que as demais linhas de dados do arquivo correspondente */
DEFINE INPUT PARAMETER aux_tamfiller AS INTEGER  NO-UNDO.

/* Cria o HEADER */
ASSIGN aux_dsheader = "00000000" + /* CNPJ da Confederacao - Nao tem */
/* CNPJ da Central */ SUBSTRING(STRING(b-crapcop.nrdocnpj,"99999999999999"),1,8) +  
/* CNPJ da Coop.   */ SUBSTRING(STRING(crapcop.nrdocnpj,"99999999999999"),1,8) +
/* DATA-BASE - ANO */ STRING(YEAR(glb_dtmvtolt),"9999") +
/* DATA-BASE - MES */ STRING(MONTH(glb_dtmvtolt),"99")  +
/* DATA-BASE - DIA */ STRING(DAY(glb_dtmvtolt), "99")   +
/* Nome do arquivo */ aux_tparquiv                      +
/* FILLER          */ FILL("0", aux_tamfiller).

END PROCEDURE.

/******************************************************************************/

PROCEDURE proc_cria_depositos:
   
DEFINE INPUT PARAMETER par_nrdconta AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER par_ttsaldos AS DECIMAL NO-UNDO.
DEFINE INPUT PARAMETER par_tpdepost AS INTEGER NO-UNDO.

IF   par_tpdepost = 1   THEN
     DO:
         ASSIGN aux_contador = aux_contador + 1.
         IF   aux_contador <= 100   THEN
              DO:
                 CREATE w_depositos.
                 ASSIGN w_depositos.sequence = aux_contador
                        w_depositos.nrdconta = par_nrdconta
                        w_depositos.vlsaldos = par_ttsaldos
                        w_depositos.tpdepost = par_tpdepost.
                  
                 RETURN "OK".
              END.

         RETURN "NOK".
     END.

FIND LAST w_depositos WHERE w_depositos.tpdepost = par_tpdepost NO-LOCK NO-ERROR.

IF   NOT AVAILABLE w_depositos  THEN
     DO:
        CREATE w_depositos.
        ASSIGN w_depositos.nrdconta = par_nrdconta
               w_depositos.vlsaldos = par_ttsaldos
               w_depositos.sequence = 1
               w_depositos.tpdepost = par_tpdepost.

        RETURN "OK".
     END.

ASSIGN aux_sequence = w_depositos.sequence
       aux_nrdconta = w_depositos.nrdconta
       aux_vlsaldos = w_depositos.vlsaldos.

IF   w_depositos.sequence = 100   THEN
     DO:
        FOR EACH w_depositos WHERE w_depositos.tpdepost = par_tpdepost NO-LOCK
                                   BREAK BY w_depositos.vlsaldos.
            
            ASSIGN aux_nrdconta = w_depositos.nrdconta
                   aux_vlsaldos = w_depositos.vlsaldos 
                   aux_sequence = w_depositos.sequence.
            LEAVE.
        END.

        /* Se o saldo atual for maior que o menor saldo
           da temp-table, deletar o menor saldo da temp-table e
           incluir o atual. */
        IF   par_ttsaldos > aux_vlsaldos   THEN
             DO:
                FIND w_depositos WHERE w_depositos.sequence = aux_sequence AND
                                       w_depositos.nrdconta = aux_nrdconta AND
                                       w_depositos.tpdepost = par_tpdepost.

                IF   AVAILABLE w_depositos   THEN
                     ASSIGN w_depositos.nrdconta = par_nrdconta
                            w_depositos.vlsaldos = par_ttsaldos.
             END.
     
     END.    
ELSE
     DO:
        CREATE w_depositos.
        ASSIGN w_depositos.sequence = aux_sequence + 1
               w_depositos.nrdconta = par_nrdconta
               w_depositos.vlsaldos = par_ttsaldos
               w_depositos.tpdepost = par_tpdepost.
     END.

RETURN "OK".

END PROCEDURE.  

PROCEDURE verifica_garantia:

DEFINE INPUT PARAMETER par_nrdconta1 AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER par_nrdconta2 AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER par_cdorigem  AS INTEGER NO-UNDO.

DEFINE VARIABLE aux_vercpfcgc        AS DECIMAL     NO-UNDO.

IF   par_nrdconta1 <> 0   THEN
     DO:
        FIND crabass WHERE crabass.cdcooper = glb_cdcooper AND
                           crabass.nrdconta = par_nrdconta1
                           NO-LOCK NO-ERROR.
     
        IF   AVAILABLE crabass   THEN
             DO:
                ASSIGN w_cocr01.tpgaran1 = "w"  
                       aux_vercpfcgc     = crabass.nrcpfcgc
                       w_cocr01.pergara1 = 100.
             END.
     END.
 
IF   par_nrdconta2 <> 0  AND par_nrdconta2 <> par_nrdconta1 THEN  
     DO:
        FIND crabass WHERE crabass.cdcooper = glb_cdcooper AND
                           crabass.nrdconta = par_nrdconta2 
                           NO-LOCK NO-ERROR.
      
        IF   AVAILABLE crabass   THEN
             DO:
                IF   aux_vercpfcgc <> crabass.nrcpfcgc   THEN
                     DO:
                        ASSIGN  w_cocr01.tpgaran2 = "w"  
                                w_cocr01.pergara2 = 100.
                     END.
             END.
     END.

ASSIGN aux_contador = 0.

IF   par_cdorigem = 3   THEN
     DO:
        IF   NOT AVAILABLE crawepr    THEN
             RETURN.

        /* Garantia das aplicacoes */
        FOR EACH crapadt WHERE crapadt.cdcooper = glb_cdcooper     AND
                               crapadt.nrdconta = crapepr.nrdconta AND
                               crapadt.nrctremp = crapepr.nrctremp AND
                               crapadt.cdaditiv = 2                AND
                               crapadt.tpctrato = 90 /* Emprestimo/Financiamento */
                               NO-LOCK:

            FOR EACH crapadi WHERE crapadi.cdcooper = glb_cdcooper     AND
                                   crapadi.nrdconta = crapadt.nrdconta AND
                                   crapadi.nrctremp = crapadt.nrctremp AND
                                   crapadi.tpctrato = crapadt.tpctrato NO-LOCK:
                
                FIND FIRST craptab WHERE 
                           craptab.cdcooper = glb_cdcooper               AND   
                           craptab.nmsistem = "CRED"                     AND
                           craptab.tptabela = "BLQRGT"                   AND
                           craptab.cdempres = 00                         AND
                           craptab.cdacesso =               
                                   STRING(crapadi.nrdconta,"9999999999") AND
                INT(SUBSTR(craptab.dstextab,1,7)) = crapadi.nraplica NO-LOCK 
                           NO-ERROR.

                IF    AVAILABLE craptab    THEN
                      DO:
                         FIND craprda WHERE 
                              craprda.cdcooper = glb_cdcooper     AND
                              craprda.nrdconta = crapadi.nrdconta AND
                              craprda.nraplica = crapadi.nraplica NO-LOCK 
                              NO-ERROR.

                          IF   NOT AVAILABLE craprda    THEN
                               ASSIGN aux_perdaapl = 0.
                          ELSE
                               ASSIGN aux_perdaapl = (craprda.vlaplica * 100) / 
                                                      crapepr.vlemprst.

                          IF   aux_perdaapl > 100   THEN
                               ASSIGN aux_perdaapl = 100.

                          IF   w_cocr01.tpgaran1 = "y"   THEN
                               DO:
                                  ASSIGN w_cocr01.tpgaran1 = "a"
                                         w_cocr01.pergara1 = aux_perdaapl.
                               END.
                          ELSE
                          IF   w_cocr01.tpgaran2 = "y"   THEN
                               DO:
                                  ASSIGN w_cocr01.tpgaran2 = "a"
                                         w_cocr01.pergara2 = aux_perdaapl.
                               END.
                          ELSE
                          IF   w_cocr01.tpgaran3 = "y"   THEN
                               DO:
                                  ASSIGN w_cocr01.tpgaran3 = "a"
                                         w_cocr01.pergara3 = aux_perdaapl.
                               END.
                          ELSE
                               RETURN.
                      END.

            END. /* Fim do FOR EACH - crapadi */
        END. /* Fim do FOR EACH - crapadt */

        /* Garantia dos Bens */
        FOR EACH crapbpr WHERE crapbpr.cdcooper = glb_cdcooper       AND
                               crapbpr.nrdconta = crawepr.nrdconta   AND
                               crapbpr.tpctrpro = 90                 AND
                               crapbpr.nrctrpro = crawepr.nrctremp   AND
                               crapbpr.flgalien = TRUE               NO-LOCK:
                               
            IF   crapbpr.dscatbem MATCHES "*AUTOMOVEL*"  OR
                 crapbpr.dscatbem MATCHES "*MOTO*"       OR 
                 crapbpr.dscatbem MATCHES "*CAMINHAO*"   THEN 
                 ASSIGN aux_dsgarant = "m".
            ELSE
            IF   crapbpr.dscatbem MATCHES "*MAQUINA*"      OR
                 crapbpr.dscatbem MATCHES "*EQUIPAMENTO*"  THEN
                 ASSIGN aux_dsgarant = "n".
            ELSE
            IF   crapbpr.dscatbem MATCHES "*TERRENO*"  OR
                 crapbpr.dscatbem MATCHES "*CASA*"    OR 
                 crapbpr.dscatbem MATCHES "**"        THEN
                 ASSIGN aux_dsgarant = "o". 
            ELSE
                NEXT.
            
            IF   w_cocr01.tpgaran1 = "y"   THEN
                 DO:
                    ASSIGN w_cocr01.tpgaran1 = aux_dsgarant
                           w_cocr01.pergara1 = 100.
                 END.
            ELSE
            IF   w_cocr01.tpgaran2 = "y"   THEN
                 DO:
                    ASSIGN w_cocr01.tpgaran2 = aux_dsgarant
                           w_cocr01.pergara2 = 100.
                 END.
            ELSE
            IF   w_cocr01.tpgaran3 = "y"   THEN
                 DO:
                    ASSIGN w_cocr01.tpgaran3 = aux_dsgarant
                           w_cocr01.pergara3 = 100.
                 END.
            ELSE
                 RETURN.
        
        END. /* Fim do FOR EACH bens alienados */
     END.

END PROCEDURE.

/* ..........................................................................*/

