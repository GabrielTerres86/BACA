/*..............................................................................

    Programa  : b1wgen0037.p
    Autor     : David
    Data      : Janeiro/2009                  Ultima Atualizacao:25/05/2017
    
    Dados referentes ao programa:

    Objetivo  : BO referente ao modulo de informativo da Conta On-Line.
                Baseado nos fontes wcrm0006*.html

    Alteracoes: 04/10/2010 - Ordenar historico por envio decrescente (David).
                
                06/12/2013 - Incluida validacao para permitir a inclusao de 
                             informativos somente se o cooperado possuir a 
                             senha de tele-atendimento/URA. (Reinert)

                20/12/2013 - Adicionado validate para tabela crapcra (Tiago).

				25/05/2017 - Removi das procedures obtem-grupos-informativos e 
							 obtem-informativos o carregamento de opcoes 
							 relacionadas ao extrado de conta. 
							 (SD 678836 - Carlos Rafael Tanholi)
..............................................................................*/

{ sistema/generico/includes/b1wgen0037tt.i }
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
/**           Procedure para obter lista de informativos recebidos           **/
/******************************************************************************/
PROCEDURE obtem-lista-recebimento: 

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
 
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-informativos.

    DEF VAR aux_cdgrprel AS INTE                                    NO-UNDO.
        
    DEF VAR aux_nmrelato AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsrelato AS CHAR                                    NO-UNDO.
     
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-informativos.
 
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Consultar Informativos da Conta".

    FOR EACH crapcra WHERE crapcra.cdcooper = par_cdcooper AND
                           crapcra.nrdconta = par_nrdconta AND
                           crapcra.idseqttl = par_idseqttl NO-LOCK
                           BY crapcra.cdprogra BY crapcra.cdrelato:
            
        CREATE tt-informativos.
        ASSIGN tt-informativos.cdprogra = crapcra.cdprogra
               tt-informativos.cdrelato = crapcra.cdrelato
               tt-informativos.cdfenvio = crapcra.cddfrenv
               tt-informativos.cdperiod = crapcra.cdperiod
               tt-informativos.nrdrowid = ROWID(crapcra).
                            
        FIND craptab WHERE craptab.cdcooper = 0                AND
                           craptab.nmsistem = "CRED"           AND
                           craptab.tptabela = "USUARI"         AND
                           craptab.cdempres = 11               AND
                           craptab.cdacesso = "FORENVINFO"     AND
                           craptab.tpregist = crapcra.cddfrenv NO-LOCK NO-ERROR.
                                        
        IF  AVAILABLE craptab  THEN
            DO:
                IF  ENTRY(2,craptab.dstextab,",") = "crapcem"  THEN
                    DO:
                        FIND crapcem WHERE 
                             crapcem.cdcooper = crapcra.cdcooper  AND
                             crapcem.nrdconta = crapcra.nrdconta  AND
                             crapcem.idseqttl = crapcra.idseqttl  AND
                             crapcem.cddemail = crapcra.cdseqinc  
                             NO-LOCK NO-ERROR.
                                
                        IF  AVAILABLE crapcem  THEN
                            ASSIGN tt-informativos.dsrecebe = crapcem.dsdemail
                                   tt-informativos.endcoope = crapcem.dsdemail.
                    END.
                ELSE
                IF  ENTRY(2,craptab.dstextab,",") = "craptfc"  THEN
                    DO:
                        FIND craptfc WHERE 
                             craptfc.cdcooper = crapcra.cdcooper  AND
                             craptfc.nrdconta = crapcra.nrdconta  AND
                             craptfc.idseqttl = crapcra.idseqttl  AND
                             craptfc.cdseqtfc = crapcra.cdseqinc  
                             NO-LOCK NO-ERROR.
                                                         
                        IF  AVAILABLE craptfc  THEN
                            ASSIGN tt-informativos.dsrecebe = "(" + 
                                                  STRING(craptfc.nrdddtfc) + 
                                                  ") " + 
                                                  STRING(craptfc.nrtelefo) 
                                   tt-informativos.endcoope = "(" + 
                                                  STRING(craptfc.nrdddtfc) + 
                                                  ") " + 
                                                  STRING(craptfc.nrtelefo).
                    END.
                ELSE
                IF  ENTRY(2,craptab.dstextab,",") = "crapenc"  THEN
                    DO:
                        FIND crapenc WHERE 
                             crapenc.cdcooper = crapcra.cdcooper  AND
                             crapenc.nrdconta = crapcra.nrdconta  AND
                             crapenc.idseqttl = crapcra.idseqttl  AND
                             crapenc.cdseqinc = crapcra.cdseqinc
                             NO-LOCK NO-ERROR.
                                                                             
                        IF  AVAILABLE crapenc  THEN
                            ASSIGN tt-informativos.dsrecebe = crapenc.dsendere
                                   tt-informativos.endcoope = crapenc.dsendere +
                                                  " - n: " +
                                                  STRING(crapenc.nrendere) + 
                                                 (IF  par_idorigem = 3  THEN
                                                      "&lt;BR&gt;" 
                                                  ELSE      
                                                      " - ") + 
                                                  crapenc.complend + 
                                                  " - " + crapenc.nmbairro + 
                                                  " - " + crapenc.nmcidade + 
                                                  " - "  +  crapenc.cdufend + 
                                                  " - " + 
                                                  STRING(crapenc.nrcepend).
                    END.
            END.
             
        /** Descricao do informativo **/
        RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT 
            SET h-b1wgen9999.
                          
        IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Handle invalido para BO b1wgen9999.".
               
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
            
        RUN p-conectagener IN h-b1wgen9999.

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                DELETE PROCEDURE h-b1wgen9999.
                
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Nao foi possivel efetuar conexao com " +
                                      "o banco generico.".
               
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
                 
        RUN sistema/generico/procedures/b1wgen0037a.p (INPUT crapcra.cdprogra,
                                                       INPUT crapcra.cdrelato,
                                                      OUTPUT aux_nmrelato,
                                                      OUTPUT aux_dsrelato,
                                                      OUTPUT aux_cdgrprel,
                                                      OUTPUT aux_dscritic).
               
        IF  aux_dscritic <> ""  THEN
            DO:
                DELETE PROCEDURE h-b1wgen9999.
                
                ASSIGN aux_cdcritic = 0.
               
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
                             
        RUN p-desconectagener IN h-b1wgen9999.

        DELETE PROCEDURE h-b1wgen9999.

        ASSIGN tt-informativos.nmrelato = aux_nmrelato.
                                            
        FIND craptab WHERE craptab.cdcooper = 0            AND
                           craptab.nmsistem = "CRED"       AND
                           craptab.tptabela = "USUARI"     AND
                           craptab.cdempres = 11           AND
                           craptab.cdacesso = "GRPINFORMA" AND
                           craptab.tpregist = aux_cdgrprel NO-LOCK NO-ERROR.
        
        IF  AVAILABLE craptab  THEN
            ASSIGN tt-informativos.cdgrprel = craptab.tpregist
                   tt-informativos.grupoinf = ENTRY(1,craptab.dstextab,";").
                             
        FIND craptab WHERE craptab.cdcooper = 0              AND
                           craptab.nmsistem = "CRED"         AND
                           craptab.tptabela = "USUARI"       AND
                           craptab.cdempres = 11             AND
                           craptab.cdacesso = "FORENVINFO"   AND
                           craptab.tpregist = crapcra.cddfrenv 
                           NO-LOCK NO-ERROR.
                                                
        IF  AVAILABLE craptab  THEN
            ASSIGN tt-informativos.dsfenvio = ENTRY(1,craptab.dstextab,",").
    
    END. /** Fim do FOR EACH crapcra **/
    
    RETURN "OK".
                                                                             
