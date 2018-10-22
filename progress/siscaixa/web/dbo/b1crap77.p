/*------------------------------------------------------------------------
   
    b1crap77.p - Estornos - Depositos Cheques Liberados                  
     
    Ultima Atualizacao: 21/05/2012
     
     Alteracoes:
                02/03/2006 - Unificacao dos bancos - SQLWorks - Eder
                
                01/11/2010 - Chama rotina atualiza-previa-caixa e verifica se
                             PAC faz previa dos cheques (Elton).
                                                                                   
                06/01/2011 - Substituido passagem de parametro 
                             crapcop.dsdircop por p-cooper na chamada da 
                             procedure atualiza-previa-caixa (Elton).
                             
                 27/05/2011 - Enviar email sobre o controle de movimentacao
                              (Gabriel)
                              
                 21/05/2012 - substituição do FIND craptab para os registros 
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.)            

                 16/03/2018 - Substituida verificacao "cdtipcta = 6,7" pela
                              modalidade do tipo de conta igual a 3. PRJ366 (Lombardi).

                15/10/2018 - Troca DELETE CRAPLCM pela chamada da rotina estorna_lancamento_conta 
                             de dentro da b1wgen0200 
                             (Renato AMcom)
-------------------------------------------------------------------------*/

{ dbo/bo-erro1.i}
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0200tt.i }

DEF VAR i-cod-erro          AS INT    NO-UNDO.
DEF VAR c-desc-erro         AS CHAR   NO-UNDO.

DEF VAR i-nro-lote          AS INTE   NO-UNDO.
DEF VAR l-achou             AS LOG    NO-UNDO.

DEF VAR c-docto             AS CHAR   NO-UNDO.
DEF VAR c-docto-salvo       AS CHAR   NO-UNDO.

DEF VAR aux_lsconta1        AS CHAR   NO-UNDO.
DEF VAR aux_lsconta2        AS CHAR   NO-UNDO.
DEF VAR aux_lsconta3        AS CHAR   NO-UNDO.
DEF VAR aux_lscontas        AS CHAR   NO-UNDO.

DEF VAR in99                AS INTE   NO-UNDO.

DEF VAR h_b1crap00          AS HANDLE NO-UNDO.
DEF VAR h-b1wgen9998        AS HANDLE NO-UNDO.

DEF VAR h-b1wgen0200        AS HANDLE                           NO-UNDO.

DEF VAR aux_cdcritic        AS INTE                             NO-UNDO.
DEF VAR aux_dscritic        AS CHAR                             NO-UNDO.

DEF VAR aux_nrseqdig        AS INTE   NO-UNDO. 
DEF VAR flg_exetrunc        AS LOG    NO-UNDO.

