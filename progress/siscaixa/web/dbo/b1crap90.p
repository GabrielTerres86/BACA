/*----------------------------------------------------------------------------
    
    b1crap90.p - Pagamento de Emprestimo (Sem Conta Corrente)

    Ultima atualizacao: 

    Alteracoes:


----------------------------------------------------------------------------*/
 
{dbo/bo-erro1.i}

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0002tt.i }

DEF VAR i-cod-erro      AS INT                              NO-UNDO.
DEF VAR c-desc-erro     AS CHAR                             NO-UNDO.

DEF VAR i-nro-lote      AS INTE                             NO-UNDO.
DEF VAR i_conta         AS DEC                              NO-UNDO.
DEF VAR aux_nrtrfcta    LIKE  craptrf.nrsconta              NO-UNDO.
DEF VAR inc_nrctremp    LIKE  crapepr.nrctremp              NO-UNDO.

DEF VAR h-b1wgen0001    AS HANDLE                           NO-UNDO.
DEF VAR h-b1wgen0002    AS HANDLE                           NO-UNDO.
DEF VAR h_b2crap00      AS HANDLE                           NO-UNDO.
DEF VAR h_b1crap00      AS HANDLE                           NO-UNDO.

DEF VAR p-literal       AS CHAR                             NO-UNDO.
DEF VAR p-ult-sequencia AS INTE                             NO-UNDO.
DEF VAR p-registro      AS RECID                            NO-UNDO.

DEF VAR aux_contador    AS INTE                             NO-UNDO.
DEF VAR c-docto         AS CHAR                             NO-UNDO.
DEF VAR i-nro-docto     AS INTE                             NO-UNDO. 
DEF VAR in99            AS INTE                             NO-UNDO.

DEF VAR c-literal       AS CHAR FORMAT "x(48)" EXTENT 30.
DEF VAR c-nome-titular1 AS CHAR FORMAT "x(40)"              NO-UNDO.

DEF BUFFER crabass FOR crapass.

DEF  VAR inc_nrdconta AS INT   FORMAT "zzzz,zzz,9"             NO-UNDO.
DEF  VAR inc_dtcalcul AS DATE  FORMAT "99/99/9999" INIT ?      NO-UNDO.

DEF  VAR glb_cdcritic AS INTE                                  NO-UNDO.
DEF  VAR glb_dtmvtolt AS DATE FORMAT "99/99/9999"              NO-UNDO.
DEF  VAR glb_inproces AS INTE                                  NO-UNDO.
DEF  VAR glb_cdprogra AS CHAR                                  NO-UNDO.
DEF  VAR glb_dtmvtopr AS DATE FORMAT "99/99/9999"              NO-UNDO.

/* Variavel utilizada no include includes/gera_workepr.i */
DEF  VAR glb_cdcooper   AS INT                                 NO-UNDO.

