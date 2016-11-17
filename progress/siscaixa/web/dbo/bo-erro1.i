/*-----------------------------------------------------------------------------

    bo-erro1.i - Acesso/Geracao tabela craperr
    
    Ultima Atualizacao: 11/12/2014
    
    Alteracoes: 
                23/02/2006 - Unificacao dos bancos - SQLWorks - Eder
                
                28/05/2009 - Gerou erro por chave duplicada na craperr
                             colocado o do .. to para tentar evitar (Guilherme)
                
                16/11/2009 - Incluido controle de registro alocado na procedure
                             elimina-erro (Elton).
                             
                17/04/2014 - Ajuste na procedure "cria-erro" para buscar a 
                             proxima sequence banco Oracle. (James)
                            
               11/12/2014 - Conversão da fn_sequence para procedure para não
                            gerar cursores abertos no Oracle. (Dionathan)
                             
------------------------------------------------------------------------------*/
{ sistema/generico/includes/var_oracle.i }

PROCEDURE elimina-erro:

    DEF INPUT PARAM p-cooper       AS CHAR.
    DEF INPUT PARAM p-cod-agencia  AS INTEGER.
    DEF INPUT PARAM p-nro-caixa    AS INTEGER.
    
    DEF BUFFER      craberr        FOR craperr.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    FOR EACH craperr WHERE craperr.cdcooper = crapcop.cdcooper  AND
                           craperr.cdagenci = p-cod-agencia     AND
                           craperr.nrdcaixa = p-nro-caixa       NO-LOCK:
                           
        FIND craberr OF craperr EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
        IF  NOT AVAIL craberr THEN
            DO:  
                CREATE  craberr.
                ASSIGN  craberr.cdcooper = crapcop.cdcooper
                        craberr.cdagenci = p-cod-agencia 
                        craberr.nrdcaixa = p-nro-caixa 
                        craberr.nrsequen = 88888  
                        craberr.cdcritic = 0  
                        craberr.dscritic = "Tabela craperr em uso. 
                                            Tente novamente!"  
                        craberr.erro     = YES NO-ERROR. 
                
                /** Nao mostra no log a critica de registro duplicado **/
                IF ERROR-STATUS:ERROR THEN
                   UNDO. 
                
                RETURN "NOK".
            END.
           
        DELETE craberr.
    END.
         
END PROCEDURE.

PROCEDURE cria-erro:

    DEF INPUT PARAM p-cooper       AS CHAR.
    DEF INPUT PARAM p-cod-agencia  AS INTEGER.
    DEF INPUT PARAM p-nro-caixa    AS INTEGER.
    DEF INPUT PARAM p-cod-erro     AS INTEGER.
    DEF INPUT PARAM p-descricao    AS CHAR.
    DEF INPUT PARAM p-erro         AS LOG.

    DEF VAR i-num-seq AS INTEGER NO-UNDO INIT 1.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    /* Busca a proxima sequencia */
    RUN STORED-PROCEDURE pc_sequence_progress
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPERR"
                                        ,INPUT "NRSEQUEN"
                                        ,INPUT STRING(crapcop.cdcooper) + ";" +
                                               STRING(p-cod-agencia) + ";" +
                                               STRING(p-nro-caixa)
                                        ,INPUT "N"
                                        ,"").
  
    CLOSE STORED-PROC pc_sequence_progress
    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
            
    ASSIGN i-num-seq = INTE(pc_sequence_progress.pr_sequence)
                       WHEN pc_sequence_progress.pr_sequence <> ?.

    IF  p-cod-erro <> 0   THEN 
        DO:
            FIND crapcri WHERE crapcri.cdcritic = p-cod-erro NO-LOCK NO-ERROR.
            
            IF  NOT AVAIL crapcri THEN
                ASSIGN p-descricao = "Critica nao Cadastrada".
            ELSE
                ASSIGN p-descricao =  crapcri.dscritic + p-descricao.      
        END.
    MESSAGE p-cod-erro p-descricao.
    CREATE craperr.
    ASSIGN craperr.cdcooper   = crapcop.cdcooper
           craperr.cdagenci   = p-cod-agencia
           craperr.nrdcaixa   = p-nro-caixa
           craperr.nrsequen   = i-num-seq
           craperr.cdcritic   = p-cod-erro
           craperr.dscritic   = p-descricao
           craperr.erro       = p-erro.
    RELEASE craperr.
    VALIDATE craperr.

END PROCEDURE.

PROCEDURE verifica-erro:
    DEF INPUT PARAM p-cooper       AS CHAR.
    DEF INPUT PARAM p-cod-agencia  AS INTEGER.
    DEF INPUT PARAM p-nro-caixa    AS INTEGER.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    FIND FIRST craperr WHERE craperr.cdcooper = crapcop.cdcooper   AND
                             craperr.cdagenci = p-cod-agencia      AND
                             craperr.nrdcaixa = p-nro-caixa   
                             NO-LOCK NO-ERROR.
    
    IF  AVAIL craperr THEN 
        RETURN "NOK".

    RETURN "OK".
END PROCEDURE.

/* .......................................................................... */

