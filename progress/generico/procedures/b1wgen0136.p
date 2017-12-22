/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +------------------------------------------+---------------------------------+
  | Rotina Progress                          | Rotina Oracle PLSQL             |
  +------------------------------------------+---------------------------------+
  | sistema/generico/procedures/b1wgen0136.p | EMPR0001                        |
  |      busca_dias_atraso_epr               |    fn_busca_dias_atraso_epr     |
  |      grava_liquidacao_empr               |    pc_grava_liquidacao_empr     |
  |      verifica_liquidacao_empr            |    pc_verifica_liquidacao_empr  |
  |      efetua_liquidacao_empr              |    pc_efetua_liquidacao_empr    |
  |      cria-atualiza-ttlancconta           |    pc_cria_atualiza_ttlanconta  |
  |      efetiva_pagamento_antecipado_craplem|    pc_efetiva_pagto_antec_lem   |  
  +------------------------------------------+---------------------------------+

  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/* ............................................................................

   Programa: sistema/generico/procedures/b1wgen0136.p
   Autor   : Gabriel
   Data    : Maio/2012                           Ultima atualizacao: 20/12/2017

   Dados referentes ao programa:

   Objetivo: BO com as rotinas da liquidacao do Emprestimo.

   Alteracoes: 21/11/2012 - Adicionar a função que calcula o número de 
                            dias atraso novo emprestimo (Oscar).

               04/04/2013 - Alterar funcao do calculo de dias em atraso
                            para considerar o dia anterior ao atual (Gabriel) 

               04/07/2013 - 2a. fase Projeto Credito (Gabriel).                

               21/08/2013 - Incluso o historico 1059 na consulta de Debitos (Lucas).

               17/10/2013 - GRAVAMES - Solicitacao Baixa Automatica
                            (Guilherme/SUPERO).
                            
               04/11/2013 - Ajuste para inclusao do parametro cdpactra 
                            - grava_liquidacao_empr 
                            - efetua_liquidacao_empr
                            - cria-atualiza-ttlancconta
                           (Adriano).
                           
               29/11/2013 - Alimentado o campo tt-lancconta.cdpactra
                            na procedure cria-atualiza-ttlancconta
                            (Adriano).
                           
               06/01/2014 - Ajuste na procedure "efetua_liquidacao_empr" para
                            lancar na conta valor da multa e juros de mora 
                            (James)
                            
               18/03/2014 - Correcao leitura crapepr quando LOCKED (Daniel). 
               
               11/06/2014 - Incluir parametro nrseqava na procedure 
                            "efetua_liquidacao_empr". (James)
                            
               31/03/2015 - Ajuste na procedure "grava_liquidacao_empr" para
                            verificar se houve estorno de parcela para os
                            historicos de emprestimo e financiamento. (James)
                            
               19/08/2015 - Adicionado data de liquidacao ao liquidar contratos
                            de emprestimo (Reinert)
                            
               08/10/2015 - Adicionado mais informacoes no log no momento do pagamento
                            das parcelas de emprestimo. SD 317004 (Kelvin)
                            
               08/10/2015 - Incluir os históricos de estorno no ajuste do saldo devedor PP (Oscar).
               
               20/10/2015 - Incluir os históricos de ajuste o contrato liquidado pode ser reaberto (Oscar).
               
               05/11/2015 - Incluso novo parametro "par_cdorigem" na procedure 
                            "grava_liquidacao_empr" (Daniel)
 
............................................................................ */

{ sistema/generico/includes/var_internet.i  }
{ sistema/generico/includes/gera_erro.i     }
{ sistema/generico/includes/gera_log.i      }
{ sistema/generico/includes/b1wgen0136tt.i  }
{ sistema/generico/includes/b1wgen0084att.i }

DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.


