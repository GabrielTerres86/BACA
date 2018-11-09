/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +-------------------------------------------+------------------------------+
  | Rotina Progress                           | Rotina Oracle PLSQL          |
  +-------------------------------------------+------------------------------+
  | sistema/generico/procedures/b1wgen0084a.p | EMPR0001                     |
  | busca_pagamentos_parcelas                 | pc_busca_pgto_parcelas       |
  | calcula_atraso_parcela                    | pc_calc_atraso_parcela       |
  | calcula_antecipacao_parcela               | pc_calc_antecipa_parcela     |
  | calcula_juros_normais_total               | pc_calc_juros_normais_total  |
  | lanca_juro_contrato                       | pc_lanca_juro_contrato       |
  | verifica_parcelas_anteriores              | pc_verifica_parcelas_anteriores
  | efetiva_pagamento_normal_parcela          | efetiva_pagto_parcela        |
  | efetiva_pagamento_normal_parcela_craplem  | pc_efetiva_pagto_parc_lem    | 
  | busca_registro_parcela                    | Não necessário               |
  | busca_registro_emprestimo                 | Não necessário               |
  | cria_lancamento_cc                        | pc_cria_lancamento_cc        | 
  | efetiva_pagamento_atrasado_parcela        | pc_efetiva_pagto_atr_parcel  |
  | valida_pagamento_atrasado_parcela         | pc_valida_pagto_atr_parcel   |
  | efetiva_pagamento_atrasado_parcela_craplem| pc_efetiva_pag_atr_parcel_lem| 
  | valida_pagamentos_geral                   | pc_valida_pagamentos_geral   | 
  | grava_liquidacao_empr                     | pc_grava_liquidacao_empr     |
  | verifica_liquidacao_empr                  | pc_verifica_liquidacao_empr  |
  | efetiva_pagamento_antecipado_craplem      | pc_efetiva_pagto_antec_lem   |
  | valida_pagamento_antecipado_parcela       | pc_valida_pagto_antec_parc   |
  | calcula_antecipacao_parcela_parcial       | pc_calc_antec_parcel_parci   |
  --------------------------------------------+------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/


 
 
 

/*............................................................................
    
    Programa: sistema/generico/procedures/b1wgen0084a.p
    Autor   : Gabriel
    Data    : Setembro/2011               ultima Atualizacao: 08/07/2018
     
    Dados referentes ao programa:
   
    Objetivo  : BO para rotinas do sistema referentes a pagamento e estorno
   
    Alteracoes: 05/10/2011 - efetiva pagamento antecipad _parcela
                             Quando efetivar pagamento antecipado da parcela,
                             eliminar avisos de débito (Vitor - GATI)
                             
                06/10/2011 - Incluído a procedure valida pagamentos geral
                             (Vitor - GATI)
                             
                06/10/2011 - Adicionado calculo do juros de mora na procedure
                             calcula atraso parcela, juntamente com parametro
                             de saida para retornar esse valor. (GATI - Oliver)
                
                24/01/2012 - Reformulada a procedure verifica alcada estorno 
                             (Tiago).
                             
                02/02/2012 - Validacao da alcada do operador para pagamento
                             (Tiago).       
                             
                09/02/2012 - Incluida procedure para calcular juro do contrato
                             (Gabriel).     
                             
                27/11/2012 - Ajuste no calculo dos juros de atraso (Gabriel).
                
                12/12/2012 - Ajuste no calculo do juros de mora/multa (Oscar).
                
                21/02/2013 - Incluir procedure para trazer valor de desconto
                             quando pagamento antecipado (Gabriel).
                             
                27/02/2013 - Tratar valor dos juros do contrato quando vier
                             negativo (Gabriel).             
                             
                15/05/2013 - Enviar cdagenci = 1 na criacao da craplem
                             (Gabriel).             
                             
                05/07/2013 - Incluir saldo contratado (Gabriel).
                
                14/10/2013 - Ajustado a procedure busca_pagamentos_parcelas
                             para atualizar o valor a regularizar quando a 
                             parcela estiver em dia (James).
                             
                04/11/2013 - Ajuste para inclusao do parametro cdpactra
                             nas procedures: 
                             - gera_pagamentos_parcelas 
                             - efetiva_pagamento_normal_parcela_craplem
                             - efetiva_pagamento_normal_parcela
                             - efetiva_pagamento_atrasado_parcela_craplem
                             - efetiva_pagamento_atrasado_parcela
                             - efetiva_pagamento_antecipado_craplem
                             - efetiva_pagamento_antecipado_parcela
                             - cria_lancamento_cc
                             - lanca_juro_contrato
                             (Adriano).             
                             
                17/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
                
                15/01/2014 - Ajuste na procedure "cria_lancamento_cc" 
                             para somente inserir, caso o valor do lancamento
                             for maior que 0. (James).
                             
                17/01/2014 - Ajuste na procedure "efetiva_pagamento_normal_parcela_craplem"
                             para chamar a procedure "valida_pagamento_normal_parcela"
                             (James)
                             
                12/03/2014 - Ajuste na procedure "calcula_atraso_parcela"
                             para pegar o prazo de atraso da tabela 
                             crapepr.qttolatr. (James)
                             
                02/05/2014 - Ajuste no calculo da tolerancia da multa e Juros de
                             Mora na procedure "calcula_atraso_parcela". (James)
                             
                27/05/2014 - Ajuste na procedure "valida_pagamento_atrasado_parcela"
                             para nao permitir informar o valor maior que a 
                             parcela. (James)
                             
                09/06/2014 - Inserir procedure "busca_avalista_pagamento_parcela"
                             (James)
                             
                11/06/2014 - Ajuste nas procedures de lancamento de emprestimo
                             e lancamento de conta, para gravar o campo nrseqava.
                             (James)
                             
                31/07/2014 - Ajuste na procedure "calcula_atraso_parcela" para 
                             filtrar a parcela na tabela craplem. (James)
                             
                13/08/2014 - Ajuste para gravar o operador e a hora da transacao
                             na procedure "cria_lancamento_cc". (James)
                
                22/01/2015 - Alterado o formato do campo nrctremp para 8 
                             caracters (Kelvin - 233714)
                             
                29/01/2015 - Ajuste na procedure "calcula_desconto_parcela".
                             (James)
                             
                31/03/2015 - Ajuste nas procedures "busca_pagamentos_parcelas"
                             e "calcula_atraso_parcela" para verificar os
                             historicos de emprestimo e financiamento. (James)                                            
                             
                07/10/2015 - Adicionado mais informacoes no log no momento do pagamento
                             das parcelas de emprestimo. SD 317004 (Kelvin)
                             
                08/10/2015 - Diminuir valor do estorno do valor pago no menos produto PP (Oscar)             
                
                16/10/2015 - Zerar o campo vlsdvsji quando liquidar a parcela PP (Oscar)
                
                28/10/2015 - Removido as procedures valida_estorno_lancamento
                             verifica_alcada_estorno, efetiva_estorno_lancamento
                             e gera_estorno_lancamento.(Reinert)
                             
                06/11/2015 - Adicionado tratamento para pagamento de boleto de
                             emprestimos. (Reinert)
                             
                20/11/2015 - Ajustes referente Projeto 215 - DV 2 (Daniel)
                
                27/11/2015 - Feito ajuste no tratamento para pagamento de boletos
                             de emprestimos. (Reinert)

                31/10/2016 - Validação dentro do busca_registro_parcela para identificar
				                     parcelas ja liquidadas (AJFink - SD545719)

                10/05/2018 - P410 - Ajustes IOF (Marcos-Envolti)                     

                12/06/2018 - Ajuste para usar procedure que centraliza lancamentos na CRAPLCM 
                             [gerar_lancamento_conta_comple]. (PRJ450 - Teobaldo J - AMcom)

                23/06/2018 - Rename da tabela tbepr_cobranca para tbrecup_cobranca e filtro tpproduto = 0 (Paulo Penteado GFT)                   

                07/08/2018 - P410 - IOF Prejuizo - Diminuir valores já pagos (Marcos-Envolti)                
                            
                08/11/2018 - Ajuste para arredondar par_vlmrapar em duas casas, devido a diferenca entre LCM e LEM
                             PRJ450 - Regulatorio(Odirlei-AMcom)

............................................................................. */

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgen0084tt.i }
{ sistema/generico/includes/b1wgen0084att.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/b1wgen0200tt.i }


DEF STREAM str_1.

DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR h-b1wgen0084 AS HANDLE                                      NO-UNDO.


PROCEDURE busca_lancamentos_parcelas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrparepr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtini AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtfin AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-lanctos-parcelas.


    DEF          VAR aux_contparc AS INTE                           NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-lanctos-parcelas.

    IF   par_flgerlog THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Busca lancamentos das parcelas de emprestimo".

    IF   par_dtmvtini = ?   THEN 
         ASSIGN par_dtmvtini = 01/01/0001.

    IF   par_dtmvtfin = ?   THEN 
         ASSIGN par_dtmvtfin = 12/31/9999.
    
    IF   NOT CAN-FIND(FIRST craplem WHERE craplem.cdcooper  = par_cdcooper  AND
                                        craplem.nrdconta  = par_nrdconta    AND
                                        craplem.nrctremp  = par_nrctremp    AND
                                        craplem.dtmvtolt >= par_dtmvtini    AND
                                        craplem.dtmvtolt <= par_dtmvtfin)   THEN 
         DO:
             ASSIGN aux_cdcritic = 357
                    aux_dscritic = "".
             
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1, 
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             
             RETURN "NOK".
         END.    

    BLOCO_LANCAMENTOS:
    FOR EACH craplem WHERE craplem.cdcooper  = par_cdcooper    AND
                           craplem.nrdconta  = par_nrdconta    AND
                           craplem.nrctremp  = par_nrctremp    AND
                           craplem.dtmvtolt >= par_dtmvtini    AND
                           craplem.dtmvtolt <= par_dtmvtfin    NO-LOCK
                           BREAK BY craplem.nrparepr:

        CREATE tt-lanctos-parcelas.
        BUFFER-COPY craplem TO tt-lanctos-parcelas.

        FIND craphis WHERE craphis.cdcooper = craplem.cdcooper AND 
                           craphis.cdhistor = craplem.cdhistor 
                           NO-LOCK NO-ERROR.

        IF   AVAIL craphis   THEN
             ASSIGN tt-lanctos-parcelas.dshistor = craphis.dshistor.
                   
        IF   LAST-OF(craplem.nrparepr)   AND 
             par_nrparepr <> 0           THEN
             DO:
                 ASSIGN aux_contparc = aux_contparc + 1.

                 IF   aux_contparc > par_nrparepr   THEN
                      LEAVE BLOCO_LANCAMENTOS.
             END.

    END. /* FOR EACH craplem (BLOCO_LANCAMENTOS) */

    IF   par_flgerlog   THEN
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

END PROCEDURE. /* busca lancamentos parcelas */


PROCEDURE busca_pagamentos_parcelas:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/


    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtoan AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrparepr AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-pagamentos-parcelas.
    DEF OUTPUT PARAM TABLE FOR tt-calculado.

    DEF VAR aux_flgtrans         AS LOGI                            NO-UNDO.
    DEF VAR aux_nrdolote         AS INTE       EXTENT 3             NO-UNDO.
    DEF VAR aux_cdhistor LIKE craplem.cdhistor EXTENT 8             NO-UNDO.
    DEF VAR aux_contador         AS INTE                            NO-UNDO.
    DEF VAR aux_contlote         AS INTE                            NO-UNDO.
    DEF VAR aux_vlsdeved         AS DECI                            NO-UNDO.
    DEF VAR aux_vlprepag         AS DECI                            NO-UNDO.
    DEF VAR aux_vlpreapg         AS DECI                            NO-UNDO.
    DEF VAR aux_vlpagsld         AS DECI                            NO-UNDO.
    DEF VAR aux_vlsderel         AS DECI                            NO-UNDO.
    DEF VAR aux_vlsdvctr         AS DECI                            NO-UNDO.
    DEF VAR aux_qtdiaiof         AS INTE                            NO-UNDO.


    DEF BUFFER crabhis_2 FOR craphis.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-pagamentos-parcelas.
    EMPTY TEMP-TABLE tt-calculado.

    IF   par_flgerlog THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Busca pagamentos de parcelas".

    BUSCA:
    DO ON ERROR UNDO , LEAVE:

       FIND crapepr WHERE crapepr.cdcooper = par_cdcooper   AND
                          crapepr.nrdconta = par_nrdconta   AND
                          crapepr.nrctremp = par_nrctremp   NO-LOCK NO-ERROR.
                          
       IF   NOT AVAIL crapepr   THEN
            DO:
                ASSIGN aux_cdcritic = 356.
                LEAVE BUSCA.
            END.

       FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                          crawepr.nrdconta = par_nrdconta   AND
                          crawepr.nrctremp = par_nrctremp   NO-LOCK NO-ERROR.
                          
       IF   NOT AVAIL crawepr   THEN
            DO:
                ASSIGN aux_cdcritic = 535.
                LEAVE BUSCA.
            END.

       FOR EACH crappep WHERE crappep.cdcooper = par_cdcooper          AND
                              crappep.nrdconta = par_nrdconta          AND
                              crappep.nrctremp = par_nrctremp          AND 

                            ( ( par_nrparepr <> 0  AND
                                crappep.nrparepr = par_nrparepr) OR 
                               par_nrparepr = 0 )                      AND

                              crappep.inliquid = 0 /* nao liquidada */ NO-LOCK:

           CREATE tt-pagamentos-parcelas.
           BUFFER-COPY crappep TO tt-pagamentos-parcelas.
    
           IF   par_dtmvtolt <= crawepr.dtlibera   THEN /* Nao liberado */
                DO:
                    ASSIGN tt-pagamentos-parcelas.vlatupar = crapepr.vlemprst / crapepr.qtpreemp
	                       tt-pagamentos-parcelas.vlsdvpar = tt-pagamentos-parcelas.vlatupar.         
                           tt-pagamentos-parcelas.vlatrpag = tt-pagamentos-parcelas.vlatupar.

                           aux_vlsdvctr = aux_vlsdvctr + crappep.vlsdvpar.
                END.
           ELSE    
           IF   crappep.dtvencto >  par_dtmvtoan   AND 
                crappep.dtvencto <= par_dtmvtolt   THEN /* Parcela em dia */
                DO:
                    ASSIGN tt-pagamentos-parcelas.vlatupar = crappep.vlsdvpar
                           
                           aux_vlsdvctr = aux_vlsdvctr + crappep.vlsdvpar
                           /* A regularizar */
                           aux_vlpreapg = aux_vlpreapg + 
                                          tt-pagamentos-parcelas.vlatupar.
                END.
           ELSE
           IF   crappep.dtvencto < par_dtmvtolt   THEN /* Parcela Vencida */
                DO:
                    RUN calcula_atraso_parcela
                                         (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT par_cdoperad,
                                          INPUT par_nmdatela,
                                          INPUT par_idorigem,
                                          INPUT par_nrdconta,
                                          INPUT par_idseqttl,
                                          INPUT par_dtmvtolt,
                                          INPUT par_flgerlog,
                                          INPUT crappep.nrctremp,
                                          INPUT crappep.nrparepr,
                                          INPUT 0, /* vlpagpar */
                                         OUTPUT TABLE tt-erro,
                                         OUTPUT aux_vlpagsld,
                                         OUTPUT tt-pagamentos-parcelas.vlatupar,
                                         OUTPUT tt-pagamentos-parcelas.vlmtapar,
                                         OUTPUT tt-pagamentos-parcelas.vljinpar,
                                         OUTPUT tt-pagamentos-parcelas.vlmrapar,
                                         OUTPUT tt-pagamentos-parcelas.vliofcpl,
                                         OUTPUT tt-pagamentos-parcelas.vljinp59,
                                         OUTPUT tt-pagamentos-parcelas.vljinp60).

                    IF   RETURN-VALUE <> "OK"   THEN
                         RETURN "NOK".
                     
                    /* A regularizar */
                    ASSIGN aux_vlpreapg = aux_vlpreapg + 
                                          tt-pagamentos-parcelas.vlatupar
                            
                           aux_vlsdvctr = aux_vlsdvctr + 
                                          tt-pagamentos-parcelas.vlatupar.                          
                END.
           ELSE
           IF   crappep.dtvencto > par_dtmvtolt  THEN /* Parcela a Vencer */
                DO:        
                    RUN calcula_antecipacao_parcela
                                           (INPUT crappep.cdcooper,
                                            INPUT crappep.dtvencto,
                                            INPUT crappep.vlsdvpar,
                                            INPUT crapepr.txmensal,
                                            INPUT par_dtmvtolt, 
                                            INPUT crapepr.dtdpagto,
                                           OUTPUT tt-pagamentos-parcelas.vlatupar,
                                           OUTPUT tt-pagamentos-parcelas.vldespar).
        
                    IF   RETURN-VALUE <> "OK"   THEN
                         RETURN "NOK".

                    ASSIGN tt-pagamentos-parcelas.flgantec = TRUE
                           aux_vlsdvctr = aux_vlsdvctr + crappep.vlsdvpar.
                END.
       
           IF   NOT par_dtmvtolt <= crawepr.dtlibera   THEN /* Se liberado */
                DO:
                           /* Saldo devedor */
                    ASSIGN tt-pagamentos-parcelas.vlsdvpar = crappep.vlsdvpar.
                
                  /* \* Projeto 410 - Novo IOF *\
                   \* Bens do contrato: 
                        Faz o order by dscatbem pois "CASA" e "APARTAMENTO" reduzem as 3 aliquotas de IOF (principal, adicional e complementar) a zero.
                        Já "MOTO" reduz apenas as alíquotas de IOF principal e complementar..
                        Dessa forma, se tiver um bem que seja CASA ou APARTAMENTO, não precisa mais verificar os outros bens..*\

                   ASSIGN aux_dscatbem = ?.
                   FOR EACH crapbpr WHERE crapbpr.cdcooper = par_cdcooper 
                                            AND crapbpr.nrdconta = par_nrdconta
                                            AND crapbpr.nrctrpro = crappep.nrctremp
                                            AND (crapbpr.dscatbem = "APARTAMENTO" OR 
                                                 crapbpr.dscatbem = "CASA" OR 
                                                 crapbpr.dscatbem = "MOTO") NO-LOCK BY crapbpr.dscatbem:
                        ASSIGN aux_dscatbem = crapbpr.dscatbem.
                        RETURN.
                   END.

                   ASSIGN aux_qtdiaiof = par_dtmvtolt - crappep.dtvencto.
                   IF aux_qtdiaiof < 0 THEN
                       ASSIGN aux_qtdiaiof = 0.
                
                   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                   RUN STORED-PROCEDURE pc_calcula_valor_iof_epr
                   aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper     \* Código da cooperativa referente ao contrato de empréstimos *\
                                                       ,INPUT par_nrdconta     \* Número da conta referente ao empréstimo *\
                                                       ,INPUT crapepr.nrctremp \* Número do contrato de empréstimo *\
                                                       ,INPUT tt-pagamentos-parcelas.vlsdvpar \*crapepr.vlsdeved*\     \* Valor do empréstimo para efeito de cálculo *\
                                                       ,INPUT crapepr.vlemprst \* vltotope *\
                             ,INPUT aux_dscatbem     \* Descrição da categoria do bem, valor default NULO  *\
                                                       ,INPUT crapepr.cdlcremp     \* Linha de crédito do empréstimo *\
                                                       ,INPUT crapepr.cdfinemp     \* Finalidade do crédito do empréstimo *\
                                                       ,INPUT par_dtmvtolt     \* Data do movimento *\
                                                       ,INPUT aux_qtdiaiof     \* Quantidade de dias em atraso *\
                                                       ,OUTPUT 0               \* Valor do IOF principal *\
                                                       ,OUTPUT 0               \* Valor do IOF adicional *\
                                                       ,OUTPUT 0               \* Valor do IOF complementar *\
                                                       ,OUTPUT 0               \* Valor da Taxa do IOF Principal *\
                                                       ,OUTPUT 0               \* Possui imunidade tributária *\
                                                       ,OUTPUT "").            \* Critica *\
             
                   \* Fechar o procedimento para buscarmos o resultado *\ 
                   CLOSE STORED-PROC pc_calcula_valor_iof_epr

                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
                   \* Se retornou erro *\
                   ASSIGN aux_dscritic = ""
                          aux_dscritic = pc_calcula_valor_iof_epr.pr_dscritic WHEN pc_calcula_valor_iof_epr.pr_dscritic <> ?.
                   IF aux_dscritic <> "" THEN
                     RETURN "NOK".
                      
                   \* Soma IOF complementar ao saldo, se tiver IOF complementar e não for imune *\
                   ASSIGN tt-pagamentos-parcelas.vliofcpl = 0.
                   IF pc_calcula_valor_iof_epr.pr_vliofcpl <> ? AND pc_calcula_valor_iof_epr.pr_flgimune <> ? AND pc_calcula_valor_iof_epr.pr_flgimune <= 0 THEN
                     DO:
                       ASSIGN tt-pagamentos-parcelas.vliofcpl = ROUND(DECI(pc_calcula_valor_iof_epr.pr_vliofcpl),2).
                     END.*/
					 
                
                           /* Valor atual da parcela mais multa mais juros de mora */
                   ASSIGN tt-pagamentos-parcelas.vlatrpag = 
                                      tt-pagamentos-parcelas.vlatupar + 
                                      tt-pagamentos-parcelas.vlmtapar + 
                              tt-pagamentos-parcelas.vlmrapar +
                              tt-pagamentos-parcelas.vliofcpl
                
                           /* Saldo para relatorios */
                   aux_vlsderel = aux_vlsderel + tt-pagamentos-parcelas.vlatupar + tt-pagamentos-parcelas.vliofcpl
                
                           /* Saldo devedor total do emprestimo */
                   aux_vlsdeved = aux_vlsdeved + tt-pagamentos-parcelas.vlatrpag + tt-pagamentos-parcelas.vliofcpl.
                   
                END.
       END.

              /* Financiamento */
       ASSIGN aux_nrdolote[1] = 600013
              /* Emprestimo */
              aux_nrdolote[2] = 600012
              /* Estorno */
              aux_nrdolote[3] = 600031

              /* Financiamento */
              aux_cdhistor[1] = 1039
              aux_cdhistor[2] = 1057
              /* Emprestimo */
              aux_cdhistor[3] = 1044
              aux_cdhistor[4] = 1045

              /* Estorno Financiamento */
              aux_cdhistor[5] = 1716
              aux_cdhistor[6] = 1707

              /* Estorno Emprestimo */
              aux_cdhistor[7] = 1714
              aux_cdhistor[8] = 1705.

       
       DO aux_contlote = 1 TO 3:

           DO aux_contador = 1 TO 8:
                  
              /* Total pago no mes */
              FOR EACH craplem 
                  WHERE craplem.cdcooper = par_cdcooper               AND
                        craplem.nrdconta = par_nrdconta               AND
                        craplem.nrctremp = par_nrctremp               AND
                        craplem.nrdolote = aux_nrdolote[aux_contlote] AND
                        craplem.cdhistor = aux_cdhistor[aux_contador]
                        NO-LOCK:
        
                  IF YEAR(par_dtmvtolt)  = YEAR(craplem.dtmvtolt)  AND
                     MONTH(par_dtmvtolt) = MONTH(craplem.dtmvtolt) THEN
                     DO:
                       FOR FIRST crabhis_2 FIELDS(indebcre)
                           WHERE crabhis_2.cdcooper = craplem.cdcooper
                             AND crabhis_2.cdhistor = craplem.cdhistor 
                       NO-LOCK: END.

                       IF NOT AVAIL(crabhis_2) THEN
                          DO:
                             ASSIGN aux_cdcritic = 356
                                    aux_dscritic = "".

                             RUN gera_erro (INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT 1, 
                                            INPUT aux_cdcritic,
                                            INPUT-OUTPUT aux_dscritic).
                             RETURN "NOK".
                          END.
                       
                       IF (crabhis_2.indebcre = "C") THEN
                          ASSIGN aux_vlprepag = aux_vlprepag + craplem.vllanmto.
                       ELSE
                       IF (crabhis_2.indebcre = "D") THEN
                          ASSIGN aux_vlprepag = aux_vlprepag - craplem.vllanmto.

                     END.
    
              END. /* FOR EACH craplem */
    
           END. /* END DO aux_contador */

       END. /* END DO aux_contlote */

       CREATE tt-calculado.
       ASSIGN tt-calculado.qtprecal = crapepr.qtprecal.

       IF   par_dtmvtolt <= crawepr.dtlibera THEN /* Nao liberado */
	        DO:
	            ASSIGN tt-calculado.vlsdeved = crapepr.vlemprst
        	           tt-calculado.vlsderel = crapepr.vlemprst
                       tt-calculado.vlsdvctr = crapepr.vlemprst
	                   tt-calculado.vlprepag = 0 
        	           tt-calculado.vlpreapg = 0.
            END.
       ELSE
            DO:
                ASSIGN  tt-calculado.vlsdeved = aux_vlsdeved  
                        tt-calculado.vlsderel = aux_vlsderel
                        tt-calculado.vlsdvctr = aux_vlsdvctr
                        tt-calculado.vlprepag = aux_vlprepag
                        tt-calculado.vlpreapg = aux_vlpreapg.
            END.
                                
       ASSIGN aux_flgtrans = TRUE.
       
    END.

    IF   NOT aux_flgtrans   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1, 
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    IF   par_flgerlog   THEN
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