DEF  VAR aux_vljurmes AS DECIMAL FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF  VAR aux_vljuracu AS DECIMAL FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF  VAR aux_vlsdeved AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF  VAR aux_vlprepag AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF  VAR aux_txdjuros AS DECIMAL DECIMALS 7                    NO-UNDO.
DEF  VAR aux_nrdconta AS INT                                   NO-UNDO.
DEF  VAR aux_nrctremp AS INT                                   NO-UNDO.
DEF  VAR aux_qtprecal AS DECIMAL DECIMALS 4                    NO-UNDO.
DEF  VAR aux_dtmesant AS DATE                                  NO-UNDO.
DEF  VAR aux_nrdiacal AS INT                                   NO-UNDO.
DEF  VAR aux_inhst093 AS LOGICAL                               NO-UNDO.
DEF  VAR aux_ddlanmto AS INT                                   NO-UNDO.
DEF  VAR aux_dtultpag AS DATE                                  NO-UNDO.
DEF  VAR aux_qtprepag AS INT                                   NO-UNDO.
DEF  VAR aux_nrdiames AS INT                                   NO-UNDO.
DEF  VAR aux_nrdiamss AS INT                                   NO-UNDO.
DEF  VAR aux_vldescto AS DECIMAL                               NO-UNDO.
DEF  VAR aux_vltotemp AS DECIMAL                               NO-UNDO.
DEF  VAR aux_vltotpre AS DECIMAL                               NO-UNDO.
DEF  VAR aux_nrctatos AS INT                                   NO-UNDO.
DEF  VAR aux_cdpesqui AS CHAR    FORMAT "x(25)"                NO-UNDO.
DEF  VAR aux_qtpreapg AS DECIMAL DECIMALS 4                    NO-UNDO.
DEF  VAR aux_dtinipag AS DATE                                  NO-UNDO.
DEF  VAR aux_dslcremp AS CHAR    FORMAT "x(31)"                NO-UNDO.
DEF  VAR aux_dsfinemp AS CHAR    FORMAT "x(31)"                NO-UNDO.
DEF  VAR aux_dsdaval1 AS CHAR    FORMAT "x(42)"                NO-UNDO.
DEF  VAR aux_dsdaval2 AS CHAR    FORMAT "x(42)"                NO-UNDO.
DEF  VAR aux_dtrefavs AS DATE                                  NO-UNDO.
DEF  VAR aux_flghaavs AS LOGICAL                               NO-UNDO.
DEF  VAR aux_vltotprv AS DECIMAL                               NO-UNDO.
DEF  VAR aux_vlpresta LIKE crapepr.vlsdeved                    NO-UNDO.
DEF  VAR aux_dtcalcul AS DATE.
DEF  VAR aux_dtultdia AS DATE.
DEF  VAR aux_dtrefere AS DATE.
DEF  VAR aux_vlprovis AS DEC.

DEF  VAR epr_nrctremp AS INT     EXTENT 99                     NO-UNDO.
DEF  VAR epr_nrrecepr AS INT     EXTENT 99                     NO-UNDO.

DEF  VAR s_chextent AS INTEGER                                 NO-UNDO.
DEF  VAR s_vlsdeved AS DECIMAL   EXTENT 100                    NO-UNDO.
DEF  VAR s_chlist   AS CHARACTER EXTENT 100                    NO-UNDO.

DEF  VAR ant_vlsdeved AS DECIMAL                               NO-UNDO.

DEF  VAR par_qtdialib AS INTE INITIAL 0                        NO-UNDO.



