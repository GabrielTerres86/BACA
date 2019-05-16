/*.............................................................................

    Programa  : sistema/generico/procedures/b1wgen0071.p
    Autor     : David
    Data      : Abril/2010                  Ultima Atualizacao: 17/01/2017
    
    Dados referentes ao programa:

    Objetivo  : BO referente ao modulo Meu Cadastro da Conta On-Line e
                rotina EMAILS da tela CONTAS.

    Alteracoes:  22/09/2010 - Adicionado tratamento para conta 'pai' 
                              ou 'filha' (Gabriel - DB1).
                              
                 20/12/2010 - Adicionado parametros na chamada do procedure
                              Replica_Dados para tratamento do log e  erros
                              da validação na replicação (Gabriel - DB1).
                              
                 11/03/2011 - Substituir dsdemail da crapass para a crapcem
                             (Gabriel).             

                 06/01/2012 - Validacao de espacos no email (Tiago).
                 
                 13/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
                 
                 17/01/2017 - Adicionado chamada a procedure de replicacao do 
                              email para o CDC. (Reinert Prj 289)                 
                              
                 01/02/2018 - Nao fazer a replicacao por este rotina, pois devera
                              ser feita apenas pela tabela tbcadast_pessoa_email
                              (Andrino - CRM)
.............................................................................*/


/*................................ DEFINICOES ...............................*/


{ sistema/generico/includes/b1wgen0071tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-BO=SIM }
{ sistema/generico/includes/var_oracle.i }
    
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
                                           
DEF TEMP-TABLE tt-crapcem-old NO-UNDO LIKE crapcem.
DEF TEMP-TABLE tt-crapcem-new NO-UNDO LIKE crapcem.


/*............................ PROCEDURES EXTERNAS ..........................*/


