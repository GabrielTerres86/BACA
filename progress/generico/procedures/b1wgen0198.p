/*.............................................................................

    Programa: b1wgen0198.p
    Autor   : Odirlei Busana - AMcom
    Data    : Outubro/2017                   Ultima atualizacao: 

    Objetivo  : Rotinas da tela CADCTA

    Alteracoes: 
.............................................................................*/


/*................................. DEFINICOES ..............................*/


{ sistema/generico/includes/var_internet.i}
{ sistema/generico/includes/gera_log.i}
{ sistema/generico/includes/gera_erro.i}
{ sistema/generico/includes/b1wgen0198tt.i}
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-BO=SIM }
{ sistema/generico/includes/b1wgen0075tt.i &TT-LOG=SIM }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_retorno  AS CHAR                                        NO-UNDO.
DEF VAR aux_contador AS INTE                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.


/*................................. PROCEDURES ..............................*/

PROCEDURE valida_dados:
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdbcochq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdconsul AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagedbb AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctitg AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrctacns AS DEC                            NO-UNDO.
    DEF  INPUT PARAM par_incadpos AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgiddep AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgrestr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_indserma AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inlbacen AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmtalttl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_qtfoltal AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdempres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrinfcad AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrpatlvr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsinfadi AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmctajur AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.      
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
        

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Valida dados da cadcta "
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_retorno  = "NOK".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.
        
        
        FIND  crapass 
        WHERE crapass.cdcooper = par_cdcooper 
          AND crapass.nrdconta = par_nrdconta 
          NO-LOCK NO-ERROR.
          
        IF  NOT AVAILABLE crapass THEN
        DO:
            ASSIGN aux_dscritic = "Dados do associado nao foram" +
                                  " encontrados(1).".
            UNDO Valida, LEAVE Valida.
        END.   
        

		    /* Nome Fantasia */
        IF  par_nmctajur = "" AND crapass.inpessoa <> 1 THEN
            DO:
                ASSIGN aux_dscritic = "Nome da Conta deve ser informado." .
                ASSIGN par_nmdcampo = "nmctajur".
                LEAVE Valida.
            END.
    END.
    
    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN 
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    ELSE
        ASSIGN aux_retorno = "OK".

    IF  aux_retorno <> "OK" THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT NO,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).

    RETURN aux_retorno.
END.