PROCEDURE valida-pagto-emprestimo:
    
    DEF INPUT  PARAM p-cooper                AS CHAR.
    DEF INPUT  PARAM p-cod-agencia           AS INTEGER. /* Cod. Agencia */
    DEF INPUT  PARAM p-nro-caixa             AS INTEGER. /* Numero Caixa */
    DEF INPUT  PARAM p-nro-conta             AS INTEGER. /* Nro Conta    */
    DEF INPUT  PARAM p-nro-contrato          AS INTEGER.
    DEF INPUT  PARAM p-valor-pagto           AS DECIMAL.
    DEF INPUT  PARAM p-cod-operador          AS CHAR.
    DEF INPUT  PARAM p-seq-validacao         AS INTEGER. /* sequencia validacao*/

    DEF OUTPUT PARAM p-nome-titular          AS CHAR.
    DEF OUTPUT PARAM p-mensagem              AS CHAR.

    /*  p-seq-validacao:
        1 - Validar Conta e Contrato
        2 - Validar Valores
    */

    FIND FIRST crapcop
         WHERE crapcop.nmrescop = p-cooper
       NO-LOCK NO-ERROR.

    ASSIGN p-nro-conta = DEC(REPLACE(STRING(p-nro-conta),".","")).

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).            

    ASSIGN p-mensagem     = " "
           p-nome-titular = " ".



    /****** CHAMADA ORACLE *****/

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    /* Efetuar a chamada da rotina Oracle */
    MESSAGE "BO090 - valida-pagto-emprestimo - "
            " (p-cooper)      : " inte(crapcop.cdcooper)
            " (p-cod-agencia) : " inte(p-cod-agencia)
            " (p-nro-caixa)   : " inte(p-nro-caixa)   
            " (p-nro-conta)   : " inte(p-nro-conta)
            " (p-nro-contrato): " inte(p-nro-contrato)
            " p-seq-validacao : " p-seq-validacao
        .

    RUN STORED-PROCEDURE pc_valida_pagto_emprest
         aux_handproc = PROC-HANDLE NO-ERROR
                                ( INPUT crapcop.cdcooper,
                                  INPUT inte(p-cod-agencia),  /* cdagenci */
                                  INPUT inte(p-nro-caixa),    /* nrdcaixa */
                                  INPUT inte(p-nro-conta),    /* NrdConta */
                                  INPUT inte(p-nro-contrato), /* Contrato */
                                  INPUT p-valor-pagto,        /* Valor Pago */
                                  INPUT p-seq-validacao, 
                                  INPUT 2,                   /* 2 - CAIXA  */
                                  INPUT p-cod-operador,      /* glb_cdoperad */
                                  INPUT "CRAP090",
                                 /* OUT */
                                 OUTPUT "",  /* pr_nmprimtl */
                                 OUTPUT "",  /* pr_dsmensag */
                                 OUTPUT "",  /* pr_retorno  */
                                 OUTPUT 0 ,  /* pr_cdcritic */
                                 OUTPUT ""). /* pr_dscritic */

    MESSAGE "BO090 - valida-pagto-emprestimo: Passo 2".

    /* Fechar o procedimento para buscarmos o resultado */
    CLOSE STORED-PROC pc_valida_pagto_emprest
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    MESSAGE "BO090 - valida-pagto-emprestimo: Passo 3".
    /* Busca possíveis erros */
    ASSIGN i-cod-erro = 0
           c-desc-erro = ""
           i-cod-erro = pc_valida_pagto_emprest.pr_cdcritic
                          WHEN pc_valida_pagto_emprest.pr_cdcritic <> ?
           c-desc-erro = pc_valida_pagto_emprest.pr_dscritic
                          WHEN pc_valida_pagto_emprest.pr_dscritic <> ?

           p-nome-titular = pc_valida_pagto_emprest.pr_nmprimtl
                          WHEN pc_valida_pagto_emprest.pr_nmprimtl <> ?
           p-mensagem     = pc_valida_pagto_emprest.pr_dsmensag
                          WHEN pc_valida_pagto_emprest.pr_dsmensag <> ?
        /*   aux_retorno  = pc_valida_pagto_emprest.pr_retorno
                          WHEN pc_valida_pagto_emprest.pr_retorno <> ?*/
        .

    MESSAGE "BO090 - valida-pagto-emprestimo: Passo 4".

    IF i-cod-erro <> 0  OR c-desc-erro <> "" THEN DO:
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.



    RETURN "OK".


END PROCEDURE.