END PROCEDURE. /* busca pagamentos parcelas */


PROCEDURE calcula_atraso_parcela:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/


    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrparepr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlpagpar AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM par_vlpagsld AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vlatupar AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vlmtapar AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vljinpar AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vlmrapar AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vliofcpl AS DECI                           NO-UNDO.    
    DEF OUTPUT PARAM par_vljinp59 AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vljinp60 AS DECI                           NO-UNDO.

    
    DEF          VAR aux_percmult AS DECI                           NO-UNDO.
    DEF          VAR aux_vlsldpar AS DECI                           NO-UNDO.
    DEF          VAR aux_qtdiasld AS DECI                           NO-UNDO.
    DEF          VAR aux_qtdianor AS DECI                           NO-UNDO.
    DEF          VAR aux_qtdiamor AS DECI                           NO-UNDO.
    DEF          VAR aux_nrdiamta AS INTE                           NO-UNDO.
    DEF          VAR aux_prtljuro AS DECI                           NO-UNDO.   
    DEF          VAR aux_flgtrans AS LOGI                           NO-UNDO.
    DEF          VAR aux_dtmvtolt AS DATE                           NO-UNDO.
    DEF          VAR aux_cdhistor LIKE craplem.cdhistor EXTENT 4    NO-UNDO.
    DEF          VAR aux_diavtolt AS INTE                           NO-UNDO.
    DEF          VAR aux_mesvtolt AS INTE                           NO-UNDO.
    DEF          VAR aux_anovtolt AS INTE                           NO-UNDO.
    DEF          VAR aux_txdiaria AS DECI DECIMALS 10               NO-UNDO.
    DEF          VAR aux_conthist AS INTE                           NO-UNDO.
    DEF		       VAR aux_dscritic AS CHAR                           NO-UNDO. 
    DEF		       VAR aux_vlbasiof AS DECI                           NO-UNDO.
    DEF          VAR aux_vliofcpg AS DECI                           NO-UNDO.
    DEF          VAR aux_qtdiaiof AS INTEGER                        NO-UNDO.

    DEF BUFFER crabpep    FOR crappep.
    DEF BUFFER crabepr    FOR crapepr.

    EMPTY TEMP-TABLE tt-erro.

    IF   par_flgerlog THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Calcula atraso de parcela".

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    Calcula:
    DO ON ERROR UNDO , LEAVE:

       /* Emprestimo */
       FIND crabepr WHERE crabepr.cdcooper = par_cdcooper   AND
                          crabepr.nrdconta = par_nrdconta   AND
                          crabepr.nrctremp = par_nrctremp   
                          NO-LOCK NO-ERROR.

       IF   NOT AVAIL crabepr   THEN
            DO:
                ASSIGN aux_cdcritic = 356.

                UNDO Calcula , LEAVE Calcula.
            END.

       FIND craplcr WHERE craplcr.cdcooper = crabepr.cdcooper   AND
                          craplcr.cdlcremp = crabepr.cdlcremp 
                          NO-LOCK NO-ERROR.

       IF   NOT AVAIL craplcr   THEN
            DO:
                ASSIGN aux_cdcritic = 55.
                UNDO Calcula , LEAVE Calcula.
            END.

       /* Verifica a Linha de Credito se permite Cobrar Multa */
       IF craplcr.flgcobmu THEN
          DO:
              /* Obter o % de multa da CECRED - TAB090 */
              FIND craptab WHERE craptab.cdcooper = 3              AND
                                 craptab.nmsistem = "CRED"         AND
                                 craptab.tptabela = "USUARI"       AND
                                 craptab.cdempres = 11             AND
                                 craptab.cdacesso = "PAREMPCTL"    AND
                                 craptab.tpregist = 01    
                                 NO-LOCK NO-ERROR.
        
              IF   NOT AVAIL craptab   THEN
                   DO:
                       ASSIGN aux_cdcritic = 55.
        
                       UNDO Calcula , LEAVE Calcula.            
                   END.

              ASSIGN aux_percmult = DEC(SUBSTRING(craptab.dstextab,1,6)).
          END.
       ELSE
          ASSIGN aux_percmult = 0.

       /* Parcela */
       FIND crabpep WHERE crabpep.cdcooper = par_cdcooper   AND
                          crabpep.nrdconta = par_nrdconta   AND
                          crabpep.nrctremp = par_nrctremp   AND
                          crabpep.nrparepr = par_nrparepr   NO-LOCK NO-ERROR.

       IF   NOT AVAIL crabpep   THEN
            DO:
                ASSIGN aux_dscritic = "Parcela nao encontrada.".

                UNDO Calcula, LEAVE Calcula.
            END.

              /* Prazo para tolerancia da multa */
       ASSIGN aux_nrdiamta = crabepr.qttolatr
              /* Prazo de tolerancia para incidencia de juros de mora */    
              aux_prtljuro = aux_nrdiamta.
                       
       /* Se ainda nao pagou nada da parcela, pegar a data de vencimento dela */  
       IF   crabpep.dtultpag = ?                  OR 
            crabpep.dtultpag < crabpep.dtvencto   THEN
            ASSIGN aux_dtmvtolt = crabpep.dtvencto.
       ELSE
            DO: /* Senao pegar a ultima data que pagou a parcela  */                
                  ASSIGN aux_dtmvtolt = crabpep.dtultpag. 
            END.
              
       ASSIGN aux_diavtolt = DAY(par_dtmvtolt)     
              aux_mesvtolt = MONTH(par_dtmvtolt)   
              aux_anovtolt = YEAR(par_dtmvtolt)
              aux_qtdiaiof = par_dtmvtolt - aux_dtmvtolt.    

       /* Calcular quantidade de dias para o saldo devedor */
       RUN sistema/generico/procedures/b1wgen0084.p PERSISTENT SET h-b1wgen0084.

       /* Calcular quantidade de dias para o saldo devedor */
       RUN Dias360 IN h-b1wgen0084 
                   (INPUT FALSE,
                    INPUT DAY(crabepr.dtdpagto),
                    INPUT DAY(aux_dtmvtolt),  
                    INPUT MONTH(aux_dtmvtolt),
                    INPUT YEAR(aux_dtmvtolt), 
                    INPUT-OUTPUT aux_diavtolt,
                    INPUT-OUTPUT aux_mesvtolt,
                    INPUT-OUTPUT aux_anovtolt,
                    OUTPUT aux_qtdiasld).

       DELETE PROCEDURE h-b1wgen0084.

       /* Calcula quantos dias passaram do vencimento até o parametro par_dtmvtolt 
          será usado para comparar se a quantidade de dias que passou está dentro
          da tolerância */
       aux_qtdianor = par_dtmvtolt - crabpep.dtvencto.

       /* Se ainda nao pagou nada da parcela, pegar a data de vencimento dela */  
       IF   crabpep.dtultpag <> ? OR crabpep.vlpagmra > 0  THEN
            DO: 
                       /* Financiamento */
                ASSIGN aux_cdhistor[1] = 1078
                       aux_cdhistor[2] = 1620
                
                       /* Emprestimo */ 
                       aux_cdhistor[3] = 1077
                       aux_cdhistor[4] = 1619.
                   
                DO aux_conthist = 1 TO 4:
                   
                   /* Obter ultimo lancamento de juro do contrato */
                   FOR EACH craplem FIELDS(dtmvtolt)
                      WHERE craplem.cdcooper = par_cdcooper               AND
                            craplem.nrdconta = par_nrdconta               AND
                            craplem.nrctremp = par_nrctremp               AND
                            craplem.nrparepr = par_nrparepr               AND
                            craplem.cdhistor = aux_cdhistor[aux_conthist]
                            NO-LOCK:
                   
                       IF craplem.dtmvtolt > aux_dtmvtolt OR   
                          aux_dtmvtolt = ?                THEN
                          ASSIGN aux_dtmvtolt = craplem.dtmvtolt.  
                   
                   END. /* END FOR EACH craplem */

                END. /* END DO aux_conthist */

            END. /* END IF crabpep.dtultpag <> ? */
              
       /* Calcular quantidade de dias para o juros de mora desde 
        o ultima ocorrência de juros de mora/vencimento até o par_dtmvtolt */
       aux_qtdiamor = par_dtmvtolt - aux_dtmvtolt.

       /* Calculo do valor da multa */
       /* Verifica se esta na tolerancia da multa, 
          aux_qtdianor é quantidade de dias que passaram 
          aux_nrdiamta é quantidade de dias de tolerância parametrizada */
       ASSIGN aux_percmult = IF aux_qtdianor <= aux_nrdiamta THEN 
                                0
                             ELSE 
                                aux_percmult 

              par_vlmtapar = ROUND(crabpep.vlparepr * aux_percmult / 100,2) - 
                             crabpep.vlpagmta.
           
       /* Valor saldo devedor da parcela  */
       ASSIGN aux_vlsldpar = crabpep.vlsdvpar.

       /* Considerando valor da parcela */
       RUN calcula_juros_normais_total (INPUT aux_vlsldpar,
                                        INPUT crabepr.txmensal,
                                        INPUT aux_qtdiasld,
                                        OUTPUT par_vljinpar).
       
       /* calculado na include crps310.i */
       /*
       IF   aux_qtdiasld > 59   THEN
            DO:
                /* Considerando valor da parcela ate 59 dias */
                RUN calcula_juros_normais_total (INPUT aux_vlsldpar,
                                                 INPUT crabepr.txmensal,
                                                 INPUT 59,
                                                 OUTPUT par_vljinp59).
                
                /* Comentado por Irlan. Nao eh necessario calcular, basta subtrair
                   par_vljinpar - par_vljinpar */
                
                /* Considerando valor da parcela retirando os 59 dias */

                /*
                RUN calcula_juros_normais_total (INPUT aux_vlsldpar + par_vljinp59,
                                                 INPUT crabepr.txmensal,
                                                 INPUT aux_qtdiasld - 59,
                                                 OUTPUT par_vljinp60).
                */

                par_vljinp60 = par_vljinpar - par_vljinp59.

            END.
       
       ELSE
            DO:
                /* Considerando valor da parcela ate 59 dias */
                RUN calcula_juros_normais_total (INPUT aux_vlsldpar,
                                                 INPUT crabepr.txmensal,
                                                 INPUT aux_qtdiasld,
                                                 OUTPUT par_vljinp59).
            END.
       */
       /* Valor atual parcela */
       ASSIGN par_vlatupar = crabpep.vlsdvpar + par_vljinpar.

       /* Calcular o valor dos juros de mora */
       
       /* Verifica se esta na tolerancia dos juros de mora, 
          aux_qtdianor é quantidade de dias que passaram 
          aux_prtljuro é quantidade de dias de tolerância parametrizada */
       IF   aux_qtdianor <= aux_prtljuro   THEN
            ASSIGN par_vlmrapar = 0.
       ELSE 
            ASSIGN aux_txdiaria = 
       
                     ROUND( (100 * (EXP ((craplcr.perjurmo  / 100) + 1 , (1 / 30)) - 1)), 10)

                   aux_txdiaria =   aux_txdiaria / 100
                   
                   par_vlmrapar = crabpep.vlsdvsji * aux_txdiaria * aux_qtdiamor.
                                   
                   /** Necessario arredondar devido a diferencas entre LCM e LEM **/
                   par_vlmrapar = ROUND(par_vlmrapar,2).
                                   
                    /* Calcular IOF por atraso */	   
                    /* Projeto 410 - Novo IOF */

                   /* calcula valor base do IOF de acordo com valor principal (parcela - juros) */
                   ASSIGN aux_vlbasiof = crabpep.vlparepr / (EXP((1 + crabepr.txmensal / 100 ), 
                                                                    ( crabepr.qtpreemp -  crabpep.nrparepr + 1))).                   
                   

                   /* BAse do IOF Complementar é o menor valor entre o Principal ou o Saldo Devedor */           
                   IF aux_vlbasiof > crabpep.vlsdvsji THEN
                   DO:
                       ASSIGN aux_vlbasiof = crabpep.vlsdvsji.
                   END.  
                   
                   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                   RUN STORED-PROCEDURE pc_calcula_valor_iof_epr
                   aux_handproc = PROC-HANDLE NO-ERROR (INPUT 2                /* Somente IOF Complementar do Atraso */
                                                       ,INPUT par_cdcooper     /* Código da cooperativa referente ao contrato de empréstimos */
                                                       ,INPUT par_nrdconta     /* Número da conta referente ao empréstimo */
                                                       ,INPUT par_nrctremp     /* Número do contrato de empréstimo */
                                                       ,INPUT aux_vlbasiof     /*crapepr.vlsdeved*/     /* Valor do empréstimo para efeito de cálculo */
                                                       ,INPUT crabepr.vlemprst /* vltotope */
                                           ,INPUT ""               /* Descrição da categoria do bem, valor default NULO  */
                                                       ,INPUT crabepr.cdlcremp     /* Linha de crédito do empréstimo */
                                                       ,INPUT crabepr.cdfinemp     /* Finalidade do crédito do empréstimo */
                                                       ,INPUT par_dtmvtolt     /* Data do movimento */
                                           ,INPUT aux_qtdiaiof     /* Quantidade de dias em atraso */
                                                       ,OUTPUT 0               /* Valor do IOF principal */
                                                       ,OUTPUT 0               /* Valor do IOF adicional */
                                                       ,OUTPUT 0               /* Valor do IOF complementar */
                                                       ,OUTPUT 0               /* Valor da Taxa do IOF Principal */
                                                       ,OUTPUT 0               /* Possui imunidade tributária */
                                                       ,OUTPUT "").            /* Critica */
             
                   /* Fechar o procedimento para buscarmos o resultado */ 
                   CLOSE STORED-PROC pc_calcula_valor_iof_epr

                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
                   /* Se retornou erro */
                   ASSIGN aux_dscritic = ""
                          aux_dscritic = pc_calcula_valor_iof_epr.pr_dscritic WHEN pc_calcula_valor_iof_epr.pr_dscritic <> ?.
                          

                   IF aux_dscritic <> "" THEN
                     UNDO Calcula , LEAVE Calcula.            
