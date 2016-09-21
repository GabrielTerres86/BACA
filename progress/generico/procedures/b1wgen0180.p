
/******************************************************************************
*                                                                             *
*   Programa: b1wgen0180.p                                                    *
*   Autor   : Lucas R.                                                        *
*   Data    : Novembro/2013                    Ultima atualizacao: 07/08/2014 *
*                                                                             *
*   Dados referentes ao programa:                                             *
*                                                                             *
*   Objetivo  : BO Referente a tela CONCAP "Consulta de Captacao"             *
*                                                                             *
*   Alteracoes: 29/01/2014 - Ajustar procedure cria-resgate para carregar os  *
*                            os agendamentos do dia                           *
*                          - Criar procedure cria-resgate-futuro para         *
*                            carregar os agendamentos futuros (David)         *
*               07/08/2014 - Incluido nova estrutura de lancamentos. (Reinert)*
*                                                                             *
******************************************************************************/

{ sistema/generico/includes/b1wgen0180tt.i }
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.

DEF VAR aux_vltotapl AS DEC                                            NO-UNDO.
DEF VAR aux_vltotrgt AS DEC                                            NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                           NO-UNDO.
DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmoperad AS CHAR                                           NO-UNDO.


DEF VAR h-b1wgen0004 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                         NO-UNDO.

PROCEDURE cria-aplicacao:

    DEF INPUT  PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_opcaoimp AS CHAR                              NO-UNDO.
    
    DEF OUTPUT PARAM par_vltotapl AS DEC                               NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-obtem-captacao.

    DEF VAR aux_cdoperad AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmoperad AS CHAR                                       NO-UNDO.


    FOR EACH craprda FIELDS(cdcooper nrdconta vlaplica nraplica cdoperad)
                     WHERE craprda.cdcooper = par_cdcooper AND
                           craprda.dtmvtolt = par_dtmvtolt NO-LOCK,
        FIRST crapass FIELDS(cdagenci nrdconta nmprimtl)
                      WHERE crapass.cdcooper = craprda.cdcooper AND
                            crapass.nrdconta = craprda.nrdconta
                            NO-LOCK:
    
        IF  par_cdagenci > 0 AND crapass.cdagenci <> par_cdagenci THEN
            NEXT. 
        
        ASSIGN aux_cdoperad = ""
               aux_nmoperad = "".

        IF craprda.cdoperad <> ? THEN
            DO:
                FIND crapope WHERE crapope.cdcooper = craprda.cdcooper
                               AND crapope.cdoperad = craprda.cdoperad
                                                     NO-LOCK NO-ERROR.
                IF  AVAIL(crapope) THEN
                    DO:
                        ASSIGN aux_cdoperad = crapope.cdoperad
                               aux_nmoperad = crapope.nmoperad.
                    END.
            END.        

        ASSIGN par_vltotapl = par_vltotapl + craprda.vlaplica.
                       
        CREATE tt-obtem-captacao.
        ASSIGN tt-obtem-captacao.cdagenci = crapass.cdagenci
               tt-obtem-captacao.cdoperad = aux_cdoperad
               tt-obtem-captacao.nmoperad = aux_nmoperad
               tt-obtem-captacao.nrdconta = crapass.nrdconta
               tt-obtem-captacao.nmprimtl = crapass.nmprimtl
               tt-obtem-captacao.nraplica = craprda.nraplica
               tt-obtem-captacao.vlaplica = craprda.vlaplica
               tt-obtem-captacao.tpdaimpr = "A".
    END.

    FOR EACH craprac FIELDS (cdcooper nrdconta vlaplica nraplica cdoperad)
                      WHERE craprac.cdcooper = par_cdcooper
                        AND craprac.dtmvtolt = par_dtmvtolt NO-LOCK,
        FIRST crapass FIELDS (cdagenci nrdconta nmprimtl)
                       WHERE crapass.cdcooper = craprac.cdcooper
                         AND crapass.nrdconta = craprac.nrdconta
                     NO-LOCK:

        IF  par_cdagenci > 0 AND crapass.cdagenci <> par_cdagenci THEN
            NEXT. 

        ASSIGN aux_cdoperad = ""
               aux_nmoperad = "".

        IF craprac.cdoperad <> ? THEN
            DO:
                FIND crapope WHERE crapope.cdcooper = craprac.cdcooper
                               AND crapope.cdoperad = craprac.cdoperad
                                                     NO-LOCK NO-ERROR.
                IF  AVAIL(crapope) THEN
                    DO:
                        ASSIGN aux_cdoperad = crapope.cdoperad
                               aux_nmoperad = crapope.nmoperad.
                    END.
            END.        


        ASSIGN par_vltotapl = par_vltotapl + craprac.vlaplica.
                       
        CREATE tt-obtem-captacao.
        ASSIGN tt-obtem-captacao.cdagenci = crapass.cdagenci
               tt-obtem-captacao.cdoperad = aux_cdoperad
               tt-obtem-captacao.nmoperad = aux_nmoperad
               tt-obtem-captacao.nrdconta = crapass.nrdconta
               tt-obtem-captacao.nmprimtl = crapass.nmprimtl
               tt-obtem-captacao.nraplica = craprac.nraplica
               tt-obtem-captacao.vlaplica = craprac.vlaplica
               tt-obtem-captacao.tpdaimpr = "A".
    END.

    RETURN "OK".

