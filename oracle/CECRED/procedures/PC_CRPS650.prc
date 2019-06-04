CREATE OR REPLACE PROCEDURE PC_CRPS650(pr_cdcooper  IN crapcop.cdcooper%TYPE    --> COOPERATIVA SOLICITADA
                                      ,pr_cdoperad  IN crapope.cdoperad%TYPE    --> OPERADOR DA SOLICITAÇÃO
                                      ,pr_flgresta  IN PLS_INTEGER              --> FLAG PADRÃO PARA UTILIZAÇÃO DE RESTART
                                      ,pr_stprogra OUT PLS_INTEGER              --> SAÍDA DE TERMINO DA EXECUÇÃO
                                      ,pr_infimsol OUT PLS_INTEGER              --> SAÍDA DE TERMINO DA SOLICITAÇÃO
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE    --> CRITICA ENCONTRADA
                                      ,pr_dscritic OUT VARCHAR2) IS             --> TEXTO DE ERRO/CRITICA ENCONTRADA IS

  /* ............................................................................

     Programa: fontes/crps650.p
     Sistema : MITRA - GERACAO DE ARQUIVO
     Sigla   : CRED
     Autor   : Renato Darosci
     Data    : Maio/2019                       Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Diaria.
     Objetivo  : Gerar diariamente para o sistema MITRA as informaçőes
                 referentes as aplicaçőes e operaçőes de credito feitas pelas
                 singulares na sua conta na central AILOS.
     Alteracoes:
                 03/05/2019 - Conversão Progress >> PLSQL (Renato - Supero).

  ............................................................................. */

  -- Definição de tipos utilizados na rotina
  TYPE typ_rec_datas_parcelas IS RECORD (nrparepr  NUMBER
                                        ,dtparepr  DATE);
  TYPE typ_tab_datas_parcelas IS TABLE OF typ_rec_datas_parcelas INDEX BY BINARY_INTEGER;
  -- Todos os dados serão varchar... pois será escrito em um csv
  TYPE typ_rec_dados_mitra IS RECORD (identificacao                  VARCHAR2(100)
                                     ,nome                           VARCHAR2(100)
                                     ,carteira                       VARCHAR2(100)
                                     ,corretora                      VARCHAR2(100)
                                     ,data_entrada                   VARCHAR2(100)
                                     ,descricao                      VARCHAR2(100)
                                     ,agrupamento                    VARCHAR2(100)
                                     ,quantidade                     VARCHAR2(100)
                                     ,pu                             VARCHAR2(100)
                                     ,corretagem                     VARCHAR2(100)
                                     ,emolumento                     VARCHAR2(100)
                                     ,rebate                         VARCHAR2(100)
                                     ,cpmf                           VARCHAR2(100)
                                     ,outras_despesas                VARCHAR2(100)
                                     ,inicio                         VARCHAR2(100)
                                     ,vencimento                     VARCHAR2(100)
                                     ,valor                          VARCHAR2(100)
                                     ,taxa                           VARCHAR2(100)
                                     ,taxa_registro                  VARCHAR2(100)
                                     ,porc_index                     VARCHAR2(100)
                                     ,contraparte                    VARCHAR2(100)
                                     ,impostos                       VARCHAR2(100)
                                     ,taxa_a                         VARCHAR2(100)
                                     ,taxa_p                         VARCHAR2(100)
                                     ,porc_index_a                   VARCHAR2(100)
                                     ,porc_index_p                   VARCHAR2(100)
                                     ,tipo_marcacao                  VARCHAR2(100)
                                     ,tipo_marcacao_a                VARCHAR2(100)
                                     ,tipo_marcacao_p                VARCHAR2(100)
                                     ,tipo_marcacao_stock            VARCHAR2(100)
                                     ,cotacao_base                   VARCHAR2(100)
                                     ,data_lancamento                VARCHAR2(100)
                                     ,gerar_provisao                 VARCHAR2(100)
                                     ,id                             VARCHAR2(100)
                                     ,codigo                         VARCHAR2(100)
                                     ,lastro                         VARCHAR2(100)
                                     ,cupom_operacao                 VARCHAR2(100)
                                     ,cupom_pol                      VARCHAR2(100)
                                     ,porc_index_pol                 VARCHAR2(100)
                                     ,tipo_marcacao_pol              VARCHAR2(100)
                                     ,tipo_marcacao_tes_pol          VARCHAR2(100)
                                     ,porc_rebate                    VARCHAR2(100)
                                     ,indexador                      VARCHAR2(100)
                                     ,contrato                       VARCHAR2(100)
                                     ,parcela                        VARCHAR2(100)
                                     ,correcao                       VARCHAR2(100)
                                     ,juros                          VARCHAR2(100)
                                     ,tarifas                        VARCHAR2(100)
                                     ,mora                           VARCHAR2(100)
                                     ,resgate_total                  VARCHAR2(100)
                                     ,limite_conta                   VARCHAR2(100)
                                     ,n_agencia                      VARCHAR2(100)
                                     ,n_conta_corrente               VARCHAR2(100)
                                     ,taxa_adp                       VARCHAR2(100)
                                     ,iof                            VARCHAR2(100)
                                     ,data_saldo                     VARCHAR2(100)
                                     ,data_encerramento              VARCHAR2(100)
                                     ,data_abertura                  VARCHAR2(100)
                                     ,cupom_pol_a                    VARCHAR2(100)
                                     ,cupom_pol_p                    VARCHAR2(100)
                                     ,porc_index_pol_a               VARCHAR2(100)
                                     ,porc_index_pol_p               VARCHAR2(100)
                                     ,pu_politica                    VARCHAR2(100)
                                     ,financeiro_liquido             VARCHAR2(100)
                                     ,cambio_base                    VARCHAR2(100)
                                     ,cambio_base_a                  VARCHAR2(100)
                                     ,cambio_base_p                  VARCHAR2(100)
                                     ,tipo_calculo_bacen             VARCHAR2(100)
                                     ,data_boletagem                 VARCHAR2(100)
                                     ,garantia_imobiliaria           VARCHAR2(100)
                                     ,valor_mitigador                VARCHAR2(100)
                                     ,data_aplicacao_inicial         VARCHAR2(100)
                                     ,status_quantidade              VARCHAR2(100)
                                     ,status_recurso                 VARCHAR2(100)
                                     ,pu_referencia                  VARCHAR2(100)
                                     ,volatilidade                   VARCHAR2(100)
                                     ,tipo_modalidade_operacao       VARCHAR2(100)
                                     ,tipo_calculo_modalidade        VARCHAR2(100)
                                     ,tipo_marcacao_modalidade       VARCHAR2(100)
                                     ,fator_mitigador                VARCHAR2(100)
                                     ,gerar_lancamento_automatico    VARCHAR2(100)
                                     ,cenario                        VARCHAR2(100)
                                     ,estrategia_1                   VARCHAR2(100)
                                     ,estrategia_2                   VARCHAR2(100)
                                     ,estrategia_3                   VARCHAR2(100)
                                     ,eh_clearing                    VARCHAR2(100)
                                     ,pu_a                           VARCHAR2(100)
                                     ,pu_p                           VARCHAR2(100)
                                     ,juros_a                        VARCHAR2(100)
                                     ,juros_p                        VARCHAR2(100)
                                     ,correcao_a                     VARCHAR2(100)
                                     ,correcao_p                     VARCHAR2(100)
                                     ,moeda2                         VARCHAR2(100)
                                     ,tratamento_moeda               VARCHAR2(100)
                                     ,tratamento_moeda2              VARCHAR2(100)
                                     ,tipo_marcacao_moeda2           VARCHAR2(100)
                                     ,vencimento_moeda2              VARCHAR2(100)
                                     ,tipo_posicao_operacao          VARCHAR2(100)
                                     ,status_operacao                VARCHAR2(100)
                                     ,metodo_desconto_mtm            VARCHAR2(100)
                                     ,modalidade_liquidacao          VARCHAR2(100)
                                     ,amortizacao                    VARCHAR2(100)
                                     ,saldo_devedor                  VARCHAR2(100)
                                     ,inicio_juros                   VARCHAR2(100)
                                     ,inicio_correcao                VARCHAR2(100)
                                     ,paga_amortizacao               VARCHAR2(100)
                                     ,paga_juros                     VARCHAR2(100)
                                     ,paga_correcao                  VARCHAR2(100)
                                     ,forma_aplicacao_juros          VARCHAR2(100)
                                     ,forma_aplicacao_correcao       VARCHAR2(100)
                                     ,tratamento                     VARCHAR2(100)
                                     ,pu_financeiro                  VARCHAR2(100)
                                     ,informa1                       VARCHAR2(100)
                                     ,informa2                       VARCHAR2(100)
                                     ,informa3                       VARCHAR2(100)
                                     ,informa4                       VARCHAR2(100)
                                     ,informa5                       VARCHAR2(100)
                                     ,financeiro_contabil_bruto      VARCHAR2(100)
                                     ,financeiro_contabil_provisao   VARCHAR2(100)
                                     ,taxa_base                      VARCHAR2(100)
                                     ,cambio_conversao_inicio        VARCHAR2(100)
                                     ,inicio_juros_a                 VARCHAR2(100)
                                     ,inicio_juros_p                 VARCHAR2(100)
                                     ,inicio_correcao_a              VARCHAR2(100)
                                     ,inicio_correcao_p              VARCHAR2(100)
                                     ,tratamento_a                   VARCHAR2(100)
                                     ,tratamento_p                   VARCHAR2(100)
                                     ,forma_aplicacao_juros_a        VARCHAR2(100)
                                     ,forma_aplicacao_juros_p        VARCHAR2(100)
                                     ,paga_juros_a                   VARCHAR2(100)
                                     ,paga_juros_p                   VARCHAR2(100)
                                     ,forma_aplicacao_correcao_a     VARCHAR2(100)
                                     ,forma_aplicacao_correcao_p     VARCHAR2(100)
                                     ,paga_correcao_a                VARCHAR2(100)
                                     ,paga_correcao_p                VARCHAR2(100)
                                     ,taxa_base_a                    VARCHAR2(100)
                                     ,taxa_base_p                    VARCHAR2(100)
                                     ,taxa_oper_a                    VARCHAR2(100)
                                     ,taxa_oper_p                    VARCHAR2(100)
                                     ,cambio_conversao_inicio_a      VARCHAR2(100)
                                     ,cambio_conversao_inicio_p      VARCHAR2(100)
                                     ,descricao_contrato             VARCHAR2(100)
                                     ,nome_visual_contrato           VARCHAR2(100)
                                     ,codigo_isin                    VARCHAR2(100)
                                     ,codigo_selic                   VARCHAR2(100)
                                     ,moeda_liquidacao               VARCHAR2(100)
                                     ,defasagem_moeda_liquidacao     VARCHAR2(100)
                                     ,tipo_dias_defas_liquidacao     VARCHAR2(100)
                                     ,tipo_evento                    VARCHAR2(100)
                                     ,moeda_conversao                VARCHAR2(100)
                                     ,defasagem_moed_conversao       VARCHAR2(100)
                                     ,tipo_dias_defa_conversao       VARCHAR2(100)
                                     ,moeda_conversao_a              VARCHAR2(100)
                                     ,defasagem_moeda_conversao_a    VARCHAR2(100)
                                     ,tipo_dias_defa_conversao_a     VARCHAR2(100)
                                     ,moeda_conversao_p              VARCHAR2(100)
                                     ,defasagem_moeda_conversao_p    VARCHAR2(100)
                                     ,tipo_dias_defa_conversao_p     VARCHAR2(100)
                                     ,data_incorporacao              VARCHAR2(100)
                                     ,incorpora_juros                VARCHAR2(100)
                                     ,incorpora_correcao             VARCHAR2(100)
                                     ,id_controle                    VARCHAR2(100)
                                     ,id_sistema                     VARCHAR2(100)
                                     ,data_referencia                VARCHAR2(100)
                                     ,id_connected                   VARCHAR2(100)
                                     ,id_cliente                     VARCHAR2(100)
                                     ,id_execucao                    VARCHAR2(100)
                                     ,data_evento                    VARCHAR2(100)
                                     ,saldo_devedor_evento           VARCHAR2(100)
                                     ,tipo_pagamento                 VARCHAR2(100));
  TYPE typ_tab_dados_mitra IS TABLE OF typ_rec_dados_mitra INDEX BY BINARY_INTEGER;
  
  ------------------------------- CURSORES ---------------------------------
  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
         , cop.nmrescop
         , cop.nmextcop
      FROM crapcop cop
     WHERE cop.cdcooper = 3; -- Roda para a central
  rw_crapcop     cr_crapcop%ROWTYPE;
  
  -- Buscar os dados do cadastro de pessoas jurídicas
  CURSOR cr_crapjur IS 
    SELECT jur.cdcooper
         , jur.nrdconta
         , jur.nmfansia
      FROM crapjur jur 
     WHERE jur.cdcooper = pr_cdcooper 
       AND jur.nrdconta NOT IN (820024,850004); -- nao ler as contas da CECRED
  
  -- Buscar os dados de contrato de limite de crédito 
  CURSOR cr_craplim(pr_cdcooper   craplim.cdcooper%TYPE
                   ,pr_nrdconta   craplim.nrdconta%TYPE) IS
    SELECT lim.cdcooper
         , lim.nrdconta
         , lim.dtinivig
         , lim.qtdiavig
         , lim.vllimite
         , lim.cddlinha
         , lim.nrctrlim
      FROM craplim lim
     WHERE lim.cdcooper = pr_cdcooper 
       AND lim.nrdconta = pr_nrdconta 
       AND lim.tpctrlim = 1   -- Limite de credito
       AND lim.insitlim = 2   -- Somente ativos 
     ORDER BY lim.progress_recid DESC;
  rg_craplim     cr_craplim%ROWTYPE;
      
  -- Buscar os dados de saldo de conta
  CURSOR cr_crapsda(pr_cdcooper   crapsda.cdcooper%TYPE
                   ,pr_nrdconta   crapsda.nrdconta%TYPE
                   ,pr_dtmvtolt   crapsda.dtmvtolt%TYPE) IS
    SELECT sda.vlsddisp
         , sda.vllimutl
         , sda.vllimcre
      FROM crapsda sda
     WHERE sda.cdcooper = pr_cdcooper 
       AND sda.nrdconta = pr_nrdconta 
       AND sda.dtmvtolt = pr_dtmvtolt;
  rg_crapsda     cr_crapsda%ROWTYPE;
  
  -- Buscar limites de créditos rotativos
  CURSOR cr_craplrt(pr_cdcooper   craplrt.cdcooper%TYPE
                   ,pr_cddlinha   craplrt.cddlinha%TYPE) IS
    SELECT lrt.txjurvar 
      FROM craplrt lrt 
     WHERE lrt.cdcooper = pr_cdcooper 
       AND lrt.cddlinha = pr_cddlinha;
  rg_craplrt    cr_craplrt%ROWTYPE;
  
  -- Buscar os dados do registro do associado
  CURSOR cr_crapass(pr_cdcooper  crapass.cdcooper%TYPE
                   ,pr_nrdconta  crapass.nrdconta%TYPE) IS
    SELECT ass.dsnivris
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rg_crapass   cr_crapass%ROWTYPE;
  
  -- Buscar dados da CRAPTAB
  CURSOR cr_craptab(pr_cdcooper   craptab.cdcooper%TYPE
                   ,pr_nmsistem   craptab.nmsistem%TYPE
                   ,pr_tptabela   craptab.tptabela%TYPE
                   ,pr_cdempres   craptab.cdempres%TYPE
                   ,pr_cdacesso   craptab.cdacesso%TYPE
                   ,pr_tpregist   craptab.tpregist%TYPE
                   ,pr_dsnivris   VARCHAR2) IS
    SELECT tab.dstextab
      FROM craptab tab
     WHERE tab.cdcooper                    = pr_cdcooper
       AND UPPER(tab.nmsistem)             = pr_nmsistem
       AND UPPER(tab.tptabela)             = pr_tptabela
       AND tab.cdempres                    = pr_cdempres
       AND UPPER(tab.cdacesso)             = pr_cdacesso
       AND (tab.tpregist                   = pr_tpregist OR pr_tpregist IS NULL)
       AND (TRIM(SUBSTR(tab.dstextab,8,3)) = pr_dsnivris OR pr_dsnivris IS NULL);
   
  -- Buscar os dados de empréstimos
  CURSOR cr_crapepr IS 
    SELECT ass.cdcooper
         , ass.nrdconta
         , ass.nmprimtl
         , ass.nrmatric
         , epr.nrctremp
         , epr.cdlcremp
         , epr.qtpreemp
         , epr.vlemprst
         , epr.dtmvtolt
         , wep.tpemprst
         , wep.cddindex
         , wep.percetop
         , wep.txmensal
         , wep.vlperidx
         , wep.dtdpagto
         , wep.dtvencto
         , wep.dtaprova
      FROM crapass ass
         , crawepr wep
         , crapepr epr
     WHERE ass.cdcooper  = epr.cdcooper
       AND ass.nrdconta  = epr.nrdconta
       AND wep.cdcooper  = epr.cdcooper 
       AND wep.nrdconta  = epr.nrdconta 
       AND wep.nrctremp  = epr.nrctremp
       AND epr.cdcooper  = pr_cdcooper
       AND epr.inliquid <> 1
     ORDER BY epr.cdcooper, epr.dtmvtolt, epr.cdagenci, epr.cdbccxlt, epr.nrdolote, epr.nrdconta, epr.nrctremp;
  
  -- Buscar as parcelas do empréstimo
  CURSOR cr_crappep(pr_cdcooper   crappep.cdcooper%TYPE
                   ,pr_nrdconta   crappep.nrdconta%TYPE
                   ,pr_nrctremp   crappep.nrctremp%TYPE) IS
    SELECT pep.nrparepr
         , pep.vlparepr
         , pep.dtvencto   
      FROM crappep pep
     WHERE pep.cdcooper = pr_cdcooper
       AND pep.nrdconta = pr_nrdconta
       AND pep.nrctremp = pr_nrctremp
     ORDER BY pep.nrparepr;
  
  -- Buscar os dados de antecipações do empréstimo
  CURSOR cr_antecip(pr_cdcooper   tbepr_mitra_pagamento.cdcooper%TYPE
                   ,pr_nrdconta   tbepr_mitra_pagamento.nrdconta%TYPE
                   ,pr_nrctremp   tbepr_mitra_pagamento.nrctremp%TYPE) IS
    SELECT pag.idantecipacao
         , pag.dsindentificador
         , pag.vlsaldo_devedor
         , pag.dtantecipacao
         , pag.vlantecipacao
         , pag.nrparcela_antecip
         , pag.tppagamento
         , dpg.dscodigo  dscodpag
         , pag.tpamortizacao
         , dam.dscodigo  dscodamr
      FROM tbepr_dominio_campo    dam
         , tbepr_dominio_campo    dpg
         , tbepr_mitra_pagamento  pag
     WHERE dam.nmdominio = 'TPAMORTIZACAO_ANTECIPACAO'
       AND dam.cddominio = pag.tpamortizacao
       AND dpg.nmdominio = 'TPPAGAMENTO_ANTECIPACAO'
       AND dpg.cddominio = pag.tppagamento
       AND pag.cdcooper  = pr_cdcooper
       AND pag.nrdconta  = pr_nrdconta
       AND pag.nrctremp  = pr_nrctremp
     ORDER BY pag.dtantecipacao ASC             -- Ordenado dessa forma pois podem ser geradas
            , LENGTH(pag.dsindentificador) ASC  -- antecipações na mesma hora/minuto/segundo em casos
            , pag.dsindentificador ASC;         -- de liquidação do contrato.
  
  -- Busca as parcelas da antecipação
  CURSOR cr_antpep(pr_cdcooper   tbepr_mitra_pagamento.cdcooper%TYPE
                  ,pr_nrdconta   tbepr_mitra_pagamento.nrdconta%TYPE
                  ,pr_nrctremp   tbepr_mitra_pagamento.nrctremp%TYPE
                  ,pr_idantecip  tbepr_mitra_pagamento.idantecipacao%TYPE) IS
    SELECT rownum  nrregist
         , apr.nrnova_parcela
         , apr.nrparepr
         , apr.txamortizacao
         , pep.vlparepr
         , pep.dtvencto
      FROM crappep                        pep
         , tbepr_mitra_pagamento_parcela  apr
     WHERE pep.cdcooper      = pr_cdcooper
       AND pep.nrdconta      = pr_nrdconta
       AND pep.nrctremp      = pr_nrctremp
       AND pep.nrparepr      = apr.nrparepr
       AND apr.idantecipacao = pr_idantecip
     ORDER BY apr.nrnova_parcela ASC;
  
  -- Buscar a ultima parcela paga antes da antecipação
  CURSOR cr_parcela(pr_cdcooper   crappep.cdcooper%TYPE
                   ,pr_nrdconta   crappep.nrdconta%TYPE
                   ,pr_nrctremp   crappep.nrctremp%TYPE
                   ,pr_nrparepr   crappep.nrparepr%TYPE) IS
    SELECT pep.dtvencto
      FROM crappep pep
     WHERE pep.cdcooper = pr_cdcooper
       AND pep.nrdconta = pr_nrdconta
       AND pep.nrctremp = pr_nrctremp
       AND pep.nrparepr = pr_nrparepr;
  
  -- Buscar a ultima antecipação ocorrida no dia 
  CURSOR cr_lastantecip(pr_cdcooper   tbepr_mitra_pagamento.cdcooper%TYPE
                   	   ,pr_nrdconta   tbepr_mitra_pagamento.nrdconta%TYPE
                       ,pr_nrctremp   tbepr_mitra_pagamento.nrctremp%TYPE
                       ,pr_dtanteci   tbepr_mitra_pagamento.dtantecipacao%TYPE) IS
    SELECT t.idantecipacao
      FROM tbepr_mitra_pagamento t
     WHERE t.cdcooper             = pr_cdcooper
       AND t.nrdconta             = pr_nrdconta
       AND t.nrctremp             = pr_nrctremp
       AND trunc(t.dtantecipacao) = TRUNC(pr_dtanteci)
     ORDER BY t.dtantecipacao DESC
            , LENGTH(t.dsindentificador) DESC
            , t.dsindentificador DESC;
  rg_lastantecip   cr_lastantecip%ROWTYPE;
            
  ------------------------------- VARIÁVEIS --------------------------------
  vr_tbdatpep     typ_tab_datas_parcelas;
  vr_tbdmitra     typ_tab_dados_mitra;
  rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;
  
  vr_exc_saida    EXCEPTION;
  
  vr_cdcritic     NUMBER;
  vr_dscritic     VARCHAR2(2000);
  vr_des_reto     VARCHAR2(10);
  
  vr_cdprogra     CONSTANT VARCHAR2(10) := 'CRPS650';
  vr_dscaminh     VARCHAR2(100);
  vr_nmarquiv     VARCHAR2(50);
  vr_dsarquiv     UTL_FILE.file_type;
  vr_idfndlim     BOOLEAN;
  vr_idfndsda     BOOLEAN;
  vr_nrindice     NUMBER;
  vr_vlprcris     NUMBER;
  vr_dstextab     craptab.dstextab%TYPE;
  vr_dsvaldpu     VARCHAR2(30);
  vr_vldataxa     NUMBER;
  vr_vlsldapl     NUMBER;
  vr_tbsaldo_rdca APLI0001.typ_tab_saldo_rdca;
  vr_tab_aplica   APLI0005.typ_tab_aplicacao;
  vr_tab_erro     GENE0001.typ_tab_erro;
  vr_vlamortz     NUMBER;
  vr_qtdparce     NUMBER;
  vr_qtcarenc     NUMBER;
  vr_diavecto     DATE;
  vr_dtinicio     DATE;
  vr_dtinijur     DATE;
  vr_dspepnew     VARCHAR2(100);
  
  vr_dsidendi     VARCHAR2(100);
  vr_dsnomeli     VARCHAR2(100);
  vr_dstratam     VARCHAR2(100);
  vr_dstiprod     VARCHAR2(100);
  vr_identifi     VARCHAR2(100);
  vr_dsdetaxa     VARCHAR2(100);
  vr_dscontra     VARCHAR2(100);
  vr_dscodigo     VARCHAR2(100);
  
  vr_dsdlinha     VARCHAR2(32000);
  
  -------------------------------------------------------------------------------------------------------------------
  -- Formata o número para o CSV (no mesmo formato gerado pelo Progress)
  FUNCTION format_number_csv(pr_vlformat IN NUMBER) RETURN VARCHAR2 IS
    
    -- Variável
    vr_dsdvalor    VARCHAR2(50);
    
  BEGIN
    -- Verifica se o valor possui decimais
    IF (pr_vlformat - TRUNC(pr_vlformat)) > 0 THEN
      vr_dsdvalor := TO_CHAR(pr_vlformat,'FM99999999999999999999D99' , 'NLS_NUMERIC_CHARACTERS='',.''');
    ELSE
      vr_dsdvalor := TO_CHAR(pr_vlformat,'FM99999999999999999999');
    END IF;
    
    -- Retornar o valor formatado
    RETURN vr_dsdvalor;
  
  END format_number_csv;
  
  -- Formata as taxas para o CSV (no mesmo formato gerado pelo Progress)
  FUNCTION format_taxa_csv(pr_vlformat IN NUMBER
                          ,pr_qtdcasas IN NUMBER DEFAULT 10) RETURN VARCHAR2 IS
    
    -- Variável
    vr_vlformat    NUMBER := round(pr_vlformat,pr_qtdcasas);
    vr_dsdvalor    VARCHAR2(50);
    
  BEGIN
  
    -- Verifica se o valor possui decimais
    IF (vr_vlformat - TRUNC(vr_vlformat)) > 0 THEN
      vr_dsdvalor := TO_CHAR(vr_vlformat,'FM99999999999D'||LPAD('9',pr_qtdcasas,'9') , 'NLS_NUMERIC_CHARACTERS='',.''');
    ELSE
      vr_dsdvalor := TO_CHAR(vr_vlformat,'FM9999999999999');
    END IF;
    
    -- Retornar o valor formatado
    RETURN vr_dsdvalor;
  
  END format_taxa_csv;
  -------------------------------------------------------------------------------------------------------------------