PROCEDURE valida-cheque-com-captura:
    
    DEF INPUT  PARAM p-cooper         AS CHAR.
    DEF INPUT  PARAM p-cod-agencia    AS INT. 
    DEF INPUT  PARAM p-nro-caixa      AS INT.       /* Numero Caixa       */
    DEF INPUT  PARAM p-nro-conta      AS INT.       /* Nro Conta          */
    DEF INPUT  PARAM p-nrdocto        AS INT.
    DEF INPUT  PARAM p-cdprogra       AS CHAR.     
    DEF OUTPUT PARAM p-identifica     AS CHAR.
    DEF OUTPUT PARAM p-valor-dinheiro AS DEC.
    DEF OUTPUT PARAM p-valor-cheque   AS DEC.
    DEF OUTPUT PARAM p-nome-titular   AS CHAR.
    DEF OUTPUT PARAM p-poupanca       AS LOG.

    DEF VAR aux_flgci                 AS LOG INIT NO.
    DEF VAR aux_cdmodali              AS INTE NO-UNDO.
    DEF VAR aux_des_erro              AS CHAR NO-UNDO.
    DEF VAR aux_dscritic              AS CHAR NO-UNDO.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
     
    ASSIGN p-poupanca     = NO
           p-nome-titular = " ".

    ASSIGN p-valor-dinheiro  = 0
           p-valor-cheque    = 0.

   ASSIGN p-nro-conta = INT(REPLACE(string(p-nro-conta),".","")).

    IF  LENGTH(STRING(p-nro-conta)) = 9 THEN  /* Conta Investimento */
        DO:
            FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                               crapass.nrctainv = p-nro-conta   
                               NO-LOCK NO-ERROR.
             
            ASSIGN p-nro-conta = crapass.nrdconta.
            ASSIGN aux_flgci   = YES.
    END.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    IF  aux_flgci = NO THEN
        ASSIGN i-nro-lote = 11000 + p-nro-caixa.
    ELSE
        ASSIGN i-nro-lote = 23000 + p-nro-caixa.
        
    IF  p-nrdocto = 0  THEN 
        DO:
            ASSIGN i-cod-erro  = 22
                   c-desc-erro = " ".  /* Documento deve ser Informado */ 
            RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
            RETURN "NOK".
        END.
        
    IF  p-nro-conta = 0  THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Conta deve ser Informada".           
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    /*  Le tabela com as contas convenio do Banco do Brasil - Geral  */
        RUN fontes/ver_ctace.p(INPUT crapcop.cdcooper,
                               INPUT 0,
                               OUTPUT aux_lscontas).

    IF  NOT CAN-DO(aux_lscontas,STRING(p-nro-conta)) THEN 
        DO:

            FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                               crapass.nrdconta = p-nro-conta   
                               NO-LOCK NO-ERROR.
                               
            IF  NOT AVAIL crapass  THEN  
                DO:
                    ASSIGN i-cod-erro  = 9   
                           c-desc-erro = " ".           
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.

            ASSIGN p-nome-titular = crapass.nmprimtl.
            
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

            RUN STORED-PROCEDURE pc_busca_modalidade_tipo
            aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.inpessoa, /* Tipo de pessoa */
                                                 INPUT crapass.cdtipcta, /* Tipo de conta */
                                                OUTPUT 0,                /* Modalidade */
                                                OUTPUT "",               /* Flag Erro */
                                                OUTPUT "").              /* Descriçao da crítica */

            CLOSE STORED-PROC pc_busca_modalidade_tipo
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

            ASSIGN aux_cdmodali = 0
                   aux_des_erro = ""
                   aux_dscritic = ""
                   aux_cdmodali = pc_busca_modalidade_tipo.pr_cdmodalidade_tipo 
                                  WHEN pc_busca_modalidade_tipo.pr_cdmodalidade_tipo <> ?
                   aux_des_erro = pc_busca_modalidade_tipo.pr_des_erro 
                                  WHEN pc_busca_modalidade_tipo.pr_des_erro <> ?
                   aux_dscritic = pc_busca_modalidade_tipo.pr_dscritic
                                  WHEN pc_busca_modalidade_tipo.pr_dscritic <> ?.
            
            IF aux_des_erro = "NOK"  THEN
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = aux_dscritic.
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
            
            IF  aux_cdmodali = 3 THEN  /* Conta tipo Poupanca */
                DO:
                    ASSIGN p-poupanca = YES.
                END.
        END.
  
    ASSIGN l-achou = NO.
     
    ASSIGN c-docto = STRING(p-nrdocto) + "1".
    
    FIND FIRST craplcm WHERE craplcm.cdcooper = crapcop.cdcooper  AND
                             craplcm.dtmvtolt = crapdat.dtmvtolt  AND
                             craplcm.cdagenci = p-cod-agencia     AND
                             craplcm.cdbccxlt = 11                AND /* Fixo */
                             craplcm.nrdolote = i-nro-lote        AND
                             craplcm.nrdctabb = p-nro-conta       AND
                             craplcm.nrdocmto = INTE(c-docto)    
                             USE-INDEX craplcm1 NO-LOCK NO-ERROR.

     IF   AVAIL craplcm                             AND
          ENTRY(1, craplcm.cdpesqbb) = p-cdprogra   THEN 
          ASSIGN l-achou = YES
                 p-identifica     = craplcm.dsidenti
                 p-valor-dinheiro = craplcm.vllanmto.
    
               
    ASSIGN c-docto = STRING(p-nrdocto) + "2".
    IF  aux_flgci = NO THEN
        DO:
           FIND FIRST craplcm WHERE 
                      craplcm.cdcooper = crapcop.cdcooper   AND
                      craplcm.dtmvtolt = crapdat.dtmvtolt   AND
                      craplcm.cdagenci = p-cod-agencia      AND
                      craplcm.cdbccxlt = 11                 AND /* Fixo */
                      craplcm.nrdolote = i-nro-lote         AND
                      craplcm.nrdctabb = p-nro-conta        AND
                      craplcm.nrdocmto = INTE(c-docto)      
                      USE-INDEX craplcm1 NO-LOCK NO-ERROR.
   
           IF   AVAIL craplcm                           AND
                ENTRY(1, craplcm.cdpesqbb) = p-cdprogra THEN  
                ASSIGN l-achou = YES
                       aux_nrseqdig   = craplcm.nrseqdig 
                       p-identifica   = craplcm.dsidenti
                       p-valor-cheque = craplcm.vllanmto.
         END.
    ELSE 
         DO:
           FIND FIRST craplci WHERE 
                      craplci.cdcooper = crapcop.cdcooper   AND
                      craplci.dtmvtolt = crapdat.dtmvtolt   AND
                      craplci.cdagenci = p-cod-agencia      AND
                      craplci.cdbccxlt = 11                 AND /* Fixo */
                      craplci.nrdolote = i-nro-lote         AND
                      craplci.nrdconta = p-nro-conta        AND
                      craplci.nrdocmto = INTE(c-docto)      NO-LOCK NO-ERROR.
   
           IF   AVAIL craplci THEN
                ASSIGN l-achou = YES
                       aux_nrseqdig   = craplci.nrseqdig 
                       p-valor-cheque = craplci.vllanmto.
         END.

    IF  l-achou = NO  THEN do:
        ASSIGN i-cod-erro  =  90
               c-desc-erro = " ".
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.

    FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                       craplot.dtmvtolt = crapdat.dtmvtolt  AND
                       craplot.cdagenci = p-cod-agencia     AND
                       craplot.cdbccxlt = 11                AND  /* Fixo */
                       craplot.nrdolote = i-nro-lote        NO-LOCK NO-ERROR.
                       
    IF  NOT AVAIL   craplot   THEN  
        DO:
            ASSIGN i-cod-erro  = 60
                   c-desc-erro = " ".           
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    IF  p-valor-cheque > 0  THEN 
        DO:
    
        /*** Verifica se PAC faz previa dos cheques ***/ 
        ASSIGN  flg_exetrunc = FALSE.
        FIND craptab WHERE  craptab.cdcooper = crapcop.cdcooper   AND
                            craptab.nmsistem = "CRED"             AND
                            craptab.tptabela = "GENERI"           AND
                            craptab.cdempres = 0                  AND
                            craptab.cdacesso = "EXETRUNCAGEM"     AND
                            craptab.tpregist = p-cod-agencia    
                            NO-LOCK NO-ERROR.        
            
        IF   craptab.dstextab = "SIM" THEN
             DO:
                ASSIGN i-cod-erro   = 0
                       flg_exetrunc = TRUE.
              
                FOR EACH crapchd WHERE crapchd.cdcooper = crapcop.cdcooper   AND
                                       crapchd.dtmvtolt = crapdat.dtmvtolt   AND
                                       crapchd.cdagenci = p-cod-agencia      AND
                                       crapchd.cdbccxlt = 11                 AND
                                       crapchd.nrdolote = i-nro-lote         AND
                                       crapchd.nrseqdig = aux_nrseqdig 
                                       USE-INDEX crapchd3 NO-LOCK:
    
                    IF  crapchd.insitprv > 0 THEN 
                        ASSIGN i-cod-erro =  9999.
                END.
    
                IF   i-cod-erro > 0 THEN
                     DO:
                        ASSIGN i-cod-erro  = 0  
                               c-desc-erro = "Estorno nao pode ser efetuado. " + 
                                             "Cheque ja enviado para previa.".
                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                        RETURN "NOK".
                     END.
             END.
    
             
            /* Verifica horario de Corte */
            FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                               craptab.nmsistem = "CRED"            AND
                               craptab.tptabela = "GENERI"          AND
                               craptab.cdempres = 0                 AND
                               craptab.cdacesso = "HRTRCOMPEL"      AND
                               craptab.tpregist = p-cod-agencia  
                               NO-LOCK NO-ERROR.
                
            IF  NOT AVAIL craptab   THEN  
                DO:
                    ASSIGN i-cod-erro  = 676
                           c-desc-erro = " ".           
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".          
                END.   


            IF  flg_exetrunc = FALSE  THEN 
                IF  INT(SUBSTR(craptab.dstextab,1,1)) <> 0   THEN
                    DO:
                        ASSIGN i-cod-erro  = 677
                               c-desc-erro = " ".           
                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                        RETURN "NOK".
                    END.    

            IF  INT(SUBSTR(craptab.dstextab,3,5)) <= TIME   THEN 
                DO:
                    ASSIGN i-cod-erro  = 676
                           c-desc-erro = " ".           
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END. 
     
        END.
                           
    RETURN "OK".