PROCEDURE atualiza-emprestimos:

    DEF INPUT  PARAM p-cooper                  AS CHAR.
    DEF INPUT  PARAM p-cod-agencia             AS INT.   /* Cod. Agencia   */
    DEF INPUT  PARAM p-nro-caixa               AS INT.   /* Numero Caixa   */
    DEF INPUT  PARAM p-cod-operador            AS CHAR.
    DEF INPUT  PARAM p-nro-conta               AS INT.   /* Nro Conta      */
    DEF INPUT  PARAM p-nro-contrato            AS INT.
    DEF INPUT  PARAM p-valor                   AS DEC.
    DEF OUTPUT PARAM p-literal-autentica       AS CHAR.
    DEF OUTPUT PARAM p-ult-sequencia-autentica AS INTE.
    DEF OUTPUT PARAM p-nro-docto               AS INTE.
      
    DEF VAR aux_retorno  AS CHAR NO-UNDO.

    DEF VAR          h-b1wgen0043              AS HANDLE NO-UNDO.

    FIND FIRST crapcop
         WHERE crapcop.nmrescop = p-cooper
       NO-LOCK NO-ERROR.

    ASSIGN p-nro-conta = dec(REPLACE(string(p-nro-conta),".","")).

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat
         WHERE crapdat.cdcooper = crapcop.cdcooper
       NO-LOCK NO-ERROR.

    ASSIGN aux_nrdconta = p-nro-conta.
   
    /*--- Verifica se Houve Transferencia de Conta --*/
    ASSIGN aux_nrtrfcta = 0.
    DO  WHILE TRUE:
        FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper
                       AND crapass.nrdconta = aux_nrdconta  
                   NO-LOCK NO-ERROR.
             
        IF  CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl)) THEN DO:
          
            FIND FIRST craptrf
                 WHERE craptrf.cdcooper = crapcop.cdcooper
                   AND craptrf.nrdconta = crapass.nrdconta
                   AND craptrf.tptransa = 1
                   AND craptrf.insittrs = 2   
             USE-INDEX craptrf1 NO-LOCK NO-ERROR.
            
            ASSIGN aux_nrtrfcta = craptrf.nrsconta
                   aux_nrdconta = craptrf.nrsconta.
            NEXT.
        END.
        LEAVE.
    END. /* do while */
    
    IF  aux_nrtrfcta > 0  THEN    /* Transferencia de Conta */
        ASSIGN aux_nrdconta = aux_nrtrfcta.
    /*-------------------------------------------------*/
    ASSIGN p-nro-conta = aux_nrdconta.


    ASSIGN i-nro-lote = 13000 + p-nro-caixa.



    /****** CHAMADA ORACLE *****/

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    /* Efetuar a chamada da rotina Oracle */
    MESSAGE "BO090 - Passo 1 - Conta " p-nro-conta " / Contrato " p-nro-contrato
            " / Valor: " p-valor " / Operad: " p-cod-operador.
    c-desc-erro = "Erro Exemplo".
    
    RUN STORED-PROCEDURE pc_efetua_pagto_emprest
         aux_handproc = PROC-HANDLE NO-ERROR
                                ( INPUT crapcop.cdcooper,
                                  INPUT 0,  /** agencia **/
                                  INPUT 0,  /** caixa **/
                                  INPUT p-cod-operador,  /** glb_cdoperad **/
                                  INPUT "CRAP090",
                                  INPUT 2,                   /* 2 - CAIXA  */
                                  INPUT p-nro-conta,
                                  INPUT 1,  /* idseqttl */
                                  INPUT crapdat.dtmvtolt,
                                  INPUT crapdat.dtmvtopr,
                                  INPUT inc_dtcalcul,
                                  INPUT p-nro-contrato, /** Contrato **/
                                  INPUT p-valor,    /* Valor Pago */
                                  INPUT "CRED", /* nmsistem */
                                  INPUT 1 ,   /* inproces */
                                  INPUT 0 ,   /* flgerlog */
                                  INPUT 0 ,   /* flgcondc */
                                 /* OUT */
                                 OUTPUT 0 ,  /* pr_nrdocmto */
                                 OUTPUT "",  /* pr_dslitera */
                                 OUTPUT 0 ,  /* pr_cdultseq */
                                 OUTPUT "",  /* pr_retorno  */
                                 OUTPUT 0 ,  /* pr_cdcritic */
                                 OUTPUT ""). /* pr_dscritic */

    MESSAGE "BO090 - Passo 2".

    /* Fechar o procedimento para buscarmos o resultado */
    CLOSE STORED-PROC pc_efetua_pagto_emprest
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    MESSAGE "BO090 - Passo 3".
    /* Busca possíveis erros */
    ASSIGN i-cod-erro = 0
           c-desc-erro = ""
           i-cod-erro = pc_efetua_pagto_emprest.pr_cdcritic
                          WHEN pc_efetua_pagto_emprest.pr_cdcritic <> ?
           c-desc-erro = pc_efetua_pagto_emprest.pr_dscritic
                          WHEN pc_efetua_pagto_emprest.pr_dscritic <> ?

           p-nro-docto = pc_efetua_pagto_emprest.pr_nrdocmto
                          WHEN pc_efetua_pagto_emprest.pr_nrdocmto <> ?
           p-literal-autentica = pc_efetua_pagto_emprest.pr_dslitera
                          WHEN pc_efetua_pagto_emprest.pr_dslitera <> ?
           p-ult-sequencia-autentica = pc_efetua_pagto_emprest.pr_cdultseq
                          WHEN pc_efetua_pagto_emprest.pr_cdultseq <> ?    
           aux_retorno  = pc_efetua_pagto_emprest.pr_retorno
                          WHEN pc_efetua_pagto_emprest.pr_retorno <> ?.

    MESSAGE "BO090 - Passo 4".

    IF i-cod-erro <> 0  OR c-desc-erro <> "" THEN DO:
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.


    MESSAGE "BO90 - Docto: " p-nro-docto " Seq: " p-ult-sequencia-autentica
            "Retorno: " aux_retorno " Literal: " p-literal-autentica.

    /*ELSE 
    IF (aux_vlcapital - aux_vlpago) = 0 THEN DO:
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "Valor ja pago em " + string(aux_dtinicio_credito,'99/99/9999') + ".".
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
                       
    END.
    ASSIGN p-valor-capital = aux_vlcapital - aux_vlpago
           p-origem-devolucao = 1.
  */

    /****** CHAMADA ORACLE *****/

    
