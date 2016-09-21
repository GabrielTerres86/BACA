/*.............................................................................

    Programa: b1wgen0047.p
    Autor   : David                        
    Data    : Novembro/2009                   Ultima atualizacao: 27/05/2014

    Objetivo  : Tranformacao BO tela CONTAS - Rotina DEPENDENTES
                Baseado em fontes/contas_dependentes.p

    Alteracoes: 22/09/2010 -  Adicionado tratamento para conta 'pai' 
                              ou 'filha' (Gabriel - DB1).
                              
                20/12/2010 - Adicionado parametros na chamada do procedure
                             Replica_Dados para tratamento do log e  erros
                             da validação na replicação (Gabriel - DB1).
                             
                13/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)

                27/05/2014 - Alterado a validacao do cdestcvl da tabela crapass
                             para buscar na crapttl (Douglas - Chamado 131253)

.............................................................................*/


/*................................. DEFINICOES ..............................*/

                                                                            
{ sistema/generico/includes/b1wgen0047tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-BO=SIM }

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
                                                                       
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
                                                                      
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.

DEF TEMP-TABLE tt-crapdep-old NO-UNDO LIKE crapdep.
DEF TEMP-TABLE tt-crapdep-new NO-UNDO LIKE crapdep.


/*............................ PROCEDURES EXTERNAS .........................*/


/****************************************************************************/
/**        Procedure para carregar dados dos dependentes do associado      **/
/****************************************************************************/
PROCEDURE obtem-dependentes:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_msgconta AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-dependente.

    DEF VAR aux_nrdconta AS INTE                                    NO-UNDO.
    DEF VAR h-b1wgen0077 AS HANDLE                                  NO-UNDO.
    
    EMPTY TEMP-TABLE tt-dependente.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obtem dependentes do associado".
    
    FOR EACH crapdep WHERE crapdep.cdcooper = par_cdcooper AND 
                           crapdep.nrdconta = par_nrdconta AND 
                           crapdep.idseqdep = par_idseqttl NO-LOCK
                           BY crapdep.nmdepend:
        
        FIND craptab WHERE craptab.cdcooper = crapdep.cdcooper AND 
                           craptab.nmsistem = "CRED"           AND 
                           craptab.tptabela = "GENERI"         AND 
                           craptab.cdempres = 0                AND 
                           craptab.cdacesso = "DSTPDEPEND"     AND 
                           craptab.tpregist = crapdep.tpdepend NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE craptab THEN 
            NEXT.
                
        CREATE tt-dependente.
        ASSIGN tt-dependente.nmdepend = crapdep.nmdepend
               tt-dependente.dtnascto = crapdep.dtnascto
               tt-dependente.cdtipdep = crapdep.tpdepend
               tt-dependente.dstipdep = craptab.dstextab
               tt-dependente.nrdrowid = ROWID(crapdep).   
    
    END. /** Fim do FOR EACH crapdep **/     
    
    /*Alteração: Busca CPF do cooperado e procura por contar filhas. 
    (Gabriel - DB1)*/
    FOR FIRST crapttl FIELDS (nrcpfcgc)
                       WHERE crapttl.cdcooper = par_cdcooper AND 
                             crapttl.nrdconta = par_nrdconta AND 
                             crapttl.idseqttl = par_idseqttl NO-LOCK: 
    END.
    
    IF AVAILABLE crapttl THEN
        DO:
            /* Rotina para controle/replicacao entre contas */
            IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
                RUN sistema/generico/procedures/b1wgen0077.p 
                    PERSISTENT SET h-b1wgen0077.
           
            RUN Busca_Conta IN h-b1wgen0077
                ( INPUT par_cdcooper,
                  INPUT par_nrdconta,
                  INPUT crapttl.nrcpfcgc,
                  INPUT par_idseqttl,
                 OUTPUT aux_nrdconta,
                 OUTPUT par_msgconta,
                 OUTPUT aux_cdcritic,
                 OUTPUT aux_dscritic ).

            IF  VALID-HANDLE(h-b1wgen0077) THEN
                DELETE OBJECT h-b1wgen0077.
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
/**     Procedure que carrega dados para alteracao, exclusao ou inclusao    **/
/*****************************************************************************/
PROCEDURE obtem-dados-operacao:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-dependente.
    DEF OUTPUT PARAM TABLE FOR tt-tipos-dependente.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    EMPTY TEMP-TABLE tt-dependente.
    EMPTY TEMP-TABLE tt-tipos-dependente.
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obtem dados para operacoes com dependente".
           
    FOR EACH craptab WHERE craptab.cdcooper = par_cdcooper AND 
                           craptab.nmsistem = "CRED"       AND 
                           craptab.tptabela = "GENERI"     AND 
                           craptab.cdempres = 0            AND 
                           craptab.cdacesso = "DSTPDEPEND" NO-LOCK:
         
        CREATE tt-tipos-dependente.
        ASSIGN tt-tipos-dependente.cdtipdep = craptab.tpregist
               tt-tipos-dependente.dstipdep = craptab.dstextab.
                                                                             
    END. /** Fim do FOR EACH craptab **/

    IF  NOT CAN-FIND(FIRST tt-tipos-dependente)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Tabela DSTPDEPEND nao cadastrada.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
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

    IF  par_cddopcao = "I"  THEN
        RETURN "OK".

    FIND crapdep WHERE ROWID(crapdep) = par_nrdrowid NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapdep  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro de dependente nao encontrado.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
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

    FIND tt-tipos-dependente WHERE 
         tt-tipos-dependente.cdtipdep = crapdep.tpdepend NO-LOCK NO-ERROR.

    CREATE tt-dependente.
    ASSIGN tt-dependente.nmdepend = crapdep.nmdepend
           tt-dependente.dtnascto = crapdep.dtnascto
           tt-dependente.cdtipdep = crapdep.tpdepend
           tt-dependente.dstipdep = IF  AVAILABLE tt-tipos-dependente  THEN 
                                        tt-tipos-dependente.dstipdep
                                    ELSE
                                        ""
           tt-dependente.nrdrowid = ROWID(crapdep).

    RETURN "OK".                             
                                                                             