END PROCEDURE.


/******************************************************************************/
/**       Procedure para retornar dados para alteracao de informativo        **/
/******************************************************************************/
PROCEDURE obtem-dados-alteracao: 

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_nmrelato AS CHAR                           NO-UNDO.
 
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-periodo-envio.
    DEF OUTPUT PARAM TABLE FOR tt-destino-envio.

    DEF VAR aux_dsrelato AS CHAR                                    NO-UNDO.
    
    DEF VAR aux_cdgrprel AS INTE                                    NO-UNDO.
    
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-periodo-envio.
    EMPTY TEMP-TABLE tt-destino-envio.
 
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter Dados para Alteracao de Informativo".

    FIND crapcra WHERE ROWID(crapcra) = TO-ROWID(par_nrdrowid) 
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcra  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Informativo para cooperado nao cadastrado.".
               
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
        
    /** Descricao do informativo **/
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
                          
    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen9999.".
              
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
            
    RUN p-conectagener IN h-b1wgen9999.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            DELETE PROCEDURE h-b1wgen9999.
            
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Nao foi possivel efetuar conexao com " +
                                  "o banco generico.".
               
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
                 
    RUN sistema/generico/procedures/b1wgen0037a.p (INPUT crapcra.cdprogra,
                                                   INPUT crapcra.cdrelato,
                                                  OUTPUT par_nmrelato,
                                                  OUTPUT aux_dsrelato,
                                                  OUTPUT aux_cdgrprel,
                                                  OUTPUT aux_dscritic).
               
    IF  aux_dscritic <> ""  THEN
        DO:
            DELETE PROCEDURE h-b1wgen9999.
            
            ASSIGN aux_cdcritic = 0.
               
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
                             
    RUN p-desconectagener IN h-b1wgen9999.

    DELETE PROCEDURE h-b1wgen9999.

    RUN obtem-dados-envio (INPUT par_cdcooper,
                           INPUT par_nrdconta,
                           INPUT par_idseqttl,
                           INPUT crapcra.cdrelato,
                           INPUT crapcra.cddfrenv,
                           INPUT crapcra.cdperiod,
                           INPUT crapcra.cdseqinc,
                          OUTPUT TABLE tt-periodo-envio,
                          OUTPUT TABLE tt-destino-envio).
                          
    FIND FIRST tt-periodo-envio NO-LOCK NO-ERROR.
    FIND FIRST tt-destino-envio NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE tt-periodo-envio  OR
        NOT AVAILABLE tt-destino-envio  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Dados insuficientes para alteracao do " +
                                  "informativo.".
               
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