PROCEDURE Grava_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdbcochq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdconsul AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagedbb AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctitg AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrctacns AS DEC                            NO-UNDO.
    DEF  INPUT PARAM par_incadpos AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgiddep AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgrestr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_indserma AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inlbacen AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmtalttl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_qtfoltal AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdempres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrinfcad AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrpatlvr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsinfadi AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmctajur AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_msgrvcad AS CHAR                           NO-UNDO.    
    DEF OUTPUT PARAM par_cotcance AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.      
    
    
    DEF VAR h-b1wgen0077 AS HANDLE                                  NO-UNDO.
    
    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = (IF par_cddopcao = "E" THEN "Exclui" 
                        ELSE IF par_cddopcao = "I" THEN
                             "Inclui" ELSE "Altera") + 
                       " dados CADCTA"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:
        
        
        FIND  crapass 
        WHERE crapass.cdcooper = par_cdcooper 
          AND crapass.nrdconta = par_nrdconta 
          NO-LOCK NO-ERROR.
          
        IF  NOT AVAILABLE crapass THEN
        DO:
            ASSIGN aux_dscritic = "Dados do Titular nao foram" +
                                  " encontrados(1).".
            UNDO Grava, LEAVE Grava.
        END.   
        
        IF  crapass.inpessoa = 1 THEN
        DO:
          FIND FIRST crapttl 
               WHERE crapttl.cdcooper = par_cdcooper
                 AND crapttl.nrdconta = par_nrdconta
                 AND crapttl.idseqttl = 1
                 NO-LOCK NO-ERROR.

          IF  NOT AVAILABLE crapttl THEN
          DO:
              ASSIGN aux_dscritic = "Dados do Titular nao foram" +
                                    " encontrados(2).".
              UNDO Grava, LEAVE Grava.
          END.
        END.
        ELSE 
        DO:
          FIND FIRST crapjur
               WHERE crapjur.cdcooper = par_cdcooper
                 AND crapjur.nrdconta = par_nrdconta                 
                 NO-LOCK NO-ERROR.

          IF  NOT AVAILABLE crapjur THEN
          DO:
              ASSIGN aux_dscritic = "Dados da pessao juridica nao foram" +
                                    " encontrados(3).".
              UNDO Grava, LEAVE Grava.
          END.
        END.
        
        CREATE tt-dados-ant.
        ASSIGN tt-dados-ant.cdbcochq = crapass.cdbcochq.
               tt-dados-ant.cdconsul = crapass.cdconsul.                          
               tt-dados-ant.nrdctitg = crapass.nrdctitg.                      
               tt-dados-ant.nrctacns = crapass.nrctacns.
               tt-dados-ant.incadpos = crapass.incadpos.               
               tt-dados-ant.flgiddep = crapass.flgiddep.                
               tt-dados-ant.flgrestr = crapass.flgrestr.       
               tt-dados-ant.indserma = crapass.indserma.
               tt-dados-ant.inlbacen = crapass.inlbacen.                        
               tt-dados-ant.qtfoltal = crapass.qtfoltal.      
               
        IF AVAILABLE crapttl THEN       
        DO:
            tt-dados-ant.cdempres = crapttl.cdempres.     
            tt-dados-ant.nrinfcad = crapttl.nrinfcad.    
            tt-dados-ant.nrpatlvr = crapttl.nrpatlvr.  
            tt-dados-ant.dsinfadi = crapttl.dsinfadi.  
            tt-dados-ant.nmtalttl = crapttl.nmtalttl.       
        
        END.

        IF AVAILABLE crapjur THEN       
        DO:
            tt-dados-ant.nmctajur = crapjur.nmctajur.               
        END.

        IF  par_flgerlog  THEN 
            DO:
                { sistema/generico/includes/b1wgenalog.i }
            END.
        
        /* Chamada rotina ORACLE */
        
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
          
          RUN STORED-PROCEDURE pc_atualiza_dados_cadcta
            aux_handproc = PROC-HANDLE NO-ERROR (  INPUT par_cdcooper  /* pr_cdcooper */
                                                  ,INPUT par_cdagenci  /* pr_cdagenci */
                                                  ,INPUT par_nrdcaixa  /* pr_nrdcaixa */
                                                  ,INPUT par_cdoperad  /* pr_cdoperad */
                                                  ,INPUT par_nmdatela  /* pr_nmdatela */
                                                  ,INPUT par_idorigem  /* pr_idorigem */
                                                  ,INPUT par_nrdconta  /* pr_nrdconta */
                                                  ,INPUT par_idseqttl  /* pr_idseqttl */
                                                  ,INPUT par_cdbcochq  /* pr_cdbcochq */
                                                  ,INPUT par_cdconsul  /* pr_cdconsul */
                                                  ,INPUT par_cdagedbb  /* pr_cdagedbb */
                                                  ,INPUT par_nrdctitg  /* pr_nrdctitg */
                                                  ,INPUT par_nrctacns  /* pr_nrctacns */
                                                  ,INPUT par_incadpos  /* pr_incadpos */
                                                  ,INPUT par_flgiddep  /* pr_flgiddep */
                                                  ,INPUT par_flgrestr  /* pr_flgrestr */
                                                  ,INPUT par_indserma  /* pr_indserma */
                                                  ,INPUT par_inlbacen  /* pr_inlbacen */
                                                  ,INPUT par_nmtalttl  /* pr_nmtalttl */
                                                  ,INPUT par_qtfoltal  /* pr_qtfoltal */
                                                  ,INPUT par_cdempres  /* pr_cdempres */
                                                  ,INPUT par_nrinfcad  /* pr_nrinfcad */
                                                  ,INPUT par_nrpatlvr  /* pr_nrpatlvr */
                                                  ,INPUT par_dsinfadi  /* pr_dsinfadi */
                                                  ,INPUT par_nmctajur  /* pr_dsinfadi */ 
                                                  ,OUTPUT 0            /* pr_cdcritic */
                                                  ,OUTPUT "").         /* pr_dscritic */


          CLOSE STORED-PROC pc_atualiza_dados_cadcta
                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

          ASSIGN aux_cdcritic = 0
                 aux_dscritic = ""
                 aux_cdcritic = pc_atualiza_dados_cadcta.pr_cdcritic 
                                  WHEN pc_atualiza_dados_cadcta.pr_cdcritic <> ?
                 aux_dscritic = pc_atualiza_dados_cadcta.pr_dscritic 
                                  WHEN pc_atualiza_dados_cadcta.pr_dscritic <> ?.
        
        
        FIND  crapass 
        WHERE crapass.cdcooper = par_cdcooper 
          AND crapass.nrdconta = par_nrdconta 
          NO-LOCK NO-ERROR.
          
        IF  NOT AVAILABLE crapass THEN
        DO:
            ASSIGN aux_cdcritic = 9.
            UNDO Grava, LEAVE Grava.
        END. 
        
        IF  crapass.inpessoa = 1 THEN
        DO:
          /* Buscar dados atualizados */
          FIND FIRST crapttl 
               WHERE crapttl.cdcooper = par_cdcooper
                 AND crapttl.nrdconta = par_nrdconta
                 AND crapttl.idseqttl = 1
                 NO-LOCK NO-ERROR.

          IF  NOT AVAILABLE crapttl THEN
          DO:
              ASSIGN aux_dscritic = "Dados do Titular nao foram" +
                                    " encontrados.".
              UNDO Grava, LEAVE Grava.
          END.
        END.
        ELSE 
        DO:
          FIND FIRST crapjur
               WHERE crapjur.cdcooper = par_cdcooper
                 AND crapjur.nrdconta = par_nrdconta                 
                 NO-LOCK NO-ERROR.

          IF  NOT AVAILABLE crapjur THEN
          DO:
              ASSIGN aux_dscritic = "Dados da pessao juridica nao foram" +
                                    " encontrados.".
              UNDO Grava, LEAVE Grava.
          END.
        END.
                
        IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
             RUN sistema/generico/procedures/b1wgen0077.p
                 PERSISTENT SET h-b1wgen0077.

        RUN Revisao_Cadastral IN h-b1wgen0077
           ( INPUT par_cdcooper,
             INPUT crapass.nrcpfcgc,
             INPUT par_nrdconta,
            OUTPUT par_msgrvcad ).

        IF  VALID-HANDLE(h-b1wgen0077) THEN
             DELETE OBJECT h-b1wgen0077.
        
        
        CREATE tt-dados-atl.
        ASSIGN tt-dados-atl.cdbcochq = crapass.cdbcochq
               tt-dados-atl.cdconsul = crapass.cdconsul                        
               /* tt-dados-atl.cdagedbb = crapass.cdagedbb */                     
               tt-dados-atl.nrdctitg = crapass.nrdctitg                        
               tt-dados-atl.nrctacns = crapass.nrctacns
               tt-dados-atl.incadpos = crapass.incadpos                
               tt-dados-atl.flgiddep = crapass.flgiddep                  
               tt-dados-atl.flgrestr = crapass.flgrestr          
               tt-dados-atl.indserma = crapass.indserma
               tt-dados-atl.inlbacen = crapass.inlbacen          
               tt-dados-atl.qtfoltal = crapass.qtfoltal.         
               
        IF AVAILABLE crapttl THEN       
        DO:
            tt-dados-atl.cdempres = crapttl.cdempres.     
            tt-dados-atl.nrinfcad = crapttl.nrinfcad.    
            tt-dados-atl.nrpatlvr = crapttl.nrpatlvr.  
            tt-dados-atl.dsinfadi = crapttl.dsinfadi.  
            tt-dados-atl.nmtalttl = crapttl.nmtalttl.       
        
        END.   
        
        IF AVAILABLE crapjur THEN       
        DO:
            tt-dados-atl.nmctajur = crapjur.nmctajur.               
        END.
        
        IF  par_flgerlog  THEN 
            DO:
                { sistema/generico/includes/b1wgenllog.i }
            END.
        
        ASSIGN aux_retorno = "OK".

        LEAVE Grava.
    END.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_retorno = "NOK".           
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,           
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.   
   
   IF  par_flgerlog THEN
   
       RUN proc_gerar_log_tab
           ( INPUT par_cdcooper,
             INPUT par_cdoperad,
             INPUT aux_dscritic,
             INPUT aux_dsorigem,
             INPUT aux_dstransa,
             INPUT (IF aux_retorno = "OK" THEN TRUE ELSE FALSE),
             INPUT 1,
             INPUT par_nmdatela,
             INPUT par_nrdconta,
             INPUT YES,
             INPUT BUFFER tt-dados-ant:HANDLE,
             INPUT BUFFER tt-dados-atl:HANDLE ).

   
   IF aux_retorno <> 'NOK' AND crapass.inpessoa = 1 THEN
   DO:
     
     /* atualiza empresa do titular */
     RUN atualiza_cdempres ( INPUT par_cdcooper, 
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa, 
                             INPUT par_cdoperad, 
                             INPUT par_nmdatela, 
                             INPUT par_idorigem, 
                             INPUT par_nrdconta, 
                             INPUT par_idseqttl, 
                             INPUT par_flgerlog, 
                             INPUT par_cddopcao, 
                             INPUT par_dtmvtolt,     
                             INPUT par_cdempres,  
                            
                            OUTPUT par_cotcance, 
                            OUTPUT TABLE tt-erro).
     IF RETURN-VALUE = "NOK" THEN
     DO:
         ASSIGN aux_retorno = "NOK".
     END.        
     
   END.
   
   RETURN aux_retorno.

