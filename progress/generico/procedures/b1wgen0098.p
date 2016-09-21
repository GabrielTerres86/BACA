/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0098.p
    Autor   : Henrique
    Data    : Maio/2011               Ultima Atualizacao: 24/02/2016
     
    Dados referentes ao programa:
   
    Objetivo  : BO referente a tela ESKECI
                 
    Alteracoes: 22/12/2011 - Corrigida a validacao da senha (Gabriel).
    
                19/01/2012 - Alterado nrsencar para dssencar
                           - Comentado as validacoes na alteracao de senha
                             pois agora na tela atenda é necessário 
                             informar a senha atual na entrega e desbloqueio
                             do cartao magnetico, e quando o cartao esta 
                             bloqueado e a pessoa esqueceu a senha, nao tinha
                             como fazer a entrega (Guilherme).
                             
                 04/11/2013 - Adicionado log de alteracao de senha no cartao.
                              Alterado proc. busca-cartao para restringir
                              acesso apenas operadores "SUPERVISOR" ou 
                              "GERENTE". (Jorge)
                              
                 27/11/2013 - Adicionado verificacao e gravacao de historico da
                              senha do cartao magnetico quando for de operador
                              em proc. verifica-nova-senha e grava-nova-senha.
                              (Jorge).
                              
                 20/02/2014 - Ajuste para realizar verificacao de operador 
                              "GERENTE" ou "SUPERVISOR" em proc. busca-cartao
                              apenas quando tptitcar = 9 (cartao de operador)
                              (Jorge).
                              
                 27/07/2015 - Removido os campos vlsaqmax, insaqmax da 
                              temp-table tt-crapcrm. (James)
                              
                 24/02/2016 - Alteraçao na rotina de alteraçao de senha 
                              (Lucas Lunelli - [PROJ290])                              
.............................................................................*/

