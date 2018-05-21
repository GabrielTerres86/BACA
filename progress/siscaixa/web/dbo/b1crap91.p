/*----------------------------------------------------------------------------
    
    b1crap91.p - Estorno Pagamento de Emprestimo (Sem Conta Corrente)

    Ultima atualizacao: 

    Alteracoes:


----------------------------------------------------------------------------*/

{ dbo/bo-erro1.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0002tt.i }

DEF VAR i-cod-erro          AS INT                              NO-UNDO.
DEF VAR c-desc-erro         AS CHAR                             NO-UNDO.
                           
DEF VAR i-nro-lote          AS INTE                             NO-UNDO.
DEF VAR i_conta             AS DEC                              NO-UNDO.
DEF VAR aux_nrtrfcta        LIKE  craptrf.nrsconta              NO-UNDO.
DEF VAR inc_nrctremp        LIKE  crapepr.nrctremp              NO-UNDO.
DEF VAR l-achou             AS LOG                              NO-UNDO.
                                  
DEF VAR h_b2crap00          AS HANDLE                           NO-UNDO.
                                                      
DEF VAR aux_lscontas        AS CHAR                             NO-UNDO.
DEF VAR aux_dtultpag        AS DATE                             NO-UNDO.
DEF VAR aux_txdjuros        AS DECI                             NO-UNDO.
DEF VAR aux_vlsdeved        AS DECI                             NO-UNDO.
DEF VAR in99                AS INTE                             NO-UNDO.
DEF BUFFER crabass          FOR crapass.
DEF  VAR glb_cdcooper       AS INT                              NO-UNDO.



PROCEDURE valida-estorno.
    
    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-agencia   AS INT.   /* Cod. Agencia    */
    DEF INPUT  PARAM p-nro-caixa     AS INT.   /* Nro Caixa       */
    DEF INPUT  PARAM p-nro-conta     AS INT.   /* Nro Conta       */
    DEF INPUT  PARAM p-nrdocto       AS INT.
    DEF INPUT  PARAM p-cod-operador  AS CHAR.
    DEF OUTPUT PARAM p-valor         AS DEC.
    DEF OUTPUT PARAM p-nome-titular  AS CHAR.
    DEF OUTPUT PARAM p-mensagem      AS CHAR.

    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.

    ASSIGN p-nro-conta = INT(REPLACE(STRING(p-nro-conta),".","")).

    ASSIGN p-nome-titular = " "
           p-valor        = 0
           p-mensagem     = " ".
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).




    /****** CHAMADA ORACLE *****/

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    /* Efetuar a chamada da rotina Oracle */
    MESSAGE "BO091 - valida-estorno - "
            " (p-cooper)      : " inte(crapcop.cdcooper)
            " (p-cod-agencia) : " inte(p-cod-agencia)
            " (p-nro-caixa)   : " inte(p-nro-caixa)   
            " (p-nro-conta)   : " inte(p-nro-conta)
            " (p-nrdocto)     : " inte(p-nrdocto)
