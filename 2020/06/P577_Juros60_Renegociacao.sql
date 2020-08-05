/*****************************************************************
05/08/2020 - P577 - INC0049010 - Contas Juros60 Negativo. 
             Corrigir Valores de Juros Negativos na Renegociação.
             (E seus pagamentos).
             Somente para Contratos PP.
*****************************************************************/

/*
Analisado em 19/06/2020
Importante: Não existem casos de PP com os 
valores de vljura60 e vljuremu estejam diferentes na tbepr_renegociao_saldo. 
No PP estes valores são sempre iguais.
No H3 exitem valores diferentes, porém se trata de uma alteração do Darlei
que segundo Télvio não funcionou, então desta forma não será considerado neste
script de correção.
A Alteração do Darlei se refere a lançamento de Juros na Mensal quando a
Renegociação é feita no ultimo dia do mês.
*/
DECLARE   
  --                                                  
  --Busca Registros com Valores Negativos (Renegociações Efetivadas de Contratos PP)
  CURSOR cr_reneg_saldo_jurneg IS
    SELECT trs.cdcooper    cdcooper
          ,trs.nrdconta    nrdconta
          ,trs.nrctremp    nrctremp                
          ,trs.vljura60    vljura60
          ,trs.vljuremu    vljuremu  
          ,trs.vltariof    vltariof
          ,trs.vlmultap    vlmultap
          ,trs.vljurmor    vljurmor   
          -- (New)
          ,trs.vlpgjr60    vlpgjr60 
          ,trs.vlpgjrem    vlpgjrem  
          --                              
    FROM   tbepr_renegociacao_saldo  trs --(Se está nesta tabela, já é Renegociação Efetivada)   
    WHERE  EXISTS (SELECT 1 
                   FROM   crapepr  epr
                   WHERE  epr.cdcooper = trs.cdcooper
                   AND    epr.nrdconta = trs.nrdconta
                   AND    epr.nrctremp = trs.nrctremp 
                   AND    epr.tpemprst = 1  --PP  
                   AND    epr.inliquid = 0) --Atendendo a solicitação da contabilidade (Somente Contratos não Liquidados) 
    ---
    --AND trs.cdcooper = 10   --????? Somente para Testes (Caso passado pela Helo que não considera os pagamentos)
    --AND trs.nrdconta = 1201 --????? Somente para Testes (Caso passado pela Helo que não considera os pagamentos)
    --AND trs.nrctremp = 2762 --????? Somente para Testes (Caso passado pela Helo que não considera os pagamentos)
    ---                              
    ORDER BY trs.cdcooper
            ,trs.nrdconta
            ,trs.nrctremp;            
  --
  --
  CURSOR cr_crappep_maior_carga(pr_cdcooper crappep.cdcooper%TYPE
                                 ,pr_nrdconta crappep.nrdconta%TYPE
                                 ,pr_nrctremp crappep.nrctremp%TYPE
                                 ,pr_dtmvtolt crapdat.dtmvtolt%TYPE
                                 ) IS 
      SELECT MIN(pep.dtvencto) dtvencto
        FROM tbepr_renegociacao_crappep pep
       WHERE pep.cdcooper = pr_cdcooper
         AND (pep.inliquid = 0 OR pep.inprejuz = 1)
         AND pep.dtvencto <= pr_dtmvtolt
         AND pep.cdcooper  = pr_cdcooper
         AND pep.nrdconta  = pr_nrdconta
         AND pep.nrctremp  = pr_nrctremp
         AND pep.nrversao  = 1; --Primeira Renegociação (As demais renegociações já são em cima de novo contrato)
    rw_crappep_maior_carga  cr_crappep_maior_carga%ROWTYPE;   
  --
  --            
  --
  CURSOR cr_crappep(pr_cdcooper crappep.cdcooper%TYPE
                   ,pr_nrdconta crappep.nrdconta%TYPE
                   ,pr_nrctremp crappep.nrctremp%TYPE
                   ,pr_nrparepr crappep.nrparepr%TYPE) IS
    SELECT pep.cdcooper
          ,pep.nrdconta
          ,pep.nrctremp
          ,pep.nrparepr        
          ,pep.vljura60         
    FROM   tbepr_renegociacao_crappep pep
    WHERE  pep.cdcooper = pr_cdcooper
    AND    pep.nrdconta = pr_nrdconta
    AND    pep.nrctremp = pr_nrctremp
    AND    pep.nrparepr = pr_nrparepr
    AND    pep.nrversao = 1; --Primeira Renegociação (As demais renegociações já são em cima de novo contrato)    
  rw_crappep  cr_crappep%ROWTYPE;     
  
  --Buscar Pagamentos (New)
  CURSOR cr_pagamentos(pr_cdcooper IN NUMBER
                      ,pr_nrdconta IN NUMBER
                      ,pr_nrctremp IN NUMBER) IS 
    select dtmvtolt, dtpagemp, cdcooper, nrdconta, nrctremp
          ,cdhistor, vllanmto
    from   craplem
    where  cdcooper = pr_cdcooper
    and    nrdconta = pr_nrdconta
    and    nrctremp = pr_nrctremp
    and    cdhistor in (1039,1044,1045,1057) ---Historico levantado atraves da empr0021 (pagamentos LEM) com apoio do James
    order by dtmvtolt, progress_recid;         
             
  --Variáveis de Erro
  vr_erro         EXCEPTION; 
  vr_ds_erro      VARCHAR2(4000);            
  vr_cdcritic    crapcri.cdcritic%TYPE;
  vr_dscritic    crapcri.dscritic%TYPE;
  vr_des_reto    VARCHAR2(3);
  vr_tab_erro    gene0001.typ_tab_erro;
  
  --Variáveis
  vr_qt_lido      NUMBER := 0;
  vr_qt_alterado  NUMBER := 0;
  vr_qt_diferente NUMBER := 0;
  vr_qt_igual     NUMBER := 0;
  vr_qtdiaatr     NUMBER;
  vr_vljuremutt   NUMBER := 0;
  vr_vliofcpltt   NUMBER := 0;
  vr_vlmtapartt   NUMBER := 0;
  vr_vlmrapartt   NUMBER := 0;     
  w_dtmvtolt      DATE;
  w_dtmvtoan      DATE;
  -- (New)
  vr_qt_pagtos    NUMBER := 0;
  vr_vlpgjr60     NUMBER := 0;
  vr_vlpgjrem     NUMBER := 0;
  -- (Fim New)
  --
  vr_tab_pgto_parcel  empr0001.typ_tab_pgto_parcel;
  vr_tab_calculado    empr0001.typ_tab_calculado;
  vr_indice           PLS_INTEGER;
  --
  --  
    /* Busca dos pagamentos das parcelas de empréstimo */
    PROCEDURE pc_busca_pgto_parcelas(pr_cdcooper        IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                    ,pr_cdagenci        IN crapass.cdagenci%TYPE --> Código da agência
                                    ,pr_nrdcaixa        IN craperr.nrdcaixa%TYPE --> Número do caixa
                                    ,pr_cdoperad        IN crapdev.cdoperad%TYPE --> Código do Operador
                                    ,pr_nmdatela        IN VARCHAR2 --> Nome da tela
                                    ,pr_idorigem        IN INTEGER --> Id do módulo de sistema
                                    ,pr_nrdconta        IN crapepr.nrdconta%TYPE --> Número da conta
                                    ,pr_idseqttl        IN crapttl.idseqttl%TYPE --> Seq titula
                                    ,pr_dtmvtolt        IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                    ,pr_flgerlog        IN VARCHAR2 --> Indicador S/N para geração de log
                                    ,pr_nrctremp        IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                    ,pr_dtmvtoan        IN crapdat.dtmvtolt%TYPE --> Data anterior
                                    ,pr_nrparepr        IN INTEGER --> Número parcelas empréstimo
                                    ,pr_des_reto        OUT VARCHAR --> Retorno OK / NOK
                                    ,pr_tab_erro        OUT gene0001.typ_tab_erro --> Tabela com possíves erros
                                    ,pr_tab_pgto_parcel OUT empr0001.typ_tab_pgto_parcel --> Tabela com registros de pagamentos
                                    ,pr_tab_calculado   OUT empr0001.typ_tab_calculado) IS --> Tabela com totais calculados
    BEGIN     
      DECLARE
        -- Saida com erro opção 2
        vr_exc_erro_2 EXCEPTION;
        -- Rowid para inserção de log
        vr_nrdrowid ROWID;
        -- Busca dos dados de empréstimo
        CURSOR cr_crapepr IS
          SELECT epr.cdlcremp
                ,epr.txmensal
                ,epr.dtdpagto
                ,epr.qtprecal
                ,epr.vlemprst
                ,epr.qtpreemp
                ,epr.inliquid
                ,epr.idfiniof
                ,epr.vliofepr
                ,epr.vltarifa
                ,epr.vlsdeved
                --P437
                ,epr.tpemprst
                ,epr.tpdescto
                --
            FROM tbepr_renegociacao_crapepr epr
           WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp
           AND epr.nrversao = 1; --Primeira Renegociação (As demais renegociações já são em cima de novo contrato)
                                       
        rw_crapepr cr_crapepr%ROWTYPE;
        -- Busca dos dados de complemento do empréstimo
        CURSOR cr_crawepr IS
          SELECT epr.dtlibera, epr.idfiniof
            FROM tbepr_renegociacao_crawepr epr
           WHERE epr.cdcooper = pr_cdcooper
             AND epr.nrdconta = pr_nrdconta
             AND epr.nrctremp = pr_nrctremp
             AND epr.nrversao = 1; --Primeira Renegociação (As demais renegociações já são em cima de novo contrato)
             
        rw_crawepr cr_crawepr%ROWTYPE;

        -- Indice para o Array de historicos
        vr_vllanmto   craplem.vllanmto%TYPE;
        vr_vlsdeved   NUMBER := 0; --> Saldo devedor
        vr_vlprepag   NUMBER := 0; --> Qtde parcela paga
        vr_vlpreapg   NUMBER := 0; --> Qtde parcela a pagar
        vr_vlpagsld   NUMBER := 0; --> Valor pago saldo
        vr_vlsderel   NUMBER := 0; --> Saldo para relatórios
        vr_vlsdvctr   NUMBER := 0;
        -- Buscar todas as parcelas de pagamento
        -- do empréstimo e seus valores
        CURSOR cr_crappep IS
          SELECT pep.cdcooper
                ,pep.nrdconta
                ,pep.nrctremp
                ,pep.nrparepr
                ,pep.vlparepr
                ,pep.vljinpar
                ,pep.vlmrapar
                ,pep.vliofcpl
                ,pep.vlmtapar
                ,pep.dtvencto
                ,pep.dtultpag
                ,pep.vlpagpar
                ,pep.vlpagmta
                ,pep.vlpagmra
                ,pep.vldespar
                ,pep.vlsdvpar
                ,pep.inliquid
                ,pep.vlpagjin
                --P437
                ,pep.vlsdvatu
            FROM tbepr_renegociacao_crappep pep
           WHERE pep.cdcooper = pr_cdcooper
                 AND pep.nrdconta = pr_nrdconta
                 AND pep.nrctremp = pr_nrctremp
                 AND pep.inliquid = 0 -- Não liquidada
                 AND (pr_nrparepr = 0 OR pep.nrparepr = pr_nrparepr) -- Traz todas quado zero, ou somente a passada
             AND pep.nrversao  = 1; --Primeira Renegociação (As demais renegociações já são em cima de novo contrato)
             
        -- Indica para a temp-table
        vr_ind_pag NUMBER;
        -- Buscar o total pago no mês
        CURSOR cr_craplem(pr_cdcooper IN craplem.cdcooper%TYPE
                         ,pr_nrdconta IN craplem.nrdconta%TYPE
                         ,pr_nrctremp IN craplem.nrctremp%TYPE
                         ,pr_dtmvtolt IN craplem.dtmvtolt%TYPE) IS

        SELECT /*+ INDEX (lem CRAPLEM##CRAPLEM7) */ SUM(DECODE(lem.cdhistor,
                        1044,
                        lem.vllanmto,
                        1039,
                        lem.vllanmto,
                        1045,
                        lem.vllanmto,
                        1057,
                        lem.vllanmto,
                        1716,
                        lem.vllanmto * -1,
                        1707,
                        lem.vllanmto * -1,
                        1714,
                        lem.vllanmto * -1,
                        1705,
                        lem.vllanmto * -1)) as vllanmto
        FROM tbepr_renegociacao_craplem lem
       WHERE lem.cdcooper = pr_cdcooper
         AND lem.nrdconta = pr_nrdconta
         AND lem.nrctremp = pr_nrctremp
         AND lem.nrdolote in (600012, 600013, 600031)
         AND lem.cdhistor in (1039, 1057, 1044, 1045, 1716, 1707, 1714, 1705)
         AND TO_CHAR(lem.dtmvtolt, 'MMRRRR') = TO_CHAR(pr_dtmvtolt, 'MMRRRR')
          AND lem.nrversao  = 1; --Primeira Renegociação (As demais renegociações já são em cima de novo contrato)          

        rw_craplem cr_craplem%ROWTYPE;
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic VARCHAR2(4000);
        
              
              /* Calculo de valor atualizado de parcelas de empréstimo em atraso */
        PROCEDURE pc_calc_atraso_parcela(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                        ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                        ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                                        ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                                        ,pr_nmdatela IN VARCHAR2 --> Nome da tela
                                        ,pr_idorigem IN INTEGER --> Id do módulo de sistema
                                        ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                        ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq titula
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                        ,pr_flgerlog IN VARCHAR2 --> Indicador S/N para geração de log
                                        ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                        ,pr_nrparepr IN INTEGER --> Número parcelas empréstimo
                                        ,pr_vlpagpar IN NUMBER --> Valor a pagar originalmente
                                        ,pr_vlpagsld OUT NUMBER --> Saldo a pagar após multa e juros
                                        ,pr_vlatupar OUT NUMBER --> Valor atual da parcela
                                        ,pr_vlmtapar OUT NUMBER --> Valor de multa
                                        ,pr_vljinpar OUT NUMBER --> Valor dos juros
                                        ,pr_vlmrapar OUT NUMBER --> Valor de mora
                                        ,pr_vliofcpl OUT NUMBER --> Valor de IOF de atraso
                                        ,pr_vljinp59 OUT NUMBER --> Juros quando período inferior a 59 dias
                                        ,pr_vljinp60 OUT NUMBER --> Juros quando período igual ou superior a 60 dias
                                        ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                        ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com possíveis erros
        BEGIN    
          DECLARE
            -- Saida com erro opção 2
            vr_exc_erro_2 EXCEPTION;
            -- Rowid para inserção de log
            vr_nrdrowid ROWID;
            -- Busca dos dados de empréstimo
            CURSOR cr_crapepr IS
              SELECT epr.dtdpagto
                    ,epr.cdlcremp
                    ,epr.txmensal
                    ,epr.qttolatr
                    ,epr.qtpreemp
                    ,epr.vlemprst
                    ,epr.cdfinemp
                    --P437
                    ,epr.tpdescto
                    ,epr.tpemprst
                    --
                FROM tbepr_renegociacao_crapepr epr
               WHERE epr.cdcooper = pr_cdcooper
               AND epr.nrdconta = pr_nrdconta
               AND epr.nrctremp = pr_nrctremp
                AND epr.nrversao  = 1; --Primeira Renegociação (As demais renegociações já são em cima de novo contrato)
                
            rw_crapepr cr_crapepr%ROWTYPE;
            -- Busca dos dados da parcela
            CURSOR cr_crappep IS
              SELECT pep.nrparepr
                    ,pep.dtultpag
                    ,pep.dtvencto
                    ,pep.vlparepr
                    ,pep.vlpagmta
                    ,pep.vlsdvpar
                    ,pep.vlsdvsji
                    ,pep.vlpagmra
                    ,pep.vlpagiof
                    --P437
                    ,pep.vlsdvatu
                    ,pep.vlmtapar
                    ,pep.vljinpar
                    ,pep.vlmrapar
                    ,pep.vliofcpl
                    ,pep.vljura60
                    ,pep.vlpagpar
                    ,pep.vlpagjin
                    --               
                FROM tbepr_renegociacao_crappep pep
               WHERE pep.cdcooper = pr_cdcooper
               AND pep.nrdconta = pr_nrdconta
               AND pep.nrctremp = pr_nrctremp
               AND pep.nrparepr = pr_nrparepr
               AND pep.nrversao  = 1; --Primeira Renegociação (As demais renegociações já são em cima de novo contrato)
               
            rw_crappep cr_crappep%ROWTYPE;
            -- Busca das linhas de crédito
            CURSOR cr_craplcr(pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
              SELECT lcr.perjurmo,
                     lcr.flgcobmu
                FROM craplcr lcr
               WHERE lcr.cdcooper = pr_cdcooper
                     AND lcr.cdlcremp = pr_cdlcremp;
            rw_craplcr cr_craplcr%ROWTYPE;

            CURSOR cr_craplem(pr_cdcooper craplem.cdcooper%type
                             ,pr_nrdconta craplem.nrdconta%type
                             ,pr_nrctremp craplem.nrctremp%type
                             ,pr_nrparepr craplem.nrparepr%type) is
              SELECT lem.dtmvtolt
                FROM tbepr_renegociacao_craplem  lem
               WHERE lem.cdcooper = pr_cdcooper
               AND lem.nrdconta = pr_nrdconta
               AND lem.nrctremp = pr_nrctremp
               AND lem.nrparepr = pr_nrparepr
               AND lem.cdhistor in (1078,1620,1077,1619)
               AND lem.nrversao  = 1; --Primeira Renegociação (As demais renegociações já são em cima de novo contrato)

            -- Variaveis auxiliares ao calculo
            vr_percmult NUMBER; --> % de multa para o calculo
            vr_nrdiamta INTEGER; --> Prazo para tolerancia da multa
            vr_prtljuro NUMBER; --> Prazo de tolerancia para incidencia de juros de mora
            vr_dtmvtolt DATE; --> Data de pagamento
            vr_diavtolt INTEGER; --> Dia do pagamento
            vr_mesvtolt INTEGER; --> Mes do pagamento
            vr_anovtolt INTEGER; --> Ano do pagamento
            vr_qtdiasld INTEGER; --> Qtde de dias de atraso
            vr_qtdianor INTEGER; --> Qtde de dias passados da data do vcto
            vr_qtdiamor NUMBER; --> Qtde de dias entre a data atual e a calculada
            vr_txdiaria NUMBER(18, 10); --> Taxa para calculo de mora
            vr_dstextab craptab.dstextab%TYPE;
            vr_vliofpri NUMBER(18, 10); --> Taxa para calculo de mora
            vr_vltxaiof number(18, 10);
            vr_flgimune pls_integer;
            vr_vlbaseiof number;
            vr_qtdiaiof NUMBER;
            vr_cdcritic crapcri.cdcritic%TYPE;
            vr_dscritic VARCHAR2(4000);
            vr_dtvencto_juros_normais DATE;
            
            
            PROCEDURE pc_calcula_valor_iof_epr(pr_tpoperac IN PLS_INTEGER --> Tipo da Operacao (1-> Calculo IOF/Atraso, 2-> Calculo Pagamento em Atraso, 3-> Todos)
                                          ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa referente ao contrato de empréstimos
                                          ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da conta referente ao empréstimo
                                          ,pr_nrctremp IN NUMBER DEFAULT NULL   --> Número do contrato de empréstimo
                                          ,pr_vlemprst IN NUMBER                --> Valor do empréstimo para efeito de cálculo
                                          ,pr_vltotope in number DEFAULT 0      --> Valor total da operacao
                                          ,pr_dscatbem IN VARCHAR2              --> Descrição da categoria do bem, valor default NULO 
                                          ,pr_cdlcremp IN NUMBER                --> Linha de crédito do empréstimo
                                          ,pr_cdfinemp IN NUMBER                --> Finalidade do Empréstimo      
                                          ,pr_dtmvtolt IN DATE                  --> Data do movimento
                                          ,pr_qtdiaiof IN NUMBER DEFAULT 0      --> Quantidade de dias em atraso
                                          ,pr_vliofpri OUT NUMBER               --> Valor do IOF principal
                                          ,pr_vliofadi OUT NUMBER               --> Valor do IOF adicional
                                          ,pr_vliofcpl OUT NUMBER               --> Valor do IOF complementar
                                          ,pr_vltaxa_iof_principal OUT NUMBER   --> Valor da Taxa do IOF Principal
                                          ,pr_flgimune OUT PLS_INTEGER          --> Possui imunidade tributária
                                          ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica
            BEGIN
            
              DECLARE
                vr_exc_erro EXCEPTION;
                vr_dscritic crapcri.dscritic%TYPE;
                vr_vltaxa_iof_atraso NUMBER := null;
                vr_vltotope          number;
                vr_qtdiaiof          NUMBER;
                vr_dtvencto          DATE;
                
                -- Cursor para dados da PF, PJ, PJ Cooperativa e regime tributário
                CURSOR cr_pessoa(pr_cdcooper IN crapcop.cdcooper%TYPE
                                ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
                   SELECT a.inpessoa, NVL(j.natjurid,0) natjurid, NVL(j.tpregtrb,0) tpregtrb
                   FROM crapass a
                   LEFT JOIN crapjur j ON j.cdcooper = a.cdcooper AND j.nrdconta = a.nrdconta
                   WHERE a.nrdconta = pr_nrdconta AND a.cdcooper = pr_cdcooper;
                 rw_pessoa cr_pessoa%ROWTYPE; 
                 
               CURSOR cr_crapepr(pr_cdcooper IN crapcop.cdcooper%TYPE
                                ,pr_nrdconta IN crapass.nrdconta%TYPE
                                ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
                 SELECT t.vlaqiofc
                        ,t.dtmvtolt
                 FROM tbepr_renegociacao_crapepr t
                 WHERE t.cdcooper = pr_cdcooper
                       AND t.nrdconta = pr_nrdconta
                       AND t.nrctremp = pr_nrctremp
                       AND t.tpemprst IN(1, 2) 
                       AND t.dtmvtolt >= TO_DATE('03/04/2017','dd/mm/yyyy')
                 AND t.nrversao  = 1; --Primeira Renegociação (As demais renegociações já são em cima de novo contrato)
                 
               rw_crapepr cr_crapepr%ROWTYPE;
               

                 
              BEGIN
                -- Inicializar retornos
                pr_vliofpri             := 0;
                pr_vliofadi             := 0;
                pr_vliofcpl             := 0;
                pr_vltaxa_iof_principal := 0;
                pr_flgimune             := 0;
                vr_qtdiaiof             := pr_qtdiaiof;
                 
                -- Retornar tipo da pessoa
                OPEN cr_pessoa(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);
                FETCH cr_pessoa INTO rw_pessoa;
                IF cr_pessoa%NOTFOUND THEN
                  CLOSE cr_pessoa;
                  vr_dscritic := 'Associado não localizado!';
                  RAISE vr_exc_erro;
                END IF;
                CLOSE cr_pessoa;
                
                -- Se foi enviado contrato, iremos buscar suas informações
                IF pr_nrctremp IS NOT NULL THEN
                  OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctremp => pr_nrctremp);
                   FETCH cr_crapepr INTO rw_crapepr;
                   IF cr_crapepr%FOUND THEN
                      vr_vltaxa_iof_atraso := rw_crapepr.vlaqiofc;
                   END IF;
                   CLOSE cr_crapepr;  
                END IF;
                
                IF pr_vltotope = 0 then
                   vr_vltotope := pr_vlemprst;
                ELSE
                   vr_vltotope := pr_vltotope;
                END IF;
                
                -- Para pagamento em atraso
                IF pr_tpoperac = 2 AND vr_qtdiaiof > 0 THEN 
                  -- Calcular data do vencimento (Diminuimos data pagamento - dias em atraso pra chegar no dia do vencimento)
                  vr_dtvencto := pr_dtmvtolt - vr_qtdiaiof;
                  -- Regra 01 - Pagamentos superiores a 365 dias da contratação
                  IF (pr_dtmvtolt - rw_crapepr.dtmvtolt ) >= 365 THEN 
                    -- Descontamos os dios de IOF já cobrados na liberação
                    vr_qtdiaiof := 365 - (vr_dtvencto - rw_crapepr.dtmvtolt);
                  ELSE -- Regra 02 - PAgamentos entre 365 dias da contratação
                    -- Diferença entre a data do pagamento e o vencimento
                    vr_qtdiaiof := pr_dtmvtolt - vr_dtvencto;
                  END IF;
                  -- Garantir que a quantidade de dias não fique negativa
                  vr_qtdiaiof := greatest(vr_qtdiaiof,0);
                END IF;
                
                -- Procedure para calcular o valor do IOF
                tiof0001.pc_calcula_valor_iof(pr_tpproduto            => 1 --> 1 - Emprestimo
                                    ,pr_tpoperacao           => pr_tpoperac
                                    ,pr_cdcooper             => pr_cdcooper
                                    ,pr_nrdconta             => pr_nrdconta
                                    ,pr_inpessoa             => rw_pessoa.inpessoa
                                    ,pr_natjurid             => rw_pessoa.natjurid
                                    ,pr_tpregtrb             => rw_pessoa.tpregtrb
                                    ,pr_dtmvtolt             => pr_dtmvtolt
                                    ,pr_qtdiaiof             => vr_qtdiaiof
                                    ,pr_vloperacao           => pr_vlemprst
                                    ,pr_vltotalope           => vr_vltotope
                                    ,pr_vltaxa_iof_atraso    => vr_vltaxa_iof_atraso
                                    ,pr_vliofpri             => pr_vliofpri
                                    ,pr_vliofadi             => pr_vliofadi
                                    ,pr_vliofcpl             => pr_vliofcpl
                                    ,pr_vltaxa_iof_principal => pr_vltaxa_iof_principal
                                    ,pr_dscritic             => vr_dscritic
                                    ,pr_flgimune             => pr_flgimune);
                                    
                  IF NVL(vr_dscritic, ' ') <> ' ' THEN
                    RAISE vr_exc_erro;
                  END IF;
                  
                  -- Não calcular IOF em atraso para contratos com data anterior a 04/04/2017
                IF rw_crapepr.dtmvtolt < TO_DATE('04/04/2017','dd/mm/yyyy') THEN
                    pr_vliofcpl := 0;
                  END IF;
                  
                  
                -- Checar isenção de IOF
                tiof0001.pc_Calcula_isencao_iof(pr_cdcooper => pr_cdcooper --> Código da cooperativa referente ao contrato de empréstimos
                                           ,pr_nrdconta => pr_nrdconta --> Número da conta referente ao empréstimo
                                           ,pr_dscatbem => pr_dscatbem --> Descrição da categoria do bem, valor default NULO 
                                           ,pr_cdlcremp => pr_cdlcremp --> Linha de crédito do empréstimo                                                                        
                                      ,pr_cdfinemp => pr_cdfinemp --> Finalidade
                                           ,pr_vliofpri => pr_vliofpri --> Valor do IOF principal
                                           ,pr_vliofadi => pr_vliofadi --> Valor do IOF adicional
                                           ,pr_vliofcpl => pr_vliofcpl --> Valor do IOF complementar
                                           ,pr_dscritic => vr_dscritic); --> Descrição da crítica
                -- Testar retorno de erro
                IF vr_dscritic IS NOT NULL THEN
                  RAISE vr_exc_erro;
                  END IF;
                   
                EXCEPTION
                  WHEN vr_exc_erro THEN
                    pr_dscritic := vr_dscritic;
                  WHEN OTHERS THEN
                    --Variavel de erro recebe erro ocorrido
                  pr_dscritic := 'Erro ao calcular IOF-EPR. Rotina TIOF0001.pc_calcula_valor_iof_epr. '||sqlerrm;
              END;
                
            END pc_calcula_valor_iof_epr;              

          BEGIN
            -- Criar um bloco para faciliar o tratamento de erro
            BEGIN
              -- Busca dos dados do empréstimo
              OPEN cr_crapepr;
              FETCH cr_crapepr
                INTO rw_crapepr;
              -- Se não encontrar
              IF cr_crapepr%NOTFOUND THEN
                -- Fechar o cursor e gerar erro
                CLOSE cr_crapepr;
                -- Gerar erro com critica 356
                vr_cdcritic := 356;
                vr_ds_erro := gene0001.fn_busca_critica(356);
                RAISE vr_erro;
              ELSE
                -- Apenas fechar o cursor e continuar
                CLOSE cr_crapepr;
              END IF;

              -- Buscar informações da linha de crédito
              OPEN cr_craplcr(pr_cdlcremp => rw_crapepr.cdlcremp);
              FETCH cr_craplcr
                INTO rw_craplcr;
              -- Se não encontrar
              IF cr_craplcr%NOTFOUND THEN
                -- Fechar o cursor
                CLOSE cr_craplcr;
                -- Gerar erro
                vr_cdcritic := 55;
                RAISE vr_erro;
              ELSE
                -- Fechar o cursor
                CLOSE cr_craplcr;
              END IF;

              -- Verifica se a Linha de Credito Cobra Multa
              IF rw_craplcr.flgcobmu = 1 THEN
                -- Obter o % de multa da CECRED - TAB090
               
                vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => 3 -- Fixo 3 - Cecred
                               ,pr_nmsistem => 'CRED'
                               ,pr_tptabela => 'USUARI'
                               ,pr_cdempres => 11
                               ,pr_cdacesso => 'PAREMPCTL'
                               ,pr_tpregist => 01);
                IF vr_dstextab IS NULL THEN
                  -- Gerar erro com critica 55
                  vr_cdcritic := 55;
                  vr_ds_erro := gene0001.fn_busca_critica(55);
                  RAISE vr_erro;
                END IF;
                -- Utilizar como % de multa, as 6 primeiras posições encontradas
                vr_percmult := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,1,6));
              ELSE
                vr_percmult := 0;
              END IF;

              -- Prazo para tolerancia da multa está nas três primeiras posições do campo
              vr_nrdiamta := rw_crapepr.qttolatr;
              -- Prazo de tolerancia para incidencia de juros de mora
              -- também recebe inicialmente o mesmo valor
              vr_prtljuro := vr_nrdiamta;

              -- Busca dos dados da parcela
              OPEN cr_crappep;
              FETCH cr_crappep
                INTO rw_crappep;
              -- Se não encontrar
              IF cr_crappep%NOTFOUND THEN
                -- Fechar o cursor e gerar erro
                CLOSE cr_crappep;
                -- MOntar descrição de erro
                vr_dscritic := 'Parcela nao encontrada.';
                RAISE vr_erro;
              ELSE
                -- Apenas fechar o cursor e continuar
                CLOSE cr_crappep;
              END IF;
              
              --P437-Consignado. Se Consignado, retornar os valores calculados pela FIS
              IF rw_crapepr.tpemprst = 1 AND 
                 rw_crapepr.tpdescto = 2 THEN
                 
                 -- Se o valor a pagar originalmente for diferente de zero
                 IF pr_vlpagpar <> 0 THEN
                    -- Valor a pagar - multa e juros de mora
                    pr_vlpagsld := pr_vlpagpar -
                                   (ROUND(rw_crappep.vlmtapar, 2) + ROUND( rw_crappep.vlmrapar, 2) + round(nvl(rw_crappep.vliofcpl,0),2));
                 ELSE
                   -- Utilizar o valor já calculado anteriormente
                   pr_vlpagsld := rw_crappep.vlsdvpar;
                END IF;
                pr_vlatupar := rw_crappep.vlsdvatu;
                pr_vlmtapar := rw_crappep.vlmtapar;
                pr_vljinpar := rw_crappep.vljinpar;
                pr_vlmrapar := rw_crappep.vlmrapar;
                pr_vliofcpl := rw_crappep.vliofcpl;
                --pr_vljinp59 := rw_crappep.vlj
                pr_vljinp60 := rw_crappep.vljura60;          
              ELSE          
              -- Se ainda nao pagou nada da parcela
              IF rw_crappep.dtultpag IS NULL
                 OR rw_crappep.dtultpag < rw_crappep.dtvencto THEN
                -- Pegar a data de vencimento dela
                vr_dtmvtolt := rw_crappep.dtvencto;
              ELSE
                -- Pegar a ultima data que pagou a parcela
                vr_dtmvtolt := rw_crappep.dtultpag;
              END IF;

              IF NVL(rw_crappep.vlpagjin,0) > 0 AND rw_crappep.dtultpag IS NOT NULL THEN
                -- Senao pegar a ultima data que pagou a parcela
                vr_dtvencto_juros_normais := rw_crappep.dtultpag;
              ELSE
                vr_dtvencto_juros_normais := rw_crappep.dtvencto;
              END IF;

              -- Calcula dias para o IOF
              vr_qtdiaiof := pr_dtmvtolt - vr_dtmvtolt;

              -- Dividir a data em dia/mes/ano para utilização da rotina dia360
              vr_diavtolt := to_char(pr_dtmvtolt, 'dd');
              vr_mesvtolt := to_char(pr_dtmvtolt, 'mm');
              vr_anovtolt := to_char(pr_dtmvtolt, 'yyyy');
              
              -- Calcular quantidade de dias para o saldo devedor        
              empr0001.pc_calc_dias360(pr_ehmensal => FALSE -- Indica se juros esta rodando na mensal
                              ,pr_dtdpagto => to_char(rw_crapepr.dtdpagto
                                                     ,'dd') -- Dia do primeiro vencimento do emprestimo
                              ,pr_diarefju => to_char(vr_dtvencto_juros_normais, 'dd') -- Dia da data de referência da última vez que rodou juros
                              ,pr_mesrefju => to_char(vr_dtvencto_juros_normais, 'mm') -- Mes da data de referência da última vez que rodou juros
                              ,pr_anorefju => to_char(vr_dtvencto_juros_normais, 'yyyy') -- Ano da data de referência da última vez que rodou juros
                              ,pr_diafinal => vr_diavtolt -- Dia data final
                              ,pr_mesfinal => vr_mesvtolt -- Mes data final
                              ,pr_anofinal => vr_anovtolt -- Ano data final
                              ,pr_qtdedias => vr_qtdiasld); -- Quantidade de dias calculada
                                      
              -- Calcula quantos dias passaram do vencimento até o parametro par_dtmvtolt
              -- Obs: Será usado para comparar se a quantidade de dias que passou está dentro da tolerância
              --vr_qtdianor := pr_dtmvtolt - rw_crappep.dtvencto;          
              empr9999.pc_calc_dias_atraso_jur( pr_cdcooper => pr_cdcooper,
                                      pr_dtmvtolt => pr_dtmvtolt,
                                      pr_dtvencto => rw_crappep.dtvencto,
                                      pr_qttolatr => vr_nrdiamta,
                                      pr_qtdiacal => vr_qtdianor,
                                      pr_cdcritic => vr_cdcritic,
                                      pr_dscritic => vr_dscritic);
                                                
              IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_erro;
              END IF; 
              
              -- Se a quantidade de dias for menor ou igual a zero
              IF vr_qtdianor <= 0 THEN
                -- Zerar a multa
                vr_percmult := 0;
              END IF;
              -- Calcular o valor da multa, descontando o que já foi calculado para a parcela
              pr_vlmtapar := ROUND((rw_crappep.vlparepr * vr_percmult / 100), 2) -
                             rw_crappep.vlpagmta; 
              
              IF pr_vlmtapar < 0 THEN
                pr_vlmtapar := 0; 
              END IF;  
              
              -- Se já houve pagamento
              IF rw_crappep.dtultpag IS NOT NULL OR rw_crappep.vlpagmra > 0 THEN
                /* Obter ultimo lancamento de juro do contrato */
                FOR rw_craplem IN cr_craplem(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_nrctremp => pr_nrctremp
                                            ,pr_nrparepr => pr_nrparepr) LOOP

                  IF rw_craplem.dtmvtolt > vr_dtmvtolt OR vr_dtmvtolt IS NULL THEN
                    vr_dtmvtolt := rw_craplem.dtmvtolt;
                  END IF;

                END LOOP; /* END FOR rw_craplem */

              END IF;
              
              -- Calcular quantidade de dias para o juros de mora desde
              -- o ultima ocorrência de juros de mora/vencimento até o par_dtmvtolt
              --vr_qtdiamor := pr_dtmvtolt - vr_dtmvtolt;
              empr9999.pc_calc_dias_atraso_jur( pr_cdcooper => pr_cdcooper,
                                        pr_dtmvtolt => pr_dtmvtolt,
                                        pr_dtvencto => vr_dtmvtolt,
                                        pr_qttolatr => vr_prtljuro,
                                        pr_qtdiacal => vr_qtdiamor,
                                        pr_cdcritic => vr_cdcritic,
                                        pr_dscritic => vr_dscritic);
              
              IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
                RAISE vr_erro;
              END IF;

              -- Calcular os juros considerando o valor da parcela             
              empr0001.pc_calc_juros_normais_total(pr_vlpagpar => rw_crappep.vlsdvpar -- Valor a pagar originalmente
                                                  ,pr_txmensal => rw_crapepr.txmensal -- Valor da taxa mensal
                                                  ,pr_qtdiajur => vr_qtdiasld -- Quantidade de dias de aplicação de juros
                                                  ,pr_vljinpar => pr_vljinpar); -- Valor com os juros aplicados

         
              -- Atualizar o valor da parcela
              pr_vlatupar := rw_crappep.vlsdvpar + pr_vljinpar;

              -- Se a quantidade de dias está dentro da tolerancia de juros de mora
              IF vr_qtdianor <= 0 THEN
                -- Zerar o percentual de mora
                pr_vlmrapar := 0;
              ELSE
                -- TAxa de mora recebe o valor da linha de crédito
                vr_txdiaria := ROUND((100 * (POWER((rw_craplcr.perjurmo / 100) + 1
                                                  ,(1 / 30)) - 1))
                                    ,10);
                -- Dividimos por 100
                vr_txdiaria := vr_txdiaria / 100;
                -- Valor de juros de mora é relativo ao juros sem inadimplencia da parcela + taxa diaria calculada + quantidade de dias de mora
                pr_vlmrapar := round((rw_crappep.vlsdvsji * vr_txdiaria * vr_qtdiamor),2);
              END IF;


                /* Projeto 410 - valor base para IOF:
                   Valor da Parcela /((1+ tx mensal)^(qt parcelas - parcela atual))) */
              --Sempre calcular IOF complementar - ajustado com James
                vr_vlbaseiof :=   rw_crappep.vlparepr / ((power(( 1 + rw_crapepr.txmensal / 100 ),
                                      (rw_crapepr.qtpreemp - rw_crappep.nrparepr + 1) )));

                -- BAse do IOF Complementar é o menor valor entre o Saldo Devedor ou O Principal
                vr_vlbaseiof := LEAST(vr_vlbaseiof,rw_crappep.vlsdvsji );
                
                --novo (local)
                pc_calcula_valor_iof_epr(pr_tpoperac => 2 -- Só atraso
                                                 ,pr_cdcooper => pr_cdcooper
                                                 ,pr_nrdconta => pr_nrdconta
                                                 ,pr_nrctremp => pr_nrctremp
                                                 ,pr_vlemprst => vr_vlbaseiof -- valor principal
                                                 ,pr_vltotope => rw_crapepr.vlemprst
                                                 ,pr_dscatbem => ''
                                                 ,pr_cdlcremp => rw_crapepr.cdlcremp
                                                 ,pr_cdfinemp => rw_crapepr.cdfinemp
                                                 ,pr_dtmvtolt => pr_dtmvtolt
                                                 ,pr_qtdiaiof => vr_qtdiaiof
                                                 ,pr_vliofpri => vr_vliofpri
                                                 ,pr_vliofadi => vr_vliofpri
                                                 ,pr_vliofcpl => pr_vliofcpl
                                                 ,pr_vltaxa_iof_principal => vr_vltxaiof
                                                 ,pr_flgimune => vr_flgimune
                                                 ,pr_dscritic => vr_dscritic);

              -- Diminuir do valor do IOF complementar o valor já pago
              IF rw_crappep.vlpagiof > 0 THEN
                pr_vliofcpl := greatest(0,pr_vliofcpl-rw_crappep.vlpagiof);
              END IF;

              -- Se o valor a pagar originalmente for diferente de zero
              IF pr_vlpagpar <> 0 THEN
                -- Valor a pagar - multa e juros de mora
                pr_vlpagsld := pr_vlpagpar -
                               (ROUND(pr_vlmtapar, 2) + ROUND(pr_vlmrapar, 2) + round(nvl(pr_vliofcpl,0),2));
              ELSE
                -- Utilizar o valor já calculado anteriormente
                pr_vlpagsld := pr_vlatupar;
              END IF;
              
              END IF; --P437
              
              -- Chegou ao final sem problemas, retorna OK
              pr_des_reto := 'OK';
            EXCEPTION
              WHEN vr_erro THEN
                -- Retorno não OK
                pr_des_reto := 'NOK';
               
              WHEN vr_exc_erro_2 THEN
                -- Retorno não OK
                pr_des_reto := 'NOK';
                -- Copiar tabela de erro temporária para saída da rotina
                pr_tab_erro := vr_tab_erro;
            END;
            -- Se foi solicitado o envio de LOG
            IF pr_flgerlog = 'S' THEN
            null;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              -- Retorno não OK
              pr_des_reto := 'NOK';
              -- Montar descrição de erro não tratado
              vr_dscritic := 'Erro não tratado na empr0001.pc_calc_atraso_parcela> ' ||
                             sqlerrm;
          END;
        END pc_calc_atraso_parcela;
      BEGIN
        --Limpar Tabelas Memoria
        pr_tab_erro.DELETE;
        pr_tab_pgto_parcel.DELETE;
        pr_tab_calculado.DELETE;
        -- Criar um bloco para faciliar o tratamento de erro
        BEGIN
          -- Busca detalhes do empréstimo
          OPEN cr_crapepr;
          FETCH cr_crapepr
            INTO rw_crapepr;
          -- Se não tiver encontrado
          IF cr_crapepr%NOTFOUND THEN
            -- Fechar o cursor e gerar critica
            CLOSE cr_crapepr;
            vr_cdcritic := 356;
            RAISE vr_erro;
          ELSE
            -- fechar o cursor e continuar o processo
            CLOSE cr_crapepr;
          END IF;
          -- Busca dados complementares do empréstimo
          OPEN cr_crawepr;
          FETCH cr_crawepr
            INTO rw_crawepr;
          -- Se não tiver encontrado
          IF cr_crawepr%NOTFOUND THEN
            -- Fechar o cursor e gerar critica
            CLOSE cr_crawepr;
            vr_cdcritic := 535;
            RAISE vr_erro;
          ELSE
            -- fechar o cursor e continuar o processo
            CLOSE cr_crawepr;
          END IF;

          -- Buscar todas as parcelas de pagamento
          -- do empréstimo e seus valores
          FOR rw_crappep IN cr_crappep LOOP
            -- Criar um novo indice para a temp-table
            vr_ind_pag := pr_tab_pgto_parcel.COUNT() + 1;
            -- Copiar as informações da tabela para a temp-table
            pr_tab_pgto_parcel(vr_ind_pag).cdcooper := rw_crappep.cdcooper;
            pr_tab_pgto_parcel(vr_ind_pag).nrdconta := rw_crappep.nrdconta;
            pr_tab_pgto_parcel(vr_ind_pag).nrctremp := rw_crappep.nrctremp;
            pr_tab_pgto_parcel(vr_ind_pag).nrparepr := rw_crappep.nrparepr;
            pr_tab_pgto_parcel(vr_ind_pag).vlparepr := rw_crappep.vlparepr;
            pr_tab_pgto_parcel(vr_ind_pag).vljinpar := rw_crappep.vljinpar;
            pr_tab_pgto_parcel(vr_ind_pag).vlmrapar := rw_crappep.vlmrapar;
            pr_tab_pgto_parcel(vr_ind_pag).vlmtapar := rw_crappep.vlmtapar;
            pr_tab_pgto_parcel(vr_ind_pag).vliofcpl := rw_crappep.vliofcpl;
            pr_tab_pgto_parcel(vr_ind_pag).dtvencto := rw_crappep.dtvencto;
            pr_tab_pgto_parcel(vr_ind_pag).dtultpag := rw_crappep.dtultpag;
            pr_tab_pgto_parcel(vr_ind_pag).vlpagpar := rw_crappep.vlpagpar;
            pr_tab_pgto_parcel(vr_ind_pag).vlpagmta := rw_crappep.vlpagmta;
            pr_tab_pgto_parcel(vr_ind_pag).vlpagmra := rw_crappep.vlpagmra;
            pr_tab_pgto_parcel(vr_ind_pag).vldespar := rw_crappep.vldespar;
            pr_tab_pgto_parcel(vr_ind_pag).vlsdvpar := rw_crappep.vlsdvpar;
            pr_tab_pgto_parcel(vr_ind_pag).inliquid := rw_crappep.inliquid;
            pr_tab_pgto_parcel(vr_ind_pag).vlpagjin := rw_crappep.vlpagjin;

            -- Se ainda não foi liberado
            IF pr_dtmvtolt <= rw_crawepr.dtlibera THEN
              
              --P437-Consignado. Se Consignado, retornar os valores calculados pela FIS
              IF rw_crapepr.tpemprst = 1 AND rw_crapepr.tpdescto = 2 THEN               
                pr_tab_pgto_parcel(vr_ind_pag).vlatupar := rw_crappep.vlsdvatu;              
              ELSE
                pr_tab_pgto_parcel(vr_ind_pag).vlatupar := rw_crapepr.vlemprst / rw_crapepr.qtpreemp;
              END IF;
                                                                       
              pr_tab_pgto_parcel(vr_ind_pag).vlsdvpar := pr_tab_pgto_parcel(vr_ind_pag).vlatupar;
              pr_tab_pgto_parcel(vr_ind_pag).vlatrpag := pr_tab_pgto_parcel(vr_ind_pag).vlatupar;
              -- Guardar quantidades calculadas
              vr_vlsdvctr := vr_vlsdvctr + rw_crappep.vlsdvpar;

              -- Se a parcela ainda não venceu
            ELSIF rw_crappep.dtvencto > pr_dtmvtoan AND
                  rw_crappep.dtvencto <= pr_dtmvtolt THEN
                  
              -- Parcela em dia
              pr_tab_pgto_parcel(vr_ind_pag).vlatupar := rw_crappep.vlsdvpar;
              -- Guardar quantidades calculadas
              vr_vlsdvctr := vr_vlsdvctr + rw_crappep.vlsdvpar;

              /* A regularizar */
              vr_vlpreapg := vr_vlpreapg + pr_tab_pgto_parcel(vr_ind_pag)
                            .vlatupar;
              -- Se a parcela está vencida
            ELSIF rw_crappep.dtvencto < pr_dtmvtolt THEN
              -- Calculo de valor atualizado de parcelas de empréstimo em atraso
              --novo (local)
              pc_calc_atraso_parcela(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                             ,pr_cdagenci => pr_cdagenci --> Código da agência
                                             ,pr_nrdcaixa => pr_nrdcaixa --> Número do caixa
                                             ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                             ,pr_nmdatela => pr_nmdatela --> Nome da tela
                                             ,pr_idorigem => pr_idorigem --> Id do módulo de sistema
                                             ,pr_nrdconta => pr_nrdconta --> Número da conta
                                             ,pr_idseqttl => pr_idseqttl --> Seq titula
                                             ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                             ,pr_flgerlog => pr_flgerlog --> Indicador S/N para geração de log
                                             ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                             ,pr_nrparepr => rw_crappep.nrparepr --> Número parcelas empréstimo
                                             ,pr_vlpagpar => 0 --> Valor a pagar originalmente
                                             ,pr_vlpagsld => vr_vlpagsld --> Saldo a pagar após multa e juros
                                             ,pr_vlatupar => pr_tab_pgto_parcel(vr_ind_pag)
                                                             .vlatupar --> Valor atual da parcela
                                             ,pr_vlmtapar => pr_tab_pgto_parcel(vr_ind_pag)
                                                             .vlmtapar --> Valor de multa
                                             ,pr_vljinpar => pr_tab_pgto_parcel(vr_ind_pag)
                                                             .vljinpar --> Valor dos juros
                                             ,pr_vlmrapar => pr_tab_pgto_parcel(vr_ind_pag)
                                                             .vlmrapar --> Valor de mora
                                             ,pr_vliofcpl => pr_tab_pgto_parcel(vr_ind_pag)
                                                             .vliofcpl --> Valor de mora
                                             ,pr_vljinp59 => pr_tab_pgto_parcel(vr_ind_pag)
                                                             .vljinp59 --> Juros quando período inferior a 59 dias
                                             ,pr_vljinp60 => pr_tab_pgto_parcel(vr_ind_pag)
                                                             .vljinp60 --> Juros quando período igual ou superior a 60 dias
                                             ,pr_des_reto => vr_des_reto --> Retorno OK / NOK
                                             ,pr_tab_erro => vr_tab_erro); --> Tabela com possíveis erros
              -- Testar erro
              IF vr_des_reto = 'NOK' THEN
                -- Levantar exceção 2, onde já temos o erro na vr_tab_erro
                RAISE vr_exc_erro_2;
              END IF;
              -- Acumular o valor a regularizar
              vr_vlpreapg := vr_vlpreapg + pr_tab_pgto_parcel(vr_ind_pag)
                            .vlatupar;
              -- Guardar quantidades calculadas
              vr_vlsdvctr := vr_vlsdvctr + pr_tab_pgto_parcel(vr_ind_pag)
                            .vlatupar;

              -- Antecipação de parcela
            ELSIF rw_crappep.dtvencto > pr_dtmvtolt THEN
              --P437-Consignado. Se Consignado, retornar os valores calculados pela FIS
              IF rw_crapepr.tpemprst = 1 AND rw_crapepr.tpdescto = 2 THEN               
                pr_tab_pgto_parcel(vr_ind_pag).vlatupar := rw_crappep.vlsdvatu;
                pr_tab_pgto_parcel(vr_ind_pag).vldespar := rw_crappep.vldespar;               
              --
              ELSE
              -- Procedure para calcular valor antecipado de parcelas de empréstimo
              --Não precisa trocar
              empr0001.pc_calc_antecipa_parcela(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                               ,pr_cdagenci => pr_cdagenci --> Código da agência
                                               ,pr_nrdcaixa => pr_nrdcaixa --> Número do caixa
                                               ,pr_dtvencto => rw_crappep.dtvencto --> Data do vencimento
                                               ,pr_vlsdvpar => rw_crappep.vlsdvpar --> Valor devido parcela
                                               ,pr_txmensal => rw_crapepr.txmensal --> Taxa aplicada ao empréstimo
                                               ,pr_dtmvtolt => pr_dtmvtolt --> Data do movimento atual
                                               ,pr_dtdpagto => rw_crapepr.dtdpagto --> Data de pagamento
                                               ,pr_vlatupar => pr_tab_pgto_parcel(vr_ind_pag)
                                                               .vlatupar --> Valor atualizado da parcela
                                               ,pr_vldespar => pr_tab_pgto_parcel(vr_ind_pag)
                                                               .vldespar --> Valor desconto da parcela
                                               ,pr_des_reto => vr_des_reto --> Retorno OK / NOK
                                               ,pr_tab_erro => vr_tab_erro); --> Tabela com possíves erros
              -- Testar erro
              IF vr_des_reto = 'NOK' THEN
                -- Levantar exceção 2, onde já temos o erro na vr_tab_erro
                RAISE vr_exc_erro_2;
              END IF;
              END IF; --P437
              -- Iniciar valor da flag
              pr_tab_pgto_parcel(vr_ind_pag).flgantec := TRUE;
              -- Guardar quantidades calculadas
              vr_vlsdvctr := vr_vlsdvctr + rw_crappep.vlsdvpar;
            END IF;
            -- Somente calcular se o empréstimo estiver liberado
            IF NOT pr_dtmvtolt <= rw_crawepr.dtlibera THEN
              /* Se liberado */
              -- Saldo devedor
              pr_tab_pgto_parcel(vr_ind_pag).vlsdvpar := rw_crappep.vlsdvpar;

              pr_tab_pgto_parcel(vr_ind_pag).vlatrpag := NVL(pr_tab_pgto_parcel(vr_ind_pag)
                                                             .vlatupar
                                                            ,0) +
                                                         NVL(pr_tab_pgto_parcel(vr_ind_pag)
                                                             .vlmtapar
                                                            ,0) +
                                                         NVL(pr_tab_pgto_parcel(vr_ind_pag)
                                                             .vlmrapar
                                                            ,0) +
                                                         NVL(pr_tab_pgto_parcel(vr_ind_pag)
                                                             .vliofcpl
                                                            ,0);
              -- Saldo para relatorios
              vr_vlsderel := vr_vlsderel + pr_tab_pgto_parcel(vr_ind_pag)
                            .vlatupar;
              -- Saldo devedor total do emprestimo
              vr_vlsdeved := vr_vlsdeved + pr_tab_pgto_parcel(vr_ind_pag)
                            .vlatrpag;
            END IF;
          END LOOP;

          -- Limpar a variável
          vr_vllanmto := 0;

          -- Buscar o total pago no mês
          OPEN cr_craplem(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrctremp => pr_nrctremp
                         ,pr_dtmvtolt => pr_dtmvtolt);

          FETCH cr_craplem
           INTO rw_craplem;
          IF cr_craplem%FOUND THEN
            vr_vllanmto := nvl(vr_vllanmto, 0) + nvl(rw_craplem.vllanmto, 0);
          END IF;
          -- Fechar o cursor
          CLOSE cr_craplem;

          -- Adicionar o valor encontrado no valor pago
          vr_vlprepag := vr_vlprepag + NVL(vr_vllanmto, 0);
          -- Se o empréstimo ainda não estiver liberado e não esteja liquidado
          IF pr_dtmvtolt <= rw_crawepr.dtlibera AND rw_crapepr.inliquid <> 1 THEN
            /* Nao liberado */
            -- Continuar com os valores da tabela
            pr_tab_calculado(1).vlsdeved := rw_crapepr.vlemprst;
            pr_tab_calculado(1).vlsderel := rw_crapepr.vlemprst;
            pr_tab_calculado(1).vlsdvctr := rw_crapepr.vlemprst;

            -- Zerar prestações pagas e a pagar
            pr_tab_calculado(1).vlprepag := 0;
            pr_tab_calculado(1).vlpreapg := 0;
          ELSE
            -- Utilizar informações do cálculo
            pr_tab_calculado(1).vlsdeved := vr_vlsdeved;
            pr_tab_calculado(1).vlsderel := vr_vlsderel;
            pr_tab_calculado(1).vlsdvctr := vr_vlsdvctr;

            pr_tab_calculado(1).vlprepag := vr_vlprepag;
            pr_tab_calculado(1).vlpreapg := vr_vlpreapg;
          END IF;


          -- Copiar qtde prestações calculadas
          pr_tab_calculado(1).qtprecal := rw_crapepr.qtprecal;
          -- Chegou ao final sem problemas, retorna OK
          pr_des_reto := 'OK';
        EXCEPTION
          WHEN vr_erro THEN
            -- Retorno não OK
            pr_des_reto := 'NOK';        
          WHEN vr_exc_erro_2 THEN
            -- Retorno não OK
            pr_des_reto := 'NOK';
            -- Copiar tabela de erro temporária para saída da rotina
            pr_tab_erro := vr_tab_erro;
        END;
        
      EXCEPTION
        WHEN OTHERS THEN
          -- Retorno não OK
          pr_des_reto := 'NOK';
          -- Montar descrição de erro não tratado
          vr_dscritic := 'Erro não tratado na empr0001.pc_busca_pgto_parcelas> ' ||
                         sqlerrm;
          
      END;
    END pc_busca_pgto_parcelas;
  --
  --
  --
  -- Paamentos de Juros (New)
  PROCEDURE pc_paga_sld_ctr_renegociado1(pr_cdcooper IN  tbepr_renegociacao_saldo.cdcooper%TYPE
                                       ,pr_nrdconta IN  tbepr_renegociacao_saldo.nrdconta%TYPE
                                       ,pr_nrctremp IN  tbepr_renegociacao_saldo.nrctremp%TYPE
                                       ,pr_vldpagto IN  tbepr_renegociacao_saldo.vljura60%TYPE
                                       ,pr_dtpagto in date
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                       ,pr_dscritic OUT crapcri.dscritic%TYPE
                                       ) IS
    CURSOR cr_saldo(pr_cdcooper tbepr_renegociacao_saldo.cdcooper%TYPE
                   ,pr_nrdconta tbepr_renegociacao_saldo.nrdconta%TYPE
                   ,pr_nrctremp tbepr_renegociacao_saldo.nrctremp%TYPE
                   ) IS
      SELECT nvl(trs.vljura60, 0) - nvl(trs.vlpgjr60, 0) sldjur60
            ,nvl(trs.vljuremu, 0) - nvl(trs.vlpgjrem, 0) sldjurem
            ,nvl(trs.vlmultap, 0) - nvl(trs.vlpgmult, 0) sldmulta
            ,nvl(trs.vljurmor, 0) - nvl(trs.vlpgjrmr, 0) sldjurmr
            ,nvl(trs.vljurcor, 0) - nvl(trs.vlpgjrco, 0) sldjurco
        FROM tbepr_renegociacao_saldo trs
       WHERE trs.cdcooper = pr_cdcooper
         AND trs.nrdconta = pr_nrdconta
         AND trs.nrctremp = pr_nrctremp;
    --
    rw_saldo    cr_saldo%ROWTYPE;

    CURSOR cr_crapepr (pr_cdcooper crapepr.cdcooper%TYPE
                      ,pr_nrdconta crapepr.nrdconta%TYPE
                      ,pr_nrctremp crapepr.nrctremp%TYPE) IS

      SELECT p.tpemprst
        FROM crapepr p
       WHERE p.cdcooper = pr_cdcooper
         AND p.nrdconta = pr_nrdconta
         AND p.nrctremp = pr_nrctremp;

    rw_crapepr cr_crapepr%rowtype;


    vr_vldpagto NUMBER;
    vr_pgtmulta NUMBER;
    vr_pgtjurmr NUMBER;
    vr_pgtjurem NUMBER;
    vr_pgtjurco NUMBER;
    vr_exc_erro EXCEPTION;
    --
    PROCEDURE pc_gera_lcto_pgto1(pr_cdcooper IN  tbepr_renegociacao_lancto.cdcooper%TYPE
                               ,pr_nrdconta IN  tbepr_renegociacao_lancto.nrdconta%TYPE
                               ,pr_nrctremp IN  tbepr_renegociacao_lancto.nrctremp%TYPE
                               ,pr_pgtmulta IN  tbepr_renegociacao_lancto.vllanmto%TYPE
                               ,pr_pgtjurmr IN  tbepr_renegociacao_lancto.vllanmto%TYPE
                               ,pr_pgtjurem IN  tbepr_renegociacao_lancto.vllanmto%TYPE
                               ,pr_pgtjurco IN  tbepr_renegociacao_lancto.vllanmto%TYPE
                               ,pr_dtpagto in date
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                               ,pr_dscritic OUT crapcri.dscritic%TYPE
                               ) IS
     
      CURSOR cr_craplcr(pr_cdcooper crapepr.cdcooper%TYPE
                       ,pr_nrdconta crapepr.nrdconta%TYPE
                       ,pr_nrctremp crapepr.nrctremp%TYPE
                       ) IS
        SELECT epr.tpemprst
              ,lcr.dsoperac
          FROM crapepr epr
              ,craplcr lcr
         WHERE epr.cdcooper = lcr.cdcooper
           AND epr.cdlcremp = lcr.cdlcremp
           AND epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp;

      rw_craplcr  cr_craplcr%ROWTYPE;
      rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
      vr_hismult  tbepr_renegociacao_lancto.cdhistor%TYPE;
      vr_hisjrmr  tbepr_renegociacao_lancto.cdhistor%TYPE;
      vr_hisjrem  tbepr_renegociacao_lancto.cdhistor%TYPE;
      vr_hisjrco  tbepr_renegociacao_lancto.cdhistor%TYPE;
      vr_exc_erro EXCEPTION;

    BEGIN

      OPEN cr_craplcr(pr_cdcooper
                     ,pr_nrdconta
                     ,pr_nrctremp
                     );
      FETCH cr_craplcr INTO rw_craplcr;
      CLOSE cr_craplcr;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        --
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        pr_cdcritic := 0;
        pr_dscritic := 'Sistema sem data de movimento, tente novamente mais tarde';
        RAISE vr_exc_erro;
        --
      ELSE
        --
        CLOSE btch0001.cr_crapdat;
        --
      END IF;

      IF rw_craplcr.tpemprst = 1 THEN -- PP

        IF rw_craplcr.dsoperac = 'EMPRESTIMO' THEN

          vr_hismult := 3051; -- MULTA EMPRESTIMO PRE-FIXADO
          vr_hisjrmr := 3052; -- JURO MORA EMPRESTIMO PRE-FIXADO
          vr_hisjrem := 1037; -- APROPRIACAO JUROS CONTRATO EMPR. TX. PRE-FIXADA

        ELSE -- FINANCIAMENTO

          vr_hismult := 3053; -- MULTA FINANCIAMENTO PRE-FIXADO
          vr_hisjrmr := 3054; -- JURO MORA FINANCIAMENTO PRE-FIXADO
          vr_hisjrem := 1038; -- APROPR.JUROS CONTRATO FINANC. TX. PRE-FIXADA

        END IF;

      ELSE -- POS

        IF rw_craplcr.dsoperac = 'EMPRESTIMO' THEN

          vr_hismult := 2348; -- APROPR. MULTA EMPRESTIMO POS FIXADO
          vr_hisjrmr := 2346; -- APROPR. JUROS DE MORA EMPRESTIMO POS FIXADO
          vr_hisjrem := 2342; -- APROPR. JUROS REMUNERATORIOS EMPRESTIMO POS FIXADO
          vr_hisjrco := 2344; -- APROPR. JUROS DE CORRECAO EMPRESTIMO POS FIXADO

        ELSE -- FINANCIAMENTO

          vr_hismult := 2349; -- APROPR. MULTA FINANCINANCIAMENTO POS FIXADO
          vr_hisjrmr := 2347; -- APROPR. JUROS DE MORA FINANCIAMENTO POS FIXADO
          vr_hisjrem := 2343; -- APROPR. JUROS REMUNERATORIOS FINANC. POS FIXADO
          vr_hisjrco := 2345; -- APROPR. JUROS DE CORRECAO FINANCIAMENTO POS FIXADO

        END IF;

      END IF;

      -- Gera o lançamento da multa
      IF nvl(pr_pgtmulta, 0) > 0 THEN
        BEGIN
          INSERT INTO tbepr_renegociacao_lancto(dtmvtolt
                                               ,nrdconta
                                               ,nrdocmto
                                               ,cdhistor
                                               ,nrctremp
                                               ,vllanmto
                                               ,cdcooper
                                               ,nrparepr
                                               )
                                         VALUES(pr_dtpagto
                                               ,pr_nrdconta
                                               ,0
                                               ,vr_hismult
                                               ,pr_nrctremp
                                               ,pr_pgtmulta
                                               ,pr_cdcooper
                                               ,0
                                               );
        EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao inserir na tbepr_renegociacao_lancto: ' || SQLERRM;
        END pc_grava_lcto_pgto;                  

        IF pr_cdcritic IS NOT NULL OR pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      
      END IF;
      
      -- Gera o lançamento do juros mora
      IF nvl(pr_pgtjurmr, 0) > 0 THEN
        BEGIN
          INSERT INTO tbepr_renegociacao_lancto(dtmvtolt
                                               ,nrdconta
                                               ,nrdocmto
                                               ,cdhistor
                                               ,nrctremp
                                               ,vllanmto
                                               ,cdcooper
                                               ,nrparepr
                                               )
                                         VALUES(pr_dtpagto
                                               ,pr_nrdconta
                                               ,0
                                               ,vr_hisjrmr
                                               ,pr_nrctremp
                                               ,pr_pgtjurmr
                                               ,pr_cdcooper
                                               ,0
                                               );
        EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao inserir na tbepr_renegociacao_lancto: ' || SQLERRM;
        END pc_grava_lcto_pgto;                  

        IF pr_cdcritic IS NOT NULL OR pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Gera o lançamento do juros remuneratorio
      IF nvl(pr_pgtjurem, 0) > 0 THEN                     
        BEGIN
          INSERT INTO tbepr_renegociacao_lancto(dtmvtolt
                                               ,nrdconta
                                               ,nrdocmto
                                               ,cdhistor
                                               ,nrctremp
                                               ,vllanmto
                                               ,cdcooper
                                               ,nrparepr
                                               )
                                         VALUES(pr_dtpagto
                                               ,pr_nrdconta
                                               ,0
                                               ,vr_hisjrem
                                               ,pr_nrctremp
                                               ,pr_pgtjurem
                                               ,pr_cdcooper
                                               ,0
                                               );
        EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao inserir na tbepr_renegociacao_lancto: ' || SQLERRM;
        END pc_grava_lcto_pgto;                  

        IF pr_cdcritic IS NOT NULL OR pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

      END IF;

    
    EXCEPTION
      WHEN vr_exc_erro THEN
        RETURN;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na pc_gera_lcto_pgto: ' || SQLERRM;
    END pc_gera_lcto_pgto1;
  BEGIN
    --
    --
    vr_pgtmulta := 0;
    vr_pgtjurmr := 0;
    vr_pgtjurem := 0;
    vr_pgtjurco := 0;
    vr_vldpagto := pr_vldpagto;
    --
    OPEN cr_saldo(pr_cdcooper
                 ,pr_nrdconta
                 ,pr_nrctremp
                 );
    --
    FETCH cr_saldo INTO rw_saldo;
    --
    CLOSE cr_saldo;
    -- Paga multa se tiver saldo

    OPEN cr_crapepr(pr_cdcooper
                   ,pr_nrdconta
                   ,pr_nrctremp
                   );
    FETCH cr_crapepr INTO rw_crapepr;
    CLOSE cr_crapepr;

  
    IF rw_saldo.sldmulta > 0 THEN
      --
      IF vr_vldpagto >= rw_saldo.sldmulta THEN
        --
        vr_pgtmulta := rw_saldo.sldmulta;
        vr_vldpagto := vr_vldpagto - rw_saldo.sldmulta;
        --
      ELSE
        --
        vr_pgtmulta := vr_vldpagto;
        vr_vldpagto := 0;
        --
      END IF;
      --
    END IF;
    -- Paga juros mora se tiver saldo
    IF rw_saldo.sldjurmr > 0 THEN
      --
      IF vr_vldpagto >= rw_saldo.sldjurmr THEN
        --
        vr_pgtjurmr := rw_saldo.sldjurmr;
        vr_vldpagto := vr_vldpagto - rw_saldo.sldjurmr;
        --
      ELSE
        --
        vr_pgtjurmr := vr_vldpagto;
        vr_vldpagto := 0;
        --
      END IF;
      --
    END IF;
    -- Paga juros remuneratorio se tiver saldo
    IF rw_saldo.sldjurem > 0 THEN
      --
      IF vr_vldpagto >= rw_saldo.sldjurem THEN
        --
        vr_pgtjurem := rw_saldo.sldjurem;
        vr_vldpagto := vr_vldpagto - rw_saldo.sldjurem;
        --
      ELSE
        --
        vr_pgtjurem := vr_vldpagto;
        vr_vldpagto := 0;
        --
      END IF;
      --
    END IF;
    -- Paga juros correcao se tiver saldo
    IF rw_saldo.sldjurco > 0 THEN
      --
      IF vr_vldpagto >= rw_saldo.sldjurco THEN
        --
        vr_pgtjurco := rw_saldo.sldjurco;
        vr_vldpagto := vr_vldpagto - rw_saldo.sldjurco;
        --
      ELSE
        --
        vr_pgtjurco := vr_vldpagto;
        vr_vldpagto := 0;
        --
      END IF;
      --
    END IF;
    --
    BEGIN
      --
      UPDATE tbepr_renegociacao_saldo trs
         SET trs.vlpgjr60 = decode(rw_crapepr.tpemprst, 1, (nvl(trs.vlpgjr60, 0) + vr_pgtjurem)
                                                      , 2, (nvl(trs.vlpgjr60, 0) + vr_pgtjurmr + vr_pgtjurem + vr_pgtjurco)
                                                      , trs.vlpgjr60)
            ,trs.vlpgjrem = nvl(trs.vlpgjrem, 0) + vr_pgtjurem
            ,trs.vlpgjrmr = nvl(trs.vlpgjrmr, 0) + vr_pgtjurmr
            ,trs.vlpgmult = nvl(trs.vlpgmult, 0) + vr_pgtmulta
          --,trs.vlpgjrco = nvl(trs.vlpgjrco, 0) + vr_pgtjurco
       WHERE trs.cdcooper = pr_cdcooper
         AND trs.nrdconta = pr_nrdconta
         AND trs.nrctremp = pr_nrctremp;
      --
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao atualizar a tbepr_renegociacao_saldo: ' || SQLERRM;
        RAISE vr_exc_erro;
    END;
    --
    --
    pc_gera_lcto_pgto1(pr_cdcooper => pr_cdcooper -- IN
                     ,pr_nrdconta => pr_nrdconta -- IN
                     ,pr_nrctremp => pr_nrctremp -- IN
                     ,pr_pgtmulta => vr_pgtmulta -- IN
                     ,pr_pgtjurmr => vr_pgtjurmr -- IN
                     ,pr_pgtjurem => vr_pgtjurem -- IN
                     ,pr_pgtjurco => vr_pgtjurco -- IN
                     ,pr_dtpagto => pr_dtpagto
                     ,pr_cdcritic => pr_cdcritic -- OUT
                     ,pr_dscritic => pr_dscritic -- OUT
                     );

    IF pr_cdcritic IS NOT NULL OR pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    --
  EXCEPTION
    WHEN vr_exc_erro THEN
      RETURN;
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na pc_paga_sld_ctr_renegociado: ' || SQLERRM;
  END pc_paga_sld_ctr_renegociado1;
  ---
  ---
  ---
  ---Recalcula Valor Juros após pagamentos de parcelas (New)
  PROCEDURE pc_atualiza_valor_59d1(pr_cdcooper IN  crapepr.cdcooper%TYPE
                                 ,pr_nrdconta IN  crapepr.nrdconta%TYPE
                                 ,pr_nrctremp IN  crapepr.nrctremp%TYPE
                                 ,pr_cdcritic OUT INTEGER
                                 ,pr_dscritic OUT VARCHAR2
                                 ) IS

    CURSOR cr_crapepr(pr_cdcooper crapepr.cdcooper%TYPE
                     ,pr_nrdconta crapepr.nrdconta%TYPE
                     ,pr_nrctremp crapepr.nrctremp%TYPE
                     ) IS
      SELECT epr.tpemprst
            ,epr.tpdescto
        FROM crapepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp;

    CURSOR cr_parc_aberto(pr_cdcooper crappep.cdcooper%TYPE
                         ,pr_nrdconta crappep.nrdconta%TYPE
                         ,pr_nrctremp crappep.nrctremp%TYPE
                         ,pr_dtmvtolt crapdat.dtmvtolt%TYPE
                         ) IS
        SELECT MIN(pep.dtvencto) dtvencto
          FROM crappep pep
         WHERE (pep.inliquid = 0 OR pep.inprejuz = 1)
           AND pep.dtvencto <= pr_dtmvtolt
           AND pep.cdcooper  = pr_cdcooper
           AND pep.nrdconta  = pr_nrdconta
           AND pep.nrctremp  = pr_nrctremp;

    CURSOR cr_saldo(pr_cdcooper tbepr_renegociacao_saldo.cdcooper%TYPE
                   ,pr_nrdconta tbepr_renegociacao_saldo.nrdconta%TYPE
                   ,pr_nrctremp tbepr_renegociacao_saldo.nrctremp%TYPE
                   ) IS
      SELECT trs.vljura60 - trs.vlpgjr60 vljura60
        FROM tbepr_renegociacao_saldo trs
       WHERE trs.cdcooper = pr_cdcooper
         AND trs.nrdconta = pr_nrdconta
         AND trs.nrctremp = pr_nrctremp;

    rw_crapepr         cr_crapepr%ROWTYPE;
    rw_crapdat         btch0001.cr_crapdat%ROWTYPE;
    vr_tab_pgto_parcel empr0001.typ_tab_pgto_parcel; --> Tabela com registros de pagamentos
    vr_tab_calculado   empr0001.typ_tab_calculado;   --> Tabela com totais calculados
    vr_dtvencto        crappep.dtvencto%TYPE;
    vr_dtmvtolt        crapdat.dtmvtolt%TYPE;
    vr_dtmvtoan        crapdat.dtmvtoan%TYPE;
    vr_vljura60        tbepr_renegociacao_saldo.vljura60%TYPE;
    vr_vlparc59        crappep.vljura60%TYPE;
    vr_qtdias59        NUMBER;
    vr_des_reto        VARCHAR(4000);
    vr_tab_erro        GENE0001.typ_tab_erro;
    vr_exc_erro        EXCEPTION;

  BEGIN
    vr_tab_erro.DELETE;
    vr_tab_pgto_parcel.DELETE;

    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    OPEN cr_crapepr(pr_cdcooper
                   ,pr_nrdconta
                   ,pr_nrctremp
                   );
    FETCH cr_crapepr INTO rw_crapepr;
    CLOSE cr_crapepr;

    OPEN cr_saldo(pr_cdcooper
                 ,pr_nrdconta
                 ,pr_nrctremp
                 );
    FETCH cr_saldo INTO vr_vljura60;
    CLOSE cr_saldo;

    -- Apenas PP, exceto consignado
    IF (rw_crapepr.tpemprst = 1 AND rw_crapepr.tpdescto <> 2) AND nvl(vr_vljura60, 0) = 0 THEN
      -- Calculo do Juros+60
      
      --TROCADO PELA ROTINA DO JAMES
      EMPR9999.pc_calcula_juros_59_pp_baca(pr_cdcooper => pr_cdcooper                                      
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_nrctremp => pr_nrctremp
                                          ,pr_nrparepr => 0
                                          ,pr_tab_erro => vr_tab_erro
                                          ,pr_tab_pgto_parcel => vr_tab_pgto_parcel);  

      -- Condicao para verificar se tem erro
      IF vr_tab_erro.exists(vr_tab_erro.first) THEN
        pr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        pr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        -- Gera exceção
        RAISE vr_exc_erro;
      END IF;

      IF vr_tab_pgto_parcel.count > 0 THEN
        FOR indx IN vr_tab_pgto_parcel.FIRST .. vr_tab_pgto_parcel.LAST LOOP
          -- Não precisa calcular para as parcelas pagas
          IF nvl(vr_tab_pgto_parcel(indx).vlatupar, 0) > 0 THEN
            BEGIN
              UPDATE crappep pep
                 SET pep.vljura60 = nvl(vr_tab_pgto_parcel(indx).vlatupar,0)
               WHERE pep.cdcooper = pr_cdcooper
                 AND pep.nrdconta = pr_nrdconta
                 AND pep.nrctremp = pr_nrctremp
                 AND pep.nrparepr = vr_tab_pgto_parcel(indx).nrparepr;
            EXCEPTION
              WHEN OTHERS THEN
                pr_cdcritic := 0;
                pr_dscritic := 'Erro ao atualizar a crappep: ' || SQLERRM;
                RAISE vr_exc_erro;
            END;

          END IF;

        END LOOP;

      END IF;

    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      RETURN;
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro empr0021.pc_atualiza_valor_59d: ' || SQLERRM;
  END pc_atualiza_valor_59d1;
  ---
BEGIN
  --Imprime Mensagem de Início de Execução
  dbms_output.put_line('Início Execução: '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));
  
  --Para Registro com Valor Negativo
  FOR rw_reneg_saldo_jurneg IN cr_reneg_saldo_jurneg LOOP         
    --Incrementa a Qtde de Registros Lidos
    vr_qt_lido := Nvl(vr_qt_lido,0) + 1;
    
    --Inicializa Variáveis
    vr_vljuremutt := 0;
    vr_vliofcpltt := 0;
    vr_vlmtapartt := 0;
    vr_vlmrapartt := 0;
    vr_cdcritic   := NULL;
    vr_dscritic   := NULL;
    --
    w_dtmvtolt := null;
    w_dtmvtoan := null; 
    --
    --Busca a Data de Liberação da Renegociação (Efetivação) para levar em conta no calculo dos Juros            
    BEGIN
      SELECT dtmvtolt 
      INTO   w_dtmvtolt
      from   crapepr  --Novo contrato (Data Efetivação da Renegociação)
      WHERE  cdcooper = rw_reneg_saldo_jurneg.cdcooper
      AND    nrdconta = rw_reneg_saldo_jurneg.nrdconta 
      AND    nrctremp = rw_reneg_saldo_jurneg.nrctremp;
    EXCEPTION
      WHEN OTHERS THEN
         vr_cdcritic := 0;
         vr_dscritic := 'Erro ao Buscar Data Efetivação da Renegociação(2). Erro: '||SubStr(SQLERRM,1,255);
         RAISE vr_erro;
    END; 
    
    -- Funcao para calcular o dia uitl anterior (Data Anterior Ultil a Efetivação da Renegociação)
    w_dtmvtoan := gene0005.fn_valida_dia_util(pr_cdcooper => rw_reneg_saldo_jurneg.cdcooper, 
                                              pr_dtmvtolt => w_dtmvtolt - 1, 
                                              pr_tipo => 'A');
    --         
    --Busca Menor Data de Vencimento da Parcela 
    OPEN cr_crappep_maior_carga(rw_reneg_saldo_jurneg.cdcooper
                               ,rw_reneg_saldo_jurneg.nrdconta
                               ,rw_reneg_saldo_jurneg.nrctremp
                               ,w_dtmvtolt);
    FETCH cr_crappep_maior_carga INTO rw_crappep_maior_carga;
    CLOSE cr_crappep_maior_carga;             
   
    --Qtde Dias Atraso
    vr_qtdiaatr := 0; 
    IF rw_crappep_maior_carga.dtvencto IS NOT NULL THEN
      --Data Atual - Menor Data de Vencimento da Parcela
      vr_qtdiaatr := w_dtmvtolt - rw_crappep_maior_carga.dtvencto;
    END IF;
    
    --Se a Qtede de Dias de Atraso é Maior/Igual a 60 Dias  
    IF Nvl(vr_qtdiaatr,0) >= 60  THEN
      --Busca Valores Atualizados das Parcelas Não Liquidadas
      --novo (local)
      pc_busca_pgto_parcelas(pr_cdcooper        => rw_reneg_saldo_jurneg.cdcooper
                           ,pr_cdagenci        => 1 
                           ,pr_nrdcaixa        => 1 
                           ,pr_cdoperad        => 1 
                           ,pr_nmdatela        => 'ATENDA' 
                           ,pr_idorigem        => 5 
                           ,pr_nrdconta        => rw_reneg_saldo_jurneg.nrdconta
                           ,pr_idseqttl        => 1 
                           ,pr_dtmvtolt        => w_dtmvtolt
                           ,pr_flgerlog        => 'N' 
                           ,pr_nrctremp        => rw_reneg_saldo_jurneg.nrctremp
                           ,pr_dtmvtoan        => w_dtmvtoan
                           ,pr_nrparepr        => 0
                           ,pr_des_reto        => vr_des_reto
                           ,pr_tab_erro        => vr_tab_erro
                           ,pr_tab_pgto_parcel => vr_tab_pgto_parcel
                           ,pr_tab_calculado   => vr_tab_calculado);
      IF vr_des_reto = 'NOK' THEN           
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;    
        RAISE vr_erro;
      END IF;
        
      --Calcula Valores                           
      vr_indice := vr_tab_pgto_parcel.FIRST;
      WHILE vr_indice IS NOT NULL LOOP
        --Buscar Valor Juro60 de cada Parcela
        OPEN cr_crappep(pr_cdcooper => vr_tab_pgto_parcel(vr_indice).cdcooper
                       ,pr_nrdconta => vr_tab_pgto_parcel(vr_indice).nrdconta
                       ,pr_nrctremp => vr_tab_pgto_parcel(vr_indice).nrctremp
                       ,pr_nrparepr => vr_tab_pgto_parcel(vr_indice).nrparepr);
        FETCH cr_crappep INTO rw_crappep;
        CLOSE cr_crappep;
          
        --Valor Juros60         
        IF Nvl(vr_tab_pgto_parcel(vr_indice).vlatupar,0) < Nvl(rw_crappep.vljura60,0) THEN 
          rw_crappep.vljura60 := Nvl(vr_tab_pgto_parcel(vr_indice).vlatupar,0);
        END IF; 
        --Calcula somente Juros60
        vr_vljuremutt := Nvl(vr_vljuremutt,0) + Nvl(vr_tab_pgto_parcel(vr_indice).vlatupar,0) - Nvl(rw_crappep.vljura60,0);           
        --
        vr_vliofcpltt := nvl(vr_vliofcpltt,0) + NVL(vr_tab_pgto_parcel(vr_indice).vliofcpl,0);
        vr_vlmtapartt := nvl(vr_vlmtapartt,0) + NVL(vr_tab_pgto_parcel(vr_indice).vlmtapar,0);
        vr_vlmrapartt := nvl(vr_vlmrapartt,0) + NVL(vr_tab_pgto_parcel(vr_indice).vlmrapar,0);          
        vr_indice     := vr_tab_pgto_parcel.NEXT(vr_indice);
      END LOOP; 
                        
    END IF;

    
    --Se o valor de Juros Calculado for Negativo ou Zero
    IF Nvl(vr_vljuremutt,0) < 0 THEN
      --Mostra Mensagem e Aborta a execução
      vr_ds_erro := 'Valor Calculado de Juros é Negativo ('||Nvl(vr_vljuremutt,0)||'). Cooper: '||rw_reneg_saldo_jurneg.cdcooper||' | Conta: '||rw_reneg_saldo_jurneg.nrdconta||' | Contrato: '||rw_reneg_saldo_jurneg.nrctremp||'.';
      RAISE vr_erro;
    END IF;
    
    --Mensagens ????? Comentar depois as mensagens   
    /* 
    IF  Nvl(vr_qt_lido,0) = 1 THEN       
      dbms_output.put_line(' ');
      dbms_output.put_line('Tipo;Cooperativa;Conta;Contrato;vljura60_old;vljura60_new;vljuremu_old;vljuremu_new;vlpgjr60_old;vlpgjr60_new;vlpgjrem_old;vlpgjrem_new');            
    END IF; 
    */
    --Fim Mensagens ????? Comentar depois as mensagens
    
    --Se o Novo Valor de Juros+60 Calculo é Diferente do Valor que está na Base de Dados (Altera tabela)
    IF (Nvl(vr_vljuremutt,0) <> Nvl(rw_reneg_saldo_jurneg.vljura60,0)) 
      OR (Nvl(vr_vljuremutt,0) <> Nvl(rw_reneg_saldo_jurneg.vljuremu,0)) THEN
      
        --Incrementa Qtde Diferentes
        vr_qt_diferente := Nvl(vr_qt_diferente,0) + 1;                    
                             
        --Atualiza Valores Recalculados na Tabela de Renegociação Saldo
        BEGIN
          UPDATE tbepr_renegociacao_saldo  trs
          SET    trs.vljura60   = Nvl(vr_vljuremutt,0)
                ,trs.vljuremu   = Nvl(vr_vljuremutt,0)                                  
          WHERE  trs.cdcooper = rw_reneg_saldo_jurneg.cdcooper
          AND    trs.nrdconta = rw_reneg_saldo_jurneg.nrdconta         
          AND    trs.nrctremp = rw_reneg_saldo_jurneg.nrctremp;
        EXCEPTION
          WHEN OTHERS THEN
            vr_ds_erro := 'Erro ao Atualizar Renegociação Saldo (tbepr_renegociacao_saldo). Cooper: '||rw_reneg_saldo_jurneg.cdcooper||' | Conta: '||rw_reneg_saldo_jurneg.nrdconta||' | Contrato: '||rw_reneg_saldo_jurneg.nrctremp||'. Erro: '||SubStr(SQLERRM,1,255);
            RAISE vr_erro;
        END;  
        
        --Incrementa a Qtde de Registros Alterados
        IF SQL%ROWCOUNT > 0 THEN
          vr_qt_alterado := Nvl(vr_qt_alterado,0) + SQL%ROWCOUNT;
        END IF;

        ----------------------------------------------------------------------------------------------
        --Atualizar Pagamentos Juros (New)
        --A tabela tbepr_renegociacao_lancto só é utlizada para fazer o estorno da renegociação.
        vr_qt_pagtos := 0;
        vr_vlpgjr60  := 0;
        vr_vlpgjrem  := 0;
        --
        --Para cada Pagamento (lançado na craplem)
        FOR rw_pagamentos IN cr_pagamentos(pr_cdcooper => rw_reneg_saldo_jurneg.cdcooper
                                          ,pr_nrdconta => rw_reneg_saldo_jurneg.nrdconta
                                          ,pr_nrctremp => rw_reneg_saldo_jurneg.nrctremp) LOOP
                                          
          vr_qt_pagtos := Nvl(vr_qt_pagtos,0) + 1;
          
          IF Nvl(vr_qt_pagtos,0) = 1 THEN                                    
            --Limpa o valor de pagamentos de juros para refazer abaixo                                      
            BEGIN
              UPDATE tbepr_renegociacao_saldo trs
              SET    trs.vlpgjr60 = 0
                    ,trs.vlpgjrem = 0
                    ,trs.vlpgmult = 0
                    ,trs.vlpgjrmr = 0
              WHERE  trs.cdcooper = rw_reneg_saldo_jurneg.cdcooper
              AND    trs.nrdconta = rw_reneg_saldo_jurneg.nrdconta
              AND    trs.nrctremp = rw_reneg_saldo_jurneg.nrctremp;
            EXCEPTION
              WHEN OTHERS THEN
                vr_ds_erro := 'Erro ao Limpar Valor Pagto Juros da Renegociação Saldo (tbepr_renegociacao_saldo). Cooper: '||rw_reneg_saldo_jurneg.cdcooper||' | Conta: '||rw_reneg_saldo_jurneg.nrdconta||' | Contrato: '||rw_reneg_saldo_jurneg.nrctremp||'. Erro: '||SubStr(SQLERRM,1,255);
                RAISE vr_erro;
            END;  
            
            --Exclui lançamentos de pagamentos de juros para refazer abaixo
            BEGIN
              DELETE tbepr_renegociacao_lancto trl
              WHERE  trl.cdcooper = rw_reneg_saldo_jurneg.cdcooper
              AND    trl.nrdconta = rw_reneg_saldo_jurneg.nrdconta
              AND    trl.nrctremp = rw_reneg_saldo_jurneg.nrctremp
              AND    trl.nrdocmto = 0 --Fixo
              AND    trl.cdhistor IN (1037,1038   -- APROPRIACAO JUROS CONTRATO EMPR. TX. PRE-FIXADA (Financimanto ou Empréstimo)
                                     ,3051,3053   -- MULTA EMPRESTIMO PRE-FIXADO (Financimanto ou Empréstimo)
                                     ,3052,3054); -- JURO MORA EMPRESTIMO PRE-FIXADO (Financimanto ou Empréstimo)
            EXCEPTION
              WHEN OTHERS THEN
                vr_ds_erro := 'Erro ao Excluir Lançamentos de Pagto Juros na Renegociação Saldo (tbepr_renegociacao_saldo). Cooper: '||rw_reneg_saldo_jurneg.cdcooper||' | Conta: '||rw_reneg_saldo_jurneg.nrdconta||' | Contrato: '||rw_reneg_saldo_jurneg.nrctremp||'. Erro: '||SubStr(SQLERRM,1,255);
                RAISE vr_erro;
            END;
          END IF;         
                                                          
          --Atualiza Valor Pago Juros e Gera lançamentos na  tbepr_renegociacao_lancto                              
          pc_paga_sld_ctr_renegociado1(pr_cdcooper => rw_pagamentos.cdcooper
                                      ,pr_nrdconta => rw_pagamentos.nrdconta
                                      ,pr_nrctremp => rw_pagamentos.nrctremp
                                      ,pr_vldpagto => rw_pagamentos.vllanmto
                                      ,pr_dtpagto  => rw_pagamentos.dtmvtolt
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_erro;
          END IF;                             
        END LOOP; --Pagamentos
      
        -- Atualiza valor 59 dias  (DENTRO DESTA É CHAMADO A ROTINA DO JAMES ___59D_BACA)
        --Segundo James aqui refaz os valores de juros60 na crappep
        pc_atualiza_valor_59d1(pr_cdcooper => rw_reneg_saldo_jurneg.cdcooper 
                              ,pr_nrdconta => rw_reneg_saldo_jurneg.nrdconta
                              ,pr_nrctremp => rw_reneg_saldo_jurneg.nrctremp 
                              ,pr_cdcritic => vr_cdcritic 
                              ,pr_dscritic => vr_dscritic);                              
        IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_erro;
        END IF;   
        
        --Se refez a soma dos pagamentos dos juros na tbepr_renegociacao_saldo
        IF Nvl(vr_qt_pagtos,0) >= 1 THEN
          --Busca novo Valor de Juros Pagos (atuaizados acima)
          BEGIN
            SELECT trs.vlpgjr60
                  ,trs.vlpgjrem
            INTO   vr_vlpgjr60
                  ,vr_vlpgjrem
            FROM   tbepr_renegociacao_saldo trs      
            WHERE  trs.cdcooper = rw_reneg_saldo_jurneg.cdcooper
            AND    trs.nrdconta = rw_reneg_saldo_jurneg.nrdconta
            AND    trs.nrctremp = rw_reneg_saldo_jurneg.nrctremp;
          EXCEPTION
            WHEN OTHERS THEN
              vr_ds_erro := 'Erro ao Buscar Valor Pago Juros da Renegociação Saldo (tbepr_renegociacao_saldo). Cooper: '||rw_reneg_saldo_jurneg.cdcooper||' | Conta: '||rw_reneg_saldo_jurneg.nrdconta||' | Contrato: '||rw_reneg_saldo_jurneg.nrctremp||'. Erro: '||SubStr(SQLERRM,1,255);
              RAISE vr_erro;
          END;
        --Se não refez  
        ELSE
          --Popula as variaveis com o valor que já estava na tbepr_renegociacao_saldo
          vr_vlpgjr60 := rw_reneg_saldo_jurneg.vlpgjr60;
          vr_vlpgjrem := rw_reneg_saldo_jurneg.vlpgjrem;
        END IF;  
        --Fim Atualizar Pagamentos (New) 
        ----------------------------------------------------------------------------------------------
 
        --Mensagens ????? Comentar depois as mensagens
        /*
        dbms_output.put_line('Diferente'||';'||
                             rw_reneg_saldo_jurneg.cdcooper||';'||
                             rw_reneg_saldo_jurneg.nrdconta||';'||
                             rw_reneg_saldo_jurneg.nrctremp||';'||  
                             Nvl(rw_reneg_saldo_jurneg.vljura60,0)||';'||
                             Nvl(vr_vljuremutt,0)||';'||
                             Nvl(rw_reneg_saldo_jurneg.vljuremu,0)||';'||
                             Nvl(vr_vljuremutt,0)||';'||
                             Nvl(rw_reneg_saldo_jurneg.vlpgjr60,0)||';'||
                             Nvl(vr_vlpgjr60,0)||';'||
                             Nvl(rw_reneg_saldo_jurneg.vlpgjrem,0)||';'||
                             Nvl(vr_vlpgjrem,0));  
        */                                        
        --Fim Mensagens ????? Comentar depois as mensagens 
        
      --Se o Novo Valor de Juros+60 Calculo é Igual ao Valor que já está na Base de Dados (Não altera tabela)                    
      ELSE
        
        --Incrementa Qtde Iguais
        vr_qt_igual := Nvl(vr_qt_igual,0) + 1;
        
        --Mensagens ????? Comentar depois as mensagens
        /*
        dbms_output.put_line('Igual'||';'||
                             rw_reneg_saldo_jurneg.cdcooper||';'||
                             rw_reneg_saldo_jurneg.nrdconta||';'||
                             rw_reneg_saldo_jurneg.nrctremp||';'||  
                             Nvl(rw_reneg_saldo_jurneg.vljura60,0)||';'||
                             Nvl(vr_vljuremutt,0)||';'||
                             Nvl(rw_reneg_saldo_jurneg.vljuremu,0)||';'||
                             Nvl(vr_vljuremutt,0)||';'||
                             Nvl(rw_reneg_saldo_jurneg.vlpgjr60,0)||';'||
                             Nvl(rw_reneg_saldo_jurneg.vlpgjr60,0)||';'||
                             Nvl(rw_reneg_saldo_jurneg.vlpgjrem,0)||';'||
                             Nvl(rw_reneg_saldo_jurneg.vlpgjrem,0)); 
        */                                       
        --Fim Mensagens ????? Comentar depois as mensagens                     
    END IF;  
    --   
  END LOOP; --Renegociações
  
  --Imprime Mensagens de Qtdes
  dbms_output.put_line(' ');
  dbms_output.put_line(Lpad(vr_qt_lido,6,0)     ||' Registro(s) Lido(s)');
  dbms_output.put_line(Lpad(vr_qt_diferente,6,0)||' Registro(s) Diferente(s)');
  dbms_output.put_line(Lpad(vr_qt_igual,6,0)    ||' Registro(s) Igual(s)');
  dbms_output.put_line(Lpad(vr_qt_alterado,6,0) ||' Registro(s) Alterado(s)');
  
  --Imprime Mensagem de Fim de Execução
  dbms_output.put_line(' ');
  dbms_output.put_line('Fim Execução: '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));
  
  --Salva  
  COMMIT;
  
EXCEPTION
  WHEN vr_erro THEN
    dbms_output.put_line(vr_ds_erro||' '||vr_dscritic);
    ROLLBACK;
    Raise_Application_Error(-20000,vr_ds_erro);
  WHEN OTHERS THEN
    dbms_output.put_line('Erro Geral no Script de Correção Juros60 - Renegociação. Erro: '||SubStr(SQLERRM,1,255));
    ROLLBACK;
    Raise_Application_Error(-20001,'Erro Geral no Script de Correção Juros60 - Renegociação. Erro: '||SubStr(SQLERRM,1,255));
END;
/
