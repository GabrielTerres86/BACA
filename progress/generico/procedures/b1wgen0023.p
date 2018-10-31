/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +------------------------------------------+--------------------------------+
  | Rotina Progress                          | Rotina Oracle PLSQL            |
  +------------------------------------------+--------------------------------+
  | procedures/b1wgen0023.p                  | PAGA0001                       |
  |   baixa_epr_titulo                       | PAGA0001.pc_baixa_epr_titulo   |
  +------------------------------------------+--------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/









/*..............................................................................

    Programa: b1wgen0023.p
    Autor   : Guilherme
    Data    : Junho/2009                       Ultima Atualizacao: 06/07/2018
    
    Dados referentes ao programa:

    Objetivo  : BO referente a funcoes e transacoes de EMPRESTIMOS

    DEFINICOES DE BAIXA E ESTORNO DE PAGAMENTO PARA EMPRESTIMO:
    Atualizacao dos campos do crapepr quando pagamento do emprestimo com boleto:
        -crapepr.indpagto = podera passar para 1 quando 
                            crapcob.dtvencto = crapepr.dtdpagto
                            senao a parcela que esta sendo paga sera 
                            considerada como antecipacao
        -crapepr.dtdpagto = podera ser atualizada para o mes seguinte, 
                            usando a fontes/calcdata.p
                            quando crapcob.dtvencto = crapepr.dtdpagto 
                            senao fica como esta
        -crapepr.dtultpag = atualizar com glb_dtmvtolt
        -crapepr.inliquid = passara para 1 quando nao houver mais nenhum 
                            crapcob em aberto.
 
    E no caso de estornos eh so voltar:
        -crapepr.dtdpagto = if crapepr.dtdpagto > crapcob.dtvencto then
                            crapcob.dtvencto else nao atualiza
        -crapepr.indpagto = if  crapepr.indpagto = 1 and
                                crapepr.dtdpagto = crapcob.dtvencto then
                            crapepr.indpagto = 0 
                            else nao atualiza
       - crapepr.dtultpag = ler ultimo craplem com historico de pagamento
       - crapepr.inliquid = if crapepr.inliquid = 1 then
                               crapepr.inliquid = 0 
                            else nao atualiza.
                        
   Alteracoes: 04/07/2009 - Melhoria para tratamento de erros (Guilherme).
   
               20/05/2010 - Desativar Rating quando liquidado o emprestimo
                            (Gabriel). 
               
               19/12/2013 - Adicionado validate para as tabelas craplot,
                            craplcm, craplem (Tiago).
                            
               09/09/2014 - Criação de procedures para validação de limites
                            de crédito (Dionathan).
               
               01/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                            Cedente por Beneficiário e  Sacado por Pagador 
                            Chamado 229313 (Jean Reddiga - RKAM).    

               02/12/2014 - Inclusao da chamada do solicita_baixa_automatica
                            (Guilherme/SUPERO)

               07/06/2018 - PRJ450 - Centralizaçao do lançamento em conta corrente Rangel Decker  AMcom.

 .............................................................................*/

{ sistema/generico/includes/b1wgen0023tt.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgen0200tt.i }


DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

/*****************************/
/*    Procedures EXTERNAS    */
/*****************************/
/*****************************************************************************/
/*              Verificar se conta possui emprestimo informado               */
/*****************************************************************************/
PROCEDURE valida_contrato_epr:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrctasac AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-dados_epr_net.    

    DEF VAR aux_cdlcremp AS INTE NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dados_epr_net.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_dstransa = "Validar numero de contrato para gerar boletos " +
                          "para emprestimo via internet.".    

    IF  par_nrctasac = 0  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Pagador nao possui conta corrente " +
                                  "cadastrada.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog  THEN
                DO:
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
                END.
                
            RETURN "NOK".
        END.
        
    /* Buscar a linha de credito ativa para emprestimo na internet */
    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "GENERI"     AND
                       craptab.cdempres = 00           AND
                       craptab.cdacesso = "LCREMISBOL" AND
                       craptab.tpregist = 0 NO-LOCK NO-ERROR.
                       
    IF  NOT AVAIL craptab  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro de linha de credito para gerar " +
                                  "boletos na internet nao encontrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog  THEN
                DO:
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid). 
                
                    RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                            INPUT "Chave da craptab",
                                            INPUT "",
                                            INPUT "").
                    
                    RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                            INPUT "nmsistem",
                                            INPUT "",
                                            INPUT "CRED").
                    
                    RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                            INPUT "tptabela",
                                            INPUT "",
                                            INPUT "GENERI").
                    
                    RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                            INPUT "cdempres",
                                            INPUT "",
                                            INPUT "0").
                    
                    RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                            INPUT "cdacesso",
                                            INPUT "",
                                            INPUT "LCREMISBOL").

                    RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                            INPUT "tpregist",
                                            INPUT "",
                                            INPUT "0").
                
                END.    
            
            RETURN "NOK".
            
        END. /* Fim do IF NOT AVAIL */
    
    ASSIGN aux_cdlcremp = INTEGER(craptab.dstextab).
    
    /* Buscar dados do emprestimo informado para gerar boletos */
    FIND crapepr WHERE crapepr.cdcooper = par_cdcooper AND
                       crapepr.nrdconta = par_nrctasac AND
                       crapepr.nrctremp = par_nrctremp
                       NO-LOCK NO-ERROR.
                       
    IF  NOT AVAIL crapepr  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Contrato de emprestimo inexistente.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog  THEN
                DO:
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid). 
                
                    RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                            INPUT "nrctasac",
                                            INPUT "",
                                            INPUT par_nrctasac).

                    RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                            INPUT "nrctremp",
                                            INPUT "",
                                            INPUT par_nrctremp).
                    
                END.    

            RETURN "NOK".
            
        END. /* Fim do IF NOT AVAIL */
    
    IF  crapepr.cdlcremp <> aux_cdlcremp  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Linha de credito do contrato nao esta " +
                                  "habilitada para gerar boletos.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog  THEN
                DO:
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid). 
                
                    RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                            INPUT "nrctremp",
                                            INPUT "",
                                            INPUT par_nrctremp).
                    
                    RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                            INPUT "cdlcremp",
                                            INPUT "",
                                            INPUT aux_cdlcremp).
                END.    

            RETURN "NOK".        

        END.
    
    CREATE tt-dados_epr_net.
    ASSIGN tt-dados_epr_net.dtdpagto = crapepr.dtdpagto
           tt-dados_epr_net.vlpreemp = crapepr.vlpreemp
           tt-dados_epr_net.qtpreemp = crapepr.qtpreemp.
        
    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).
    
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/*      Buscar conta valida para gerar boletos de emprestimo na internet     */
/*****************************************************************************/
PROCEDURE busca_cta_coop_epr:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-dados_epr_net.
        
    EMPTY TEMP-TABLE tt-dados_epr_net.
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_dstransa = "Buscar conta valida para gerar boletos de " +
                          "emprestimo na internet.".

    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "GENERI"     AND
                       craptab.cdempres = 00           AND
                       craptab.cdacesso = "CTAEMISBOL" AND
                       craptab.tpregist = 0 NO-LOCK NO-ERROR.
                       
    /* Nao eh conta cadastrada para gerar boletos */
    IF  NOT AVAIL craptab  THEN
        RETURN "OK".        

    CREATE tt-dados_epr_net.
    ASSIGN tt-dados_epr_net.nrdconta = INTEGER(craptab.dstextab).
    
    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).
                           
    RETURN "OK".
    