/******************************************************************************/
/**             Procedure para alteracao de informativo da conta             **/
/******************************************************************************/
PROCEDURE alterar-informativo: 

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdperiod AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdseqinc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
 
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_cdrelato AS INTE                                    NO-UNDO.
    DEF VAR aux_cdgrprel AS INTE                                    NO-UNDO.
    DEF VAR aux_cddfrenv AS INTE                                    NO-UNDO.
    DEF VAR ant_cdperiod AS INTE                                    NO-UNDO.
    DEF VAR ant_cdseqinc AS INTE                                    NO-UNDO.
    
    DEF VAR aux_nmrelato AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsrelato AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsperiod AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdcanal AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsendere AS CHAR                                    NO-UNDO.
    DEF VAR ant_dsperiod AS CHAR                                    NO-UNDO.
    DEF VAR ant_dsdcanal AS CHAR                                    NO-UNDO.
    DEF VAR ant_dsendere AS CHAR                                    NO-UNDO.

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    
    DEF BUFFER crabcra FOR crapcra.
                                  
    EMPTY TEMP-TABLE tt-erro.
 
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Alteracao de Informativo"
           aux_flgtrans = FALSE.

    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
    
        DO aux_contador = 1 TO 10:
        
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".
                   
            FIND crapcra WHERE ROWID(crapcra) = TO-ROWID(par_nrdrowid) 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapcra  THEN
                DO:
                    IF  LOCKED crapcra  THEN
                        DO:
                            aux_dscritic = "Registro do informativo esta " +
                                           "sendo alterado. Tente novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE    
                        aux_dscritic = "Informativo para cooperado nao " +
                                       "cadastrado.".
                END.
                
            LEAVE.
                   
        END. /** Fim do DO ... TO **/
                     
        IF  aux_dscritic <> ""  THEN
            UNDO TRANSACAO, LEAVE TRANSACAO.

        ASSIGN aux_cdrelato = crapcra.cdrelato
               aux_cddfrenv = crapcra.cddfrenv.

        RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT 
            SET h-b1wgen9999.
                          
        IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Handle invalido para BO " +
                                      "b1wgen9999.".
               
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
            
        RUN p-conectagener IN h-b1wgen9999.

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                DELETE PROCEDURE h-b1wgen9999.
                
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Nao foi possivel efetuar conexao com " +
                                      "o banco generico.".
               
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
                 
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "".
               
        RUN sistema/generico/procedures/b1wgen0037a.p (INPUT crapcra.cdprogra,
                                                       INPUT crapcra.cdrelato,
                                                      OUTPUT aux_nmrelato,
                                                      OUTPUT aux_dsrelato,
                                                      OUTPUT aux_cdgrprel,
                                                      OUTPUT aux_dscritic).
               
        IF  aux_dscritic <> ""  THEN
            DO:
                DELETE PROCEDURE h-b1wgen9999.
                
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
                                     
        RUN p-desconectagener IN h-b1wgen9999.

        DELETE PROCEDURE h-b1wgen9999.
        
        FIND craptab WHERE craptab.cdcooper = 0                AND
                           craptab.nmsistem = "CRED"           AND
                           craptab.tptabela = "USUARI"         AND
                           craptab.cdempres = 11               AND
                           craptab.cdacesso = "PERIODICID"     AND
                           craptab.tpregist = crapcra.cdperiod 
                           NO-LOCK NO-ERROR.
         
        IF  AVAILABLE craptab  THEN
            ASSIGN ant_dsperiod = STRING(craptab.tpregist) + "-" +
                                  craptab.dstextab.
            
        FIND craptab WHERE craptab.cdcooper = 0                AND
                           craptab.nmsistem = "CRED"           AND
                           craptab.tptabela = "USUARI"         AND
                           craptab.cdempres = 11               AND
                           craptab.cdacesso = "FORENVINFO"     AND
                           craptab.tpregist = crapcra.cddfrenv NO-LOCK NO-ERROR.
                                                                
        IF  AVAILABLE craptab  THEN
            DO:
                IF  ENTRY(2,craptab.dstextab,",") = "crapcem"  THEN
                    DO:
                        FIND crapcem WHERE 
                             crapcem.cdcooper = crapcra.cdcooper AND
                             crapcem.nrdconta = crapcra.nrdconta AND
                             crapcem.idseqttl = crapcra.idseqttl AND
                             crapcem.cddemail = crapcra.cdseqinc 
                             NO-LOCK NO-ERROR.
                                             
                        IF  AVAILABLE crapcem  THEN
                            ant_dsendere = STRING(crapcem.cddemail) + "-" +
                                           crapcem.dsdemail.
                    END.
                ELSE
                IF  ENTRY(2,craptab.dstextab,",") = "craptfc"  THEN
                    DO:
                        FIND craptfc WHERE 
                             craptfc.cdcooper = crapcra.cdcooper AND
                             craptfc.nrdconta = crapcra.nrdconta AND
                             craptfc.idseqttl = crapcra.idseqttl AND
                             craptfc.cdseqtfc = crapcra.cdseqinc 
                             NO-LOCK NO-ERROR.
                                             
                        IF  AVAILABLE craptfc  THEN
                            ant_dsendere = STRING(craptfc.cdseqtfc) + "-" + 
                                           STRING(craptfc.nrtelefo).
                    END.
                ELSE
                IF  ENTRY(2,craptab.dstextab,",") = "crapenc"  THEN
                    DO:
                        FIND crapenc WHERE 
                             crapenc.cdcooper = crapcra.cdcooper AND
                             crapenc.nrdconta = crapcra.nrdconta AND
                             crapenc.idseqttl = crapcra.idseqttl AND
                             crapenc.cdseqinc = crapcra.cdseqinc
                             NO-LOCK NO-ERROR.

                        IF  AVAILABLE crapenc  THEN
                            ant_dsendere = STRING(crapenc.cdseqinc) + "-" + 
                                           crapenc.dsendere.
                    END.                
            END.             
            
        ASSIGN ant_cdperiod = crapcra.cdperiod
               ant_cdseqinc = crapcra.cdseqinc.
                            
        IF  crapcra.cdseqinc <> par_cdseqinc  THEN
            DO: 
                FIND crabcra WHERE crabcra.cdcooper = crapcra.cdcooper AND  
                                   crabcra.nrdconta = crapcra.nrdconta AND
                                   crabcra.idseqttl = crapcra.idseqttl AND
                                   crabcra.cdrelato = crapcra.cdrelato AND
                                   crabcra.cdprogra = crapcra.cdprogra AND
                                   crabcra.cddfrenv = crapcra.cddfrenv AND
                                   crabcra.cdseqinc = par_cdseqinc     AND
                                   crabcra.cdselimp = crapcra.cdselimp
                                   NO-LOCK NO-ERROR.
                                         
                IF  AVAILABLE crabcra  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Local de Recebimento ja " +
                                              "cadastrado para este " +
                                              "informativo.".
                                                     
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.
            END.

        ASSIGN crapcra.cdseqinc = par_cdseqinc
               crapcra.cdperiod = par_cdperiod
               aux_flgtrans     = TRUE.
    
    END. /** Fim do DO TRANSACTION - TRANSACAO **/
                              
    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel concluir a requisicao.".
               
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

    IF  par_flgerlog                   AND 
       (ant_cdperiod <> par_cdperiod   OR
        ant_cdseqinc <> par_cdseqinc)  THEN
        DO:
            ASSIGN aux_dstransa = "Alteracao de Informativo: " + 
                                  STRING(aux_cdrelato) + "-" + aux_nmrelato.
                          
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
                
            IF  ant_cdperiod <> par_cdperiod  THEN
                DO:
                    FIND craptab WHERE craptab.cdcooper = 0            AND
                                       craptab.nmsistem = "CRED"       AND
                                       craptab.tptabela = "USUARI"     AND
                                       craptab.cdempres = 11           AND
                                       craptab.cdacesso = "PERIODICID" AND
                                       craptab.tpregist = par_cdperiod 
                                       NO-LOCK NO-ERROR.
                                                                               
                    IF  AVAILABLE craptab  THEN
                        aux_dsperiod = STRING(craptab.tpregist) + "-" + 
                                       craptab.dstextab.
                                                                               
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Periodo",
                                             INPUT ant_dsperiod,
                                             INPUT aux_dsperiod).
                END.
            ELSE
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "Periodo",
                                         INPUT "",
                                         INPUT ant_dsperiod).
                                                                               
            FIND craptab WHERE craptab.cdcooper = 0            AND
                               craptab.nmsistem = "CRED"       AND
                               craptab.tptabela = "USUARI"     AND
                               craptab.cdempres = 11           AND
                               craptab.cdacesso = "FORENVINFO" AND
                               craptab.tpregist = aux_cddfrenv NO-LOCK NO-ERROR.
               
            IF  AVAILABLE craptab  THEN
                aux_dsdcanal = STRING(craptab.tpregist) + "-" +
                               ENTRY(1,craptab.dstextab,",").
                                           
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Canal",
                                     INPUT "",
                                     INPUT aux_dsdcanal).
                                                                               
            IF  ant_cdseqinc <> par_cdseqinc AND AVAILABLE craptab  THEN
                DO:
                    IF  ENTRY(2,craptab.dstextab,",") = "crapcem"  THEN
                        DO:
                            FIND crapcem WHERE 
                                 crapcem.cdcooper = par_cdcooper AND
                                 crapcem.nrdconta = par_nrdconta AND
                                 crapcem.idseqttl = par_idseqttl AND
                                 crapcem.cddemail = par_cdseqinc  
                                 NO-LOCK NO-ERROR.
                                     
                            IF  AVAILABLE crapcem  THEN
                                aux_dsendere = STRING(crapcem.cddemail) +
                                               "-" + crapcem.dsdemail.
                        END.
                    ELSE
                    IF  ENTRY(2,craptab.dstextab,",") = "craptfc"  THEN
                        DO:
                            FIND craptfc WHERE 
                                 craptfc.cdcooper = par_cdcooper AND
                                 craptfc.nrdconta = par_nrdconta AND
                                 craptfc.idseqttl = par_idseqttl AND
                                 craptfc.cdseqtfc = par_cdseqinc  
                                 NO-LOCK NO-ERROR.
                                    
                            IF  AVAILABLE craptfc  THEN             
                                aux_dsendere = STRING(craptfc.cdseqtfc) +
                                               "-" + STRING(craptfc.nrtelefo).
                        END.
                    ELSE 
                    IF  ENTRY(2,craptab.dstextab,",") = "crapenc"  THEN
                        DO:
                            FIND crapenc WHERE 
                                 crapenc.cdcooper = par_cdcooper AND
                                 crapenc.nrdconta = par_nrdconta AND
                                 crapenc.idseqttl = par_idseqttl AND
                                 crapenc.cdseqinc = par_cdseqinc
                                 NO-LOCK NO-ERROR.
                                          
                            IF  AVAILABLE crapenc  THEN                        
                                aux_dsendere = STRING(crapenc.cdseqinc) +
                                                   "-" + crapenc.dsendere.
                        END.   
                                                                               
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Endereco",
                                             INPUT ant_dsendere,
                                             INPUT aux_dsendere).
                END.
            ELSE
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "Endereco",
                                         INPUT "",
                                         INPUT ant_dsendere).
        END.

    RETURN "OK".            