/*****************************************************************************/
/**              Procedure para retornar e-mails do cooperado               **/
/*****************************************************************************/
PROCEDURE obtem-email-cooperado: 

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
    DEF OUTPUT PARAM TABLE FOR tt-email-cooperado.

    DEF VAR aux_nrdconta AS INTE                                    NO-UNDO.
    DEF VAR h-b1wgen0077 AS HANDLE                                  NO-UNDO.

    EMPTY TEMP-TABLE tt-email-cooperado.
 
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter e-mails do cooperado".

    FOR EACH crapcem WHERE crapcem.cdcooper = par_cdcooper AND
                           crapcem.nrdconta = par_nrdconta AND
                           crapcem.idseqttl = par_idseqttl NO-LOCK
                           BY crapcem.dsdemail:
                                                                               
        CREATE tt-email-cooperado.
        ASSIGN tt-email-cooperado.dsdemail = crapcem.dsdemail
               tt-email-cooperado.secpscto = crapcem.secpscto
               tt-email-cooperado.nmpescto = crapcem.nmpescto
               tt-email-cooperado.nrdrowid = ROWID(crapcem).
        
    END. /** Fim do FOR EACH crapcem **/
    
    /*Alteração: Busca CPF do cooperado e procura por contar filhas. 
    (Gabriel - DB1)*/
    FOR FIRST crapttl FIELDS (nrcpfcgc)
                       WHERE crapttl.cdcooper = par_cdcooper AND 
                             crapttl.nrdconta = par_nrdconta AND 
                             crapttl.idseqttl = par_idseqttl NO-LOCK: 
    END.
    
    IF  AVAILABLE crapttl THEN
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
/**             Procedure para obter dados para gerenciar e-mail            **/
/*****************************************************************************/
PROCEDURE obtem-dados-gerenciar-email: 

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

    DEF OUTPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
 
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-email-cooperado.

    DEF VAR aux_insituac AS INTE                                    NO-UNDO.
    DEF VAR aux_dssituac AS CHAR                                    NO-UNDO.
    DEF VAR aux_idcanal  AS INTE                                    NO-UNDO.
    DEF VAR aux_dscanal  AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtrevisa AS DATE                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-email-cooperado.
 
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter dados para gerenciar e-mail do cooperado".

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".
                           
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

    ASSIGN par_inpessoa = crapass.inpessoa.

    IF  par_cddopcao = "I"  THEN
        DO:
            CREATE tt-email-cooperado.
            ASSIGN tt-email-cooperado.cddemail = 0
                   tt-email-cooperado.dsdemail = ""
                   tt-email-cooperado.secpscto = ""
                   tt-email-cooperado.nmpescto = "".

            RETURN "OK".
        END.

    FIND crapcem WHERE ROWID(crapcem) = par_nrdrowid NO-LOCK NO-ERROR.
                               
    IF  NOT AVAILABLE crapcem  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "E-mail nao cadastrado.".
                           
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
    CREATE tt-email-cooperado.
    
    IF  par_cddopcao = "A"  THEN
      DO:
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
        /* Efetuar a chamada a rotina Oracle */
        RUN STORED-PROCEDURE pc_busca_tbcadast
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.nrcpfcgc /* Cpf */
                                            ,INPUT crapcem.cddemail     /* Numero sequencial  */
                                            ,INPUT "EMAIL"          /* Tabela que será buscada */ 
                                            ,OUTPUT 0               /* Codigo da situacao */
                                            ,OUTPUT ""              /* Descricao da situacao   */
                                            ,OUTPUT 0               /* Codigo do Canal    */
                                            ,OUTPUT ""              /* Descricao do Canal */
                                            ,OUTPUT ?               /* Data da Revisao    */
                                            ,OUTPUT "").            /* Descrição da crítica    */
        /* Fechar o procedimento para buscarmos o resultado */ 
        CLOSE STORED-PROC pc_busca_tbcadast
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
        ASSIGN aux_insituac = pc_busca_tbcadast.pr_insituac
                              WHEN pc_busca_tbcadast.pr_insituac <> ?
               aux_dssituac = pc_busca_tbcadast.pr_dssituac
                              WHEN pc_busca_tbcadast.pr_dssituac <> ?
               aux_idcanal  = pc_busca_tbcadast.pr_idcanal
                              WHEN pc_busca_tbcadast.pr_idcanal <> ?
               aux_dscanal  = pc_busca_tbcadast.pr_dscanal
                              WHEN pc_busca_tbcadast.pr_dscanal <> ?
               aux_dtrevisa = pc_busca_tbcadast.pr_dtrevisa
                              WHEN pc_busca_tbcadast.pr_dtrevisa <> ?
               aux_dscritic = pc_busca_tbcadast.pr_dscritic
                              WHEN pc_busca_tbcadast.pr_dscritic <> ?.
                             
        /* Se retornou erro */
        IF aux_dscritic <> "" THEN 
          DO:
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1, /** Sequencia **/
                             INPUT 0,
                             INPUT-OUTPUT aux_dscritic).
          END.    
                
        ASSIGN tt-email-cooperado.dssituac = aux_dssituac
               tt-email-cooperado.dsdcanal = aux_dscanal
               tt-email-cooperado.dtrevisa = aux_dtrevisa.
      END.
 
    ASSIGN tt-email-cooperado.cddemail = crapcem.cddemail
           tt-email-cooperado.dsdemail = crapcem.dsdemail
           tt-email-cooperado.secpscto = crapcem.secpscto
           tt-email-cooperado.nmpescto = crapcem.nmpescto
           tt-email-cooperado.nrdrowid = ROWID(crapcem).

    
    RETURN "OK".
    
END PROCEDURE.