END PROCEDURE.


/*****************************************************************************/
/*      Efetuar lancamentos da baixa de titulo que esta em emprestimo        */
/*****************************************************************************/
PROCEDURE baixa_epr_titulo:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrctasac AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrboleto AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dtvencto AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_vlboleto AS DECI                    NO-UNDO.
    DEF INPUT PARAM par_vllanmto AS DECI                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
        
    DEF VAR aux_contador AS INTE                            NO-UNDO.
    DEF VAR aux_nrdocmto AS CHAR                            NO-UNDO.
    DEF VAR tab_inusatab AS LOGI                            NO-UNDO.
    DEF VAR aux_txdjuros AS DECI                            NO-UNDO.
    DEF VAR aux_liquida  AS INTE                            NO-UNDO.
    DEF VAR aux_dtdpagto AS DATE                            NO-UNDO.
    DEF VAR aux_dtmvtopr AS DATE                            NO-UNDO.                                                        

    DEF VAR h-b1wgen0043 AS HANDLE                          NO-UNDO.
    DEF VAR h-b1wgen0171 AS HANDLE                          NO-UNDO.
    DEF BUFFER crabcob FOR crapcob.
    
    DEF VAR h-b1wgen0200 AS HANDLE  NO-UNDO.
    DEF VAR aux_incrineg AS INT     NO-UNDO.
    DEF VAR aux_cdcritic AS INT     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    
    
    /* Identificar orgao expedidor */
    IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
        RUN sistema/generico/procedures/b1wgen0200.p
    PERSISTENT SET h-b1wgen0200. 
    
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_dstransa = "Lancamentos de titulo pago que esta em " +
                          "emprestimo.".
    
    DO  aux_contador = 1 TO 10:
    
        FIND crapepr WHERE crapepr.cdcooper = par_cdcooper AND
                           crapepr.nrctremp = par_nrctremp AND
                           crapepr.nrdconta = par_nrctasac 
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                       
        IF  NOT AVAIL crapepr  THEN
            DO:
                IF  LOCKED crapepr THEN
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Registro de emprestimo esta " +
                                              "em uso. Tente novamente.".
                        NEXT.
                    END.
                ELSE
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Registro de emprestimo nao " +
                                              "encontrado.".
                        LEAVE.
                    END.

            END.
            
        ASSIGN aux_dscritic = "".            
        
        LEAVE.
    END.
    
    IF  aux_dscritic <> ""  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog  THEN
                DO:
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid). 
                
                    RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                            INPUT "nrctasac",
                                            INPUT "",
                                            INPUT par_nrctasac).

                    RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                            INPUT "nrctremp",
                                            INPUT "",
                                            INPUT par_nrctremp).
                    
                END.
                
            RETURN "NOK".
        END.
    
    /*  Leitura do indicador de uso da tabela de taxa de juros  */
    FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
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
    
    IF   tab_inusatab  THEN
         DO:
             FIND craplcr WHERE craplcr.cdcooper = par_cdcooper     AND
                                craplcr.cdlcremp = crapepr.cdlcremp  
                                NO-LOCK NO-ERROR.

             IF   NOT AVAILABLE craplcr   THEN
                  DO:
                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT 1,            /** Sequencia **/
                                     INPUT aux_cdcritic,
                                     INPUT-OUTPUT aux_dscritic).

                      IF  par_flgerlog  THEN
                          DO:
                              RUN proc_gerar_log (INPUT par_cdcooper,
                                                  INPUT par_cdoperad,
                                                  INPUT aux_dscritic,
                                                  INPUT aux_dsorigem,
                                                  INPUT aux_dstransa,
                                                  INPUT FALSE,
                                                  INPUT par_idseqttl,
                                                  INPUT par_nmdatela,
                                                  INPUT par_nrdconta,
                                                 OUTPUT aux_nrdrowid). 
                 
                              RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                      INPUT "cdlcremp",
                                                      INPUT "",
                                                      INPUT crapepr.cdlcremp).
                      
                          END.
                      
                      RETURN "NOK".
                  END.
             ELSE
                  aux_txdjuros = craplcr.txdiaria.
         END.
    ELSE
         aux_txdjuros = crapepr.txjuremp.
    
    ASSIGN aux_nrdocmto = STRING(par_nrctremp) +
                                 STRING(MONTH(par_dtvencto),"99") +
                                 SUBSTR(STRING(par_dtvencto),
                                        R-INDEX(STRING(par_dtvencto),"/")
                                        + 1).
    
    /* 
        Caso a chamada vier pelo includes/crps375.i faz o credito de cobranca
        na conta corrente da cooperativa
    */
    IF  par_idorigem = 1  THEN
        DO:
            DO  aux_contador = 1 TO 10:
                FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND
                                   craplot.dtmvtolt = par_dtmvtolt   AND
                                   craplot.cdagenci = 1              AND
                                   craplot.cdbccxlt = 100            AND
                                   craplot.nrdolote = 9600
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAILABLE craplot  THEN
                    DO:
                        IF  LOCKED craplot  THEN
                            DO:                           
                                PAUSE 1 NO-MESSAGE.
                                ASSIGN aux_cdcritic = 341.
                                NEXT.
                            END.
                        ELSE
                            DO:
                                CREATE craplot.
                                ASSIGN craplot.dtmvtolt = par_dtmvtolt 
                                       craplot.cdagenci = 1
                                       craplot.cdbccxlt = 100
                                       craplot.nrdolote = 9600
                                       craplot.tplotmov = 1
                                       craplot.cdoperad = par_cdoperad
                                       craplot.cdhistor = 266
                                       craplot.cdcooper = par_cdcooper
                                       craplot.nrseqdig = 1.
                            END.       
                    END.
               
                ASSIGN aux_cdcritic = 0.
                         
                LEAVE.

            END. /* Fim do DO ... TO */
            
            IF  aux_cdcritic > 0  THEN
                DO:
                    ASSIGN aux_dscritic = "".
                    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,     /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.

                RUN gerar_lancamento_conta_comple IN h-b1wgen0200
                      ( INPUT craplot.dtmvtolt         /* par_dtmvtolt */
                       ,INPUT craplot.cdagenci         /* par_cdagenci */
                       ,INPUT craplot.cdbccxlt        /* par_cdbccxlt */
                       ,INPUT craplot.nrdolote        /* par_nrdolote */
                       ,INPUT par_nrdconta            /* par_nrdconta */
                       ,INPUT DECIMAL(aux_nrdocmto)   /* par_nrdocmto */
                       ,INPUT 266                    /* par_cdhistor */
                       ,INPUT craplot.nrseqdig + 1   /* par_nrseqdig */
                       ,INPUT par_vllanmto           /* par_vllanmto */
                       ,INPUT par_nrdconta           /* par_nrdctabb */
                       ,INPUT "Pagador " + STRING(par_nrctasac) /* par_cdpesqbb */
                       ,INPUT 0                 /* par_vldoipmf */
                       ,INPUT 0                 /* par_nrautdoc */
                       ,INPUT craplot.nrseqdig  /* par_nrsequni */
                       ,INPUT 0                 /* par_cdbanchq */
                       ,INPUT 0                 /* par_cdcmpchq */
                       ,INPUT 0                 /* par_cdagechq */
                       ,INPUT 0                 /* par_nrctachq */
                       ,INPUT 0                 /* par_nrlotchq */
                       ,INPUT 0                 /* par_sqlotchq */
                       ,INPUT ""              /* par_dtrefere */
                       ,INPUT ""              /* par_hrtransa */
                       ,INPUT par_cdoperad      /* par_cdoperad */                               
                       ,INPUT ""                /* par_dsidenti */
                       ,INPUT par_cdcooper      /* par_cdcooper */
                       ,INPUT 0                 /* par_nrdctitg */
                       ,INPUT ""                /* par_dscedent */
                       ,INPUT 0                 /* par_cdcoptfn */
                       ,INPUT 0                 /* par_cdagetfn */
                       ,INPUT 0                 /* par_nrterfin */
                       ,INPUT 0                 /* par_nrparepr */
                       ,INPUT 0                 /* par_nrseqava */
                       ,INPUT 0                 /* par_nraplica */
                       ,INPUT 0                 /*par_cdorigem*/
                       ,INPUT 0                 /* par_idlautom */
                       ,INPUT 0                 /*par_inprolot*/ 
                       ,INPUT 0                 /*par_tplotmov */
                       ,OUTPUT TABLE tt-ret-lancto
                       ,OUTPUT aux_incrineg
                       ,OUTPUT aux_cdcritic
                       ,OUTPUT aux_dscritic).

                       IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO: 			 
                           RUN gera_erro (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT 1,     /** Sequencia **/
                                          INPUT aux_cdcritic,
                                          INPUT-OUTPUT aux_dscritic).
                           RETURN "NOK".
                        END.

             ASSIGN craplot.vlinfodb = craplot.vlinfocr + par_vllanmto
                    craplot.vlcompdb = craplot.vlcompcr + par_vllanmto
                   craplot.qtinfoln = craplot.qtinfoln + 1
                   craplot.qtcompln = craplot.qtcompln + 1
                   craplot.nrseqdig = craplot.nrseqdig + 1.

            
            VALIDATE craplot.
            
        END. /* Fim do credito na c/c da cooperativa */
    
    /* Debitar na conta da cooperativa */
    DO  aux_contador = 1 TO 10:
        FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND
                           craplot.dtmvtolt = par_dtmvtolt   AND
                           craplot.cdagenci = 1              AND
                           craplot.cdbccxlt = 100            AND
                           craplot.nrdolote = 9601
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAILABLE craplot  THEN
            DO:
                IF  LOCKED craplot  THEN
                    DO:                           
                        PAUSE 1 NO-MESSAGE.
                        ASSIGN aux_cdcritic = 341.
                        NEXT.
                    END.
                ELSE
                    DO:
                        CREATE craplot.
                        ASSIGN craplot.dtmvtolt = par_dtmvtolt
                               craplot.cdagenci = 1
                               craplot.cdbccxlt = 100
                               craplot.nrdolote = 9601
                               craplot.tplotmov = 1
                               craplot.cdoperad = par_cdoperad
                               craplot.cdhistor = 302
                               craplot.cdcooper = par_cdcooper
                               craplot.nrseqdig = 1.
                    END.       
            END.
               
        ASSIGN aux_cdcritic = 0.
                         
        LEAVE.

    END. /* Fim do DO ... TO */
            
    IF  aux_cdcritic > 0  THEN
        DO:
            ASSIGN aux_dscritic = "".
                    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

             RUN gerar_lancamento_conta_comple IN h-b1wgen0200
                      ( INPUT craplot.dtmvtolt        /* par_dtmvtolt */
                       ,INPUT craplot.cdagenci        /* par_cdagenci */
                       ,INPUT craplot.cdbccxlt        /* par_cdbccxlt */
                       ,INPUT craplot.nrdolote        /* par_nrdolote */
                       ,INPUT par_nrdconta            /* par_nrdconta */
                       ,INPUT DECIMAL(aux_nrdocmto)   /* par_nrdocmto */
                       ,INPUT 302                    /* par_cdhistor */
                       ,INPUT craplot.nrseqdig + 1  /* par_nrseqdig */
                       ,INPUT par_vllanmto           /* par_vllanmto */
                       ,INPUT par_nrdconta           /* par_nrdctabb */
                       ,INPUT STRING(par_nrctasac,"99999999") /* par_cdpesqbb */
                       ,INPUT 0                 /* par_vldoipmf */
                       ,INPUT 0                 /* par_nrautdoc */
                       ,INPUT 0                 /* par_nrsequni */
                       ,INPUT 0                 /* par_cdbanchq */
                       ,INPUT 0                 /* par_cdcmpchq */
                       ,INPUT 0                 /* par_cdagechq */
                       ,INPUT 0                 /* par_nrctachq */
                       ,INPUT 0                 /* par_nrlotchq */
                       ,INPUT 0                 /* par_sqlotchq */
                       ,INPUT ""                /* par_dtrefere */
                       ,INPUT ""                /* par_hrtransa */
                       ,INPUT par_cdoperad      /* par_cdoperad */                               
                       ,INPUT ""                /* par_dsidenti */
                       ,INPUT par_cdcooper      /* par_cdcooper */
                       ,INPUT STRING(crapepr.nrdconta,"99999999")   /* par_nrdctitg */
                       ,INPUT ""                /* par_dscedent */
                       ,INPUT 0                 /* par_cdcoptfn */
                       ,INPUT 0                 /* par_cdagetfn */
                       ,INPUT 0                 /* par_nrterfin */
                       ,INPUT 0                 /* par_nrparepr */
                       ,INPUT 0                 /* par_nrseqava */
                       ,INPUT 0                 /* par_nraplica */
                       ,INPUT 0                 /*par_cdorigem*/
                       ,INPUT 0                 /* par_idlautom */
                       ,INPUT 0                 /*par_inprolot*/ 
                       ,INPUT 0                 /*par_tplotmov */ 
                       ,OUTPUT TABLE tt-ret-lancto
                       ,OUTPUT aux_incrineg
                       ,OUTPUT aux_cdcritic
                       ,OUTPUT aux_dscritic).

                       IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO: 			 
                           RUN gera_erro (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT 1,     /** Sequencia **/
                                          INPUT aux_cdcritic,
                                          INPUT-OUTPUT aux_dscritic).
                           RETURN "NOK".
                        END.

    ASSIGN   craplot.vlinfodb = craplot.vlinfodb + par_vllanmto
             craplot.vlcompdb = craplot.vlcompdb + par_vllanmto
           craplot.qtinfoln = craplot.qtinfoln + 1
           craplot.qtcompln = craplot.qtcompln + 1
           craplot.nrseqdig = craplot.nrseqdig + 1.
    VALIDATE craplot.
    
    /* Fim do debito da c/c da cooperativa */
    
    
    DELETE PROCEDURE h-b1wgen0200. 
    
    /* Fazer o pagamento do emprestimo */
    DO  aux_contador = 1 TO 10:
        FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND
                           craplot.dtmvtolt = par_dtmvtolt   AND
                           craplot.cdagenci = 1              AND
                           craplot.cdbccxlt = 100            AND
                           craplot.nrdolote = 9062
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAILABLE craplot  THEN
            DO:
                IF  LOCKED craplot  THEN
                    DO:                           
                        PAUSE 1 NO-MESSAGE.
                        ASSIGN aux_cdcritic = 341.
                        NEXT.
                    END.
                ELSE
                    DO:
                        CREATE craplot.
                        ASSIGN craplot.dtmvtolt = par_dtmvtolt 
                               craplot.cdagenci = 1
                               craplot.cdbccxlt = 100
                               craplot.nrdolote = 9062
                               craplot.tplotmov = 1
                               craplot.cdoperad = par_cdoperad
                               craplot.cdhistor = 91
                               craplot.cdcooper = par_cdcooper
                               craplot.nrseqdig = 1.
                    END.       
            END.
               
        ASSIGN aux_cdcritic = 0.
                         
        LEAVE.

    END. /* Fim do DO ... TO */
            
    IF  aux_cdcritic > 0  THEN
        DO:
            ASSIGN aux_dscritic = "".
                    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    aux_liquida = 1.
    FOR EACH crabcob WHERE crabcob.cdcooper = crapepr.cdcooper AND
                           crabcob.nrctasac = crapepr.nrdconta AND
                           crabcob.nrctremp = crapepr.nrctremp
                           NO-LOCK:

        /* se encontrar algum boleto em aberto significa que ainda nao 
           deve liquidar o emprestimo */
        IF  crabcob.dtdbaixa = ?  THEN
            aux_liquida = 0.

    END.                           
    
    FIND crabcob WHERE crabcob.cdcooper = crapepr.cdcooper AND
                       crabcob.nrctasac = crapepr.nrdconta AND
                       crabcob.nrctremp = crapepr.nrctremp AND
                       crabcob.nrdocmto = par_nrboleto
                       NO-LOCK NO-ERROR.
                               
    IF  NOT AVAIL crabcob  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro de boleto nao encontrado.".
                    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.
    
    IF  CAN-FIND(craplem WHERE craplem.cdcooper = par_cdcooper       AND
                               craplem.dtmvtolt = par_dtmvtolt       AND
                               craplem.cdagenci = 1                  AND
                               craplem.cdbccxlt = 100                AND
                               craplem.nrdolote = 9062               AND
                               craplem.nrdconta = par_nrctasac       AND
                               craplem.nrdocmto = DECI(aux_nrdocmto) AND
                               craplem.cdhistor = 91
                               NO-LOCK) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Lancamento de emprestimo ja exite.".
                    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    RUN fontes/calcdata.p (INPUT crapepr.dtdpagto,
                           INPUT 1,
                           INPUT "M", 
                           INPUT 0,
                           OUTPUT aux_dtdpagto).
    
    /* Fazer o lancamento de pagamento de emprestimo */
    CREATE craplem.
    ASSIGN craplem.dtmvtolt = craplot.dtmvtolt
           craplem.cdagenci = craplot.cdagenci
           craplem.cdbccxlt = craplot.cdbccxlt
           craplem.nrdolote = craplot.nrdolote
           craplem.nrdconta = par_nrctasac
           craplem.nrctremp = crapepr.nrctremp
           craplem.nrdocmto = DECIMAL(aux_nrdocmto)
           craplem.cdhistor = 91
           craplem.nrseqdig = craplot.nrseqdig + 1
           craplem.vllanmto = par_vllanmto
           craplem.txjurepr = aux_txdjuros 
           craplem.dtpagemp = par_dtmvtolt 
           craplem.vlpreemp = crapepr.vlpreemp
           craplem.cdcooper = par_cdcooper

           crapepr.indpagto = IF  crabcob.dtvencto = crapepr.dtdpagto 
                              THEN 1
                              ELSE 0
                              
           crapepr.dtdpagto = IF  crabcob.dtvencto = crapepr.dtdpagto
                              THEN aux_dtdpagto
                              ELSE crapepr.dtdpagto
           
           crapepr.dtultpag = par_dtmvtolt
           crapepr.inliquid = aux_liquida

           craplot.vlinfodb = craplot.vlinfodb + craplem.vllanmto
           craplot.vlcompdb = craplot.vlcompdb + craplem.vllanmto
           craplot.qtinfoln = craplot.qtinfoln + 1
           craplot.qtcompln = craplot.qtcompln + 1
           craplot.nrseqdig = craplot.nrseqdig + 1.
    VALIDATE craplot.
    VALIDATE craplem.

    IF  par_vllanmto > par_vlboleto  THEN
        DO:
            /* Fazer o pagamento a maior da parcela */
            DO  aux_contador = 1 TO 10:
                FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND
                                   craplot.dtmvtolt = par_dtmvtolt   AND
                                   craplot.cdagenci = 1              AND
                                   craplot.cdbccxlt = 100            AND
                                   craplot.nrdolote = 9063
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAILABLE craplot  THEN
                    DO:
                        IF  LOCKED craplot  THEN
                            DO:                           
                                PAUSE 1 NO-MESSAGE.
                                ASSIGN aux_cdcritic = 341.
                                NEXT.
                            END.
                        ELSE
                            DO:
                                CREATE craplot.
                                ASSIGN craplot.dtmvtolt = par_dtmvtolt
                                       craplot.cdagenci = 1
                                       craplot.cdbccxlt = 100
                                       craplot.nrdolote = 9063
                                       craplot.tplotmov = 1
                                       craplot.cdoperad = par_cdoperad
                                       craplot.cdhistor = 441
                                       craplot.cdcooper = par_cdcooper
                                       craplot.nrseqdig = 1.
                            END.       
                    END.
               
                ASSIGN aux_cdcritic = 0.
                         
                LEAVE.

            END. /* Fim do DO ... TO */
            
            IF  aux_cdcritic > 0  THEN
                DO:
                    ASSIGN aux_dscritic = "".
                    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,     /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.    
    
            /* Fazer lancamento para titulo pago a maior da parcela */
            CREATE craplem.
            ASSIGN craplem.dtmvtolt = craplot.dtmvtolt
                   craplem.cdagenci = craplot.cdagenci
                   craplem.cdbccxlt = craplot.cdbccxlt
                   craplem.nrdolote = craplot.nrdolote
                   craplem.nrdconta = par_nrctasac
                   craplem.nrctremp = crapepr.nrctremp
                   craplem.nrdocmto = DECIMAL(aux_nrdocmto)
                   craplem.cdhistor = 441
                   craplem.nrseqdig = craplot.nrseqdig + 1
                   craplem.vllanmto = par_vllanmto - par_vlboleto
                   craplem.txjurepr = aux_txdjuros 
                   craplem.dtpagemp = par_dtmvtolt
                   craplem.vlpreemp = crapepr.vlpreemp
                   craplem.cdcooper = par_cdcooper

                   craplot.vlinfodb = craplot.vlinfodb + craplem.vllanmto
                   craplot.vlcompdb = craplot.vlcompdb + craplem.vllanmto
                   craplot.qtinfoln = craplot.qtinfoln + 1
                   craplot.qtcompln = craplot.qtcompln + 1
                   craplot.nrseqdig = craplot.nrseqdig + 1.

            VALIDATE craplot.
            VALIDATE craplem.
        END. /* Final do pagamento a maior */

    
    /* Liquida o emprestimo */
    IF  crapepr.vlsdeved <= par_vllanmto  THEN
        crapepr.inliquid = 1.              
    ELSE
        crapepr.inliquid = 0.
    

    FIND crapdat WHERE crapdat.cdcooper = par_cdcooper   AND
                       crapdat.dtmvtolt = par_dtmvtolt
                       NO-LOCK NO-ERROR.

    IF   AVAIL crapdat THEN
         aux_dtmvtopr = crapdat.dtmvtopr.

    RUN sistema/generico/procedures/b1wgen0043.p
                PERSISTENT SET h-b1wgen0043.

    /* Desativa/ativa Rating dependendo o inliquid do Emprestimo */
    RUN verifica_contrato_rating IN h-b1wgen0043
                                 (INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT par_cdoperad,
                                  INPUT par_dtmvtolt,
                                  INPUT aux_dtmvtopr,
                                  INPUT crapepr.nrdconta,
                                  INPUT 90,
                                  INPUT crapepr.nrctremp,
                                  INPUT par_idseqttl,
                                  INPUT par_idorigem,
                                  INPUT par_nmdatela,
                                  INPUT 0,
                                  INPUT FALSE,
                                  OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0043.

    IF   RETURN-VALUE <> "OK" THEN
         RETURN "NOK".

    IF  crapepr.inliquid = 1 THEN DO:

         /*** GRAVAMES ***/
         RUN sistema/generico/procedures/b1wgen0171.p
             PERSISTENT SET h-b1wgen0171.

         RUN solicita_baixa_automatica  IN h-b1wgen0171
                     (INPUT par_cdcooper,
                      INPUT crapepr.nrdconta,
                      INPUT crapepr.nrctremp,
                      INPUT par_dtmvtolt,
                      OUTPUT TABLE tt-erro).

         DELETE PROCEDURE h-b1wgen0171.

    END.


    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).
                           
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/* Efetuar estorno de lancamentos da baixa de titulo que esta em emprestimo  */
/*****************************************************************************/
PROCEDURE estorna_baixa_epr_titulo:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrctasac AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrboleto AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dtvencto AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
        
    DEF VAR aux_contador AS INTE                            NO-UNDO.
    DEF VAR aux_nrdocmto AS CHAR                            NO-UNDO.
    DEF VAR flg_notfound AS LOGI                            NO-UNDO.
    DEF VAR aux_dtultpag AS DATE                            NO-UNDO.
    DEF VAR aux_flgderro AS LOGI                            NO-UNDO.
    DEF VAR aux_dtmvtopr AS DATE                            NO-UNDO.
                                                            
    DEF VAR h-b1wgen0043 AS HANDLE                          NO-UNDO.

    DEF BUFFER crablem FOR craplem.
    DEF BUFFER crabcob FOR crapcob.
        
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_dstransa = "Estorno de lancamentos de titulo pago que esta em " +
                          "emprestimo."
           aux_flgderro = FALSE.
    
    FIND crapepr WHERE crapepr.cdcooper = par_cdcooper AND
                       crapepr.nrctremp = par_nrctremp AND
                       crapepr.nrdconta = par_nrctasac NO-LOCK NO-ERROR.
                       
    IF  NOT AVAIL crapepr  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro de emprestimo nao encontrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog  THEN
                DO:
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid). 
                                       
                    RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                            INPUT "nrctremp",
                                            INPUT "",
                                            INPUT par_nrctremp).

                END.
            RETURN "NOK".
        END.

    ASSIGN aux_nrdocmto = STRING(par_nrctremp) +
                                 STRING(MONTH(par_dtvencto),"99") +
                                 SUBSTR(STRING(par_dtvencto),
                                        R-INDEX(STRING(par_dtvencto),"/")
                                        + 1).
    
    flg_notfound = FALSE.
    
    ESTORNO:
    DO  TRANSACTION ON ERROR UNDO ESTORNO, LEAVE ESTORNO:
        
        /* 1o. Passo*/
        /* Estornar lancamento de debito na conta da cooperativa */
        DO  WHILE TRUE:
                
            DO  aux_contador = 1 TO 10:
                
                FIND craplcm WHERE craplcm.cdcooper = par_cdcooper       AND
                                   craplcm.dtmvtolt = par_dtmvtolt       AND
                                   craplcm.cdagenci = 1                  AND
                                   craplcm.cdbccxlt = 100                AND
                                   craplcm.nrdolote = 9601               AND
                                   craplcm.nrdctabb = par_nrdconta       AND
                                   craplcm.nrdocmto = DECI(aux_nrdocmto) AND
                                   craplcm.cdhistor = 302
                                   USE-INDEX craplcm1
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAILABLE craplcm   THEN
                    DO:
                        IF  LOCKED craplcm   THEN
                            DO:                           
                                PAUSE 1 NO-MESSAGE.
                                ASSIGN aux_cdcritic = 341.
                                NEXT.
                            END.
                        ELSE
                            DO:
                                flg_notfound = TRUE.
                                LEAVE.
                            END.    
                    END.                                       

                LEAVE.                   

            END. /* Final do DO .. TO */
                                       
            IF  flg_notfound THEN
                LEAVE.

            IF  aux_cdcritic > 0  THEN
                DO:
                    ASSIGN aux_dscritic = "".
                    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,     /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).

                    ASSIGN aux_flgderro = TRUE.

                    UNDO ESTORNO, LEAVE ESTORNO.
                
                END.

            DO  aux_contador = 1 TO 10:
                FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND
                                   craplot.dtmvtolt = par_dtmvtolt   AND
                                   craplot.cdagenci = 1              AND
                                   craplot.cdbccxlt = 100            AND
                                   craplot.nrdolote = 9601
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAILABLE craplot  THEN
                    DO:
                        IF  LOCKED craplot  THEN
                            DO:                           
                                PAUSE 1 NO-MESSAGE.
                                ASSIGN aux_cdcritic = 341.
                                NEXT.
                            END.
                    END.
               
                ASSIGN aux_cdcritic = 0.
                         
                LEAVE.

            END. /* Fim do DO ... TO */
            
            IF  aux_cdcritic > 0  THEN
                DO:
                    ASSIGN aux_dscritic = "".
                    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,     /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).

                    ASSIGN aux_flgderro = TRUE.

                    UNDO ESTORNO, LEAVE ESTORNO.
                END.

            ASSIGN craplot.qtcompln = craplot.qtcompln - 1
                   craplot.qtinfoln = craplot.qtinfoln - 1
                   craplot.vlinfocr = craplot.vlinfodb - craplcm.vllanmto
                   craplot.vlcompcr = craplot.vlcompdb - craplcm.vllanmto.    

            /* Caso lote zerado o mesmo eh removido. */
            IF  craplot.qtcompln = 0  THEN
                DELETE craplot.

            DELETE craplcm.
            
            LEAVE.
        END. /* Final do estorno lancto de credito na conta da cooperativa */

        /* 2o. Passo */
        /* Estornar o pagamento do emprestimo */
        DO  WHILE TRUE:
                
            DO  aux_contador = 1 TO 10:
                
                FIND craplem WHERE craplem.cdcooper = par_cdcooper       AND
                                   craplem.dtmvtolt = par_dtmvtolt       AND
                                   craplem.cdagenci = 1                  AND
                                   craplem.cdbccxlt = 100                AND
                                   craplem.nrdolote = 9062               AND
                                   craplem.nrdconta = par_nrctasac       AND
                                   craplem.nrdocmto = DECI(aux_nrdocmto) AND
                                   craplem.cdhistor = 91
                                   USE-INDEX craplem1
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAILABLE craplem   THEN
                    DO:
                        IF  LOCKED craplem   THEN
                            DO:                           
                                PAUSE 1 NO-MESSAGE.
                                ASSIGN aux_cdcritic = 341.
                                NEXT.
                            END.
                        ELSE
                            DO:
                                flg_notfound = TRUE.
                                LEAVE.
                            END.    
                    END.                                       

                ASSIGN aux_cdcritic = 0.
                
                LEAVE.                   

            END. /* Final do DO .. TO */
                                       
            IF  flg_notfound THEN
                LEAVE.

            IF  aux_cdcritic > 0  THEN
                DO:
                    ASSIGN aux_dscritic = "".
                    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,     /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).

                    ASSIGN aux_flgderro = TRUE.

                    UNDO ESTORNO, LEAVE ESTORNO.
                    
                END.

            DO  aux_contador = 1 TO 10:
                FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND
                                   craplot.dtmvtolt = par_dtmvtolt   AND
                                   craplot.cdagenci = 1              AND
                                   craplot.cdbccxlt = 100            AND
                                   craplot.nrdolote = 9062
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAILABLE craplot  THEN
                    DO:
                        IF  LOCKED craplot  THEN
                            DO:                           
                                PAUSE 1 NO-MESSAGE.
                                ASSIGN aux_cdcritic = 341.
                                NEXT.
                            END.
                    END.
               
                ASSIGN aux_cdcritic = 0.
                         
                LEAVE.

            END. /* Fim do DO ... TO */
            
            IF  aux_cdcritic > 0  THEN
                DO:
                    ASSIGN aux_dscritic = "".
                    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,     /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).

                    ASSIGN aux_flgderro = TRUE.

                    UNDO ESTORNO, LEAVE ESTORNO.
                END.

            DO  aux_contador = 1 TO 10:
                
                FIND crapepr WHERE crapepr.cdcooper = par_cdcooper AND
                                   crapepr.nrdconta = par_nrctasac AND
                                   crapepr.nrctremp = par_nrctremp
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAILABLE crapepr  THEN
                    DO:
                        IF  LOCKED crapepr   THEN
                            DO:                           
                                PAUSE 1 NO-MESSAGE.
                                ASSIGN aux_cdcritic = 341.
                                NEXT.
                            END.
                        ELSE
                            DO:
                                ASSIGN aux_cdcritic = 356.
                                LEAVE.
                            END.    
                    END.                                       

                ASSIGN aux_cdcritic = 0.
                
                LEAVE.                   

            END. /* Final do DO .. TO */
                                       
            IF  aux_cdcritic > 0  THEN
                DO:
                    ASSIGN aux_dscritic = "".
                    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,     /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).

                    ASSIGN aux_flgderro = TRUE.

                    UNDO ESTORNO, LEAVE ESTORNO.
                
                END.            
            
            FIND crabcob WHERE crabcob.cdcooper = crapepr.cdcooper AND
                               crabcob.nrctasac = crapepr.nrdconta AND
                               crabcob.nrctremp = crapepr.nrctremp AND
                               crabcob.nrdocmto = par_nrboleto
                               NO-LOCK NO-ERROR.
                               
            IF  NOT AVAIL crabcob  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Registro de boleto nao encontrado.".
                    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,     /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).

                    ASSIGN aux_flgderro = TRUE.

                    UNDO ESTORNO, LEAVE ESTORNO.
                END.
            
            ASSIGN craplot.qtcompln = craplot.qtcompln - 1
                   craplot.qtinfoln = craplot.qtinfoln - 1
                   craplot.vlinfocr = craplot.vlinfodb - craplem.vllanmto
                   craplot.vlcompcr = craplot.vlcompdb - craplem.vllanmto.    

            /* Caso lote zerado o mesmo eh removido. */
            IF  craplot.qtcompln = 0  THEN
                DELETE craplot.

            DELETE craplem.
            
            /* ultimo lancamento de pagamento deste emprestimo */
            FIND LAST crablem WHERE 
                      crablem.cdcooper = par_cdcooper       AND
                      crablem.nrdconta = crapepr.nrdconta   AND
                      crablem.nrctremp = crapepr.nrctremp  
                      USE-INDEX craplem2
                      NO-LOCK NO-ERROR.
                      
            /* Data de pagamento do ultimo emprestimo */
            IF  AVAIL crablem  THEN
                aux_dtultpag = crablem.dtpagemp.
            ELSE
                aux_dtultpag = ?.

            ASSIGN crapepr.dtdpagto = IF crapepr.dtdpagto > crabcob.dtvencto 
                                      THEN crabcob.dtvencto 
                                      ELSE crapepr.dtdpagto
                   
                   crapepr.indpagto = IF crapepr.indpagto = 1 AND
                                         crapepr.dtdpagto = crabcob.dtvencto 
                                      THEN 0
                                      ELSE crapepr.indpagto

                   crapepr.dtultpag = aux_dtultpag
                   
                   crapepr.inliquid = IF crapepr.inliquid = 1 
                                      THEN 0 
                                      ELSE crapepr.inliquid.

            FIND crapdat WHERE crapdat.cdcooper = par_cdcooper   AND
                               crapdat.dtmvtolt = par_dtmvtolt
                               NO-LOCK NO-ERROR.

            IF   AVAIL crapdat THEN
                 aux_dtmvtopr = crapdat.dtmvtopr.
            
            RUN sistema/generico/procedures/b1wgen0043.p
                        PERSISTENT SET h-b1wgen0043.

            /* Desativa/ativa Rating dependendo o inliquid do Emprestimo */
            RUN verifica_contrato_rating IN h-b1wgen0043
                                         (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT par_cdoperad,
                                          INPUT par_dtmvtolt,
                                          INPUT aux_dtmvtopr,
                                          INPUT crapepr.nrdconta,
                                          INPUT 90,
                                          INPUT crapepr.nrctremp,
                                          INPUT par_idseqttl,
                                          INPUT par_idorigem,
                                          INPUT par_nmdatela,
                                          INPUT 0,
                                          INPUT FALSE,
                                          OUTPUT TABLE tt-erro).
          
            DELETE PROCEDURE h-b1wgen0043.

            IF   RETURN-VALUE <> "OK" THEN
                 RETURN "NOK".
           
            LEAVE.
        
        END. /* Final do estorno de pagamentos de emprestimo */        
    
        /* 3o. Passo */
        /* Estornar o valor pago a maior no pagamento do emprestimo */
        DO  WHILE TRUE:
                
            DO  aux_contador = 1 TO 10:
                
                FIND craplem WHERE craplem.cdcooper = par_cdcooper       AND
                                   craplem.dtmvtolt = par_dtmvtolt       AND
                                   craplem.cdagenci = 1                  AND
                                   craplem.cdbccxlt = 100                AND
                                   craplem.nrdolote = 9063               AND
                                   craplem.nrdconta = par_nrctasac       AND
                                   craplem.nrdocmto = DECI(aux_nrdocmto) AND
                                   craplem.cdhistor = 441
                                   USE-INDEX craplem1
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAILABLE craplem   THEN
                    DO:
                        IF  LOCKED craplem   THEN
                            DO:                           
                                PAUSE 1 NO-MESSAGE.
                                ASSIGN aux_cdcritic = 341.
                                NEXT.
                            END.
                        ELSE
                            DO:
                                flg_notfound = TRUE.
                                LEAVE.
                            END.    
                    END.                                       

                ASSIGN aux_cdcritic = 0.
                
                LEAVE.                   

            END. /* Final do DO .. TO */
                                       
            IF  flg_notfound THEN
                LEAVE.

            IF  aux_cdcritic > 0  THEN
                DO:
                    ASSIGN aux_dscritic = "".
                    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,     /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).

                    ASSIGN aux_flgderro = TRUE.

                    UNDO ESTORNO, LEAVE ESTORNO.
                
                END.

            DO  aux_contador = 1 TO 10:
                FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND
                                   craplot.dtmvtolt = par_dtmvtolt   AND
                                   craplot.cdagenci = 1              AND
                                   craplot.cdbccxlt = 100            AND
                                   craplot.nrdolote = 9063
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAILABLE craplot  THEN
                    DO:
                        IF  LOCKED craplot  THEN
                            DO:                           
                                PAUSE 1 NO-MESSAGE.
                                ASSIGN aux_cdcritic = 341.
                                NEXT.
                            END.
                    END.
               
                ASSIGN aux_cdcritic = 0.
                         
                LEAVE.

            END. /* Fim do DO ... TO */
            
            IF  aux_cdcritic > 0  THEN
                DO:
                    ASSIGN aux_dscritic = "".
                    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,     /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).

                    ASSIGN aux_flgderro = TRUE.

                    UNDO ESTORNO, LEAVE ESTORNO.
                END.

            ASSIGN craplot.qtcompln = craplot.qtcompln - 1
                   craplot.qtinfoln = craplot.qtinfoln - 1
                   craplot.vlinfocr = craplot.vlinfodb - craplem.vllanmto
                   craplot.vlcompcr = craplot.vlcompdb - craplem.vllanmto.    

            /* Caso lote zerado o mesmo eh removido. */
            IF  craplot.qtcompln = 0  THEN
                DELETE craplot.

            DELETE craplem.
            
            LEAVE.
        
        END. /* Final do estorno de valor pago a maior no pagto do emprestimo */
    
    END. /* Fim da Transacao de ESTORNO */
    
    IF  aux_flgderro  THEN
        DO:
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).

            RETURN "NOK".
        END.
            
    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).
                           
    RETURN "OK".