END PROCEDURE.

PROCEDURE atualiza_cdempres:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.    
    DEF  INPUT PARAM par_cdempres AS INTE                           NO-UNDO. 
    
    DEF OUTPUT PARAM par_cotcance AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.      
    
    
    DEF VAR aux_rowidttl AS ROWID                                   NO-UNDO.
    DEF VAR aux_rowidenc AS ROWID                                   NO-UNDO.
    DEF VAR aux_cdseqinc AS INTE                                    NO-UNDO.  
    DEF VAR aux_cdempres AS INTE                                    NO-UNDO.
    DEF VAR aux_flgtroca AS LOG                                     NO-UNDO.
    DEF VAR aux_flgpagto AS LOG                                     NO-UNDO.
        
    DEF BUFFER crabemp  FOR crapemp.
    DEF BUFFER crabpla  FOR crappla.
    DEF BUFFER crabavs  FOR crapavs.
    DEF BUFFER crabepr  FOR crapepr.
    
    
    DEF VAR h-b1wgen0077 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0021 AS HANDLE                                  NO-UNDO.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = (IF par_cddopcao = "E" THEN "Exclui" 
                        ELSE IF par_cddopcao = "I" THEN
                             "Inclui" ELSE "Altera") + 
                       " dados Comerciais"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".
        
    EMPTY TEMP-TABLE tt-comercial-ant.
    EMPTY TEMP-TABLE tt-comercial-atl.    

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        EMPTY TEMP-TABLE tt-erro.   

        /* Dados do Titular */
        ContadorTtl: DO aux_contador = 1 TO 10:

            FIND FIRST crapttl 
                 WHERE crapttl.cdcooper = par_cdcooper
                   AND crapttl.nrdconta = par_nrdconta
                   AND crapttl.idseqttl = par_idseqttl
                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapttl THEN
                DO:
                   IF  LOCKED(crapttl) THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 ASSIGN aux_cdcritic = 341.
                                 LEAVE ContadorTtl.
                              END.
                          ELSE 
                              DO:
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT ContadorTtl.
                              END.
                       END.
                   ELSE
                       DO:
                          ASSIGN aux_dscritic = "Dados do Titular nao foram" +
                                                " encontrados(3).".
                          LEAVE ContadorTtl.
                       END.
                END.
            ELSE
                LEAVE ContadorTtl.
        END.
        
