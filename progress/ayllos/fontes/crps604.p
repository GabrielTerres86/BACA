/* ..........................................................................

   Programa: Fontes/crps604.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gati - Oliver
   Data    : Agosto/2011.                  Ultima atualizacao: 16/06/2015

   Dados referentes ao programa:

   Frequencia : Diario. Solicitacao 1 / Ordem 36 / Cadeia Exclusiva.
   Objetivo   : Realizar a renovacao dos seguros residenciais.
   
   Alteracoes: 08/12/2011 - Incluida validacao chave tabela crawseg (Diego).
   
               19/12/2011 - Incluido a passagem do parametro crawseg.dtnascsg
                            na procedure cria_seguro (Adriano).
   
               27/02/2013 - Incluir parametro aux_flgsegur na procedure 
                            cria_seguro (Lucas R.).
                            
               25/07/2013 - Incluido o parametro "crawseg.complend" na
                            chamada da procedure "cria_seguro()". (James)
                            
               29/04/2014 - Considerar o valor do plano no novo seguro e 
                            nao mais o valor do antigo seguro (Jonata-RKAM).
                            
               10/11/2014 - Por enquanto, foi retirado o tratamento 
                            de renovacao automatica dos seguros de vida
                            (Jonata-RKAM). 
                            
               13/02/2015 - Ajuste para incluir a renovacao automatica do 
                            seguro de vida.(James)
                            
               16/06/2015 - Incluir a renovacao do seguro de vida no Oracle.
                            (James)
............................................................................. */
{ includes/var_batch.i }
{ includes/var_seguro.i }

/* Include com a tt-erro */
{ sistema/generico/includes/var_internet.i }


DEF BUFFER w_crawseg  FOR crawseg.
DEF BUFFER w2_crawseg FOR crawseg.

DEF VAR aux_nrctrseg LIKE crawseg.nrctrseg                            NO-UNDO.
DEF VAR aux_flgsegur AS LOG                                           NO-UNDO.
DEF VAR aux_dtfimvig AS DATE                                          NO-UNDO.
DEF VAR aux_contador AS INTE                                          NO-UNDO.

ASSIGN glb_cdprogra = "crps604".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