.

    RUN STORED-PROCEDURE pc_valida_estorno_emprest
         aux_handproc = PROC-HANDLE NO-ERROR
                                ( INPUT crapcop.cdcooper,
                                  INPUT inte(p-cod-agencia),  /* cdagenci */
                                  INPUT inte(p-nro-caixa),    /* nrdcaixa */
                                  INPUT inte(p-nro-conta),    /* NrdConta */
                                  INPUT inte(p-nrdocto),      /* NrDocmto */
                                  INPUT 2,                   /* 2 - CAIXA */
                                  INPUT p-cod-operador,      /* cdoperad  */
                                  INPUT "CRAP090",           /* nmdatela  */
                                  /* OUT */
                                 OUTPUT 0 ,  /* pr_valorest */
                                 OUTPUT "",  /* pr_nmprimtl */
                                 OUTPUT "",  /* pr_dsmensag */
                                 OUTPUT "",  /* pr_retorno  */
                                 OUTPUT 0 ,  /* pr_cdcritic */
                                 OUTPUT ""). /* pr_dscritic */

    MESSAGE "BO091 - valida-estorno: Passo 2".

    /* Fechar o procedimento para buscarmos o resultado */
    CLOSE STORED-PROC pc_valida_estorno_emprest
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    MESSAGE "BO091 - valida-estorno: Passo 3".
    /* Busca possíveis erros */
    ASSIGN i-cod-erro = 0
           c-desc-erro = ""
           i-cod-erro = pc_valida_estorno_emprest.pr_cdcritic
                          WHEN pc_valida_estorno_emprest.pr_cdcritic <> ?
           c-desc-erro = pc_valida_estorno_emprest.pr_dscritic
                          WHEN pc_valida_estorno_emprest.pr_dscritic <> ?

           p-valor        = pc_valida_estorno_emprest.pr_valorest
                          WHEN pc_valida_estorno_emprest.pr_valorest <> ?           
           p-nome-titular = pc_valida_estorno_emprest.pr_nmprimtl
                          WHEN pc_valida_estorno_emprest.pr_nmprimtl <> ?
           p-mensagem     = pc_valida_estorno_emprest.pr_dsmensag
                          WHEN pc_valida_estorno_emprest.pr_dsmensag <> ?
        /*   aux_retorno  = pc_valida_estorno_emprest.pr_retorno
                          WHEN pc_valida_estorno_emprest.pr_retorno <> ?*/
        .

    MESSAGE "BO091 - valida-estorno: Passo 4 - "
               " p-valor       : " p-valor
               " p-nome-titular: " p-nome-titular
               " p-mensagem    : " p-mensagem.

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
    /******/


END PROCEDURE.

PROCEDURE estorna-pagto.                
    
    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-agencia   AS INT.    /* Cod. Agencia       */
    DEF INPUT  PARAM p-nro-caixa     AS INT.    /* Numero Caixa       */
    DEF INPUT  PARAM p-cod-operador  AS CHAR.
    DEF INPUT  PARAM p-nro-conta     AS INT.    /* Nro Conta          */
    DEF INPUT  PARAM p-nrdocto       AS INT.

    DEF OUTPUT PARAM p-valor-est               AS DEC.
    DEF OUTPUT PARAM p-ult-sequencia-autentica AS INTE.
    DEF OUTPUT PARAM p-literal-autentica       AS CHAR. 

    DEF VAR          h-b1wgen0043    AS HANDLE             NO-UNDO.
    DEF VAR  aux_literal AS CHAR                           NO-UNDO.


    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.

    ASSIGN p-nro-conta = INT(REPLACE(STRING(p-nro-conta),".","")).

    ASSIGN p-literal-autentica       = " "
           p-valor-est               = 0
           p-ult-sequencia-autentica = 0.
 
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).


    /****** CHAMADA ORACLE *****/

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    /* Efetuar a chamada da rotina Oracle */
    MESSAGE "BO091 - efetua-estorno: Passo 1 "
            " (p-cooper)      : " inte(crapcop.cdcooper)
            " (p-cod-agencia) : " inte(p-cod-agencia)
            " (p-nro-caixa)   : " inte(p-nro-caixa)   
            " (p-nro-conta)   : " inte(p-nro-conta)
            " (p-nrdocto)     : " inte(p-nrdocto)
            " (p-cod-operador): " p-cod-operador.


    RUN STORED-PROCEDURE pc_estorna_pagto_emprest
         aux_handproc = PROC-HANDLE NO-ERROR
                                ( INPUT crapcop.cdcooper,
                                  INPUT inte(p-cod-agencia),  /* cdagenci */
                                  INPUT inte(p-nro-caixa),    /* nrdcaixa */
                                  INPUT inte(p-nro-conta),    /* NrdConta */
                                  INPUT inte(p-nrdocto),      /* NrDocmto */
                                  INPUT 2,                   /* 2 - CAIXA */
                                  INPUT p-cod-operador,      /* cdoperad  */
                                  INPUT "CRAP090",           /* nmdatela  */
                                  /* OUT */
                                 OUTPUT 0 ,  /* pr_valorest */
                                 OUTPUT 0 ,  /* pr_nrdocaut */
                                 OUTPUT "",  /* pr_dslitera */
                                 OUTPUT "",  /* pr_dsmensag */
                                 OUTPUT "",  /* pr_retorno  */
                                 OUTPUT 0 ,  /* pr_cdcritic */
                                 OUTPUT ""). /* pr_dscritic */

    MESSAGE "BO091 - efetua-estorno: Passo 2".

    /* Fechar o procedimento para buscarmos o resultado */
    CLOSE STORED-PROC pc_estorna_pagto_emprest
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    MESSAGE "BO091 - efetua-estorno: Passo 3".
    /* Busca possíveis erros */
    ASSIGN i-cod-erro = 0
           c-desc-erro = ""
           i-cod-erro = pc_estorna_pagto_emprest.pr_cdcritic
                          WHEN pc_estorna_pagto_emprest.pr_cdcritic <> ?
           c-desc-erro = pc_estorna_pagto_emprest.pr_dscritic
                          WHEN pc_estorna_pagto_emprest.pr_dscritic <> ?

           p-valor-est  = pc_estorna_pagto_emprest.pr_valorest
                           WHEN pc_estorna_pagto_emprest.pr_valorest <> ?           

           p-literal-autentica  = pc_estorna_pagto_emprest.pr_dslitera
                          WHEN pc_estorna_pagto_emprest.pr_dslitera <> ?

           aux_literal = pc_estorna_pagto_emprest.pr_retorno
                          WHEN pc_estorna_pagto_emprest.pr_retorno <> ?

            .

    p-ult-sequencia-autentica = INTE(aux_literal).

    MESSAGE "BO091 - efetua-estorno: Passo 4 - "
               " p-valor-est   : " p-valor-est
               " aux_literal   : " aux_literal
               " p-ult-sequencia-autentica: " p-ult-sequencia-autentica
               " p-literal-autentica    : " p-literal-autentica

               .

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
    /******/