MESSAGE "3-Odirlei " aux_retorno.        
        ASSIGN aux_rowidttl = ROWID(crapttl).
        
        /* apenas executar as operacoes de será 
           foi alterado. */
        IF  par_cdempres = crapttl.cdempres THEN
        DO: 
        MESSAGE "3.1-Odirlei " aux_retorno . 
           aux_retorno = "OK".
           RETURN aux_retorno.        
        END.
        
        CREATE tt-comercial-ant.
        ASSIGN tt-comercial-ant.cdempres = crapttl.cdempres                   
               tt-comercial-ant.nrcpfemp = STRING(crapttl.nrcpfemp).          
               
        /* Guardar valor anterior*/
        ASSIGN aux_cdempres = crapttl.cdempres.
        
        /* Buscar endereco atual */
        FIND LAST crapenc WHERE crapenc.cdcooper = par_cdcooper   AND
                                crapenc.nrdconta = par_nrdconta   AND
                                crapenc.idseqttl = par_idseqttl   AND
                                crapenc.tpendass = 9 /* Comercial */
                                NO-LOCK NO-ERROR.

        IF  AVAILABLE crapenc THEN
            ASSIGN aux_rowidenc = ROWID(crapenc).
        ELSE 
            ASSIGN aux_rowidenc = ?.

        /* Endereco Comercial */
        ContadorEnc: DO aux_contador = 1 TO 10:

            FIND crapenc WHERE ROWID(crapenc) = aux_rowidenc
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapenc THEN
                DO:
                   IF  LOCKED(crapenc) THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 ASSIGN aux_cdcritic = 341.
                                 LEAVE ContadorEnc.
                              END.
                          ELSE 
                              DO:
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT ContadorEnc.
                              END.
                       END.
                   ELSE
                       DO:
                          ASSIGN aux_cdseqinc = 1.
                          /* Pegar o sequencial */
                          FOR LAST crapenc FIELDS(cdseqinc) WHERE 
                                           crapenc.cdcooper = par_cdcooper AND
                                           crapenc.nrdconta = par_nrdconta AND
                                           crapenc.idseqttl = par_idseqttl
                                           NO-LOCK:
                              ASSIGN aux_cdseqinc = crapenc.cdseqinc + 1.
                          END.

                          CREATE crapenc.
                          ASSIGN
                              crapenc.cdcooper = par_cdcooper
                              crapenc.nrdconta = par_nrdconta
                              crapenc.idseqttl = par_idseqttl
                              crapenc.tpendass = 9           
                              crapenc.cdseqinc = aux_cdseqinc NO-ERROR.
                          
                          IF  ERROR-STATUS:ERROR THEN
                              aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).

                          LEAVE ContadorEnc.
                       END.
                END.
            ELSE
                LEAVE ContadorEnc.
        END.
        
        ASSIGN tt-comercial-ant.cepedct1 = crapenc.nrcepend
               tt-comercial-ant.endrect1 = crapenc.dsendere
               tt-comercial-ant.nrendcom = crapenc.nrendere
               tt-comercial-ant.complcom = crapenc.complend
               tt-comercial-ant.bairoct1 = crapenc.nmbairro
               tt-comercial-ant.cidadct1 = crapenc.nmcidade
               tt-comercial-ant.ufresct1 = crapenc.cdufende
               tt-comercial-ant.cxpotct1 = crapenc.nrcxapst.

        VALIDATE tt-comercial-ant.

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.
        
        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta 
                           NO-LOCK NO-ERROR.
        
        IF  par_flgerlog  THEN 
            DO:
                { sistema/generico/includes/b1wgenalog.i }
            END.
        
  MESSAGE "4-Odirlei " aux_retorno.        
        /* buscar dados da nova empresa */
        FOR FIRST crapemp FIELDS(cdcooper nmextemp nrcepend dsendemp nrendemp
                                 dscomple nmbairro nmcidade cdufdemp nrdocnpj
                                 nmresemp cdempres flgpagto flgpgtib)
                          WHERE crapemp.cdcooper = par_cdcooper AND
                                crapemp.cdempres = par_cdempres 
                                NO-LOCK:
        END.                        
      
        ASSIGN crapttl.cdempres = par_cdempres
               crapttl.nrcpfemp = crapemp.nrdocnpj
               crapttl.nmextemp = crapemp.nmextemp.
        
        /* Se for diferente de empresas diversas */       
        IF  crapemp.cdempres <> 81   AND
            NOT(crapemp.cdcooper = 2 AND crapemp.cdempres = 88) THEN
        DO:
        
        MESSAGE "4.1-Odirlei " crapemp.dsendemp.   
           ASSIGN
           crapenc.cdufende = CAPS(crapemp.cdufdemp)
           crapenc.nmbairro = CAPS(crapemp.nmbairro)
           crapenc.nmcidade = CAPS(crapemp.nmcidade)
           crapenc.complend = CAPS(crapemp.dscomple)
           crapenc.dsendere = CAPS(crapemp.dsendemp)
           crapenc.nrcepend = crapemp.nrcepend
           crapenc.nrendere = crapemp.nrendemp NO-ERROR.

           IF  ERROR-STATUS:ERROR THEN
              DO:
                 ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                 UNDO Grava, LEAVE Grava.
              END.
        
        END.
  
        IF par_flgerlog  THEN 
            DO:
                { sistema/generico/includes/b1wgenllog.i }
            END.
        
        /*  Validar alteracao */        
        
       ASSIGN aux_flgtroca = TRUE.
