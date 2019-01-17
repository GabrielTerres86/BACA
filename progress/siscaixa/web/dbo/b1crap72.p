/*---------------------------------------------------------------------*/
/* b1crap72.p - Movimentacoes  - Estorno Deposito Cheque sem Captura   */       /*--------------------------------------------------------------------=*/
/*.............................................................................

Alteracoes: 02/03/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

            21/05/2012 - substituição do FIND craptab para os registros 
                         CONTACONVE pela chamada do fontes ver_ctace.p
                         (Lucas R.)

            16/03/2018 - Substituida verificacao "cdtipcta = 6,7" pela
                         modalidade do tipo de conta igual a 3. PRJ366 (Lombardi).

            18/06/2018 - Alteracoes para usar as rotinas mesmo com o processo 
                         norturno rodando (Douglas Pagel - AMcom).	

            15/10/2018 - Troca DELETE CRAPLCM pela chamada da rotina estorna_lancamento_conta 
                            de dentro da b1wgen0200 
                            (Renato AMcom)
                            
            16/01/2019 - Revitalizacao (Remocao de lotes) - Pagamentos, Transferencias, Poupanca
                     Heitor (Mouts)

.............................................................................. **/

{dbo/bo-erro1.i}
{ sistema/generico/includes/b1wgen0200tt.i }

DEFINE VARIABLE i-cod-erro                    AS INT                 NO-UNDO.
DEFINE VARIABLE c-desc-erro                   AS CHAR                NO-UNDO.

DEF VAR i-nro-lote                            AS INTE                NO-UNDO.
DEF VAR aux_nrdconta                          AS INTE                NO-UNDO.
DEF VAR i_conta                               AS DEC                 NO-UNDO.
DEF VAR aux_nrtrfcta LIKE  craptrf.nrsconta                NO-UNDO.
DEF VAR l-achou                               AS LOG                 NO-UNDO.

DEF VAR h_b2crap00                            AS HANDLE              NO-UNDO.
DEF VAR h-b1wgen0200                          AS HANDLE              NO-UNDO.

DEF VAR aux_cdcritic                          AS INTE                NO-UNDO.
DEF VAR aux_dscritic                          AS CHAR                NO-UNDO.

DEF VAR aux_contador                          AS INTE                NO-UNDO.
DEF VAR dt-menor-fpraca                       AS DATE                NO-UNDO.
DEF VAR dt-maior-praca                        AS DATE                NO-UNDO.
DEF VAR dt-menor-praca                        AS DATE                NO-UNDO.
DEF VAR dt-maior-fpraca                       AS DATE                NO-UNDO.
DEF VAR c-docto                               AS CHAR                NO-UNDO.
DEF VAR c-docto-salvo                         AS CHAR                NO-UNDO.
DEF VAR i-docto                               AS INTE                NO-UNDO.

DEF VAR aux_lscontas                          AS CHAR                NO-UNDO.
DEF VAR in99                                  AS INTE                NO-UNDO.