/*                     RETURN "NOK".*/
                     
                     
                   /* Soma IOF complementar ao saldo, se tiver IOF complementar e não for imune */
                   ASSIGN par_vliofcpl = 0.
                   IF pc_calcula_valor_iof_epr.pr_vliofcpl <> ? 
				           AND pc_calcula_valor_iof_epr.pr_flgimune <> ? 
				           AND pc_calcula_valor_iof_epr.pr_flgimune <= 0 THEN
                     DO:
                       ASSIGN par_vliofcpl = ROUND(DECI(pc_calcula_valor_iof_epr.pr_vliofcpl),2).
                     END.
                     
                   IF par_vliofcpl <> ? AND crabpep.vlpagiof > 0 THEN
                     DO:
                       ASSIGN par_vliofcpl = par_vliofcpl - crabpep.vlpagiof.
                       IF par_vliofcpl < 0 THEN
                         DO:
                           ASSIGN par_vliofcpl = 0.
                         END.
                     END.  
                     
                     
                     
       /* Valor a pagar - multa e juros de mora  */
       ASSIGN  par_vlpagsld = IF   par_vlpagpar <> 0   THEN
                                   par_vlpagpar - (ROUND(par_vlmtapar,2) + 
                                                                 ROUND(par_vlmrapar,2) +
                                                                 ROUND(par_vliofcpl,2))
                              ELSE 
                                   par_vlatupar .
                  
       ASSIGN aux_flgtrans = TRUE.

    END. /* Calcula */

    IF   NOT aux_flgtrans  THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1, 
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
              RETURN "NOK".
         END.

    IF   par_flgerlog   THEN
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

END PROCEDURE. /* calcula atraso parcela */


PROCEDURE calcula_desconto_parcela:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrparepr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dspagpar AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtoan AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-desconto.
    
    DEF VAR aux_contador          AS INTE                           NO-UNDO.
    DEF VAR aux_dspagpar          AS CHAR                           NO-UNDO.
    DEF VAR aux_nrparepr          AS INTE                           NO-UNDO.
    DEF VAR aux_vlpagpar          AS DECI                           NO-UNDO.
    DEF VAR aux_vldespar          AS DECI                           NO-UNDO.
    DEF VAR aux_vlatupar          AS DECI                           NO-UNDO.
    DEF VAR aux_flgtrans          AS LOGI                           NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-desconto.
    EMPTY TEMP-TABLE tt-pagamentos-parcelas.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    Calculo:
    DO ON ERROR UNDO, LEAVE :

       FIND crapepr WHERE crapepr.cdcooper = par_cdcooper   AND
                          crapepr.nrdconta = par_nrdconta   AND
                          crapepr.nrctremp = par_nrctremp
                          NO-LOCK NO-ERROR.

       IF   NOT AVAIL crapepr   THEN
            DO:
                aux_cdcritic = 356.
                LEAVE Calculo.
            END.
                
       DO aux_contador = 1 TO NUM-ENTRIES(par_dspagpar,"|"):
            
            ASSIGN aux_dspagpar = ENTRY(aux_contador,par_dspagpar,"|")
                   aux_nrparepr = INTE (ENTRY(1,aux_dspagpar,";")) 
                   aux_vlpagpar = DECI (ENTRY(2,aux_dspagpar,";")).

            CREATE tt-pagamentos-parcelas.
            ASSIGN tt-pagamentos-parcelas.nrparepr = aux_nrparepr
                   tt-pagamentos-parcelas.vlpagpar = aux_vlpagpar.

       END.

       FOR EACH crappep WHERE crappep.cdcooper = par_cdcooper   AND
                              crappep.nrdconta = par_nrdconta   AND
                              crappep.nrctremp = par_nrctremp   AND
                             (crappep.nrparepr = par_nrparepr   OR
                              par_nrparepr  = 0)                NO-LOCK:

           IF   crappep.inliquid = 1   THEN
                NEXT.
            
           /* Parcela a Vencer */
           IF   crappep.dtvencto <= par_dtmvtolt   THEN 
                NEXT.

           RUN calcula_antecipacao_parcela (INPUT crappep.cdcooper,
                                            INPUT crappep.dtvencto,
                                            INPUT crappep.vlsdvpar,
                                            INPUT crapepr.txmensal,
                                            INPUT par_dtmvtolt,
                                            INPUT crapepr.dtdpagto,
                                           OUTPUT aux_vlatupar,
                                           OUTPUT aux_vldespar).
                                   
           /* Considerar valor atualizado da parcela */
           FIND tt-pagamentos-parcelas WHERE 
                tt-pagamentos-parcelas.nrparepr = crappep.nrparepr
                NO-LOCK NO-ERROR.

           IF   NOT AVAIL tt-pagamentos-parcelas   THEN
                NEXT.

           ASSIGN aux_vlpagpar = tt-pagamentos-parcelas.vlpagpar.

                /* Pagamento antecipado parcial */
           IF   aux_vlpagpar < aux_vlatupar   THEN
                RUN calcula_antecipacao_parcela_parcial
                                                    (INPUT crappep.cdcooper,
                                                     INPUT crappep.dtvencto,
                                                     INPUT crapepr.txmensal,
                                                     INPUT par_dtmvtolt,
                                                     INPUT aux_vlpagpar,
                                                     INPUT crapepr.dtdpagto,
                                                    OUTPUT aux_vldespar).
                
           ASSIGN aux_vldespar = ROUND( aux_vldespar , 2)
                  aux_vldespar = 0 WHEN aux_vldespar < 0.
            
           CREATE tt-desconto.
           ASSIGN tt-desconto.nrparepr = crappep.nrparepr
                  tt-desconto.vldespar = aux_vldespar.
       
       END.

       ASSIGN aux_flgtrans = TRUE.

    END.
        
    IF   NOT aux_flgtrans  THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1, 
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
              RETURN "NOK".
         END.

    IF   par_flgerlog   THEN
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



PROCEDURE calcula_antecipacao_parcela:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/   


    DEF  INPUT PARAM par_cdcooper AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_dtvencto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vlsdvpar AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_txmensal AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM par_vlatupar AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vldespar AS DECI                           NO-UNDO.

    DEF          VAR aux_vlsldpar AS DECI                           NO-UNDO.
    DEF          VAR aux_ndiasant AS INTE                           NO-UNDO.
    DEF          VAR aux_diavenct AS INTE                           NO-UNDO.
    DEF          VAR aux_mesvenct AS INTE                           NO-UNDO.
    DEF          VAR aux_anovenct AS INTE                           NO-UNDO.


    ASSIGN aux_diavenct = DAY(par_dtvencto)
           aux_mesvenct = MONTH(par_dtvencto)
           aux_anovenct = YEAR(par_dtvencto).

    RUN sistema/generico/procedures/b1wgen0084.p PERSISTENT SET h-b1wgen0084.

    RUN Dias360 IN h-b1wgen0084 (INPUT FALSE,
                                 INPUT DAY(par_dtdpagto),
                                 INPUT DAY(par_dtmvtolt),
                                 INPUT MONTH(par_dtmvtolt),
                                 INPUT YEAR(par_dtmvtolt),
                                 INPUT-OUTPUT aux_diavenct,
                                 INPUT-OUTPUT aux_mesvenct,
                                 INPUT-OUTPUT aux_anovenct,
                                 OUTPUT aux_ndiasant).

    DELETE PROCEDURE h-b1wgen0084.

    ASSIGN aux_vlsldpar = par_vlsdvpar
           par_vlatupar = ROUND(aux_vlsldpar * 
                          EXP(1 + (par_txmensal / 100),- aux_ndiasant / 30)
                                ,2)
           par_vldespar = aux_vlsldpar - par_vlatupar.

    RETURN "OK".

END PROCEDURE. /* calcula antecipacao parcela */


PROCEDURE gera_pagamentos_parcelas:

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
    DEF  INPUT PARAM par_totatual AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_totpagto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqava AS INTE                           NO-UNDO.

    DEF  INPUT PARAM TABLE FOR tt-pagamentos-parcelas.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabpep FOR crappep.

    DEF VAR aux_flgtrans          AS LOGI                           NO-UNDO.
    DEF VAR h-b1wgen0136          AS HANDLE                         NO-UNDO.

    DEF VAR aux_menor_parcela     AS INTE                           NO-UNDO.
    DEF VAR aux_nrseqpgo          AS INTE                           NO-UNDO.

    EMPTY TEMP-TABLE tt-erro. 
    
    IF   par_flgerlog THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,",")).
                    

    IF   NOT CAN-FIND(FIRST tt-pagamentos-parcelas)   THEN
         DO:
             ASSIGN  aux_cdcritic = 0
                     aux_dscritic = "Para efetuar o pagamento selecione " +
                                    "a(s) parcela(s).".
       
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1, 
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.


    FOR FIRST crapprm
    WHERE crapprm.cdcooper = par_cdcooper AND
          crapprm.cdacesso = "COBEMP_BLQ_RESG_CC"
         NO-LOCK:

        IF  crapprm.dsvlrprm = "S" THEN
            DO:
                /* buscar ultimo boleto do contratos */
                FOR EACH tbrecup_cobranca FIELDS (cdcooper nrdconta_cob nrcnvcob nrboleto nrctremp)
                   WHERE tbrecup_cobranca.cdcooper = par_cdcooper AND
                         tbrecup_cobranca.nrdconta = par_nrdconta AND    
                         tbrecup_cobranca.nrctremp = par_nrctremp AND
                         tbrecup_cobranca.tpproduto = 0
                         NO-LOCK    
                         BY tbrecup_cobranca.nrboleto DESC:
                    
                        /* verificar se o boleto do contrato está em aberto */
                        FOR FIRST crapcob FIELDS (dtvencto vltitulo)
                            WHERE crapcob.cdcooper = tbrecup_cobranca.cdcooper
                              AND crapcob.nrdconta = tbrecup_cobranca.nrdconta_cob
                              AND crapcob.nrcnvcob = tbrecup_cobranca.nrcnvcob
                              AND crapcob.nrdocmto = tbrecup_cobranca.nrboleto
                              AND crapcob.incobran = 0 NO-LOCK:
                
                            ASSIGN  aux_cdcritic = 0
                                    aux_dscritic = "Boleto do contrato " + STRING(tbrecup_cobranca.nrctremp) + 
                                                   " em aberto." +      
                                                   " Vencto " + STRING(crapcob.dtvencto,"99/99/9999") +      
                                                   " R$ " + TRIM(STRING(crapcob.vltitulo, "zzz,zzz,zz9.99-")) + ".".    
                            LEAVE.    
            
                        END.          
                
                        /* verificar se o boleto do contrato está em pago, pendente de processamento */
                        FOR FIRST crapcob FIELDS (dtvencto vltitulo dtdpagto)
                            WHERE crapcob.cdcooper = tbrecup_cobranca.cdcooper
                              AND crapcob.nrdconta = tbrecup_cobranca.nrdconta_cob
                              AND crapcob.nrcnvcob = tbrecup_cobranca.nrcnvcob
                              AND crapcob.nrdocmto = tbrecup_cobranca.nrboleto
                              AND crapcob.incobran = 5 NO-LOCK:
                
                                FOR FIRST crapret      
                                    WHERE crapret.cdcooper = crapcob.cdcooper    
                                      AND crapret.nrdconta = crapcob.nrdconta     
                                      AND crapret.nrcnvcob = crapcob.nrcnvcob     
                                      AND crapret.nrdocmto = crapcob.nrdocmto     
                                      AND crapret.cdocorre = 6     
                                      AND crapret.dtocorre = crapcob.dtdpagto     
                                      AND crapret.flcredit = 0     
                                      NO-LOCK:    
                
                                    ASSIGN  aux_cdcritic = 0
                                            aux_dscritic = "Boleto do contrato " + STRING(tbrecup_cobranca.nrctremp) + 
                                                           " esta pago pendente de processamento." +       
                                                           " Vencto " + STRING(crapcob.dtvencto,"99/99/9999") +      
                                                           " R$ " + TRIM(STRING(crapcob.vltitulo, "zzz,zzz,zz9.99-")) + ".".    
                                    LEAVE.
                   
                                END.
                        END.   
                END.
            END.
    END.

    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1, 
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
        END.

        
    BLOCO_TRANSACAO:
    DO TRANSACTION ON ERROR UNDO, LEAVE:

       IF    par_totatual = par_totpagto   THEN /* Liquida Emprestimo */
             DO:
                 /* Trazer todas as parcelas */
                 RUN busca_pagamentos_parcelas 
                                        (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_cdoperad,
                                         INPUT par_nmdatela,
                                         INPUT par_idorigem,
                                         INPUT par_nrdconta,
                                         INPUT 1,
                                         INPUT par_dtmvtolt,
                                         INPUT par_flgerlog,
                                         INPUT par_nrctremp,
                                         INPUT par_dtmvtoan,
                                         INPUT 0, /* Todas */
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-pagamentos-parcelas,
                                        OUTPUT TABLE tt-calculado).  

                 IF   RETURN-VALUE <> "OK"   THEN
                      UNDO BLOCO_TRANSACAO, LEAVE BLOCO_TRANSACAO.

                 IF par_idorigem = 3 THEN
                 DO:
                 
    				 FIND FIRST crapepr 
    					  WHERE crapepr.cdcooper = par_cdcooper
    					    AND crapepr.nrdconta = par_nrdconta
    						AND crapepr.nrctremp = par_nrctremp
    						EXCLUSIVE-LOCK NO-ERROR.
    
    				 IF AVAIL(crapepr) THEN
    				 DO:
    				   IF crapepr.dtapgoib = ? THEN
                       DO:
                      
    				     crapepr.dtapgoib = TODAY.
    					 
    					 RUN proc_gerar_log (INPUT par_cdcooper,
    										 INPUT par_cdoperad,
    										 INPUT "",
    										 INPUT aux_dsorigem,
    										 INPUT "Aceite Pagamento Contrato Internet Bank",
    										 INPUT TRUE,
    										 INPUT par_idseqttl,
    										 INPUT par_nmdatela,
    										 INPUT par_nrdconta,
    									    OUTPUT aux_nrdrowid).
                                       
    					RUN proc_gerar_log_item (INPUT aux_nrdrowid,
    											 INPUT "dtapgoib", 
    											 INPUT STRING(TODAY),
    											 INPUT STRING(TODAY)).
    				   END.  
    				 END. /* AVAIL(crapepr) */
    				 ELSE
    				 DO:
    				  ASSIGN aux_cdcritic = 0
    				 	     aux_dscritic = "Contrato nao Localizado.".
    
    					  UNDO BLOCO_TRANSACAO, LEAVE BLOCO_TRANSACAO.    
    				 END. 

                 END.

                 RUN sistema/generico/procedures/b1wgen0136.p 
                      PERSISTENT SET h-b1wgen0136.

                 RUN efetua_liquidacao_empr IN h-b1wgen0136
                                          (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdoperad,
                                           INPUT par_nmdatela,
                                           INPUT par_idorigem,
                                           INPUT par_cdpactra,
                                           INPUT par_nrdconta,
                                           INPUT 1,
                                           INPUT par_dtmvtolt,
                                           INPUT FALSE,
                                           INPUT par_nrctremp,
                                           INPUT par_dtmvtoan,
                                           INPUT FALSE,
                                           INPUT TABLE tt-pagamentos-parcelas,
                                           INPUT par_nrseqava,
                                          OUTPUT TABLE tt-erro).

                 DELETE PROCEDURE h-b1wgen0136.

                 IF   RETURN-VALUE <> "OK"   THEN
                      UNDO BLOCO_TRANSACAO, LEAVE BLOCO_TRANSACAO.

                 ASSIGN aux_flgtrans = TRUE.

                 LEAVE BLOCO_TRANSACAO.
             END.

       FIND FIRST crappep 
            WHERE crappep.cdcooper = par_cdcooper
              AND crappep.nrdconta = par_nrdconta
              AND crappep.nrctremp = par_nrctremp
              AND crappep.inliquid = 0              
              NO-LOCK NO-ERROR.
                                         
       IF AVAIL(crappep) THEN
	     ASSIGN aux_menor_parcela = crappep.nrparepr.

       ASSIGN aux_nrseqpgo = 0.

       /* Se encontra menor parcela indicando que pagamento eh do inicio para final */
       FIND FIRST tt-pagamentos-parcelas
            WHERE tt-pagamentos-parcelas.nrparepr = aux_menor_parcela
            NO-LOCK NO-ERROR.

       IF AVAIL(tt-pagamentos-parcelas) THEN
       DO: /* Do Inicio para o Final */
         FOR EACH tt-pagamentos-parcelas 
           BREAK BY tt-pagamentos-parcelas.nrparepr:

           ASSIGN aux_nrseqpgo = aux_nrseqpgo + 1
                  tt-pagamentos-parcelas.nrseqpgo = aux_nrseqpgo.

         END.
       END.
       ELSE
       DO: /* Do Final para o Inicio */	
         FOR EACH tt-pagamentos-parcelas 
           BREAK BY tt-pagamentos-parcelas.nrparepr DESC:

           ASSIGN aux_nrseqpgo = aux_nrseqpgo + 1
                  tt-pagamentos-parcelas.nrseqpgo = aux_nrseqpgo.

         END.
       END.

       IF par_idorigem = 3 THEN
       DO:
       
           FIND FIRST crapepr 
               WHERE crapepr.cdcooper = par_cdcooper
                 AND crapepr.nrdconta = par_nrdconta
                 AND crapepr.nrctremp = par_nrctremp
                 EXCLUSIVE-LOCK NO-ERROR.
    
           IF AVAIL(crapepr) THEN
           DO:
             IF crapepr.dtapgoib = ? THEN
             DO:
               
               crapepr.dtapgoib = TODAY.
               
               RUN proc_gerar_log (INPUT par_cdcooper,
                                   INPUT par_cdoperad,
                                   INPUT "",
                                   INPUT aux_dsorigem,
                                   INPUT "Aceite Pagamento Contrato Internet Bank",
                                   INPUT TRUE,
                                   INPUT par_idseqttl,
                                   INPUT par_nmdatela,
                                   INPUT par_nrdconta,
                                  OUTPUT aux_nrdrowid).
                                   
               RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                        INPUT "dtapgoib", 
                                        INPUT STRING(TODAY),
                                        INPUT STRING(TODAY)).
             END.
           END.
           ELSE
           DO:
               ASSIGN aux_cdcritic = 0
                      aux_dscritic = "Contrato nao Localizado.".
    
                      UNDO BLOCO_TRANSACAO, LEAVE BLOCO_TRANSACAO.    
           END.

       END.
             
       FOR EACH tt-pagamentos-parcelas BREAK BY tt-pagamentos-parcelas.nrseqpgo:
            
            FIND crappep WHERE 
                 crappep.cdcooper = tt-pagamentos-parcelas.cdcooper   AND
                 crappep.nrdconta = tt-pagamentos-parcelas.nrdconta   AND
                 crappep.nrctremp = tt-pagamentos-parcelas.nrctremp   AND
                 crappep.nrparepr = tt-pagamentos-parcelas.nrparepr
                 NO-LOCK NO-ERROR.
    
            IF    NOT AVAIL crappep   THEN
                  DO:
                      ASSIGN aux_cdcritic = 0
                             aux_dscritic = "Parcela nao encontrada.".
                     
                      UNDO BLOCO_TRANSACAO, LEAVE BLOCO_TRANSACAO.
                  END.

            /* Verifica se tem uma parcela anterior nao liquida e ja vencida */
            RUN verifica_parcelas_anteriores (INPUT par_cdcooper,
                                              INPUT par_nrdconta,
                                              INPUT par_nrctremp,
                                              INPUT crappep.nrparepr,
                                              INPUT par_dtmvtolt,
                                             OUTPUT aux_dscritic).
            
            IF   RETURN-VALUE <> "OK"   THEN
                 UNDO BLOCO_TRANSACAO, LEAVE BLOCO_TRANSACAO.                    

            /* Verifica se pode antecipar*/
            RUN verifica_parcelas_antecipacao (INPUT par_cdcooper,
                                               INPUT par_nrdconta,
                                               INPUT par_nrctremp,
                                               INPUT crappep.nrparepr,
                                               INPUT par_dtmvtolt,
                                              OUTPUT aux_dscritic).

            IF   RETURN-VALUE <> "OK"   THEN
                 UNDO BLOCO_TRANSACAO, LEAVE BLOCO_TRANSACAO.  
            
            IF   crappep.inliquid = 1 /* liquidada */    THEN
                 DO:
                     ASSIGN aux_cdcritic = 0
                            aux_dscritic = "Parcela ja liquidada!".

                     UNDO BLOCO_TRANSACAO, LEAVE BLOCO_TRANSACAO.                    
                 END.

            IF   crappep.dtvencto >  par_dtmvtoan   AND 
                 crappep.dtvencto <= par_dtmvtolt   THEN /* Parcela em dia */
                 DO: 
                     RUN efetiva_pagamento_normal_parcela
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
                                        INPUT  tt-pagamentos-parcelas.vlpagpar,
                                        INPUT  par_nrseqava,
                                        OUTPUT TABLE tt-erro).

                     IF   RETURN-VALUE <> "OK"   THEN
                          UNDO BLOCO_TRANSACAO, LEAVE BLOCO_TRANSACAO.
                 END.
            ELSE
            IF   crappep.dtvencto < par_dtmvtolt   THEN /* Parcela Vencida */
                 DO: 
                     RUN efetiva_pagamento_atrasado_parcela
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
                                       INPUT  tt-pagamentos-parcelas.vlpagpar,
                                       INPUT  par_nrseqava,
                                       OUTPUT TABLE tt-erro).

                     IF   RETURN-VALUE <> "OK"   THEN
                          UNDO BLOCO_TRANSACAO, LEAVE BLOCO_TRANSACAO.
                 END.
            ELSE
            IF   crappep.dtvencto > par_dtmvtolt   THEN /* Parcela a Vencer */
                 DO: 
                     RUN efetiva_pagamento_antecipado_parcela
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
                                         INPUT  tt-pagamentos-parcelas.vlpagpar,
                                         INPUT  par_nrseqava,
                                         OUTPUT TABLE tt-erro).

                     IF   RETURN-VALUE <> "OK"   THEN
                          UNDO BLOCO_TRANSACAO, LEAVE BLOCO_TRANSACAO.
                 END.          

        END. /* FOR EACH tt-pagamentos-parcelas:  */        
        
        ASSIGN aux_flgtrans = TRUE.

    END. /* DO TRANSACTION (BLOCO_TRANSACAO) */

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
END PROCEDURE. /* gera pagamentos parcelas */