END.

PROCEDURE cria-resgate:

    DEF INPUT  PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_opcaoimp AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_cdprogra AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INTE                              NO-UNDO.

    DEF OUTPUT PARAM par_vltotrgt AS DEC                               NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-obtem-captacao.

    DEF VAR aux_lshistor AS CHAR                                       NO-UNDO.
    DEF VAR aux_tmphisto AS INTE                                       NO-UNDO.
    DEF VAR aux_contador AS INTE                                       NO-UNDO.
    DEF VAR aux_cdoperad AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmoperad AS CHAR                                       NO-UNDO.

    /* Historicos de resgates lancados na craplap 
       RDCA30: 118,126,492,493
       RDCA60: 178,183,494,495
       RDCPRE: 477
       RDCPOS: 534 */
    ASSIGN aux_lshistor = "118,126,492,493,178,183,494,495,477,534".

    EMPTY TEMP-TABLE tt-erro.

    /* Carregar os resgates agendados para o dia que ja foram efetuados. */
    DO aux_contador = 1 TO NUM-ENTRIES(aux_lshistor,","):

        ASSIGN aux_tmphisto = INTE(ENTRY(aux_contador,aux_lshistor,",")).

        /* Obter o valor do resgate lendo o lancamento do extrato */
        FOR EACH craplap FIELDS (cdcooper nrdconta nraplica vllanmto cdoperad)
                         WHERE craplap.cdcooper = par_cdcooper AND
                               craplap.dtmvtolt = par_dtmvtolt AND
                               craplap.cdhistor = aux_tmphisto NO-LOCK,
            FIRST crapass FIELDS (cdagenci nrdconta nmprimtl)
                          WHERE crapass.cdcooper = craplap.cdcooper AND
                                crapass.nrdconta = craplap.nrdconta NO-LOCK:

            IF  par_cdagenci > 0 AND crapass.cdagenci <> par_cdagenci  THEN
                NEXT.

            ASSIGN aux_cdoperad = ""
                   aux_nmoperad = "".
          
            IF craplap.cdoperad <> ? THEN
                DO:
                    FIND crapope WHERE crapope.cdcooper = craplap.cdcooper
                                   AND crapope.cdoperad = craplap.cdoperad
                                                         NO-LOCK NO-ERROR.
                                                          
                    IF  AVAIL(crapope) THEN
                        DO:
                            ASSIGN aux_cdoperad = crapope.cdoperad
                                   aux_nmoperad = crapope.nmoperad.
                        END. 
                END.
            

            CREATE tt-obtem-captacao.
            ASSIGN tt-obtem-captacao.cdagenci = crapass.cdagenci
                   tt-obtem-captacao.nrdconta = crapass.nrdconta
                   tt-obtem-captacao.nmprimtl = crapass.nmprimtl
                   tt-obtem-captacao.nraplica = craplap.nraplica
                   tt-obtem-captacao.vlaplica = craplap.vllanmto
                   tt-obtem-captacao.cdoperad = aux_cdoperad
                   tt-obtem-captacao.nmoperad = aux_nmoperad 
                   tt-obtem-captacao.tpdaimpr = "R".

            ASSIGN par_vltotrgt = par_vltotrgt + craplap.vllanmto.

        END.

    END.

    FOR EACH crapcpc FIELDS (cdhsrgap cdhsvtap) NO-LOCK:

        FOR EACH craplac FIELDS (cdcooper nrdconta nraplica vllanmto)
                         WHERE craplac.cdcooper = par_cdcooper      AND
                               craplac.dtmvtolt = par_dtmvtolt      AND
                              (craplac.cdhistor = crapcpc.cdhsrgap  OR
                               craplac.cdhistor = crapcpc.cdhsvtap) NO-LOCK,
            FIRST crapass FIELDS (cdagenci nrdconta nmprimtl)
                          WHERE crapass.cdcooper = craplac.cdcooper AND
                                crapass.nrdconta = craplac.nrdconta NO-LOCK:

            IF  par_cdagenci > 0 AND crapass.cdagenci <> par_cdagenci  THEN
                NEXT.

            CREATE tt-obtem-captacao.
            ASSIGN tt-obtem-captacao.cdagenci = crapass.cdagenci
                   tt-obtem-captacao.nrdconta = crapass.nrdconta
                   tt-obtem-captacao.nmprimtl = crapass.nmprimtl
                   tt-obtem-captacao.nraplica = craplac.nraplica
                   tt-obtem-captacao.vlaplica = craplac.vllanmto
                   tt-obtem-captacao.tpdaimpr = "R".

            ASSIGN par_vltotrgt = par_vltotrgt + craplac.vllanmto.

        END.

    END.

    IF  NOT VALID-HANDLE(h-b1wgen0004) THEN
        RUN sistema/generico/procedures/b1wgen0004.p 
            PERSISTENT SET h-b1wgen0004.

    /* Ler os resgates agendados para o dia que ainda nao foram efetuados */
    FOR EACH craplrg WHERE craplrg.cdcooper = par_cdcooper AND
                           craplrg.dtresgat = par_dtmvtolt AND
                           craplrg.inresgat = 0            NO-LOCK,
        FIRST crapass WHERE crapass.cdcooper = craplrg.cdcooper AND
                            crapass.nrdconta = craplrg.nrdconta NO-LOCK:
    
        /* Despreza resgate de poupanca programada */
        IF  craplrg.tpaplica = 4  THEN 
    	    NEXT.
    
        IF  par_cdagenci > 0 AND crapass.cdagenci <> par_cdagenci  THEN
            NEXT.
    
        /* Resgate total, portanto necessario carregar o saldo disponivel 
           para resgate atraves da procedure de consulta de aplicacoes */
        IF  craplrg.vllanmto = 0  THEN
            DO:  
                RUN consulta-aplicacoes IN h-b1wgen0004 
                                       (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_cdoperad,
                                        INPUT craplrg.nrdconta,
                                        INPUT craplrg.nraplica,
                                        INPUT 0,
                                        INPUT ?,
                                        INPUT ?,
                                        INPUT par_cdprogra,
                                        INPUT par_idorigem,
                                       OUTPUT TABLE tt-erro,
                                       OUTPUT TABLE tt-saldo-rdca).
            
                FIND FIRST tt-saldo-rdca NO-LOCK NO-ERROR.
        
                IF  AVAIL tt-saldo-rdca THEN
                    ASSIGN aux_vltotrgt = tt-saldo-rdca.sldresga
                           par_vltotrgt = par_vltotrgt + 
                                          tt-saldo-rdca.sldresga. 
            END.
        ELSE /* Resgate parcial, valor fica armazenado no campo vllanmto */
            ASSIGN aux_vltotrgt = craplrg.vllanmto
                   par_vltotrgt = par_vltotrgt + craplrg.vllanmto.
    

        ASSIGN aux_cdoperad = ""
               aux_nmoperad = "".
      
        IF craplrg.cdoperad <> ? THEN
            DO:
                FIND crapope WHERE crapope.cdcooper = craplrg.cdcooper
                               AND crapope.cdoperad = craplrg.cdoperad
                                                     NO-LOCK NO-ERROR.
                                                      
                IF  AVAIL(crapope) THEN
                    DO:
                        ASSIGN aux_cdoperad = crapope.cdoperad
                               aux_nmoperad = crapope.nmoperad.
                    END. 
            END.


        CREATE tt-obtem-captacao.
        ASSIGN tt-obtem-captacao.cdagenci = crapass.cdagenci
               tt-obtem-captacao.nrdconta = crapass.nrdconta
               tt-obtem-captacao.nmprimtl = crapass.nmprimtl
               tt-obtem-captacao.nraplica = craplrg.nraplica
               tt-obtem-captacao.cdoperad = aux_cdoperad
               tt-obtem-captacao.nmoperad = aux_nmoperad
               tt-obtem-captacao.vlaplica = aux_vltotrgt
               tt-obtem-captacao.tpdaimpr = "R"
               tt-obtem-captacao.dtresgat = craplrg.dtresgat.

    END.

    IF  VALID-HANDLE(h-b1wgen0004) THEN
        DELETE PROCEDURE h-b1wgen0004.

    RETURN "OK".