END PROCEDURE.


/*****************************************************************************/
/**         Procedure para validar operacao de alteracao e inclusao         **/
/*****************************************************************************/
PROCEDURE valida-operacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_nmdepend AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtnascto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdtipdep AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabdep FOR crapdep.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Valida " + 
                         (IF  par_cddopcao = "A"  THEN 
                              "alteracao" 
                          ELSE 
                              "inclusao") +
                          " de dependente"
           aux_cdcritic = 0
           aux_dscritic = "".

    DO WHILE TRUE:

        IF  par_cddopcao <> "I"  THEN
            DO:
                FIND crabdep WHERE ROWID(crabdep) = par_nrdrowid 
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crabdep  THEN
                    DO:
                        ASSIGN aux_dscritic = "Dependente nao cadastrado.".
                        LEAVE.
                    END.
            END.

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapass  THEN
            DO:
                ASSIGN aux_cdcritic = 9.
                LEAVE.
            END.

        IF  par_cddopcao = "I"  AND
            par_nmdepend = ""   THEN
            DO:
                ASSIGN aux_dscritic = "Informe o nome do dependente.".
                LEAVE.
            END.

        IF  par_dtnascto = ?  THEN
            DO:
                ASSIGN aux_dscritic = "Informe a data de nascimento.".
                LEAVE.
            END.    

        IF  par_dtnascto >= par_dtmvtolt  THEN
            DO:
                ASSIGN aux_dscritic = "Data de nascimento invalida.".
                LEAVE.
            END.

        FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                           craptab.nmsistem = "CRED"       AND
                           craptab.tptabela = "GENERI"     AND
                           craptab.cdempres = 0            AND
                           craptab.cdacesso = "DSTPDEPEND" AND
                           craptab.tpregist = par_cdtipdep NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE craptab  THEN 
            DO:
                ASSIGN aux_dscritic = "Tipo de dependente invalido.".
                LEAVE.
            END.

        FIND FIRST crapttl WHERE crapttl.cdcooper = crapass.cdcooper
                             AND crapttl.nrdconta = crapass.nrdconta
                             AND crapttl.idseqttl = 1
                           NO-LOCK.
            IF AVAIL crapttl THEN
                DO:
                    IF (crapttl.cdestcvl = 1  OR 
                        crapttl.cdestcvl = 5) AND
                       (par_cdtipdep = 1      OR
                       (par_cdtipdep = 2      AND
                        par_cddopcao = "A"))  THEN
                        DO:
                            ASSIGN aux_cdcritic = 74.                            
                            LEAVE.
                        END.
                END.
       
        IF  par_cdtipdep = 1  OR 
            par_cdtipdep = 2  THEN   
            DO:
                IF  par_cddopcao = "A"  AND 
                    CAN-FIND(FIRST crapdep WHERE
                                   crapdep.cdcooper  = par_cdcooper     AND
                                   crapdep.nrdconta  = par_nrdconta     AND
                                   crapdep.nmdepend <> crabdep.nmdepend AND
                                  (crapdep.tpdepend  = 1                OR 
                                   crapdep.tpdepend  = 2))              THEN
                    DO:
                        ASSIGN aux_dscritic = "Ja existe um Conjugue/" +
                                              "Companheiro cadastrado.".
                        LEAVE.
                    END.

                IF  par_cddopcao = "I"  AND 
                    CAN-FIND(FIRST crapdep WHERE
                                   crapdep.cdcooper = par_cdcooper  AND
                                   crapdep.nrdconta = par_nrdconta  AND
                                  (crapdep.tpdepend = 1             OR 
                                   crapdep.tpdepend = 2))           THEN
                    DO:
                        ASSIGN aux_dscritic = "Ja existe um Conjugue/" +
                                              "Companheiro cadastrado.".
                        LEAVE.
                    END.
            END.

        IF  par_cddopcao = "I"  THEN  
            DO:
                IF  CAN-FIND(crapdep WHERE 
                             crapdep.cdcooper = par_cdcooper   AND
                             crapdep.nrdconta = par_nrdconta   AND
                             crapdep.idseqdep = par_idseqttl   AND
                             crapdep.nmdepend = par_nmdepend)  THEN 
                    DO:
                        ASSIGN aux_dscritic = "Dependente ja cadastrado.".
                        LEAVE.
                    END.
            END.
            
        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
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