PROCEDURE efetiva_pagamento_normal_parcela_craplem:

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
    DEF  INPUT PARAM par_nrparepr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlparepr AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqava AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_cdhistor AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_nrdolote AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF          VAR aux_vljurmes AS DECI                           NO-UNDO.
    DEF          VAR aux_cdhistor AS INTE                           NO-UNDO.
    DEF          VAR aux_flgtrans AS LOGI                           NO-UNDO.
    DEF          VAR aux_floperac AS LOGI                           NO-UNDO.
    DEF          VAR aux_diarefju AS INTE                           NO-UNDO.
    DEF          VAR aux_mesrefju AS INTE                           NO-UNDO.
    DEF          VAR aux_anorefju AS INTE                           NO-UNDO.
    DEF          VAR aux_nrdolote AS INTE                           NO-UNDO.
    DEF          VAR aux_dtcalcul AS DATE                           NO-UNDO.
    DEF          VAR aux_ehmensal AS LOGI                           NO-UNDO.

    DEF          VAR h-b1wgen0084 AS HANDLE                         NO-UNDO.
    DEF          VAR h-b1wgen0134 AS HANDLE                         NO-UNDO.
    DEF          VAR h-b1wgen0136 AS HANDLE                         NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    IF   par_flgerlog THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Efetiva pagamento normal de parcela craplem".

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    RUN valida_pagamento_normal_parcela (INPUT  par_cdcooper,
                                         INPUT  par_cdagenci,
                                         INPUT  par_nrdcaixa,
                                         INPUT  par_cdoperad,
                                         INPUT  par_nmdatela,
                                         INPUT  par_idorigem,
                                         INPUT  par_nrdconta,
                                         INPUT  par_idseqttl,
                                         INPUT  par_dtmvtolt,
                                         INPUT  par_flgerlog,
                                         INPUT  par_nrctremp,
                                         INPUT  par_nrparepr,
                                         INPUT  par_vlparepr,
                                         OUTPUT TABLE tt-erro).

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".    

    EFETIVA:
    DO ON ENDKEY UNDO , LEAVE ON ERROR UNDO , LEAVE:  
       
       RUN busca_registro_parcela (INPUT par_cdcooper,
                                   INPUT par_nrdconta,
                                   INPUT par_nrctremp,
                                   INPUT par_nrparepr).
       
       IF   RETURN-VALUE <> "OK"   THEN
            UNDO EFETIVA , LEAVE EFETIVA.

       RUN busca_registro_emprestimo (INPUT par_cdcooper,
                                      INPUT par_nrdconta,
                                      INPUT par_nrctremp,
                                     OUTPUT aux_floperac).
       
       IF   RETURN-VALUE <> "OK"   THEN
            UNDO EFETIVA , LEAVE EFETIVA.
       
       ASSIGN aux_nrdolote = IF aux_floperac   THEN /* Financiamento */
                                600013
                             ELSE
                                600012. /* Emprestimo */

       /* Condicao para verificar se o pagamento foi feito por um avalista */
       IF par_nrseqava = 0 OR par_nrseqava = ? THEN
          DO:
              ASSIGN aux_cdhistor = IF aux_floperac THEN
                                       1039
                                    ELSE 
                                       1044.
          END.
       ELSE
          DO:
              ASSIGN aux_cdhistor = IF aux_floperac THEN
                                       1057
                                    ELSE 
                                       1045.
          END.

       RUN sistema/generico/procedures/b1wgen0084.p PERSISTENT SET h-b1wgen0084.

       aux_dtcalcul = DYNAMIC-FUNCTION("fnBuscaDataDoUltimoDiaUtilMes" 
                                     IN h-b1wgen0084, 
                                             INPUT par_cdcooper,
                                             INPUT crappep.dtvencto). 

       DELETE PROCEDURE h-b1wgen0084.

       IF   crappep.dtvencto > aux_dtcalcul   THEN
            DO:
                ASSIGN crapepr.vlsdeved = crapepr.vlsdeved - par_vlparepr
                       aux_ehmensal = TRUE.                         
            END.
       ELSE 
            DO:
                ASSIGN aux_ehmensal = FALSE.
            END.

       RUN lanca_juro_contrato (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT par_nrdconta,
                                INPUT par_nrctremp,
                                INPUT par_dtmvtolt,
                                INPUT par_cdoperad,
                                INPUT par_cdpactra,
                                INPUT TRUE,
                                INPUT crappep.dtvencto,
                                INPUT aux_ehmensal,
                                INPUT crapepr.dtdpagto,
                                INPUT par_idorigem,
                               OUTPUT TABLE tt-erro,
                               OUTPUT aux_vljurmes,
                               OUTPUT aux_diarefju,
                               OUTPUT aux_mesrefju,
                               OUTPUT aux_anorefju).


       IF   RETURN-VALUE <> "OK"   THEN
            UNDO EFETIVA , LEAVE EFETIVA.

       RUN sistema/generico/procedures/b1wgen0134.p PERSISTENT SET h-b1wgen0134.

       /* Cria lancamento craplem e atualiza o seu lote */
       RUN cria_lancamento_lem IN h-b1wgen0134
                               (INPUT par_cdcooper,
                                INPUT par_dtmvtolt,  
                                INPUT par_cdagenci,
                                INPUT 100,  /* cdbccxlt */    
                                INPUT par_cdoperad,
                                INPUT par_cdpactra,
                                INPUT 5,    /* tplotmov */
                                INPUT aux_nrdolote,    
                                INPUT crappep.nrdconta,
                                INPUT aux_cdhistor,
                                INPUT crappep.nrctremp,
                                INPUT par_vlparepr,
                                INPUT par_dtmvtolt,
                                INPUT crapepr.txjuremp,
                                INPUT crappep.vlparepr,
                                INPUT crappep.nrparepr, 
                                INPUT crappep.nrparepr,
                                INPUT TRUE,
                                INPUT TRUE,
                                INPUT par_nrseqava,
								INPUT par_idorigem). 

       DELETE PROCEDURE h-b1wgen0134.

       ASSIGN crappep.dtultpag = par_dtmvtolt
              crappep.vlpagpar = crappep.vlpagpar + par_vlparepr 
              crappep.vlsdvpar = crappep.vlsdvpar - par_vlparepr
              crappep.vlsdvsji = crappep.vlsdvsji - par_vlparepr
              crappep.inliquid = IF   crappep.vlsdvpar = 0   THEN
                                      1
                                 ELSE
                                      0.

       /* Se liquidou a parcela, limpa saldo atualizado e juros de 60 dias */
       IF   crappep.inliquid = 1   THEN
            ASSIGN crappep.vlsdvatu = 0
                   crappep.vljura60 = 0
                   crappep.vlsdvsji = 0.

       IF   aux_vljurmes > 0 THEN
            ASSIGN crapepr.diarefju = aux_diarefju
                   crapepr.mesrefju = aux_mesrefju
                   crapepr.anorefju = aux_anorefju.
                         
       /* Atualiza o emprestimo */
       ASSIGN crapepr.dtultpag = par_dtmvtolt
              crapepr.qtprepag = IF   crappep.inliquid = 1   THEN 
                                      crapepr.qtprepag + 1  
                                 ELSE 
                                      crapepr.qtprepag.

       IF    crappep.dtvencto > aux_dtcalcul   THEN
             ASSIGN crapepr.vlsdeved = crapepr.vlsdeved + aux_vljurmes.
       ELSE
             ASSIGN crapepr.vlsdeved = crapepr.vlsdeved - par_vlparepr + 
                                       aux_vljurmes.

       ASSIGN crapepr.vljuratu = crapepr.vljuratu + aux_vljurmes
              crapepr.vljuracu = crapepr.vljuracu + aux_vljurmes
              crapepr.qtprecal = IF    crappep.inliquid = 1   THEN 
                                       crapepr.qtprecal + 1
                                 ELSE 
                                       crapepr.qtprecal.

       ASSIGN aux_nrdolote = IF   aux_floperac   THEN /* Financiamento */
                                  600015
                             ELSE
                                  600014  
              par_nrdolote = aux_nrdolote.

       /* Condicao para verificar se o pagamento foi feito por um avalista */
       IF par_nrseqava = 0 OR par_nrseqava = ? THEN
          ASSIGN par_cdhistor = 108.
       ELSE
          ASSIGN par_cdhistor = 1539.

       RUN sistema/generico/procedures/b1wgen0136.p 
           PERSISTENT SET h-b1wgen0136.

       /* Verifica e efetua se necessario a liquidacao */
       RUN grava_liquidacao_empr IN h-b1wgen0136
                                 (INPUT par_cdcooper,
                                  INPUT par_dtmvtolt,
                                  INPUT par_cdagenci,
                                  INPUT 100,
                                  INPUT par_cdoperad,
                                  INPUT par_cdpactra,
                                  INPUT par_nrdcaixa,
                                  INPUT par_nrdconta,
                                  INPUT par_nrctremp,
                                  INPUT par_nmdatela,
                                  INPUT 0,
                                  INPUT par_idorigem,
                                 OUTPUT TABLE tt-erro). 

       DELETE PROCEDURE h-b1wgen0136.

       IF   RETURN-VALUE <> "OK"   THEN
            UNDO EFETIVA , LEAVE EFETIVA.

       ASSIGN aux_flgtrans = TRUE.

    END.

    IF   NOT aux_flgtrans    THEN
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
    
END PROCEDURE. /* efetiva pagamento normal parcela na tabela craplem.*/


PROCEDURE efetiva_pagamento_normal_parcela:

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
    DEF  INPUT PARAM par_nrparepr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlparepr AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqava AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdhistor          AS INT                            NO-UNDO.
    DEF VAR aux_nrdolote          AS INT                            NO-UNDO.
    DEF VAR aux_flgtrans          AS LOG                            NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    IF   par_flgerlog THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Efetiva pagamento normal de parcela".

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EFETIVA:
    DO ON ENDKEY UNDO , LEAVE ON ERROR UNDO , LEAVE:  

        RUN efetiva_pagamento_normal_parcela_craplem
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
                                        INPUT  par_nrctremp,
                                        INPUT  par_nrparepr,
                                        INPUT  par_vlparepr,
                                        INPUT  par_nrseqava,
                                        OUTPUT aux_cdhistor,
                                        OUTPUT aux_nrdolote,
                                        OUTPUT TABLE tt-erro).

    
        IF   RETURN-VALUE <> "OK"   THEN
             UNDO EFETIVA , LEAVE EFETIVA.
        
        /* Lanca em C/C e atualiza o lote */
        RUN cria_lancamento_cc (INPUT par_cdcooper,
                                INPUT par_dtmvtolt,
                                INPUT par_cdagenci,
                                INPUT 100, /* cdbccxlt */
                                INPUT par_cdoperad,
                                INPUT par_cdpactra,
                                INPUT aux_nrdolote,
                                INPUT par_nrdconta,
                                INPUT aux_cdhistor, /* cdhistor */
                                INPUT par_vlparepr,
                                INPUT par_nrparepr,
                                INPUT par_nrctremp,
                                INPUT par_nrseqava).

        IF   RETURN-VALUE <> "OK"   THEN
             UNDO EFETIVA , LEAVE EFETIVA.

        ASSIGN aux_flgtrans = TRUE.

    END.

    IF   NOT aux_flgtrans    THEN
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
    
END PROCEDURE. /* efetiva pagamento normal parcela */


PROCEDURE valida_pagamento_normal_parcela:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrparepr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlpagpar AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabpep FOR crappep.

    EMPTY TEMP-TABLE tt-erro.

    IF   par_flgerlog THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Valida pagamento normal de parcela".

    FIND crabpep WHERE crabpep.cdcooper = par_cdcooper   AND
                       crabpep.nrdconta = par_nrdconta   AND
                       crabpep.nrctremp = par_nrctremp   AND
                       crabpep.nrparepr = par_nrparepr   
                       NO-LOCK NO-ERROR.
    
    IF NOT AVAIL crabpep THEN
       DO:
           ASSIGN aux_cdcritic = 0
                  aux_dscritic = "Parcela nao encontrada.".
          
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1, 
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

           RETURN "NOK".
       END.

    IF   par_vlpagpar = 0   THEN
         DO:
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = "Valor de pagamento nao informado.".
             
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1, 
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).

              RETURN "NOK".
         END.

    IF   par_vlpagpar > crabpep.vlsdvpar   THEN
         DO:
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = "Valor informado para pagamento maior " +
                                    "que valor da parcela.".

              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1, 
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).

              RETURN "NOK".
         END. 

    IF   par_flgerlog   THEN
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
    
END PROCEDURE. /* valida pagamento normal parcela */