FUNCTION busca_dias_atraso_epr RETURN INT(INPUT par_cdcooper AS INT,
                                          INPUT par_nrctremp AS INT,
                                          INPUT par_nrdconta AS INT,
                                          INPUT par_dtmvtolt AS DATE,
                                          INPUT par_dtmvtoan AS DATE):

    DEF VAR aux_qtdedias AS INT INIT 0 NO-UNDO.

         FOR FIRST crappep FIELDS(crappep.dtvencto) 
                   WHERE crappep.cdcooper = par_cdcooper 
                     AND crappep.nrctremp = par_nrctremp 
                     AND crappep.nrdconta = par_nrdconta 
                     AND crappep.inliquid = 0
                     AND crappep.dtvencto <= par_dtmvtoan
                     NO-LOCK BY crappep.dtvencto:
    
             ASSIGN aux_qtdedias = par_dtmvtolt - 
                                   crappep.dtvencto.

         END.
    
    RETURN aux_qtdedias.

END FUNCTION.


PROCEDURE verifica_liquidacao_empr:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_flgliqui AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM par_flgopera AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.


    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    VERIFICA:
    DO ON ERROR UNDO , LEAVE:

        FIND crapepr WHERE crapepr.cdcooper = par_cdcooper   AND
                           crapepr.nrdconta = par_nrdconta   AND
                           crapepr.nrctremp = par_nrctremp
                           NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapepr   THEN
             DO:
                 ASSIGN aux_cdcritic = 356.

                 LEAVE VERIFICA.
             END.

        /* Se ja foi liquidado ,  desconsidera */
        IF    crapepr.inliquid <> 0   THEN
              LEAVE VERIFICA.

        /* Todas as parcelas devem estar liquidadas */
        FOR EACH crappep WHERE crappep.cdcooper = par_cdcooper   AND
                               crappep.nrdconta = par_nrdconta   AND
                               crappep.nrctremp = par_nrctremp   NO-LOCK:

            IF   crappep.inliquid <> 1   THEN
                 LEAVE VERIFICA.

        END.

        FIND craplcr WHERE craplcr.cdcooper = par_cdcooper   AND
                           craplcr.cdlcremp = crapepr.cdlcremp 
                           NO-LOCK NO-ERROR.

        IF   NOT AVAIL craplcr   THEN
             DO:
                 ASSIGN aux_cdcritic = 363.
                 LEAVE VERIFICA.
             END.

        ASSIGN par_flgopera = (craplcr.dsoperac = "FINANCIAMENTO")
               par_flgliqui = TRUE.

    END.

    IF   aux_cdcritic <> 0   OR
         aux_dscritic <> ""  THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,           
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE grava_liquidacao_empr:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdbccxlt AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdpactra AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdorigem AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR          aux_contador AS INTE                           NO-UNDO.
    DEF VAR          aux_flgopera AS LOGI                           NO-UNDO.
    DEF VAR          aux_vllancre AS DECI                           NO-UNDO.
    DEF VAR          aux_vllandeb AS DECI                           NO-UNDO.
    DEF VAR          aux_vlsdeved AS DECI                           NO-UNDO.
    DEF VAR          aux_flgliqui AS LOGI                           NO-UNDO.
    DEF VAR          aux_cdhistor AS INTE                           NO-UNDO.
    DEF VAR          aux_nrdolote AS INTE                           NO-UNDO.
    DEF VAR          aux_flgcredi AS LOGI                           NO-UNDO.
    DEF VAR          aux_flgtrans AS LOGI                           NO-UNDO.

    DEF VAR          h-b1wgen0043 AS HANDLE                         NO-UNDO.
    DEF VAR          h-b1wgen0134 AS HANDLE                         NO-UNDO.
    DEF VAR          h-b1wgen0171 AS HANDLE                         NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    GRAVA:
    DO ON ERROR UNDO , LEAVE:

       FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

       IF   NOT AVAIL crapdat   THEN
            DO:
                ASSIGN aux_cdcritic = 1.
                LEAVE GRAVA.
            END.

       RUN verifica_liquidacao_empr (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT par_nrdconta,
                                     INPUT par_nrctremp,
                                    OUTPUT aux_flgliqui,
                                    OUTPUT aux_flgopera,
                                    OUTPUT TABLE tt-erro).

       IF   RETURN-VALUE <> "OK"   THEN
            LEAVE GRAVA.

       IF   NOT aux_flgliqui   THEN
            DO:
                ASSIGN aux_flgtrans = TRUE.
                LEAVE GRAVA.
            END.

       DO aux_contador = 1 TO 10:

           FIND crapepr WHERE crapepr.cdcooper = par_cdcooper   AND
                              crapepr.nrdconta = par_nrdconta   AND
                              crapepr.nrctremp = par_nrctremp
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
          
           IF   NOT AVAIL crapepr   THEN
                IF   LOCKED crapepr   THEN
                     DO:
                         ASSIGN aux_cdcritic = 356.
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                ELSE 
                     DO:
                         ASSIGN aux_cdcritic = 77.
                         LEAVE.
                     END.
          
           ASSIGN aux_cdcritic = 0.
           LEAVE.

       END.

       IF   aux_cdcritic <> 0   THEN
            LEAVE GRAVA.
        

       ASSIGN aux_vllancre = 0
              aux_vllandeb = 0.
            
       /* Contabilizar creditos  */
       FOR EACH craplem WHERE craplem.cdcooper = par_cdcooper   AND
                              craplem.nrdconta = par_nrdconta   AND
                              craplem.nrctremp = par_nrctremp   NO-LOCK:

                 /* Creditos */
           IF   CAN-DO("1044,1039,1045,1046,1057,1058,1043,1041",
                       STRING(craplem.cdhistor)) THEN
                ASSIGN aux_vllancre = aux_vllancre + craplem.vllanmto.
           ELSE /* Debitos */
           IF   CAN-DO("1036,1059,1037,1038,1716,1707,1714,1705,1042,1040,2013,2014",
                       STRING(craplem.cdhistor)) THEN
                ASSIGN aux_vllandeb = aux_vllandeb + craplem.vllanmto.
          
       END.

       ASSIGN aux_vlsdeved = aux_vllancre - aux_vllandeb.

       IF   aux_vlsdeved < 0   THEN
            DO:
                IF   aux_flgopera   THEN           /* Financiamento */
                     ASSIGN aux_cdhistor = 1043
                            aux_nrdolote = 600009.
                ELSE                                /* Emprestimo */
                     ASSIGN aux_cdhistor = 1041
                            aux_nrdolote = 600007.

                /* Inverter sinal para efetuar o lancamento */
                ASSIGN aux_vlsdeved = aux_vlsdeved * -1
                    
                       aux_flgcredi = TRUE. /* Credita */

            END.
       ELSE
       IF   aux_vlsdeved > 0   THEN
            DO:
                IF   aux_flgopera   THEN           /* Financiamento */
                     ASSIGN aux_cdhistor = 1042
                            aux_nrdolote = 600008.
                ELSE                                /* Emprestimo */
                     ASSIGN aux_cdhistor = 1040
                            aux_nrdolote = 600006. 

                ASSIGN aux_flgcredi = FALSE. /* Debita */
            END.       
           
       IF   aux_vlsdeved <> 0   THEN /* Efetuar ajuste */
            DO:
                RUN sistema/generico/procedures/b1wgen0134.p
                    PERSISTENT SET h-b1wgen0134.
                       
                RUN cria_lancamento_lem IN h-b1wgen0134 
                                            (INPUT par_cdcooper,
                                             INPUT par_dtmvtolt,
                                             INPUT par_cdagenci,
                                             INPUT par_cdbccxlt,
                                             INPUT par_cdoperad,
                                             INPUT par_cdpactra,
                                             INPUT 5,  /* tplotmov*/ 
                                             INPUT aux_nrdolote,
                                             INPUT par_nrdconta,
                                             INPUT aux_cdhistor,
                                             INPUT par_nrctremp,
                                             INPUT aux_vlsdeved,
                                             INPUT par_dtmvtolt, 
                                             INPUT 0,  /* txjurepr */
                                             INPUT 0,  /* vlpreemp */
                                             INPUT 0,  /* nrsequni */
                                             INPUT 0,
                                             INPUT TRUE,
                                             INPUT aux_flgcredi,
                                             INPUT 0,
                                             INPUT par_cdorigem). 

                DELETE PROCEDURE h-b1wgen0134.

            END.

       IF   crapepr.vlsdeved <> 0   THEN /* Se tem residuo */
            DO:
                /* Verificar se existe registro de estorno */
                FIND FIRST craplem WHERE
                           craplem.cdcooper = par_cdcooper   AND
                           craplem.nrdconta = par_nrdconta   AND
                           craplem.nrctremp = par_nrctremp   AND
                            /* Financiamento */
                           (craplem.cdhistor = 1052          OR 
                            /* Emprestimo */
                            craplem.cdhistor = 1073)
                           NO-LOCK NO-ERROR.

                IF   NOT AVAIL craplem   THEN
                     DO:
                          ASSIGN crapepr.vlajsdev = crapepr.vlsdeved
                                 crapepr.vlsdeved = 0.
                     END.
            END.
            
       ASSIGN crapepr.inliquid = 1
              crapepr.dtliquid = par_dtmvtolt. /* Liquidar Emprestimo */

       RUN sistema/generico/procedures/b1wgen0043.p 
           PERSISTENT SET h-b1wgen0043.
       
       RUN desativa_rating IN h-b1wgen0043 (INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_cdoperad,
                                            INPUT par_dtmvtolt,
                                            INPUT crapdat.dtmvtopr,
                                            INPUT crapepr.nrdconta,
                                            INPUT 90, /* Emprestimo */
                                            INPUT crapepr.nrctremp,
                                            INPUT YES,
                                            INPUT 1,
                                            INPUT 1,
                                            INPUT par_nmdatela,
                                            INPUT par_inproces,
                                            INPUT FALSE,
                                           OUTPUT TABLE tt-erro).       
       DELETE PROCEDURE h-b1wgen0043.


       /** GRAVAMES **/
       RUN sistema/generico/procedures/b1wgen0171.p
                            PERSISTENT SET h-b1wgen0171.

       RUN solicita_baixa_automatica IN h-b1wgen0171
                    (INPUT par_cdcooper,
                     INPUT crapepr.nrdconta,
                     INPUT crapepr.nrctremp,
                     INPUT par_dtmvtolt,
                    OUTPUT TABLE tt-erro).

       DELETE PROCEDURE h-b1wgen0171.


       ASSIGN aux_flgtrans = TRUE.

    END.

    IF   NOT aux_flgtrans   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF   NOT AVAIL tt-erro  THEN
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,           
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).
                  
             RETURN "NOK".
         END.
         
    RETURN "OK".

