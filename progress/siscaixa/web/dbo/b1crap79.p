/*-----------------------------------------------------------------------*//*  
b1crap79.p - Movimentacoes  - Estorno Pagamento Emprestimo           */
/*-----------------------------------------------------------------------*/
/*

    Alteracoes: 02/03/2006 - Unificacao dos Bancos - SQLWorks - Fernando
                
                16/02/2009 - Alteracao cdempres (Diego).
                
                20/05/2010 - Re-ativar Rating quando emprestimo estiver em 
                             aberto de novo (Gabriel).
                             
                07/02/2011 - Substituida temp-table workepr por tt-dados-epr e
                             substituida include gera_workepr pela chamada da
                             procedure obtem-dados-emprestimos. (Gabriel/DB1)
    
                21/05/2012 - substituição do FIND craptab para os registros 
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.)

                16/03/2018 - Substituida verificacao "cdtipcta = 6,7" pela
                             modalidade do tipo de conta igual a 3. PRJ366 (Lombardi).
----------------------------------------------------------------------------*/

{ dbo/bo-erro1.i }
{ sistema/generico/includes/var_internet.i }

DEFINE VARIABLE i-cod-erro  AS INT                      NO-UNDO.
DEFINE VARIABLE c-desc-erro AS CHAR                     NO-UNDO.

DEF VAR i-nro-lote          AS INTE                     NO-UNDO.
DEF VAR i_conta             AS DEC                      NO-UNDO.
DEF VAR aux_nrtrfcta LIKE  craptrf.nrsconta             NO-UNDO.
DEF VAR l-achou             AS LOG                      NO-UNDO.
DEF VAR inc_nrctremp LIKE  crapepr.nrctremp             NO-UNDO.


DEF VAR h_b2crap00          AS HANDLE                   NO-UNDO.

DEF VAR aux_contador        AS INTE                     NO-UNDO.
DEF VAR aux_lscontas        AS CHAR                     NO-UNDO.

DEF VAR in99                AS INTE                     NO-UNDO.

DEF BUFFER crabass FOR crapass.
DEF  VAR glb_cdcooper AS INT                                   NO-UNDO.

DEF  VAR aux_vljurmes AS DECIMAL FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF  VAR aux_vljuracu AS DECIMAL FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF  VAR aux_vlsdeved AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF  VAR aux_vlprepag AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF  VAR aux_txdjuros AS DECIMAL DECIMALS 7                    NO-UNDO.
DEF  VAR aux_nrdconta AS INT                                   NO-UNDO.
DEF  VAR aux_nrctremp AS INT                                   NO-UNDO.
DEF  VAR aux_qtprecal AS DECIMAL DECIMALS 4                    NO-UNDO.
DEF  VAR aux_dtmesant AS DATE                                  NO-UNDO.
DEF  VAR aux_nrdiacal AS INT                                   NO-UNDO.
DEF  VAR aux_inhst093 AS LOGICAL                               NO-UNDO.
DEF  VAR aux_ddlanmto AS INT                                   NO-UNDO.
DEF  VAR aux_dtultpag AS DATE                                  NO-UNDO.
DEF  VAR aux_qtprepag AS INT                                   NO-UNDO.
DEF  VAR aux_nrdiames AS INT                                   NO-UNDO.
DEF  VAR aux_nrdiamss AS INT                                   NO-UNDO.
DEF  VAR aux_vldescto AS DECIMAL                               NO-UNDO.
DEF  VAR aux_vltotemp AS DECIMAL                               NO-UNDO.
DEF  VAR aux_vltotpre AS DECIMAL                               NO-UNDO.
DEF  VAR aux_nrctatos AS INT                                   NO-UNDO.
DEF  VAR aux_cdpesqui AS CHAR    FORMAT "x(25)"                NO-UNDO.
DEF  VAR aux_qtpreapg AS DECIMAL DECIMALS 4                    NO-UNDO.
DEF  VAR aux_dtinipag AS DATE                                  NO-UNDO.
DEF  VAR aux_dslcremp AS CHAR    FORMAT "x(31)"                NO-UNDO.
DEF  VAR aux_dsfinemp AS CHAR    FORMAT "x(31)"                NO-UNDO.
DEF  VAR aux_dsdaval1 AS CHAR    FORMAT "x(42)"                NO-UNDO.
DEF  VAR aux_dsdaval2 AS CHAR    FORMAT "x(42)"                NO-UNDO.
DEF  VAR aux_dtrefavs AS DATE                                  NO-UNDO.
DEF  VAR aux_flghaavs AS LOGICAL                               NO-UNDO.
DEF  VAR aux_vltotprv AS DECIMAL                               NO-UNDO.
DEF  VAR aux_vlpresta LIKE crapepr.vlsdeved                    NO-UNDO.
DEF  VAR aux_dtcalcul AS DATE.
DEF  VAR aux_dtultdia AS DATE.
DEF  VAR aux_dtrefere AS DATE.
DEF  VAR aux_vlprovis AS DEC.