PROCEDURE efetiva_pagamento_atrasado_parcela_craplem:

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
    DEF  INPUT PARAM par_nrparepr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlpagpar AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqava AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_vlpagsld AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vlrmulta AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vlatraso AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_cdhismul AS INTE                           NO-UNDO. 
    DEF OUTPUT PARAM par_cdhisatr AS INTE                           NO-UNDO. 
    DEF OUTPUT PARAM par_cdhispag AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_loteatra AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_lotemult AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_lotepaga AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_vliofcpl AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_cdhisiof AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_loteiof  AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF          VAR aux_vlatupar AS DECI                           NO-UNDO.
    DEF          VAR aux_vlmtapar AS DECI                           NO-UNDO.
    DEF          VAR aux_vljinpar AS DECI                           NO-UNDO.
    DEF          VAR aux_vlmrapar AS DECI                           NO-UNDO.
	  DEF          VAR aux_vliofcpl AS DECI                           NO-UNDO.
    DEF          VAR aux_vlpagpar AS DECI                           NO-UNDO.
    DEF          VAR aux_txdiaria AS DECI                           NO-UNDO.
    DEF          VAR aux_vljurmes AS DECI                           NO-UNDO.
    DEF          VAR aux_floperac AS LOGI                           NO-UNDO.
    DEF          VAR aux_nrdolote AS INTE                           NO-UNDO.
    DEF          VAR aux_cdhistor AS INTE                           NO-UNDO.
    DEF          VAR aux_diarefju AS INTE                           NO-UNDO.
    DEF          VAR aux_mesrefju AS INTE                           NO-UNDO.
    DEF          VAR aux_anorefju AS INTE                           NO-UNDO.
    DEF          VAR aux_vlmuljur AS DECI                           NO-UNDO.
    DEF          VAR aux_flgtrans AS LOGI                           NO-UNDO.
    DEF          VAR aux_nrseqdig AS INTE                           NO-UNDO.
    

    DEF          VAR h-b1wgen0134 AS HANDLE                         NO-UNDO.
    DEF          VAR h-b1wgen0136 AS HANDLE                         NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    IF   par_flgerlog THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Efetiva pagamento atrasado de parcela craplem".    

    ASSIGN aux_cdcritic = 0 
           aux_dscritic = "".

    RUN valida_pagamento_atrasado_parcela (INPUT  par_cdcooper,
                                           INPUT  par_cdagenci,
                                           INPUT  par_nrdcaixa,
                                           INPUT  par_cdoperad,
                                           INPUT  par_nmdatela,
                                           INPUT  par_idorigem,
                                           INPUT  par_nrdconta,
                                           INPUT  par_idseqttl,
                                           INPUT  par_dtmvtolt,
                                           INPUT  par_flgerlog,
                                           INPUT  par_nrctremp,
                                           INPUT  par_nrparepr,
                                           INPUT  par_vlpagpar,
                                          OUTPUT TABLE tt-erro,
                                          OUTPUT par_vlpagsld,
                                          OUTPUT aux_vlatupar,
                                          OUTPUT aux_vlmtapar,
                                          OUTPUT aux_vljinpar,
                                          OUTPUT aux_vlmrapar,
										                      OUTPUT aux_vliofcpl).
    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".    

    EFETIVA:
    DO ON ENDKEY UNDO , LEAVE ON ERROR UNDO , LEAVE:  

       RUN busca_registro_parcela (INPUT par_cdcooper,
                                   INPUT par_nrdconta,
                                   INPUT par_nrctremp,
                                   INPUT par_nrparepr).
       
       IF   RETURN-VALUE <> "OK"   THEN
            UNDO EFETIVA , LEAVE EFETIVA.

       RUN busca_registro_emprestimo (INPUT par_cdcooper,
                                      INPUT par_nrdconta,
                                      INPUT par_nrctremp,
                                     OUTPUT aux_floperac).
       
       IF   RETURN-VALUE <> "OK"   THEN
            UNDO EFETIVA , LEAVE EFETIVA.   
                  
       ASSIGN aux_vlpagpar = par_vlpagsld
              aux_txdiaria = crapepr.txjuremp.               
                     
       RUN lanca_juro_contrato (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT par_nrdconta,
                                INPUT par_nrctremp,
                                INPUT par_dtmvtolt,
                                INPUT par_cdoperad, 
                                INPUT par_cdpactra,
                                INPUT FALSE,
                                INPUT ?,
                                INPUT FALSE,
                                INPUT crapepr.dtdpagto,
                                INPUT par_idorigem,
                               OUTPUT TABLE tt-erro,
                               OUTPUT aux_vljurmes,
                               OUTPUT aux_diarefju,
                               OUTPUT aux_mesrefju,
                               OUTPUT aux_anorefju).

       IF   RETURN-VALUE <> "OK"   THEN
            UNDO EFETIVA , LEAVE EFETIVA.

       /* Valor da multa */
       IF   aux_vlmtapar > 0  THEN
            DO:                    
                IF aux_floperac   THEN         /* Financiamento */
                   ASSIGN aux_nrdolote = 600019.
                ELSE
                   ASSIGN aux_nrdolote = 600018. /* Emprestimo */

                /* Condicao para verificar se o pagamento foi feito por aval */
                IF par_nrseqava = 0 OR par_nrseqava = ? THEN
                   DO:
                       ASSIGN aux_cdhistor = IF aux_floperac THEN
                                                1076
                                             ELSE 
                                                1047.
                   END.
                ELSE
                   DO:
                       ASSIGN aux_cdhistor = IF aux_floperac THEN
                                                1618
                                             ELSE
                                                1540.
                   END.

                RUN sistema/generico/procedures/b1wgen0134.p
                    PERSISTENT SET h-b1wgen0134.

                /* Cria o lancamento e atualizar o lote */
                RUN cria_lancamento_lem IN h-b1wgen0134
                                        (INPUT par_cdcooper,
                                         INPUT par_dtmvtolt,
                                         INPUT par_cdagenci,
                                         INPUT 100, /* cdbccxlt */
                                         INPUT par_cdoperad,
                                         INPUT par_cdpactra,
                                         INPUT 5,   /* tplotmov */
                                         INPUT aux_nrdolote,
                                         INPUT par_nrdconta,
                                         INPUT aux_cdhistor,
                                         INPUT par_nrctremp,
                                         INPUT aux_vlmtapar,
                                         INPUT par_dtmvtolt,
                                         INPUT crapepr.txjuremp,   
                                         INPUT crappep.vlparepr,    
                                         INPUT crappep.nrparepr,   
                                         INPUT crappep.nrparepr,
                                         INPUT TRUE,
                                         INPUT TRUE,
                                         INPUT par_nrseqava,
										 INPUT par_idorigem).	

                DELETE PROCEDURE h-b1wgen0134.

                IF aux_floperac THEN /* Financiamento */
                   ASSIGN aux_nrdolote = 600021.
                ELSE                 /* Emprestimo */
                   ASSIGN aux_nrdolote = 600020.
                          
                /* Condicao para verificar se o pagamento foi feito por aval */
                IF par_nrseqava = 0 OR par_nrseqava = ? THEN
                   DO:
                       ASSIGN aux_cdhistor = IF aux_floperac THEN
                                                1070 /* Financiamento */
                                             ELSE 
                                                1060.
                   END.
                ELSE
                   DO:
                       ASSIGN aux_cdhistor = IF aux_floperac THEN
                                                1542 /* Financiamento */
                                             ELSE
                                                1541.
                   END.

                ASSIGN par_vlrmulta = aux_vlmtapar
                       par_cdhismul = aux_cdhistor
                       par_lotemult = aux_nrdolote.
    
                /* Atualizar o valor pago da multa */
                ASSIGN crappep.vlpagmta = crappep.vlpagmta + aux_vlmtapar.                                                               
                                              
            END. /* IF   aux_vlmtapar > 0  THEN */
       
            /* Pagamento de juros de mora */
       IF   aux_vlmrapar > 0 AND aux_vlpagpar >= 0 THEN
            DO:
                IF   aux_floperac   THEN            /* Financiamento */
                     ASSIGN aux_nrdolote = 600023.
                ELSE
                     ASSIGN aux_nrdolote = 600022.   /* Emprestimo */

                /* Condicao para verificar se o pagamento foi feito por aval */
                IF par_nrseqava = 0 OR par_nrseqava = ? THEN
                   DO:
                       ASSIGN aux_cdhistor = IF aux_floperac THEN
                                                1078
                                             ELSE 
                                                1077.
                   END.
                ELSE
                   DO:
                       ASSIGN aux_cdhistor = IF aux_floperac THEN
                                                1620
                                             ELSE 
                                                1619.
                   END.

                RUN sistema/generico/procedures/b1wgen0134.p
                         PERSISTENT SET h-b1wgen0134.

                /* Cria o lancamento e atualiza o lote */
                RUN cria_lancamento_lem IN h-b1wgen0134
                                             (INPUT par_cdcooper,
                                              INPUT par_dtmvtolt,
                                              INPUT par_cdagenci,
                                              INPUT 100, /* cdbccxlt */
                                              INPUT par_cdoperad,
                                              INPUT par_cdpactra,
                                              INPUT 5,   /* tplotmov */
                                              INPUT aux_nrdolote,
                                              INPUT par_nrdconta,
                                              INPUT aux_cdhistor,
                                              INPUT par_nrctremp,
                                              INPUT aux_vlmrapar,
                                              INPUT par_dtmvtolt,
                                              INPUT crapepr.txjuremp,   
                                              INPUT crappep.vlparepr,    
                                              INPUT crappep.nrparepr,   
                                              INPUT crappep.nrparepr,
                                              INPUT TRUE,
                                              INPUT TRUE,
                                              INPUT par_nrseqava,
                                              INPUT par_idorigem). 											  

                DELETE PROCEDURE h-b1wgen0134.

                IF aux_floperac   THEN          /* Financiamento */
                   ASSIGN aux_nrdolote = 600025.
                ELSE                              /* Emprestimo */
                   ASSIGN aux_nrdolote = 600024.

                /* Condicao para verificar se o pagamento foi feito por aval */
                IF par_nrseqava = 0 OR par_nrseqava = ? THEN
                   DO:
                       ASSIGN aux_cdhistor = IF aux_floperac THEN
                                                1072 /* Financiamento */
                                             ELSE 
                                                1071.
                   END.
                ELSE
                   DO:
                       ASSIGN aux_cdhistor = IF aux_floperac THEN
                                                1544 /* Financiamento */
                                             ELSE
                                                1543.
                   END.

                ASSIGN par_vlatraso = aux_vlmrapar  
                       par_cdhisatr = aux_cdhistor
                       par_loteatra = aux_nrdolote.

                /* Valor de pagamento juros de Mora */       
                ASSIGN crappep.vlpagmra = crappep.vlpagmra + aux_vlmrapar.

            END. /* IF   aux_vlmrapar > 0  THEN */
       
       /* Juros normais */
       IF   aux_vljinpar > 0 AND aux_vlpagpar > 0 THEN
            DO:       
                IF   aux_floperac   THEN           /* Financiamento */
                     ASSIGN aux_nrdolote = 600027
                            aux_cdhistor = 1051.
                ELSE                               /* Emprestimo */
                     ASSIGN aux_nrdolote = 600026       
                            aux_cdhistor = 1050.

                RUN sistema/generico/procedures/b1wgen0134.p
                         PERSISTENT SET h-b1wgen0134.

                /* Cria o lancamento e atualiza o lote */
                RUN cria_lancamento_lem IN h-b1wgen0134
                                             (INPUT par_cdcooper,
                                              INPUT par_dtmvtolt,
                                              INPUT par_cdagenci, 
                                              INPUT 100, /* cdbccxlt */
                                              INPUT par_cdoperad,
                                              INPUT par_cdpactra,
                                              INPUT 5,   /* tplotmov */
                                              INPUT aux_nrdolote,
                                              INPUT par_nrdconta,
                                              INPUT aux_cdhistor,
                                              INPUT par_nrctremp,
                                              INPUT aux_vljinpar,
                                              INPUT par_dtmvtolt,
                                              INPUT crapepr.txjuremp,   
                                              INPUT crappep.vlparepr,    
                                              INPUT crappep.nrparepr,   
                                              INPUT crappep.nrparepr,
                                              INPUT TRUE,
                                              INPUT TRUE,
                                              INPUT 0,
											  INPUT par_idorigem). 

                DELETE PROCEDURE h-b1wgen0134.

                /* Atualizar valor pago dos juros normais */
                ASSIGN crappep.vlpagjin = crappep.vlpagjin + aux_vljinpar.

            END. /* IF   aux_vljinpar > 0  THEN */

      /* Valor do IOF Complementar */
       IF   aux_vliofcpl > 0  THEN
            DO:                    
                IF aux_floperac   THEN         /* Financiamento */
                   ASSIGN aux_nrdolote = 600019.
                ELSE
                   ASSIGN aux_nrdolote = 600018. /* Emprestimo */

                       ASSIGN aux_cdhistor = IF aux_floperac THEN
                                                2312
                                             ELSE
                                                2311.
              
                RUN sistema/generico/procedures/b1wgen0134.p
                    PERSISTENT SET h-b1wgen0134.

                /* Cria o lancamento e atualizar o lote */
                RUN cria_lancamento_lem_chave IN h-b1wgen0134
                                        (INPUT par_cdcooper,
                                         INPUT par_dtmvtolt,
                                         INPUT par_cdagenci,
                                         INPUT 100, /* cdbccxlt */
                                         INPUT par_cdoperad,
                                         INPUT par_cdpactra,
                                         INPUT 5,   /* tplotmov */
                                         INPUT aux_nrdolote,
                                         INPUT par_nrdconta,
                                         INPUT aux_cdhistor,
                                         INPUT par_nrctremp,
                                         INPUT aux_vliofcpl,
                                         INPUT par_dtmvtolt,
                                         INPUT crapepr.txjuremp,   
                                         INPUT crappep.vlparepr,    
                                         INPUT crappep.nrparepr,   
                                         INPUT crappep.nrparepr,
                                         INPUT TRUE,
                                         INPUT TRUE,
                                         INPUT par_nrseqava,
                                                 INPUT par_idorigem,
                                                 OUTPUT aux_nrseqdig).	

                DELETE PROCEDURE h-b1wgen0134.

                IF aux_floperac THEN /* Financiamento */
                   ASSIGN aux_nrdolote = 600021.
                ELSE                 /* Emprestimo */
                   ASSIGN aux_nrdolote = 600020.
                          
                ASSIGN aux_cdhistor = IF aux_floperac THEN
                                                2314 /* Financiamento */
                                             ELSE
                                                2313.
                
                ASSIGN par_vliofcpl = aux_vliofcpl
                       par_cdhisiof = aux_cdhistor
                       par_loteiof  = aux_nrdolote.
                                                 
				/* Atualizar valor pago do iof */
                ASSIGN crappep.vlpagiof = crappep.vlpagiof + aux_vliofcpl.
                                                 
                 /* Projeto 410 - Gera lancamento de IOF complementar na TBGEN_IOF_LANCAMENTO - Jean (Mout´S) */
                 { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                 RUN STORED-PROCEDURE pc_insere_iof
                 aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper     /* Código da cooperativa referente ao contrato de empréstimos */
                                                     ,INPUT par_nrdconta     /* Número da conta referente ao empréstimo */
                                                     ,INPUT par_dtmvtolt     /* data de movimento */
                                                     ,INPUT 1                /* tipo de produto - 1 - Emprestimo */
                                                     ,INPUT par_nrctremp     /* Número do contrato de empréstimo */
                                                     ,INPUT ?                /* lancamento automatico */
                                                     ,INPUT par_dtmvtolt     /* data de movimento LCM*/
                                                     ,INPUT par_cdpactra     /* par_cdagenci - codigo da agencia  */
                                                     ,INPUT 100              /* Codigo caixa*/
                                                     ,INPUT aux_nrdolote      /* numero do lote */
                                                     ,INPUT aux_nrseqdig     /* sequencia do lote */
                                                     ,INPUT 0                /* iof principal */
                                                     ,INPUT 0                /* iof adicional */
                                                     ,INPUT aux_vliofcpl     /* iof complementar */
                                                     ,INPUT 0                 /* flag IMUNE - fixo 0 pois se entrar aqui nao é imune */
                                                     ,OUTPUT 0               /* codigo da critica */
                                                     ,OUTPUT "").            /* Critica */
           
                 /* Fechar o procedimento para buscarmos o resultado */ 
                 CLOSE STORED-PROC pc_insere_iof

                 aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                 { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                 /* Se retornou erro */
                 ASSIGN aux_dscritic = ""
                        aux_dscritic = pc_insere_iof.pr_dscritic WHEN pc_insere_iof.pr_dscritic <> ?.
                        

                 IF aux_dscritic <> "" THEN
                     UNDO EFETIVA , LEAVE EFETIVA.
                                                 
            END. /* IF   aux_vliofcpl > 0  THEN */
            
       /* Lancamento de Valor Pago da Parcela */
       IF   aux_vlpagpar > 0 THEN 
            DO:
                IF aux_floperac   THEN           /* Financiamento */
                   ASSIGN aux_nrdolote = 600013.
                ELSE                               /* Emprestimo */
                   ASSIGN aux_nrdolote = 600012.

                /* Condicao para verificar se o pagamento foi feito por aval */
                IF par_nrseqava = 0 OR par_nrseqava = ? THEN
                   DO:
                       ASSIGN aux_cdhistor = IF aux_floperac THEN
                                                1039 /* Financiamento */
                                             ELSE 
                                                1044.
                   END.
                ELSE
                   DO:
                       ASSIGN aux_cdhistor = IF aux_floperac THEN
                                                1057 /* Financiamento */
                                             ELSE
                                                1045.
                   END.

                RUN sistema/generico/procedures/b1wgen0134.p
                         PERSISTENT SET h-b1wgen0134.

                /* Cria o lancamento e atualiza o lote */
                RUN cria_lancamento_lem IN h-b1wgen0134
                                             (INPUT par_cdcooper,
                                              INPUT par_dtmvtolt,
                                              INPUT par_cdagenci,
                                              INPUT 100, /* cdbccxlt */
                                              INPUT par_cdoperad,
                                              INPUT par_cdpactra,
                                              INPUT 5,   /* tplotmov */
                                              INPUT aux_nrdolote,
                                              INPUT par_nrdconta,
                                              INPUT aux_cdhistor,
                                              INPUT par_nrctremp,
                                              INPUT aux_vlpagpar,
                                              INPUT par_dtmvtolt,
                                              INPUT crapepr.txjuremp,   
                                              INPUT crappep.vlparepr,    
                                              INPUT crappep.nrparepr,   
                                              INPUT crappep.nrparepr,
                                              INPUT TRUE,
                                              INPUT TRUE,
                                              INPUT par_nrseqava,
											  INPUT par_idorigem).											  

                DELETE PROCEDURE h-b1wgen0134.
                
                IF aux_floperac   THEN           /* Financiamento */
                   ASSIGN aux_nrdolote = 600015.
                ELSE 
                   ASSIGN aux_nrdolote = 600014. /* Emprestimo */

                /* Condicao para verificar se o pagamento foi feito por aval */
                IF par_nrseqava = 0 OR par_nrseqava = ? THEN
                   DO:
                       ASSIGN aux_cdhistor = 108.
                   END.
                ELSE
                   DO:
                       ASSIGN aux_cdhistor = 1539.
                   END.

                ASSIGN par_cdhispag = aux_cdhistor
                       par_lotepaga = aux_nrdolote.
                     
                ASSIGN crappep.dtultpag = par_dtmvtolt
                       crappep.vlpagpar = crappep.vlpagpar + aux_vlpagpar /*+ aux_vliofcpl*/                   
                       crappep.vlsdvpar = ROUND (aux_vlatupar,2) - ROUND (aux_vlpagpar,2)                                                        
                       crappep.inliquid = 
                         IF  ROUND(aux_vlatupar,2) = ROUND (aux_vlpagpar,2) THEN
                             1
                         ELSE
                             0.

                ASSIGN aux_vlmuljur     = aux_vlmtapar + aux_vljinpar + 
                                          aux_vlmrapar + aux_vliofcpl

                       crappep.vlsdvsji = crappep.vlsdvsji - 
                         ( ROUND (par_vlpagpar,2) - ROUND(aux_vlmuljur,2) ).

                /* Se liquidou a parcela, limpa saldo atualizado e juros de 
                   60 dias */
                IF   crappep.inliquid = 1   THEN
                     ASSIGN crappep.vlsdvatu = 0
                            crappep.vljura60 = 0
                            crappep.vlsdvsji = 0.
            END. 

       IF   aux_vljurmes > 0   THEN
            ASSIGN crapepr.diarefju = aux_diarefju 
                   crapepr.mesrefju = aux_mesrefju
                   crapepr.anorefju = aux_anorefju.

       /* Atualiza o emprestimo */
       ASSIGN crapepr.dtultpag = par_dtmvtolt
              crapepr.qtprepag = IF   crappep.inliquid = 1   THEN 
                                      crapepr.qtprepag + 1  
                                 ELSE 
                                      crapepr.qtprepag
              crapepr.vlsdeved = crapepr.vlsdeved - aux_vlpagpar + aux_vljurmes
              crapepr.vljuratu = crapepr.vljuratu + aux_vljurmes
              crapepr.vljuracu = crapepr.vljuracu + aux_vljurmes
              crapepr.qtprecal = IF    crappep.inliquid = 1   THEN 
                                       crapepr.qtprecal + 1
                                 ELSE 
                                       crapepr.qtprecal.

       RUN sistema/generico/procedures/b1wgen0136.p PERSISTENT SET h-b1wgen0136.

       /* Verifica e efetua se necessario a liquidacao */
       RUN grava_liquidacao_empr IN h-b1wgen0136
                                 (INPUT par_cdcooper,
                                  INPUT par_dtmvtolt,
                                  INPUT par_cdagenci,
                                  INPUT 100,
                                  INPUT par_cdoperad,
                                  INPUT par_cdpactra,
                                  INPUT par_nrdcaixa,
                                  INPUT par_nrdconta,
                                  INPUT par_nrctremp,
                                  INPUT par_nmdatela,
                                  INPUT 0,
                                  INPUT par_idorigem,
                                 OUTPUT TABLE tt-erro). 

       DELETE PROCEDURE h-b1wgen0136.

       IF   RETURN-VALUE <> "OK"   THEN
            UNDO EFETIVA , LEAVE EFETIVA.

       ASSIGN aux_flgtrans = TRUE.

    END.

    IF   NOT aux_flgtrans   THEN
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
    
END PROCEDURE. /* efetiva pagamento atrasado parcela */


PROCEDURE efetiva_pagamento_atrasado_parcela:

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
    DEF  INPUT PARAM par_nrparepr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlpagpar AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqava AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF          VAR aux_vlrmulta AS DECI                           NO-UNDO.
    DEF          VAR aux_vlatraso AS DECI                           NO-UNDO.
    DEF          VAR aux_cdhismul AS DECI                           NO-UNDO.
    DEF          VAR aux_cdhisatr AS DECI                           NO-UNDO.
    DEF          VAR aux_cdhispag AS DECI                           NO-UNDO.
    DEF          VAR aux_loteatra AS DECI                           NO-UNDO.
    DEF          VAR aux_lotemult AS DECI                           NO-UNDO.
    DEF          VAR aux_lotepaga AS DECI                           NO-UNDO.
    DEF          VAR aux_flgtrans AS LOGI                           NO-UNDO.
    DEF          VAR aux_vlpagsld AS DECI                           NO-UNDO.
    DEF          VAR aux_vliofcpl AS DECI                           NO-UNDO.
    DEF          VAR aux_cdhisiof AS INTE                           NO-UNDO.
    DEF          VAR aux_loteiof AS INTE                           NO-UNDO.
    DEF          VAR aux_nrseqdig AS INTE                           NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    IF   par_flgerlog THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Efetiva pagamento atrasado de parcela".    

    ASSIGN aux_cdcritic = 0 
           aux_dscritic = "".

    EFETIVA:
    DO ON ENDKEY UNDO , LEAVE ON ERROR UNDO , LEAVE:  

       RUN efetiva_pagamento_atrasado_parcela_craplem (INPUT par_cdcooper,
                                                       INPUT par_cdagenci,
                                                       INPUT par_nrdcaixa,
                                                       INPUT par_cdoperad,
                                                       INPUT par_nmdatela,
                                                       INPUT par_idorigem,
                                                       INPUT par_cdpactra,
                                                       INPUT par_nrdconta,
                                                       INPUT par_idseqttl,
                                                       INPUT par_dtmvtolt,
                                                       INPUT par_flgerlog,
                                                       INPUT par_nrctremp,
                                                       INPUT par_nrparepr,
                                                       INPUT par_vlpagpar,
                                                       INPUT par_nrseqava,
                                                       OUTPUT aux_vlpagsld,
                                                       OUTPUT aux_vlrmulta,
                                                       OUTPUT aux_vlatraso,
                                                       OUTPUT aux_cdhismul,
                                                       OUTPUT aux_cdhisatr,
                                                       OUTPUT aux_cdhispag,
                                                       OUTPUT aux_loteatra,
                                                       OUTPUT aux_lotemult,
                                                       OUTPUT aux_lotepaga,
                                                       OUTPUT aux_vliofcpl,
                                                       OUTPUT aux_cdhisiof,
                                                       OUTPUT aux_loteiof,
                                                       OUTPUT TABLE tt-erro).

       IF   RETURN-VALUE <> "OK"   THEN
            UNDO EFETIVA , LEAVE EFETIVA.


       /* Valor da multa */
       IF   aux_vlrmulta > 0  THEN
            DO:
                 /* Debita o pagamento da parcela da C/C */                                      
                RUN cria_lancamento_cc (INPUT par_cdcooper,
                                        INPUT par_dtmvtolt,
                                        INPUT par_cdagenci,
                                        INPUT 100, /* cdbccxlt */
                                        INPUT par_cdoperad,
                                        INPUT par_cdpactra,
                                        INPUT aux_lotemult,
                                        INPUT par_nrdconta,
                                        INPUT aux_cdhismul,
                                        INPUT aux_vlrmulta,
                                        INPUT par_nrparepr,
                                        INPUT par_nrctremp,
                                        INPUT par_nrseqava).

            END. /* IF   aux_vlmtapar > 0  THEN */
       
       /* Pagamento de juros de mora */
       IF   aux_vlatraso > 0 AND aux_vlpagsld > 0 THEN
            DO:                           
                /* Debita o pagamento da parcela da C/C */                                      
                RUN cria_lancamento_cc (INPUT par_cdcooper,
                                        INPUT par_dtmvtolt,
                                        INPUT par_cdagenci,
                                        INPUT 100, /* cdbccxlt */
                                        INPUT par_cdoperad,
                                        INPUT par_cdpactra,
                                        INPUT aux_loteatra,
                                        INPUT par_nrdconta,
                                        INPUT aux_cdhisatr,
                                        INPUT aux_vlatraso,
                                        INPUT par_nrparepr,
                                        INPUT par_nrctremp,
                                        INPUT par_nrseqava).
                                              
            END. /* IF   aux_vlmrapar > 0  THEN */
            

       /* Projeto 410 - efetua o debito do IOF complementar de atraso */
       IF aux_vliofcpl > 0 AND aux_vlpagsld >= 0 THEN DO:
            /* Debita o pagamento da parcela da C/C */                                      
            RUN cria_lancamento_cc (INPUT par_cdcooper,
                                    INPUT par_dtmvtolt,
                                    INPUT par_cdagenci,
                                    INPUT 100, /* cdbccxlt */
                                    INPUT par_cdoperad,
                                    INPUT par_cdpactra,
                                    INPUT aux_loteiof,
                                    INPUT par_nrdconta,
                                    INPUT aux_cdhisiof,
                                    INPUT aux_vliofcpl,
                                    INPUT par_nrparepr,
                                    INPUT par_nrctremp,
                                    INPUT par_nrseqava).
        END.
            
       /* Lancamento de Valor Pago da Parcela */
       IF   aux_vlpagsld > 0 THEN 
            DO:
                /* Debita o pagamento da parcela da C/C */                                      
                RUN cria_lancamento_cc (INPUT par_cdcooper,
                                        INPUT par_dtmvtolt,
                                        INPUT par_cdagenci,
                                        INPUT 100, /* cdbccxlt */
                                        INPUT par_cdoperad,
                                        INPUT par_cdpactra,
                                        INPUT aux_lotepaga,
                                        INPUT par_nrdconta,
                                        INPUT aux_cdhispag,
                                        INPUT aux_vlpagsld,
                                        INPUT par_nrparepr,
                                        INPUT par_nrctremp,
                                        INPUT par_nrseqava).
            END. 
            

       ASSIGN aux_flgtrans = TRUE.
       
    END.

    IF   NOT aux_flgtrans   THEN
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
    
END PROCEDURE. /* efetiva pagamento atrasado parcela */


PROCEDURE valida_pagamento_atrasado_parcela:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrparepr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlpagpar AS DECI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM par_vlpagsld AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vlatupar AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vlmtapar AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vljinpar AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vlmrapar AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vliofcpl AS DECI                           NO-UNDO.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    DEF VAR aux_vlpagmin AS DECI                                    NO-UNDO.
    DEF VAR aux_valormin AS DECI                                    NO-UNDO.
    DEF VAR aux_vljinp59 AS DECI                                    NO-UNDO.
    DEF VAR aux_vljinp60 AS DECI                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    IF   par_flgerlog THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Valida pagamento atrasado de parcela".


    VALIDA_ATRASO:
    DO ON ERROR UNDO, LEAVE:

       IF   par_vlpagpar = 0   THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Valor de pagamento nao informado.".
                
                UNDO VALIDA_ATRASO , LEAVE VALIDA_ATRASO.
            END.

       RUN calcula_atraso_parcela (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_cdoperad,
                                   INPUT par_nmdatela,
                                   INPUT par_idorigem,
                                   INPUT par_nrdconta,
                                   INPUT par_idseqttl,
                                   INPUT par_dtmvtolt,
                                   INPUT par_flgerlog,
                                   INPUT par_nrctremp,
                                   INPUT par_nrparepr,
                                   INPUT par_vlpagpar,
                                  OUTPUT TABLE tt-erro,
                                  OUTPUT par_vlpagsld,
                                  OUTPUT par_vlatupar,
                                  OUTPUT par_vlmtapar,
                                  OUTPUT par_vljinpar,
                                  OUTPUT par_vlmrapar,
                                  OUTPUT par_vliofcpl,
                                  OUTPUT aux_vljinp59,
                                  OUTPUT aux_vljinp60).

       IF   RETURN-VALUE <> "OK"   THEN
            UNDO VALIDA_ATRASO , LEAVE VALIDA_ATRASO.

       FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                          craptab.nmsistem = "CRED"       AND
                          craptab.tptabela = "USUARI"     AND
                          craptab.cdempres = 11           AND
                          craptab.cdacesso = "PAREMPREST" AND
                          craptab.tpregist = 01
                          NO-LOCK NO-ERROR.

       IF   NOT AVAIL craptab   THEN
            DO:
                ASSIGN  aux_cdcritic = 55
                        aux_dscritic = "".

                UNDO VALIDA_ATRASO , LEAVE VALIDA_ATRASO.
            END.

       ASSIGN aux_vlpagmin = DEC(SUBSTRING(craptab.dstextab,22,12)).

       IF   par_idorigem = 1   THEN /* Pagamento via processo batch */
            DO:
                /* Se valor atual da parcela >= que o minimo a pagar */
                IF   par_vlatupar >= aux_vlpagmin   THEN
                     DO:
                         /* Multa + jr.mora + minimo a pagar */
                         ASSIGN aux_valormin = ROUND(par_vlmtapar,2) + 
                                               ROUND(par_vlmrapar,2) + 
                                               ROUND(par_vliofcpl,2) +
                                               ROUND(aux_vlpagmin,2).               
                     END. 
                ELSE     /* Valor atual é menor que o minimo */
                     DO:
                         /* Multa + jr.normais */
                         ASSIGN aux_valormin =  ROUND(par_vlmtapar,2) + 
                                                ROUND(par_vlmrapar,2) + 
                                                ROUND(par_vliofcpl,2) +
                                                ROUND(par_vlatupar,2).                    
                     END.                  
            END.
       ELSE     /* Pagamento via tela */ 
            DO:
                /* Multa + jr.mora + qualquer valor de pagamento */
                ASSIGN aux_valormin = ROUND(par_vlmtapar,2) + 
                                      ROUND(par_vlmrapar,2) + 
                                      ROUND(par_vliofcpl,2) + 0.01. 
            END.

       IF   ROUND(par_vlpagpar,2) < aux_valormin   THEN 
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic =
                  "Valor a pagar deve ser maior ou igual que R$ " + 
                   STRING(aux_valormin) + ".". 
            
                UNDO VALIDA_ATRASO , LEAVE VALIDA_ATRASO.
            END.

       IF ROUND(par_vlpagpar,2) > ROUND(par_vlatupar,2) + ROUND(par_vlmtapar,2) + 
                                  ROUND(par_vlmrapar,2) + ROUND(par_vliofcpl,2) THEN
          DO:             
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = "Valor informado para pagamento maior que valor da parcela".


              UNDO VALIDA_ATRASO , LEAVE VALIDA_ATRASO.
          END. 
                  
       ASSIGN aux_flgtrans = TRUE.

    END.           /* Fim Validacoes */

    IF   NOT aux_flgtrans   THEN
         DO:
             IF   NOT TEMP-TABLE tt-erro:HAS-RECORDS  THEN
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1, 
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    IF   par_flgerlog   THEN
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
    
END PROCEDURE. /* valida pagamento atrasado parcela */

PROCEDURE efetiva_pagamento_antecipado_craplem:
    
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
    DEF  INPUT PARAM par_nrparepr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlpagpar AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqava AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_cdhistor AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_nrdolote AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF          VAR aux_contador AS INTE                           NO-UNDO.
    DEF          VAR aux_vljurmes AS DECI                           NO-UNDO.
    DEF          VAR aux_vlatupar AS DECI                           NO-UNDO.
    DEF          VAR aux_vldespar AS DECI                           NO-UNDO.
    DEF          VAR aux_floperac AS LOGI                           NO-UNDO.
    DEF          VAR aux_flgtrans AS LOGI                           NO-UNDO.
    DEF          VAR aux_diarefju AS INTE                           NO-UNDO.
    DEF          VAR aux_mesrefju AS INTE                           NO-UNDO.
    DEF          VAR aux_anorefju AS INTE                           NO-UNDO.
    DEF          VAR pag_nrdolote AS INTE                           NO-UNDO.
    DEF          VAR pag_cdhistor AS INTE                           NO-UNDO.
    DEF          VAR des_nrdolote AS INTE                           NO-UNDO.
    DEF          VAR des_cdhistor AS INTE                           NO-UNDO.
    DEF          VAR lcm_nrdolote AS INTE                           NO-UNDO.

    DEF          VAR h-b1wgen0134 AS HANDLE                         NO-UNDO.
    DEF          VAR h-b1wgen0136 AS HANDLE                         NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    IF   par_flgerlog THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Efetiva pagamento antecipado de parcela craplem".

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    RUN valida_pagamento_antecipado_parcela (INPUT  par_cdcooper,
                                             INPUT  par_cdagenci,
                                             INPUT  par_nrdcaixa,
                                             INPUT  par_cdoperad,
                                             INPUT  par_nmdatela,
                                             INPUT  par_idorigem,
                                             INPUT  par_nrdconta,
                                             INPUT  par_idseqttl,
                                             INPUT  par_dtmvtolt,
                                             INPUT  par_flgerlog,
                                             INPUT  par_nrctremp,
                                             INPUT  par_nrparepr,
                                             INPUT  par_vlpagpar,
                                             OUTPUT TABLE tt-erro,
                                             OUTPUT aux_vlatupar,
                                             OUTPUT aux_vldespar).

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    EFETIVA:
    DO ON ENDKEY UNDO , LEAVE ON ERROR UNDO, LEAVE:

       RUN busca_registro_parcela (INPUT par_cdcooper,
                                   INPUT par_nrdconta,
                                   INPUT par_nrctremp,
                                   INPUT par_nrparepr).
       
       IF   RETURN-VALUE <> "OK"   THEN
            UNDO EFETIVA , LEAVE EFETIVA.

       RUN busca_registro_emprestimo (INPUT par_cdcooper,
                                      INPUT par_nrdconta,
                                      INPUT par_nrctremp,
                                     OUTPUT aux_floperac).
       
       IF   RETURN-VALUE <> "OK"   THEN
            UNDO EFETIVA , LEAVE EFETIVA.

       IF   aux_floperac    THEN           /* Financiamento */
            ASSIGN pag_nrdolote = 600013
                   des_nrdolote = 600017
                   des_cdhistor = 1049
                   lcm_nrdolote = 600015.
       ELSE                                /* Emprestimo */     
            ASSIGN pag_nrdolote = 600012
                   des_nrdolote = 600016
                   des_cdhistor = 1048
                   lcm_nrdolote = 600014.

       /* Condicao para verificar se o pagamento foi feito por um avalista */
       IF par_nrseqava = 0 OR par_nrseqava = ? THEN
          DO:
              ASSIGN pag_cdhistor = IF aux_floperac THEN
                                       1039  /* Financiamento */
                                    ELSE 
                                       1044. /* Emprestimo */
          END.
       ELSE
          DO:
              ASSIGN pag_cdhistor = IF aux_floperac THEN
                                       1057  /* Financiamento */
                                    ELSE 
                                       1045. /* Emprestimo */
          END.
                              
       RUN lanca_juro_contrato (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT par_nrdconta,
                                INPUT par_nrctremp,
                                INPUT par_dtmvtolt,
                                INPUT par_cdoperad,
                                INPUT par_cdpactra,
                                INPUT FALSE,
                                INPUT ?,
                                INPUT FALSE,
                                INPUT crapepr.dtdpagto,
                                INPUT par_idorigem,
                               OUTPUT TABLE tt-erro,
                               OUTPUT aux_vljurmes,
                               OUTPUT aux_diarefju,
                               OUTPUT aux_mesrefju,
                               OUTPUT aux_anorefju).

       IF   RETURN-VALUE <> "OK"   THEN
            UNDO EFETIVA , LEAVE EFETIVA.

       /* Se pagamento nao eh total */ 
       IF   par_vlpagpar <> aux_vlatupar   THEN 
            RUN calcula_antecipacao_parcela_parcial (INPUT crappep.cdcooper,
                                                     INPUT crappep.dtvencto,
                                                     INPUT crapepr.txmensal,
                                                     INPUT par_dtmvtolt,
                                                     INPUT par_vlpagpar,
                                                     INPUT crapepr.dtdpagto,
                                                    OUTPUT aux_vldespar). 

       RUN sistema/generico/procedures/b1wgen0134.p PERSISTENT SET h-b1wgen0134.

       /* Lancamento de Desconto da Parcela e atualiza o seu lote */      
       RUN cria_lancamento_lem IN h-b1wgen0134
                               (INPUT par_cdcooper,
                                INPUT par_dtmvtolt,  
                                INPUT par_cdagenci,
                                INPUT 100,  /* cdbccxlt */  
                                INPUT par_cdoperad,
                                INPUT par_cdpactra,
                                INPUT 5,    /* tplotmov*/
                                INPUT des_nrdolote,    
                                INPUT crappep.nrdconta,
                                INPUT des_cdhistor,
                                INPUT crappep.nrctremp,
                                INPUT aux_vldespar,
                                INPUT par_dtmvtolt,
                                INPUT crapepr.txjuremp,
                                INPUT crappep.vlparepr,
                                INPUT 0, /* nrsequni */
                                INPUT crappep.nrparepr,
                                INPUT TRUE,
                                INPUT TRUE,
                                INPUT 0,
								INPUT par_idorigem). 

       DELETE PROCEDURE h-b1wgen0134.

       RUN sistema/generico/procedures/b1wgen0134.p PERSISTENT SET h-b1wgen0134.

       /* Lancamento de Valor Pago da Parcela e atualiza o seu lote */
       RUN cria_lancamento_lem IN h-b1wgen0134
                              (INPUT par_cdcooper,
                               INPUT par_dtmvtolt,  
                               INPUT par_cdagenci,
                               INPUT 100,  /* cdbccxlt */ 
                               INPUT par_cdoperad,
                               INPUT par_cdpactra,
                               INPUT 5,    /* tplotmov */
                               INPUT pag_nrdolote,    
                               INPUT crappep.nrdconta,
                               INPUT pag_cdhistor,
                               INPUT crappep.nrctremp,
                               INPUT par_vlpagpar,
                               INPUT par_dtmvtolt,
                               INPUT crapepr.txjuremp,
                               INPUT crappep.vlparepr,
                               INPUT crappep.nrparepr,
                               INPUT crappep.nrparepr,
                               INPUT TRUE,
                               INPUT TRUE,
                               INPUT par_nrseqava,
							   INPUT par_idorigem).

       DELETE PROCEDURE h-b1wgen0134.

       ASSIGN crappep.vldespar = crappep.vldespar + aux_vldespar
              crappep.dtultpag = par_dtmvtolt
              crappep.vlpagpar = crappep.vlpagpar + par_vlpagpar
              crappep.vlsdvpar = crappep.vlsdvpar - (par_vlpagpar + aux_vldespar)
              crappep.vlsdvsji = crappep.vlsdvsji - (par_vlpagpar + aux_vldespar) 
              crappep.inliquid = IF  crappep.vlsdvpar = 0   THEN
                                     1
                                 ELSE
                                     0.
       
       /* Se liquidou a parcela, limpa saldo atualizado e juros de 60 dias */
       IF   crappep.inliquid = 1   THEN
            ASSIGN crappep.vlsdvatu = 0
                   crappep.vljura60 = 0
                   crappep.vlsdvsji = 0.
       
       IF   aux_vljurmes > 0   THEN
            ASSIGN crapepr.diarefju = aux_diarefju
                   crapepr.mesrefju = aux_mesrefju
                   crapepr.anorefju = aux_anorefju.

       /* Atualiza o emprestimo */
       ASSIGN crapepr.dtultpag = par_dtmvtolt
              crapepr.qtprepag = crapepr.qtprepag + crappep.inliquid 
              crapepr.qtprecal = crapepr.qtprecal + crappep.inliquid
              crapepr.vlsdeved = crapepr.vlsdeved + aux_vljurmes - par_vlpagpar
              crapepr.vljuratu = crapepr.vljuratu + aux_vljurmes
              crapepr.vljuracu = crapepr.vljuracu + aux_vljurmes.  

       /* Condicao para verificar se o pagamento foi feito por um avalista */
       IF par_nrseqava = 0 OR par_nrseqava = ? THEN
          DO:
              ASSIGN par_cdhistor = 108.
          END.
       ELSE
          DO:
              ASSIGN par_cdhistor = 1539.
          END.

       ASSIGN par_nrdolote = lcm_nrdolote.
       
       /* Deletar avisos de Debito */
       FOR EACH crapavs WHERE 
                crapavs.cdcooper = par_cdcooper   AND
                crapavs.nrdconta = par_nrdconta   AND
                crapavs.nrdocmto = par_nrctremp   AND
                crapavs.nrparepr = par_nrparepr   EXCLUSIVE-LOCK:
       
           DELETE crapavs.
       END.

       RUN sistema/generico/procedures/b1wgen0136.p PERSISTENT SET h-b1wgen0136.

       /* Verifica e efetua se necessario a liquidacao */
       RUN grava_liquidacao_empr IN h-b1wgen0136
                                 (INPUT par_cdcooper,
                                  INPUT par_dtmvtolt,
                                  INPUT par_cdagenci,
                                  INPUT 100,
                                  INPUT par_cdoperad,
                                  INPUT par_cdpactra,
                                  INPUT par_nrdcaixa,
                                  INPUT par_nrdconta,
                                  INPUT par_nrctremp,
                                  INPUT par_nmdatela,
                                  INPUT 0,
                                  INPUT par_idorigem,
                                 OUTPUT TABLE tt-erro). 

       DELETE PROCEDURE h-b1wgen0136.

       IF   RETURN-VALUE <> "OK"   THEN
            UNDO EFETIVA , LEAVE EFETIVA.

       ASSIGN aux_flgtrans = TRUE.
                            
    END.

    IF   NOT aux_flgtrans   THEN
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
END.


PROCEDURE efetiva_pagamento_antecipado_parcela:

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
    DEF  INPUT PARAM par_nrparepr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlpagpar AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqava AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF          VAR aux_flgtrans AS LOGI                           NO-UNDO.
    DEF          VAR aux_cdhistor AS INTE                           NO-UNDO.
    DEF          VAR aux_nrdolote AS INTE                           NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.

    IF   par_flgerlog THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Efetiva pagamento antecipado de parcela".

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EFETIVA:
    DO ON ENDKEY UNDO , LEAVE ON ERROR UNDO, LEAVE:

       RUN efetiva_pagamento_antecipado_craplem (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_cdoperad,
                                                 INPUT par_nmdatela,
                                                 INPUT par_idorigem,
                                                 INPUT par_cdpactra,
                                                 INPUT par_nrdconta,
                                                 INPUT par_idseqttl,
                                                 INPUT par_dtmvtolt,
                                                 INPUT par_flgerlog,
                                                 INPUT par_nrctremp,
                                                 INPUT par_nrparepr,
                                                 INPUT par_vlpagpar,
                                                 INPUT par_nrseqava,
                                                OUTPUT aux_cdhistor,
                                                OUTPUT aux_nrdolote,
                                                OUTPUT TABLE tt-erro).
                                              
       IF   RETURN-VALUE <> "OK"   THEN
            UNDO EFETIVA , LEAVE EFETIVA.       
       
       /* Debita o pagamento da parcela da C/C */                                      
       RUN cria_lancamento_cc (INPUT par_cdcooper,
                               INPUT par_dtmvtolt,
                               INPUT par_cdagenci,
                               INPUT 100, /* cdbccxlt */
                               INPUT par_cdoperad,
                               INPUT par_cdpactra,
                               INPUT aux_nrdolote,
                               INPUT par_nrdconta,
                               INPUT aux_cdhistor, /* Historico */
                               INPUT par_vlpagpar,
                               INPUT par_nrparepr,
                               INPUT par_nrctremp,
                               INPUT par_nrseqava).

       IF   RETURN-VALUE <> "OK"   THEN
            UNDO EFETIVA , LEAVE EFETIVA.

       ASSIGN aux_flgtrans = TRUE.
                            
    END.

    IF   NOT aux_flgtrans   THEN
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
    
END PROCEDURE. /* efetiva pagamento antecipado parcela */


PROCEDURE valida_pagamento_antecipado_parcela:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrparepr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlpagpar AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM par_vlatupar AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vldespar AS DECI                           NO-UNDO.

    DEF BUFFER crabpep FOR crappep.
    DEF BUFFER crabepr FOR crapepr.


    EMPTY TEMP-TABLE tt-erro.

    IF   par_flgerlog THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Valida pagamento antecipado de parcela".

    FIND crabpep WHERE crabpep.cdcooper = par_cdcooper   AND
                       crabpep.nrdconta = par_nrdconta   AND
                       crabpep.nrctremp = par_nrctremp   AND
                       crabpep.nrparepr = par_nrparepr   
                       NO-LOCK NO-ERROR.
    
    IF    NOT AVAIL crabpep   THEN
          DO:
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = "Parcela nao encontrada.".
             
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1, 
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).

              RETURN "NOK".
          END.

    IF   par_vlpagpar = 0   THEN
         DO:
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = "Valor de pagamento nao informado.".
             
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1, 
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).

              RETURN "NOK".
          END.

    FIND crabepr WHERE crabepr.cdcooper = crabpep.cdcooper   AND
                       crabepr.nrdconta = crabpep.nrdconta   AND
                       crabepr.nrctremp = crabpep.nrctremp   NO-LOCK NO-ERROR.

    RUN calcula_antecipacao_parcela (INPUT crabpep.cdcooper,
                                     INPUT crabpep.dtvencto,
                                     INPUT crabpep.vlsdvpar,
                                     INPUT crabepr.txmensal,
                                     INPUT par_dtmvtolt,
                                     INPUT crabepr.dtdpagto,
                                    OUTPUT par_vlatupar,
                                    OUTPUT par_vldespar).

    IF   RETURN-VALUE <> "OK"  THEN
         RETURN "NOK".

    IF   par_vlpagpar > par_vlatupar   THEN
         DO:
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = "Valor informado para pagamento maior que valor da parcela".

              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1, 
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).

              RETURN "NOK".
          END. 
       
    IF   par_flgerlog   THEN
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
    