END PROCEDURE.


/******************************************************************************/
/**              Procedure para retornar grupos de informativos              **/
/******************************************************************************/
PROCEDURE obtem-grupos-informativos: 

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
 
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-grupo-informativo.

    DEF VAR aux_cdgrprel AS INTE                                    NO-UNDO.
    
    DEF VAR aux_nmrelato AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsrelato AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmgrprel AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsgrprel AS CHAR                                    NO-UNDO.
    DEF VAR aux_lsgrprel AS CHAR                                    NO-UNDO.

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-grupo-informativo.
 
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter Grupos de Informativos".

	/* busca grupos diferentes de extrato de conta corrente. SD 678836 */
    FOR EACH crapifc WHERE crapifc.cdcooper = par_cdcooper AND 
						   crapifc.cdrelato <> 171 AND 
						   crapifc.cdprogra <> 217 NO-LOCK
                           BREAK BY crapifc.cdprogra:
                                            
        IF  FIRST-OF(crapifc.cdprogra)  THEN
            DO:
                IF  CAN-DO(aux_lsgrprel,STRING(aux_cdgrprel))  THEN
                    NEXT.
                                
                aux_lsgrprel = aux_lsgrprel + STRING(aux_cdgrprel) + ",". 
                                             
                RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT 
                    SET h-b1wgen9999.
                          
                IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen9999.".

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
            
                RUN p-conectagener IN h-b1wgen9999.

                IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        DELETE PROCEDURE h-b1wgen9999.
                        
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Nao foi possivel efetuar " +
                                              "conexao com o banco generico.".

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
                 
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "".
               
                RUN sistema/generico/procedures/b1wgen0037a.p 
                                                      (INPUT crapifc.cdprogra,
                                                       INPUT crapifc.cdrelato,
                                                      OUTPUT aux_nmrelato,
                                                      OUTPUT aux_dsrelato,
                                                      OUTPUT aux_cdgrprel,
                                                      OUTPUT aux_dscritic).
          
                IF  aux_dscritic <> ""  THEN
                    DO:
                        DELETE PROCEDURE h-b1wgen9999.
                        
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
                             
                RUN p-desconectagener IN h-b1wgen9999.

                DELETE PROCEDURE h-b1wgen9999.
                
                FIND craptab WHERE craptab.cdcooper = 0            AND
                                   craptab.nmsistem = "CRED"       AND
                                   craptab.tptabela = "USUARI"     AND
                                   craptab.cdempres = 11           AND
                                   craptab.cdacesso = "GRPINFORMA" AND
                                   craptab.tpregist = aux_cdgrprel 
                                   NO-LOCK NO-ERROR.
                 
                IF  AVAILABLE craptab  THEN
                    DO:
                        ASSIGN aux_nmgrprel = ENTRY(1,craptab.dstextab,";")
                               aux_dsgrprel = ENTRY(2,craptab.dstextab,";").

                        IF  NUM-ENTRIES(craptab.dstextab,";") = 3  THEN
                            ASSIGN aux_dsgrprel = aux_dsgrprel + " " + 
                                                  ENTRY(3,craptab.dstextab,";").
                                                 
                        CREATE tt-grupo-informativo.
                        ASSIGN tt-grupo-informativo.cdgrprel = aux_cdgrprel
                               tt-grupo-informativo.nmgrprel = aux_nmgrprel
                               tt-grupo-informativo.dsgrprel = aux_dsgrprel.
                    END.                             
            END.
               
    END. /** Fim do FOR EACH crapifc **/

    FIND FIRST tt-grupo-informativo NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE tt-grupo-informativo  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Nao ha grupos de informativos cadastrados.".
                   
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


/******************************************************************************/
/**                   Procedure para retornar informativos                   **/
/******************************************************************************/
PROCEDURE obtem-informativos: 

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdgrprel AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
 
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-informativos.

    DEF VAR aux_cdgrprel AS INTE                                    NO-UNDO.
    
    DEF VAR aux_nmrelato AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsrelato AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmgrprel AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsgrprel AS CHAR                                    NO-UNDO.
    DEF VAR aux_lsgrprel AS CHAR                                    NO-UNDO.

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-informativos.
 
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter Informativos".

	/* busca grupos diferentes de extrato de conta corrente. SD 678836 */
    FOR EACH crapifc WHERE crapifc.cdcooper = par_cdcooper AND 
						   crapifc.cdrelato <> 171 AND 
						   crapifc.cdprogra <> 217 NO-LOCK
                           BREAK BY crapifc.cdrelato:
                        
        IF  crapifc.envcpttl = 1 AND par_idseqttl <> 1  THEN   
            NEXT.
                                                                                
        RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT 
            SET h-b1wgen9999.
                          
        IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Handle invalido para BO b1wgen9999.".

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
            
        RUN p-conectagener IN h-b1wgen9999.

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                DELETE PROCEDURE h-b1wgen9999.
                
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Nao foi possivel efetuar " +
                                      "conexao com o banco generico.".

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
                 
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "".
               
        RUN sistema/generico/procedures/b1wgen0037a.p (INPUT crapifc.cdprogra,
                                                       INPUT crapifc.cdrelato,
                                                      OUTPUT aux_nmrelato,
                                                      OUTPUT aux_dsrelato,
                                                      OUTPUT aux_cdgrprel,
                                                      OUTPUT aux_dscritic).
          
        IF  aux_dscritic <> ""  THEN
            DO:
                DELETE PROCEDURE h-b1wgen9999.
                
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
                             
        RUN p-desconectagener IN h-b1wgen9999.

        DELETE PROCEDURE h-b1wgen9999.    
        
        IF  FIRST-OF(crapifc.cdrelato)  THEN
            DO:
                IF  par_cdgrprel <> aux_cdgrprel  THEN
                    NEXT.

                CREATE tt-informativos.
                ASSIGN tt-informativos.cdprogra = crapifc.cdprogra
                       tt-informativos.cdrelato = crapifc.cdrelato
                       tt-informativos.nmrelato = aux_nmrelato
                       tt-informativos.dsrelato = aux_dsrelato
                       tt-informativos.cdgrprel = aux_cdgrprel.
            END.
               
    END. /** Fim do FOR EACH crapifc **/

    FIND FIRST tt-informativos NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE tt-informativos  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "O grupo selecionado nao possui informativo" +
                                  "cadastrado.".
                   
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