PROCEDURE valida-cheque-sem-captura.
    
    DEF INPUT  PARAM p-cooper                AS CHAR.
    DEF INPUT  PARAM p-cod-agencia           AS INTEGER.    
    DEF INPUT  PARAM p-nro-caixa             AS INTEGER.           
    DEF INPUT  PARAM p-nro-conta             AS INTEGER.       
    DEF INPUT  PARAM p-nrdocto               AS INTE.
    DEF OUTPUT PARAM p-valor-menor-praca     AS DEC.
    DEF OUTPUT PARAM p-valor-maior-praca     AS DEC.
    DEF OUTPUT PARAM p-valor-menor-fpraca    AS DEC.
    DEF OUTPUT PARAM p-valor-maior-fpraca    AS DEC.
    DEF OUTPUT PARAM p-data-menor-praca      AS DATE.
    DEF OUTPUT PARAM p-data-maior-praca      AS DATE.
    DEF OUTPUT PARAM p-data-menor-fpraca     AS DATE.
    DEF OUTPUT PARAM p-data-maior-fpraca     AS DATE.
    DEF OUTPUT PARAM p-nome-titular          AS CHAR.
    DEF OUTPUT PARAM p-poupanca              AS LOG.
    DEF OUTPUT PARAM p-dsidenti              AS CHAR.
      
    DEF VAR aux_cdmodali AS INTE             NO-UNDO.
    DEF VAR aux_des_erro AS CHAR             NO-UNDO.
    DEF VAR aux_dscritic AS CHAR             NO-UNDO.
    
    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.

    ASSIGN p-nro-conta = INT(REPLACE(STRING(p-nro-conta),".","")).

    ASSIGN p-poupanca     = NO
           p-nome-titular = " ".

    ASSIGN p-valor-menor-praca  = 0
           p-valor-maior-praca  = 0
           p-valor-menor-fpraca = 0
           p-valor-maior-fpraca = 0
           p-data-menor-praca   = ?
           p-data-maior-praca   = ?
           p-data-menor-fpraca  = ?
           p-data-maior-fpraca  = ?.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    ASSIGN i-nro-lote = 11000 + p-nro-caixa.
    
    IF  p-nrdocto = 0  THEN 
        DO:
            ASSIGN i-cod-erro  = 22
                    c-desc-erro = " ".  /* Documento deve ser Informado */                  RUN cria-erro (INPUT p-cooper,
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

    IF   NOT CAN-DO(aux_lscontas,STRING(p-nro-conta)) THEN 
        DO:
             FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                            crapass.nrdconta = p-nro-conta  
                            NO-LOCK NO-ERROR.
     
             IF  NOT AVAIL crapass  THEN  DO:
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
        
        IF   aux_cdmodali = 3 THEN  
        DO: /* Conta tipo Poupan‡a */
             ASSIGN p-poupanca = YES.
        END.
    END.
  
    ASSIGN l-achou = NO.

    ASSIGN c-docto = string(p-nrdocto) + "1".
    FIND FIRST craplcm WHERE
         craplcm.cdcooper = crapcop.cdcooper  AND
         craplcm.dtmvtolt = crapdat.dtmvtocd  AND
         craplcm.cdagenci = p-cod-agencia     AND
         craplcm.cdbccxlt = 11                AND /* Fixo */
         craplcm.nrdolote = i-nro-lote        AND
         craplcm.nrdctabb = p-nro-conta       AND
         craplcm.nrdocmto = inte(c-docto)     USE-INDEX craplcm1
         NO-LOCK NO-ERROR.
   

    IF   AVAIL craplcm  and
         ENTRY(1, craplcm.cdpesqbb) = "CRAP52" THEN 
            DO:
                ASSIGN l-achou             = YES.
                ASSIGN p-dsidenti          = craplcm.dsidenti.
                ASSIGN p-valor-menor-praca = craplcm.vllanmto.
        
         FIND FIRST crapdpb WHERE
                    crapdpb.cdcooper = crapcop.cdcooper  AND
                    crapdpb.dtmvtolt = crapdat.dtmvtocd  AND
                    crapdpb.cdagenci = p-cod-agencia     AND
                    crapdpb.cdbccxlt = 11                AND /* Fixo */
                    crapdpb.nrdolote = i-nro-lote        AND
                    crapdpb.nrdconta = p-nro-conta       AND
                    crapdpb.nrdocmto = inte(c-docto)     NO-LOCK NO-ERROR.

         IF  AVAIL crapdpb THEN
             ASSIGN p-data-menor-praca = crapdpb.dtliblan. 
    END.
        
    ASSIGN c-docto = string(p-nrdocto) + "2".
  
    FIND FIRST craplcm WHERE craplcm.cdcooper = crapcop.cdcooper  AND
                             craplcm.dtmvtolt = crapdat.dtmvtocd  AND
                             craplcm.cdagenci = p-cod-agencia     AND
                             craplcm.cdbccxlt = 11                AND /* Fixo */
                             craplcm.nrdolote = i-nro-lote        AND
                             craplcm.nrdctabb = p-nro-conta       AND
                             craplcm.nrdocmto = inte(c-docto)     
                             USE-INDEX craplcm1 NO-ERROR.

    IF   AVAIL craplcm  and
         ENTRY(1, craplcm.cdpesqbb) = "CRAP52" THEN 
            DO:

             ASSIGN l-achou = YES.
             ASSIGN p-dsidenti = craplcm.dsidenti.
             ASSIGN p-valor-maior-praca = craplcm.vllanmto.

         FIND FIRST crapdpb WHERE
                    crapdpb.cdcooper = crapcop.cdcooper  AND
                    crapdpb.dtmvtolt = crapdat.dtmvtocd  AND
                    crapdpb.cdagenci = p-cod-agencia     AND
                    crapdpb.cdbccxlt = 11                AND /* Fixo */
                    crapdpb.nrdolote = i-nro-lote        AND
                    crapdpb.nrdconta = p-nro-conta       AND
                    crapdpb.nrdocmto = inte(c-docto)     NO-LOCK NO-ERROR.

         IF  AVAIL crapdpb THEN  
            DO:
                  ASSIGN p-data-maior-praca = crapdpb.dtliblan. 
            END.
         ELSE 
            DO:
                  ASSIGN i-cod-erro  = 82
                         c-desc-erro = " ".           
                  RUN cria-erro (INPUT p-cooper,
                                 INPUT p-cod-agencia,
                                 INPUT p-nro-caixa,
                                 INPUT i-cod-erro,
                                 INPUT c-desc-erro,
                                 INPUT YES).
                  RETURN "NOK". 
            END.
         
         IF  crapdpb.inlibera = 2  THEN 
            DO:
                 ASSIGN i-cod-erro  = 220
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


    ASSIGN c-docto = string(p-nrdocto) + "3".

    FIND FIRST craplcm WHERE
               craplcm.cdcooper = crapcop.cdcooper  AND
               craplcm.dtmvtolt = crapdat.dtmvtocd  AND
               craplcm.cdagenci = p-cod-agencia     AND
               craplcm.cdbccxlt = 11                AND /* Fixo */
               craplcm.nrdolote = i-nro-lote        AND
               craplcm.nrdctabb = p-nro-conta       AND
               craplcm.nrdocmto = inte(c-docto)     
               USE-INDEX craplcm1 NO-LOCK NO-ERROR.

    IF   AVAIL craplcm  and
         ENTRY(1, craplcm.cdpesqbb) = "CRAP52" THEN DO:

         ASSIGN l-achou = YES.
         ASSIGN p-dsidenti = craplcm.dsidenti.
         ASSIGN p-valor-menor-fpraca = craplcm.vllanmto.
    
         FIND FIRST crapdpb WHERE
                    crapdpb.cdcooper = crapcop.cdcooper  AND
                    crapdpb.dtmvtolt = crapdat.dtmvtocd  AND
                    crapdpb.cdagenci = p-cod-agencia     AND
                    crapdpb.cdbccxlt = 11                AND /* Fixo */
                    crapdpb.nrdolote = i-nro-lote        AND
                    crapdpb.nrdconta = p-nro-conta       AND
                    crapdpb.nrdocmto = inte(c-docto)     NO-LOCK NO-ERROR.

         IF  AVAIL crapdpb THEN 
         DO:
                ASSIGN p-data-menor-fpraca = crapdpb.dtliblan. 
            END.
            ELSE DO:
                ASSIGN i-cod-erro  = 82
                       c-desc-erro = " ".           
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                RETURN "NOK". 
            END.
         IF  crapdpb.inlibera = 2  THEN
             DO:
                 ASSIGN i-cod-erro  = 220
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

    ASSIGN c-docto = string(p-nrdocto) + "4".

    FIND FIRST craplcm WHERE
               craplcm.cdcooper = crapcop.cdcooper  AND
               craplcm.dtmvtolt = crapdat.dtmvtocd  AND
               craplcm.cdagenci = p-cod-agencia     AND
               craplcm.cdbccxlt = 11                AND /* Fixo */
               craplcm.nrdolote = i-nro-lote        AND
               craplcm.nrdctabb = p-nro-conta       AND
               craplcm.nrdocmto = inte(c-docto)     
               USE-INDEX craplcm1 NO-LOCK NO-ERROR.
   
    IF   AVAIL craplcm  AND
         ENTRY(1, craplcm.cdpesqbb) = "CRAP52" THEN 
            DO:

                ASSIGN l-achou = YES.
                ASSIGN p-dsidenti = craplcm.dsidenti.
                ASSIGN p-valor-maior-fpraca = craplcm.vllanmto.
        
         FIND FIRST crapdpb WHERE
                    crapdpb.cdcooper = crapcop.cdcooper  AND
                    crapdpb.dtmvtolt = crapdat.dtmvtocd  AND
                    crapdpb.cdagenci = p-cod-agencia     AND
                    crapdpb.cdbccxlt = 11                AND /* Fixo */
                    crapdpb.nrdolote = i-nro-lote        AND
                    crapdpb.nrdconta = p-nro-conta       AND
                    crapdpb.nrdocmto = inte(c-docto)     NO-LOCK NO-ERROR.

         IF  AVAIL crapdpb THEN DO:
             ASSIGN p-data-maior-fpraca = crapdpb.dtliblan. 
         END.
         ELSE   
         DO:
             ASSIGN i-cod-erro  = 82
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK". 
         END.
         IF  crapdpb.inlibera = 2  THEN 
             DO:
                 ASSIGN i-cod-erro  = 220
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
                       craplot.dtmvtolt = crapdat.dtmvtocd  AND
                       craplot.cdagenci = p-cod-agencia     AND
                       craplot.cdbccxlt = 11                AND  /* Fixo */
                       craplot.nrdolote = i-nro-lote        NO-LOCK  NO-ERROR .

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

    RETURN "OK".

END PROCEDURE.

   


PROCEDURE estorna-cheque-sem-captura.
    
    DEF INPUT  PARAM p-cooper                AS CHAR.
    DEF INPUT  PARAM p-cod-agencia           AS INTEGER.    
    DEF INPUT  PARAM p-nro-caixa             AS INTEGER.      
    DEF INPUT  PARAM p-cod-operador          AS CHAR.
    DEF INPUT  PARAM p-nro-conta             AS INTEGER.    
    DEF INPUT  PARAM p-nrdocto               AS INTE.
    DEF INPUT  PARAM p-valor-menor-praca     aS dec.
    DEF INPUT  PARAM p-valor-maior-praca     AS DEC.
    DEF INPUT  PARAM p-valor-menor-fpraca    AS dec.
    DEF INPUT  PARAM p-valor-maior-fpraca    AS DEC.
    DEF OUTPUT PARAM p-valor                 AS DEC.
    
      
    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.
 
                                                  
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    ASSIGN p-nro-conta = INT(REPLACE(string(p-nro-conta),".","")).

    ASSIGN i-nro-lote = 11000 + p-nro-caixa.
  
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
               
    ASSIGN in99 = 0.
    DO  WHILE TRUE:

        ASSIGN in99 = in99 + 1.

        FIND craplot WHERE
             craplot.cdcooper = crapcop.cdcooper  AND 
             craplot.dtmvtolt = crapdat.dtmvtocd  AND
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

    IF  p-valor-menor-praca > 0  THEN DO:
        ASSIGN c-docto = string(p-nrdocto) + "1".
        ASSIGN in99 = 0.
        DO  WHILE TRUE:
            ASSIGN in99 = in99 + 1.
           
            FIND craplcm WHERE
                 craplcm.cdcooper = crapcop.cdcooper  AND
                 craplcm.dtmvtolt = crapdat.dtmvtocd  AND
                 craplcm.cdagenci = p-cod-agencia     AND
                 craplcm.cdbccxlt = 11                AND /* Fixo */
                 craplcm.nrdolote = i-nro-lote        AND
                 craplcm.nrdctabb = p-nro-conta       AND
                 craplcm.nrdocmto = inte(c-docto)   USE-INDEX craplcm1
                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
            IF   NOT AVAIL   craplcm THEN DO:
                 IF   LOCKED craplcm THEN DO:
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
                      run cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                 END.

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
    
        ASSIGN in99 = 0.
        DO  WHILE TRUE:
            ASSIGN in99 = in99 + 1.

            FIND FIRST  crapdpb WHERE
                        crapdpb.cdcooper = crapcop.cdcooper  AND
                        crapdpb.dtmvtolt = crapdat.dtmvtocd  AND
                        crapdpb.cdagenci = p-cod-agencia     AND
                        crapdpb.cdbccxlt = 11                AND /* Fixo */
                        crapdpb.nrdolote = i-nro-lote        AND
                        crapdpb.nrdconta = p-nro-conta       AND
                        crapdpb.nrdocmto = inte(c-docto) 
                        EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
  
            IF   NOT AVAIL   crapdpb THEN DO:
                 IF   LOCKED crapdpb THEN DO:
                      IF  in99 <  100  THEN DO:
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                      END.
                      ELSE DO:
                          ASSIGN i-cod-erro  = 0
                                 c-desc-erro = "Tabela CRAPDPB em uso ".           
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
                      ASSIGN i-cod-erro  = 82
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

            DELETE crapdpb.
            LEAVE.
        END.  /*  DO WHILE */
   
        ASSIGN craplot.qtcompln  = craplot.qtcompln - 1
               craplot.qtinfoln  = craplot.qtinfoln - 1
               craplot.vlcompcr  = craplot.vlcompcr - p-valor-menor-praca
               craplot.vlinfocr  = craplot.vlinfocr - p-valor-menor-praca.
    END.

    IF  p-valor-maior-praca > 0 THEN DO: 
        ASSIGN c-docto = string(p-nrdocto) + "2".
        ASSIGN in99 = 0.
        DO  WHILE TRUE:
            ASSIGN in99 = in99 + 1.

            FIND craplcm WHERE
                 craplcm.cdcooper = crapcop.cdcooper  AND
                 craplcm.dtmvtolt = crapdat.dtmvtocd  AND
                 craplcm.cdagenci = p-cod-agencia     AND
                 craplcm.cdbccxlt = 11                AND /* Fixo */
                 craplcm.nrdolote = i-nro-lote        AND
                 craplcm.nrdctabb = p-nro-conta       AND
                 craplcm.nrdocmto = inte(c-docto)  USE-INDEX craplcm1
                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
            IF   NOT AVAIL   craplcm THEN DO:
                 IF   LOCKED craplcm THEN DO:
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

        ASSIGN in99 = 0.
        DO  WHILE TRUE:
            ASSIGN in99 = in99 + 1.
      
            FIND FIRST  crapdpb WHERE
                        crapdpb.cdcooper = crapcop.cdcooper  AND
                        crapdpb.dtmvtolt = crapdat.dtmvtocd  AND
                        crapdpb.cdagenci = p-cod-agencia     AND
                        crapdpb.cdbccxlt = 11                AND /* Fixo */
                        crapdpb.nrdolote = i-nro-lote        AND
                        crapdpb.nrdconta = p-nro-conta       AND
                        crapdpb.nrdocmto = inte(c-docto) 
                        EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
  
            IF   NOT AVAIL   crapdpb THEN DO:
                 IF   LOCKED crapdpb THEN DO:
                      IF  in99 <  100  THEN DO:
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                      END.
                      ELSE DO:
                          ASSIGN i-cod-erro  = 0
                                 c-desc-erro = "Tabela CRAPDPB em uso ".           
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
                
                      ASSIGN i-cod-erro  = 82
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
            DELETE crapdpb.
            LEAVE.
        END.  /*  DO WHILE */
     
        ASSIGN craplot.qtcompln  = craplot.qtcompln - 1
               craplot.qtinfoln  = craplot.qtinfoln - 1
               craplot.vlcompcr  = craplot.vlcompcr - p-valor-maior-praca
               craplot.vlinfocr  = craplot.vlinfocr - p-valor-maior-praca.
    END.

    IF  p-valor-menor-fpraca > 0  THEN DO:
        ASSIGN c-docto = string(p-nrdocto) + "3".
        ASSIGN in99   = 0.
        DO  WHILE TRUE:
            assign in99 = in99 + 1.
           
            FIND craplcm WHERE
                 craplcm.cdcooper = crapcop.cdcooper  AND
                 craplcm.dtmvtolt = crapdat.dtmvtocd  AND
                 craplcm.cdagenci = p-cod-agencia     AND
                 craplcm.cdbccxlt = 11                AND /* Fixo */
                 craplcm.nrdolote = i-nro-lote        AND
                 craplcm.nrdctabb = p-nro-conta       AND
                 craplcm.nrdocmto = inte(c-docto)   USE-INDEX craplcm1 
                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

             IF  NOT AVAIL   craplcm THEN DO:
                 IF   LOCKED craplcm THEN DO:
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

        ASSIGN in99 = 0.
        DO  WHILE TRUE:
            ASSIGN in99 = in99 + 1.

            FIND FIRST  crapdpb WHERE
                        crapdpb.cdcooper = crapcop.cdcooper  AND
                        crapdpb.dtmvtolt = crapdat.dtmvtocd  AND
                        crapdpb.cdagenci = p-cod-agencia     AND
                        crapdpb.cdbccxlt = 11                AND /* Fixo */
                        crapdpb.nrdolote = i-nro-lote        AND
                        crapdpb.nrdconta = p-nro-conta       AND
                        crapdpb.nrdocmto = inte(c-docto) 
                        EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
  
            IF   NOT AVAIL   crapdpb THEN DO:
                 IF   LOCKED crapdpb THEN DO:
                      IF  in99 <  100  THEN DO:
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                      END.
                      ELSE DO:
                          ASSIGN i-cod-erro  = 0
                                 c-desc-erro = 
                                 "Tabela CRAPDPB em uso ".           
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
                
                      ASSIGN i-cod-erro  = 82
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

            DELETE crapdpb.
            LEAVE.
        END.  /*  DO WHILE */
    
        ASSIGN craplot.qtcompln  = craplot.qtcompln - 1
               craplot.qtinfoln  = craplot.qtinfoln - 1
               craplot.vlcompcr  = craplot.vlcompcr - p-valor-menor-fpraca
               craplot.vlinfocr  = craplot.vlinfocr - p-valor-menor-fpraca.
    END.

    IF  p-valor-maior-fpraca > 0  THEN DO:
        ASSIGN c-docto = string(p-nrdocto) + "4".
        ASSIGN in99 = 0.
        DO  WHILE TRUE:
            ASSIGN in99 = in99 + 1.
          
            FIND  craplcm WHERE
                  craplcm.cdcooper = crapcop.cdcooper  AND
                  craplcm.dtmvtolt = crapdat.dtmvtocd  AND
                  craplcm.cdagenci = p-cod-agencia     AND
                  craplcm.cdbccxlt = 11                AND /* Fixo */
                  craplcm.nrdolote = i-nro-lote        AND
                  craplcm.nrdctabb = p-nro-conta       AND
                  craplcm.nrdocmto = inte(c-docto)   USE-INDEX craplcm1 
                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

             IF   NOT AVAIL   craplcm THEN 
                DO:
                     IF   LOCKED craplcm THEN 
                        DO:
                              IF  in99 <  100  THEN 
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                              ELSE 
                                DO:
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

        ASSIGN in99 = 0.
        DO  WHILE TRUE:
            ASSIGN in99 = in99 + 1.
           
            FIND FIRST crapdpb WHERE
                       crapdpb.cdcooper = crapcop.cdcooper  AND
                       crapdpb.dtmvtolt = crapdat.dtmvtocd  AND
                       crapdpb.cdagenci = p-cod-agencia     AND
                       crapdpb.cdbccxlt = 11                AND /* Fixo */
                       crapdpb.nrdolote = i-nro-lote        AND
                       crapdpb.nrdconta = p-nro-conta       AND
                       crapdpb.nrdocmto = inte(c-docto) 
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF   NOT AVAIL   crapdpb THEN DO:
                 IF   LOCKED crapdpb THEN DO:
                      IF  in99 <  100  THEN DO:
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                      END.
                      ELSE DO:
                          ASSIGN i-cod-erro  = 0
                                 c-desc-erro = "Tabela CRAPDPB em uso ".           
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
                
                      ASSIGN i-cod-erro  = 82
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
            
             DELETE crapdpb.
             LEAVE.
         END.  /*  DO WHILE */
           
         ASSIGN craplot.qtcompln  = craplot.qtcompln - 1
                craplot.qtinfoln  = craplot.qtinfoln - 1
                craplot.vlcompcr  = craplot.vlcompcr - p-valor-maior-fpraca
                craplot.vlinfocr  = craplot.vlinfocr - p-valor-maior-fpraca.
   END.

   IF  craplot.vlcompdb = 0 and
       craplot.vlinfodb = 0 and
       craplot.vlcompcr = 0 and
       craplot.vlinfocr = 0 THEN
       DELETE craplot.
   ELSE
      RELEASE craplot.

   ASSIGN  p-valor    = p-valor-menor-praca  + 
                        p-valor-maior-praca  +
                        p-valor-menor-fpraca +
                        p-valor-maior-fpraca.

   RETURN "OK".
END PROCEDURE.


/* b1crap72.p */