END PROCEDURE. /* valida pagamento antecipado parcela */

PROCEDURE verifica_parcelas_anteriores:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrparepr AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                              NO-UNDO.

    DEF BUFFER crabpep FOR crappep.

    /* Verifica se tem uma parcela anterior nao liquida e ja vencida */
    FIND FIRST crabpep WHERE crabpep.cdcooper = par_cdcooper   AND
                             crabpep.nrdconta = par_nrdconta   AND
                             crabpep.nrctremp = par_nrctremp   AND
                             crabpep.nrparepr < par_nrparepr   AND
                             crabpep.inliquid = 0              AND
                             crabpep.dtvencto < par_dtmvtolt
                             NO-LOCK NO-ERROR.
              
    IF   AVAIL crabpep   THEN
         DO:
             ASSIGN par_dscritic = 
                 "Efetuar primeiro o pagamento da parcela em atraso".   

             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE verifica_parcelas_antecipacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrparepr AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                              NO-UNDO.

    DEF VAR aux_flgmenor AS LOGICAL INIT FALSE NO-UNDO.
    DEF VAR aux_flgmaior AS LOGICAL INIT FALSE NO-UNDO.
    DEF BUFFER crabpep FOR crappep.

    /* Verifica se tem uma parcela anterior nao liquida e ja vencida */
    FIND FIRST crabpep WHERE crabpep.cdcooper = par_cdcooper   AND
                             crabpep.nrdconta = par_nrdconta   AND
                             crabpep.nrctremp = par_nrctremp   AND
                             crabpep.nrparepr < par_nrparepr   AND
                             crabpep.inliquid = 0             AND
                             crabpep.dtvencto < par_dtmvtolt
                             NO-LOCK NO-ERROR.
                          
    IF   AVAIL crabpep   THEN
         DO:
           ASSIGN par_dscritic = 
                  "Efetuar primeiro o pagamento da parcela em atraso".   

           RETURN "NOK".             
         END.
                              
                
    FIND FIRST crabpep WHERE crabpep.cdcooper = par_cdcooper   AND
                             crabpep.nrdconta = par_nrdconta   AND
                             crabpep.nrctremp = par_nrctremp   AND
                             crabpep.nrparepr < par_nrparepr   AND
                             crabpep.inliquid = 0              
                             NO-LOCK NO-ERROR.
                                         
    aux_flgmenor = (AVAIL crabpep).
                 
                                                           
    FIND FIRST crabpep WHERE crabpep.cdcooper = par_cdcooper   AND
                             crabpep.nrdconta = par_nrdconta   AND
                             crabpep.nrctremp = par_nrctremp   AND
                             crabpep.nrparepr > par_nrparepr   AND
                             crabpep.inliquid = 0
                                                                                    NO-LOCK NO-ERROR.
       
    aux_flgmaior = (AVAIL crabpep).

    /* Parcela do meio nao pode */
    IF (aux_flgmenor AND aux_flgmaior) THEN
       DO:
                              
          ASSIGN par_dscritic = "Efetuar o pagamento das parcelas na 
                                 sequencia crescente ou decrescente.".            
          RETURN "NOK".             
                    
       END.
                    
     RETURN "OK".     
                                              