DEF  VAR epr_nrctremp AS INT     EXTENT 99                     NO-UNDO.
DEF  VAR epr_nrrecepr AS INT     EXTENT 99                     NO-UNDO.

DEF  VAR s_chextent   AS INTEGER                               NO-UNDO.
DEF  VAR s_vlsdeved   AS DECIMAL   EXTENT 100                  NO-UNDO.
DEF  VAR s_chlist     AS CHARACTER EXTENT 100                  NO-UNDO.

DEF  VAR ant_vlsdeved AS DECIMAL                               NO-UNDO.

DEF  VAR par_qtdialib AS INTE INITIAL 0                        NO-UNDO.


PROCEDURE valida-estorno.
    
    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-agencia   AS INT.   /* Cod. Agencia    */
    DEF INPUT  PARAM p-nro-caixa     AS INT.   /* Nro Caixa       */
    DEF INPUT  PARAM p-nro-conta     AS INT.   /* Nro Conta       */
    DEF INPUT  PARAM p-nrdocto       AS INT.
    DEF OUTPUT PARAM p-valor         AS DEC.
    DEF OUTPUT PARAM p-nome-titular  AS CHAR.

    DEF VAR aux_cdmodali             AS INTE NO-UNDO.
    DEF VAR aux_des_erro             AS CHAR NO-UNDO.
    DEF VAR aux_dscritic             AS CHAR NO-UNDO.
    
    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.

    ASSIGN p-nro-conta = INT(REPLACE(STRING(p-nro-conta),".","")).

    ASSIGN p-nome-titular = " "
           p-valor        = 0.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    ASSIGN i-nro-lote = 13000 + p-nro-caixa.
    
    IF  p-nrdocto = 0  THEN 
        DO:
            ASSIGN i-cod-erro  = 22
                   c-desc-erro = " ".  /* Documento deve ser Informado */                  RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
    
    IF  p-nro-conta = 0  THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Conta deve ser Informada".           
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    /*  Le tabela com as contas convenio do Banco do Brasil - Geral  */
        RUN fontes/ver_ctace.p(INPUT crapcop.cdcooper,
                               INPUT 0,
                               OUTPUT aux_lscontas).

    IF   NOT CAN-DO(aux_lscontas,STRING(p-nro-conta)) THEN 
         DO:

             FIND crapass WHERE 
                  crapass.cdcooper = crapcop.cdcooper  AND
                  crapass.nrdconta = p-nro-conta       NO-LOCK NO-ERROR.
                  
         IF  NOT AVAIL crapass  THEN  
             DO:
                 ASSIGN i-cod-erro  = 9   
                        c-desc-erro = " ".           
                 ruN cria-erro (INPUT p-cooper,
                                INPUT p-cod-agencia,
                                INPUT p-nro-caixa,
                                INPUT i-cod-erro,
                                INPUT c-desc-erro,
                                INPUT YES).
                 RETURN "NOK".
             END.

        ASSIGN p-nome-titular = crapass.nmprimtl.
        
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        
        RUN STORED-PROCEDURE pc_busca_modalidade_tipo
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.inpessoa, /* Tipo de pessoa */
                                             INPUT crapass.cdtipcta, /* Tipo de conta */
                                            OUTPUT 0,                /* Modalidade */
                                            OUTPUT "",               /* Flag Erro */
                                            OUTPUT "").              /* Descriçao da crítica */
        
        CLOSE STORED-PROC pc_busca_modalidade_tipo
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN aux_cdmodali = 0
               aux_des_erro = ""
               aux_dscritic = ""
               aux_cdmodali = pc_busca_modalidade_tipo.pr_cdmodalidade_tipo 
                              WHEN pc_busca_modalidade_tipo.pr_cdmodalidade_tipo <> ?
               aux_des_erro = pc_busca_modalidade_tipo.pr_des_erro 
                              WHEN pc_busca_modalidade_tipo.pr_des_erro <> ?
               aux_dscritic = pc_busca_modalidade_tipo.pr_dscritic
                              WHEN pc_busca_modalidade_tipo.pr_dscritic <> ?.
        
        IF aux_des_erro = "NOK"  THEN
            DO:
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = aux_dscritic.
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                RETURN "NOK".
            END.
        
        IF   aux_cdmodali = 3 THEN  DO: /* Conta tipo Poupan‡a */
             ASSIGN i-cod-erro  = 17 /* Tipo de Conta Errada */
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
        END.
    END.
  
    FIND craplem WHERE craplem.cdcooper = crapcop.cdcooper  AND
                       craplem.dtmvtolt = crapdat.dtmvtolt  AND
                       craplem.cdagenci = p-cod-agencia     AND
                       craplem.cdbccxlt = 11                AND
                       craplem.nrdolote = i-nro-lote        AND
                       craplem.nrdconta = p-nro-conta       AND
                       craplem.nrdocmto = p-nrdocto         NO-ERROR.
 
    IF  NOT AVAIL craplem THEN 
        DO:
            ASSIGN i-cod-erro  = 90
                   c-desc-erro = " ". 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
    
    ASSIGN p-valor = craplem.vllanmto.
    
    FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                       craplot.dtmvtolt = crapdat.dtmvtolt  AND
                       craplot.cdagenci = p-cod-agencia     AND
                       craplot.cdbccxlt = 11                AND  /* Fixo */
                       craplot.nrdolote = i-nro-lote        NO-LOCK NO-ERROR.

    IF   NOT AVAIL   craplot   THEN  
         DO:
              ASSIGN i-cod-erro  = 60
                     c-desc-erro = " ".           
              RUN cria-erro (INPUT p-cooper,
                             INPUT p-cod-agencia,
                             INPUT p-nro-caixa,
                             INPUT i-cod-erro,
                             INPUT c-desc-erro,
                             INPUT YES).
              RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE estorna-pagto.                
    
    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-agencia   AS INT.    /* Cod. Agencia       */
    DEF INPUT  PARAM p-nro-caixa     AS INT.    /* Numero Caixa       */
    DEF INPUT  PARAM p-cod-operador  AS CHAR.
    DEF INPUT  PARAM p-nro-conta     AS INT.    /* Nro Conta          */
    DEF INPUT  PARAM p-nrdocto       AS INT.
    DEF OUTPUT PARAM p-valor         AS DEC.
    DEF OUTPUT PARAM p-autestorno    AS INTE. /* autenticacao a ser estornada*/

    DEF VAR          h-b1wgen0043    AS HANDLE             NO-UNDO.


    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
 
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    ASSIGN p-nro-conta = INT(REPLACE(STRING(p-nro-conta),".","")).

    ASSIGN i-nro-lote  = 13000 + p-nro-caixa.
  
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper 
                             NO-LOCK NO-ERROR.
               
    FIND craplem WHERE craplem.cdcooper = crapcop.cdcooper  AND
                       craplem.dtmvtolt = crapdat.dtmvtolt  AND
                       craplem.cdagenci = p-cod-agencia     AND
                       craplem.cdbccxlt = 11                AND
                       craplem.nrdolote = i-nro-lote        AND
                       craplem.nrdconta = p-nro-conta       AND
                       craplem.nrdocmto = p-nrdocto         NO-LOCK NO-ERROR.
       
    IF   NOT AVAIL   craplem THEN 
         DO:
             ASSIGN i-cod-erro  = 90
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
            RETURN "NOK".
         END.

    FIND crapepr WHERE 
         crapepr.cdcooper = crapcop.cdcooper  AND
         crapepr.nrdconta = craplem.nrdconta  AND
         crapepr.nrctremp = craplem.nrctremp  NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapepr   THEN  
         DO:
             ASSIGN i-cod-erro  = 356
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    ASSIGN in99 = 0.
    DO WHILE TRUE:    
        ASSIGN in99 = in99 + 1.

        FIND craplot WHERE
             craplot.cdcooper = crapcop.cdcooper  AND
             craplot.dtmvtolt = crapdat.dtmvtolt  AND
             craplot.cdagenci = p-cod-agencia     AND
             craplot.cdbccxlt = 11                AND  /* Fixo */
             craplot.nrdolote = i-nro-lote      
             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF   NOT AVAIL   craplot   THEN DO:
             IF   LOCKED craplot   THEN DO:
                  IF  in99 <  100  THEN DO:
                      PAUSE 1 NO-MESSAGE.
                      NEXT.
                  END.
                  ELSE DO:
                      ASSIGN i-cod-erro  = 0
                             c-desc-erro = "Tabela CRAPLOT em uso ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
             END.
             ELSE DO:
                  ASSIGN i-cod-erro  = 60
                         c-desc-erro = " ".           
                  RUN cria-erro (INPUT p-cooper,
                                 INPUT p-cod-agencia,
                                 INPUT p-nro-caixa,
                                 INPUT i-cod-erro,
                                 INPUT c-desc-erro,
                                 INPUT YES).
                  RETURN "NOK".
             END.
        END.
        LEAVE.
    END.  /*  DO WHILE */

    ASSIGN in99 = 0.
    DO  WHILE TRUE:
        ASSIGN in99 = in99 + 1.
            
        FIND craplem WHERE craplem.cdcooper = crapcop.cdcooper  AND
                           craplem.dtmvtolt = crapdat.dtmvtolt  AND
                           craplem.cdagenci = p-cod-agencia     AND
                           craplem.cdbccxlt = 11                AND
                           craplem.nrdolote = i-nro-lote        AND
                           craplem.nrdconta = p-nro-conta       AND
                           craplem.nrdocmto = p-nrdocto        
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
        IF   NOT AVAIL   craplem THEN DO:
             IF   LOCKED craplem THEN DO:
                  IF  in99 <  100  THEN DO:
                      PAUSE 1 NO-MESSAGE.
                      NEXT.
                  END.
                  ELSE DO:
                      ASSIGN i-cod-erro  = 0
                             c-desc-erro = "Tabela CRAPLEM em uso ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
             END.
             ELSE DO:

                  ASSIGN i-cod-erro  = 90
                         c-desc-erro = " ".           
                  RUN cria-erro (INPUT p-cooper,
                                 INPUT p-cod-agencia,
                                 INPUT p-nro-caixa,
                                 INPUT i-cod-erro,
                                 INPUT c-desc-erro,
                                 INPUT YES).
                  RETURN "NOK".
             END.
         END.
         LEAVE.
    END.  /*  DO WHILE */
    
    ASSIGN p-valor = craplem.vllanmto.
    
    ASSIGN craplot.qtcompln  = craplot.qtcompln - 1
           craplot.qtinfoln  = craplot.qtinfoln - 1
           craplot.vlcompcr  = craplot.vlcompcr - p-valor
           craplot.vlinfocr  = craplot.vlinfocr - p-valor.

    IF  craplot.vlcompdb = 0 and
        craplot.vlinfodb = 0 and
        craplot.vlcompcr = 0 and
        craplot.vlinfocr = 0 THEN
        DELETE craplot.
    ELSE
        RELEASE craplot.

    ASSIGN in99 = 0.
    DO  WHILE TRUE:
       
        FIND crapepr WHERE 
             crapepr.cdcooper = crapcop.cdcooper  AND
             crapepr.nrdconta = craplem.nrdconta  AND
             crapepr.nrctremp = craplem.nrctremp  
             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
        ASSIGN in99 = in99 + 1.
        IF   NOT AVAIL   crapepr   THEN DO:
             IF   LOCKED crapepr   THEN DO:
                  IF  in99 <  100  THEN DO:
                      PAUSE 1 NO-MESSAGE.
                      NEXT.
                  END.
                  ELSE DO:
                      ASSIGN i-cod-erro  = 0
                             c-desc-erro = "Tabela CRAPEPR em uso ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                    INPUT YES).
                      RETURN "NOK".
                  END.
             END.
           
             ELSE DO:
                  ASSIGN i-cod-erro  = 356
                         c-desc-erro = " ".           
                  RUN cria-erro (INPUT p-cooper,
                                 INPUT p-cod-agencia,
                                 INPUT p-nro-caixa,
                                 INPUT i-cod-erro,
                                 INPUT c-desc-erro,
                                 INPUT YES).
                  RETURN "NOK".
             END.
        END.
        LEAVE.
    END.  /*  DO WHILE */

   ASSIGN aux_dtultpag = crapepr.dtmvtolt
          p-autestorno = craplem.nrautdoc.

   DELETE craplem.

   FOR EACH craplem WHERE
            craplem.cdcooper = crapcop.cdcooper   AND
            craplem.nrdconta = crapepr.nrdconta   AND
            craplem.nrctremp = crapepr.nrctremp   NO-LOCK:

       FIND craphis WHERE craphis.cdcooper = crapcop.cdcooper  AND
                          craphis.cdhistor = craplem.cdhistor NO-LOCK NO-ERROR.

       IF   NOT AVAILABLE craphis   THEN
            NEXT.

       IF   craphis.indebcre = "C"   THEN
            aux_dtultpag = craplem.dtmvtolt.

   END.  /*  Fim do FOR EACH  --  Pesquisa do ultimo pagamento  */

   ASSIGN crapepr.dtultpag = aux_dtultpag
          crapepr.txjuremp = aux_txdjuros.
   
   ASSIGN crapepr.inliquid = IF 
                            (aux_vlsdeved + p-valor) > 0
                             THEN 0
                             ELSE 1.

   RUN sistema/generico/procedures/b1wgen0043.p PERSISTENT SET h-b1wgen0043.

   RUN ativa_rating IN h-b1wgen0043 (INPUT crapepr.cdcooper,
                                     INPUT 0,
                                     INPUT 0,
                                     INPUT p-cod-operador,
                                     INPUT crapdat.dtmvtolt,
                                     INPUT crapdat.dtmvtopr,
                                     INPUT crapepr.nrdconta,
                                     INPUT 90, /* Emprestimo */
                                     INPUT crapepr.nrctremp,
                                     INPUT TRUE,
                                     INPUT 1,
                                     INPUT 2, /*Caixa On-line*/
                                     INPUT "b1crap79",
                                     INPUT 1,
                                     INPUT FALSE,
                                     OUTPUT TABLE tt-erro). 
   DELETE PROCEDURE h-b1wgen0043.

   IF   RETURN-VALUE <> "OK"   THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF   AVAIL tt-erro   THEN
                 ASSIGN i-cod-erro  = tt-erro.cdcritic
                        c-desc-erro = " ".           
            ELSE
                 ASSIGN c-desc-erro = "Erro na ativaçao do Rating.".
            
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).

            RELEASE crapepr.

            RETURN "NOK".
        END.

   RELEASE crapepr.
   
   RETURN "OK".
END PROCEDURE.

/* b1crap79.p */

