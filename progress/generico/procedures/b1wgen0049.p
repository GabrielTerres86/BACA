/*..............................................................................

    Programa: b1wgen0049.p
    Autor   : David
    Data    : Novembro/2009                   Ultima atualizacao: 13/12/2013   

    Objetivo  : Tranformacao BO tela CONTAS - Rotina REFERENCIAS
                Baseado em fontes/contas_contatos_juridica.p

    Alteracoes: 11/03/2011 - Retirar campo dsdemail da crapass (Gabriel).
    
                18/04/2011 - Validacao de CEP existente. (André - DB1) 
                
                05/08/2013 - Alterado para pegar o telefone da tabela 
                             craptfc ao invés da crapass (James).
                           
                19/08/2013 - Incluido a chamada da procedure 
                             "atualiza_data_manutencao_cadastro" dentro da
                             procedure "gerenciar-contato" (James).
                             
                13/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
                             
..............................................................................*/


/*................................. DEFINICOES ...............................*/

                                                                                
{ sistema/generico/includes/b1wgen0049tt.i}
{ sistema/generico/includes/b1wgen0168tt.i}
{ sistema/generico/includes/var_internet.i}
{ sistema/generico/includes/gera_log.i}
{ sistema/generico/includes/gera_erro.i}
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-BO=SIM }

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
                                                                       
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
                                                                      
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.

DEF TEMP-TABLE tt-crapavt-old NO-UNDO LIKE crapavt.
DEF TEMP-TABLE tt-crapavt-new NO-UNDO LIKE crapavt.


/*............................ PROCEDURES EXTERNAS ...........................*/