END PROCEDURE.


PROCEDURE busca_registro_parcela:

    DEF INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrparepr AS INTE                              NO-UNDO.

    DEF VAR aux_contador         AS INTE                              NO-UNDO.


    DO aux_contador = 1 TO 10:

       FIND crappep WHERE crappep.cdcooper = par_cdcooper   AND
                          crappep.nrdconta = par_nrdconta   AND
                          crappep.nrctremp = par_nrctremp   AND
                          crappep.nrparepr = par_nrparepr   
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAIL crappep   THEN
            IF   LOCKED crappep   THEN
                 DO:
                     ASSIGN aux_cdcritic = 77.
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
            ELSE 
                 DO:
                     ASSIGN aux_cdcritic = 55.
                     LEAVE.
                 END.

       ASSIGN aux_cdcritic = 0.
       LEAVE.

    END.
       
    IF   aux_cdcritic <> 0   THEN
         RETURN "NOK".

    /* SD545719 inicio */
	IF   crappep.inliquid = 1 /* liquidada */    THEN
	DO:
		 ASSIGN aux_cdcritic = 0
				aux_dscritic = "Parcela ja liquidada!!".
		 RETURN "NOK".
	END.
	/* SD545719 fim */

    RETURN "OK".

END PROCEDURE. /* busca registro parcela */


PROCEDURE busca_registro_emprestimo:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_floperac AS LOGI                           NO-UNDO.


    DEF VAR aux_contador         AS INTE                            NO-UNDO.


    DO aux_contador = 1 TO 10:

       FIND crapepr WHERE crapepr.cdcooper = par_cdcooper   AND
                          crapepr.nrdconta = par_nrdconta   AND
                          crapepr.nrctremp = par_nrctremp  
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
       IF   NOT AVAIL crapepr   THEN
            IF   LOCKED crapepr   THEN
                 DO:
                     ASSIGN aux_cdcritic = 77.
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
            ELSE 
                 DO:
                     ASSIGN aux_cdcritic = 55.
                     LEAVE.
                 END.
       
       ASSIGN aux_cdcritic = 0.
       LEAVE.

    END.

    IF   aux_cdcritic <> 0   THEN
         RETURN "NOK".

    FIND craplcr WHERE craplcr.cdcooper = par_cdcooper       AND
                       craplcr.cdlcremp = crapepr.cdlcremp   NO-LOCK NO-ERROR.

    IF   NOT AVAIL craplcr    THEN
         DO:
             aux_cdcritic = 363.
             RETURN "NOK".
         END.

    ASSIGN par_floperac = ( craplcr.dsoperac = "FINANCIAMENTO" ) .

    RETURN "OK".

END PROCEDURE. /* busca registro parcela */


PROCEDURE calcula_antecipacao_parcela_parcial:
    
    DEF  INPUT PARAM par_cdcooper AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_dtvencto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_txmensal AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.   
    DEF  INPUT PARAM par_vlpagpar AS DECI                           NO-UNDO.       
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM par_vldespar AS DECI                           NO-UNDO.
    
    DEF          VAR aux_ndiasant AS INTE                           NO-UNDO.
    DEF          VAR aux_vlpresen AS DECI                           NO-UNDO.
    DEF          VAR aux_diavenct AS INTE                           NO-UNDO.
    DEF          VAR aux_mesvenct AS INTE                           NO-UNDO.
    DEF          VAR aux_anovenct AS INTE                           NO-UNDO.

    
    ASSIGN aux_diavenct = DAY(par_dtvencto)
           aux_mesvenct = MONTH(par_dtvencto)
           aux_anovenct = YEAR(par_dtvencto).

    RUN sistema/generico/procedures/b1wgen0084.p PERSISTENT SET h-b1wgen0084.

    RUN Dias360 IN h-b1wgen0084 (INPUT FALSE,
                                 INPUT DAY(par_dtdpagto),
                                 INPUT DAY(par_dtmvtolt),
                                 INPUT MONTH(par_dtmvtolt),
                                 INPUT YEAR(par_dtmvtolt),
                                 INPUT-OUTPUT aux_diavenct,
                                 INPUT-OUTPUT aux_mesvenct,
                                 INPUT-OUTPUT aux_anovenct,
                                 OUTPUT aux_ndiasant).

    DELETE PROCEDURE h-b1wgen0084.
      
    ASSIGN aux_vlpresen = par_vlpagpar * EXP((1 + par_txmensal / 100),(aux_ndiasant / 30)).
           par_vldespar = aux_vlpresen - par_vlpagpar.
                      
END PROCEDURE. /* calcula antecipacao parcela parcial */


PROCEDURE calcula_juros_normais:

    DEF  INPUT PARAM par_vlpagpar AS DECI                               NO-UNDO.
    DEF  INPUT PARAM par_txmensal AS DECI                               NO-UNDO.
    DEF  INPUT PARAM par_qtdiajur AS INTE                               NO-UNDO.
    DEF OUTPUT PARAM par_vljinpar AS DECI                               NO-UNDO.


    ASSIGN par_vljinpar = par_vlpagpar *  EXP((1 + par_txmensal / 100), 
                                             ( - par_qtdiajur / 30) )
                        
          par_vljinpar =  par_vlpagpar - par_vljinpar.  


END PROCEDURE. /* calcula juros normais*/ 