/******************************************************************************/
/**        Procedure para retornar canais para envio de informativos         **/
/******************************************************************************/
PROCEDURE obtem-canais-envio: 

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdrelato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
 
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-canais-envio.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-canais-envio.
 
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter Canais para Envio de Informativos".

    FOR EACH crapifc WHERE crapifc.cdcooper = par_cdcooper AND
                           crapifc.cdrelato = par_cdrelato NO-LOCK
                           BREAK BY crapifc.cddfrenv BY crapifc.cdperiod:
                                    
        IF  FIRST-OF(crapifc.cddfrenv)  THEN
            DO:
                FIND craptab WHERE craptab.cdcooper = 0                AND
                                   craptab.nmsistem = "CRED"           AND
                                   craptab.tptabela = "USUARI"         AND
                                   craptab.cdempres = 11               AND
                                   craptab.cdacesso = "FORENVINFO"     AND
                                   craptab.tpregist = crapifc.cddfrenv
                                   NO-LOCK NO-ERROR.
                                  
                IF  AVAILABLE craptab  THEN
                    DO:
                        CREATE tt-canais-envio.
                        ASSIGN tt-canais-envio.cdprogra = crapifc.cdprogra 
                               tt-canais-envio.cdrelato = par_cdrelato
                               tt-canais-envio.cddfrenv = craptab.tpregist
                               tt-canais-envio.dsdfrenv = ENTRY(1,
                                                          craptab.dstextab,",").
                    END.
            END.
            
    END. /** Fim do FOR EACH crapifc **/
        
    FIND FIRST tt-canais-envio NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE tt-canais-envio  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "O informativo selecionado nao possui " +
                                  "forma de envio cadastrada.".
                   
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


/******************************************************************************/
/**  Procedure para retornar periodos e destinos para envio de informativos  **/
/******************************************************************************/
PROCEDURE obtem-dados-envio-inclusao: 

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdrelato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddfrenv AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
 
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-periodo-envio.
    DEF OUTPUT PARAM TABLE FOR tt-destino-envio.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-periodo-envio.
    EMPTY TEMP-TABLE tt-destino-envio.
 
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter Dados para Envio de Informativos".

    RUN obtem-dados-envio (INPUT par_cdcooper,
                           INPUT par_nrdconta,
                           INPUT par_idseqttl,
                           INPUT par_cdrelato,
                           INPUT par_cddfrenv,
                           INPUT 0,
                           INPUT 0,
                          OUTPUT TABLE tt-periodo-envio,
                          OUTPUT TABLE tt-destino-envio).
                          
    FIND FIRST tt-periodo-envio NO-LOCK NO-ERROR.
    FIND FIRST tt-destino-envio NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE tt-periodo-envio  OR
        NOT AVAILABLE tt-destino-envio  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Dados de periodo e/ou envio nao " +
                                  "cadastrados.".
               
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