MESSAGE "5-Odirlei " aux_retorno.        
       /* buscar dados da empresa antiga */
       FOR FIRST crabemp FIELDS(flgpagto flgpgtib)
           WHERE crabemp.cdcooper = crapass.cdcooper AND
                 crabemp.cdempres = aux_cdempres NO-LOCK:

           ASSIGN aux_flgpagto = (crabemp.flgpagto OR crabemp.flgpgtib).
       END.

       /* Dados da nova empresa */
       IF  aux_flgpagto AND (NOT crapemp.flgpagto AND NOT crapemp.flgpgtib) THEN
           ASSIGN aux_flgtroca = TRUE.
       ELSE
           ASSIGN aux_flgtroca = FALSE.
   

       RUN sistema/generico/procedures/b1wgen0021.p
           PERSISTENT SET h-b1wgen0021.

       /* atualiza planos de capitalização */
       Plano: FOR EACH crappla 
           WHERE crappla.cdcooper = crapass.cdcooper AND
                 crappla.nrdconta = crapass.nrdconta
                 USE-INDEX crappla1 NO-LOCK:

           ContadorPla: DO aux_contador = 1 TO 10:

              FIND crabpla WHERE
                  ROWID(crabpla) = ROWID(crappla) 
                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

              IF  NOT AVAILABLE crabpla THEN
                  DO:
                     IF  LOCKED(crabpla) THEN
                         DO:
                            IF  aux_contador = 10 THEN
                                DO:
                                   aux_cdcritic = 341.
                                   LEAVE ContadorPla.
                                END.
                            ELSE 
                                DO:
                                   PAUSE 1 NO-MESSAGE.
                                   NEXT ContadorPla.
                                END.
                         END.
                     ELSE
                         LEAVE ContadorPla.
                  END.
              ELSE 
                  DO:
                     IF  crabpla.cdsitpla = 1  AND 
                         aux_flgtroca          AND
                         crabpla.flgpagto     THEN
                     DO:
                         IF crabpla.dtinipla = 
                            par_dtmvtolt THEN
                         DO:
                             RUN exclui-plano IN
                             h-b1wgen0021 (
                                    INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT par_cdoperad,
                                    INPUT par_nmdatela,
                                    INPUT par_idorigem,
                                    INPUT par_nrdconta,
                                    INPUT par_idseqttl,
                                   OUTPUT TABLE tt-erro).

                             IF RETURN-VALUE = "NOK" THEN
                             DO:
                                 ASSIGN aux_retorno = "NOK".

                                 UNDO Grava, LEAVE Grava.
                             END.
                         END.
                         ELSE
                             ASSIGN crabpla.cdsitpla = 2
                                    crabpla.dtcancel = 
                                            par_dtmvtolt
                                    crabpla.cdempres = 
                                         crapttl.cdempres.

                         ASSIGN par_cotcance = "Plano de"
                         + " Cotas com vinculo em Folha "
                         + "cancelado - Efetue novo Plano.".
                     END.

                     LEAVE ContadorPla.
                  END.
           END. /* ContadorPla */
           
           IF  aux_dscritic <> ""  OR 
               aux_cdcritic <> 0   THEN
               UNDO Grava, LEAVE Grava.

           RELEASE crabpla.
       END.  /*  Fim do FOR EACH crappla */