{ sistema/generico/includes/b1wgen0098tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.

/*****************************************************************************
  Carregar os dados do cooperado a partir do numero do cartao 
******************************************************************************/
PROCEDURE busca-cartao:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcartao AS DECI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-crapcrm.

    DEF VAR aux_flgerror AS LOGI                                    NO-UNDO.
    DEF VAR aux_dssititg AS CHAR                                    NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgerror = TRUE.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapcrm.

    DO WHILE TRUE:
        
        FIND crapcrm WHERE crapcrm.cdcooper = par_cdcooper AND
                           crapcrm.nrcartao = par_nrcartao NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapcrm  THEN
        DO:
            ASSIGN aux_cdcritic = 546.
            LEAVE.
        END.

        /* comentado as validacoe 19/01/2012
        IF  crapcrm.dtemscar  = ?  OR
            crapcrm.dtcancel <> ?  THEN
            DO:
                ASSIGN aux_cdcritic = 277.
                LEAVE.
            END.
            
        IF  crapcrm.cdsitcar <> 2  THEN
            DO:
                IF  crapcrm.cdsitcar = 3 OR
                    crapcrm.cdsitcar = 4 THEN
                    DO:
                        ASSIGN aux_cdcritic = 625.
                        LEAVE.
                    END.
                ELSE
                    DO:
                        ASSIGN aux_dscritic = "** O Cartao nao foi entregue **".
                        LEAVE.
                    END.
            END.
        */
        IF  crapcrm.tptitcar = 9  THEN /* Cartao de Operador */
            DO:
                IF CAN-FIND(crapope NO-LOCK WHERE
                            crapope.cdcooper = par_cdcooper AND
                            crapope.cdoperad = par_cdoperad AND
                            (crapope.nvoperad <> 2 AND crapope.nvoperad <> 3)) THEN
                DO:
                    ASSIGN aux_flgerror = TRUE
                           aux_dscritic = "Acesso autorizado somente para " +
                                          "SUPERVISOR/GERENTE".
                    LEAVE.
                END.

                CREATE tt-crapcrm.
                ASSIGN tt-crapcrm.nrdconta = crapcrm.nrdconta
                       tt-crapcrm.nrdctitg = ""
                       tt-crapcrm.dssititg = ""
                       tt-crapcrm.nmprimtl = ""
                       tt-crapcrm.nmtitcrd = crapcrm.nmtitcrd
                       tt-crapcrm.dtemscar = crapcrm.dtemscar
                       tt-crapcrm.dtvalcar = crapcrm.dtvalcar.
            END.
        ELSE
            DO:
                FIND crapass WHERE crapass.cdcooper = par_cdcooper      AND
                                   crapass.nrdconta = crapcrm.nrdconta  
                                   NO-LOCK NO-ERROR.
    
                IF  crapass.flgctitg = 2   THEN
                    ASSIGN aux_dssititg = "Ativa".
                ELSE
                IF  crapass.flgctitg = 3   THEN
                    ASSIGN aux_dssititg = "Inativa".
                ELSE
                IF  crapass.nrdctitg <> ""   THEN
                    ASSIGN aux_dssititg = "Em Proc".
                ELSE
                    ASSIGN aux_dssititg = "".
             
                CREATE tt-crapcrm.
                ASSIGN tt-crapcrm.nrdconta = crapcrm.nrdconta
                       tt-crapcrm.nrdctitg = crapass.nrdctitg
                       tt-crapcrm.dssititg = aux_dssititg
                       tt-crapcrm.nmprimtl = IF  crapcrm.tptitcar = 1 THEN
                                                 crapass.nmprimtl
                                             ELSE
                                                 crapcrm.nmtitcrd
                       tt-crapcrm.nmtitcrd = crapcrm.nmtitcrd
                       tt-crapcrm.dtemscar = crapcrm.dtemscar
                       tt-crapcrm.dtvalcar = crapcrm.dtvalcar.
            END.

        ASSIGN aux_flgerror = FALSE.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  aux_flgerror  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,  /* Sequencia */   
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE. 

/*****************************************************************************
  Verifica a nova senha do cartao do cooperado
******************************************************************************/
PROCEDURE verifica-nova-senha:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrcartao AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrsennov AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrsencon AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgerror AS LOGI                                    NO-UNDO.

    DEF VAR h-b1wgen0032 AS HANDLE                                  NO-UNDO.

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Validar senha do cartao magnetico".

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgerror = TRUE.

    EMPTY TEMP-TABLE tt-erro.

    DO WHILE TRUE:

        IF  par_nrsennov <> par_nrsencon  THEN
            DO:
                ASSIGN aux_cdcritic = 3.
                LEAVE.
            END.
         
        IF  LENGTH(par_nrsennov) < 6  THEN
            DO:
                ASSIGN aux_cdcritic = 623.
                LEAVE.
            END.
        
        FIND crapcrm WHERE crapcrm.cdcooper = par_cdcooper AND
                           crapcrm.nrcartao = par_nrcartao NO-LOCK NO-ERROR.
        
        IF  crapcrm.tptitcar = 1 THEN
            DO:
                IF  ENCODE(par_nrsennov) = crapcrm.dssencar THEN
                    DO:
                        ASSIGN aux_cdcritic = 6.
                        LEAVE.
                    END.
            END.
        
        /* se for cartao magnetico de operador */
        IF crapcrm.tptitcar = 9 THEN
           DO:
               IF  NOT VALID-HANDLE(h-b1wgen0032)  THEN
                   RUN  sistema/generico/procedures/b1wgen0032.p 
                        PERSISTENT SET h-b1wgen0032.
        
               RUN validar-hist-cartmagope IN h-b1wgen0032 
                                          (INPUT crapcrm.cdcooper,
                                           INPUT crapcrm.nrdconta,
                                           INPUT crapcrm.tpusucar,
                                           INPUT par_nrsencon,
                                           INPUT NO, /* nao vai encodada */
                                          OUTPUT aux_dscritic).
               DELETE PROCEDURE h-b1wgen0032.
               IF aux_dscritic <> "" THEN
               DO:
                   ASSIGN aux_cdcritic  = 0.           
                   LEAVE.
               END.
        
           END. /* if crapcrm.tptitcar = 9 */

        ASSIGN aux_flgerror = FALSE.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  aux_flgerror  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,  /* Sequencia */   
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

                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "nrcartao",
                                             INPUT "",
                                             INPUT STRING(par_nrcartao,
                                                     "9999,9999,9999,9999")).
                END.

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE. 