/******************************************************************************/
/**             Procedure para inclusao de informativo da conta              **/
/******************************************************************************/
PROCEDURE incluir-informativo: 

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdrelato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_lsdfrenv AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_lsperiod AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_lsseqinc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
 
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_cdgrprel AS INTE                                    NO-UNDO.
    DEF VAR aux_cddfrenv AS INTE                                    NO-UNDO.
    DEF VAR aux_cdperiod AS INTE                                    NO-UNDO.
    DEF VAR aux_cdseqinc AS INTE                                    NO-UNDO.
    
    DEF VAR aux_nmrelato AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsrelato AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsperiod AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdcanal AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsendere AS CHAR                                    NO-UNDO.

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    
    DEF BUFFER crabtab FOR craptab.
    
    EMPTY TEMP-TABLE tt-erro.
 
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Inclusao de Informativo"
           aux_flgtrans = FALSE.

    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
    
        IF  par_lsdfrenv = ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Escolha a Forma de Envio.".
                       
                UNDO TRANSACAO, LEAVE TRANSACAO.       
            END.
            
        DO aux_contador = 1 TO NUM-ENTRIES(par_lsdfrenv,"/"):

            ASSIGN aux_cddfrenv = INTE(ENTRY(aux_contador,par_lsdfrenv,"/")).
        
            FIND craptab WHERE craptab.cdcooper = 0            AND
                               craptab.nmsistem = "CRED"       AND
                               craptab.tptabela = "USUARI"     AND
                               craptab.cdempres = 11           AND
                               craptab.cdacesso = "FORENVINFO" AND
                               craptab.tpregist = aux_cddfrenv NO-LOCK NO-ERROR.
                               
            IF  NOT AVAILABLE craptab  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Forma de envio nao cadastrada.".
                           
                    UNDO TRANSACAO, LEAVE TRANSACAO.
                END.

            ASSIGN aux_cdperiod = INTE(ENTRY(aux_contador,par_lsperiod,"/"))
                   aux_cdseqinc = INTE(ENTRY(aux_contador,par_lsseqinc,"/"))
                   aux_dsdcanal = STRING(craptab.tpregist) + " - " +
                                  craptab.dstextab.
                                   
            IF  aux_cdperiod <= 0  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Selecione o Periodo de recebimento.".
                           
                    UNDO TRANSACAO, LEAVE TRANSACAO.
                END.
                
            FIND crabtab WHERE crabtab.cdcooper = 0            AND
                               crabtab.nmsistem = "CRED"       AND
                               crabtab.tptabela = "USUARI"     AND
                               crabtab.cdempres = 11           AND
                               crabtab.cdacesso = "PERIODICID" AND
                               crabtab.tpregist = aux_cdperiod NO-LOCK NO-ERROR.
         
            IF  NOT AVAILABLE crabtab  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Periodo de recebimento nao " +
                                          "cadastrado.".
               
                    UNDO TRANSACAO, LEAVE TRANSACAO.
                END.
            
            ASSIGN aux_dsperiod = STRING(crabtab.tpregist) + " - " +
                                  crabtab.dstextab.
                                  
            IF  aux_cdseqinc <= 0  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Selecione o Endereco para envio.".
                           
                    UNDO TRANSACAO, LEAVE TRANSACAO. 
                END.    

            IF  ENTRY(2,craptab.dstextab,",") = "crapcem"  THEN
                DO:
                    FIND crapcem WHERE crapcem.cdcooper = par_cdcooper AND
                                       crapcem.nrdconta = par_nrdconta AND
                                       crapcem.idseqttl = par_idseqttl AND
                                       crapcem.cddemail = aux_cdseqinc 
                                       NO-LOCK NO-ERROR.
                                             
                    IF  NOT AVAILABLE crapcem  THEN
                        DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Endereco para envio nao " +
                                                  "cadastrado.".
                           
                            UNDO TRANSACAO, LEAVE TRANSACAO.
                        END.
                        
                    aux_dsendere = STRING(crapcem.cddemail) + " - " +
                                   crapcem.dsdemail.
                END.
            ELSE
            IF  ENTRY(2,craptab.dstextab,",") = "craptfc"  THEN
                DO:
                    FIND craptfc WHERE craptfc.cdcooper = par_cdcooper AND
                                       craptfc.nrdconta = par_nrdconta AND
                                       craptfc.idseqttl = par_idseqttl AND
                                       craptfc.cdseqtfc = aux_cdseqinc 
                                       NO-LOCK NO-ERROR.
                                             
                    IF  NOT AVAILABLE craptfc  THEN
                        DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Endereco para envio nao " +
                                                  "cadastrado.".
                           
                            UNDO TRANSACAO, LEAVE TRANSACAO.
                        END.
                    
                    aux_dsendere = STRING(craptfc.cdseqtfc) + " - " + 
                                   STRING(craptfc.nrtelefo).
                END.
            ELSE
            IF  ENTRY(2,craptab.dstextab,",") = "crapenc"  THEN
                DO:
                    FIND crapenc WHERE crapenc.cdcooper = par_cdcooper AND
                                       crapenc.nrdconta = par_nrdconta AND
                                       crapenc.idseqttl = par_idseqttl AND
                                       crapenc.cdseqinc = aux_cdseqinc
                                       NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE crapenc  THEN
                        DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Endereco para envio nao " +
                                                  "cadastrado.".
                           
                            UNDO TRANSACAO, LEAVE TRANSACAO.
                        END.
                        
                    aux_dsendere = STRING(crapenc.cdseqinc) + " - " + 
                                   crapenc.dsendere.
                END.
                
            FIND crapcra WHERE crapcra.cdcooper = par_cdcooper AND
                               crapcra.nrdconta = par_nrdconta AND
                               crapcra.idseqttl = par_idseqttl AND
                               crapcra.cdrelato = par_cdrelato AND
                               crapcra.cdprogra = par_cdprogra AND
                               crapcra.cddfrenv = aux_cddfrenv AND
                               crapcra.cdseqinc = aux_cdseqinc AND
                               crapcra.cdselimp = 0            NO-LOCK NO-ERROR.

            IF  AVAILABLE crapcra  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Este informativo ja esta " +
                                          "cadastrado para esse periodo e " + 
                                          ENTRY(1,craptab.dstextab,",") + ".".
            
                    UNDO TRANSACAO, LEAVE TRANSACAO.
                END.

            /* Verificar se cooperado possui senha URA cadastrada */
            IF NOT CAN-FIND(FIRST crapsnh WHERE 
                        crapsnh.cdcooper = par_cdcooper 
                    AND crapsnh.nrdconta = par_nrdconta
                    AND crapsnh.tpdsenha = 2) THEN
               DO:
                 IF par_cdrelato = 171 THEN
                 DO:                 
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Senha do tele-atendimento/URA "
                                        + "nao cadastrada. Dirija-se a seu PA".
                    UNDO TRANSACAO, LEAVE TRANSACAO.
                 END.
               END.
            
            RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT 
                SET h-b1wgen9999.
                          
            IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Handle invalido para BO b1wgen9999.".
               
                    UNDO TRANSACAO, LEAVE TRANSACAO.
                END.
            
            RUN p-conectagener IN h-b1wgen9999.

            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    DELETE PROCEDURE h-b1wgen9999.
                    
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Nao foi possivel efetuar conexao " +
                                          "com o banco generico.".
               
                    UNDO TRANSACAO, LEAVE TRANSACAO.
                END.
                 
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".
               
            RUN sistema/generico/procedures/b1wgen0037a.p 
                                                      (INPUT par_cdprogra,
                                                       INPUT par_cdrelato,
                                                      OUTPUT aux_nmrelato,
                                                      OUTPUT aux_dsrelato,
                                                      OUTPUT aux_cdgrprel,
                                                      OUTPUT aux_dscritic).
               
            IF  aux_dscritic <> ""  THEN
                DO:
                    DELETE PROCEDURE h-b1wgen9999.
                    
                    UNDO TRANSACAO, LEAVE TRANSACAO.
                END.
                             
            RUN p-desconectagener IN h-b1wgen9999.

            DELETE PROCEDURE h-b1wgen9999.
            
            CREATE crapcra.
            ASSIGN crapcra.cdcooper = par_cdcooper
                   crapcra.nrdconta = par_nrdconta
                   crapcra.idseqttl = par_idseqttl
                   crapcra.cdprogra = par_cdprogra
                   crapcra.cdrelato = par_cdrelato
                   crapcra.cddfrenv = aux_cddfrenv 
                   crapcra.cdperiod = aux_cdperiod
                   crapcra.cdseqinc = aux_cdseqinc
                   crapcra.cdselimp = 0.
            VALIDATE crapcra.

            IF  par_flgerlog  THEN
                DO:
                    ASSIGN aux_dstransa = "Inclusao de Informativo: " + 
                                          STRING(par_cdrelato) + "-" + 
                                          aux_nmrelato.
                          
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
                                             INPUT "Periodo",
                                             INPUT "",
                                             INPUT aux_dsperiod).

                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Canal",
                                             INPUT "",
                                             INPUT aux_dsdcanal).
                                                                               
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Endereco",
                                             INPUT "",
                                             INPUT aux_dsendere).
                END.
    
        END. /** Fim do DO ... TO **/

        ASSIGN aux_flgtrans = TRUE.
        
    END. /** Fim do DO TRANSACTION - TRANSACAO **/
                              
    IF  NOT aux_flgtrans  THEN
        DO:
            ASSIGN aux_dstransa = "Inclusao de Informativo".
            
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel concluir a requisicao.".
               
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


