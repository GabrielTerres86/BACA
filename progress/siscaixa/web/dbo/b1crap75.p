/*=========NAO MAIS UTILIZADA  =========================================*/
/*======== Susbstituida pela bo b1crap77.p==============================*/
/*----------------------------------------------------------------------*/
/*  b1crap75.p   - Deposito Cheque Liberado (ESTORNO)                   */
/*  Historico    - 372                                                  */
/*  Autenticacao - RC                                                   */
/*
            21/05/2012 - substituição do FIND craptab para os registros 
                         CONTACONVE pela chamada do fontes ver_ctace.p
                         (Lucas R.)

            16/03/2018 - Substituida verificacao "cdtipcta = 6,7" pela
                         modalidade do tipo de conta igual a 3. PRJ366 (Lombardi).
------------------------------------------------------------------------*/

DEF VAR  in99                       AS INTE    NO-UNDO.

DEF VAR aux_lsconta1                  AS CHAR    NO-UNDO.
DEF VAR aux_lsconta2                  AS CHAR    NO-UNDO.
DEF VAR aux_lsconta3                  AS CHAR    NO-UNDO.
DEF VAR aux_lscontas                  AS CHAR    NO-UNDO.

DEF VAR i-nro-lote                    AS INTE    NO-UNDO.
DEF VAR c-docto                       AS CHAR    NO-UNDO.                  
DEF VAR l-achou                       AS LOGICAL NO-UNDO.
                                 
{dbo/bo-erro1.i}

DEFINE VARIABLE i-cod-erro            AS INT    NO-UNDO.
DEFINE VARIABLE c-desc-erro           AS CHAR   NO-UNDO.