/******************************************************************************/
/**               Procedure para carregar contatos do associado              **/
/******************************************************************************/
PROCEDURE obtem-contatos:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-contato-juridica.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-contato-juridica.
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obtem contatos do associado".

    FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper AND
                           crapavt.nrdconta = par_nrdconta AND
                           crapavt.tpctrato = 5            
                           NO-LOCK BY crapavt.nrdctato:

        CREATE tt-contato-juridica.
        ASSIGN tt-contato-juridica.cddctato = TRIM(STRING(crapavt.nrdctato,
                                                          "zzzz,zzz,9"))
               tt-contato-juridica.nrdctato = crapavt.nrdctato
               tt-contato-juridica.nmdavali = crapavt.nmdavali
               tt-contato-juridica.nrtelefo = crapavt.nrtelefo
               tt-contato-juridica.dsdemail = crapavt.dsdemail
               tt-contato-juridica.nrdrowid = ROWID(crapavt).
        
        IF  crapavt.nrdctato > 0  THEN 
            DO:
                FIND crapass WHERE 
                     crapass.cdcooper = par_cdcooper                 AND 
                     crapass.nrdconta = tt-contato-juridica.nrdctato 
                     NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapass  THEN
                    DO:
                        ASSIGN aux_cdcritic = 9
                               aux_dscritic = "".
                        
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
                                          
                /** Telefone **/
                FIND FIRST craptfc WHERE craptfc.cdcooper = par_cdcooper     AND
                                         craptfc.nrdconta = crapavt.nrdctato AND
                                         craptfc.idseqttl = 1                
                                         NO-LOCK NO-ERROR.
                                          
                /** E-Mail **/
                FIND crapcem WHERE crapcem.cdcooper = par_cdcooper     AND 
                                   crapcem.nrdconta = crapavt.nrdctato AND 
                                   crapcem.idseqttl = 1                AND 
                                   crapcem.cddemail = 1 
                                   NO-LOCK NO-ERROR.
                
                ASSIGN tt-contato-juridica.nmdavali = crapass.nmprimtl 
                       tt-contato-juridica.nrtelefo = IF AVAILABLE craptfc THEN
                                                       STRING(craptfc.nrtelefo)
                                                      ELSE
                                                       ""
                       tt-contato-juridica.dsdemail = crapcem.dsdemail
                                                      WHEN AVAIL crapcem.

            END.

    END. /** Fim do FOR EACH crapavt **/

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
/**                 Procedure para consultar dados do contato                **/
/******************************************************************************/
PROCEDURE consultar-dados-contato:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-contato-jur.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEFINE VARIABLE aux_nmdbanco AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE aux_nmageban AS CHARACTER   NO-UNDO.

    EMPTY TEMP-TABLE tt-contato-jur.
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Consultar dados do contato" +
                         (IF  par_cddopcao = "A"  THEN
                              " para alteracao"
                          ELSE
                          IF  par_cddopcao = "E"  THEN
                              " para exclusao"
                          ELSE
                              "").

    FIND crapavt WHERE ROWID(crapavt) = par_nrdrowid NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapavt  THEN
        DO:
            ASSIGN aux_cdcritic = 491
                   aux_dscritic = "".

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

    IF  crapavt.nrdctato > 0  THEN
        DO:
            IF  par_cddopcao = "A"  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Nao e possivel alterar um contato " +
                                          "que e cooperado.".

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

            FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND
                               crapass.nrdconta = crapavt.nrdctato
                               NO-LOCK NO-ERROR.
                               
            IF  NOT AVAILABLE crapass  THEN
                DO:
                    ASSIGN aux_cdcritic = 9
                           aux_dscritic = "".
                     
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
                 
            /** Endereco **/
            FIND crapenc WHERE crapenc.cdcooper = par_cdcooper     AND
                               crapenc.nrdconta = crapavt.nrdctato AND
                               crapenc.idseqttl = 1                AND
                               crapenc.cdseqinc = 1
                               NO-LOCK NO-ERROR.
                               
            IF  NOT AVAILABLE crapenc  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Endereco nao cadastrado.".
                     
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

            /** Telefone **/
            FIND FIRST craptfc WHERE craptfc.cdcooper = par_cdcooper     AND
                                     craptfc.nrdconta = crapavt.nrdctato AND
                                     craptfc.idseqttl = 1                
                                     NO-LOCK NO-ERROR.
                               
            /** E-Mail **/
            FIND crapcem WHERE crapcem.cdcooper = par_cdcooper     AND
                               crapcem.nrdconta = crapavt.nrdctato AND
                               crapcem.idseqttl = 1                AND
                               crapcem.cddemail = 1
                               NO-LOCK NO-ERROR.
                    
            CREATE tt-contato-jur.
            ASSIGN tt-contato-jur.nrdctato = crapavt.nrdctato
                   tt-contato-jur.nmdavali = crapass.nmprimtl
                   tt-contato-jur.dsproftl = ""
                   tt-contato-jur.nmextemp = ""
                   tt-contato-jur.cddbanco = 0
                   tt-contato-jur.cdageban = 0
                   tt-contato-jur.nrcepend = crapenc.nrcepend
                   tt-contato-jur.dsendere = crapenc.dsendere
                   tt-contato-jur.nrendere = crapenc.nrendere
                   tt-contato-jur.complend = crapenc.complend
                   tt-contato-jur.nmbairro = crapenc.nmbairro
                   tt-contato-jur.nmcidade = crapenc.nmcidade
                   tt-contato-jur.cdufende = crapenc.cdufende
                   tt-contato-jur.nrcxapst = crapenc.nrcxapst
                   tt-contato-jur.nrtelefo = IF AVAILABLE craptfc  THEN
                                                STRING(craptfc.nrtelefo)
                                             ELSE 
                                                ""
                   tt-contato-jur.dsdemail = crapcem.dsdemail
                                             WHEN AVAIL crapcem
                   tt-contato-jur.nrdrowid = ROWID(crapavt).
             
        END.
    ELSE
        DO:
            /** Buscar dados de banco e agencia **/
            FIND crapban WHERE crapban.cdbccxlt = crapavt.cddbanco 
                               NO-LOCK NO-ERROR.

            IF  AVAILABLE crapban  THEN
                ASSIGN aux_nmdbanco = crapban.nmresbcc.
            ELSE
                ASSIGN aux_nmdbanco = "".

            FIND crapagb WHERE crapagb.cddbanco = crapavt.cddbanco AND
                               crapagb.cdageban = crapavt.cdagenci
                               NO-LOCK NO-ERROR.

            IF  AVAILABLE crapagb  THEN
                ASSIGN aux_nmageban = crapagb.nmageban.
            ELSE
                ASSIGN aux_nmageban = "".

            CREATE tt-contato-jur.
            ASSIGN tt-contato-jur.nrdctato = 0
                   tt-contato-jur.nmdavali = crapavt.nmdavali
                   tt-contato-jur.nmextemp = crapavt.nmextemp
                   tt-contato-jur.cddbanco = crapavt.cddbanco
                   tt-contato-jur.nmdbanco = aux_nmdbanco
                   tt-contato-jur.cdageban = crapavt.cdagenci
                   tt-contato-jur.nmageban = aux_nmageban
                   tt-contato-jur.dsproftl = crapavt.dsproftl
                   tt-contato-jur.nrcepend = crapavt.nrcepend
                   tt-contato-jur.dsendere = crapavt.dsendres[1]
                   tt-contato-jur.nrendere = crapavt.nrendere
                   tt-contato-jur.complend = crapavt.complend
                   tt-contato-jur.nmbairro = crapavt.nmbairro
                   tt-contato-jur.nmcidade = crapavt.nmcidade
                   tt-contato-jur.cdufende = crapavt.cdufresd
                   tt-contato-jur.nrcxapst = crapavt.nrcxapst
                   tt-contato-jur.nrtelefo = crapavt.nrtelefo
                   tt-contato-jur.dsdemail = crapavt.dsdemail
                   tt-contato-jur.nrdrowid = ROWID(crapavt).
        END.
        
    IF  par_flgerlog        AND
        par_cddopcao = "C"  THEN
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
/**   Procedure para consultar dados de determinado cooperado para contato   **/
/******************************************************************************/
PROCEDURE consultar-dados-cooperado-contato:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-contato-jur.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-contato-jur.
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Consultar dados de associado para contato".
    
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND 
                       crapass.nrdconta = par_nrdctato NO-LOCK NO-ERROR.
        
    IF  NOT AVAILABLE crapass  THEN 
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

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

    /** Endereco **/
    FIND crapenc WHERE crapenc.cdcooper = par_cdcooper AND
                       crapenc.nrdconta = par_nrdctato AND
                       crapenc.idseqttl = 1            AND
                       crapenc.cdseqinc = 1            NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapenc  THEN 
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Endereco nao cadastrado.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

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

    /** Telefone **/
    FIND FIRST craptfc WHERE craptfc.cdcooper = par_cdcooper AND 
                             craptfc.nrdconta = par_nrdctato AND 
                             craptfc.idseqttl = 1            NO-LOCK NO-ERROR.
                                  
    /** E-Mail **/
    FIND crapcem WHERE crapcem.cdcooper = par_cdcooper AND 
                       crapcem.nrdconta = par_nrdctato AND 
                       crapcem.idseqttl = 1            AND 
                       crapcem.cddemail = 1            NO-LOCK NO-ERROR.

    CREATE tt-contato-jur.
    ASSIGN tt-contato-jur.nrdctato = par_nrdctato
           tt-contato-jur.nmdavali = crapass.nmprimtl
           tt-contato-jur.nrcepend = crapenc.nrcepend
           tt-contato-jur.dsendere = crapenc.dsendere
           tt-contato-jur.nrendere = crapenc.nrendere
           tt-contato-jur.complend = crapenc.complend
           tt-contato-jur.nmbairro = crapenc.nmbairro
           tt-contato-jur.nmcidade = crapenc.nmcidade
           tt-contato-jur.cdufende = crapenc.cdufende
           tt-contato-jur.nrcxapst = crapenc.nrcxapst
           tt-contato-jur.nrtelefo = IF  AVAILABLE craptfc  THEN
                                         STRING(craptfc.nrtelefo)
                                     ELSE 
                                         ""
           tt-contato-jur.dsdemail = crapcem.dsdemail WHEN AVAIL crapcem.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**                  Procedure para validar dados do contato                 **/