END PROCEDURE.


PROCEDURE cria-atualiza-ttlancconta:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdpactra AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdolote AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vllanmto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqava AS INTE                           NO-UNDO.
    
    DEF  INPUT-OUTPUT PARAM TABLE FOR tt-lancconta.

    FIND tt-lancconta WHERE tt-lancconta.cdcooper = par_cdcooper AND
                            tt-lancconta.nrctremp = par_nrctremp AND
                            tt-lancconta.cdhistor = par_cdhistor AND
                            tt-lancconta.dtmvtolt = par_dtmvtolt AND
                            tt-lancconta.cdagenci = par_cdpactra AND
                            tt-lancconta.cdbccxlt = 100          AND
                            tt-lancconta.nrdolote = par_nrdolote AND
                            tt-lancconta.nrdconta = par_nrdconta 
                            NO-LOCK NO-ERROR.
                     
    IF AVAIL tt-lancconta THEN
       ASSIGN tt-lancconta.vllanmto = tt-lancconta.vllanmto + par_vllanmto.
    ELSE     
    DO:
       CREATE tt-lancconta.

       ASSIGN tt-lancconta.cdcooper = par_cdcooper
              tt-lancconta.nrctremp = par_nrctremp
              tt-lancconta.cdhistor = par_cdhistor
              tt-lancconta.dtmvtolt = par_dtmvtolt
              tt-lancconta.cdagenci = par_cdpactra
              tt-lancconta.cdbccxlt = 100
              tt-lancconta.cdoperad = par_cdoperad
              tt-lancconta.nrdolote = par_nrdolote
              tt-lancconta.nrdconta = par_nrdconta
              tt-lancconta.vllanmto = par_vllanmto
              tt-lancconta.cdpactra = par_cdpactra
              tt-lancconta.nrseqava = par_nrseqava.
    END.