/******************************************************************************/
/**                    Procedure para excluir informativo                    **/
/******************************************************************************/
PROCEDURE excluir-informativo: 

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
 
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_cdrelato AS INTE                                    NO-UNDO.
    DEF VAR aux_cdgrprel AS INTE                                    NO-UNDO.
    
    DEF VAR aux_nmrelato AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsrelato AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsperiod AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdcanal AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsendere AS CHAR                                    NO-UNDO.
     
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
 
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Exclusao de Informativo"
           aux_flgtrans = FALSE.

    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
    
        DO aux_contador = 1 TO 10:
        
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".
                   
            FIND crapcra WHERE ROWID(crapcra) = TO-ROWID(par_nrdrowid) 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapcra  THEN
                DO:
                    IF  LOCKED crapcra  THEN
                        DO:
                            aux_dscritic = "Registro do informativo esta " +
                                           "sendo alterado. Tente novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE    
                        aux_dscritic = "Informativo para cooperado nao " +
                                       "cadastrado.".
                END.
                
            LEAVE.
                   
        END. /** Fim do DO ... TO **/
                     
        IF  aux_dscritic <> ""  THEN
            UNDO TRANSACAO, LEAVE TRANSACAO.

        ASSIGN aux_cdrelato = crapcra.cdrelato.
                                    
        FIND crapifc WHERE crapifc.cdcooper = par_cdcooper     AND
                           crapifc.cdrelato = crapcra.cdrelato AND
                           crapifc.cdprogra = crapcra.cdprogra AND
                           crapifc.cddfrenv = crapcra.cddfrenv AND
                           crapifc.cdperiod = crapcra.cdperiod NO-LOCK NO-ERROR.
                                                           
        IF  crapifc.envcobrg  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Esse informativo e' de envio " +
                                      "obrigatorio. Nao e' possivel exclui-lo.".
                
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        /** Descricao do informativo **/
        RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT 
            SET h-b1wgen9999.
                          
        IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Handle invalido para BO b1wgen9999.".
               
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
            
        RUN p-conectagener IN h-b1wgen9999.

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                DELETE PROCEDURE h-b1wgen9999.
                
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Nao foi possivel efetuar conexao com " +
                                      "o banco generico.".
               
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
                 
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "".
               
        RUN sistema/generico/procedures/b1wgen0037a.p (INPUT crapcra.cdprogra,
                                                       INPUT crapcra.cdrelato,
                                                      OUTPUT aux_nmrelato,
                                                      OUTPUT aux_dsrelato,
                                                      OUTPUT aux_cdgrprel,
                                                      OUTPUT aux_dscritic).
               
        IF  aux_dscritic <> ""  THEN
            DO:
                DELETE PROCEDURE h-b1wgen9999.
                
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
                             
        RUN p-desconectagener IN h-b1wgen9999.

        DELETE PROCEDURE h-b1wgen9999.
        
        /** Busca descricao do periodo de recebimento **/ 
        FIND craptab WHERE craptab.cdcooper = 0                AND
                           craptab.nmsistem = "CRED"           AND
                           craptab.tptabela = "USUARI"         AND
                           craptab.cdempres = 11               AND
                           craptab.cdacesso = "PERIODICID"     AND
                           craptab.tpregist = crapcra.cdperiod NO-LOCK NO-ERROR.
                             
        IF  AVAILABLE craptab  THEN
            ASSIGN aux_dsperiod = STRING(craptab.tpregist) + "-" +
                                  craptab.dstextab.
                                                                               
        /** Descricao da forma de envio e endereco de recebimento **/
        FIND craptab WHERE craptab.cdcooper = 0                AND
                           craptab.nmsistem = "CRED"           AND
                           craptab.tptabela = "USUARI"         AND
                           craptab.cdempres = 11               AND
                           craptab.cdacesso = "FORENVINFO"     AND
                           craptab.tpregist = crapcra.cddfrenv NO-LOCK NO-ERROR.
                                    
        IF  AVAILABLE craptab  THEN
            DO:
                ASSIGN aux_dsdcanal = STRING(craptab.tpregist) + "-" + 
                                      ENTRY(1,craptab.dstextab,",").
                                      
                IF  ENTRY(2,craptab.dstextab,",") = "crapcem"  THEN
                    DO:
                        FIND crapcem WHERE 
                             crapcem.cdcooper = crapcra.cdcooper AND
                             crapcem.nrdconta = crapcra.nrdconta AND
                             crapcem.idseqttl = crapcra.idseqttl AND
                             crapcem.cddemail = crapcra.cdseqinc  
                             NO-LOCK NO-ERROR.
                                                                               
                        IF  AVAILABLE crapcem  THEN
                            ASSIGN aux_dsendere = STRING(crapcem.cddemail) + 
                                                  "-" + crapcem.dsdemail.
                    END.
                ELSE
                IF  ENTRY(2,craptab.dstextab,",") = "craptfc"  THEN
                    DO:
                        FIND craptfc WHERE 
                             craptfc.cdcooper = crapcra.cdcooper AND
                             craptfc.nrdconta = crapcra.nrdconta AND
                             craptfc.idseqttl = crapcra.idseqttl AND
                             craptfc.cdseqtfc = crapcra.cdseqinc  
                             NO-LOCK NO-ERROR.
                                                                             
                        IF  AVAILABLE craptfc  THEN
                            ASSIGN aux_dsendere = STRING(craptfc.cdseqtfc) + 
                                                  "-" + 
                                                  STRING(craptfc.nrtelefo). 
                    END.
                ELSE
                IF  ENTRY(2,craptab.dstextab,",") = "crapenc"  THEN
                    DO:
                        FIND crapenc WHERE 
                             crapenc.cdcooper = crapcra.cdcooper AND
                             crapenc.nrdconta = crapcra.nrdconta AND
                             crapenc.idseqttl = crapcra.idseqttl AND
                             crapenc.cdseqinc = crapcra.cdseqinc
                             NO-LOCK NO-ERROR.
                     
                        IF  AVAILABLE crapenc  THEN
                            ASSIGN aux_dsendere = STRING(crapenc.cdseqinc) + 
                                                  "-" + 
                                                  STRING(crapenc.dsendere).  
                    END.               
            END.
                              
        DELETE crapcra.

        ASSIGN aux_flgtrans = TRUE.
    
    END. /** Fim do DO TRANSACTION - TRANSACAO **/
                              
    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel concluir a requisicao.".
               
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
        DO:
            ASSIGN aux_dstransa = "Exclusao de Informativo: " + 
                                  STRING(aux_cdrelato) + "-" + aux_nmrelato.
                          
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
                                     INPUT "Periodo",
                                     INPUT "",
                                     INPUT aux_dsperiod).

            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Canal",
                                     INPUT "",
                                     INPUT aux_dsdcanal).

            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Endereco",
                                     INPUT "",
                                     INPUT aux_dsendere).
        END.

    RETURN "OK".
                                                                             
END PROCEDURE.


/******************************************************************************/
/**       Procedure para consultar historico de envio de informativos        **/
/******************************************************************************/
PROCEDURE historico-envio-informativos: 

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
    DEF  INPUT PARAM par_iniconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
 
    DEF OUTPUT PARAM par_qtinfrec AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-historico.

    EMPTY TEMP-TABLE tt-historico.
 
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Historico de Envio de Informativos".

    FOR EACH craplgm WHERE (craplgm.cdcooper  = par_cdcooper  AND
                            craplgm.nrdconta  = par_nrdconta  AND
                            craplgm.idseqttl  = par_idseqttl  AND
                            craplgm.nmdatela  = "crps217"     AND
                            craplgm.dttransa >= par_dtiniper  AND
                            craplgm.dttransa <= par_dtfimper) OR
                           (craplgm.cdcooper  = par_cdcooper  AND
                            craplgm.nrdconta  = par_nrdconta  AND
                            craplgm.idseqttl  = par_idseqttl  AND
                            craplgm.nmdatela  = "crps488"     AND
                            craplgm.dttransa >= par_dtiniper  AND
                            craplgm.dttransa <= par_dtfimper)
                            NO-LOCK BY craplgm.dttransa DESC:
          
        ASSIGN par_qtinfrec = par_qtinfrec + 1.
        
        /** Retornar somente registros selecionados na tela **/
        IF  par_qtinfrec <= par_iniconta                  OR
            par_qtinfrec > (par_iniconta + par_nrregist)  THEN
            NEXT.
               
        CREATE tt-historico.
        ASSIGN tt-historico.dttransa = craplgm.dttransa
               tt-historico.dstransa = SUBSTR(craplgm.dstransa,
                                              INDEX(craplgm.dstransa,"-") + 1).

        FOR EACH craplgi WHERE craplgi.cdcooper = craplgm.cdcooper AND
                               craplgi.nrdconta = craplgm.nrdconta AND
                               craplgi.idseqttl = craplgm.idseqttl AND
                               craplgi.dttransa = craplgm.dttransa AND
                               craplgi.hrtransa = craplgm.hrtransa AND
                               craplgi.nrsequen = craplgm.nrsequen NO-LOCK:

            IF  craplgi.nmdcampo = "Periodo"  THEN
                ASSIGN tt-historico.dsperiod = SUBSTR(craplgi.dsdadatu,
                                               INDEX(craplgi.dsdadatu,"-") + 1).
            ELSE
            IF  craplgi.nmdcampo = "Canal"  THEN
                ASSIGN tt-historico.dsdcanal = SUBSTR(craplgi.dsdadatu,
                                               INDEX(craplgi.dsdadatu,"-") + 1).
            ELSE
            IF  craplgi.nmdcampo = "Endereco"  THEN
                ASSIGN tt-historico.dsendere = SUBSTR(craplgi.dsdadatu,
                                               INDEX(craplgi.dsdadatu,"-") + 1).
        
        END. /** Fim do FOR EACH craplgi **/

    END. /** Fim do FOR EACH craplgm **/ 

    RETURN "OK".
                                                                             