MESSAGE "6-Odirlei " aux_retorno.        
       /*Altera empresa dos debitos automaticos*/
       Aviso: FOR EACH crapavs 
           WHERE crapavs.cdcooper = crapass.cdcooper AND
                 crapavs.tpdaviso = 1                AND
                 crapavs.nrdconta = crapass.nrdconta
                 USE-INDEX crapavs2 NO-LOCK:
           
           ContadorAvs: DO aux_contador = 1 TO 10:

               FIND crabavs WHERE
                   ROWID(crabavs) = ROWID(crapavs) 
                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

               IF  NOT AVAILABLE crabavs THEN
                   DO:
                      IF  LOCKED(crabavs) THEN
                          DO:
                             IF  aux_contador = 10 THEN
                                 DO:
                                    aux_cdcritic = 341.
                                    LEAVE ContadorAvs.
                                 END.
                             ELSE 
                                 DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT ContadorAvs.
                                 END.
                          END.
                      ELSE
                          LEAVE ContadorAvs.
                   END.
               ELSE
                   DO:
                     crabavs.cdempres = crapttl.cdempres.
                     LEAVE ContadorAvs.
                   END.
           END. /* ContadorAvs */

           IF  aux_dscritic <> ""  OR 
               aux_cdcritic <> 0   THEN
               UNDO Grava, LEAVE Grava.

           RELEASE crabavs.
       END. /* Fim do FOR EACH crapavs  */