/*


               
    FIND craplem WHERE craplem.cdcooper = crapcop.cdcooper  AND
                       craplem.dtmvtolt = crapdat.dtmvtolt  AND
                       craplem.cdagenci = p-cod-agencia     AND
                       craplem.cdbccxlt = 11                AND
                       craplem.nrdolote = i-nro-lote        AND
                       craplem.nrdconta = p-nro-conta       AND
                       craplem.nrdocmto = p-nrdocto         NO-LOCK NO-ERROR.
       
    IF   NOT AVAIL   craplem THEN DO:
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

    FIND crapepr WHERE 
         crapepr.cdcooper = crapcop.cdcooper  AND
         crapepr.nrdconta = craplem.nrdconta  AND
         crapepr.nrctremp = craplem.nrctremp  NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapepr   THEN DO:
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

    ASSIGN in99 = 0.
    DO WHILE TRUE:    
        ASSIGN in99 = in99 + 1.

        FIND craplot WHERE
             craplot.cdcooper = crapcop.cdcooper  AND
             craplot.dtmvtolt = crapdat.dtmvtolt  AND
             craplot.cdagenci = p-cod-agencia     AND
             craplot.cdbccxlt = 11                AND  /* Fixo */
             craplot.nrdolote = i-nro-lote      
             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF   NOT AVAIL   craplot   THEN DO:
             IF   LOCKED craplot   THEN DO:
                  IF  in99 <  100  THEN DO:
                      PAUSE 1 NO-MESSAGE.
                      NEXT.
                  END.
                  ELSE DO:
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
             ELSE DO:
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

    ASSIGN in99 = 0.
    DO  WHILE TRUE:
        ASSIGN in99 = in99 + 1.
            
        FIND craplem WHERE craplem.cdcooper = crapcop.cdcooper  AND
                           craplem.dtmvtolt = crapdat.dtmvtolt  AND
                           craplem.cdagenci = p-cod-agencia     AND
                           craplem.cdbccxlt = 11                AND
                           craplem.nrdolote = i-nro-lote        AND
                           craplem.nrdconta = p-nro-conta       AND
                           craplem.nrdocmto = p-nrdocto        
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
        IF   NOT AVAIL   craplem THEN DO:
             IF   LOCKED craplem THEN DO:
                  IF  in99 <  100  THEN DO:
                      PAUSE 1 NO-MESSAGE.
                      NEXT.
                  END.
                  ELSE DO:
                      ASSIGN i-cod-erro  = 0
                             c-desc-erro = "Tabela CRAPLEM em uso ".           
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
         LEAVE.
    END.  /*  DO WHILE */
    
    ASSIGN p-valor = craplem.vllanmto.
    
    ASSIGN craplot.qtcompln  = craplot.qtcompln - 1
           craplot.qtinfoln  = craplot.qtinfoln - 1
           craplot.vlcompcr  = craplot.vlcompcr - p-valor
           craplot.vlinfocr  = craplot.vlinfocr - p-valor.

    IF  craplot.vlcompdb = 0 and
        craplot.vlinfodb = 0 and
        craplot.vlcompcr = 0 and
        craplot.vlinfocr = 0 THEN
        DELETE craplot.
    ELSE
        RELEASE craplot.

    ASSIGN in99 = 0.
    DO  WHILE TRUE:
       
        FIND crapepr WHERE 
             crapepr.cdcooper = crapcop.cdcooper  AND
             crapepr.nrdconta = craplem.nrdconta  AND
             crapepr.nrctremp = craplem.nrctremp  
             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
        ASSIGN in99 = in99 + 1.
        IF   NOT AVAIL   crapepr   THEN DO:
             IF   LOCKED crapepr   THEN DO:
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

   ASSIGN aux_dtultpag = crapepr.dtmvtolt
          p-autestorno = craplem.nrautdoc.

   DELETE craplem.

   FOR EACH craplem
      WHERE craplem.cdcooper = crapcop.cdcooper
        AND craplem.nrdconta = crapepr.nrdconta
        AND craplem.nrctremp = crapepr.nrctremp
    NO-LOCK:

       FIND craphis 
           WHERE craphis.cdcooper = crapcop.cdcooper
             AND craphis.cdhistor = craplem.cdhistor NO-LOCK NO-ERROR.

       IF   NOT AVAILABLE craphis   THEN
            NEXT.

       IF   craphis.indebcre = "C"   THEN
            aux_dtultpag = craplem.dtmvtolt.

   END.  /*  Fim do FOR EACH  --  Pesquisa do ultimo pagamento  */

   ASSIGN crapepr.dtultpag = aux_dtultpag
          crapepr.txjuremp = aux_txdjuros.
   
   ASSIGN crapepr.inliquid = IF 
                            (aux_vlsdeved + p-valor) > 0
                             THEN 0
                             ELSE 1.

   RUN sistema/generico/procedures/b1wgen0043.p PERSISTENT SET h-b1wgen0043.

   RUN ativa_rating IN h-b1wgen0043 (INPUT crapepr.cdcooper,
                                     INPUT 0,
                                     INPUT 0,
                                     INPUT p-cod-operador,
                                     INPUT crapdat.dtmvtolt,
                                     INPUT crapdat.dtmvtopr,
                                     INPUT crapepr.nrdconta,
                                     INPUT 90, /* Emprestimo */
                                     INPUT crapepr.nrctremp,
                                     INPUT TRUE,
                                     INPUT 1,
                                     INPUT 2, /*Caixa On-line*/
                                     INPUT "b1crap91",
                                     INPUT 1,
                                     INPUT FALSE,
                                     OUTPUT TABLE tt-erro). 
   DELETE PROCEDURE h-b1wgen0043.

   IF   RETURN-VALUE <> "OK"   THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF   AVAIL tt-erro   THEN
             ASSIGN i-cod-erro  = tt-erro.cdcritic
                    c-desc-erro = " ".           
        ELSE
             ASSIGN c-desc-erro = "Erro na ativaçao do Rating.".
        
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).

        RELEASE crapepr.

        RETURN "NOK".
    END.

   RELEASE crapepr.
   
   RETURN "OK".
*/



END PROCEDURE.

/* b1crap91.p */