/*****************************************************************************/
/**          Procedure para validar alteracao/inclusao de e-mail            **/
/*****************************************************************************/
PROCEDURE validar-email: 

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
    DEF  INPUT PARAM par_dsdemail AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_secpscto AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmpescto AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrctarep AS INTE                           NO-UNDO.
 
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabcem FOR crapcem.

    DEF VAR aux_cddfrenv AS INTE                                    NO-UNDO.

    DEF VAR aux_flgerror AS LOGI                                    NO-UNDO.

    DEF VAR aux_msgconta AS CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Validar e-mail do cooperado"
           aux_flgerror = TRUE
           aux_cdcritic = 0
           aux_dscritic = "".

    DO WHILE TRUE:

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapass  THEN
            DO:
                ASSIGN aux_cdcritic = 9.
                LEAVE.
            END.

        IF  par_cddopcao <> "I"  THEN
            DO:
                FIND crabcem WHERE ROWID(crabcem) = par_nrdrowid 
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crabcem  THEN
                    DO:
                        ASSIGN aux_dscritic = "E-mail nao cadastrado.".
                        LEAVE.
                    END.
            END.

        IF  par_cddopcao = "A"  OR 
            par_cddopcao = "I"  THEN
            DO:
                IF  par_dsdemail = ""  THEN
                    DO:
                        ASSIGN aux_dscritic = "Informe o e-mail.".
                        LEAVE.
                    END.

                IF  NOT par_dsdemail MATCHES "*@*" OR
                        par_dsdemail MATCHES "* *" THEN
                    DO:
                        ASSIGN aux_dscritic = "Endereco de e-mail invalido.".
                        LEAVE.
                    END. 

                IF  par_cddopcao = "A"  AND
                    CAN-FIND(LAST crapcem WHERE 
                             crapcem.cdcooper  = par_cdcooper     AND
                             crapcem.nrdconta  = par_nrdconta     AND
                             crapcem.idseqttl  = par_idseqttl     AND
                             crapcem.dsdemail  = par_dsdemail     AND
                             crapcem.cddemail <> crabcem.cddemail NO-LOCK) THEN
                    DO:
                        ASSIGN aux_dscritic = "E-mail ja cadastrado para o " +
                                              "titular.".
                        LEAVE.
                    END.
        
                IF  par_cddopcao = "I"  AND
                    CAN-FIND(LAST crapcem WHERE 
                             crapcem.cdcooper = par_cdcooper AND
                             crapcem.nrdconta = par_nrdconta AND
                             crapcem.idseqttl = par_idseqttl AND
                             crapcem.dsdemail = par_dsdemail NO-LOCK) THEN
                    DO:
                        ASSIGN aux_dscritic = "E-mail ja cadastrado para o " +
                                              "titular.".
                        LEAVE.
                    END.
            END.
        ELSE
        IF  par_cddopcao = "E"  THEN
            DO: 
                IF  par_nrctarep > 0  THEN
                    DO: 
                        RUN obtem-email-cooperado
                                       (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_cdoperad,
                                        INPUT par_nmdatela,
                                        INPUT par_idorigem,
                                        INPUT par_nrctarep,
                                        INPUT 1,
                                        INPUT FALSE,
                                       OUTPUT aux_msgconta,
                                       OUTPUT TABLE tt-email-cooperado).

                        IF  RETURN-VALUE = "NOK"  THEN
                            LEAVE.
                    END.

                /** Verifica se o e-mail esta vinculado para informativo **/
                FOR EACH craptab WHERE craptab.cdcooper = 0            AND
                                       craptab.nmsistem = "CRED"       AND
                                       craptab.tptabela = "USUARI"     AND
                                       craptab.cdempres = 11           AND
                                       craptab.cdacesso = "FORENVINFO" NO-LOCK:

                    IF  ENTRY(2,craptab.dstextab,",") = "crapcem"  THEN
                        ASSIGN aux_cddfrenv = craptab.tpregist.

                END. /** Fim do FOR EACH craptab **/

                IF  CAN-FIND(FIRST crapcra WHERE 
                             crapcra.cdcooper = par_cdcooper     AND
                             crapcra.nrdconta = par_nrdconta     AND
                             crapcra.idseqttl = par_idseqttl     AND
                             crapcra.cddfrenv = aux_cddfrenv     AND
                             crapcra.cdseqinc = crabcem.cddemail NO-LOCK) THEN
                    DO: 
                        /* Se email excluido na conta replicadora, criticar */
                        IF  par_nrctarep = 0  OR
                            NOT CAN-FIND(FIRST tt-email-cooperado WHERE
                                tt-email-cooperado.dsdemail = par_dsdemail
                                NO-LOCK)  THEN
                            DO: 
                                ASSIGN aux_dscritic = "Existem informativos " +
                                                      "cadastrados com este " + 
                                                      "e-mail.".
                                LEAVE.
                            END.
                    END.
                
                /************************************************************/
                /** Se o e-mail a ser excluido e o mesmo e-mail usado para **/
                /** retorno de arquivo de cobranca, nao pode ser excluido. **/
                /************************************************************/
                IF  CAN-FIND (FIRST crapceb WHERE
                                    crapceb.cdcooper = par_cdcooper AND
                                    crapceb.nrdconta = par_nrdconta AND
                                    crapceb.cddemail = crabcem.cddemail) THEN
                    DO:
                        /* Se email excluido na conta replicadora, criticar */
                        IF  par_nrctarep = 0  OR
                            NOT CAN-FIND(FIRST tt-email-cooperado WHERE
                                tt-email-cooperado.dsdemail = par_dsdemail
                                NO-LOCK)  THEN
                            DO:
                                ASSIGN aux_dscritic = "E-mail usado para " +
                                                      "retorno de arquivo " +
                                                      "de cobranca.".
                                LEAVE.
                            END.
                    END.
            END.
        
        ASSIGN aux_flgerror = FALSE.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  aux_flgerror  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro  THEN
                ASSIGN aux_dscritic = tt-erro.dscritic.
            ELSE
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