/******************************************************************************/
PROCEDURE validar-dados-contato:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdavali AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmextemp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddbanco AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdageban AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrtelefo AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdemail AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepend AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsendere AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Validar dados do contato"
           aux_cdcritic = 0
           aux_dscritic = "".

    DO WHILE TRUE:

        IF  par_nrdctato = 0  THEN
            DO:
                IF  par_nmdavali = ""  THEN
                    DO:
                        ASSIGN aux_dscritic = "Informe o nome do contato.".
                        LEAVE.
                    END. 

                IF  par_cddopcao = "I"  THEN
                    DO: 
                        FIND crapavt WHERE crapavt.cdcooper = par_cdcooper AND
                                           crapavt.nrdconta = par_nrdconta AND
                                           crapavt.tpctrato = 5            AND
                                           crapavt.nmdavali = par_nmdavali 
                                           NO-LOCK NO-ERROR.

                        IF  AVAILABLE crapavt  THEN 
                            DO:
                                ASSIGN aux_dscritic = "Contato ja cadastrado.".
                                LEAVE.
                            END.
                    END.

                IF  par_cddbanco > 0  THEN 
                    DO:
                        FIND crapban WHERE crapban.cdbccxlt = par_cddbanco 
                                           NO-LOCK NO-ERROR.
        
                        IF  NOT AVAILABLE crapban  THEN 
                            DO:
                                ASSIGN aux_cdcritic = 57.
                                LEAVE.
                            END.
                    END.

                IF  par_cddbanco > 0  AND
                    par_cdageban = 0  THEN
                    DO:
                        ASSIGN aux_dscritic = "Agencia deve ser informada.".
                        LEAVE.
                    END.
                                       
                IF  par_cdageban > 0  AND
                    par_cddbanco = 0  THEN
                    DO:
                        ASSIGN aux_dscritic = "Banco deve ser informado.".
                        LEAVE.
                    END.
                
                IF  par_nmextemp = ""  AND
                    par_cddbanco = 0   THEN
                    DO:
                        ASSIGN aux_dscritic = "Empresa ou banco devem ser " +
                                              "informados.".
                        LEAVE.
                    END.

                IF  par_nrcepend <> 0 THEN 
                    DO: 
                        IF  NOT CAN-FIND(FIRST crapdne 
                                     WHERE crapdne.nrceplog = par_nrcepend) THEN
                            DO:
                                ASSIGN aux_dscritic = "CEP nao cadastrado.".
                                LEAVE.
                            END.

                        IF  NOT CAN-FIND(FIRST crapdne
                                         WHERE crapdne.nrceplog = par_nrcepend  
                                           AND (TRIM(par_dsendere) MATCHES 
                                               ("*" + TRIM(crapdne.nmextlog) + "*")
                                            OR TRIM(par_dsendere) MATCHES
                                               ("*" + TRIM(crapdne.nmreslog) + "*"))) 
                            THEN
                            DO:
                            
                                ASSIGN aux_dscritic = 
                                               "Endereco nao pertence ao CEP.".
                                LEAVE.
                            END.
                    END.

                IF  par_nrtelefo = ""  AND
                    par_dsdemail = ""  THEN
                    DO:
                        ASSIGN aux_dscritic = "Telefone ou e-mail devem ser " +
                                              "informados.".
                        LEAVE.   
                    END.
                       
                IF  par_dsdemail <> ""              AND
                    NOT par_dsdemail MATCHES "*@*"  THEN
                    DO:
                        ASSIGN aux_dscritic = "E-mail invalido.".
                        LEAVE.
                    END.
            END.
        ELSE
            DO:
                IF  par_cddopcao = "I"  THEN
                    DO: 
                        IF  par_nrdctato = par_nrdconta  THEN
                            DO:
                                ASSIGN aux_cdcritic = 121.
                                LEAVE.
                            END.

                        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                           crapass.nrdconta = par_nrdctato
                                           NO-LOCK NO-ERROR.
                                          
                        IF  NOT AVAILABLE crapass  THEN
                            DO:
                                ASSIGN aux_cdcritic = 9.
                                LEAVE.
                            END.
                        
                        FIND FIRST crapavt WHERE 
                                   crapavt.cdcooper = par_cdcooper AND 
                                   crapavt.nrdconta = par_nrdconta AND 
                                   crapavt.tpctrato = 5            AND 
                                   crapavt.nrdctato = par_nrdctato 
                                   NO-LOCK NO-ERROR.

                        IF  AVAILABLE crapavt  THEN 
                            DO:
                                ASSIGN aux_dscritic = "Contato ja cadastrado.".
                                LEAVE.
                            END.
                    END.
            END.

        LEAVE.
        
    END. /** Fim do DO WHILE TRUE **/
    
    IF  aux_cdcritic <> 0   OR 
        aux_dscritic <> ""  THEN
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