PROCEDURE valida-pagto-cheque-liberado.
    
    DEF INPUT  PARAM p-cooper         AS CHAR.
    DEF INPUT  PARAM p-cod-agencia    AS INT.              /*Cod. Agencia   */
    DEF INPUT  PARAM p-nro-caixa      AS INT FORMAT "999". /*Numero Caixa   */  
    DEF INPUT  PARAM p-nro-conta      AS INTE.             /*Numero da Conta*/
    DEF INPUT  PARAM p-nro-docto      AS INTE.
    DEF OUTPUT PARAM p-valor1         AS DEC.
    DEF output PARAM p-valor          AS DEC.
    DEF OUTPUT PARAM p-poupanca       AS LOG.
    DEF OUTPUT PARAM p-nome-titular   AS CHAR.

    DEF VAR aux_cdmodali AS INTE      NO-UNDO.
    DEF VAR aux_des_erro AS CHAR      NO-UNDO.
    DEF VAR aux_dscritic AS CHAR      NO-UNDO.

    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper NO-ERROR.
         
    ASSIGN p-nro-conta = INT(REPLACE(string(p-nro-conta),".","")).

    ASSIGN p-poupanca = NO.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
   
    ASSIGN i-nro-lote = 11000 + p-nro-caixa.

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper 
                             NO-LOCK NO-ERROR.
                    
     /*  Le tabela com as contas convenio do Banco do Brasil - Geral  */

        RUN fontes/ver_ctace.p(INPUT crapcop.cdcooper,
                               INPUT 0,
                               OUTPUT aux_lscontas).

    IF  p-nro-conta = 0  THEN DO:
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

    IF  p-nro-docto = 0 THEN DO: 
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "Documento deve ser Informado ".           
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.

    IF   NOT CAN-DO(aux_lscontas,STRING(p-nro-conta))   THEN  DO:

         FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                            crapass.nrdconta = p-nro-conta    
                            NO-LOCK NO-ERROR.
         
         IF  NOT AVAIL crapass THEN DO: 
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
         
         IF   aux_cdmodali = 3 THEN  DO: /* Conta tipo Poupanca */
              ASSIGN p-poupanca = YES.
         END.
    END.

    ASSIGN c-docto = STRING(p-nro-docto) + "1".

    FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper  AND
                       craplcm.dtmvtolt = crapdat.dtmvtolt  AND
                       craplcm.cdagenci = p-cod-agencia     AND
                       craplcm.cdbccxlt = 11                AND  /* Fixo */
                       craplcm.nrdolote = i-nro-lote        AND
                       craplcm.nrdctabb = p-nro-conta       AND
                       craplcm.nrdocmto = INTE(c-docto)     
                       USE-INDEX craplcm1 NO-LOCK NO-ERROR.
    
    IF   AVAIL craplcm  and
         ENTRY(1, craplcm.cdpesqbb) = "CRAP55" THEN 
         ASSIGN l-achou  = YES
                p-valor1 = craplcm.vllanmto.
    
    ASSIGN c-docto = string(p-nro-docto) + "2".

    FIND FIRST craplcm WHERE craplcm.cdcooper = crapcop.cdcooper  AND
                             craplcm.dtmvtolt = crapdat.dtmvtolt  AND
                             craplcm.cdagenci = p-cod-agencia     AND
                             craplcm.cdbccxlt = 11                AND /* Fixo */
                             craplcm.nrdolote = i-nro-lote        AND
                             craplcm.nrdctabb = p-nro-conta       AND
                             craplcm.nrdocmto = inte(c-docto)
                             USE-INDEX craplcm1 NO-LOCK NO-ERROR.
   
    IF   AVAIL craplcm  and
         ENTRY(1, craplcm.cdpesqbb) = "CRAP55" THEN  
         ASSIGN l-achou = YES
                p-valor = craplcm.vllanmto.
 
    IF  l-achou = NO  THEN do:
        ASSIGN i-cod-erro  = 90
               c-desc-erro = " ". 
        run cria-erro (INPUT p-cooper,
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

    IF   NOT AVAIL   craplot   THEN  DO:
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

    IF   p-valor <> 0   THEN
         DO:
             FIND craptab WHERE  /*  Verifica o horario de corte  */
                  craptab.cdcooper = crapcop.cdcooper  AND
                  craptab.nmsistem = "CRED"            AND
                  craptab.tptabela = "GENERI"          AND
                  craptab.cdempres = 0                 AND
                  craptab.cdacesso = "HRTRCOMPEL"      AND
                  craptab.tpregist = 0                 NO-LOCK NO-ERROR.

             IF   NOT AVAIL craptab   THEN DO:
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
             IF   INT(SUBSTR(craptab.dstextab,1,1)) <> 0   THEN DO:
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
             IF   INT(SUBSTR(craptab.dstextab,3,5)) <= TIME   THEN DO:
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


 
PROCEDURE estorna-pagto-cheque-liberado.
  
    DEF INPUT PARAM p-cooper         AS CHAR.
    DEF INPUT PARAM p-cod-agencia    AS INTEGER. 
    DEF INPUT PARAM p-nro-caixa      AS INTEGER FORMAT "999".       
    DEF INPUT PARAM p-cod-operador   AS CHAR.
    DEF INPUT PARAM p-nro-conta      AS INTE.
    DEF INPUT PARAM p-nro-docto      AS INTE.
    DEF INPUT PARAM p-valor1         AS DEC.
    DEF INPUT PARAM p-valor          AS DEC.
    
    FIND crapcop WHERE
         crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
         
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    ASSIGN p-nro-conta = INT(REPLACE(string(p-nro-conta),".","")).

    ASSIGN i-nro-lote = 11000 + p-nro-caixa.
    
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    IF   p-valor <> 0   THEN
         DO:
             /* Verifica hor rio de Corte */
             
             FIND craptab WHERE                     
                  craptab.cdcooper = crapcop.cdcooper  AND
                  craptab.nmsistem = "CRED"            AND
                  craptab.tptabela = "GENERI"          AND
                  craptab.cdempres = 0                 AND
                  craptab.cdacesso = "HRTRCOMPEL"      AND
                  craptab.tpregist = 0                 NO-LOCK NO-ERROR.

             IF  NOT AVAIL craptab   THEN  DO:
                 ASSIGN i-cod-erro  = 676
                        c-desc-erro = " ".           
                 run cria-erro (INPUT p-cooper,
                                INPUT p-cod-agencia,
                                INPUT p-nro-caixa,
                                INPUT i-cod-erro,
                                INPUT c-desc-erro,
                                INPUT YES).
                 RETURN "NOK".
             END.    

             IF   INT(SUBSTR(craptab.dstextab,1,1)) <> 0   THEN DO:
                  ASSIGN i-cod-erro  = 677
                         c-desc-erro = " ".           
                  run cria-erro (INPUT p-cooper,
                                 INPUT p-cod-agencia,
                                 INPUT p-nro-caixa,
                                 INPUT i-cod-erro,
                                 INPUT c-desc-erro,
                                 INPUT YES).
                  RETURN "NOK".
             END.    

             IF   INT(SUBSTR(craptab.dstextab,3,5)) <= TIME   THEN DO:
                  ASSIGN i-cod-erro  = 676
                         c-desc-erro = " ".           
                  run cria-erro (INPUT p-cooper,
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

        FIND craplot WHERE
             craplot.cdcooper = crapcop.cdcooper  AND  
             craplot.dtmvtolt = crapdat.dtmvtolt  AND
             craplot.cdagenci = p-cod-agencia     AND
             craplot.cdbccxlt = 11                AND  /* Fixo */
             craplot.nrdolote = i-nro-lote 
             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF   NOT AVAIL   craplot   THEN  DO:
             IF   LOCKED craplot     THEN DO:
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
       
        FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper  AND 
                           craplcm.dtmvtolt = crapdat.dtmvtolt  AND
                           craplcm.cdagenci = p-cod-agencia     AND
                           craplcm.cdbccxlt = 11                AND  /* Fixo */
                           craplcm.nrdolote = i-nro-lote        AND
                           craplcm.nrdctabb = p-nro-conta       AND
                           craplcm.nrdocmto = p-nro-docto  USE-INDEX craplcm1
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF   NOT AVAIL   craplcm   THEN  DO:
             IF   LOCKED craplcm     THEN DO:

                  IF  in99 <  100  THEN DO:
                      PAUSE 1 NO-MESSAGE.
                      NEXT.
                  END.
                  ELSE DO:
                      ASSIGN i-cod-erro  = 0
                             c-desc-erro = "Tabela CRAPLCM em uso ".           
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


    FOR EACH  crapchd WHERE
              crapchd.cdcooper = crapcop.cdcooper  AND
              crapchd.dtmvtolt = craplcm.dtmvtolt  AND
              crapchd.cdagenci = craplcm.cdagenci  AND
              crapchd.cdbccxlt = craplcm.cdbccxlt  AND
              crapchd.nrdolote = craplcm.nrdolote  AND
              crapchd.nrseqdig = craplcm.nrseqdig 
              USE-INDEX crapchd3:
                          
        DELETE crapchd. 
    END.
           
    DELETE craplcm.

    ASSIGN craplot.qtcompln  = craplot.qtcompln - 1
           craplot.qtinfoln  = craplot.qtinfoln - 1
/* Vander */
/*         craplot.vlcompdb  = craplot.vlcompdb - p-valor
           craplot.vlinfodb  = craplot.vlinfodb - p-valor.*/
           craplot.vlcompcr  = craplot.vlcompcr - p-valor
           craplot.vlinfocr  = craplot.vlinfocr - p-valor.
/**********/
    
   IF  craplot.vlcompdb = 0 and
       craplot.vlinfodb = 0 and
       craplot.vlcompcr = 0 and
       craplot.vlinfocr = 0 THEN
       DELETE craplot.
   ELSE
      RELEASE craplot.

 
    RETURN "OK".
END PROCEDURE.

/* b1crap55.p */