/*****************************************************************************
  Atualiza a senha do cartao do cooperado
******************************************************************************/
PROCEDURE grava-nova-senha:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcartao AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrsennov AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.    
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    DEF VAR aux_dstpfrom AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsaltsen AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdpsrwd AS INTE                                    NO-UNDO.
    DEF VAR aux_ponteiro AS INTE                                    NO-UNDO.
    DEF VAR aux_nrsequen AS CHAR                                    NO-UNDO.

    DEF VAR h-b1wgen0032 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgenprwd AS HANDLE                                  NO-UNDO.

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Gravar senha do cartao magnetico".

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.

    EMPTY TEMP-TABLE tt-erro.
    
    TRANS_SENHA:

    DO TRANSACTION ON ENDKEY UNDO TRANS_SENHA, LEAVE TRANS_SENHA
                   ON ERROR  UNDO TRANS_SENHA, LEAVE TRANS_SENHA:
        
        FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper 
                           NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapcop THEN
            ASSIGN aux_dscritic = "Cooperativa nao encontrada".


        DO aux_contador = 1 TO 10:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".

            FIND crapcrm WHERE crapcrm.cdcooper = par_cdcooper AND
                               crapcrm.nrcartao = par_nrcartao 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
            IF  NOT AVAILABLE crapcrm  THEN
                DO:
                    IF  LOCKED crapcrm  THEN
                        DO:
                            ASSIGN aux_cdcritic = 77.
                            NEXT.
                        END.
                    ELSE
                        ASSIGN aux_dscritic = "Falha ao atualizar a senha.".
                END.

            LEAVE.

        END. /** Fim do DO ... TO **/

        IF  aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
            UNDO TRANS_SENHA, LEAVE TRANS_SENHA.
        
        /* se for cartao magnetico de operador */
        IF crapcrm.tptitcar = 9 THEN
           DO:
               IF  NOT VALID-HANDLE(h-b1wgen0032)  THEN
                   RUN  sistema/generico/procedures/b1wgen0032.p 
                        PERSISTENT SET h-b1wgen0032.
        
               RUN gravar-hist-cartmagope IN h-b1wgen0032 
                                         (INPUT crapcrm.cdcooper,
                                          INPUT crapcrm.nrdconta,
                                          INPUT crapcrm.tpusucar,
                                          INPUT ENCODE(par_nrsennov),
                                          OUTPUT aux_dscritic).
               DELETE PROCEDURE h-b1wgen0032.
        
               IF aux_dscritic <> "" THEN
               DO:
                   ASSIGN aux_cdcritic  = 0.           
                   UNDO TRANS_SENHA, LEAVE TRANS_SENHA.
               END.
           END.

        ASSIGN crapcrm.dssencar = ENCODE(par_nrsennov)
               crapcrm.dttransa = par_dtmvtolt
               crapcrm.hrtransa = TIME
               crapcrm.cdoperad = par_cdoperad.
        
        RUN sistema/generico/procedures/b1wgenpwrd.p 
                PERSISTENT SET h-b1wgenprwd ( INPUT crapcrm.dssencar,
                                             OUTPUT aux_dsdpsrwd).
    
        DELETE PROCEDURE h-b1wgenprwd.
    
        IF  aux_dsdpsrwd > 0 THEN
            DO:
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                
                RUN STORED-PROCEDURE pc_getPinBlockCripto
                aux_handproc = PROC-HANDLE NO-ERROR (INPUT STRING(crapcrm.nrcartao)
                                                    ,INPUT STRING(aux_dsdpsrwd)
                                                    ,"").
                                                    
                CLOSE STORED-PROC pc_getPinBlockCripto aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                
                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
                ASSIGN aux_nrsequen = pc_getPinBlockCripto.pSenhaCrypto
                                      WHEN pc_getPinBlockCripto.pSenhaCrypto <> ?.
                                      
                IF  TRIM(aux_nrsequen) <> "" THEN
                    ASSIGN crapcrm.dssenpin = TRIM(aux_nrsequen).
            END.

        
        IF crapcrm.tptitcar = 9 THEN /* se for cartao operador */
            ASSIGN aux_dstpfrom = "Operador " + STRING(crapcrm.nrdconta).
        ELSE
            ASSIGN aux_dstpfrom = "Conta/DV " + STRING(crapcrm.nrdconta).

        ASSIGN aux_dsaltsen = STRING(TODAY,"99/99/9999") + " - "               +
                              STRING(TIME,"HH:MM:SS") + " - "                  +
                              "Operador: " + STRING(par_cdoperad) + " - "      +
                              "Senha do cartao " + STRING(par_nrcartao) + ", " +
                              aux_dstpfrom + ", " + "foi alterada.".
        
        UNIX SILENT VALUE("echo " + aux_dsaltsen +
                         " >> /usr/coop/" + TRIM(crapcop.dsdircop) + 
                         "/log/" + LOWER(par_nmdatela) + ".log").

        FIND CURRENT crapcrm NO-LOCK NO-ERROR.

        RELEASE crapcrm.

        ASSIGN aux_flgtrans = TRUE.
    
    END. /** Fim do DO TRANSACTION **/

    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel gravar a senha.".
               
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

                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "nrcartao",
                                             INPUT "",
                                             INPUT STRING(par_nrcartao,
                                                     "9999,9999,9999,9999")).
                END.                                                            
            
            RETURN "NOK".
        END.

    IF  par_flgerlog  THEN 
        DO:
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

            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrcartao",
                                     INPUT "",
                                     INPUT STRING(par_nrcartao,
                                             "9999,9999,9999,9999")).
        END.

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/