/******************************************************************************/
/**               Procedure para gerenciar contato do associado              **/
/******************************************************************************/
PROCEDURE gerenciar-contato:

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
    DEF  INPUT PARAM par_nrdctato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdavali AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmextemp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddbanco AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdageban AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsproftl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsendere AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrendere AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complend AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepend AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxapst AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmbairro AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidade AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufende AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrtelefo AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdemail AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_nrsequen AS INTE                                    NO-UNDO.

    DEF VAR h-b1wgen0168 AS HANDLE                                  NO-UNDO.

    DEF BUFFER crabavt FOR crapavt.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapavt-old.
    EMPTY TEMP-TABLE tt-crapavt-new.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = (IF  par_cddopcao = "A"  THEN
                               "Alterar"
                           ELSE
                           IF  par_cddopcao = "E"  THEN
                               "Excluir"
                           ELSE
                               "Incluir") +
                          " contato para o associado"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.

    TRANSACAO:

    DO TRANSACTION ON ERROR  UNDO TRANSACAO, LEAVE TRANSACAO
                   ON ENDKEY UNDO TRANSACAO, LEAVE TRANSACAO:

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta 
                           NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapass  THEN
            DO:
                ASSIGN aux_cdcritic = 9
                       aux_dscritic = "".

                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        IF  par_cddopcao = "I"  THEN
            DO:
                /** Obtem o sequencial para cadastro **/
                DO aux_contador = 1 TO 10:
                                          
                    FIND LAST crabavt WHERE crabavt.cdcooper = par_cdcooper AND 
                                            crabavt.nrdconta = par_nrdconta AND 
                                            crabavt.tpctrato = 5 
                                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                    IF  NOT AVAILABLE crabavt  THEN
                        DO:
                            IF  LOCKED crabavt  THEN
                                DO:
                                    IF  aux_contador = 10  THEN
                                        DO:
                                            FIND LAST crabavt WHERE 
                                             crabavt.cdcooper = par_cdcooper AND 
                                             crabavt.nrdconta = par_nrdconta AND 
                                             crabavt.tpctrato = 5
                                             NO-LOCK NO-ERROR.
                                            
                                            RUN critica-lock 
                                               (INPUT RECID(crapavt),
                                                INPUT "banco",
                                                INPUT "crapavt",
                                                INPUT par_idorigem).
                                        END.
                                    ELSE
                                        DO:
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT.
                                        END.    
                                END.
                            ELSE
                                ASSIGN aux_nrsequen = 1.
                        END.
                    ELSE
                        ASSIGN aux_nrsequen = crabavt.nrctremp + 1.
        
                    LEAVE.
        
                END. /** Fim do DO ... TO **/
        
                IF  aux_dscritic <> ""  THEN
                    UNDO TRANSACAO, LEAVE TRANSACAO.
        
                CREATE crapavt.
                ASSIGN crapavt.cdcooper = par_cdcooper
                       crapavt.tpctrato = 5 
                       crapavt.nrctremp = aux_nrsequen
                       crapavt.nrdconta = par_nrdconta
                       crapavt.nrdctato = par_nrdctato.
                    
                /** Se nao for associado, armazena os dados **/
                IF  par_nrdctato = 0   THEN
                    ASSIGN crapavt.nmdavali    = CAPS(par_nmdavali) 
                           crapavt.nmextemp    = CAPS(par_nmextemp)
                           crapavt.cddbanco    = par_cddbanco 
                           crapavt.cdagenci    = par_cdageban 
                           crapavt.dsproftl    = CAPS(par_dsproftl)
                           crapavt.dsendres[1] = CAPS(par_dsendere)
                           crapavt.nrendere    = par_nrendere 
                           crapavt.complend    = CAPS(par_complend)
                           crapavt.nrcepend    = par_nrcepend 
                           crapavt.nrcxapst    = par_nrcxapst
                           crapavt.nmbairro    = CAPS(par_nmbairro)
                           crapavt.nmcidade    = CAPS(par_nmcidade) 
                           crapavt.cdufresd    = par_cdufende
                           crapavt.nrtelefo    = par_nrtelefo
                           crapavt.dsdemail    = LC(par_dsdemail).

                VALIDATE crapavt.

                CREATE tt-crapavt-old.
                CREATE tt-crapavt-new.
                BUFFER-COPY crapavt TO tt-crapavt-new.
            END.
        ELSE
            DO:
                DO aux_contador = 1 TO 10:

                    FIND crapavt WHERE ROWID(crapavt) = par_nrdrowid 
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                    IF  NOT AVAILABLE crapavt  THEN
                        DO:
                            IF  LOCKED crapavt  THEN
                                DO:
                                    IF  aux_contador = 10  THEN
                                        DO:
                                            FIND crapavt WHERE 
                                                 ROWID(crapavt) = par_nrdrowid 
                                                 NO-LOCK NO-ERROR.
                                            
                                            RUN critica-lock 
                                               (INPUT RECID(crapavt),
                                                INPUT "banco",
                                                INPUT "crapavt",
                                                INPUT par_idorigem).
                                        END.
                                    ELSE
                                        DO:
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT.
                                        END.     
                                END.
                            ELSE
                                ASSIGN aux_dscritic = "Registro de contato " +
                                                      "nao encontrado.".
                        END.
        
                    LEAVE.
        
                END. /** Fim do DO ... TO **/
        
                IF  aux_dscritic <> ""  THEN
                    UNDO TRANSACAO, LEAVE TRANSACAO.

                { sistema/generico/includes/b1wgenalog.i }

                CREATE tt-crapavt-new.
                CREATE tt-crapavt-old.
                BUFFER-COPY crapavt TO tt-crapavt-old.
                
                IF  par_cddopcao= "E"  THEN
                    DO: 
                        { sistema/generico/includes/b1wgenllog.i }

                        DELETE crapavt.
                    END.
                ELSE
                IF  par_cddopcao = "A"  THEN
                    DO:
                        ASSIGN crapavt.nmdavali    = CAPS(par_nmdavali) 
                               crapavt.nmextemp    = CAPS(par_nmextemp)
                               crapavt.cddbanco    = par_cddbanco 
                               crapavt.cdagenci    = par_cdageban 
                               crapavt.dsproftl    = CAPS(par_dsproftl)
                               crapavt.dsendres[1] = CAPS(par_dsendere)
                               crapavt.nrendere    = par_nrendere 
                               crapavt.complend    = CAPS(par_complend)
                               crapavt.nrcepend    = par_nrcepend 
                               crapavt.nrcxapst    = par_nrcxapst
                               crapavt.nmbairro    = CAPS(par_nmbairro)
                               crapavt.nmcidade    = CAPS(par_nmcidade) 
                               crapavt.cdufresd    = par_cdufende
                               crapavt.nrtelefo    = par_nrtelefo
                               crapavt.dsdemail    = LC(par_dsdemail).

                        BUFFER-COPY crapavt TO tt-crapavt-new.

                        { sistema/generico/includes/b1wgenllog.i }
                    END.
            END.

        /* INICIO - Atualizar os dados da tabela crapcyb (CYBER) */
        IF NOT VALID-HANDLE(h-b1wgen0168) THEN
           RUN sistema/generico/procedures/b1wgen0168.p
               PERSISTENT SET h-b1wgen0168.
                 
        EMPTY TEMP-TABLE tt-crapcyb.

        CREATE tt-crapcyb.
        ASSIGN tt-crapcyb.cdcooper = par_cdcooper
               tt-crapcyb.nrdconta = par_nrdconta
               tt-crapcyb.dtmancad = par_dtmvtolt.

        RUN atualiza_data_manutencao_cadastro
            IN h-b1wgen0168(INPUT TABLE tt-crapcyb,
                            OUTPUT aux_cdcritic,
                            OUTPUT aux_dscritic).

        IF RETURN-VALUE <> "OK" THEN
           UNDO TRANSACAO, LEAVE TRANSACAO.
        /* FIM - Atualizar os dados da tabela crapcyb */

        IF  AVAILABLE crabavt  THEN
            FIND CURRENT crabavt NO-LOCK NO-ERROR.

        IF  AVAILABLE crapavt  THEN
            FIND CURRENT crapavt NO-LOCK NO-ERROR.

        ASSIGN aux_flgtrans = TRUE.

    END. /** Fim do DO TRANSACTION - TRANSACAO **/

    IF VALID-HANDLE(h-b1wgen0168) THEN
       DELETE PROCEDURE(h-b1wgen0168).

    /** Verifica se transacao foi executada com sucesso **/
    IF  NOT aux_flgtrans  THEN
        DO:
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
               (aux_cdcritic = 0                    AND 
                aux_dscritic = "")                  THEN
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Nao foi possivel " +
                                     (IF  par_cddopcao = "A"  THEN
                                          "alterar"
                                      ELSE
                                      IF  par_cddopcao = "E"  THEN
                                          "excluir"
                                      ELSE
                                          "incluir") +
                                      " excluir o contato.".
            
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
                                INPUT BUFFER tt-crapavt-old:HANDLE,
                                INPUT BUFFER tt-crapavt-new:HANDLE).

    RETURN "OK".

END PROCEDURE.


/*............................ PROCEDURES INTERNAS ...........................*/


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


/*............................................................................*/