END.

PROCEDURE efetua_liquidacao_empr:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdpactra AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtoan AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_ehprcbat AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-pagamentos-parcelas.
    DEF  INPUT PARAM par_nrseqava AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_vlrmulta AS DECI                                    NO-UNDO.
    DEF VAR aux_vlatraso AS DECI                                    NO-UNDO.    
    DEF VAR aux_vlsdeved AS DECI                                    NO-UNDO.
    DEF VAR aux_cdhismul AS INTE                                    NO-UNDO.
    DEF VAR aux_cdhisatr AS INTE                                    NO-UNDO.
    DEF VAR aux_cdhispag AS INTE                                    NO-UNDO.
    DEF VAR aux_loteatra AS INTE                                    NO-UNDO.
    DEF VAR aux_lotemult AS INTE                                    NO-UNDO.
    DEF VAR aux_lotepaga AS INTE                                    NO-UNDO.
    DEF VAR aux_vlpagsld AS DECI                                    NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    DEF BUFFER crabpep FOR crappep.
    
    DEF VAR h-b1wgen0084a         AS HANDLE                         NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.    
    EMPTY TEMP-TABLE tt-lancconta.

    IF   par_flgerlog THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Liquida emprestimo".
    
    RUN sistema/generico/procedures/b1wgen0084a.p PERSISTENT SET h-b1wgen0084a.
                     
    BLOCO_TRANSACAO:
    DO TRANSACTION ON ERROR UNDO, LEAVE:

        FOR EACH crappep WHERE crappep.cdcooper = par_cdcooper AND
                               crappep.nrdconta = par_nrdconta AND
                               crappep.nrctremp = par_nrctremp AND
                               crappep.inliquid = 0 
                               NO-LOCK BREAK BY crappep.nrparepr:

            FIND tt-pagamentos-parcelas WHERE 
                 tt-pagamentos-parcelas.cdcooper = crappep.cdcooper   AND
                 tt-pagamentos-parcelas.nrdconta = crappep.nrdconta   AND
                 tt-pagamentos-parcelas.nrctremp = crappep.nrctremp   AND
                 tt-pagamentos-parcelas.nrparepr = crappep.nrparepr
                 NO-LOCK NO-ERROR.
    
            IF    NOT AVAIL tt-pagamentos-parcelas   THEN
                  DO:
                      ASSIGN aux_cdcritic = 0
                             aux_dscritic = "Parcela nao encontrada.".
                     
                      UNDO BLOCO_TRANSACAO, LEAVE BLOCO_TRANSACAO.
                  END.
            
            IF   crappep.dtvencto >  par_dtmvtoan   AND 
                 crappep.dtvencto <= par_dtmvtolt   THEN /* Parcela em dia */
                 DO: 

                     RUN efetiva_pagamento_normal_parcela_craplem IN h-b1wgen0084a
                                       (INPUT  par_cdcooper,
                                        INPUT  par_cdagenci,
                                        INPUT  par_nrdcaixa,
                                        INPUT  par_cdoperad,
                                        INPUT  par_nmdatela,
                                        INPUT  par_idorigem,
                                        INPUT  par_cdpactra,
                                        INPUT  par_nrdconta,
                                        INPUT  par_idseqttl,
                                        INPUT  par_dtmvtolt,
                                        INPUT  par_flgerlog,
                                        INPUT  crappep.nrctremp,
                                        INPUT  crappep.nrparepr,
                                        INPUT  tt-pagamentos-parcelas.vlatupar,
                                        INPUT  par_nrseqava,
                                       OUTPUT aux_cdhispag,
                                       OUTPUT aux_lotepaga,
                                       OUTPUT TABLE tt-erro).                     
                     
                     IF   RETURN-VALUE <> "OK"   THEN
                          UNDO BLOCO_TRANSACAO, LEAVE BLOCO_TRANSACAO.
                     
                     IF (NOT par_ehprcbat) THEN
                        DO:                     
                            RUN cria-atualiza-ttlancconta
                                        (INPUT par_cdcooper,
                                         INPUT par_nrctremp,
                                         INPUT aux_cdhispag,
                                         INPUT par_dtmvtolt,
                                         INPUT par_cdoperad,
                                         INPUT par_cdpactra,
                                         INPUT aux_lotepaga,
                                         INPUT par_nrdconta,
                                         INPUT tt-pagamentos-parcelas.vlatupar,
                                         INPUT par_nrseqava,
                                         INPUT-OUTPUT TABLE tt-lancconta).
                        END.
                 END.
            ELSE
            IF   crappep.dtvencto < par_dtmvtolt   THEN /* Parcela Vencida */
                 DO: 
                     RUN efetiva_pagamento_atrasado_parcela_craplem  IN h-b1wgen0084a
                                      (INPUT  par_cdcooper,
                                       INPUT  par_cdagenci,
                                       INPUT  par_nrdcaixa,
                                       INPUT  par_cdoperad,
                                       INPUT  par_nmdatela,
                                       INPUT  par_idorigem,
                                       INPUT  par_cdpactra,
                                       INPUT  par_nrdconta,
                                       INPUT  par_idseqttl,
                                       INPUT  par_dtmvtolt,
                                       INPUT  par_flgerlog,
                                       INPUT  crappep.nrctremp,
                                       INPUT  crappep.nrparepr,
                                       INPUT  tt-pagamentos-parcelas.vlatrpag,
                                       INPUT  par_nrseqava,
                                       OUTPUT aux_vlpagsld,
                                       OUTPUT aux_vlrmulta,
                                       OUTPUT aux_vlatraso,
                                       OUTPUT aux_cdhismul,
                                       OUTPUT aux_cdhisatr,
                                       OUTPUT aux_cdhispag,
                                       OUTPUT aux_loteatra,
                                       OUTPUT aux_lotemult,
                                       OUTPUT aux_lotepaga,
                                       OUTPUT TABLE tt-erro).

                     IF   RETURN-VALUE <> "OK"   THEN
                          UNDO BLOCO_TRANSACAO, LEAVE BLOCO_TRANSACAO.

                     /* multa */
                     RUN cria-atualiza-ttlancconta
                                    (INPUT par_cdcooper,
                                     INPUT par_nrctremp,
                                     INPUT aux_cdhismul,
                                     INPUT par_dtmvtolt,
                                     INPUT par_cdoperad,
                                     INPUT par_cdpactra,
                                     INPUT aux_lotemult,
                                     INPUT par_nrdconta,
                                     INPUT aux_vlrmulta,
                                     INPUT par_nrseqava,
                                     INPUT-OUTPUT TABLE tt-lancconta).
                     
                     /* juros de inadinplencia */
                     RUN cria-atualiza-ttlancconta
                                    (INPUT par_cdcooper,
                                     INPUT par_nrctremp,
                                     INPUT aux_cdhisatr,
                                     INPUT par_dtmvtolt,
                                     INPUT par_cdoperad,
                                     INPUT par_cdpactra,
                                     INPUT aux_loteatra,
                                     INPUT par_nrdconta,
                                     INPUT aux_vlatraso,
                                     INPUT par_nrseqava,
                                     INPUT-OUTPUT TABLE tt-lancconta).

                     IF (NOT par_ehprcbat) THEN
                        DO:
                             /* pagamento */
                             RUN cria-atualiza-ttlancconta
                                        (INPUT par_cdcooper,
                                         INPUT par_nrctremp,
                                         INPUT aux_cdhispag,
                                         INPUT par_dtmvtolt,
                                         INPUT par_cdoperad,
                                         INPUT par_cdpactra,
                                         INPUT aux_lotepaga,
                                         INPUT par_nrdconta,
                                         INPUT tt-pagamentos-parcelas.vlatupar,
                                         INPUT par_nrseqava,
                                         INPUT-OUTPUT TABLE tt-lancconta).
                        END.
                 END.
            ELSE
            IF   crappep.dtvencto > par_dtmvtolt   THEN /* Parcela a Vencer */
                 DO: 
                     RUN efetiva_pagamento_antecipado_craplem IN h-b1wgen0084a
                                      (INPUT  par_cdcooper,
                                       INPUT  par_cdagenci,
                                       INPUT  par_nrdcaixa,
                                       INPUT  par_cdoperad,
                                       INPUT  par_nmdatela,
                                       INPUT  par_idorigem,
                                       INPUT  par_cdpactra,
                                       INPUT  par_nrdconta,
                                       INPUT  par_idseqttl,
                                       INPUT  par_dtmvtolt,
                                       INPUT  par_flgerlog,
                                       INPUT  crappep.nrctremp,
                                       INPUT  crappep.nrparepr,
                                       INPUT  tt-pagamentos-parcelas.vlatupar,
                                       INPUT  par_nrseqava,
                                       OUTPUT aux_cdhispag,
                                       OUTPUT aux_lotepaga,
                                       OUTPUT TABLE tt-erro).

                     IF   RETURN-VALUE <> "OK"   THEN
                          UNDO BLOCO_TRANSACAO, LEAVE BLOCO_TRANSACAO.

                     /* pagamento */
                     IF   (NOT par_ehprcbat) THEN
                           DO:  
                               RUN cria-atualiza-ttlancconta
                                         (INPUT par_cdcooper,
                                          INPUT par_nrctremp,
                                          INPUT aux_cdhispag,
                                          INPUT par_dtmvtolt,
                                          INPUT par_cdoperad,
                                          INPUT par_cdpactra,
                                          INPUT aux_lotepaga,
                                          INPUT par_nrdconta,
                                          INPUT tt-pagamentos-parcelas.vlatupar,
                                          INPUT par_nrseqava,
                                          INPUT-OUTPUT TABLE tt-lancconta).
                           END.
                 END.

        END. /* FOR EACH tt-pagamentos-parcelas:  */

        FOR EACH tt-lancconta:
                 
            RUN cria_lancamento_cc IN h-b1wgen0084a 
                                  (INPUT tt-lancconta.cdcooper,
                                   INPUT tt-lancconta.dtmvtolt,
                                   INPUT tt-lancconta.cdagenci,
                                   INPUT tt-lancconta.cdbccxlt,
                                   INPUT tt-lancconta.cdoperad,
                                   INPUT tt-lancconta.cdpactra,
                                   INPUT tt-lancconta.nrdolote,
                                   INPUT tt-lancconta.nrdconta,
                                   INPUT tt-lancconta.cdhistor,
                                   INPUT tt-lancconta.vllanmto,
                                   INPUT 0,  /* Sem nr parcela */  
                                   INPUT tt-lancconta.nrctremp,
                                   INPUT tt-lancconta.nrseqava).
        END.
       
        ASSIGN aux_flgtrans  = TRUE.

    END. /* DO TRANSACTION (BLOCO_TRANSACAO) */

    DELETE PROCEDURE h-b1wgen0084a.
     
    IF   NOT aux_flgtrans  THEN
         DO:
             IF   NOT TEMP-TABLE tt-erro:HAS-RECORDS   THEN
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1, 
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).         
             RETURN "NOK".
         END.

    IF   par_flgerlog   THEN
        DO:
            FOR EACH tt-pagamentos-parcelas BREAK BY tt-pagamentos-parcelas.nrparepr:
                
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT "",
                                    INPUT aux_dsorigem,
                                    INPUT "Pag. Emp/Fin Nr " + STRING(par_nrctremp) + "/" + STRING(tt-pagamentos-parcelas.nrparepr),
                                    INPUT TRUE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                                   
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "vlpagpar", 
                                         INPUT STRING(tt-pagamentos-parcelas.vlpagpar),
                                         INPUT STRING(tt-pagamentos-parcelas.vlpagpar)).
            END.
        END.

    RETURN "OK".

END PROCEDURE.
/* ......................................................................... */