END PROCEDURE.

PROCEDURE valida_limites_credito:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_flglimcr AS CHAR                   NO-UNDO.

    DEF VAR aux_vlemprst_micro AS DECI                      NO-UNDO.
    DEF VAR aux_vlemprst_indep AS DECI                      NO-UNDO.

    aux_vlemprst_micro = 0.
    aux_vlemprst_indep = 0.

    FOR EACH craplcr WHERE craplcr.cdcooper = par_cdcooper,
    
    EACH crapepr WHERE crapepr.cdcooper = craplcr.cdcooper
    AND crapepr.cdlcremp = craplcr.cdlcremp
    AND crapepr.nrdconta = par_nrdconta
    AND crapepr.inliquid = 0
    NO-LOCK:

        /* Crédito Independente */
        ASSIGN aux_vlemprst_indep = aux_vlemprst_indep + crapepr.vlemprst.

        /* Microcrédito */
        IF craplcr.cdusolcr = 1 THEN
        DO:
         ASSIGN aux_vlemprst_micro = aux_vlemprst_micro + crapepr.vlemprst.
        END.
    END.
    
    IF aux_vlemprst_indep >= 40000 OR aux_vlemprst_micro >= 12000 THEN
        DO:
            par_flglimcr = "1".
        END.
    ELSE
        DO:
            par_flglimcr = "0".
        END.

END PROCEDURE.

/* .......................................................................... */