/* Renovacao do Seguro Residencial */
FOR EACH crapseg NO-LOCK WHERE
         crapseg.cdcooper  = glb_cdcooper        AND 
         crapseg.tpseguro  = 11                  AND /* Residencia */
         CAN-DO("1,3", STRING(crapseg.cdsitseg)) AND /* Novo, Renovado  */
         crapseg.dtfimvig  > glb_dtmvtolt        AND
         crapseg.dtfimvig <= glb_dtmvtopr:
    
    FIND FIRST crawseg NO-LOCK WHERE
               crawseg.cdcooper = crapseg.cdcooper AND
               crawseg.nrdconta = crapseg.nrdconta AND
               crawseg.tpseguro = crapseg.tpseguro AND
               crawseg.nrctrseg = crapseg.nrctrseg 
               NO-ERROR.
    
    FIND craptsg WHERE
         craptsg.cdcooper = crapseg.cdcooper AND
         craptsg.tpplaseg = crapseg.tpplaseg AND
         craptsg.cdsegura = crapseg.cdsegura AND
         craptsg.tpseguro = crapseg.tpseguro  
         NO-LOCK NO-ERROR.

    IF   NOT AVAIL craptsg THEN 
         NEXT.

    /* nao eh dia util */
    IF (CAN-DO("1,7",STRING(WEEKDAY(DATE(MONTH(crawseg.dtfimvig),
                                         DAY(crawseg.dtfimvig),
                                         YEAR(crawseg.dtfimvig)))))OR
        /* eh feriado */
        CAN-FIND(crapfer WHERE 
                 crapfer.cdcooper = crapseg.cdcooper AND
                 crapfer.dtferiad = DATE(MONTH(crawseg.dtfimvig),
                                         DAY(crawseg.dtfimvig),
                                         YEAR(crawseg.dtfimvig)))) THEN
                                         
        /* Se a data do vencimento esta no proximo mes, devera efetuar
           o primeiro debito no mes do vencimento, e devera aparecer no
           relatorio 416 no mes do vencimento. Caso contrario o 
           primeiro debito eh antecipado */
        IF   MONTH(glb_dtmvtolt) <> MONTH(crawseg.dtfimvig)  THEN
             ASSIGN aux_dtprideb = glb_dtmvtopr.
        ELSE
             ASSIGN aux_dtprideb = glb_dtmvtolt.
    ELSE
         /* Se nao for feriado efetua primeiro debito na data de inicio
            de vigencia do sego renovado */ 
         ASSIGN aux_dtprideb = crawseg.dtfimvig.
    
    /* Busca ultimo contrato de seguro CASA cadastrado */
    FIND LAST w2_crawseg NO-LOCK WHERE
              w2_crawseg.cdcooper = crawseg.cdcooper AND
              w2_crawseg.nrdconta = crawseg.nrdconta AND
             (w2_crawseg.tpseguro = 11 OR
              w2_crawseg.tpseguro = 1) NO-ERROR.
    
    /* Gera novo numero de contrato */ 
    IF   AVAIL w2_crawseg THEN
         ASSIGN aux_nrctrseg = w2_crawseg.nrctrseg + 1.
    ELSE
         ASSIGN aux_nrctrseg = 1.
    
    /* Validar chave da tabela crawseg ref. demais tipos seguros do 
       cooperado */ 
    DO WHILE TRUE:
    
        FIND w_crawseg WHERE w_crawseg.cdcooper = crawseg.cdcooper  AND
                             w_crawseg.nrdconta = crawseg.nrdconta  AND
                             w_crawseg.nrctrseg = aux_nrctrseg
                             NO-LOCK NO-ERROR.
    
        IF   NOT AVAIL w_crawseg THEN
             LEAVE.
        ELSE
             ASSIGN aux_nrctrseg = aux_nrctrseg + 1.  
    END.
    
    IF   NOT craptsg.flgunica   AND 
         crawseg.qtparcel <> 1  THEN
         DO:
            /* calcula a data para o proximo mes */
            RUN fontes/calcdata.p 
                     (INPUT DATE(MONTH(crawseg.dtfimvig),
                                 DAY(crawseg.dtdebito),
                                 YEAR(crawseg.dtfimvig)),
                      INPUT  1,
                      INPUT  "M",
                      INPUT  0,
                      OUTPUT aux_dtdebito).
         END.
    ELSE 
         /* Parcela unica */  
         ASSIGN aux_dtdebito = aux_dtprideb.
    
    RUN sistema/generico/procedures/b1wgen0033.p 
        PERSISTENT SET h-b1wgen0033.
    
    RUN cria_seguro IN h-b1wgen0033 
                         (INPUT glb_cdcooper,
                          INPUT 0,
                          INPUT 0,
                          INPUT glb_cdoperad,
                          INPUT glb_dtmvtolt,
                          INPUT crawseg.nrdconta,
                          INPUT 1, /*idseqttl*/
                          INPUT 1, /* idorigem */
                          INPUT glb_nmdatela,
                          INPUT FALSE,
                          INPUT 0, /* cdmotcan */
                          INPUT crawseg.cdsegura,
                          INPUT 3, /* cdsitseg */
                          INPUT "", /* dsgraupr1 */
                          INPUT "", /* dsgraupr2 */
                          INPUT "", /* dsgraupr3 */
                          INPUT "", /* dsgraupr4 */
                          INPUT "", /* dsgraupr5 */
                          INPUT ?, /* dtaltseg */
                          INPUT ?, /* dtcancel */
                          INPUT aux_dtdebito,
                          INPUT crawseg.dtfimvig + 365, /* dtfimvig */
                          INPUT crawseg.dtfimvig, /* dtiniseg */
                          INPUT crawseg.dtfimvig, /* dtinivig */
                          INPUT aux_dtprideb,
                          INPUT ?, /* dtultalt */
                          INPUT ?, /* dtultpag */
                          INPUT crapseg.flgclabe,
                          INPUT NO, /* flgconve */
                          INPUT craptsg.flgunica,
                          INPUT 0, /* indebito */
                          INPUT "", /* lsctrant */
                          INPUT crapseg.nmbenvid[1],
                          INPUT "", /* nmbenvid2 */
                          INPUT "", /* nmbenvid3 */
                          INPUT "", /* nmbenvid4 */
                          INPUT "", /* nmbenvid5 */
                          INPUT 0, /* nrctratu */
                          INPUT aux_nrctrseg,
                          INPUT 4151, /* nrdolote */
                          INPUT crawseg.qtparcel,
                          INPUT 0, /* qtprepag */
                          INPUT 0, /* qtprevig */
                          INPUT 0, /* tpdpagto */
                          INPUT crapseg.tpendcor,
                          /*INPUT 3, /* tpoperac - renovacao */*/
                          INPUT crawseg.tpplaseg,
                          INPUT crawseg.tpseguro,
                          INPUT 0, /* txpartic1 */
                          INPUT 0, /* txpartic3 */
                          INPUT 0, /* txpartic4 */
                          INPUT 0, /* txpartic5 */
                          INPUT 0, /* txpartic6 */
                          INPUT 0, /* vldifseg */
                          INPUT crawseg.vlpremio,
                          INPUT 0, /* vlprepag */
                          INPUT craptsg.vlplaseg,
                          INPUT 0, /* vlcapseg */
                          INPUT 200, /* Banco/Caixa cdbccxlt */
                          INPUT crawseg.nrcpfcgc,
                          INPUT crawseg.nmdsegur, /*nmdsegur*/
                          INPUT crawseg.vlpremio, /* vltotpre */
                          INPUT crawseg.cdcalcul,
                          INPUT crawseg.vlseguro,
                          INPUT crawseg.dsendres,
                          INPUT crawseg.nrendres,
                          INPUT crawseg.nmbairro,
                          INPUT crawseg.nmcidade,
                          INPUT crawseg.cdufresd,
                          INPUT crawseg.nrcepend,
                          INPUT 0, /*cdsexosg*/
                          INPUT 0, /*cdempres*/
                          INPUT crawseg.dtnascsg,
                          INPUT crawseg.complend,
                          OUTPUT aux_flgsegur, 
                          OUTPUT aux_crawseg,
                          OUTPUT TABLE tt-erro).
    
    DELETE PROCEDURE h-b1wgen0033.
    
    IF RETURN-VALUE <> "OK" THEN
       DO:
            FIND FIRST tt-erro NO-ERROR.
            IF AVAIL tt-erro THEN
                ASSIGN glb_dscritic = tt-erro.dscritic +
                                      " Tipo seguro: " +
                                      STRING(crawseg.tpseguro) +
                                      ". Conta: " +
                                      STRING(crawseg.nrdconta).
            ELSE
                ASSIGN glb_dscritic = "Nao foi possivel criar" +
                                      " o registro na crapseg." +
                                      " Tipo seguro: " +
                                      STRING(crawseg.tpseguro) +
                                      ". Conta: " +
                                      STRING(crawseg.nrdconta).
            /*RUN fontes/critic.p.*/
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                             " - " + glb_cdprogra + "' --> '"  +
                             "'" + glb_dscritic + "'" + 
                             " >> log/proc_batch.log").
            NEXT.
       END.

END. /* END FOR EACH REGURO RESIDENCIAL */

RUN fontes/fimprg.p.

/* ........................................................................ */