END PROCEDURE.


/*........................... PROCEDURES INTERNAS ............................*/


/******************************************************************************/
/**         Procedure para retornar dados para envio de informativos         **/
/******************************************************************************/
PROCEDURE obtem-dados-envio:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdrelato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddfrenv AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdperiod AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdseqinc AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-periodo-envio.
    DEF OUTPUT PARAM TABLE FOR tt-destino-envio.
    
    EMPTY TEMP-TABLE tt-periodo-envio.
    EMPTY TEMP-TABLE tt-destino-envio.
    
    FOR EACH crapifc WHERE crapifc.cdcooper = par_cdcooper AND
                           crapifc.cdrelato = par_cdrelato AND
                           crapifc.cddfrenv = par_cddfrenv NO-LOCK:
                    
        FIND craptab WHERE craptab.cdcooper = 0                AND
                           craptab.nmsistem = "CRED"           AND
                           craptab.tptabela = "USUARI"         AND
                           craptab.cdempres = 11               AND
                           craptab.cdacesso = "PERIODICID"     AND
                           craptab.tpregist = crapifc.cdperiod NO-LOCK NO-ERROR.
                                            
        IF  AVAILABLE craptab  THEN
            DO:
                CREATE tt-periodo-envio.
                ASSIGN tt-periodo-envio.cdrelato = par_cdrelato
                       tt-periodo-envio.cddfrenv = par_cddfrenv
                       tt-periodo-envio.cdperiod = craptab.tpregist 
                       tt-periodo-envio.dsperiod = craptab.dstextab
                       tt-periodo-envio.selected = IF  craptab.tpregist = 
                                                       par_cdperiod  THEN
                                                       " selected"
                                                   ELSE
                                                       "".
            END.
            
    END. /** Fim do FOR EACH crapifc **/

    FIND craptab WHERE craptab.cdcooper = 0            AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "USUARI"     AND
                       craptab.cdempres = 11           AND
                       craptab.cdacesso = "FORENVINFO" AND
                       craptab.tpregist = par_cddfrenv NO-LOCK NO-ERROR.
                       
    IF  AVAILABLE craptab  THEN
        DO:
            IF  ENTRY(2,craptab.dstextab,",") = "crapcem"  THEN
                DO:
                    FOR EACH crapcem WHERE crapcem.cdcooper = par_cdcooper AND
                                           crapcem.nrdconta = par_nrdconta AND
                                           crapcem.idseqttl = par_idseqttl
                                           NO-LOCK:
                                        
                        CREATE tt-destino-envio.
                        ASSIGN tt-destino-envio.cdrelato = par_cdrelato
                               tt-destino-envio.cddfrenv = par_cddfrenv
                               tt-destino-envio.cddestin = crapcem.cddemail
                               tt-destino-envio.dsdestin = crapcem.dsdemail
                               tt-destino-envio.selected = 
                                                     IF  crapcem.cddemail = 
                                                         par_cdseqinc  THEN
                                                         " selected"
                                                     ELSE
                                                         "".
     
                    END. /** Fim do FOR EACH crapcem **/
                END.
            ELSE
            IF  ENTRY(2,craptab.dstextab,",") = "crapenc"  THEN
                DO:
                    IF  par_cdseqinc = 0  THEN
                        DO:
                            FIND crapenc WHERE 
                                 crapenc.cdcooper = par_cdcooper AND
                                 crapenc.nrdconta = par_nrdconta AND
                                 crapenc.idseqttl = par_idseqttl AND
                                 crapenc.tpendass = 
                                            INTE(ENTRY(3,craptab.dstextab,","))
                                 NO-LOCK NO-ERROR.
                        
                            IF  NOT AVAILABLE crapenc                     AND
                                INTE(ENTRY(3,craptab.dstextab,",")) = 12  THEN
                                FIND crapenc WHERE 
                                     crapenc.cdcooper = par_cdcooper AND
                                     crapenc.nrdconta = par_nrdconta AND
                                     crapenc.idseqttl = par_idseqttl AND
                                     crapenc.tpendass = 10
                                     NO-LOCK NO-ERROR.    
                        END.
                    ELSE
                        FIND crapenc WHERE crapenc.cdcooper = par_cdcooper AND
                                           crapenc.nrdconta = par_nrdconta AND
                                           crapenc.idseqttl = par_idseqttl AND
                                           crapenc.cdseqinc = par_cdseqinc  
                                           NO-LOCK NO-ERROR.
                                                                             
                    IF  AVAILABLE crapenc  THEN
                        DO:
                            CREATE tt-destino-envio.
                            ASSIGN tt-destino-envio.cdrelato = par_cdrelato
                                   tt-destino-envio.cddfrenv = par_cddfrenv
                                   tt-destino-envio.cddestin = crapenc.cdseqinc
                                   tt-destino-envio.dsdestin = crapenc.dsendere
                                                      + ", " + 
                                                      STRING(crapenc.nrendere)
                                   tt-destino-envio.selected = 
                                                     IF  crapenc.cdseqinc = 
                                                         par_cdseqinc  THEN
                                                         " selected"
                                                     ELSE
                                                         "".
                        END.
                END.
            ELSE
            IF  ENTRY(2,craptab.dstextab,",") = "craptfc"  THEN
                DO:
                    FOR EACH craptfc WHERE craptfc.cdcooper = par_cdcooper  AND
                                           craptfc.nrdconta = par_nrdconta  AND
                                           craptfc.idseqttl = par_idseqttl  AND
                                           craptfc.tptelefo = 
                                            INTE(ENTRY(3,craptab.dstextab,","))
                                           NO-LOCK:
                                        
                        CREATE tt-destino-envio.
                        ASSIGN tt-destino-envio.cdrelato = par_cdrelato
                               tt-destino-envio.cddfrenv = par_cddfrenv
                               tt-destino-envio.cddestin = craptfc.cdseqtfc
                               tt-destino-envio.dsdestin = "(" + 
                                                    STRING(craptfc.nrdddtfc) +
                                                    ") " + 
                                                    STRING(craptfc.nrtelefo)
                               tt-destino-envio.selected = 
                                                     IF  craptfc.cdseqtfc = 
                                                         par_cdseqinc  THEN
                                                         " selected"
                                                     ELSE
                                                         "".

                    END. /** Fim do FOR EACH craptfc **/
                END.
        END.

    RETURN "OK".
    
END PROCEDURE.
 

/*............................................................................*/