BEGIN

  -- Incluir nome do módulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                             pr_action => NULL);

  -- Verifica se a cooperativa esta cadastrada
  OPEN  cr_crapcop;
  FETCH cr_crapcop INTO rw_crapcop;

  -- Se não encontrar
  IF cr_crapcop%NOTFOUND THEN
    -- Fechar o cursor pois haverá raise
    CLOSE cr_crapcop;
    -- Montar mensagem de critica
    vr_cdcritic := 651;
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE cr_crapcop;
  END IF;
  
  -- Buscar a data do sistema
  OPEN  BTCH0001.cr_crapdat(rw_crapcop.cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
  
  -- Se não encontrar
  IF BTCH0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor pois efetuaremos raise
    CLOSE BTCH0001.cr_crapdat;
    -- MONTAR MENSAGEM DE CRITICA
    vr_cdcritic := 1;
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE BTCH0001.cr_crapdat;
  END IF;

  -- Validações iniciais do programa
  BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => vr_cdcritic);

  -- Se a variavel de erro é <> 0
  IF vr_cdcritic <> 0 THEN
    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  END IF;
  
  -- Buscar o diretório de dados do MITRA
  vr_dscaminh := GENE0001.fn_diretorio(pr_tpdireto => 'M'
                                      ,pr_cdcooper => rw_crapcop.cdcooper);
  
  -- Completar com o sub diretório
  vr_dscaminh := vr_dscaminh || '/Risco_de_Mercado_Mitra/';
  
  -- Definir o nome do arquivo do MITRA
  vr_nmarquiv := to_char(rw_crapdat.dtmvtolt, 'DD_MM_RRRR')||'_MITRA.csv';
  
  
  /***** CARREGAR OS DADOS QUE SERÃO DISPONIBILIZADO PARA O MITRA *****/
  
  -- Percorrer os dados dos cadastros de pessoas jurídicas
  FOR rg_crapjur IN cr_crapjur LOOP

    -- Buscar o cadastro de limite de crédito da pessoa jurídica
    OPEN  cr_craplim(rg_crapjur.cdcooper
                    ,rg_crapjur.nrdconta);
    FETCH cr_craplim INTO rg_craplim;
    
    -- Indica se entrou registros
    vr_idfndlim := cr_craplim%FOUND;
    
    -- Fechar o cursor
    CLOSE cr_craplim; 
    
    -- Buscar os dados de saldo da pessoa jurídica
    OPEN  cr_crapsda(rg_crapjur.cdcooper
                    ,rg_crapjur.nrdconta
                    ,rw_crapdat.dtmvtolt);
    FETCH cr_crapsda INTO rg_crapsda;
    
    -- Indica se entrou registros
    vr_idfndsda := cr_crapsda%FOUND;
    
    -- Fechar o cursor
    CLOSE cr_crapsda; 
    
    
    -- Se possui cadastro de limite de crédito
    IF vr_idfndlim THEN
      
      -- Indice a ser inserido no registro
      vr_nrindice := vr_tbdmitra.COUNT() + 1;

      -- Inserir os dados do MITRA
      vr_tbdmitra(vr_nrindice).identificacao  := 'CCB_' || rg_craplim.nrdconta || '_' || rg_craplim.nrctrlim;
      vr_tbdmitra(vr_nrindice).nome           := 'LIMITE_DISPONIVEL';
      vr_tbdmitra(vr_nrindice).carteira       := 'AILOS_PROPRIA';
      vr_tbdmitra(vr_nrindice).inicio         := TO_CHAR(rg_craplim.dtinivig, 'DD/MM/RRRR');
      vr_tbdmitra(vr_nrindice).vencimento     := TO_CHAR((rg_craplim.dtinivig + rg_craplim.qtdiavig), 'DD/MM/RRRR');
      vr_tbdmitra(vr_nrindice).contraparte    := rg_crapjur.nmfansia;
      vr_tbdmitra(vr_nrindice).codigo         := 'CCBLMT_' || rg_crapjur.nrdconta;
      vr_tbdmitra(vr_nrindice).limite_conta   := rg_craplim.vllimite;
      vr_tbdmitra(vr_nrindice).n_agencia      := '85';
      vr_tbdmitra(vr_nrindice).n_conta_corrente := rg_crapjur.nrdconta;
      vr_tbdmitra(vr_nrindice).data_saldo     := TO_CHAR(rw_crapdat.dtmvtolt, 'DD/MM/RRRR');
      vr_tbdmitra(vr_nrindice).data_abertura  := TO_CHAR(rg_craplim.dtinivig, 'DD/MM/RRRR');
      vr_tbdmitra(vr_nrindice).status_recurso := 'Terceiros';
      vr_tbdmitra(vr_nrindice).financeiro_contabil_bruto := '0';
                
      -- Se encontrou registro de saldo
      IF vr_idfndsda THEN
      
        vr_tbdmitra(vr_nrindice).valor        := format_number_csv(rg_crapsda.vllimutl * (-1));
         
        -- Se o valor de limite utilizado é maior que zero          
        IF rg_crapsda.vllimutl > 0 THEN
          
          -- Buscar linha de crédito rotativos
          OPEN  cr_craplrt(pr_cdcooper
                          ,rg_craplim.cddlinha);
          FETCH cr_craplrt INTO rg_craplrt;
          -- Se não encontrar registros
          IF cr_craplrt%NOTFOUND THEN
            -- Limpar o registro
            rg_craplrt := NULL;
          END IF;
          
          -- Fechar o cursor
          CLOSE cr_craplrt;
                             
          -- Novo indice a ser inserido no registro
          vr_nrindice := vr_tbdmitra.COUNT() + 1;

          -- Inserir os dados do MITRA
          vr_tbdmitra(vr_nrindice).identificacao := 'CCBCDI_' || rg_craplim.nrdconta || '_' || rg_craplim.nrctrlim;
          vr_tbdmitra(vr_nrindice).nome          := 'CCB_CDI - RF';
          vr_tbdmitra(vr_nrindice).carteira      := 'AILOS_PROPRIA';
          vr_tbdmitra(vr_nrindice).data_entrada  := TO_CHAR(rw_crapdat.dtmvtolt, 'DD/MM/RRRR');
          vr_tbdmitra(vr_nrindice).quantidade    := '1';
          vr_tbdmitra(vr_nrindice).pu            := rg_crapsda.vllimutl;
          vr_tbdmitra(vr_nrindice).inicio        := TO_CHAR(rw_crapdat.dtmvtolt, 'DD/MM/RRRR');
          vr_tbdmitra(vr_nrindice).vencimento    := TO_CHAR((rg_craplim.dtinivig + rg_craplim.qtdiavig), 'DD/MM/RRRR');
          vr_tbdmitra(vr_nrindice).valor         := rg_crapsda.vllimutl;
          vr_tbdmitra(vr_nrindice).porc_index    := rg_craplrt.txjurvar;
          vr_tbdmitra(vr_nrindice).contraparte   := rg_crapjur.nmfansia;
          vr_tbdmitra(vr_nrindice).tipo_marcacao := 'C';
          vr_tbdmitra(vr_nrindice).codigo        := 'CCBUTI_' || rg_crapjur.nrdconta;
          vr_tbdmitra(vr_nrindice).contrato      := vr_tbdmitra(vr_nrindice).codigo;
          vr_tbdmitra(vr_nrindice).status_quantidade := 'Disponivel';
          vr_tbdmitra(vr_nrindice).estrategia_1  := 'CCB';
          vr_tbdmitra(vr_nrindice).estrategia_2  := 'Disponivel';
          vr_tbdmitra(vr_nrindice).estrategia_3  := rg_crapjur.nmfansia;
          vr_tbdmitra(vr_nrindice).amortizacao   := '1';
          vr_tbdmitra(vr_nrindice).financeiro_contabil_bruto := rg_crapsda.vllimutl;
                              
          -- Buscar os registro do associado
          OPEN  cr_crapass(rg_crapjur.cdcooper
                          ,rg_crapjur.nrdconta);
          FETCH cr_crapass INTO rg_crapass;
          
          -- Se não encontrar registro
          IF cr_crapass%FOUND THEN
            -- Se não tem nível de risco
            IF TRIM(rg_crapass.dsnivris) IS NULL THEN
              rg_crapass.dsnivris := 'A';
            END IF;
            
            -- Limpar
            vr_dstextab := NULL;
            
            -- Buscar registro da TAB
            OPEN  cr_craptab(pr_cdcooper           -- pr_cdcooper
                            ,'CRED'                -- pr_nmsistem
                            ,'GENERI'              -- pr_tptabela
                            ,00                    -- pr_cdempres
                            ,'PROVISAOCL'          -- pr_cdacesso
                            ,NULL                  -- pr_tpregist
                            ,rg_crapass.dsnivris); -- pr_dsnivris
            FETCH cr_craptab INTO vr_dstextab;
            
            -- Fechar o cursor
            CLOSE cr_craptab;
            
            -- Calcular o percentual de risco
            vr_vlprcris := TO_NUMBER(SUBSTR(vr_dstextab,1,6), '000D00', 'NLS_NUMERIC_CHARACTERS='',.''') / 100;
          
            -- Incluir
            vr_tbdmitra(vr_nrindice).financeiro_contabil_provisao := format_number_csv(((rg_crapsda.vllimutl * vr_vlprcris) * (-1)));
          
          END IF;
          
          -- Fechar o cursor 
          CLOSE cr_crapass;   
        
        END IF; -- rg_crapsda.vllimutl > 0
      END IF; -- vr_idfndsda
            
    END IF; -- vr_idfndlim

    -- Se encontrou registro de saldo
    IF vr_idfndsda THEN
      -- Se o saldo disponivel é maior que zero
      IF rg_crapsda.vlsddisp > 0 THEN
        -- Novo indice a ser inserido no registro
        vr_nrindice := vr_tbdmitra.COUNT() + 1;
        
        -- Incluir registro MITRA
        vr_tbdmitra(vr_nrindice).identificacao    := 'DPV_' || rg_crapjur.nrdconta || '_1';
        vr_tbdmitra(vr_nrindice).nome             := 'DEPOSITO_A_ VISTA';
        vr_tbdmitra(vr_nrindice).carteira         := 'AILOS_PROPRIA';
        vr_tbdmitra(vr_nrindice).valor            := format_number_csv(rg_crapsda.vlsddisp);
        vr_tbdmitra(vr_nrindice).contraparte      := rg_crapjur.nmfansia;
        vr_tbdmitra(vr_nrindice).codigo           := vr_tbdmitra(vr_nrindice).identificacao;
        vr_tbdmitra(vr_nrindice).limite_conta     := '0';
        vr_tbdmitra(vr_nrindice).n_agencia        := '85';
        vr_tbdmitra(vr_nrindice).n_conta_corrente := rg_crapjur.nrdconta;
        vr_tbdmitra(vr_nrindice).data_saldo       := TO_CHAR(rw_crapdat.dtmvtolt, 'DD/MM/RRRR');
        vr_tbdmitra(vr_nrindice).data_abertura    := TO_CHAR(rw_crapdat.dtmvtoan, 'DD/MM/RRRR');
        vr_tbdmitra(vr_nrindice).status_recurso   := 'Proprio';
        vr_tbdmitra(vr_nrindice).financeiro_contabil_bruto := '0';
        
      END IF;
                
      -- Valida os saldos 
      IF (rg_crapsda.vlsddisp < 0)       AND
         ((rg_crapsda.vllimcre      >  0                    AND 
           rg_crapsda.vllimutl      >= rg_crapsda.vllimcre  AND
           ABS(rg_crapsda.vlsddisp) >  rg_crapsda.vllimcre ) OR
          rg_crapsda.vllimcre       =  0)                  THEN
      
      
        -- Novo indice a ser inserido no registro
        vr_nrindice := vr_tbdmitra.COUNT() + 1;
        
        -- calcula valor do PU
        vr_dsvaldpu := format_number_csv( ABS(rg_crapsda.vlsddisp + rg_crapsda.vllimcre) );
        
        -- Incluir os dados
        vr_tbdmitra(vr_nrindice).identificacao    := 'ADP_' || rg_crapjur.nrdconta || '_1';
        vr_tbdmitra(vr_nrindice).nome             := 'ADIANT DEP_PRE - RF';
        vr_tbdmitra(vr_nrindice).carteira         := 'AILOS_PROPRIA';
        vr_tbdmitra(vr_nrindice).data_entrada     := TO_CHAR(rw_crapdat.dtmvtolt, 'DD/MM/RRRR');
        vr_tbdmitra(vr_nrindice).quantidade       := '1';
        vr_tbdmitra(vr_nrindice).pu               := vr_dsvaldpu;
        vr_tbdmitra(vr_nrindice).inicio           := TO_CHAR(rw_crapdat.dtmvtolt, 'DD/MM/RRRR');
        vr_tbdmitra(vr_nrindice).vencimento       := TO_CHAR(rw_crapdat.dtmvtopr, 'DD/MM/RRRR');
        vr_tbdmitra(vr_nrindice).valor            := vr_dsvaldpu;
        vr_tbdmitra(vr_nrindice).contraparte      := rg_crapjur.nmfansia;
        vr_tbdmitra(vr_nrindice).tipo_marcacao    := 'C';
        vr_tbdmitra(vr_nrindice).codigo           := vr_tbdmitra(vr_nrindice).identificacao;
        vr_tbdmitra(vr_nrindice).contrato         := vr_tbdmitra(vr_nrindice).codigo;
        vr_tbdmitra(vr_nrindice).status_quantidade:= 'Disponivel';
        vr_tbdmitra(vr_nrindice).estrategia_1     := 'ADP';
        vr_tbdmitra(vr_nrindice).estrategia_2     := vr_tbdmitra(vr_nrindice).status_quantidade;
        vr_tbdmitra(vr_nrindice).estrategia_3     := vr_tbdmitra(vr_nrindice).contraparte;
        vr_tbdmitra(vr_nrindice).amortizacao      := '1';
        vr_tbdmitra(vr_nrindice).financeiro_contabil_bruto := '0';
        
        -- Limpar variável
        vr_dstextab := NULL;
        
        -- Buscar registro da TAB
        OPEN  cr_craptab(pr_cdcooper           -- pr_cdcooper
                        ,'CRED'                -- pr_nmsistem
                        ,'USUARI'              -- pr_tptabela
                        ,11                    -- pr_cdempres
                        ,'JUROSNEGAT'          -- pr_cdacesso
                        ,001                   -- pr_tpregist
                        ,NULL ); -- pr_dsnivris
        FETCH cr_craptab INTO vr_dstextab;
        
        -- Se encontrar registro
        IF cr_craptab%FOUND THEN
          
          -- Ler a taxa
          vr_vldataxa := TO_NUMBER(SUBSTR(vr_dstextab,1,10), 'FM000D000000', 'NLS_NUMERIC_CHARACTERS='',.''');
          
          -- Formatar e adicionar no registro
          vr_tbdmitra(vr_nrindice).taxa := format_taxa_csv(vr_vldataxa);
          
        END IF;
        
        -- Fechar o cursor
        CLOSE cr_craptab;
         
      END IF; -- Valida os saldos 
    END IF; -- Se encontrou registro de saldo

    -- Buscar os dados de aplicações
    APLI0002.pc_obtem_dados_aplicacoes(pr_cdcooper       => pr_cdcooper
                                      ,pr_cdagenci       => 0
                                      ,pr_nrdcaixa       => 0
                                      ,pr_cdoperad       => pr_cdoperad
                                      ,pr_nmdatela       => 'MITRA'
                                      ,pr_idorigem       => 1
                                      ,pr_nrdconta       => rg_crapjur.nrdconta
                                      ,pr_idseqttl       => 1
                                      ,pr_nraplica       => NULL
                                      ,pr_cdprogra       => 'MITRA'
                                      ,pr_flgerlog       => 0 -- FALSE
                                      ,pr_dtiniper       => NULL
                                      ,pr_dtfimper       => NULL
                                      ,pr_vlsldapl       => vr_vlsldapl
                                      ,pr_des_reto       => vr_des_reto --Retorno OK ou NOK
                                      ,pr_tab_saldo_rdca => vr_tbsaldo_rdca
                                      ,pr_tab_erro       => vr_tab_erro);
    
    -- Se retornou erro
    IF vr_des_reto = 'NOK' THEN
      --Se possuir erro na PLTable
      IF vr_tab_erro.count > 0 THEN
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
      ELSE
        vr_dscritic := 'Nao foi possivel carregar aplicacoes.';
      END IF;

      -- Limpar tabela de erros
      vr_tab_erro.delete;

      RAISE vr_exc_saida;
    END IF;
  
    -- Se há saldos de aplicações
    IF vr_tbsaldo_rdca.COUNT() > 0 THEN
      -- Percorrer os dados das aplicações retornadas
      FOR idaplica IN vr_tbsaldo_rdca.FIRST..vr_tbsaldo_rdca.LAST LOOP
      
        -- Novo indice a ser inserido no registro
        vr_nrindice := vr_tbdmitra.COUNT() + 1;
      
        vr_tbdmitra(vr_nrindice).identificacao := 'RDC_' || rg_crapjur.nrdconta || '_' ||vr_tbsaldo_rdca(idaplica).nraplica;
        vr_tbdmitra(vr_nrindice).nome          := 'RDC_CDI - RF';
        vr_tbdmitra(vr_nrindice).carteira      := 'AILOS_PROPRIA';
        vr_tbdmitra(vr_nrindice).data_entrada  := TO_CHAR(rw_crapdat.dtmvtolt, 'DD/MM/RRRR');
        vr_tbdmitra(vr_nrindice).quantidade    := '1';
        vr_tbdmitra(vr_nrindice).pu            := format_number_csv(vr_tbsaldo_rdca(idaplica).sldresga);
        vr_tbdmitra(vr_nrindice).inicio        := TO_CHAR(rw_crapdat.dtmvtolt, 'DD/MM/RRRR');
        vr_tbdmitra(vr_nrindice).vencimento    := TO_CHAR(vr_tbsaldo_rdca(idaplica).dtvencto, 'DD/MM/RRRR');
        vr_tbdmitra(vr_nrindice).valor         := vr_tbdmitra(vr_nrindice).pu;
        vr_tbdmitra(vr_nrindice).porc_index    := vr_tbsaldo_rdca(idaplica).txaplmax;
        vr_tbdmitra(vr_nrindice).contraparte   := rg_crapjur.nmfansia;
        vr_tbdmitra(vr_nrindice).tipo_marcacao := 'C';
        vr_tbdmitra(vr_nrindice).codigo        := vr_tbdmitra(vr_nrindice).identificacao;
        vr_tbdmitra(vr_nrindice).contrato      := vr_tbdmitra(vr_nrindice).codigo;
        
        -- Verifica a situação da aplicação
        IF UPPER(vr_tbsaldo_rdca(idaplica).dssitapl) = 'BLOQUEADA' THEN
          vr_tbdmitra(vr_nrindice).status_quantidade := 'Vinculado';
        ELSE
          vr_tbdmitra(vr_nrindice).status_quantidade := 'Disponivel';
        END IF;
        
        vr_tbdmitra(vr_nrindice).estrategia_1  := 'RDC';
        vr_tbdmitra(vr_nrindice).estrategia_2  := vr_tbdmitra(vr_nrindice).status_quantidade;
        vr_tbdmitra(vr_nrindice).estrategia_3  := vr_tbdmitra(vr_nrindice).contraparte;
        vr_tbdmitra(vr_nrindice).amortizacao   := '1';
        vr_tbdmitra(vr_nrindice).financeiro_contabil_bruto := '0';

      END LOOP; -- Aplicações RDCA
    END IF;

    /********NOVA CONSULTA APLICACOOES*********/
    /** Saldo das aplicacoes **/
    APLI0005.pc_busca_aplicacoes(pr_cdcooper   => pr_cdcooper         --> Código da Cooperativa
                                ,pr_cdoperad   => '1'                 --> Código do Operador
                                ,pr_nmdatela   => vr_cdprogra         --> Nome da Tela
                                ,pr_idorigem   => 1                   --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                ,pr_nrdconta   => rg_crapjur.nrdconta --> Número da Conta
                                ,pr_idseqttl   => 1                   --> Titular da Conta
                                ,pr_nraplica   => 0                   --> Número da Aplicação - Parâmetro Opcional
                                ,pr_cdprodut   => 0                   --> Código do Produto – Parâmetro Opcional
                                ,pr_dtmvtolt   => rw_crapdat.dtmvtolt --> Data de Movimento
                                ,pr_idconsul   => 0                   --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                ,pr_idgerlog   => 0                   --> Identificador de Log (0 – Não / 1 – Sim)
                                ,pr_cdcritic   => vr_cdcritic         --> Código da crítica
                                ,pr_dscritic   => vr_dscritic         --> Descrição da crítica
                                ,pr_tab_aplica => vr_tab_aplica);     --> Tabela com os dados da aplicação

    -- Se retornou alguma critica
    IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    
    -- Se há registros de saldos para processar
    IF vr_tab_aplica.COUNT() > 0 THEN
      -- Percorrer os registros de aplicações retornados
      FOR idaplica IN vr_tab_aplica.FIRST..vr_tab_aplica.LAST LOOP
      
        -- Novo indice a ser inserido no registro
        vr_nrindice := vr_tbdmitra.COUNT() + 1;

        vr_tbdmitra(vr_nrindice).identificacao := 'RDC_' || rg_crapjur.nrdconta || '_' || vr_tab_aplica(idaplica).nraplica;
        vr_tbdmitra(vr_nrindice).nome          := 'RDC_CDI - RF';
        vr_tbdmitra(vr_nrindice).carteira      := 'AILOS_PROPRIA';
        vr_tbdmitra(vr_nrindice).data_entrada  := TO_CHAR(rw_crapdat.dtmvtolt, 'DD/MM/RRRR');
        vr_tbdmitra(vr_nrindice).quantidade    := '1';
        vr_tbdmitra(vr_nrindice).pu            := format_number_csv(vr_tab_aplica(idaplica).vlsldrgt);
        vr_tbdmitra(vr_nrindice).inicio        := TO_CHAR(rw_crapdat.dtmvtolt, 'DD/MM/RRRR');
        vr_tbdmitra(vr_nrindice).vencimento    := TO_CHAR(vr_tab_aplica(idaplica).dtvencto, 'DD/MM/RRRR');
        vr_tbdmitra(vr_nrindice).valor         := vr_tbdmitra(vr_nrindice).pu;
        
        -- Verificar se a taxa é fixa
        IF vr_tab_aplica(idaplica).idtxfixa = 1 THEN
          vr_tbdmitra(vr_nrindice).porc_index  := '100';
          vr_tbdmitra(vr_nrindice).taxa        := format_taxa_csv(vr_tab_aplica(idaplica).txaplica);
        ELSE
          vr_tbdmitra(vr_nrindice).porc_index  := format_taxa_csv(vr_tab_aplica(idaplica).txaplica);
          vr_tbdmitra(vr_nrindice).taxa        := NULL;
        END IF;
        
        vr_tbdmitra(vr_nrindice).contraparte   := rg_crapjur.nmfansia;
        vr_tbdmitra(vr_nrindice).tipo_marcacao := 'C';
        vr_tbdmitra(vr_nrindice).codigo        := 'RDC_' || rg_crapjur.nrdconta || '_' || vr_tab_aplica(idaplica).nraplica;
        vr_tbdmitra(vr_nrindice).contrato      := vr_tbdmitra(vr_nrindice).codigo;
        
        -- Verifica a situação da aplicação
        IF UPPER(vr_tab_aplica(idaplica).dssitapl) = 'BLOQUEADA' THEN
          vr_tbdmitra(vr_nrindice).status_quantidade := 'Vinculado';
        ELSE
          vr_tbdmitra(vr_nrindice).status_quantidade := 'Disponivel';
        END IF;
        
        vr_tbdmitra(vr_nrindice).estrategia_1  := 'RDC';
        vr_tbdmitra(vr_nrindice).estrategia_2  := vr_tbdmitra(vr_nrindice).status_quantidade;
        vr_tbdmitra(vr_nrindice).estrategia_3  := vr_tbdmitra(vr_nrindice).contraparte;
        vr_tbdmitra(vr_nrindice).amortizacao   := '1';
        vr_tbdmitra(vr_nrindice).financeiro_contabil_bruto := '0';
      END LOOP;
    END IF;
    
    /*******FIM CONSULTA APLICACAOES**********/
  END LOOP;  -- crapjur

  /*******CONSULTA INFORMACOES DE EMPRESTIMOS **********/
  FOR rg_crapepr IN cr_crapepr LOOP
    
    -- Montar informações
    IF    rg_crapepr.cdlcremp IN (1,2) THEN
      vr_dsidendi := 'REPASSE CAIXA';
      vr_dsnomeli := 'BNDES_PRE_360 - RF';
      vr_dstratam := NULL;
      vr_dsdetaxa := format_number_csv(rg_crapepr.percetop);

    ELSIF rg_crapepr.cdlcremp = 3      THEN
      vr_dsidendi := 'REFAP';
      vr_dsnomeli := 'EMPRESTIMOS_CDI - RF';
      vr_dstratam := 'Correção CDI - Diária_d.c./360 % Cmp_1';
      vr_dsdetaxa := ' ';

    ELSIF rg_crapepr.cdlcremp = 4 THEN
      vr_dsidendi := 'CCB MAIS CREDITO';
      vr_dsnomeli := 'EMPRESTIMOS_CDI - RF';
      vr_dstratam := 'Correção CDI - Diária_d.c./360 % Cmp_1';
      vr_dsdetaxa := ' ';
      
    ELSIF rg_crapepr.cdlcremp = 5 THEN
      vr_dsidendi := 'REPASSE BNDES';
      vr_dsnomeli := 'BNDES - PROCAPCRED_TJLP - RF';
      vr_dstratam := NULL;
      vr_dsdetaxa := ' ';

    ELSIF rg_crapepr.cdlcremp = 6 THEN
      vr_dsidendi := 'REPASSE CAIXA';
      vr_dsnomeli := 'BNDES_PRE_360 - RF';
      vr_dstratam := 'Prefixado_d.c./360 % Cmp_0';
      vr_dsdetaxa := '8,73';
      
    ELSE 
      vr_dsidendi := ' ';
      vr_dsnomeli := 'NAO CADASTRADA';
      vr_dstratam := NULL;
      vr_dsdetaxa := ' ';
    END IF;

    -- 
    vr_dstiprod := NULL;

    -- Se for Pos-Fixado 
    IF rg_crapepr.tpemprst = 2 THEN
      IF rg_crapepr.cddindex = 1 THEN
        vr_dstiprod := 'CDI';
      ELSIF rg_crapepr.cddindex = 2 THEN
        vr_dstiprod := 'TR';
      END IF;

      -- Formar as descrições
      vr_dsnomeli := 'EMPRESTIMO_' || vr_dstiprod || '360 - RF';
      vr_dsidendi := 'POS';
    
      -- Código
      vr_dscodigo := rg_crapepr.nrdconta || '_' || rg_crapepr.nrctremp;
    ELSE 
      -- Código
      vr_dscodigo := rg_crapepr.nrmatric || '_' || rg_crapepr.nrctremp;
    END IF;

    -- Identificador
    vr_identifi := 'EMP' || vr_dstiprod || '_' || rg_crapepr.nrdconta || '_' || rg_crapepr.nrctremp;
    
    -- Contraparte
    IF INSTR(rg_crapepr.nmprimtl,'-') > 0 THEN
      vr_dscontra := SUBSTR(rg_crapepr.nmprimtl, 1, INSTR(rg_crapepr.nmprimtl,'-') - 1);
    ELSE
      vr_dscontra := rg_crapepr.nmprimtl;
    END IF;
  
    -- Novo indice a ser inserido no registro
    vr_nrindice := vr_tbdmitra.COUNT() + 1;
    
    vr_tbdmitra(vr_nrindice).identificacao  := vr_identifi;
    vr_tbdmitra(vr_nrindice).carteira       := 'AILOS_PROPRIA';
    vr_tbdmitra(vr_nrindice).data_entrada   := TO_CHAR(rg_crapepr.dtmvtolt, 'DD/MM/RRRR');
    vr_tbdmitra(vr_nrindice).quantidade     := '1';
    vr_tbdmitra(vr_nrindice).pu             := format_number_csv(rg_crapepr.vlemprst);
    vr_tbdmitra(vr_nrindice).taxa           := vr_dsdetaxa;
    vr_tbdmitra(vr_nrindice).contraparte    := vr_dscontra;
    vr_tbdmitra(vr_nrindice).tipo_marcacao  := 'C';
    vr_tbdmitra(vr_nrindice).codigo         := vr_dscodigo;
    vr_tbdmitra(vr_nrindice).contrato       := vr_identifi;
    vr_tbdmitra(vr_nrindice).estrategia_1   := vr_dsidendi;
    vr_tbdmitra(vr_nrindice).estrategia_3   := vr_dscontra;
    vr_tbdmitra(vr_nrindice).financeiro_contabil_bruto := '0';
    
    /* Se for Pos-Fixado */
    IF rg_crapepr.tpemprst = 2 THEN
          
      -- Percorrer as parcelas do emprestimo            
      FOR rg_crappep IN cr_crappep(rg_crapepr.cdcooper       -- pr_cdcooper 
                                  ,rg_crapepr.nrdconta       -- pr_nrdconta
                                  ,rg_crapepr.nrctremp) LOOP -- pr_nrctremp
        
        -- Novo indice a ser inserido no registro
        vr_nrindice := vr_tbdmitra.COUNT() + 1;
        
        -- Calcular o valor da taxa
        vr_dsdetaxa := format_taxa_csv( (POWER((rg_crapepr.txmensal / 100) + 1, 12) - 1) * 100 ,2);
        
        -- Se foi pago em dia
        IF rg_crappep.dtvencto >= rg_crapepr.dtdpagto THEN
          -- Calcular o valor da amortização 
          vr_vlamortz := ROUND((1 / rg_crapepr.qtpreemp), 9);
        ELSE
          vr_vlamortz := 0;
        END IF;
        
        vr_tbdmitra(vr_nrindice).identificacao := vr_identifi;
        vr_tbdmitra(vr_nrindice).nome          := vr_dsnomeli;
        vr_tbdmitra(vr_nrindice).inicio        := TO_CHAR(rg_crapepr.dtaprova, 'DD/MM/RRRR');
        vr_tbdmitra(vr_nrindice).vencimento    := TO_CHAR(rg_crappep.dtvencto, 'DD/MM/RRRR');
        vr_tbdmitra(vr_nrindice).valor         := format_number_csv(rg_crapepr.vlemprst);
        vr_tbdmitra(vr_nrindice).taxa          := vr_dsdetaxa;
        vr_tbdmitra(vr_nrindice).porc_index    := format_number_csv(rg_crapepr.vlperidx);
        vr_tbdmitra(vr_nrindice).contraparte   := vr_dscontra;
        vr_tbdmitra(vr_nrindice).contrato      := vr_identifi;
        vr_tbdmitra(vr_nrindice).parcela       := rg_crappep.nrparepr;
        vr_tbdmitra(vr_nrindice).amortizacao   := format_taxa_csv(vr_vlamortz ,9);
        vr_tbdmitra(vr_nrindice).tratamento    := vr_dstratam;
        vr_tbdmitra(vr_nrindice).estrategia_1  := vr_dsidendi;
        vr_tbdmitra(vr_nrindice).estrategia_3  := vr_dscontra;
        vr_tbdmitra(vr_nrindice).financeiro_contabil_bruto := '0';

      END LOOP; -- Loop parcelas

      /* Esse trecho de código não deverá ser executado, foi mantido erroneamente no progress
      FOR EACH tt-datas-parcelas NO-LOCK:
         CREATE tt-dados-mitra.
         ASSIGN tt-dados-mitra.contrato = "EMP"
                                        + aux_dstiprod + "_"
                                        + STRING(crapass.nrdconta) + "_"
                                        + STRING(crapepr.nrctremp)
                tt-dados-mitra.financeiro_contabil_bruto = "0"
                tt-dados-mitra.tipo_evento = "Incorporacao"
                tt-dados-mitra.data_incorporacao = STRING(tt-datas-parcelas.dtparepr,"99/99/9999")
                tt-dados-mitra.incorpora_juros = "Sim"
                tt-dados-mitra.incorpora_correcao = "Sim".
      END.*/
      
      /********** GERAR OS DADOS DE ANTECIPAÇÃO **********/
      -- Percorrer as antecipações que ocorreram para o empréstimo
      FOR rg_antecip IN cr_antecip(pr_cdcooper => rg_crapepr.cdcooper
                                  ,pr_nrdconta => rg_crapepr.nrdconta
                                  ,pr_nrctremp => rg_crapepr.nrctremp)  LOOP
        
        -- Se a amortização foi do tipo total
        IF rg_antecip.tpamortizacao = 2 THEN
          
          -- Novo indice a ser inserido no registro
          vr_nrindice := vr_tbdmitra.COUNT() + 1;
        
          -- Incluir os dados de amortização de liquidação total
          vr_tbdmitra(vr_nrindice).identificacao         := vr_identifi;
          vr_tbdmitra(vr_nrindice).data_entrada          := TO_CHAR(rg_antecip.dtantecipacao, 'DD/MM/RRRR');
          vr_tbdmitra(vr_nrindice).pu                    := format_number_csv(rg_antecip.vlantecipacao);
          vr_tbdmitra(vr_nrindice).contraparte           := vr_dscontra;
          vr_tbdmitra(vr_nrindice).contrato              := vr_identifi;
          vr_tbdmitra(vr_nrindice).parcela               := rg_antecip.nrparcela_antecip;
          vr_tbdmitra(vr_nrindice).modalidade_liquidacao := 'Liquidação Parcela';
          vr_tbdmitra(vr_nrindice).tipo_evento           := 'Liquidação Total';
          vr_tbdmitra(vr_nrindice).data_evento           := TO_CHAR(rg_antecip.dtantecipacao, 'DD/MM/RRRR');
        
        END IF;
        
        -- Ultima antecipação do dia
        rg_lastantecip := NULL;
        
        -- Buscar a ultima antecipação do dia para o contrato (deve ser impresso as parcelas apenas da última)
        OPEN  cr_lastantecip(rg_crapepr.cdcooper
                            ,rg_crapepr.nrdconta
                            ,rg_crapepr.nrctremp
                            ,rg_antecip.dtantecipacao);
        FETCH cr_lastantecip INTO rg_lastantecip;
        CLOSE cr_lastantecip;
        
        -- Verifica se a antecipação é a ultima do dia
        IF NVL(rg_lastantecip.idantecipacao,rg_antecip.idantecipacao) = rg_antecip.idantecipacao THEN
          
          /* Gerar EVENTO DE ANTECIPAÇAO TOTAL / PARCIAL */
          -- Novo indice a ser inserido no registro
          vr_nrindice := vr_tbdmitra.COUNT() + 1;
          
          vr_tbdmitra(vr_nrindice).identificacao        := vr_identifi;
          vr_tbdmitra(vr_nrindice).contraparte          := vr_dscontra;
          vr_tbdmitra(vr_nrindice).contrato             := vr_identifi;
          vr_tbdmitra(vr_nrindice).data_evento          := TO_CHAR(rg_antecip.dtantecipacao, 'DD/MM/RRRR');
          vr_tbdmitra(vr_nrindice).saldo_devedor_evento := format_number_csv(rg_antecip.vlsaldo_devedor);
        
          -- Limpar a variável a cada antecipação
          vr_dtinicio := NULL;
          
          -- Percorrer cada uma das parcelas geradas
          FOR rg_antpep IN cr_antpep(rg_crapepr.cdcooper
                                    ,rg_crapepr.nrdconta
                                    ,rg_crapepr.nrctremp
                                    ,rg_antecip.idantecipacao) LOOP
            
            -- INICIO - Última vencimento de parcela antes da data de antecipação.
            -- Carregar a mesma apenas quando for a primeira parcela
            IF rg_antpep.nrregist = 1 THEN
              
              -- Buscar a data de vencimento da parcela anterior
              OPEN  cr_parcela(pr_cdcooper => rg_crapepr.cdcooper
                              ,pr_nrdconta => rg_crapepr.nrdconta
                              ,pr_nrctremp => rg_crapepr.nrctremp
                              ,pr_nrparepr => rg_antpep.nrparepr - 1);
              FETCH cr_parcela INTO vr_dtinicio;
              
              -- Se não encontrar a primeira parcela 
              IF cr_parcela%NOTFOUND THEN
                -- Quando não encontrar parcela anterior, irá utilizar a data de efetivação do contrato
                vr_dtinicio := rg_crapepr.dtmvtolt;
              END IF;
              
              CLOSE cr_parcela;  
            
            
              -- Na primeira linha deve informar a data de inicio do juros
              vr_dtinijur := rg_antecip.dtantecipacao;
            ELSE 
              -- Nas demais o valor não deve ser apresentado
              vr_dtinijur := NULL;
            END IF;
            
            -- Configurar o identificador da nova parcela
            vr_dspepnew := LOWER(rg_antecip.dsindentificador)||LPAD(rg_antpep.nrnova_parcela,3,'0');
            
            -- Calcular o valor da taxa
            vr_dsdetaxa := format_taxa_csv( (POWER((rg_crapepr.txmensal / 100) + 1, 12) - 1) * 100 ,2);
            
            -- Novo indice a ser inserido no registro
            vr_nrindice := vr_tbdmitra.COUNT() + 1;
            
            -- Registro da parcela
            vr_tbdmitra(vr_nrindice).identificacao         := vr_identifi;
            vr_tbdmitra(vr_nrindice).nome                  := vr_dsnomeli;
            vr_tbdmitra(vr_nrindice).inicio                := TO_CHAR(vr_dtinicio, 'DD/MM/RRRR');
            vr_tbdmitra(vr_nrindice).vencimento            := TO_CHAR(rg_antpep.dtvencto, 'DD/MM/RRRR');
            vr_tbdmitra(vr_nrindice).valor                 := format_number_csv(rg_crapepr.vlemprst);
            vr_tbdmitra(vr_nrindice).taxa                  := vr_dsdetaxa;
            vr_tbdmitra(vr_nrindice).porc_index            := format_number_csv(rg_crapepr.vlperidx);
            vr_tbdmitra(vr_nrindice).contraparte           := vr_dscontra;
            vr_tbdmitra(vr_nrindice).contrato              := vr_identifi;
            vr_tbdmitra(vr_nrindice).parcela               := vr_dspepnew;
            vr_tbdmitra(vr_nrindice).estrategia_1          := vr_dsidendi;
            vr_tbdmitra(vr_nrindice).estrategia_3          := vr_dscontra;
            vr_tbdmitra(vr_nrindice).amortizacao           := format_taxa_csv(rg_antpep.txamortizacao ,9);
            vr_tbdmitra(vr_nrindice).inicio_juros          := TO_CHAR(vr_dtinijur, 'DD/MM/RRRR');
            vr_tbdmitra(vr_nrindice).inicio_correcao       := TO_CHAR(vr_dtinijur, 'DD/MM/RRRR');
            vr_tbdmitra(vr_nrindice).financeiro_contabil_bruto := '0';
            vr_tbdmitra(vr_nrindice).data_evento           := TO_CHAR(rg_antecip.dtantecipacao, 'DD/MM/RRRR');
            vr_tbdmitra(vr_nrindice).tipo_pagamento        := rg_antecip.dscodpag;
                      
          END LOOP;
          
        END IF; -- IF NVL(rg_lastantecip.idantecipacao,rg_antecip.idantecipacao) = rg_antecip.idantecipacao
      
      END LOOP;
      
      /********** FIM DOS DADOS DE ANTECIPAÇÃO **********/
      
    ELSE  -- IF rg_crapepr.tpemprst = 2
    
      -- calculos
      vr_qtdparce := ROUND((rg_crapepr.dtvencto - rg_crapepr.dtaprova)/ 30,0) + rg_crapepr.qtpreemp;
      vr_qtcarenc := ROUND((rg_crapepr.dtvencto - rg_crapepr.dtaprova)/ 30,0);
      vr_vlamortz := (1 / rg_crapepr.qtpreemp);
      vr_diavecto := rg_crapepr.dtaprova + 30;
              
      /* Datas das Prestacoes */
      -- Limpar a tabela de dados temporários
      vr_tbdatpep.DELETE;

      -- Se a parcela é maior que zero
      IF vr_qtdparce > 0 THEN
        DECLARE
          vr_dtcalcul   DATE   := vr_diavecto;
          vr_dia        NUMBER := to_number(to_char(vr_dtcalcul,'DD'));
          vr_mes        NUMBER := to_number(to_char(vr_dtcalcul,'MM'));
          vr_ano        NUMBER := to_number(to_char(vr_dtcalcul,'YYYY'));
        BEGIN
          
          -- Percorrer quantidade de parcelas
          FOR vr_idparcel IN 1..vr_qtdparce LOOP
            -- Se é ou passou do dia 29
            IF vr_dia >= 29 THEN
              BEGIN
                -- Se nao existir o dia no mes, joga o vencimento para o ultimo deste mesmo mes.
                vr_dtcalcul := TO_DATE(to_char(vr_dia,'FM00')||to_char(vr_mes,'FM00')||to_char(vr_ano,'FM0000'), 'DDMMYYYY');
              EXCEPTION
                WHEN OTHERS THEN
                  -- Último dia do mês
                  vr_dtcalcul := LAST_DAY( TO_DATE('01'||to_char(vr_mes,'FM00')||to_char(vr_ano,'FM0000'), 'DDMMYYYY') );
              END;             
            ELSE
              -- Monta a data
              vr_dtcalcul := TO_DATE(to_char(vr_dia,'FM00')||to_char(vr_mes,'FM00')||to_char(vr_ano,'FM0000'), 'DDMMYYYY');
            END IF;

            -- Registrar os dados
            vr_tbdatpep(vr_idparcel).nrparepr := vr_idparcel;
            vr_tbdatpep(vr_idparcel).dtparepr := vr_dtcalcul;

            -- Se for o mês de dezembro
            IF vr_mes = 12 THEN
              vr_mes := 1;
              vr_ano := vr_ano + 1;
            ELSE
              vr_mes := vr_mes + 1;
            END IF;
          END LOOP; -- PARCELAS
        END;
        
      END IF;  -- IF vr_qtdparce > 0     
       
      -- Verifica se há parcelas a processar
      IF vr_tbdatpep.COUNT() > 0 THEN
        -- Percorrer as parcelas geradas e validar o dia e incluir registro
        FOR idparcel IN vr_tbdatpep.FIRST..vr_tbdatpep.LAST LOOP
                   
          -- Buscar o próximo dia útil
          vr_tbdatpep(idparcel).dtparepr := GENE0005.fn_valida_dia_util(pr_cdcooper  => rg_crapepr.cdcooper
                                                                       ,pr_dtmvtolt  => vr_tbdatpep(idparcel).dtparepr
                                                                       ,pr_excultdia => TRUE);  -- Considerar 31/12 dia útil
          
          -- Novo indice a ser inserido no registro
          vr_nrindice := vr_tbdmitra.COUNT() + 1;
          
          vr_tbdmitra(vr_nrindice).identificacao := vr_identifi;
          vr_tbdmitra(vr_nrindice).nome          := vr_dsnomeli;
          vr_tbdmitra(vr_nrindice).inicio        := TO_CHAR(rg_crapepr.dtaprova, 'DD/MM/RRRR');
          vr_tbdmitra(vr_nrindice).vencimento    := TO_CHAR(vr_tbdatpep(idparcel).dtparepr, 'DD/MM/RRRR');
          vr_tbdmitra(vr_nrindice).valor         := format_number_csv(rg_crapepr.vlemprst);
          
          -- Se a linha de crédito do empréstimo é 5
          IF    rg_crapepr.cdlcremp = 5 THEN
            vr_tbdmitra(vr_nrindice).taxa        := '0,1';
          ELSIF rg_crapepr.cdlcremp = 6 THEN 
            vr_tbdmitra(vr_nrindice).taxa        := '8,73';
          ELSE 
            vr_tbdmitra(vr_nrindice).taxa        := ' ';
          END IF;
          
          vr_tbdmitra(vr_nrindice).porc_index    := '100';
          vr_tbdmitra(vr_nrindice).contraparte   := vr_dscontra;
          vr_tbdmitra(vr_nrindice).contrato      := vr_identifi;
          vr_tbdmitra(vr_nrindice).parcela       := idparcel;
          
          -- Calcula a amortizacao
          IF    idparcel <= vr_qtcarenc THEN
            vr_tbdmitra(vr_nrindice).amortizacao := '0';
          ELSIF rg_crapepr.cdlcremp = 6 THEN
            vr_tbdmitra(vr_nrindice).amortizacao := format_taxa_csv(vr_vlamortz ,9);
          ELSE
            vr_tbdmitra(vr_nrindice).amortizacao := format_taxa_csv(vr_vlamortz);
          END IF;
          
          vr_tbdmitra(vr_nrindice).tratamento    := vr_dstratam;
          vr_tbdmitra(vr_nrindice).estrategia_1  := vr_dsidendi;
          vr_tbdmitra(vr_nrindice).estrategia_3  := vr_dscontra;
          vr_tbdmitra(vr_nrindice).financeiro_contabil_bruto := '0';

        END LOOP;
      END IF;

    END IF;  -- IF rg_crapepr.tpemprst = 2
  
  END LOOP; -- cr_crapepr
    
  /*******FIM CONSULTA INFORMACOES DE EMPRESTIMOS**********/

  /******* IMPRIMIR OS DADOS EM UM CLOB ********/
  
  -- Criar o arquivo
  GENE0001.pc_abre_arquivo(pr_nmdireto => vr_dscaminh
                          ,pr_nmarquiv => vr_nmarquiv
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_dsarquiv
                          ,pr_des_erro => vr_dscritic);
                         
  -- Se retornar erro
  IF vr_dscritic IS NOT NULL THEN
    -- Encerra com erro
    RAISE vr_exc_saida;
  END IF;
    
  -- Cabeçalho do arquivo CSV
  vr_dsdlinha := 'IDENTIFICACAO;NOME;CARTEIRA;'
              || 'CORRETORA;DATA_ENTRADA;DESCRICAO;'
              || 'AGRUPAMENTO;QUANTIDADE;PU;'
              || 'CORRETAGEM;EMOLUMENTO;REBATE;'
              || 'CPMF;OUTRAS_DESPESAS;INICIO;'
              || 'VENCIMENTO;VALOR;TAXA;TAXA_REGISTRO;'
              || 'PORC_INDEX;CONTRAPARTE;IMPOSTOS;'
              || 'TAXA_A;TAXA_P;PORC_INDEX_A;'
              || 'PORC_INDEX_P;TIPO_MARCACAO;'
              || 'TIPO_MARCACAO_A;TIPO_MARCACAO_P;'
              || 'TIPO_MARCACAO_STOCK;COTACAO_BASE;'
              || 'DATA_LANCAMENTO;GERAR_PROVISAO;'
              || 'ID;CODIGO;LASTRO;CUPOM_OPERACAO;'
              || 'CUPOM_POL;PORC_INDEX_POL;'
              || 'TIPO_MARCACAO_POL;TIPO_MARCACAO_TES_POL;'
              || 'PORC_REBATE;INDEXADOR;CONTRATO;PARCELA;'
              || 'CORRECAO;JUROS;TARIFAS;MORA;RESGATE_TOTAL;'
              || 'LIMITE_CONTA;N_AGENCIA;N_CONTA_CORRENTE;'
              || 'TAXA_ADP;IOF;DATA_SALDO;DATA_ENCERRAMENTO;'
              || 'DATA_ABERTURA;CUPOM_POL_A;CUPOM_POL_P;'
              || 'PORC_INDEX_POL_A;PORC_INDEX_POL_P;PU_POLITICA;'
              || 'FINANCEIRO_LIQUIDO;CAMBIO_BASE;CAMBIO_BASE_A;'
              || 'CAMBIO_BASE_P;TIPO_CALCULO_BACEN;'
              || 'DATA_BOLETAGEM;GARANTIA_IMOBILIARIA;'
              || 'VALOR_MITIGADOR;DATA_APLICACAO_INICIAL;'
              || 'STATUS_QUANTIDADE;STATUS_RECURSO;'
              || 'PU_REFERENCIA;VOLATILIDADE;'
              || 'TIPO_MODALIDADE_OPERACAO;'
              || 'TIPO_CALCULO_MODALIDADE;'
              || 'TIPO_MARCACAO_MODALIDADE;FATOR_MITIGADOR;'
              || 'GERAR_LANCAMENTO_AUTOMATICO;CENARIO;'
              || 'ESTRATEGIA_1;ESTRATEGIA_2;ESTRATEGIA_3;'
              || 'EH_CLEARING;PU_A;PU_P;JUROS_A;JUROS_P;'
              || 'CORRECAO_A;CORRECAO_P;MOEDA2;TRATAMENTO_MOEDA;'
              || 'TRATAMENTO_MOEDA2;TIPO_MARCACAO_MOEDA2;'
              || 'VENCIMENTO_MOEDA2;TIPO_POSICAO_OPERACAO;'
              || 'STATUS_OPERACAO;METODO_DESCONTO_MTM;'
              || 'MODALIDADE_LIQUIDACAO;AMORTIZACAO;'
              || 'SALDO_DEVEDOR;INICIO_JUROS;INICIO_CORRECAO;'
              || 'PAGA_AMORTIZACAO;PAGA_JUROS;PAGA_CORRECAO;'
              || 'FORMA_APLICACAO_JUROS;FORMA_APLICACAO_CORRECAO;'
              || 'TRATAMENTO;PU_FINANCEIRO;INFORMA1;INFORMA2;'
              || 'INFORMA3;INFORMA4;INFORMA5;'
              || 'FINANCEIRO_CONTABIL_BRUTO;'
              || 'FINANCEIRO_CONTABIL_PROVISAO;'
              || 'TAXA_BASE;CAMBIO_CONVERSAO_INICIO;'
              || 'INICIO_JUROS_A;INICIO_JUROS_P;'
              || 'INICIO_CORRECAO_A;INICIO_CORRECAO_P;'
              || 'TRATAMENTO_A;TRATAMENTO_P;'
              || 'FORMA_APLICACAO_JUROS_A;'
              || 'FORMA_APLICACAO_JUROS_P;'
              || 'PAGA_JUROS_A;PAGA_JUROS_P;'
              || 'FORMA_APLICACAO_CORRECAO_A;'
              || 'FORMA_APLICACAO_CORRECAO_P;'
              || 'PAGA_CORRECAO_A;PAGA_CORRECAO_P;TAXA_BASE_A;'
              || 'TAXA_BASE_P;TAXA_OPER_A;TAXA_OPER_P;'
              || 'CAMBIO_CONVERSAO_INICIO_A;'
              || 'CAMBIO_CONVERSAO_INICIO_P;'
              || 'DESCRICAO_CONTRATO;NOME_VISUAL_CONTRATO;'
              || 'CODIGO_ISIN;CODIGO_SELIC;MOEDA_LIQUIDACAO;'
              || 'DEFASAGEM_MOEDA_LIQUIDACAO;'
              || 'TIPO_DIAS_DEFAS_LIQUIDACAO;'
              || 'TIPO_EVENTO;MOEDA_CONVERSAO;'
              || 'DEFASAGEM_MOED_CONVERSAO;'
              || 'TIPO_DIAS_DEFA_CONVERSAO;'
              || 'MOEDA_CONVERSAO_A;DEFASAGEM_MOEDA_CONVERSAO_A;'
              || 'TIPO_DIAS_DEFA_CONVERSAO_A;MOEDA_CONVERSAO_P;'
              || 'DEFASAGEM_MOEDA_CONVERSAO_P;'
              || 'TIPO_DIAS_DEFA_CONVERSAO_P;'
              || 'DATA_INCORPORACAO;INCORPORA_JUROS;'
              || 'INCORPORA_CORRECAO;ID_CONTROLE;ID_SISTEMA;'
              || 'DATA_REFERENCIA;ID_CONNECTED;ID_CLIENTE;'
              || 'ID_EXECUCAO;DATA_EVENTO;SALDO_DEVEDOR_EVENTO;TIPO_PAGAMENTO;';
            
  -- Escreve a linha no arquivo
  GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_dsarquiv
                                ,pr_des_text => vr_dsdlinha);
  
  -- Percorrer todos os registros registrados para o MITRA
  FOR indice IN vr_tbdmitra.FIRST..vr_tbdmitra.LAST LOOP
    
    -- Linha do arquivo CSV
    vr_dsdlinha := vr_tbdmitra(indice).identificacao                || ';'
                || vr_tbdmitra(indice).nome                         || ';'
                || vr_tbdmitra(indice).carteira                     || ';'
                || vr_tbdmitra(indice).corretora                    || ';'
                || vr_tbdmitra(indice).data_entrada                 || ';'
                || vr_tbdmitra(indice).descricao                    || ';'
                || vr_tbdmitra(indice).agrupamento                  || ';'
                || vr_tbdmitra(indice).quantidade                   || ';'
                || vr_tbdmitra(indice).pu                           || ';'
                || vr_tbdmitra(indice).corretagem                   || ';'
                || vr_tbdmitra(indice).emolumento                   || ';'
                || vr_tbdmitra(indice).rebate                       || ';'
                || vr_tbdmitra(indice).cpmf                         || ';'
                || vr_tbdmitra(indice).outras_despesas              || ';'
                || vr_tbdmitra(indice).inicio                       || ';'
                || vr_tbdmitra(indice).vencimento                   || ';'
                || vr_tbdmitra(indice).valor                        || ';'
                || vr_tbdmitra(indice).taxa                         || ';'
                || vr_tbdmitra(indice).taxa_registro                || ';'
                || vr_tbdmitra(indice).porc_index                   || ';'
                || vr_tbdmitra(indice).contraparte                  || ';'
                || vr_tbdmitra(indice).impostos                     || ';'
                || vr_tbdmitra(indice).taxa_a                       || ';'
                || vr_tbdmitra(indice).taxa_p                       || ';'
                || vr_tbdmitra(indice).porc_index_a                 || ';'
                || vr_tbdmitra(indice).porc_index_p                 || ';'
                || vr_tbdmitra(indice).tipo_marcacao                || ';'
                || vr_tbdmitra(indice).tipo_marcacao_a              || ';'
                || vr_tbdmitra(indice).tipo_marcacao_p              || ';'
                || vr_tbdmitra(indice).tipo_marcacao_stock          || ';'
                || vr_tbdmitra(indice).cotacao_base                 || ';'
                || vr_tbdmitra(indice).data_lancamento              || ';'
                || vr_tbdmitra(indice).gerar_provisao               || ';'
                || vr_tbdmitra(indice).id                           || ';'
                || vr_tbdmitra(indice).codigo                       || ';'
                || vr_tbdmitra(indice).lastro                       || ';'
                || vr_tbdmitra(indice).cupom_operacao               || ';'
                || vr_tbdmitra(indice).cupom_pol                    || ';'
                || vr_tbdmitra(indice).porc_index_pol               || ';'
                || vr_tbdmitra(indice).tipo_marcacao_pol            || ';'
                || vr_tbdmitra(indice).tipo_marcacao_tes_pol        || ';'
                || vr_tbdmitra(indice).porc_rebate                  || ';'
                || vr_tbdmitra(indice).indexador                    || ';'
                || vr_tbdmitra(indice).contrato                     || ';'
                || vr_tbdmitra(indice).parcela                      || ';'
                || vr_tbdmitra(indice).correcao                     || ';'
                || vr_tbdmitra(indice).juros                        || ';'
                || vr_tbdmitra(indice).tarifas                      || ';'
                || vr_tbdmitra(indice).mora                         || ';'
                || vr_tbdmitra(indice).resgate_total                || ';'
                || vr_tbdmitra(indice).limite_conta                 || ';'
                || vr_tbdmitra(indice).n_agencia                    || ';'
                || vr_tbdmitra(indice).n_conta_corrente             || ';'
                || vr_tbdmitra(indice).taxa_adp                     || ';'
                || vr_tbdmitra(indice).iof                          || ';'
                || vr_tbdmitra(indice).data_saldo                   || ';'
                || vr_tbdmitra(indice).data_encerramento            || ';'
                || vr_tbdmitra(indice).data_abertura                || ';'
                || vr_tbdmitra(indice).cupom_pol_a                  || ';'
                || vr_tbdmitra(indice).cupom_pol_p                  || ';'
                || vr_tbdmitra(indice).porc_index_pol_a             || ';'
                || vr_tbdmitra(indice).porc_index_pol_p             || ';'
                || vr_tbdmitra(indice).pu_politica                  || ';'
                || vr_tbdmitra(indice).financeiro_liquido           || ';'
                || vr_tbdmitra(indice).cambio_base                  || ';'
                || vr_tbdmitra(indice).cambio_base_a                || ';'
                || vr_tbdmitra(indice).cambio_base_p                || ';'
                || vr_tbdmitra(indice).tipo_calculo_bacen           || ';'
                || vr_tbdmitra(indice).data_boletagem               || ';'
                || vr_tbdmitra(indice).garantia_imobiliaria         || ';'
                || vr_tbdmitra(indice).valor_mitigador              || ';'
                || vr_tbdmitra(indice).data_aplicacao_inicial       || ';'
                || vr_tbdmitra(indice).status_quantidade            || ';'
                || vr_tbdmitra(indice).status_recurso               || ';'
                || vr_tbdmitra(indice).pu_referencia                || ';'
                || vr_tbdmitra(indice).volatilidade                 || ';'
                || vr_tbdmitra(indice).tipo_modalidade_operacao     || ';'
                || vr_tbdmitra(indice).tipo_calculo_modalidade      || ';'
                || vr_tbdmitra(indice).tipo_marcacao_modalidade     || ';'
                || vr_tbdmitra(indice).fator_mitigador              || ';'
                || vr_tbdmitra(indice).gerar_lancamento_automatico  || ';'
                || vr_tbdmitra(indice).cenario                      || ';'
                || vr_tbdmitra(indice).estrategia_1                 || ';'
                || vr_tbdmitra(indice).estrategia_2                 || ';'
                || vr_tbdmitra(indice).estrategia_3                 || ';'
                || vr_tbdmitra(indice).eh_clearing                  || ';'
                || vr_tbdmitra(indice).pu_a                         || ';'
                || vr_tbdmitra(indice).pu_p                         || ';'
                || vr_tbdmitra(indice).juros_a                      || ';'
                || vr_tbdmitra(indice).juros_p                      || ';'
                || vr_tbdmitra(indice).correcao_a                   || ';'
                || vr_tbdmitra(indice).correcao_p                   || ';'
                || vr_tbdmitra(indice).moeda2                       || ';'
                || vr_tbdmitra(indice).tratamento_moeda             || ';'
                || vr_tbdmitra(indice).tratamento_moeda2            || ';'
                || vr_tbdmitra(indice).tipo_marcacao_moeda2         || ';'
                || vr_tbdmitra(indice).vencimento_moeda2            || ';'
                || vr_tbdmitra(indice).tipo_posicao_operacao        || ';'
                || vr_tbdmitra(indice).status_operacao              || ';'
                || vr_tbdmitra(indice).metodo_desconto_mtm          || ';'
                || vr_tbdmitra(indice).modalidade_liquidacao        || ';'
                || vr_tbdmitra(indice).amortizacao                  || ';'
                || vr_tbdmitra(indice).saldo_devedor                || ';'
                || vr_tbdmitra(indice).inicio_juros                 || ';'
                || vr_tbdmitra(indice).inicio_correcao              || ';'
                || vr_tbdmitra(indice).paga_amortizacao             || ';'
                || vr_tbdmitra(indice).paga_juros                   || ';'
                || vr_tbdmitra(indice).paga_correcao                || ';'
                || vr_tbdmitra(indice).forma_aplicacao_juros        || ';'
                || vr_tbdmitra(indice).forma_aplicacao_correcao     || ';'
                || vr_tbdmitra(indice).tratamento                   || ';'
                || vr_tbdmitra(indice).pu_financeiro                || ';'
                || vr_tbdmitra(indice).informa1                     || ';'
                || vr_tbdmitra(indice).informa2                     || ';'
                || vr_tbdmitra(indice).informa3                     || ';'
                || vr_tbdmitra(indice).informa4                     || ';'
                || vr_tbdmitra(indice).informa5                     || ';'
                || vr_tbdmitra(indice).financeiro_contabil_bruto    || ';'
                || vr_tbdmitra(indice).financeiro_contabil_provisao || ';'
                || vr_tbdmitra(indice).taxa_base                    || ';'
                || vr_tbdmitra(indice).cambio_conversao_inicio      || ';'
                || vr_tbdmitra(indice).inicio_juros_a               || ';'
                || vr_tbdmitra(indice).inicio_juros_p               || ';'
                || vr_tbdmitra(indice).inicio_correcao_a            || ';'
                || vr_tbdmitra(indice).inicio_correcao_p            || ';'
                || vr_tbdmitra(indice).tratamento_a                 || ';'
                || vr_tbdmitra(indice).tratamento_p                 || ';'
                || vr_tbdmitra(indice).forma_aplicacao_juros_a      || ';'
                || vr_tbdmitra(indice).forma_aplicacao_juros_p      || ';'
                || vr_tbdmitra(indice).paga_juros_a                 || ';'
                || vr_tbdmitra(indice).paga_juros_p                 || ';'
                || vr_tbdmitra(indice).forma_aplicacao_correcao_a   || ';'
                || vr_tbdmitra(indice).forma_aplicacao_correcao_p   || ';'
                || vr_tbdmitra(indice).paga_correcao_a              || ';'
                || vr_tbdmitra(indice).paga_correcao_p              || ';'
                || vr_tbdmitra(indice).taxa_base_a                  || ';'
                || vr_tbdmitra(indice).taxa_base_p                  || ';'
                || vr_tbdmitra(indice).taxa_oper_a                  || ';'
                || vr_tbdmitra(indice).taxa_oper_p                  || ';'
                || vr_tbdmitra(indice).cambio_conversao_inicio_a    || ';'
                || vr_tbdmitra(indice).cambio_conversao_inicio_p    || ';'
                || vr_tbdmitra(indice).descricao_contrato           || ';'
                || vr_tbdmitra(indice).nome_visual_contrato         || ';'
                || vr_tbdmitra(indice).codigo_isin                  || ';'
                || vr_tbdmitra(indice).codigo_selic                 || ';'
                || vr_tbdmitra(indice).moeda_liquidacao             || ';'
                || vr_tbdmitra(indice).defasagem_moeda_liquidacao   || ';'
                || vr_tbdmitra(indice).tipo_dias_defas_liquidacao   || ';'
                || vr_tbdmitra(indice).tipo_evento                  || ';'
                || vr_tbdmitra(indice).moeda_conversao              || ';'
                || vr_tbdmitra(indice).defasagem_moed_conversao     || ';'
                || vr_tbdmitra(indice).tipo_dias_defa_conversao     || ';'
                || vr_tbdmitra(indice).moeda_conversao_a            || ';'
                || vr_tbdmitra(indice).defasagem_moeda_conversao_a  || ';'
                || vr_tbdmitra(indice).tipo_dias_defa_conversao_a   || ';'
                || vr_tbdmitra(indice).moeda_conversao_p            || ';'
                || vr_tbdmitra(indice).defasagem_moeda_conversao_p  || ';'
                || vr_tbdmitra(indice).tipo_dias_defa_conversao_p   || ';'
                || vr_tbdmitra(indice).data_incorporacao            || ';'
                || vr_tbdmitra(indice).incorpora_juros              || ';'
                || vr_tbdmitra(indice).incorpora_correcao           || ';'
                || vr_tbdmitra(indice).id_controle                  || ';'
                || vr_tbdmitra(indice).id_sistema                   || ';'
                || vr_tbdmitra(indice).data_referencia              || ';'
                || vr_tbdmitra(indice).id_connected                 || ';'
                || vr_tbdmitra(indice).id_cliente                   || ';'
                || vr_tbdmitra(indice).id_execucao                  || ';'
                || vr_tbdmitra(indice).data_evento                  || ';'
                || vr_tbdmitra(indice).saldo_devedor_evento         || ';'
                || vr_tbdmitra(indice).tipo_pagamento               || ';';
                
    -- Escreve a linha no arquivo
    GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_dsarquiv
                                  ,pr_des_text => vr_dsdlinha);
      
  END LOOP;
  
  -- Fechar / salvar o arquivo
  GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_dsarquiv);
  
  -- PROCESSO OK, DEVEMOS CHAMAR A FIMPRG
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                            pr_cdprogra => vr_cdprogra,
                            pr_infimsol => pr_infimsol,
                            pr_stprogra => pr_stprogra);
  
  -- Commmita para fechar a sessão
  COMMIT;
  
EXCEPTION
  WHEN vr_exc_saida THEN
    -- SE FOI RETORNADO APENAS CÓDIGO
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- BUSCAR A DESCRIÇÃO
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- DEVOLVEMOS CÓDIGO E CRITICA ENCONTRADAS DAS VARIAVEIS LOCAIS
    pr_cdcritic := NVL(vr_cdcritic, 0);
    pr_dscritic := vr_dscritic;
    
    -- Fechar a sessão
    ROLLBACK;
  WHEN OTHERS THEN
    -- EFETUAR RETORNO DO ERRO NÃO TRATADO
    pr_cdcritic := 0;
    pr_dscritic := 'Erro na PC_CRPS650: '||SQLERRM;
    
    -- Fechar a sessão
    ROLLBACK;
END PC_CRPS650;
/