END PROCEDURE.

PROCEDURE estorna-cheque-com-captura:
    
    DEF INPUT  PARAM p-cooper         AS CHAR. 
    DEF INPUT  PARAM p-cod-agencia    AS INT.      /* Cod. Agencia       */
    DEF INPUT  PARAM p-nro-caixa      AS INT.      /* Numero Caixa       */
    DEF INPUT  PARAM p-cod-operador   AS CHAR.
    DEF INPUT  PARAM p-nro-conta      AS INT.      /* Nro Conta          */
    DEF INPUT  PARAM p-nrdocto        AS INTE.
    DEF INPUT  PARAM p-valor-dinheiro AS DEC.
    DEF INPUT  PARAM p-valor-cheque   AS DEC.
    DEF OUTPUT PARAM p-valor          AS DEC.
                                                     
    DEF VAR aux_flgci                 AS LOG INIT NO.
  
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    ASSIGN p-nro-conta = INT(REPLACE(string(p-nro-conta),".","")).
    
    IF  LENGTH(STRING(p-nro-conta)) = 9 THEN  /* Conta Investimento */
        DO:
            FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                               crapass.nrctainv = p-nro-conta 
                               NO-LOCK NO-ERROR.
            ASSIGN p-nro-conta = crapass.nrdconta.
            ASSIGN aux_flgci   = YES.
        END.
      
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    IF  aux_flgci = NO THEN 
        ASSIGN  i-nro-lote = 11000 + p-nro-caixa.
    ELSE 
        ASSIGN  i-nro-lote = 23000 + p-nro-caixa.
                
        
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    IF  p-valor-cheque > 0  THEN   
        DO:
            ASSIGN c-docto = STRING(p-nrdocto) + "2".
            
            IF  aux_flgci = NO THEN 
                DO: 
                    FIND craplcm WHERE 
                                 craplcm.cdcooper = crapcop.cdcooper    AND
                                 craplcm.dtmvtolt = crapdat.dtmvtolt    AND
                                 craplcm.cdagenci = p-cod-agencia       AND
                                 craplcm.cdbccxlt = 11                  AND /* Fixo */
                                 craplcm.nrdolote = i-nro-lote          AND
                                 craplcm.nrdctabb = p-nro-conta         AND
                                 craplcm.nrdocmto = INTE(c-docto)  USE-INDEX craplcm1   
                                 NO-LOCK NO-ERROR.
                    
                    IF  AVAIL craplcm THEN
                        ASSIGN  aux_nrseqdig = craplcm.nrseqdig.
                END.
            ELSE 
                DO:
                    FIND craplci WHERE
                                 craplci.cdcooper = crapcop.cdcooper    AND
                                 craplci.dtmvtolt = crapdat.dtmvtolt    AND
                                 craplci.cdagenci = p-cod-agencia       AND
                                 craplci.cdbccxlt = 11                  AND /* Fixo */
                                 craplci.nrdolote = i-nro-lote          AND
                                 craplci.nrdconta = p-nro-conta         AND
                                 craplci.nrdocmto = INTE(c-docto)    
                                 NO-LOCK NO-ERROR.
               
                    IF  AVAIL craplci THEN
                        ASSIGN  aux_nrseqdig = craplci.nrseqdig.
                END.

            ASSIGN  flg_exetrunc = FALSE.
            FIND craptab WHERE  craptab.cdcooper = crapcop.cdcooper   AND
                                craptab.nmsistem = "CRED"             AND
                                craptab.tptabela = "GENERI"           AND
                                craptab.cdempres = 0                  AND
                                craptab.cdacesso = "EXETRUNCAGEM"     AND
                                craptab.tpregist = p-cod-agencia    
                                NO-LOCK NO-ERROR.        
        
            IF   craptab.dstextab = "SIM" THEN
                 DO:
                      ASSIGN i-cod-erro   = 0
                             flg_exetrunc = TRUE.
              
                      FOR EACH crapchd WHERE crapchd.cdcooper = crapcop.cdcooper   AND
                                             crapchd.dtmvtolt = craplcm.dtmvtolt   AND
                                             crapchd.cdagenci = craplcm.cdagenci   AND
                                             crapchd.cdbccxlt = craplcm.cdbccxlt   AND
                                             crapchd.nrdolote = craplcm.nrdolote   AND
                                             crapchd.nrseqdig = aux_nrseqdig
                                             USE-INDEX crapchd3 NO-LOCK:
        
                          IF  crapchd.insitprv > 0 THEN 
                              ASSIGN i-cod-erro =  9999.
                      END.
    
                      IF   i-cod-erro > 0 THEN
                           DO:
                                ASSIGN i-cod-erro  = 0  
                                       c-desc-erro = "Estorno nao pode ser efetuado. " + 
                                                     "Cheque ja enviado para previa.".
                                RUN cria-erro (INPUT p-cooper,
                                               INPUT p-cod-agencia,
                                               INPUT p-nro-caixa,
                                               INPUT i-cod-erro,
                                               INPUT c-desc-erro,
                                               INPUT YES).
                                RETURN "NOK".
                           END.
                 END.

            /* Verifica horario de Corte */
            FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                               craptab.nmsistem = "CRED"            AND
                               craptab.tptabela = "GENERI"          AND
                               craptab.cdempres = 0                 AND
                               craptab.cdacesso = "HRTRCOMPEL"      AND
                               craptab.tpregist = p-cod-agencia  
                               NO-LOCK NO-ERROR.
                
            IF  NOT AVAIL craptab   THEN  
                DO:
                    ASSIGN i-cod-erro  = 676
                           c-desc-erro = " ".           
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.    

            IF  flg_exetrunc = FALSE THEN
                IF  INT(SUBSTR(craptab.dstextab,1,1)) <> 0   THEN 
                    DO:
                        ASSIGN i-cod-erro  = 677
                               c-desc-erro = " ".           
                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                        RETURN "NOK".
                    END.    

            IF  INT(SUBSTR(craptab.dstextab,3,5)) <= TIME   THEN 
                DO:
                    ASSIGN i-cod-erro  = 676
                           c-desc-erro = " ".           
                    RUN  cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                    RETURN "NOK".
                END. 
        END.

    ASSIGN in99 = 0.
    DO  WHILE TRUE:

        ASSIGN in99 = in99 + 1.
        FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                           craplot.dtmvtolt = crapdat.dtmvtolt  AND
                           craplot.cdagenci = p-cod-agencia     AND
                           craplot.cdbccxlt = 11                AND  /* Fixo */
                           craplot.nrdolote = i-nro-lote 
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL   craplot   THEN  
            DO:
                IF  LOCKED craplot     THEN 
                    DO:
                        IF  in99 <  100  THEN 
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                ELSE 
                    DO:
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = "Tabela CRAPLOT em uso ".           
                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                        RETURN "NOK".
                    END.
            END.
        ELSE 
            DO:
                ASSIGN i-cod-erro  = 60
                       c-desc-erro = " ".           
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                RETURN "NOK".
            END.
        END.
        LEAVE.
    END.  /*  DO WHILE */
 
    IF  p-valor-dinheiro > 0 THEN 
        DO: 
            ASSIGN c-docto = STRING(p-nrdocto) + "1".
            ASSIGN in99 = 0.
            DO  WHILE TRUE:
                ASSIGN in99 = in99 + 1.
                FIND craplcm WHERE 
                     craplcm.cdcooper = crapcop.cdcooper    AND
                     craplcm.dtmvtolt = crapdat.dtmvtolt    AND
                     craplcm.cdagenci = p-cod-agencia       AND
                     craplcm.cdbccxlt = 11                  AND /* Fixo */
                     craplcm.nrdolote = i-nro-lote          AND
                     craplcm.nrdctabb = p-nro-conta         AND
                     craplcm.nrdocmto = INTE(c-docto) USE-INDEX craplcm1   
                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

             IF NOT AVAIL   craplcm THEN 
                DO:
                    IF  LOCKED craplcm THEN 
                        DO:
                            IF  in99 <  100  THEN 
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                     NEXT.
                                END.
                            ELSE 
                                DO:
                                    ASSIGN i-cod-erro  = 0
                                           c-desc-erro = 
                                                  "Tabela CRAPLCM em uso ".
                                       
                                    RUN cria-erro (INPUT p-cooper,
                                                   INPUT p-cod-agencia,
                                                   INPUT p-nro-caixa,
                                                   INPUT i-cod-erro,
                                                   INPUT c-desc-erro,
                                                   INPUT YES).
                                    RETURN "NOK".
                                END.
                        END.
                    ELSE 
                        DO:
                            ASSIGN i-cod-erro  = 90
                                   c-desc-erro = " ".           
                            RUN cria-erro (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT p-nro-caixa,
                                           INPUT i-cod-erro,
                                           INPUT c-desc-erro,
                                           INPUT YES).
                            RETURN "NOK".
                        END.  
                END.
             
             /*** Controle de movimentacao em especie ***/
             FIND crapcme WHERE crapcme.cdcooper = crapcop.cdcooper     AND
                                crapcme.dtmvtolt = craplcm.dtmvtolt     AND
                                crapcme.cdagenci = craplcm.cdagenci     AND
                                crapcme.cdbccxlt = craplcm.cdbccxlt     AND
                                crapcme.nrdolote = craplcm.nrdolote     AND
                                crapcme.nrdctabb = craplcm.nrdctabb     AND
                                crapcme.nrdocmto = craplcm.nrdocmto   
                                EXCLUSIVE-LOCK NO-ERROR.

             IF   AVAILABLE crapcme   THEN 
                  DO:                                                  
                      RUN sistema/generico/procedures/b1wgen9998.p   
                          PERSISTENT SET h-b1wgen9998.               
                                                                     
                      RUN email-controle-movimentacao IN h-b1wgen9998
                                (INPUT crapcop.cdcooper,             
                                 INPUT p-cod-agencia,                
                                 INPUT p-nro-caixa,                  
                                 INPUT p-cod-operador,               
                                 INPUT "b1crap77",                   
                                 INPUT 2, /* Caixa online */         
                                 INPUT crapcme.nrdconta,             
                                 INPUT 1, /* Tit*/                   
                                 INPUT 3, /* Exclusao */             
                                 INPUT ROWID(crapcme),  
                                 INPUT TRUE, /* Enviar */
                                 INPUT crapdat.dtmvtolt,             
                                 INPUT TRUE,                         
                                OUTPUT TABLE tt-erro).               

                      DELETE PROCEDURE h-b1wgen9998.                      
                                                                          
                      IF   RETURN-VALUE <> "OK"   THEN                    
                           DO:                                            
                               FIND FIRST tt-erro NO-LOCK NO-ERROR.       
                                                                          
                               IF   AVAIL tt-erro   THEN                            
                                    IF   tt-erro.cdcritic <> 0   THEN 
                                         ASSIGN i-cod-erro  = tt-erro.cdcritic.           
                                    ELSE 
                                         ASSIGN c-desc-erro = tt-erro.dscritic.          
                               ELSE                                                 
                                    ASSIGN c-desc-erro = "Erro no envio do email.".       
                                                                                    
                               RUN cria-erro (INPUT p-cooper,             
                                              INPUT p-cod-agencia,        
                                              INPUT p-nro-caixa,          
                                              INPUT i-cod-erro,           
                                              INPUT c-desc-erro,          
                                              INPUT YES).                 
                               RETURN "NOK".                              
                           END.                                           
                                                                          
                      DELETE crapcme.                                     

                  END.
             IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
                RUN sistema/generico/procedures/b1wgen0200.p PERSISTENT SET h-b1wgen0200.

             RUN estorna_lancamento_conta IN h-b1wgen0200 
               (INPUT craplcm.cdcooper               /* par_cdcooper */
               ,INPUT craplcm.dtmvtolt               /* par_dtmvtolt */
               ,INPUT craplcm.cdagenci               /* par_cdagenci*/
               ,INPUT craplcm.cdbccxlt               /* par_cdbccxlt */
               ,INPUT craplcm.nrdolote               /* par_nrdolote */
               ,INPUT craplcm.nrdctabb               /* par_nrdctabb */
               ,INPUT craplcm.nrdocmto               /* par_nrdocmto */
               ,INPUT craplcm.cdhistor               /* par_cdhistor */
               ,INPUT craplcm.nrctachq               /* PAR_nrctachq */
               ,INPUT craplcm.nrdconta               /* PAR_nrdconta */
               ,INPUT craplcm.cdpesqbb               /* PAR_cdpesqbb */
               ,OUTPUT aux_cdcritic                  /* Codigo da critica                             */
               ,OUTPUT aux_dscritic).                /* Descricao da critica                          */
                
             IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                DO: 
                    /* Tratamento de erros conforme anteriores */
                    ASSIGN i-cod-erro  = aux_cdcritic
                           c-desc-erro = aux_dscritic.
                      
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.   
                
             IF  VALID-HANDLE(h-b1wgen0200) THEN
               DELETE PROCEDURE h-b1wgen0200.
             LEAVE.
        END.  /*  DO WHILE */
        ASSIGN craplot.qtcompln  = craplot.qtcompln - 1
               craplot.qtinfoln  = craplot.qtinfoln - 1
               craplot.vlcompcr  = craplot.vlcompcr - p-valor-dinheiro
               craplot.vlinfocr  = craplot.vlinfocr - p-valor-dinheiro.
    END.


    IF  p-valor-cheque > 0  AND 
        aux_flgci = YES THEN DO:
        
        ASSIGN c-docto = string(p-nrdocto) + "2".
        ASSIGN in99 = 0.
        DO  WHILE TRUE:
            ASSIGN in99 = in99 + 1.

            FIND craplci WHERE
                 craplci.cdcooper = crapcop.cdcooper    AND
                 craplci.dtmvtolt = crapdat.dtmvtolt    AND
                 craplci.cdagenci = p-cod-agencia       AND
                 craplci.cdbccxlt = 11                  AND /* Fixo */
                 craplci.nrdolote = i-nro-lote          AND
                 craplci.nrdconta = p-nro-conta         AND
                 craplci.nrdocmto = INTE(c-docto)    
                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
            IF  NOT AVAIL   craplci THEN 
                DO:
                    IF  LOCKED craplci THEN 
                        DO:
                            IF  in99 <  100  THEN 
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                            ELSE 
                                DO:
                                    ASSIGN i-cod-erro  = 0
                                           c-desc-erro = 
                                                  "Tabela CRAPLCI em uso ".
                                     
                                    RUN cria-erro (INPUT p-cooper,
                                                   INPUT p-cod-agencia,
                                                   INPUT p-nro-caixa,
                                                   INPUT i-cod-erro,
                                                   INPUT c-desc-erro,
                                                   INPUT YES).
                                    RETURN "NOK".
                                END.
                        END.
                    ELSE 
                        DO:
                            ASSIGN i-cod-erro  = 90
                                   c-desc-erro = " ".           
                            RUN cria-erro (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT p-nro-caixa,
                                           INPUT i-cod-erro,
                                           INPUT c-desc-erro,
                                           INPUT YES).
                            RETURN "NOK".
                        END.              

                END.
           
            
            FOR EACH  crapchd WHERE crapchd.cdcooper = crapcop.cdcooper     AND
                                    crapchd.dtmvtolt = craplci.dtmvtolt     AND
                                    crapchd.cdagenci = craplci.cdagenci     AND
                                    crapchd.cdbccxlt = craplci.cdbccxlt     AND
                                    crapchd.nrdolote = craplci.nrdolote     AND
                                    crapchd.nrseqdig = craplci.nrseqdig
                                    USE-INDEX crapchd3 EXCLUSIVE-LOCK:
                DELETE crapchd.

                /*** Decrementa quantidade de cheques para a previa ***/
                RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
                RUN atualiza-previa-caixa  IN h_b1crap00  
                                                  (INPUT p-cooper,
                                                   INPUT p-cod-agencia,
                                                   INPUT p-nro-caixa,
                                                   INPUT p-cod-operador,
                                                   INPUT crapdat.dtmvtolt,
                                                   INPUT 2).  /*Estorno*/
                DELETE PROCEDURE h_b1crap00.

            END.
           
            /*----- Atualizar Saldo Conta Investimento */
            FIND crapsli WHERE crapsli.cdcooper  = crapcop.cdcooper         AND
                               crapsli.nrdconta  = craplci.nrdconta         AND
                         MONTH(crapsli.dtrefere) = MONTH(crapdat.dtmvtolt)  AND
                          YEAR(crapsli.dtrefere) = YEAR(crapdat.dtmvtolt)  
                               EXCLUSIVE-LOCK NO-ERROR.
                 
            IF  AVAIL crapsli THEN   
                DO:
                    ASSIGN crapsli.vlsddisp =
                           crapsli.vlsddisp - craplci.vllanmto.
                END.
            
            DELETE craplci.
        
            LEAVE.
        
        END.  /*  DO WHILE */
    
        ASSIGN craplot.qtcompln  = craplot.qtcompln - 1
               craplot.qtinfoln  = craplot.qtinfoln - 1
               craplot.vlcompcr  = craplot.vlcompcr - p-valor-cheque
               craplot.vlinfocr  = craplot.vlinfocr - p-valor-cheque.
    END.

    IF  p-valor-cheque > 0      AND 
        aux_flgci      = NO     THEN 
        DO:
            ASSIGN c-docto = string(p-nrdocto) + "2".
            ASSIGN in99 = 0.
            DO  WHILE TRUE:
                ASSIGN in99 = in99 + 1.
                FIND craplcm WHERE 
                     craplcm.cdcooper = crapcop.cdcooper    AND
                     craplcm.dtmvtolt = crapdat.dtmvtolt    AND
                     craplcm.cdagenci = p-cod-agencia       AND
                     craplcm.cdbccxlt = 11                  AND /* Fixo */
                     craplcm.nrdolote = i-nro-lote          AND
                     craplcm.nrdctabb = p-nro-conta         AND
                     craplcm.nrdocmto = INTE(c-docto)  USE-INDEX craplcm1   
                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
                IF  NOT AVAIL   craplcm THEN 
                    DO:
                        IF  LOCKED craplcm THEN 
                            DO:
                                IF  in99 <  100  THEN 
                                    DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT.
                                    END.
                                ELSE 
                                    DO:
                                        ASSIGN i-cod-erro  = 0
                                               c-desc-erro = 
                                                     "Tabela CRAPLCM em uso ".  
                                        RUN cria-erro (INPUT p-cooper,
                                                       INPUT p-cod-agencia,
                                                       INPUT p-nro-caixa,
                                                       INPUT i-cod-erro,
                                                       INPUT c-desc-erro,
                                                       INPUT YES).
                                        RETURN "NOK".
                                    END.
                            END.
                        ELSE 
                            DO:
                                ASSIGN i-cod-erro  = 90
                                       c-desc-erro = " ".           
                                RUN cria-erro (INPUT p-cooper,
                                               INPUT p-cod-agencia,
                                               INPUT p-nro-caixa,
                                               INPUT i-cod-erro,
                                               INPUT c-desc-erro,
                                                INPUT YES).
                                RETURN "NOK".
                            END.              
                    END.
            
                FOR EACH crapchd WHERE crapchd.cdcooper = crapcop.cdcooper  AND
                                       crapchd.dtmvtolt = craplcm.dtmvtolt  AND
                                       crapchd.cdagenci = craplcm.cdagenci  AND
                                       crapchd.cdbccxlt = craplcm.cdbccxlt  AND
                                       crapchd.nrdolote = craplcm.nrdolote  AND
                                       crapchd.nrseqdig = craplcm.nrseqdig
                                       USE-INDEX crapchd3 EXCLUSIVE-LOCK:
                    DELETE crapchd.
                    
                    /*** Decrementa quantidade de cheques para a previa ***/
                    RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
                    RUN atualiza-previa-caixa  IN h_b1crap00  
                                                  (INPUT p-cooper,
                                                   INPUT p-cod-agencia,
                                                   INPUT p-nro-caixa,
                                                   INPUT p-cod-operador,
                                                   INPUT crapdat.dtmvtolt,
                                                   INPUT 2).  /*Estorno*/
                    DELETE PROCEDURE h_b1crap00.

                END.
           
                DELETE craplcm.
                LEAVE.
            END.  /*  DO WHILE */
    
        ASSIGN craplot.qtcompln  = craplot.qtcompln - 1
               craplot.qtinfoln  = craplot.qtinfoln - 1
               craplot.vlcompcr  = craplot.vlcompcr - p-valor-cheque
               craplot.vlinfocr  = craplot.vlinfocr - p-valor-cheque.
    END.

    IF  craplot.vlcompdb = 0    AND
        craplot.vlinfodb = 0    AND
        craplot.vlcompcr = 0    AND
        craplot.vlinfocr = 0    THEN
        DELETE craplot.
    ELSE
        RELEASE craplot.                   

    ASSIGN  p-valor  = p-valor-dinheiro + p-valor-cheque.

    RETURN "OK".
END PROCEDURE.


/* b1crap77.p */

/* .......................................................................... */