END.

PROCEDURE cria-resgate-futuro:

    DEF INPUT  PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_opcaoimp AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_cdprogra AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INTE                              NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-obtem-captacao.

    EMPTY TEMP-TABLE tt-erro.

    DEF VAR aux_vlsldrgt AS DECI                                       NO-UNDO.


    IF  NOT VALID-HANDLE(h-b1wgen0004)  THEN
        RUN sistema/generico/procedures/b1wgen0004.p 
            PERSISTENT SET h-b1wgen0004.

    /* Ler os resgates agendados para o dia que ainda nao foram efetuados */
    FOR EACH craplrg FIELDS(cdcooper nrdconta tpaplica vllanmto
                            nrdconta nraplica dtresgat cdoperad)
                     WHERE craplrg.cdcooper = par_cdcooper AND
                           craplrg.dtresgat > par_dtmvtolt AND
                           craplrg.inresgat = 0            NO-LOCK,
        FIRST crapass FIELDS(cdagenci nrdconta nmprimtl)
                      WHERE crapass.cdcooper = craplrg.cdcooper AND
                            crapass.nrdconta = craplrg.nrdconta NO-LOCK:
    
        /* Despreza resgate de poupanca programada */
        IF  craplrg.tpaplica = 4  THEN 
    	    NEXT.  
    
        IF  par_cdagenci > 0 AND crapass.cdagenci <> par_cdagenci  THEN
            NEXT.
    
        /* Resgate total, portanto necessario carregar o saldo disponivel 
           para resgate atraves da procedure de consulta de aplicacoes */
        IF  craplrg.vllanmto = 0  THEN
            DO:  
                RUN consulta-aplicacoes IN h-b1wgen0004 
                                       (INPUT par_cdcooper,             
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_cdoperad,
                                        INPUT craplrg.nrdconta,
                                        INPUT craplrg.nraplica,
                                        INPUT 0,
                                        INPUT ?,
                                        INPUT ?,
                                        INPUT par_cdprogra,
                                        INPUT par_idorigem,
                                       OUTPUT TABLE tt-erro,
                                       OUTPUT TABLE tt-saldo-rdca).
            
                FIND FIRST tt-saldo-rdca NO-LOCK NO-ERROR.
        
                IF  AVAIL tt-saldo-rdca THEN
                    ASSIGN aux_vltotrgt = tt-saldo-rdca.sldresga.
            END.
        ELSE /* Resgate parcial, valor fica armazenado no campo vllanmto */
            ASSIGN aux_vltotrgt = craplrg.vllanmto.
    
        ASSIGN aux_cdoperad = ""
               aux_nmoperad = "".
      
        IF craplrg.cdoperad <> ? THEN
            DO:
                FIND crapope WHERE crapope.cdcooper = craplrg.cdcooper
                               AND crapope.cdoperad = craplrg.cdoperad
                                                     NO-LOCK NO-ERROR.
                                                      
                IF  AVAIL(crapope) THEN
                    DO:
                        ASSIGN aux_cdoperad = crapope.cdoperad
                               aux_nmoperad = crapope.nmoperad.
                    END. 
            END.

        CREATE tt-obtem-captacao.
        ASSIGN tt-obtem-captacao.cdagenci = crapass.cdagenci
               tt-obtem-captacao.nrdconta = crapass.nrdconta
               tt-obtem-captacao.nmprimtl = crapass.nmprimtl
               tt-obtem-captacao.nraplica = craplrg.nraplica
               tt-obtem-captacao.cdoperad = aux_cdoperad
               tt-obtem-captacao.nmoperad = aux_nmoperad
               tt-obtem-captacao.vlaplica = aux_vltotrgt
               tt-obtem-captacao.tpdaimpr = "F"
               tt-obtem-captacao.dtresgat = craplrg.dtresgat.

    END.

    FOR EACH craprga FIELDS(cdcooper nrdconta idtiprgt nraplica
                            vlresgat dtresgat cdoperad)       
                     WHERE craprga.cdcooper = par_cdcooper AND
                           craprga.dtresgat > par_dtmvtolt AND
                           craprga.idresgat = 0            NO-LOCK,
        FIRST crapass FIELDS(cdagenci nrdconta nmprimtl)
                      WHERE crapass.cdcooper = craprga.cdcooper AND
                            crapass.nrdconta = craprga.nrdconta NO-LOCK:

        IF  par_cdagenci > 0 AND crapass.cdagenci <> par_cdagenci  THEN
            NEXT.

        IF  craprga.idtiprgt = 2 THEN
            DO:
                                
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
            
                /* Rotina referente a consulta de saldos de aplicacao */
                RUN STORED-PROCEDURE pc_busca_saldo_aplicacoes
                    aux_handproc = PROC-HANDLE NO-ERROR
                                     (INPUT par_cdcooper,           /*Código da Cooperativa                                                                               */
                                      INPUT par_cdoperad,           /*Código do Operador                                                                                  */
                                      INPUT "CONCAP",               /*Nome da Tela                                                                                        */
                                      INPUT par_idorigem,           /*Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                      INPUT crapass.nrdconta,       /*Número da Conta                                                                                     */
                                      INPUT 1,                      /*Titular da Conta                                                                                    */
                                      INPUT craprga.nraplica,       /*Número da Aplicação / Parâmetro Opcional                                                            */
                                      INPUT par_dtmvtolt,           /*Data de Movimento                                                                                   */
                                      INPUT 0,                      /*Código do Produto -–> Parâmetro Opcional                                                            */
                                      INPUT 1,                      /*Identificador de Bloqueio de Resgate (1 – Todas / 2 – Bloqueadas / 3 – Desbloqueadas)               */ 
                                      INPUT 1,                      /*Identificador de Log (0 – Não / 1 – Sim)                                                            */ 
                                      OUTPUT 0,                     /*Saldo Total da Aplicação                                                                            */ 
                                      OUTPUT 0,                     /*Saldo Total para Resgate                                                                            */ 
                                      OUTPUT 0,                     /*Código da crítica                                                                                   */ 
                                      OUTPUT "").                   /*Descrição da crítica                                                                                */ 
                                                                    
                CLOSE STORED-PROC pc_busca_saldo_aplicacoes
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
                
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = ""
                       aux_vlsldrgt = 0
                       aux_cdcritic = pc_busca_saldo_aplicacoes.pr_cdcritic 
                                      WHEN pc_busca_saldo_aplicacoes.pr_cdcritic <> ?
                       aux_dscritic = pc_busca_saldo_aplicacoes.pr_dscritic 
                                      WHEN pc_busca_saldo_aplicacoes.pr_dscritic <> ?
                       aux_vlsldrgt = pc_busca_saldo_aplicacoes.pr_vlsldrgt
                                      WHEN pc_busca_saldo_aplicacoes.pr_vlsldrgt <> ?.
                    
                IF  aux_cdcritic <> 0   OR
                    aux_dscritic <> ""  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.cdcritic = aux_cdcritic
                           tt-erro.dscritic = aux_dscritic.
                END.
                    
                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

            END.
        ELSE
            ASSIGN aux_vlsldrgt = craprga.vlresgat.


        ASSIGN aux_cdoperad = ""
               aux_nmoperad = "".
      
        IF craprga.cdoperad <> ? THEN
            DO:
                FIND crapope WHERE crapope.cdcooper = craprga.cdcooper
                               AND crapope.cdoperad = craprga.cdoperad
                                                     NO-LOCK NO-ERROR.
                                                      
                IF  AVAIL(crapope) THEN
                    DO:
                        ASSIGN aux_cdoperad = crapope.cdoperad
                               aux_nmoperad = crapope.nmoperad.
                    END. 
            END.

        CREATE tt-obtem-captacao.
        ASSIGN tt-obtem-captacao.cdagenci = crapass.cdagenci
               tt-obtem-captacao.nrdconta = crapass.nrdconta
               tt-obtem-captacao.nmprimtl = crapass.nmprimtl
               tt-obtem-captacao.nraplica = craprga.nraplica
               tt-obtem-captacao.cdoperad = aux_cdoperad
               tt-obtem-captacao.nmoperad = aux_nmoperad
               tt-obtem-captacao.vlaplica = aux_vlsldrgt
               tt-obtem-captacao.tpdaimpr = "F"
               tt-obtem-captacao.dtresgat = craprga.dtresgat.

    END.

    IF  VALID-HANDLE(h-b1wgen0004) THEN
        DELETE PROCEDURE h-b1wgen0004.

    RETURN "OK".

