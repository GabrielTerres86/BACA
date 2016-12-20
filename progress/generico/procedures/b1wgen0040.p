/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +------------------------------------------+--------------------------------+
  | Rotina Progress                          | Rotina Oracle PLSQL            |
  +------------------------------------------+--------------------------------+
  | sistema/generico/procedures/b1wgen0040.p |                                |
  |  -  verifica-conta                       | cheq0001.pc_verif_conta
  |  -  busca-cheques                        | cheq0001.pc_busca_cheque       |
  |  -  gera-tt-cheque                       | cheq0001.pc_gera_cheques       |
  |  -  calc_cmc7_difcompe                   | cheq0001.pc_calc_cmc7_difcompe |
  +------------------------------------------+--------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/



/*..............................................................................

    Programa: b1wgen0040.p
    Autor   : David
    Data    : Maio/2009                       Ultima Atualizacao: 01/12/2016
           
    Dados referentes ao programa:
                
    Objetivo  : BO ref. a Custodia e Consulta de Cheques.
                Baseada nos programas fontes/custod.p e fontes/cheque.p.
                    
    Alteracoes: 16/12/2009 - Incluir procedure para consulta de folhas de
                             cheque (David).
                             
                02/05/2011 - Incluir procedure de busca de cheques. 
                             (André - DB1)
                
                09/12/2011 - Sustação provisória (André R./Supero).
                
                31/07/2012 - Tratamento para a tela IMGCHQ (Fabricio/Ze).
                
                20/08/2012 - Incluir parametro no consulta-cheque-compensado 
                             - Tipo de Documento (Ze).
                             
                31/08/2012 - Incluido na gravacao da tt-cheques os campos
                             de custodia de cheque (Tiago).  
                             
                18/10/2012 - Nova chamada da procedure valida_operador_migrado
                             da b1wgen9998 para controle de contas e operadores
                             migrados (David Kruger).                       
                
                20/12/2013 - Adicionado validate para tabela craplgm (Tiago).                                                     
                
                30/06/2014 - Incluir campo cdageaco ao criar temp-table 
                             tt-cheques na procedure gera-tt-cheque. (Reinert)
                             
                16/09/2014 - Inclusão do campo cdagechq na tt-cheque
                             na procedure gera-tt-cheque. (Vanessa)
                
                10/10/2014 - #200504 Ajustes consulta-cheque-compensado para
                             incorporacoes (Concredi e Credimilsul) (Carlos)

                01/12/2016 - Incorporacao Transulcred (Guilherme/SUPERO)

..............................................................................*/


/*................................ DEFINICOES ................................*/