/*****************************************************************************/
/**          Procedure para alteracao/inclusao/exclusao de e-mail           **/
/*****************************************************************************/
PROCEDURE gerenciar-email: 

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_dsdemail AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_secpscto AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmpescto AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_prgqfalt AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_msgrvcad AS CHAR                           NO-UNDO.
 
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    DEF VAR h-b1wgen0077 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_cddemail AS INTE                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
   
    DEF BUFFER bcrapttl FOR crapttl.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapcem-old.
    EMPTY TEMP-TABLE tt-crapcem-new.
 
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = IF  par_cddopcao = "A"  THEN
                              "Alteracao de e-mail"
                          ELSE
                          IF  par_cddopcao = "E"  THEN
                              "Exclusao de e-mail"
                          ELSE
                              "Inclusao de e-mail"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.

    TRANS_EMAIL:
    
    DO TRANSACTION ON ERROR  UNDO TRANS_EMAIL, LEAVE TRANS_EMAIL
                   ON ENDKEY UNDO TRANS_EMAIL, LEAVE TRANS_EMAIL:

        IF  par_cddopcao = "I"  THEN 
            DO:
                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = par_nrdconta
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapass  THEN
                    DO:
                        ASSIGN aux_cdcritic = 9
                               aux_dscritic = "".

                        UNDO TRANS_EMAIL, LEAVE TRANS_EMAIL.
                    END.

                FIND LAST crapcem WHERE crapcem.cdcooper = par_cdcooper AND
                                        crapcem.nrdconta = par_nrdconta AND
                                        crapcem.idseqttl = par_idseqttl   
                                        NO-LOCK NO-ERROR.
                            
                ASSIGN aux_cddemail = IF  AVAILABLE crapcem  THEN 
                                          crapcem.cddemail + 1
                                      ELSE 
                                          1.

                CREATE crapcem.
                ASSIGN crapcem.cdcooper = par_cdcooper
                       crapcem.nrdconta = par_nrdconta
                       crapcem.idseqttl = par_idseqttl
                       crapcem.cdoperad = par_cdoperad
                       crapcem.cddemail = aux_cddemail
                       crapcem.dsdemail = LC(par_dsdemail)
                       crapcem.dtmvtolt = par_dtmvtolt
                       crapcem.hrtransa = TIME
                       crapcem.prgqfalt = par_prgqfalt
                       crapcem.secpscto = CAPS(par_secpscto)
                       crapcem.nmpescto = CAPS(par_nmpescto).
                VALIDATE crapcem.

                /** Cria registro vazio para executar buffer-compare **/
                CREATE tt-crapcem-old. 
                CREATE tt-crapcem-new.
                BUFFER-COPY crapcem TO tt-crapcem-new. 

                IF  par_nmdatela = "CONTAS"  AND
                    par_flgerlog             THEN
                    DO:
                        { sistema/generico/includes/b1wgenalog.i }
                        { sistema/generico/includes/b1wgenllog.i }
                    END.
            END.
        ELSE
            DO:
                FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                                   crapass.nrdconta = par_nrdconta
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAIL crapass   THEN
                     DO:
                         ASSIGN aux_cdcritic = 9.
                         UNDO TRANS_EMAIL, LEAVE TRANS_EMAIL.
                     END.

                DO aux_contador = 1 TO 10:
        
                    FIND crapcem WHERE ROWID(crapcem) = par_nrdrowid
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crapcem  THEN
                        DO:
                            IF  LOCKED crapcem  THEN
                                DO:
                                    IF  aux_contador = 10  THEN
                                        DO:
                                            FIND crapcem WHERE 
                                                 ROWID(crapcem) = par_nrdrowid
                                                 NO-LOCK NO-ERROR.

                                            RUN critica-lock 
                                                (INPUT RECID(crapcem),
                                                 INPUT "banco",
                                                 INPUT "crapcem",
                                                 INPUT par_idorigem).
                                        END.
                                    ELSE
                                        DO:
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT.
                                        END.
                                END.
                            ELSE    
                                aux_dscritic = "E-mail nao cadastrado.".
                        END.
                
                    LEAVE.
                   
                END. /** Fim do DO ... TO **/
                     
                IF  aux_dscritic <> ""  THEN
                    UNDO TRANS_EMAIL, LEAVE TRANS_EMAIL.

                IF  par_nmdatela = "CONTAS"  AND
                    par_flgerlog             THEN
                    DO:
                        { sistema/generico/includes/b1wgenalog.i }
                    END.                       

                CREATE tt-crapcem-old.
                BUFFER-COPY crapcem TO tt-crapcem-old.

                IF  par_cddopcao = "A"  THEN
                    DO:
                        IF  par_idorigem = 3  THEN  /** InternetBank **/
                            ASSIGN par_secpscto = crapcem.secpscto 
                                   par_nmpescto = crapcem.nmpescto.

                        ASSIGN crapcem.cdoperad = par_cdoperad
                               crapcem.dsdemail = LC(par_dsdemail)
                               crapcem.secpscto = CAPS(par_secpscto)
                               crapcem.nmpescto = CAPS(par_nmpescto)
                               crapcem.dtmvtolt = par_dtmvtolt
                               crapcem.hrtransa = TIME
                               crapcem.prgqfalt = par_prgqfalt.

                        CREATE tt-crapcem-new.
                        BUFFER-COPY crapcem TO tt-crapcem-new.

                        IF  par_nmdatela = "CONTAS"  AND
                            par_flgerlog             THEN
                            DO:
                                { sistema/generico/includes/b1wgenllog.i }
                            END.                       
                    END.
                ELSE
                IF  par_cddopcao = "E"  THEN
                    DO:
                        /** Cria registro vazio para executar buffer-compare**/
                        CREATE tt-crapcem-new. 

                        IF  par_nmdatela = "CONTAS"  AND
                            par_flgerlog             THEN
                            DO:
                                { sistema/generico/includes/b1wgenllog.i }
                            END.                        

                        DELETE crapcem.
                    END.
            END.

        IF  AVAILABLE crapcem  THEN
            FIND CURRENT crapcem NO-LOCK NO-ERROR.

        /* Realiza a replicacao dos dados p/as contas relacionadas ao coop. */
        IF  par_idseqttl = 1 AND par_nmdatela = "CONTAS" THEN 
            DO:
/*      Nao replicar, pois a replicacao sera feito pelas tabelas TBCADAST_PESSOA_EMAIL
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
                     INPUT "EMAIL",
                     INPUT par_dtmvtolt,
                     INPUT FALSE, /*par_flgerlog*/
                    OUTPUT aux_cdcritic,
                    OUTPUT aux_dscritic,
                    OUTPUT TABLE tt-erro ).

               IF  VALID-HANDLE(h-b1wgen0077) THEN
                   DELETE OBJECT h-b1wgen0077.

               IF  RETURN-VALUE <> "OK" THEN
                   UNDO TRANS_EMAIL, LEAVE TRANS_EMAIL.
  */             
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
            
            /* Quando for primeiro titular, vamos ver ser o cooperado eh 
               um conveniado CDC. Caso positivo, vamos replicar os dados
               alterados de e-mail para as tabelas do CDC. */
            IF par_idseqttl = 1 THEN 
              DO:
            FOR FIRST crapcdr WHERE crapcdr.cdcooper = par_cdcooper
                                AND crapcdr.nrdconta = par_nrdconta
                                AND crapcdr.flgconve = TRUE NO-LOCK:

              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
              
              RUN STORED-PROCEDURE pc_replica_cdc
                aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                    ,INPUT par_nrdconta
                                                    ,INPUT par_cdoperad
                                                    ,INPUT par_idorigem
                                                    ,INPUT par_nmdatela
                                                    ,INPUT 0
                                                    ,INPUT 0
                                                    ,INPUT 1
                                                    ,INPUT 0
                                                    ,0
                                                    ,"").

              CLOSE STORED-PROC pc_replica_cdc
                        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

              ASSIGN aux_cdcritic = 0
                     aux_dscritic = ""
                     aux_cdcritic = pc_replica_cdc.pr_cdcritic 
                                      WHEN pc_replica_cdc.pr_cdcritic <> ?
                     aux_dscritic = pc_replica_cdc.pr_dscritic 
                                      WHEN pc_replica_cdc.pr_dscritic <> ?.
                                      
            END.
              END.

         
        ASSIGN aux_flgtrans = TRUE.
    
    END. /** Fim do DO TRANSACTION - TRANS_EMAIL **/
                              
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
                                      " o e-mail.".
               
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
                                INPUT BUFFER tt-crapcem-old:HANDLE,
                                INPUT BUFFER tt-crapcem-new:HANDLE).

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

    IF  par_idorigem = 3  THEN  /** InternetBank **/
        RETURN.

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