MESSAGE "7-Odirlei " aux_retorno.        
       /*  Altera a empresa dos emprestimos  */
       Emprestimo: FOR EACH crapepr WHERE 
                         crapepr.cdcooper = crapass.cdcooper AND
                         crapepr.nrdconta = crapass.nrdconta
                         USE-INDEX crapepr2 NO-LOCK:

            ContadorEpr: DO aux_contador = 1 TO 10:

                FIND crabepr WHERE 
                             ROWID(crabepr) = ROWID(crapepr)
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAILABLE crabepr THEN
                    DO:
                       IF  LOCKED(crabepr) THEN
                           DO:
                              IF  aux_contador = 10 THEN
                                  DO:
                                     aux_cdcritic = 341.
                                     LEAVE ContadorEpr.
                                  END.
                              ELSE 
                                  DO:
                                     PAUSE 1 NO-MESSAGE.
                                     NEXT ContadorEpr.
                                  END.
                           END.
                       ELSE
                           LEAVE ContadorEpr.
                    END.
                ELSE
                    DO:
                       ASSIGN 
                           crabepr.cdempres = crapttl.cdempres
                           crabepr.nrcadast = crapttl.nrcadast.

                       LEAVE ContadorEpr.
                    END.
            END. /* ContadorEpr */

            IF  aux_dscritic <> ""  OR 
                aux_cdcritic <> 0   THEN
                UNDO Grava, LEAVE Grava.

            RELEASE crabepr.
       END.  /*  Fim do FOR EACH crapepr */           
       
        /* concluir processo com sucesso */
        ASSIGN aux_retorno = "OK".

        LEAVE Grava.
    END.

    RELEASE crapttl.
MESSAGE "8-Odirlei " aux_retorno.            
    
    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_retorno = "NOK".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,           
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.

   CREATE tt-comercial-atl.
   
   FIND crapttl WHERE ROWID(crapttl) = aux_rowidttl NO-LOCK NO-ERROR NO-WAIT.
   IF AVAIL crapttl THEN
     DO:
       
       ASSIGN tt-comercial-atl.cdempres = crapttl.cdempres          
              tt-comercial-atl.nrcpfemp = STRING(crapttl.nrcpfemp).  
     END.
   
   FIND crapenc WHERE ROWID(crapenc) = aux_rowidenc NO-LOCK NO-ERROR NO-WAIT. 
   IF AVAIL crapenc THEN
     DO:
       ASSIGN tt-comercial-atl.cepedct1 = crapenc.nrcepend
              tt-comercial-atl.endrect1 = crapenc.dsendere
              tt-comercial-atl.nrendcom = crapenc.nrendere
              tt-comercial-atl.complcom = crapenc.complend
              tt-comercial-atl.bairoct1 = crapenc.nmbairro
              tt-comercial-atl.cidadct1 = crapenc.nmcidade
              tt-comercial-atl.ufresct1 = crapenc.cdufende
              tt-comercial-atl.cxpotct1 = crapenc.nrcxapst.
     END.
   
   VALIDATE tt-comercial-atl.
   
   IF  par_flgerlog THEN
       RUN proc_gerar_log_tab
           ( INPUT par_cdcooper,
             INPUT par_cdoperad,
             INPUT aux_dscritic,
             INPUT aux_dsorigem,
             INPUT aux_dstransa,
             INPUT (IF aux_retorno = "OK" THEN TRUE ELSE FALSE),
             INPUT par_idseqttl,
             INPUT par_nmdatela,
             INPUT par_nrdconta,
             INPUT YES,
             INPUT BUFFER tt-comercial-ant:HANDLE,
             INPUT BUFFER tt-comercial-atl:HANDLE ).

   RETURN aux_retorno.
       
END PROCEDURE.






/*................................. FUNCTIONS ................................*/


/*............................................................................*/