PROCEDURE calcula_juros_normais_total:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/

    DEF  INPUT PARAM par_vlpagpar AS DECI                               NO-UNDO.
    DEF  INPUT PARAM par_txmensal AS DECI                               NO-UNDO.
    DEF  INPUT PARAM par_qtdiajur AS INTE                               NO-UNDO.
    DEF OUTPUT PARAM par_vljinpar AS DECI                               NO-UNDO.


    ASSIGN par_vljinpar = par_vlpagpar *  EXP((1 + par_txmensal / 100), 
                                             ( par_qtdiajur / 30) )
                        
           par_vljinpar = par_vljinpar -  par_vlpagpar.  


END PROCEDURE. /* calcula juros normais total */ 


PROCEDURE cria_lancamento_cc:

    DEF INPUT PARAM par_cdcooper AS INTE                                NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                                NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                                NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTE                                NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                                NO-UNDO.
    DEF INPUT PARAM par_cdpactra AS INTE                                NO-UNDO.
    DEF INPUT PARAM par_nrdolote AS INTE                                NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                                NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                                NO-UNDO.
    DEF INPUT PARAM par_vllanmto AS DECI                                NO-UNDO.
    DEF INPUT PARAM par_nrparepr AS INTE                                NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE                                NO-UNDO.
    DEF INPUT PARAM par_nrseqava AS INTE                                NO-UNDO.

    DEF VAR aux_nrseqdig         AS INTE                                NO-UNDO.

    RUN cria_lancamento_cc_chave(INPUT par_cdcooper
                                ,INPUT par_dtmvtolt
                                ,INPUT par_cdagenci
                                ,INPUT par_cdbccxlt
                                ,INPUT par_cdoperad
                                ,INPUT par_cdpactra
                                ,INPUT par_nrdolote
                                ,INPUT par_nrdconta
                                ,INPUT par_cdhistor
                                ,INPUT par_vllanmto
                                ,INPUT par_nrparepr
                                ,INPUT par_nrctremp
                                ,INPUT par_nrseqava
                                ,OUTPUT aux_nrseqdig).

    RETURN "OK".

END PROCEDURE. /* cria lancamento cc */ 


PROCEDURE cria_lancamento_cc_chave:

    DEF INPUT PARAM par_cdcooper AS INTE                                NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                                NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                                NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTE                                NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                                NO-UNDO.
    DEF INPUT PARAM par_cdpactra AS INTE                                NO-UNDO.
    DEF INPUT PARAM par_nrdolote AS INTE                                NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                                NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                                NO-UNDO.
    DEF INPUT PARAM par_vllanmto AS DECI                                NO-UNDO.
    DEF INPUT PARAM par_nrparepr AS INTE                                NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE                                NO-UNDO.
    DEF INPUT PARAM par_nrseqava AS INTE                                NO-UNDO.
    DEF OUTPUT PARAM par_nrseqdig AS INTE                                NO-UNDO.

    DEF VAR h-b1craplot          AS HANDLE                              NO-UNDO.
    
    /* Variaveis para rotina de lancamento craplcm */
    DEF VAR h-b1wgen0200        AS HANDLE  NO-UNDO.
    DEF VAR aux_incrineg        AS INT     NO-UNDO.
    DEF VAR aux_cdcritic        AS INT     NO-UNDO.
    DEF VAR aux_dscritic        AS CHAR    NO-UNDO.

    /* 12/06/20108 - Incluida condicao que verifica se pode realizar o debito */
    IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
        RUN sistema/generico/procedures/b1wgen0200.p 
        PERSISTENT SET h-b1wgen0200.

    IF  DYNAMIC-FUNCTION("PodeDebitar"  IN h-b1wgen0200, 
                         INPUT par_cdcooper, 
                         INPUT par_nrdconta,
                         INPUT par_cdhistor) THEN
        DO:

            IF ROUND(par_vllanmto,2) > 0 THEN
               DO:
                   /* Atualizar o lote da C/C */
                   RUN sistema/generico/procedures/b1craplot.p PERSISTENT SET h-b1craplot.
                
                   RUN inclui-altera-lote IN h-b1craplot
                                             (INPUT par_cdcooper,
                                              INPUT par_dtmvtolt,
                                              INPUT par_cdpactra,
                                              INPUT par_cdbccxlt,
                                              INPUT par_nrdolote,
                                              INPUT 1,   /* tplotmov */
                                              INPUT par_cdoperad,
                                              INPUT par_cdhistor,
                                              INPUT par_dtmvtolt,
                                              INPUT par_vllanmto,
                                              INPUT TRUE,
                                              INPUT TRUE,
                                             OUTPUT par_nrseqdig,
                                             OUTPUT aux_cdcritic).
                
                   DELETE PROCEDURE h-b1craplot.

                   /* 12/06/2018 - BLOCO DA INSERÇAO DA CRAPLCM */
                   RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
                     (INPUT par_dtmvtolt                         /* par_dtmvtolt */
                     ,INPUT par_cdpactra                         /* par_cdagenci */
                     ,INPUT par_cdbccxlt                         /* par_cdbccxlt */
                     ,INPUT par_nrdolote                         /* par_nrdolote */
                     ,INPUT par_nrdconta                         /* par_nrdconta */
                     ,INPUT par_nrseqdig                         /* par_nrdocmto */
                     ,INPUT par_cdhistor                         /* par_cdhistor */
                     ,INPUT par_nrseqdig                         /* par_nrseqdig */
                     ,INPUT par_vllanmto                         /* par_vllanmto */
                     ,INPUT par_nrdconta                         /* par_nrdctabb */
                     ,INPUT STRING(par_nrctremp,"zz,zzz,zz9")    /* par_cdpesqbb */
                     ,INPUT 0                                    /* par_vldoipmf */
                     ,INPUT 0                                    /* par_nrautdoc */
                     ,INPUT 0                                    /* par_nrsequni */
                     ,INPUT 0                                    /* par_cdbanchq */
                     ,INPUT 0                                    /* par_cdcmpchq */
                     ,INPUT 0                                    /* par_cdagechq */
                     ,INPUT 0                                    /* par_nrctachq */
                     ,INPUT 0                                    /* par_nrlotchq */
                     ,INPUT 0                                    /* par_sqlotchq */
                     ,INPUT ""                                   /* par_dtrefere */
                     ,INPUT TIME                                 /* par_hrtransa */
                     ,INPUT par_cdoperad                         /* par_cdoperad */
                     ,INPUT 0                                    /* par_dsidenti */
                     ,INPUT par_cdcooper                         /* par_cdcooper */
                     ,INPUT STRING(par_nrdconta,"99999999")      /* par_nrdctitg */
                     ,INPUT ""                                   /* par_dscedent */
                     ,INPUT 0                                    /* par_cdcoptfn */
                     ,INPUT 0                                    /* par_cdagetfn */
                     ,INPUT 0                                    /* par_nrterfin */
                     ,INPUT par_nrparepr                         /* par_nrparepr */
                     ,INPUT par_nrseqava                         /* par_nrseqava */
                     ,INPUT 0                                    /* par_nraplica */
                     ,INPUT 0                                    /* par_cdorigem */
                     ,INPUT 0                                    /* par_idlautom */
                     /* CAMPOS OPCIONAIS DO LOTE                                                                  */ 
                     ,INPUT 0                                    /* Processa lote                                 */
                     ,INPUT 0                                    /* Tipo de lote a movimentar                     */
                     /* CAMPOS DE SAIDA                                                                           */                                            
                     ,OUTPUT TABLE tt-ret-lancto                 /* Collection que contém o retorno do lançamento */
                     ,OUTPUT aux_incrineg                        /* Indicador de crítica de negócio               */
                     ,OUTPUT aux_cdcritic                        /* Código da crítica                             */
                     ,OUTPUT aux_dscritic).                      /* Descriçao da crítica                          */

                   IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO:
                      RUN gera_erro (INPUT par_cdcooper,        
                                     INPUT par_cdpactra,
                                     INPUT 1, /* nrdcaixa  */
                                     INPUT 1, /* sequencia */
                                     INPUT aux_cdcritic,        
                                     INPUT-OUTPUT aux_dscritic).
                                     UNDO, RETURN "NOK". 
                   END.
                   ELSE 
                      DO:
                        FIND FIRST tt-ret-lancto.
                        FIND FIRST craplcm WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm NO-ERROR.
                      END.
               END.

            /* 12/06/2018 - TJ - Apagar handle associado */
            IF VALID-HANDLE(h-b1wgen0200) THEN
               DELETE PROCEDURE h-b1wgen0200.
               
            RETURN "OK".
        END.  /* fim pode debitar */
    ELSE 
        DO:
            /* 12/06/2018 - Apagar handle associado (SE NAO PODE DEBITAR) */
            IF VALID-HANDLE(h-b1wgen0200) THEN
               DELETE PROCEDURE h-b1wgen0200.

            RETURN "NOK".
        END.
END PROCEDURE. /* cria lancamento cc */ 


PROCEDURE lanca_juro_contrato:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdpactra AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flnormal AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtvencto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_ehmensal AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM par_vljurmes AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_diarefju AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_mesrefju AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_anorefju AS INTE                           NO-UNDO.


    DEF VAR aux_diavtolt          AS INTE                           NO-UNDO.
    DEF VAR aux_mesvtolt          AS INTE                           NO-UNDO.
    DEF VAR aux_anovtolt          AS INTE                           NO-UNDO.

    DEF VAR aux_qtdiajur          AS DECI                           NO-UNDO.
    DEF VAR aux_potencia          AS DECI DECIMALS 10               NO-UNDO.
    DEF VAR aux_valor             AS DECI                           NO-UNDO.
    DEF VAR aux_floperac          AS LOGI                           NO-UNDO.
    DEF VAR aux_nrdolote          AS INTE                           NO-UNDO.
    DEF VAR aux_cdhistor          AS INTE                           NO-UNDO.
    DEF VAR aux_dtrefjur          AS DATE                           NO-UNDO.

    DEF VAR h-b1wgen0134          AS HANDLE                         NO-UNDO.

    DEF BUFFER crabepr FOR crapepr.

    EMPTY TEMP-TABLE tt-erro.

    Calcula:
    DO ON ENDKEY UNDO, LEAVE ON ERROR UNDO, LEAVE:

       FIND crabepr WHERE crabepr.cdcooper = par_cdcooper   AND
                          crabepr.nrdconta = par_nrdconta   AND
                          crabepr.nrctremp = par_nrctremp
                          NO-LOCK NO-ERROR.

       IF   NOT AVAIL crabepr   THEN
            DO:
                ASSIGN aux_cdcritic = 55.
                LEAVE Calcula.
            END.

       FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                          crawepr.nrdconta = par_nrdconta   AND
                          crawepr.nrctremp = par_nrctremp
                          NO-LOCK NO-ERROR.

       IF   NOT AVAIL crawepr   THEN
            DO:
                ASSIGN aux_cdcritic = 510.
                LEAVE Calcula.
            END.
          
       FIND craplcr WHERE craplcr.cdcooper = par_cdcooper   AND
                          craplcr.cdlcremp = crabepr.cdlcremp 
                          NO-LOCK NO-ERROR.

       IF   NOT AVAIL craplcr   THEN
            DO:
                ASSIGN aux_cdcritic = 55.
                LEAVE Calcula.
            END.

       ASSIGN aux_floperac = (craplcr.dsoperac = "FINANCIAMENTO"). 
          
       IF   aux_floperac   THEN          /* Financiamento */
            ASSIGN aux_nrdolote = 600011
                   aux_cdhistor = 1038.
       ELSE                              /* Emprestimo */ 
            ASSIGN aux_nrdolote = 600010              
                   aux_cdhistor = 1037.

       IF   crabepr.diarefju <> 0   AND 
            crabepr.mesrefju <> 0   AND 
            crabepr.anorefju <> 0   THEN
            ASSIGN aux_diavtolt = crabepr.diarefju
                   aux_mesvtolt = crabepr.mesrefju
                   aux_anovtolt = crabepr.anorefju.
       ELSE 
            ASSIGN aux_diavtolt = DAY(crawepr.dtlibera) 
                   aux_mesvtolt = MONTH(crawepr.dtlibera)
                   aux_anovtolt = YEAR(crawepr.dtlibera).

       IF  par_flnormal   THEN
           ASSIGN aux_dtrefjur = par_dtvencto.
       ELSE  
           ASSIGN aux_dtrefjur = par_dtmvtolt.
                                              
       /* Se ainda nao foi liberado o emprestimo , volta */
              /* Modificar operador para ">" solicitado pelo Irlan */
       IF   crawepr.dtlibera > par_dtmvtolt   THEN
            LEAVE Calcula.

       ASSIGN par_diarefju = DAY(aux_dtrefjur) 
              par_mesrefju = MONTH(aux_dtrefjur)
              par_anorefju = YEAR(aux_dtrefjur).

       RUN sistema/generico/procedures/b1wgen0084.p PERSISTENT SET h-b1wgen0084.
       
       RUN Dias360 IN h-b1wgen0084 (INPUT par_ehmensal,
                                    INPUT DAY(par_dtdpagto),
                                    INPUT aux_diavtolt,
                                    INPUT aux_mesvtolt,
                                    INPUT aux_anovtolt,
                              INPUT-OUTPUT par_diarefju,
                              INPUT-OUTPUT par_mesrefju,
                              INPUT-OUTPUT par_anorefju,
                                    OUTPUT aux_qtdiajur).

       /* Atualizar com a ultima data que rodou juros */
       DELETE PROCEDURE h-b1wgen0084.       
       
       ASSIGN aux_valor    = 1 + (crabepr.txjuremp / 100)
              aux_potencia = EXP (aux_valor , aux_qtdiajur)
              par_vljurmes = crabepr.vlsdeved  * (aux_potencia - 1).
       
       IF   par_vljurmes <= 0   THEN
            DO:
                par_vljurmes = 0.
                LEAVE Calcula.
            END.

       RUN sistema/generico/procedures/b1wgen0134.p PERSISTENT SET h-b1wgen0134.

       /* Cria lancamento e atualiza o lote  */
       RUN cria_lancamento_lem IN h-b1wgen0134
                               (INPUT par_cdcooper,
                                INPUT par_dtmvtolt,  
                                INPUT par_cdagenci,
                                INPUT 100,  /* cdbccxlt */ 
                                INPUT par_cdoperad,
                                INPUT par_cdpactra,
                                INPUT 5,    /* tplotmov */
                                INPUT aux_nrdolote,    
                                INPUT par_nrdconta,
                                INPUT aux_cdhistor,
                                INPUT par_nrctremp,
                                INPUT par_vljurmes,
                                INPUT par_dtmvtolt,
                                INPUT crabepr.txjuremp,
                                INPUT crabepr.vlpreemp,
                                INPUT 0, 
                                INPUT 0,
                                INPUT TRUE,
                                INPUT TRUE,
                                INPUT 0,
								INPUT par_idorigem).

       DELETE PROCEDURE h-b1wgen0134.

    END.
    
    IF   aux_cdcritic <> 0   THEN
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

END PROCEDURE. /* lanca juro contrato */

PROCEDURE busca_avalista_pagamento_parcela:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-dados-aval.

    DEF VAR aux_nmdaval1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrcpfcg1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_inpesso1 AS INTE                                    NO-UNDO.
    DEF VAR aux_nmdaval2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrcpfcg2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_inpesso2 AS INTE                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-dados-aval.
    
    FOR crapepr FIELDS(cdcooper nrdconta nrctremp nrctaav1 nrctaav2) 
                WHERE crapepr.cdcooper = par_cdcooper AND
                      crapepr.nrdconta = par_nrdconta AND
                      crapepr.nrctremp = par_nrctremp
                      NO-LOCK: END.
        
    IF NOT AVAIL crapepr THEN
       DO:
           ASSIGN aux_cdcritic = 356
                  aux_dscritic = "".
    
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
           RETURN "NOK".
       END.
          
    FOR EACH crapavt FIELDS(nrcpfcgc nmdavali inpessoa)
                     WHERE crapavt.cdcooper = crapepr.cdcooper AND
                           crapavt.nrdconta = crapepr.nrdconta AND
                           crapavt.nrctremp = crapepr.nrctremp AND
                           crapavt.tpctrato = 1                
                           NO-LOCK:
    
        IF crapepr.nrctaav1 = 0 AND aux_nmdaval1 = "" THEN
           DO:
               ASSIGN aux_nrcpfcg1 = STRING(crapavt.nrcpfcgc)
                      aux_nmdaval1 = crapavt.nmdavali
                      aux_inpesso1 = crapavt.inpessoa.
           END.
        ELSE
        IF crapepr.nrctaav2 = 0 AND aux_nmdaval2 = ""  THEN
           DO:
               ASSIGN aux_nrcpfcg2 = STRING(crapavt.nrcpfcgc)
                      aux_nmdaval2 = crapavt.nmdavali
                      aux_inpesso2 = crapavt.inpessoa.
           END.
    
    END. /* END FOR EACH crapavt */
    
    /** Busca o nome do primeiro availista **/
    IF crapepr.nrctaav1 <> 0  THEN
       DO:
           FOR crapass FIELDS(nrcpfcgc inpessoa nmprimtl) 
                       WHERE crapass.cdcooper = crapepr.cdcooper AND
                             crapass.nrdconta = crapepr.nrctaav1
                             NO-LOCK: END.
    
           IF AVAIL crapass THEN
              ASSIGN aux_nrcpfcg1 = STRING(crapass.nrcpfcgc)
                     aux_nmdaval1 = crapass.nmprimtl
                     aux_inpesso1 = crapass.inpessoa.
       END.
    
    IF aux_nrcpfcg1 <> "" THEN
       DO:
           CREATE tt-dados-aval.
           ASSIGN tt-dados-aval.nrseqavl = 1
                  tt-dados-aval.inpessoa = aux_inpesso1
                  tt-dados-aval.nrcpfcgc = aux_nrcpfcg1
                  tt-dados-aval.nmdavali = aux_nmdaval1.
       END.

    /** Busca o nome do segundo availista **/
    IF crapepr.nrctaav2 <> 0  THEN
       DO:
           FOR crapass FIELDS(nrcpfcgc inpessoa nmprimtl)  
                       WHERE crapass.cdcooper = par_cdcooper     AND
                             crapass.nrdconta = crapepr.nrctaav2
                             NO-LOCK: END.
    
           IF AVAIL crapass THEN
              ASSIGN aux_nrcpfcg2 = STRING(crapass.nrcpfcgc)
                     aux_nmdaval2 = crapass.nmprimtl
                     aux_inpesso2 = crapass.inpessoa.
       END.
    
    IF aux_nrcpfcg2 <> "" THEN
       DO:
           CREATE tt-dados-aval.
           ASSIGN tt-dados-aval.nrseqavl = 2
                  tt-dados-aval.inpessoa = aux_inpesso2
                  tt-dados-aval.nrcpfcgc = aux_nrcpfcg2
                  tt-dados-aval.nmdavali = aux_nmdaval2.
       END.

    RETURN "OK".
    
END PROCEDURE. /* busca_avalista_pagamento_parcela */
/* ......................................................................... */