/*****************************************************************************/
/**     Procedure para alterar,excluir ou incluir dependente do associado   **/
/*****************************************************************************/
PROCEDURE gerenciar-dependente:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_nmdepend AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtnascto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdtipdep AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_msgrvcad AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR h-b1wgen0077 AS HANDLE                                  NO-UNDO.
    
    DEFINE BUFFER bcrapttl FOR crapttl.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapdep-old.
    EMPTY TEMP-TABLE tt-crapdep-new.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = (IF  par_cddopcao = "A"  THEN
                               "Alterar"
                           ELSE
                           IF  par_cddopcao = "E"  THEN
                               "Excluir"
                           ELSE
                               "Incluir") +
                          " dependente para o associado"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.

    TRANSACAO:

    DO TRANSACTION ON ERROR  UNDO TRANSACAO, LEAVE TRANSACAO
                   ON ENDKEY UNDO TRANSACAO, LEAVE TRANSACAO:

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapass  THEN
            DO:
                ASSIGN aux_cdcritic = 9
                       aux_dscritic = "".

                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        IF  par_cddopcao = "I"  THEN
            DO:
                CREATE crapdep.
                ASSIGN crapdep.cdcooper = par_cdcooper 
                       crapdep.nrdconta = par_nrdconta
                       crapdep.idseqdep = par_idseqttl
                       crapdep.nmdepend = CAPS(par_nmdepend)
                       crapdep.tpdepend = par_cdtipdep
                       crapdep.dtnascto = par_dtnascto.
                VALIDATE crapdep.

                CREATE tt-crapdep-old.
                CREATE tt-crapdep-new.
                BUFFER-COPY crapdep TO tt-crapdep-new.
            END.
        ELSE
            DO:
                DO aux_contador = 1 TO 10:

                    FIND crapdep WHERE ROWID(crapdep) = par_nrdrowid 
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                    IF  NOT AVAILABLE crapdep  THEN
                        DO:
                            IF  LOCKED crapdep  THEN
                                DO:
                                    IF  aux_contador = 10  THEN
                                        DO:
                                            FIND crapdep WHERE 
                                                 ROWID(crapdep) = par_nrdrowid
                                                 NO-LOCK NO-ERROR.
                                            
                                            RUN critica-lock 
                                               (INPUT RECID(crapdep),
                                                INPUT "banco",
                                                INPUT "crapdep",
                                                INPUT par_idorigem).
                                        END.
                                    ELSE
                                        DO:
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT.
                                        END.
                                END.
                            ELSE
                                ASSIGN aux_dscritic = "Registro de dependente" +
                                                      " nao encontrado.".
                        END.
        
                    LEAVE.
        
                END. /** Fim do DO ... TO **/
        
                IF  aux_dscritic <> ""  THEN
                    UNDO TRANSACAO, LEAVE TRANSACAO.

                IF  par_flgerlog  THEN 
                    DO:
                        { sistema/generico/includes/b1wgenalog.i }
                    END.
                    
                CREATE tt-crapdep-new.
                CREATE tt-crapdep-old.
                BUFFER-COPY crapdep TO tt-crapdep-old.
                
                IF  par_cddopcao= "E"  THEN
                    DO: 
                        IF  par_flgerlog  THEN 
                            DO:
                                { sistema/generico/includes/b1wgenllog.i }
                            END.
                            
                        DELETE crapdep.
                    END.
                ELSE
                IF  par_cddopcao = "A"  THEN
                    DO:
                        ASSIGN crapdep.tpdepend = par_cdtipdep
                               crapdep.dtnascto = par_dtnascto.

                        BUFFER-COPY crapdep TO tt-crapdep-new.

                        IF  par_flgerlog  THEN 
                            DO:
                                { sistema/generico/includes/b1wgenllog.i }
                            END.
                    END.
            END.

        IF  AVAILABLE crapdep  THEN
            FIND CURRENT crapdep NO-LOCK NO-ERROR.

         /* Realiza a replicacao dos dados p/as contas relacionadas ao coop. */
        IF  par_idseqttl = 1 AND par_nmdatela = "CONTAS" THEN 
            DO:
               IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
                   RUN sistema/generico/procedures/b1wgen0077.p 
                        PERSISTENT SET h-b1wgen0077.
    
               RUN Replica_Dados IN h-b1wgen0077
                   ( INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT par_cdoperad,
                     INPUT par_nmdatela,
                     INPUT par_idorigem,
                     INPUT par_nrdconta,
                     INPUT par_idseqttl,
                     INPUT "DEPENDENTE",
                     INPUT par_dtmvtolt,
                     INPUT FALSE, /*par_flgerlog*/
                    OUTPUT aux_cdcritic,
                    OUTPUT aux_dscritic,
                    OUTPUT TABLE tt-erro ).

               IF  VALID-HANDLE(h-b1wgen0077) THEN
                   DELETE OBJECT h-b1wgen0077.

               IF  RETURN-VALUE <> "OK" THEN
                   UNDO TRANSACAO, LEAVE TRANSACAO.

               FIND FIRST bcrapttl WHERE bcrapttl.cdcooper = par_cdcooper AND
                                         bcrapttl.nrdconta = par_nrdconta AND
                                         bcrapttl.idseqttl = par_idseqttl
                                         NO-ERROR.
    
               IF AVAILABLE bcrapttl THEN DO:
                   IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
                       RUN sistema/generico/procedures/b1wgen0077.p
                           PERSISTENT SET h-b1wgen0077.
                   
                   RUN Revisao_Cadastral IN h-b1wgen0077
                     ( INPUT par_cdcooper,
                       INPUT bcrapttl.nrcpfcgc,
                       INPUT par_nrdconta,
                      OUTPUT par_msgrvcad ). 

                   IF  VALID-HANDLE(h-b1wgen0077) THEN
                       DELETE OBJECT h-b1wgen0077.
               END.

            END.

        ASSIGN aux_flgtrans = TRUE.

    END. /** Fim do DO TRANSACTION - TRANSACAO **/

    IF  VALID-HANDLE(h-b1wgen0077) THEN
        DELETE OBJECT h-b1wgen0077.

    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel " + 
                                     (IF  par_cddopcao = "A"  THEN
                                          "alterar"
                                      ELSE
                                      IF  par_cddopcao = "E"  THEN
                                          "excluir"
                                      ELSE
                                          "incluir") +
                                      " o dependente.".
                    
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
    
    IF  par_flgerlog  THEN 
        RUN proc_gerar_log_tab (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl, 
                                INPUT par_nmdatela, 
                                INPUT par_nrdconta, 
                                INPUT TRUE,
                                INPUT BUFFER tt-crapdep-old:HANDLE,
                                INPUT BUFFER tt-crapdep-new:HANDLE).

    RETURN "OK".

END PROCEDURE.


/*............................ PROCEDURES INTERNAS ..........................*/


PROCEDURE critica-lock:

    DEF  INPUT PARAM par_nrdrecid AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdbanco AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmtabela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_loginusr AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmusuari AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdevice AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtconnec AS CHAR                                    NO-UNDO.
    DEF VAR aux_numipusr AS CHAR                                    NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "Registro sendo alterado em outro terminal (" + 
                          par_nmtabela + ").".

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
    
    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        RETURN.
        
    RUN acha-lock IN h-b1wgen9999 (INPUT par_nrdrecid,
                                   INPUT par_nmdbanco,
                                   INPUT par_nmtabela,
                                  OUTPUT aux_loginusr,
                                  OUTPUT aux_nmusuari,
                                  OUTPUT aux_dsdevice,
                                  OUTPUT aux_dtconnec, 
                                  OUTPUT aux_numipusr).

    DELETE PROCEDURE h-b1wgen9999.

    ASSIGN aux_dscritic = aux_dscritic + " Operador: " + 
                          aux_loginusr + " - " + aux_nmusuari.

    RETURN "OK".

END PROCEDURE.


/*...........................................................................*/