{ sistema/generico/includes/b1wgen0040tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
                                                                    
/*............................ PROCEDURES EXTERNAS ...........................*/


/******************************************************************************/
/**           Procedure para obter resumo de cheques em custodia             **/
/******************************************************************************/
PROCEDURE resumo-cheques-custodia:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
            
    DEF OUTPUT PARAM TABLE FOR tt-resumo-custodia.

    DEF VAR aux_qttotchq AS INTE                                    NO-UNDO.
    
    DEF VAR aux_vltotchq AS DECI                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-resumo-custodia.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Resumo de cheques em custodia"
           aux_qttotchq = 0
           aux_vltotchq = 0.
    
    FOR EACH crapcst WHERE crapcst.cdcooper  = par_cdcooper AND
                           crapcst.nrdconta  = par_nrdconta AND
                           crapcst.dtlibera >= par_dtiniper AND
                           crapcst.dtlibera <= par_dtfimper 
                           USE-INDEX crapcst2 NO-LOCK 
                           BREAK BY crapcst.dtlibera:

        IF  FIRST-OF(crapcst.dtlibera)  THEN
            DO:
                CREATE tt-resumo-custodia.
                ASSIGN tt-resumo-custodia.dtlibera = crapcst.dtlibera
                       tt-resumo-custodia.qtcheque = 0
                       tt-resumo-custodia.vlcheque = 0.
            END.

        ASSIGN tt-resumo-custodia.qtcheque = tt-resumo-custodia.qtcheque + 1
               tt-resumo-custodia.vlcheque = tt-resumo-custodia.vlcheque +
                                             crapcst.vlcheque.
                                             
        IF  LAST-OF(crapcst.dtlibera)  THEN
            ASSIGN aux_qttotchq = aux_qttotchq + tt-resumo-custodia.qtcheque
                   aux_vltotchq = aux_vltotchq + tt-resumo-custodia.vlcheque.

    END.

    CREATE tt-resumo-custodia.
    ASSIGN tt-resumo-custodia.dtlibera = ?
           tt-resumo-custodia.qtcheque = aux_qttotchq
           tt-resumo-custodia.vlcheque = aux_vltotchq.
    
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


/******************************************************************************/
/**           Procedure para obter cheques que estao em custodia             **/
/******************************************************************************/
PROCEDURE consultar-cheques-custodia:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtlibera AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgpagin AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
            
    DEF OUTPUT PARAM par_qtcheque AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-cheques-custodia.

    EMPTY TEMP-TABLE tt-cheques-custodia.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Consultar cheques em custodia".
    
    FOR EACH crapcst WHERE crapcst.cdcooper = par_cdcooper AND
                           crapcst.nrdconta = par_nrdconta AND
                           crapcst.dtlibera = par_dtlibera 
                           USE-INDEX crapcst2 NO-LOCK 
                           BY crapcst.vlcheque 
                              BY crapcst.cdbanchq
                                 BY crapcst.cdagechq
                                    BY crapcst.nrctachq
                                       BY crapcst.nrcheque: 

        ASSIGN par_qtcheque = par_qtcheque + 1.
        
        /** Cadastrar somente os registros da paginacao selecionada **/
        IF  par_flgpagin  THEN 
            IF  par_qtcheque < par_nriniseq                    OR
                par_qtcheque >= (par_nriniseq + par_nrregist)  THEN
                NEXT.
        
        CREATE tt-cheques-custodia.
        ASSIGN tt-cheques-custodia.dtlibera = crapcst.dtlibera  
               tt-cheques-custodia.cdbanchq = crapcst.cdbanchq  
               tt-cheques-custodia.cdagechq = crapcst.cdagechq
               tt-cheques-custodia.nrctachq = crapcst.nrctachq  
               tt-cheques-custodia.nrcheque = crapcst.nrcheque  
               tt-cheques-custodia.vlcheque = crapcst.vlcheque
               tt-cheques-custodia.dtdevolu = crapcst.dtdevolu  
               tt-cheques-custodia.tpdevolu = IF  crapcst.dtdevolu = ?  THEN
                                                  ""
                                              ELSE
                                              IF  crapcst.insitchq = 1  THEN
                                                  "Resgatado"
                                              ELSE
                                                  "Descontado"
               tt-cheques-custodia.cdopedev = crapcst.cdopedev.

    END. /** Fim do FOR EACH crapcst **/

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


/******************************************************************************/
/**               Procedure para consulta de folhas de cheque                **/
/******************************************************************************/
PROCEDURE consultar-folhas-cheque:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idconchq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgpagin AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
            
    DEF OUTPUT PARAM par_qtcheque AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-consulta-cheque.

    EMPTY TEMP-TABLE tt-consulta-cheque.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Consultar folhas de cheque".

    IF  par_idconchq = 1  THEN  /** Compensados **/
        FOR EACH crapfdc WHERE crapfdc.cdcooper  = par_cdcooper AND
                               crapfdc.nrdconta  = par_nrdconta AND
                               crapfdc.incheque  = 5            AND
                               crapfdc.dtliqchq <> ?            NO-LOCK 
                               USE-INDEX crapfdc4 BY crapfdc.dtliqchq
                                                     BY crapfdc.nrcheque:

            RUN cria-registro-cheque (INPUT par_dtiniper,
                                      INPUT par_dtfimper,
                                      INPUT par_flgpagin, 
                                      INPUT par_nriniseq, 
                                      INPUT par_nrregist, 
                                      INPUT "COMPENSADO", 
                                      INPUT-OUTPUT par_qtcheque).

        END. /** Fim do FOR EACH crapfdc - Compensados **/
    ELSE
    IF  par_idconchq = 2  THEN  /** Cancelados **/
        FOR EACH crapfdc WHERE crapfdc.cdcooper = par_cdcooper AND 
                               crapfdc.nrdconta = par_nrdconta AND
                               crapfdc.incheque = 8            NO-LOCK
                               USE-INDEX crapfdc4 BY crapfdc.dtliqchq 
                                                     BY crapfdc.nrcheque:
        
            RUN cria-registro-cheque (INPUT par_dtiniper,
                                      INPUT par_dtfimper,
                                      INPUT par_flgpagin, 
                                      INPUT par_nriniseq, 
                                      INPUT par_nrregist, 
                                      INPUT "CANCELADO", 
                                      INPUT-OUTPUT par_qtcheque).    

        END. /** Fim do FOR EACH crapfdc - Cancelados **/
    ELSE
    IF  par_idconchq = 3  THEN  /** Nao Compensados **/
        FOR EACH crapfdc WHERE crapfdc.cdcooper  = par_cdcooper AND
                               crapfdc.nrdconta  = par_nrdconta AND
                               crapfdc.dtliqchq  = ?            AND 
                               crapfdc.dtretchq <> ?            AND
                               crapfdc.incheque <> 8            NO-LOCK 
                               USE-INDEX crapfdc4 BY crapfdc.dtretchq 
                                                     BY crapfdc.nrcheque:
        
            RUN cria-registro-cheque (INPUT par_dtiniper,
                                      INPUT par_dtfimper,
                                      INPUT par_flgpagin, 
                                      INPUT par_nriniseq, 
                                      INPUT par_nrregist, 
                                      INPUT "NAO COMPENSADO", 
                                      INPUT-OUTPUT par_qtcheque).

        END. /** Fim do FOR EACH crapfdc - Não Compensados **/           
    ELSE
    IF  par_idconchq = 4  THEN  /** Todos **/
        FOR EACH crapfdc WHERE crapfdc.cdcooper = par_cdcooper AND
                               crapfdc.nrdconta = par_nrdconta NO-LOCK 
                               USE-INDEX crapfdc2 BY crapfdc.nrcheque:

            IF  crapfdc.incheque  = 5  AND 
                crapfdc.dtliqchq <> ?  THEN 
                RUN cria-registro-cheque (INPUT par_dtiniper,
                                          INPUT par_dtfimper,
                                          INPUT par_flgpagin, 
                                          INPUT par_nriniseq, 
                                          INPUT par_nrregist, 
                                          INPUT "COMPENSADO", 
                                          INPUT-OUTPUT par_qtcheque).
            ELSE
            IF  crapfdc.incheque = 8  THEN
                RUN cria-registro-cheque (INPUT par_dtiniper,
                                          INPUT par_dtfimper,
                                          INPUT par_flgpagin, 
                                          INPUT par_nriniseq, 
                                          INPUT par_nrregist, 
                                          INPUT "CANCELADO", 
                                          INPUT-OUTPUT par_qtcheque).
            ELSE
            IF  crapfdc.dtliqchq  = ?  AND
                crapfdc.dtretchq <> ?  AND
                crapfdc.incheque <> 8  THEN
                RUN cria-registro-cheque (INPUT par_dtiniper,
                                          INPUT par_dtfimper,
                                          INPUT par_flgpagin, 
                                          INPUT par_nriniseq, 
                                          INPUT par_nrregist, 
                                          INPUT "NAO COMPENSADO", 
                                          INPUT-OUTPUT par_qtcheque).

        END. /** Fim do FOR EACH crapfdc - Todos **/

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


PROCEDURE verifica-conta:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_nmprimtl AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_qtrequis AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dsmsgcnt AS CHAR                           NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR h-b1wgen9998 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_opmigrad AS LOG                                     NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Buscar cheques"
           par_qtrequis = 0.
            
    Busca: DO WHILE TRUE:
        
        EMPTY TEMP-TABLE tt-erro.

        RUN sistema/generico/procedures/b1wgen9998.p
            PERSISTENT SET h-b1wgen9998.
      
        /* Validacao de operado e conta migrada */
        RUN valida_operador_migrado IN h-b1wgen9998 (INPUT par_cdoperad,
                                                     INPUT par_nrdconta,
                                                     INPUT par_cdcooper,
                                                     INPUT par_cdagenci,
                                                     OUTPUT aux_opmigrad,
                                                     OUTPUT TABLE tt-erro).
                     
        DELETE PROCEDURE h-b1wgen9998.
                   
        IF  RETURN-VALUE <> "OK"  THEN
            DO:
               FIND tt-erro NO-LOCK NO-ERROR.

               IF AVAIL tt-erro THEN
                  DO:
                     ASSIGN aux_cdcritic = tt-erro.cdcritic.

                     EMPTY TEMP-TABLE tt-erro.
                  END.
               ELSE
                 ASSIGN aux_cdcritic = 36.
                
                 LEAVE Busca.

            END.

        IF  par_nrdconta > 0  THEN
            DO:
    
                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = par_nrdconta 
                                   NO-LOCK NO-ERROR.
                                   
                IF  NOT AVAILABLE crapass  THEN
                    DO:
                        ASSIGN aux_cdcritic = 9.
                        LEAVE Busca.
                    END.
        
        
                ASSIGN par_nmprimtl = crapass.nmprimtl.
        
                FIND craptrf WHERE craptrf.cdcooper = par_cdcooper       AND
                                   craptrf.nrdconta = crapass.nrdconta   AND
                                   craptrf.tptransa = 1                  AND
                                   craptrf.insittrs = 2
                                   NO-LOCK NO-ERROR.
        
                IF  AVAILABLE craptrf   THEN
                    DO:
                        ASSIGN par_dsmsgcnt = "Conta transferida para" +
                                                                                 STRING(craptrf.nrsconta,"zzzz,zzz,9").
                    END.
        
                FOR EACH crapreq WHERE crapreq.cdcooper = par_cdcooper   AND
                                       crapreq.nrdconta = par_nrdconta   AND
                                       crapreq.insitreq = 1              AND
                                       crapreq.tprequis = 1         NO-LOCK:
                                  
                    par_qtrequis = par_qtrequis + (crapreq.qtreqtal * 20).
        
                END.
            END.
        ELSE
            ASSIGN par_nmprimtl = "*** TALONARIOS AVULSOS ***".


        LEAVE Busca.

    END.

    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
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

    RETURN "OK".

END PROCEDURE.



PROCEDURE busca-cheques:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF  INPUT PARAM par_nrtipoop AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcheque AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM aux_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-cheques.

    DEF VAR aux_nrregist AS INTE                                    NO-UNDO.
    DEF VAR aux_lscontas AS CHAR                                    NO-UNDO.
    DEF VAR h-b1wgen0060 AS HANDLE                                  NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-cheques.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Buscar cheques"
           aux_nrregist = par_nrregist.
            
    Busca: DO WHILE TRUE:

        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p
                PERSISTENT SET h-b1wgen0060.

        /*  Le tabela com as contas convenio do Banco do Brasil  */
        DYNAMIC-FUNCTION("BuscaCtaCe" IN h-b1wgen0060,
                         INPUT par_cdcooper,
                         INPUT 0,
                        OUTPUT aux_lscontas,
                        OUTPUT aux_dscritic).
        
        IF  VALID-HANDLE(h-b1wgen0060) THEN
            DELETE OBJECT h-b1wgen0060.

        IF  aux_dscritic <> "" THEN
            LEAVE Busca.

            CASE par_nrtipoop:
                    WHEN 1 THEN DO:
                            FOR EACH crapfdc WHERE crapfdc.cdcooper = par_cdcooper AND 
                                                                       crapfdc.nrdconta = par_nrdconta AND
                                                                       crapfdc.dtliqchq =  ?           AND 
                                                                       crapfdc.dtretchq <> ?
                                                                       USE-INDEX crapfdc2 NO-LOCK
                                                                       BY crapfdc.nrctachq DESC
                                                                       BY crapfdc.nrseqems DESC 
                                                                       BY crapfdc.nrcheque DESC:

                    RUN gera-tt-cheque ( INPUT par_nrtipoop,
                                         INPUT par_cdcooper,
                                         INPUT aux_lscontas,
                                         INPUT par_nrregist,
                                         INPUT par_nriniseq,
                                         INPUT-OUTPUT aux_nrregist,
                                         INPUT-OUTPUT aux_qtregist,
                                         INPUT-OUTPUT TABLE tt-cheques ).
                            END.
                    END.

                    WHEN 2 THEN DO:
                            FOR EACH crapfdc WHERE crapfdc.cdcooper = par_cdcooper AND 
                                                                       crapfdc.nrdconta = par_nrdconta AND
                                                                       crapfdc.dtretchq =  ?           AND 
                                                                       crapfdc.dtemschq <> ?
                                                                       USE-INDEX crapfdc2 NO-LOCK
                                                                       BY crapfdc.nrctachq DESC
                                                                       BY crapfdc.nrseqems DESC 
                                                                       BY crapfdc.nrcheque DESC:

                    RUN gera-tt-cheque ( INPUT par_nrtipoop,
                                         INPUT par_cdcooper,
                                         INPUT aux_lscontas,
                                         INPUT par_nrregist,
                                         INPUT par_nriniseq,
                                         INPUT-OUTPUT aux_nrregist,
                                         INPUT-OUTPUT aux_qtregist,
                                         INPUT-OUTPUT TABLE tt-cheques ).
                            END.
                    END.

                    WHEN 3 THEN DO:
                            FOR EACH crapfdc WHERE crapfdc.cdcooper = par_cdcooper AND 
                                                                       crapfdc.nrdconta = par_nrdconta AND
                                                                       crapfdc.dtemschq = ? 
                                                                       USE-INDEX crapfdc2 NO-LOCK
                                                                       BY crapfdc.nrctachq DESC
                                                                       BY crapfdc.nrseqems DESC 
                                                                       BY crapfdc.nrcheque DESC:

                    RUN gera-tt-cheque ( INPUT par_nrtipoop,
                                         INPUT par_cdcooper,
                                         INPUT aux_lscontas,
                                         INPUT par_nrregist,
                                         INPUT par_nriniseq,
                                         INPUT-OUTPUT aux_nrregist,
                                         INPUT-OUTPUT aux_qtregist,
                                         INPUT-OUTPUT TABLE tt-cheques ).
                            END.
                    END.

                    WHEN 4 THEN DO:
                            FOR EACH crapfdc WHERE crapfdc.cdcooper = par_cdcooper AND 
                                                                       crapfdc.nrdconta = par_nrdconta AND
                                                                       crapfdc.dtliqchq <> ?           AND 
                                                                       crapfdc.incheque =  5
                                                                       USE-INDEX crapfdc2 NO-LOCK
                                                                       BY crapfdc.nrctachq DESC
                                                                       BY crapfdc.nrseqems DESC 
                                                                       BY crapfdc.nrcheque DESC:

                    RUN gera-tt-cheque ( INPUT par_nrtipoop,
                                         INPUT par_cdcooper,
                                         INPUT aux_lscontas,
                                         INPUT par_nrregist,
                                         INPUT par_nriniseq,
                                         INPUT-OUTPUT aux_nrregist,
                                         INPUT-OUTPUT aux_qtregist,
                                         INPUT-OUTPUT TABLE tt-cheques ).
                            END.                      
                    END.
                    
                    WHEN 5 THEN DO:
                            IF  par_nrcheque = 0 THEN
                                    DO:
                                            FOR EACH crapfdc 
                            WHERE crapfdc.cdcooper = par_cdcooper AND
                                                              crapfdc.nrdconta = par_nrdconta 
                                                              NO-LOCK
                                                              BY crapfdc.nrctachq DESC
                                                              BY crapfdc.nrseqems DESC 
                                                              BY crapfdc.nrcheque DESC:

                            RUN gera-tt-cheque 
                                ( INPUT par_nrtipoop,
                                  INPUT par_cdcooper,
                                  INPUT aux_lscontas,
                                  INPUT par_nrregist,
                                  INPUT par_nriniseq,
                                  INPUT-OUTPUT aux_nrregist,
                                  INPUT-OUTPUT aux_qtregist,
                                  INPUT-OUTPUT TABLE tt-cheques ).
                        END.
                                    END.
                            ELSE
                                    DO:
                                            FOR EACH crapfdc 
                            WHERE crapfdc.cdcooper =  par_cdcooper AND
                                                              crapfdc.nrdconta =  par_nrdconta AND
                                                              crapfdc.nrcheque >= par_nrcheque
                                                              NO-LOCK 
                                                              BY crapfdc.nrcheque:

                             RUN gera-tt-cheque 
                                 ( INPUT par_nrtipoop,
                                   INPUT par_cdcooper,
                                   INPUT aux_lscontas,
                                   INPUT par_nrregist,
                                   INPUT par_nriniseq,
                                   INPUT-OUTPUT aux_nrregist,
                                   INPUT-OUTPUT aux_qtregist,
                                   INPUT-OUTPUT TABLE tt-cheques ).
                                            END.
                                    END.
                    END.
            
        END CASE.

        LEAVE Busca.

    END.

    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
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

    RETURN "OK".

END PROCEDURE.


/*............................ PROCEDURES INTERNAS ...........................*/

PROCEDURE gera-tt-cheque:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/
    
    DEF  INPUT PARAM par_nrtipoop AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_lscontas AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.

    DEF INPUT-OUTPUT PARAM aux_nrregist AS INTE                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_qtregist AS INTE                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-cheques.

    DEF VAR aux_nrchqcdv AS INTE                                    NO-UNDO.
    DEF VAR aux_dsdocmc7 AS CHAR                                    NO-UNDO.

    DEF BUFFER crabfdc FOR crapfdc.

    ASSIGN par_qtregist = par_qtregist + 1.

    /* controles da paginação */
    IF  (par_qtregist < par_nriniseq) OR
        (par_qtregist > (par_nriniseq + par_nrregist)) THEN
        NEXT.

    IF  aux_nrregist > 0 THEN
        DO:
            CREATE tt-cheques.
            ASSIGN tt-cheques.nrcheque = INT(STRING(crapfdc.nrcheque) + 
                                             STRING(crapfdc.nrdigchq))
                   tt-cheques.cdbanchq = crapfdc.cdbanchq
                   tt-cheques.nrseqems = crapfdc.nrseqems
                   tt-cheques.tpforchq = crapfdc.tpforchq
                   tt-cheques.nrdctitg = crapfdc.nrdctitg
                   tt-cheques.nrpedido = crapfdc.nrpedido
                   tt-cheques.vlcheque = crapfdc.vlcheque
                   tt-cheques.cdtpdchq = crapfdc.cdtpdchq
                   tt-cheques.cdbandep = crapfdc.cdbandep
                   tt-cheques.cdagedep = crapfdc.cdagedep
                   tt-cheques.nrctadep = crapfdc.nrctadep
                   tt-cheques.nrdigchq = crapfdc.nrdigchq
                   tt-cheques.cdbantic = crapfdc.cdbantic
                   tt-cheques.cdagetic = crapfdc.cdagetic
                   tt-cheques.nrctatic = crapfdc.nrctatic
                   tt-cheques.dtlibtic = crapfdc.dtlibtic
                   tt-cheques.cdageaco = crapfdc.cdageaco
                   tt-cheques.cdagechq = crapfdc.cdagechq. 
               
            IF  crapfdc.tpcheque = 1  THEN
                ASSIGN tt-cheques.tpcheque = "  ".
            ELSE
            IF  crapfdc.tpcheque = 2   THEN
                ASSIGN tt-cheques.tpcheque = "TB".
            ELSE
            IF  crapfdc.tpcheque = 3   THEN
                ASSIGN tt-cheques.tpcheque = "CS".
            ELSE
                ASSIGN tt-cheques.tpcheque = "  ".
            
            IF  crapfdc.incheque = 1   OR
                crapfdc.incheque = 2   THEN
                DO:
                   ASSIGN tt-cheques.dsobserv = "Contra-Ordem".
                END.
            ELSE
            IF  crapfdc.incheque = 8   THEN
                ASSIGN tt-cheques.dsobserv = "Cancelado".
            
            IF  crapfdc.dtemschq = ?   THEN
                DO:
                    FIND FIRST crapped WHERE 
                               crapped.cdcooper = par_cdcooper AND
                               crapped.nrpedido = crapfdc.nrpedido
                               NO-LOCK NO-ERROR.
                                             
                    IF  AVAILABLE crapped  THEN
                        ASSIGN tt-cheques.dsobserv = 
                                    "Ped. " + STRING(crapfdc.nrpedido,"zz,zz9")
                               tt-cheques.dtemschq = crapped.dtsolped.
                END.
            ELSE 
                ASSIGN tt-cheques.dtemschq = crapfdc.dtemschq.
         
            IF  crapfdc.dtretchq = 01/01/0001   THEN
                ASSIGN tt-cheques.dtretchq = ?.
            ELSE
                ASSIGN tt-cheques.dtretchq = crapfdc.dtretchq.
         
            IF  crapfdc.dtliqchq = 01/01/0001   THEN
                ASSIGN tt-cheques.dtliqchq = ?.
            ELSE 
                ASSIGN tt-cheques.dtliqchq = crapfdc.dtliqchq.
         
            IF  CAN-DO(par_lscontas,STRING(crapfdc.nrdctabb))   AND
                crapfdc.dtliqchq = ?                            AND
                crapfdc.incheque = 0                            THEN
                ASSIGN tt-cheques.dsobserv = "Recolher".
                
            IF  par_nrtipoop = 1   THEN                               /*  Em uso  */
                FIND LAST crabfdc WHERE 
                          crabfdc.cdcooper = crapfdc.cdcooper   AND
                          crabfdc.cdbanchq = crapfdc.cdbanchq   AND
                          crabfdc.cdagechq = crapfdc.cdagechq   AND
                          crabfdc.nrctachq = crapfdc.nrctachq   AND
                          crabfdc.nrcheque < crapfdc.nrcheque   AND
                          crabfdc.dtemschq <> ?                 AND
                          crabfdc.dtretchq <> ?                 AND
                          crabfdc.dtliqchq = ?
                          USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
            ELSE
            IF  par_nrtipoop = 2   THEN                         /*  Arquivo  */
                FIND LAST crabfdc WHERE 
                          crabfdc.cdcooper = crapfdc.cdcooper   AND
                          crabfdc.cdbanchq = crapfdc.cdbanchq   AND
                          crabfdc.cdagechq = crapfdc.cdagechq   AND
                          crabfdc.nrctachq = crapfdc.nrctachq   AND
                          crabfdc.nrcheque < crapfdc.nrcheque   AND
                          crabfdc.dtemschq <> ?                 AND
                          crabfdc.dtretchq = ?
                          USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
            ELSE
            IF  par_nrtipoop = 3   THEN                       /*  Solicitados  */
                FIND LAST crabfdc WHERE 
                          crabfdc.cdcooper = crapfdc.cdcooper   AND
                          crabfdc.cdbanchq = crapfdc.cdbanchq   AND
                          crabfdc.cdagechq = crapfdc.cdagechq   AND
                          crabfdc.nrctachq = crapfdc.nrctachq   AND
                          crabfdc.nrcheque < crapfdc.nrcheque   AND
                          crabfdc.dtemschq = ?                  AND
                          crabfdc.dtretchq = ?
                          USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
            ELSE              
            IF  par_nrtipoop = 4   THEN                      /*  Compensados  */
                FIND LAST crabfdc WHERE 
                          crabfdc.cdcooper = crapfdc.cdcooper   AND
                          crabfdc.cdbanchq = crapfdc.cdbanchq   AND
                          crabfdc.cdagechq = crapfdc.cdagechq   AND
                          crabfdc.nrctachq = crapfdc.nrctachq   AND
                          crabfdc.nrcheque < crapfdc.nrcheque   AND
                          crabfdc.dtemschq <> ?                 AND
                          crabfdc.dtretchq <> ?                 AND
                          crabfdc.dtliqchq <> ?
                          USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
            ELSE               
            IF  par_nrtipoop = 5  THEN                           /*  Todos  */
                FIND LAST crabfdc WHERE 
                          crabfdc.cdcooper = crapfdc.cdcooper   AND
                          crabfdc.cdbanchq = crapfdc.cdbanchq   AND
                          crabfdc.cdagechq = crapfdc.cdagechq   AND
                          crabfdc.nrctachq = crapfdc.nrctachq   AND
                          crabfdc.nrcheque < crapfdc.nrcheque   
                          USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
        
            IF  AVAIL crabfdc  THEN 
                DO:
                                            
                    IF  crabfdc.nrseqems <> crapfdc.nrseqems THEN
                        DO:
                            ASSIGN tt-cheques.flgsubtd = YES.
                        END.
                END.
            ELSE
                ASSIGN tt-cheques.flgsubtd = NO.


            ASSIGN tt-cheques.dscordem = "SEM CONTRA-ORDEM"
                   tt-cheques.dtmvtolt = ""
                   aux_nrchqcdv = INT(STRING(crapfdc.nrcheque) + 
                                      STRING(crapfdc.nrdigchq)).
            
            FIND FIRST crapped WHERE crapped.cdcooper = par_cdcooper       AND
                                     crapped.nrpedido = crapfdc.nrpedido 
                                     NO-LOCK NO-ERROR.
                
            IF  crapfdc.incheque = 1  OR
                crapfdc.incheque = 2  OR
                crapfdc.incheque = 6  OR
                crapfdc.incheque = 7  THEN
                DO: 
                    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper.

                    FIND crapcor WHERE crapcor.cdcooper = par_cdcooper       AND
                                       crapcor.cdbanchq = crapfdc.cdbanchq   AND
                                       crapcor.cdagechq = crapfdc.cdagechq   AND
                                       crapcor.nrctachq = crapfdc.nrctachq   AND
                                       crapcor.nrcheque = aux_nrchqcdv       AND
                                       crapcor.flgativo = TRUE
                                       USE-INDEX crapcor1 NO-LOCK NO-ERROR.
                
                    IF  AVAILABLE crapcor   THEN
                        DO:
                            FIND craphis WHERE 
                                 craphis.cdcooper = par_cdcooper     AND
                                 craphis.cdhistor = crapcor.cdhistor 
                                 NO-LOCK NO-ERROR.
    
                            ASSIGN tt-cheques.dtmvtolt = 
                                   IF  crapcor.dtmvtolt <> ?  THEN
                                       "Inclusao: " +
                                       STRING(crapcor.dtmvtolt,"99/99/9999") +
                                       " - Cod. Operador: " + 
                                       STRING(crapcor.cdoperad)
                                   ELSE
                                       "                     - " +  
                                       "Cod. Operador: " +
                                       STRING(crapcor.cdoperad)
                                   tt-cheques.dscordem = 
                                       "Emissao : " +
                                       STRING(crapcor.dtemscor,"99/99/9999") 
                                       + " - " + STRING(crapcor.cdhistor) 
                                       + " - " +
                                      (IF  AVAILABLE craphis  THEN
                                           STRING(craphis.dshistor,"x(24)")
                                       ELSE 
                                           " ") + " Validade: " +
                                      (IF   crapcor.dtvalcor = ? THEN
                                            " Indeterminado" 
                                       ELSE 
                                       STRING(crapcor.dtvalcor,"99/99/9999")).
                        END.
                END.

            ASSIGN tt-cheques.vldacpmf = 
                                DECIMAL(TRUNCATE(crapfdc.vlcheque * 0.0038,2)).
            
            IF  AVAILABLE crapped  THEN
                ASSIGN tt-cheques.dtsolped = crapped.dtsolped 
                       tt-cheques.dtrecped = crapped.dtrecped.

            IF  crapfdc.dsdocmc7 = ""   THEN
                IF  crapfdc.dtemschq > 01/01/2005  THEN
                    DO:
                        RUN calc_cmc7_difcompe ( INPUT crapfdc.cdbanchq,
                                                 INPUT crapfdc.cdcmpchq,
                                                 INPUT crapfdc.cdagechq,
                                                 INPUT crapfdc.nrdctabb,
                                                 INPUT crapfdc.nrcheque,
                                                 INPUT crapfdc.tpcheque,
                                                OUTPUT aux_dsdocmc7 ).

                        ASSIGN tt-cheques.dsdocmc7 = aux_dsdocmc7.
                    END.
                ELSE
                    ASSIGN tt-cheques.dsdocmc7 = "NAO DISPONIVEL". 
            ELSE
                ASSIGN tt-cheques.dsdocmc7 = crapfdc.dsdocmc7.

            IF  LENGTH(tt-cheques.dscordem) > 53  THEN 
                ASSIGN tt-cheques.dscorde1 = SUBSTR(tt-cheques.dscordem,55,50).
    END.

    ASSIGN aux_nrregist = aux_nrregist - 1.

END PROCEDURE.

/* .......................................................................... */
/*         Calcular o CMC-7 do cheque (baseado em calc_cmc7_difcompe)         */
/* .......................................................................... */
PROCEDURE calc_cmc7_difcompe:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/

    DEF  INPUT PARAM par_cdbanchq AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdcmpchq AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdagechq AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrctachq AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrcheque AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_tpcheque AS INTE                             NO-UNDO.
    DEF OUTPUT PARAM par_dsdocmc7 AS CHAR                             NO-UNDO.

    DEF VAR aux_nrcampo1 AS INTE                                      NO-UNDO.
    DEF VAR aux_nrcampo2 AS DECI                                      NO-UNDO.
    DEF VAR aux_nrcampo3 AS DECI                                      NO-UNDO.
    DEF VAR aux_dsdocmc7 AS CHAR                                      NO-UNDO.
    DEF VAR aux_nrcalcul AS DECI                                      NO-UNDO.
    DEF VAR aux_nrdigito AS INTE                                      NO-UNDO.
    DEF VAR aux_digtpchq AS CHAR                                      NO-UNDO.
    DEF VAR aux_stsnrcal AS LOGI                                      NO-UNDO.
    DEF VAR aux_grpsetec AS INTE                                      NO-UNDO.
    DEF VAR aux_dscmpchq AS CHAR FORMAT "x(04)"                       NO-UNDO.

    DEF VAR h-b1wgen9998 AS HANDLE                                    NO-UNDO.

    IF   par_tpcheque = 2   THEN
         aux_digtpchq = "9".    /* Cheque TB */
    ELSE
         aux_digtpchq = "5".

    IF   par_cdbanchq = 1 THEN  /* Banco do Brasil */
         aux_grpsetec = 7.
    ELSE     
         aux_grpsetec = 0.

    ASSIGN aux_dscmpchq = "<" + STRING(par_cdcmpchq,"999").

    aux_dsdocmc7 = "<" + STRING(par_cdbanchq,"999") + STRING(par_cdagechq,"9999") + 
                   "0" + aux_dscmpchq + STRING(par_nrcheque,"999999") +
                   aux_digtpchq + ">0" + STRING(aux_grpsetec,"9") + "0" + 
                   STRING(par_nrctachq,"99999999") + "0:".

    ASSIGN aux_nrcampo1 = INT(SUBSTRING(aux_dsdocmc7,2,8))
           aux_nrcampo2 = DECIMAL(SUBSTRING(aux_dsdocmc7,11,10))
           aux_nrcampo3 = DECIMAL(SUBSTRING(aux_dsdocmc7,22,12)).

    IF NOT VALID-HANDLE(h-b1wgen9998) THEN
        RUN sistema/generico/procedures/b1wgen9998.p
            PERSISTENT SET h-b1wgen9998.

    DO WHILE TRUE:

       /*  Calcula o digito do terceiro campo  - DV 1  */

       aux_nrcalcul = aux_nrcampo1.

       RUN digm10 IN h-b1wgen9998 ( INPUT-OUTPUT aux_nrcalcul,
                                    OUTPUT aux_nrdigito,
                                    OUTPUT aux_stsnrcal ).

       aux_nrcampo1 = aux_nrcalcul.

       /*  Calcula o digito do primeiro campo  - DV 2  */

       aux_nrcalcul = aux_nrcampo2 * 10.

       RUN digm10 IN h-b1wgen9998 ( INPUT-OUTPUT aux_nrcalcul,
                                    OUTPUT aux_nrdigito,
                                    OUTPUT aux_stsnrcal).

       aux_nrcampo2 = aux_nrcalcul.

       /*  Calcula digito DV 3  */

       aux_nrcalcul = DECIMAL(SUBSTRING(STRING(aux_nrcampo3,"999999999999"),2,11)).

       RUN digm10 IN h-b1wgen9998 ( INPUT-OUTPUT aux_nrcalcul,
                                    OUTPUT aux_nrdigito,
                                    OUTPUT aux_stsnrcal ).

       aux_nrcampo3 = aux_nrcalcul.

       LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    IF VALID-HANDLE(h-b1wgen9998) THEN
        DELETE PROCEDURE h-b1wgen9998.

    par_dsdocmc7 = "<" + 
                   SUBSTRING(STRING(aux_nrcampo1,"99999999"),1,7) +
                   SUBSTRING(STRING(aux_nrcampo2,"99999999999"),11,1) +
                   "<" + 
                   SUBSTRING(STRING(aux_nrcampo2,"99999999999"),1,10) +
                   ">" + 

                   SUBSTRING(STRING(aux_nrcampo1,"999999999"),9,1) +
                   SUBSTRING(STRING(aux_nrcampo3,"999999999999"),2,11) + ":".

    /* .......................................................................... */


END PROCEDURE.


PROCEDURE cria-registro-cheque:

    DEF  INPUT PARAM par_dtiniper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgpagin AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dssitchq AS CHAR                           NO-UNDO.

    DEF INPUT-OUTPUT PARAM par_qtcheque AS INTE                     NO-UNDO.

    IF  par_dssitchq = "NAO COMPENSADO"  THEN
        DO:
            IF  crapfdc.dtretchq <> 01/01/0001   AND
               (crapfdc.dtretchq < par_dtiniper  OR
                crapfdc.dtretchq > par_dtfimper) THEN
                RETURN.
        END.       
    ELSE
        DO:
            IF  crapfdc.dtliqchq <> 01/01/0001   AND
               (crapfdc.dtliqchq < par_dtiniper  OR
                crapfdc.dtliqchq > par_dtfimper) THEN
                RETURN.
        END.

    ASSIGN par_qtcheque = par_qtcheque + 1.
        
    /** Cadastrar somente os registros da paginacao selecionada **/
    IF  par_flgpagin  THEN 
        IF  par_qtcheque < par_nriniseq                    OR
            par_qtcheque >= (par_nriniseq + par_nrregist)  THEN
            RETURN.

    CREATE tt-consulta-cheque.
    ASSIGN tt-consulta-cheque.nrcheque = crapfdc.nrcheque
           tt-consulta-cheque.nrdigchq = crapfdc.nrdigchq
           tt-consulta-cheque.nrdctabb = crapfdc.nrdctabb
           tt-consulta-cheque.vlcheque = crapfdc.vlcheque
           tt-consulta-cheque.dtretchq = crapfdc.dtretchq
           tt-consulta-cheque.dtliqchq = crapfdc.dtliqchq
           tt-consulta-cheque.dssitchq = par_dssitchq.
    
END PROCEDURE.

PROCEDURE consulta-cheque-compensado:

    DEF  INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF  INPUT-OUTPUT PARAM par_cdcmpchq AS INTE NO-UNDO.
    DEF  INPUT PARAM par_cdbanchq AS INTE NO-UNDO.
    DEF  INPUT-OUTPUT PARAM par_cdagechq AS INTE NO-UNDO.
    DEF  INPUT PARAM par_nrctachq AS DECI NO-UNDO.
    DEF  INPUT PARAM par_nrcheque AS INTE NO-UNDO.
    DEF  INPUT PARAM par_tpremess AS CHAR NO-UNDO.
    
    DEF OUTPUT PARAM par_dsdocmc7 AS CHAR NO-UNDO.
    DEF OUTPUT PARAM par_nmrescop AS CHAR NO-UNDO.
    DEF OUTPUT PARAM par_cdtpddoc AS INTE NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.


    DEF VAR aux_cdagectl LIKE crapcop.cdagectl NO-UNDO.
    DEF VAR aux_cdagemig LIKE crapcop.cdagectl NO-UNDO.

    DEF BUFFER crabcop FOR crapcop.

    ASSIGN par_dsdocmc7 = ""
           par_cdtpddoc = 0.


    FIND FIRST crapcop
         WHERE crapcop.cdcooper = par_cdcooper
       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    ASSIGN par_nmrescop = UPPER(crapcop.nmrescop).

    ASSIGN aux_cdagectl =  crapcop.cdagectl.

    IF (par_tpremess = "N" AND
        par_cdbanchq = 85  AND 
        par_cdagechq = aux_cdagectl)
    OR (par_tpremess = "S") THEN DO:

        FIND FIRST crapfdc
             WHERE crapfdc.cdcooper = par_cdcooper
               AND crapfdc.cdbanchq = par_cdbanchq
               AND crapfdc.cdagechq = par_cdagechq
               AND crapfdc.nrctachq = par_nrctachq
               AND crapfdc.nrcheque = par_nrcheque
           NO-LOCK NO-ERROR.

        IF  AVAIL crapfdc THEN DO:

            ASSIGN par_dsdocmc7 = crapfdc.dsdocmc7
                   par_cdcmpchq = crapfdc.cdcmpchq
                   par_cdtpddoc = crapfdc.cdtpdchq.
        END.
    END.
    ELSE /* nossa remessa */
    DO:
        FIND crapchd WHERE crapchd.cdcooper = par_cdcooper   AND
                           crapchd.dtmvtolt = par_dtmvtolt   AND
                           crapchd.cdcmpchq = par_cdcmpchq   AND
                           crapchd.cdbanchq = par_cdbanchq   AND
                           crapchd.cdagechq = par_cdagechq   AND
                           crapchd.nrctachq = par_nrctachq   AND
                           crapchd.nrcheque = par_nrcheque   NO-LOCK NO-ERROR.

        IF AVAIL crapchd THEN
           ASSIGN par_dsdocmc7 = crapchd.dsdocmc7
                  par_cdagechq = crapcop.cdagectl.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE grava-log:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_dttransa AS DATE NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dstransa AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdprogra AS CHAR NO-UNDO.

    CREATE craplgm.
    ASSIGN craplgm.cdcooper = par_cdcooper
           craplgm.dttransa = par_dttransa
           craplgm.hrtransa = TIME
           craplgm.cdoperad = par_cdoperad
           craplgm.dstransa = par_dstransa
           craplgm.nrdconta = par_nrdconta
           craplgm.nmdatela = par_cdprogra
           craplgm.idseqttl = 1
           craplgm.nrsequen = 1
           craplgm.dsorigem = "INTERNET"
           craplgm.flgtrans = TRUE.
    VALIDATE craplgm.

END PROCEDURE.


/*............................................................................*/