/*

    FIND FIRST crapepr 
         WHERE crapepr.cdcooper = crapcop.cdcooper
           AND crapepr.nrdconta = p-nro-conta
           AND crapepr.nrctremp = p-nro-contrato    NO-LOCK NO-ERROR.
         
    IF  NOT AVAIL crapepr   THEN DO:
        ASSIGN i-cod-erro  = 356
               c-desc-erro = " ".           
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.

    ASSIGN inc_nrdconta = crapepr.nrdconta
           inc_dtcalcul = ?.
    
    /* busca informacoes de emprestimo e prestacoes (para nao 
    utilizar mais a include "gera workepr.i") - (Gabriel/DB1) */

    IF  NOT VALID-HANDLE(h-b1wgen0002)  THEN
        RUN sistema/generico/procedures/b1wgen0002.p
           PERSISTENT SET h-b1wgen0002.

    RUN obtem-dados-emprestimos IN h-b1wgen0002
        ( INPUT crapcop.cdcooper,
          INPUT 0,  /** agencia **/
          INPUT 0,  /** caixa **/
          INPUT p-cod-operador, /** glb_cdoperad **/
          INPUT "ATENDA",
          INPUT 1,  /** origem **/
          INPUT inc_nrdconta,
          INPUT 1,  /** idseqttl **/
          INPUT crapdat.dtmvtolt,
          INPUT crapdat.dtmvtopr,
          INPUT inc_dtcalcul,
          INPUT p-nro-contrato, /** Contrato **/
          INPUT "CRED",
          INPUT 1,
          INPUT FALSE, /** Log **/
          INPUT FALSE,
          INPUT 0, /** nriniseq **/
          INPUT 0, /** nrregist **/
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-erro,
         OUTPUT TABLE tt-dados-epr ).

    IF  VALID-HANDLE(h-b1wgen0002) THEN
        DELETE OBJECT h-b1wgen0002.

    IF  RETURN-VALUE = "NOK"  THEN DO:

       FIND FIRST tt-erro NO-LOCK NO-ERROR.

       IF  AVAIL tt-erro THEN
           ASSIGN i-cod-erro  = tt-erro.cdcritic.             
       ELSE
           ASSIGN c-desc-erro  = "Erro no carregamento de emprestimos.".
                    
       RUN cria-erro (INPUT glb_cdcooper,
                      INPUT 0, /** agencia **/
                      INPUT 0, /** caixa **/  
                      INPUT i-cod-erro,
                      INPUT c-desc-erro,
                      INPUT YES).
       RETURN "NOK".

    END.

    FIND FIRST tt-dados-epr NO-LOCK NO-ERROR.

    ASSIGN aux_vlsdeved = IF AVAILABLE tt-dados-epr 
                          THEN tt-dados-epr.vlsdeved ELSE 0.
                   
    IF  aux_vlsdeved < p-valor THEN DO:
        ASSIGN i-cod-erro = 0.
               c-desc-erro = "Valor superior ao Saldo Devedor " +       
                              STRING(aux_vlsdeved,"zzz,zzz,zz9.99").
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.
     
    ASSIGN in99 = 0.

    DO  WHILE TRUE:
       
        FIND crapepr WHERE crapepr.cdcooper = crapcop.cdcooper
                       AND crapepr.nrdconta = p-nro-conta
                       AND crapepr.nrctremp = p-nro-contrato 
            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
        ASSIGN in99 = in99 + 1.
        IF  NOT AVAILABLE crapepr THEN DO:
            IF  LOCKED crapepr THEN DO:
                IF  in99 <  100  THEN DO:
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
                ELSE DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Tabela CRAPEPR em uso ".
                    
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
            END.
            ELSE DO:
                ASSIGN i-cod-erro  = 356
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

    FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper
                   AND craplot.dtmvtolt = crapdat.dtmvtolt
                   AND craplot.cdagenci = p-cod-agencia
                   AND craplot.cdbccxlt = 11
                   AND craplot.nrdolote = i-nro-lote
              NO-ERROR.
                       
    IF  NOT AVAIL craplot THEN DO:
        CREATE craplot.
        ASSIGN craplot.cdcooper = crapcop.cdcooper
               craplot.dtmvtolt = crapdat.dtmvtolt
               craplot.cdagenci = p-cod-agencia   
               craplot.cdbccxlt = 11              
               craplot.nrdolote = i-nro-lote
               craplot.tplotmov = 5
               craplot.cdoperad = p-cod-operador
               craplot.cdhistor = 0 
               craplot.nrdcaixa = p-nro-caixa
               craplot.cdopecxa = p-cod-operador.
    END.

    ASSIGN c-docto = STRING(TIME).

    ASSIGN i-nro-docto = INTE(c-docto)
           p-nro-docto = INTE(c-docto).

    /*--- Verifica se Lancamento ja Existe ---*/
    FIND craplem WHERE craplem.cdcooper = crapcop.cdcooper
                   AND craplem.dtmvtolt = crapdat.dtmvtolt
                   AND craplem.cdagenci = p-cod-agencia
                   AND craplem.cdbccxlt = 11
                   AND craplem.nrdolote = i-nro-lote
                   AND craplem.nrseqdig = craplot.nrseqdig + 1  NO-ERROR.
         
    IF  AVAIL craplem THEN DO: 
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "Lancamento ja existente".           
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.

    FIND craplem WHERE craplem.cdcooper = crapcop.cdcooper  
                   AND craplem.dtmvtolt = crapdat.dtmvtolt  
                   AND craplem.cdagenci = p-cod-agencia     
                   AND craplem.cdbccxlt = 11                
                   AND craplem.nrdolote = i-nro-lote        
                   AND craplem.nrdconta = p-nro-conta       
                   AND craplem.nrdocmto = INTE(c-docto)     NO-ERROR.
         
    IF  AVAIL craplem THEN DO: 
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "Lancamento(Primario) ja existente".
        
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.

    /*--- Grava Autenticacao Arquivo/Spool --*/
    RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
    RUN grava-autenticacao  IN h_b1crap00 (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT p-nro-caixa,
                                           INPUT p-cod-operador,
                                           INPUT p-valor, 
                                           INPUT DEC(i-nro-docto),
                                           INPUT NO,  /* YES (PG), NO (REC) */
                                           INPUT "1",  /* On-line           */          
                                           INPUT NO,   /* Nao estorno       */
                                           INPUT 92,
                                           INPUT ?, /* Data off-line */
                                           INPUT 0, /* Sequencia off-line */
                                           INPUT 0, /* Hora off-line */
                                           INPUT 0, /* Seq.orig.Off-line */
                                           OUTPUT p-literal,
                                           OUTPUT p-ult-sequencia,
                                           OUTPUT p-registro).
    DELETE PROCEDURE h_b1crap00.

    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".
    /*------*/
    
    CREATE craplem.
    ASSIGN craplem.cdcooper = crapcop.cdcooper
           craplem.dtmvtolt = crapdat.dtmvtolt
           craplem.cdagenci = p-cod-agencia
           craplem.cdbccxlt  = 11
           craplem.nrdolote = i-nro-lote
           craplem.nrdconta = p-nro-conta
           craplem.nrctremp = p-nro-contrato
           craplem.nrdocmto = INTE(c-docto)
           craplem.vllanmto = p-valor
           craplem.cdhistor = 92 
           craplem.nrseqdig = craplot.nrseqdig + 1 
           craplem.nrautdoc = p-ult-sequencia
           craplem.txjurepr = IF crapepr.inprejuz <> 0
                              THEN 0
                              ELSE aux_txdjuros
           craplem.dtpagemp = crapdat.dtmvtolt
           craplem.vlpreemp = crapepr.vlpreemp.
    VALIDATE craplem.        

    ASSIGN craplot.nrseqdig  = craplot.nrseqdig + 1 
           craplot.qtcompln  = craplot.qtcompln + 1
           craplot.qtinfoln  = craplot.qtinfoln + 1
           craplot.vlcompcr  = craplot.vlcompcr + p-valor
           craplot.vlinfocr  = craplot.vlinfocr + p-valor.

    ASSIGN crapepr.dtultpag = crapdat.dtmvtolt
           crapepr.txjuremp = aux_txdjuros
           crapepr.inliquid = IF (aux_vlsdeved - p-valor ) > 0
                                 THEN 0
                               ELSE 1.
   
    IF  crapepr.inliquid = 1   THEN DO: /* Se liquidado */
    
        RUN sistema/generico/procedures/b1wgen0043.p
                          PERSISTENT SET h-b1wgen0043.
        
        /* Desativar Rating desta operaçao */
        RUN desativa_rating IN h-b1wgen0043 (INPUT crapcop.cdcooper,
                                          INPUT p-cod-agencia,
                                          INPUT p-nro-caixa,
                                          INPUT p-cod-operador,
                                          INPUT crapdat.dtmvtolt,
                                          INPUT crapdat.dtmvtopr,
                                          INPUT p-nro-conta,
                                          INPUT 90, /* Emprestimo*/ 
                                          INPUT p-nro-contrato,
                                          INPUT TRUE,
                                          INPUT 1, /* Titular */
                                          INPUT 2, /* Caixa On-line*/
                                          INPUT "b1crap90",
                                          INPUT glb_inproces,
                                          INPUT FALSE,
                                          OUTPUT TABLE tt-erro).
        DELETE PROCEDURE h-b1wgen0043.
        
        IF  RETURN-VALUE <> "OK"   THEN DO:

           FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
           IF  AVAIL tt-erro THEN
               ASSIGN i-cod-erro  = tt-erro.cdcritic.             
           ELSE
               ASSIGN c-desc-erro  = 
                        "Erro na desativaçao do Rating.".
    
           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
           
        END.
    END. /* Fim liquidaçao emprestimo */
         

   /*---- Gera literal autenticacao - RECEBIMENTO(Rolo) ----*/
   
    ASSIGN c-nome-titular1 = " ".
    FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                       crapass.nrdconta = craplem.nrdconta  NO-LOCK NO-ERROR.
         
    IF  AVAIL crapass THEN
        ASSIGN c-nome-titular1 = crapass.nmprimtl.
                   
    ASSIGN c-literal = " ".
    ASSIGN c-literal[1]  = TRIM(crapcop.nmrescop) +  " - " +
                           TRIM(crapcop.nmextcop) 
           c-literal[2]  = " "
           c-literal[3]  = STRING(crapdat.dtmvtolt,"99/99/99") +
                           " " + STRING(TIME,"HH:MM:SS") +  " PA  " + 
                           STRING(p-cod-agencia,"999") +
                           "  CAIXA: " + STRING(p-nro-caixa,"Z99") + "/" +
                           SUBSTR(p-cod-operador,1,10)  
           c-literal[4]  = " " 
           c-literal[5]  = "     ** COMPROVANTE DE PAGAMENTO " + 
                           STRING(i-nro-docto,"ZZZ,ZZ9")  + " **" 
           c-literal[6]  = " " 
           c-literal[7]  = "CONTA: "    +                                     
                           TRIM(STRING(craplem.nrdconta,"zzzz,zzz,9"))
           c-literal[8 ] = "       "    +   TRIM(c-nome-titular1)
           c-literal[9]  = "       "    
           c-literal[10] = "        PAGAMENTO DE EMPRESTIMO        "
           c-literal[11] = "---------------------------------------" 
           c-literal[12] = " " 
           c-literal[13] = "CONTRATO...........:     " +
                           STRING(p-nro-contrato,"Z,ZZZ,ZZ9")
           c-literal[14] = " " 
           c-literal[15] = "DATA PAGAMENTO.....:     " +
                           STRING(crapdat.dtmvtolt,"99/99/9999")
           c-literal[16] = " " 
           c-literal[17] = "VALOR PAGO.........: " +  
                           STRING(p-valor,"ZZZ,ZZZ,ZZ9.99") 
           c-literal[18] = " "
           c-literal[19] = p-literal
           c-literal[20] = " "
           c-literal[21] = " "
           c-literal[22] = " "
           c-literal[23] = " "
           c-literal[24] = " "
           c-literal[25] = " "
           c-literal[26] = " "
           c-literal[27] = " "
           c-literal[28] = " "
           c-literal[29] = " ".
          
    ASSIGN p-literal-autentica = STRING(c-literal[1],"x(48)")   + 
                                 STRING(c-literal[2],"x(48)")   + 
                                 STRING(c-literal[3],"x(48)")   + 
                                 STRING(c-literal[4],"x(48)")   + 
                                 STRING(c-literal[5],"x(48)")   + 
                                 STRING(c-literal[6],"x(48)")   + 
                                 STRING(c-literal[7],"x(48)")   + 
                                 STRING(c-literal[8],"x(48)")   + 
                                 STRING(c-literal[9],"x(48)")   + 
                                 STRING(c-literal[10],"x(48)")   + 
                                 STRING(c-literal[11],"x(48)")   + 
                                 STRING(c-literal[12],"x(48)")   +
                                 STRING(c-literal[13],"x(48)")   + 
                                 STRING(c-literal[14],"x(48)")   +
                                 STRING(c-literal[15],"x(48)")   + 
                                 STRING(c-literal[16],"x(48)")   +
                                 STRING(c-literal[17],"x(48)")   + 
                                 STRING(c-literal[18],"x(48)")   + 
                                 STRING(c-literal[19],"x(48)")   + 
                                 STRING(c-literal[20],"x(48)")   + 
                                 STRING(c-literal[21],"x(48)")   +
                                 STRING(c-literal[22],"x(48)")   + 
                                 STRING(c-literal[23],"x(48)")   + 
                                 STRING(c-literal[24],"x(48)")   + 
                                 STRING(c-literal[25],"x(48)")   + 
                                 STRING(c-literal[26],"x(48)")   + 
                                 STRING(c-literal[27],"x(48)")   + 
                                 STRING(c-literal[28],"x(48)")   + 
                                 STRING(c-literal[29],"x(48)") .   
 
    ASSIGN p-ult-sequencia-autentica = p-ult-sequencia.
    /*-----*/

    ASSIGN in99 = 0. 
    DO  WHILE TRUE:
        
        ASSIGN in99 = in99 + 1.
        FIND crapaut WHERE RECID(crapaut) = p-registro 
                           EXCLUSIVE-LOCK NO-ERROR  NO-WAIT.

        IF  NOT AVAIL   crapaut   THEN DO:
            IF  LOCKED crapaut   THEN DO:
                IF  in99 <  100  THEN DO:
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
                ELSE DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Tabela CRAPAUT em uso ".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
            END.
        END.
        ELSE DO:
            ASSIGN  crapaut.dslitera = p-literal-autentica.
            RELEASE crapaut.
            LEAVE.
        END.
    END.
  
    RELEASE craplot.
*/
    
    RETURN "OK".

END PROCEDURE.

/* b1crap90.p */

/* .......................................................................... */