END.

PROCEDURE consulta-captacao:

    DEF INPUT  PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_opcaoimp AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_cdprogra AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrregist AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nriniseq AS INTE                              NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_vltotrgt AS DECI                              NO-UNDO.
    DEF OUTPUT PARAM par_vltotapl AS DECI                              NO-UNDO.
    DEF OUTPUT PARAM par_vlcapliq AS DECI                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-captacao.

    EMPTY TEMP-TABLE tt-obtem-captacao.
    EMPTY TEMP-TABLE tt-captacao.

    DEF VAR aux_nrregist AS INTE                                       NO-UNDO.

    ASSIGN aux_nrregist = par_nrregist.
 
    /* Aplicacao */
    RUN cria-aplicacao (INPUT par_cdcooper,
                        INPUT par_dtmvtolt,
                        INPUT par_cdagenci,
                        INPUT par_opcaoimp,
                       OUTPUT par_vltotapl,
                       OUTPUT TABLE tt-obtem-captacao).
    
    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".
        
    RUN cria-resgate (INPUT par_cdcooper,
                      INPUT par_dtmvtolt,
                      INPUT par_cdagenci,
                      INPUT par_opcaoimp,
                      INPUT par_nrdcaixa,
                      INPUT par_cdoperad,
                      INPUT par_cdprogra,
                      INPUT par_idorigem,
                     OUTPUT par_vltotrgt,
                     OUTPUT TABLE tt-erro,
                     OUTPUT TABLE tt-obtem-captacao).
    
    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".
        
    IF  par_opcaoimp = "F"  THEN /* Resgates futuros D+1 */
        DO:
            RUN cria-resgate-futuro (INPUT par_cdcooper,
                                     INPUT par_dtmvtolt,
                                     INPUT par_cdagenci,
                                     INPUT par_opcaoimp,
                                     INPUT par_nrdcaixa,
                                     INPUT par_cdoperad,
                                     INPUT par_cdprogra,
                                     INPUT par_idorigem,
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-obtem-captacao).
     
            IF  RETURN-VALUE <> "OK" THEN
                RETURN "NOK".
        END.
    
     /*  Calculo para captacao liquida */
     ASSIGN par_vlcapliq = par_vltotapl - par_vltotrgt.
    
     IF  aux_nrregist > 0 THEN
         DO: 
             FOR EACH tt-obtem-captacao NO-LOCK WHERE 
                      tt-obtem-captacao.tpdaimpr = par_opcaoimp
                      USE-INDEX tt-obtem-captacao1:
                         
                 ASSIGN par_qtregist = par_qtregist + 1.
                 
                 IF  (par_qtregist < par_nriniseq) OR
                     (par_qtregist >= (par_nriniseq + par_nrregist)) THEN
                     NEXT.
                     
                 CREATE tt-captacao.
                 BUFFER-COPY tt-obtem-captacao TO tt-captacao.
                              
             END.
    
             ASSIGN aux_nrregist = aux_nrregist - 1. 
    
         END.
     
    RETURN "OK".

END.

PROCEDURE imprime-captacao:

    DEF INPUT  PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_opcaoimp AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_cdprogra AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nmendter AS CHAR                              NO-UNDO.
    
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                              NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_qtregist AS INTE                                       NO-UNDO.
    DEF VAR aux_resgate  AS DECI                                       NO-UNDO.
    DEF VAR aux_aplica   AS DECI                                       NO-UNDO.
    DEF VAR aux_recliq   AS DECI                                       NO-UNDO.
    DEF VAR aux_dsoperad AS CHAR                                       NO-UNDO.

    FORM tt-obtem-captacao.cdagenci COLUMN-LABEL "PA"        FORMAT "zz9"
         tt-obtem-captacao.nrdconta COLUMN-LABEL "Conta/Dv"  FORMAT "zzzz,zzz,9"
         tt-obtem-captacao.nmprimtl COLUMN-LABEL "Nome"      FORMAT "x(39)"
         tt-obtem-captacao.nraplica COLUMN-LABEL "Aplicacao" FORMAT "zzzzz,zz9"
         tt-obtem-captacao.vlaplica COLUMN-LABEL "Valor"     FORMAT "zzz,zzz,zz9.99"
         aux_dsoperad               COLUMN-LABEL "Operador"  FORMAT "x(20)"
         WITH NO-BOX NO-ATTR-SPACE DOWN WIDTH 132 FRAME f_captacao.

    FORM tt-obtem-captacao.cdagenci COLUMN-LABEL "PA"        FORMAT "zz9"
         tt-obtem-captacao.nrdconta COLUMN-LABEL "Conta/Dv"  FORMAT "zzzz,zzz,9"
         tt-obtem-captacao.nmprimtl COLUMN-LABEL "Nome"      FORMAT "x(29)"
         tt-obtem-captacao.nraplica COLUMN-LABEL "Aplicacao" FORMAT "zzzzz,zz9"
         tt-obtem-captacao.vlaplica COLUMN-LABEL "Valor"     FORMAT "zzzzzz,zz9.99"
         tt-obtem-captacao.dtresgat COLUMN-LABEL "Resgate"   FORMAT "99/99/9999"
         aux_dsoperad               COLUMN-LABEL "Operador"  FORMAT "x(20)"
         WITH NO-BOX NO-ATTR-SPACE DOWN WIDTH 132 FRAME f_resgate_futuro.

    FORM par_dtmvtolt LABEL "Data movimento"             AT 13 
                      FORMAT "99/99/9999"
         aux_aplica   LABEL "Total de aplicacoes do dia" AT 01 
                      FORMAT "zzz,zzz,zz9.99"
         SKIP
         aux_resgate  LABEL "Total de resgates do dia"   AT 03 
                      FORMAT "zzz,zzz,zz9.99"
         SKIP
         aux_recliq   LABEL "Captacao liquida do dia"    AT 04 
                      FORMAT "zzz,zzz,zz9.99-"
         SKIP(2)
         WITH SIDE-LABEL WIDTH 132 FRAME f_total.
   
   /*busca valores de aplicacao */
   RUN cria-aplicacao (INPUT par_cdcooper,
                       INPUT par_dtmvtolt,
                       INPUT par_cdagenci,
                       INPUT par_opcaoimp,
                      OUTPUT aux_aplica,
                      OUTPUT TABLE tt-obtem-captacao).
   
   IF  RETURN-VALUE <> "OK" THEN
       RETURN "NOK".
   
   /* Resgates do dia */
   RUN cria-resgate (INPUT par_cdcooper,
                     INPUT par_dtmvtolt,
                     INPUT par_cdagenci,
                     INPUT par_opcaoimp,
                     INPUT par_nrdcaixa,
                     INPUT par_cdoperad,
                     INPUT par_cdprogra,
                     INPUT par_idorigem,
                    OUTPUT aux_resgate,
                    OUTPUT TABLE tt-erro,
                    OUTPUT TABLE tt-obtem-captacao).
   
   IF  par_opcaoimp = "F"  THEN /* Resgates futuros D+1 */
       DO: 
           RUN cria-resgate-futuro (INPUT par_cdcooper,
                                    INPUT par_dtmvtolt,
                                    INPUT par_cdagenci,
                                    INPUT par_opcaoimp,
                                    INPUT par_nrdcaixa,
                                    INPUT par_cdoperad,
                                    INPUT par_cdprogra,
                                    INPUT par_idorigem,
                                   OUTPUT TABLE tt-erro,
                                   OUTPUT TABLE tt-obtem-captacao).
       
           IF  RETURN-VALUE <> "OK" THEN
               RETURN "OK".
       END.

    /* Calculo para captacao liquida */
    ASSIGN aux_recliq  = aux_aplica - aux_resgate. 
    
    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO: 
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".
        END.

    ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                          par_nmendter.
        
    UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
    
    ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
           par_nmarqimp = aux_nmendter + ".ex"
           par_nmarqpdf = aux_nmendter + ".pdf".

    OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) PAGED PAGE-SIZE 62.

    DISP STREAM str_1 par_dtmvtolt aux_aplica aux_resgate aux_recliq
                      WITH FRAME f_total.

    FIND FIRST tt-obtem-captacao NO-LOCK NO-ERROR.

    IF  NOT AVAIL tt-obtem-captacao  THEN
        RETURN "NOK".

    FOR EACH tt-obtem-captacao NO-LOCK WHERE 
             tt-obtem-captacao.tpdaimpr = par_opcaoimp
             BREAK BY tt-obtem-captacao.vlaplica DESC:

        IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.
        
        ASSIGN aux_dsoperad = "".

        IF  tt-obtem-captacao.cdoperad <> "" THEN
            DO:
                ASSIGN aux_dsoperad = tt-obtem-captacao.cdoperad + " - " +
                                      tt-obtem-captacao.nmoperad.
            END.

        IF  par_opcaoimp = "F"  THEN
            DO: 
                DISP STREAM str_1 tt-obtem-captacao.cdagenci
                                  tt-obtem-captacao.nrdconta
                                  tt-obtem-captacao.nmprimtl
                                  tt-obtem-captacao.nraplica
                                  tt-obtem-captacao.vlaplica
                                  tt-obtem-captacao.dtresgat
                                  aux_dsoperad
                                  WITH FRAME f_resgate_futuro.
                DOWN STREAM str_1 WITH FRAME f_resgate_futuro.
            END.
        ELSE
            DO:
                DISP STREAM str_1 tt-obtem-captacao.cdagenci
                                  tt-obtem-captacao.nrdconta
                                  tt-obtem-captacao.nmprimtl
                                  tt-obtem-captacao.nraplica
                                  tt-obtem-captacao.vlaplica
                                  aux_dsoperad
                                  WITH FRAME f_captacao.
                DOWN STREAM str_1 WITH FRAME f_captacao.
            END.

    END.

    OUTPUT STREAM str_1 CLOSE.

    /* Gera relatorio em PDF */
    RUN sistema/generico/procedures/b1wgen0024.p
        PERSISTENT SET h-b1wgen0024.

    RUN envia-arquivo-web IN h-b1wgen0024
                         (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_nmarqimp,
                         OUTPUT par_nmarqpdf,
                         OUTPUT TABLE tt-erro).     

     DELETE PROCEDURE h-b1wgen0024. 

    IF  RETURN-VALUE <> "OK"   THEN
        RETURN "NOK".

    RETURN "OK".

END.




