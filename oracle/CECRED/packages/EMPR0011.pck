CREATE OR REPLACE PACKAGE CECRED.EMPR0011 IS

  /* Type das parcelas do Pos-Fixado */
  TYPE typ_reg_tab_parcelas IS RECORD(
     nrparepr             crappep.nrparepr%TYPE
    ,dtvencto             crappep.dtvencto%TYPE
    ,vlparepr             crappep.vlparepr%TYPE
    ,taxa_periodo         NUMBER(25,8)
    ,fator_juros_nominais NUMBER(25,10)
    ,fator_correcao       NUMBER(25,10)
    ,fator_acumulado      NUMBER(25,10)
    ,fator_price          NUMBER(25,10));

  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_parcelas IS TABLE OF typ_reg_tab_parcelas INDEX BY BINARY_INTEGER;

  PROCEDURE pc_calcula_iof_pos_fixado(pr_vltariof OUT NUMBER                    --> Valor de IOF
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE);   --> Descricao da critica

  PROCEDURE pc_valida_dados_pos_fixado(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa
                                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE     --> Data do movimento atual
                                      ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE     --> Codigo da linha de credito
                                      ,pr_vlemprst  IN crapepr.vlemprst%TYPE     --> Valor do emprestimo
                                      ,pr_qtparepr  IN crapepr.qtpreemp%TYPE     --> Quantidade de parcelas
                                      ,pr_dtlibera  IN crawepr.dtlibera%TYPE     --> Data da liberacao
                                      ,pr_dtdpagto  IN crapepr.dtdpagto%TYPE     --> Data do pagamento
                                      ,pr_dtcarenc  IN crawepr.dtcarenc%TYPE     --> Data da Carencia
                                      ,pr_flgpagto  IN crapepr.flgpagto%TYPE     --> Debito Folha: 0-Nao/1-Sim
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE);   --> Descricao da critica

  PROCEDURE pc_grava_parcel_pos_fixado(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Numero da Conta
                                      ,pr_dtmvtoan  IN crapdat.dtmvtoan%TYPE     --> Data do movimento anterior
                                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE     --> Data do movimento atual
                                      ,pr_nrctremp  IN crapepr.nrctremp%TYPE     --> Numero do contrato
                                      ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE     --> Codigo da linha de credito
                                      ,pr_vlemprst  IN crapepr.vlemprst%TYPE     --> Valor do emprestimo
                                      ,pr_qtparepr  IN crapepr.qtpreemp%TYPE     --> Quantidade de parcelas
                                      ,pr_dtdpagto  IN crapepr.dtdpagto%TYPE     --> Data do pagamento
                                      ,pr_vlpreemp OUT crapepr.vlpreemp%TYPE     --> Valor da prestacao
                                      ,pr_txdiaria OUT crawepr.txdiaria%TYPE     --> Taxa diaria
                                      ,pr_txmensal OUT crawepr.txmensal%TYPE     --> Taxa mensal
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE);   --> Descricao da critica

  PROCEDURE pc_busca_vl_prest_pos_prog(pr_cdcooper  IN crapepr.cdcooper%TYPE   --> Codigo da Cooperativa
                                      ,pr_dtmvtoan  IN crapdat.dtmvtoan%TYPE   --> Data do movimento anterior
                                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE   --> Data do movimento atual
                                      ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE   --> Codigo da linha de credito
                                      ,pr_qtpreemp  IN crapepr.qtpreemp%TYPE   --> Quantidade de prestacoes
                                      ,pr_dtdpagto  IN crapepr.dtdpagto%TYPE   --> Data do pagamento
                                      ,pr_vlsdeved  IN crapepr.vlsdeved%TYPE   --> Valor do saldo devedor
                                      ,pr_vlpreemp OUT crapepr.vlpreemp%TYPE   --> Valor da prestacao
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE   --> Codigo da critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descricao da critica

  PROCEDURE pc_alt_numero_parcelas_pos(pr_cdcooper      IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa
                                      ,pr_nrdconta      IN crapass.nrdconta%TYPE     --> Numero da Conta
                                      ,pr_nrctremp_old  IN crapepr.nrctremp%TYPE     --> Numero do contrato
                                      ,pr_nrctremp_new  IN crapepr.nrctremp%TYPE     --> Numero do contrato
                                      ,pr_cdcritic     OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                      ,pr_dscritic     OUT crapcri.dscritic%TYPE);   --> Descricao da critica

  PROCEDURE pc_exclui_prop_pos_fixado(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Numero da Conta
                                     ,pr_nrctremp  IN crapepr.nrctremp%TYPE     --> Numero do contrato
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE);   --> Descricao da critica

  PROCEDURE pc_efetua_credito_conta(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa
                                   ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Numero da Conta
                                   ,pr_nrctremp  IN crawepr.nrctremp%TYPE     --> Numero do contrato
                                   ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE     --> Data do movimento atual
                                   ,pr_cdprogra  IN crapprg.cdprogra%TYPE     --> Codigo Programa
                                   ,pr_inpessoa  IN crapass.inpessoa%TYPE     --> Tipo de pessoa
                                   ,pr_cdagenci  IN crapage.cdagenci%TYPE     --> Codigo da agencia
                                   ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE     --> Numero do caixa
                                   ,pr_cdpactra  IN crapage.cdagenci%TYPE     --> Codigo do PA de Transacao
                                   ,pr_cdoperad  IN crapope.cdoperad%TYPE     --> Codigo do Operador
                                   ,pr_vltottar OUT NUMBER                    --> Valor da tarifa
                                   ,pr_vltariof OUT NUMBER                    --> Valor do IOF
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                   ,pr_dscritic OUT crapcri.dscritic%TYPE);   --> Descricao da critica

  PROCEDURE pc_busca_tip_atualiz_index(pr_cddindex       IN tbepr_posfix_param_index.cddindex%TYPE      --> Codigo do indice (FK crapind)
                                      ,pr_tpatualizacao OUT tbepr_posfix_param_index.tpatualizacao%TYPE --> Tipo de Atualizacao Indexador
                                      ,pr_cdcritic      OUT crapcri.cdcritic%TYPE                       --> Codigo da critica
                                      ,pr_dscritic      OUT crapcri.dscritic%TYPE);                     --> Descricao da critica

END EMPR0011;
/
CREATE OR REPLACE PACKAGE BODY CECRED.EMPR0011 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : EMPR0011
  --  Sistema  : Conta-Corrente - Cooperativa de Credito
  --  Sigla    : CRED
  --  Autor    : Jaison Fernando
  --  Data     : Abril - 2017                 Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas para calculo do emprestimo Pos-Fixado.
  --
  -- Alteracoes: 
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_calcula_qtd_dias_uteis(pr_cdcooper     IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                     ,pr_datainicial  IN DATE                  --> Data Inicial
                                     ,pr_datafinal    IN DATE                  --> Data Final
                                     ,pr_qtdiaute    OUT PLS_INTEGER           --> Quantidade de dias uteis
                                     ,pr_cdcritic    OUT PLS_INTEGER           --> Codigo da critica
                                     ,pr_dscritic    OUT VARCHAR2 ) IS         --> Descricao da critica
    BEGIN
      /* ..............................................................................
      Programa: pc_calcula_qtd_dias_uteis
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : CRED
      Autor   : James Prust Junior
      Data    : Abril/2017                        Ultima atualizacao:

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina de calculo de dias uteis.

      Alteracoes: 
      .................................................................................*/
      DECLARE
        vr_dtmvtolt DATE;

        CURSOR cr_crapfer(pr_cdcooper IN crapfer.cdcooper%TYPE
                         ,pr_dtferiad IN crapfer.dtferiad%TYPE) IS
          SELECT dtferiad
            FROM crapfer
           WHERE cdcooper = pr_cdcooper
             AND dtferiad = pr_dtferiad;
        rw_crapfer cr_crapfer%ROWTYPE;

      BEGIN
        vr_dtmvtolt := pr_datainicial + 1;
        pr_qtdiaute := 0;

        WHILE vr_dtmvtolt <= pr_datafinal LOOP
          OPEN cr_crapfer(pr_cdcooper, vr_dtmvtolt);
          FETCH cr_crapfer INTO rw_crapfer;
          -- Se não encontrar
          IF cr_crapfer%NOTFOUND AND TO_CHAR(vr_dtmvtolt, 'D') NOT IN (1,7) THEN
            -- Fechar o cursor
            CLOSE cr_crapfer;
            pr_qtdiaute := pr_qtdiaute + 1;
          ELSE
            -- Fechar o cursor
            CLOSE cr_crapfer;
          END IF;

          vr_dtmvtolt := vr_dtmvtolt + 1;
        END LOOP;

      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro geral em pc_calcula_qtd_dias_uteis: ' || SQLERRM;        
      END;

  END pc_calcula_qtd_dias_uteis;

  PROCEDURE pc_calcula_parcelas_pos_fixado(pr_cdcooper      IN crapepr.cdcooper%TYPE     --> Codigo da Cooperativa
                                          ,pr_dtmvtoan      IN crapdat.dtmvtoan%TYPE     --> Data do movimento anterior
                                          ,pr_dtmvtolt      IN crapdat.dtmvtolt%TYPE     --> Data do movimento atual
                                          ,pr_cdlcremp      IN crapepr.cdlcremp%TYPE     --> Codigo da linha de credito
                                          ,pr_qtpreemp      IN crapepr.qtpreemp%TYPE     --> Quantidade de prestacoes
                                          ,pr_dtdpagto      IN crapepr.dtdpagto%TYPE     --> Data do pagamento
                                          ,pr_vlsdeved      IN crapepr.vlsdeved%TYPE     --> Valor do saldo devedor
                                          ,pr_tab_parcelas OUT typ_tab_parcelas          --> Temp-Table das parcelas
                                          ,pr_cdcritic     OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                          ,pr_dscritic     OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_calcula_parcelas_pos_fixado
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Abril/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para calcular as parcelas do Pos-Fixado.

       Alteracoes: 
    ............................................................................. */

    DECLARE
      -- Variaveis Calculo da Parcela
      vr_txdiaria              craplcr.txdiaria%TYPE;
      vr_vlrdtaxa              craptxi.vlrdtaxa%TYPE;
      vr_taxa_periodo_anterior NUMBER(25,8);
      vr_fator_price_total     NUMBER(25,10) := 0;
      vr_qtdia_corridos        PLS_INTEGER;
      vr_qtdia_uteis           PLS_INTEGER;
      vr_data_inicial          DATE;
      vr_data_final            DATE;    --> Data Final
      vr_dia_data_final        INTEGER; --> Dia de vencimento
      vr_mes_data_final        INTEGER; --> Mes de vencimento
      vr_ano_data_final        INTEGER; --> Ano de vencimento

      -- Variaveis tratamento de erros
      vr_cdcritic              crapcri.cdcritic%TYPE;
      vr_dscritic              crapcri.dscritic%TYPE;
      vr_exc_erro              EXCEPTION;

      -- Busca os dados da linha de credito
      CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                       ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT txmensal
          FROM craplcr
         WHERE cdcooper = pr_cdcooper
           AND cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;

      -- Busca os dados da taxa do CDI
      CURSOR cr_craptxi (pr_dtiniper IN craptxi.dtiniper%TYPE) IS
        SELECT vlrdtaxa
          FROM craptxi
         WHERE cddindex = 1 -- CDI
           AND dtiniper = pr_dtiniper;
      rw_craptxi cr_craptxi%ROWTYPE;

      -- Procedure para calcular a taxa no periodo no mês anterior
      PROCEDURE pc_calc_taxa_periodo_mes_ant (pr_cdcooper              IN  crapdat.cdcooper%TYPE
                                             ,pr_vlrdtaxa              IN  craptxi.vlrdtaxa%TYPE
                                             ,pr_dtvencto              IN  crappep.dtvencto%TYPE
                                             ,pr_taxa_periodo_anterior OUT NUMBER
                                             ,pr_cdcritic              OUT crapcri.cdcritic%TYPE
                                             ,pr_dscritic              OUT crapcri.dscritic%TYPE) IS
        vr_qtdia_uteis PLS_INTEGER; 
      BEGIN
        -- Calcula a diferenca entre duas datas e retorna os dias Uteis
        pc_calcula_qtd_dias_uteis(pr_cdcooper    => pr_cdcooper, 
                                  pr_datainicial => ADD_MONTHS(pr_dtvencto, - 1), -- Data de vencimento da parcela anterior
                                  pr_datafinal   => last_day(ADD_MONTHS(pr_dtvencto, - 1)), -- Final do mes da parcela anterior
                                  pr_qtdiaute    => vr_qtdia_uteis,
                                  pr_cdcritic    => vr_cdcritic,
                                  pr_dscritic    => vr_dscritic);
                                  
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Calculo da taxa no periodo Anterior
        pr_taxa_periodo_anterior := ROUND(POWER((1 + (pr_vlrdtaxa / 100)),(vr_qtdia_uteis / 252)) - 1,8);

      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro na procedure pc_calc_taxa_periodo_mes_ant: ' || SQLERRM; 
      END pc_calc_taxa_periodo_mes_ant;

    BEGIN
      pr_tab_parcelas.DELETE;
      -- Buscar a taxa de juros
      OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                     ,pr_cdlcremp => pr_cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
      -- se achou registro
      IF cr_craplcr%FOUND THEN
        CLOSE cr_craplcr;
        -- Taxa de juros remunerados mensal
        vr_txdiaria := POWER(1 + (NVL(rw_craplcr.txmensal,0) / 100),(1 / 30)) - 1;
      ELSE
        CLOSE cr_craplcr;
        -- Gerar erro
        vr_cdcritic := 363;
        RAISE vr_exc_erro;
      END IF;

      -- Buscar a taxa acumulada do CDI
      OPEN cr_craptxi (pr_dtiniper => pr_dtmvtoan);
      FETCH cr_craptxi INTO rw_craptxi;
      -- se achou registro
      IF cr_craptxi%FOUND THEN
        CLOSE cr_craptxi;
        -- Taxa CDI
        vr_vlrdtaxa := (POWER(1 + (nvl(rw_craptxi.vlrdtaxa,0) / 100),1) - 1) * 100;
      ELSE
        CLOSE cr_craptxi;
        -- Gerar erro
        vr_dscritic := 'Taxa do CDI nao cadastrada.';
        RAISE vr_exc_erro;
      END IF;       

      vr_data_inicial := pr_dtmvtolt;
      vr_data_final   := pr_dtdpagto;
      -- Condicao para verificar se a Data de Pagamento é no mesmo mês da data de movimento
      IF TO_CHAR(vr_data_inicial,'mmyyyy') <> TO_CHAR(pr_dtdpagto,'mmyyyy') THEN
        -- A "vr_data_inicial" inicia no ultimo dia do mês anterior a data de pagamento, exemplo:
        -- Data de Pagamento: 13/08/2017
        -- Data Inicial: 31/07/2017
        vr_data_inicial := last_day(ADD_MONTHS(pr_dtmvtolt, - 1));
      END IF;

      -- Calcular o Fator Price para cada parcela
      FOR vr_nrparepr IN 1..pr_qtpreemp LOOP

        -- Guardar dia, mes e ano separamente do vencimento
        vr_dia_data_final := to_char(vr_data_final, 'dd');
        vr_mes_data_final := to_char(vr_data_final, 'mm');
        vr_ano_data_final := to_char(vr_data_final, 'yyyy');

        -- Calcula a diferenca entre duas datas e retorna os dias corridos
        EMPR0001.pc_calc_dias360(pr_ehmensal => FALSE
                                ,pr_dtdpagto => to_char(pr_dtdpagto,'dd')       -- Dia do primeiro vencimento do emprestimo
                                ,pr_diarefju => to_char(vr_data_inicial,'dd')   -- Dia da data de referência da última vez que rodou juros
                                ,pr_mesrefju => to_char(vr_data_inicial,'mm')   -- Mes da data de referência da última vez que rodou juros
                                ,pr_anorefju => to_char(vr_data_inicial,'yyyy') -- Ano da data de referência da última vez que rodou juros
                                ,pr_diafinal => vr_dia_data_final               -- Dia data final
                                ,pr_mesfinal => vr_mes_data_final               -- Mes data final
                                ,pr_anofinal => vr_ano_data_final               -- Ano data final
                                ,pr_qtdedias => vr_qtdia_corridos);             -- Quantidade de dias calculada

        IF pr_tab_parcelas.EXISTS(vr_nrparepr - 1) THEN
          -- Calcula a diferenca entre duas datas e retorna os dias Uteis
          pc_calcula_qtd_dias_uteis(pr_cdcooper    => pr_cdcooper, 
                                    pr_datainicial => last_day(vr_data_inicial),
                                    pr_datafinal   => vr_data_final, 
                                    pr_qtdiaute    => vr_qtdia_uteis,
                                    pr_cdcritic    => vr_cdcritic,
                                    pr_dscritic    => vr_dscritic);
        ELSE
          -- Calcula a diferenca entre duas datas e retorna os dias Uteis
          pc_calcula_qtd_dias_uteis(pr_cdcooper    => pr_cdcooper, 
                                    pr_datainicial => vr_data_inicial, 
                                    pr_datafinal   => vr_data_final, 
                                    pr_qtdiaute    => vr_qtdia_uteis,
                                    pr_cdcritic    => vr_cdcritic,
                                    pr_dscritic    => vr_dscritic);
        END IF;

        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;      

        pr_tab_parcelas(vr_nrparepr).nrparepr             := vr_nrparepr;
        pr_tab_parcelas(vr_nrparepr).dtvencto             := vr_data_final;      
        -- Calculo da taxa no Periodo
        pr_tab_parcelas(vr_nrparepr).taxa_periodo         := POWER((1 + (vr_vlrdtaxa / 100)),(vr_qtdia_uteis / 252)) - 1;      
        -- Condicao para verificar se a parcela anterior já foi calculada, pois o juros nominais é acumulativo
        IF pr_tab_parcelas.EXISTS(vr_nrparepr - 1) THEN
                                                               -- Fator Acumulado da parcela Anterior
          pr_tab_parcelas(vr_nrparepr).fator_juros_nominais := (pr_tab_parcelas(vr_nrparepr - 1).fator_acumulado * 
                                                               -- Calculo do Juros Nominais
                                                               (POWER(1 + vr_txdiaria,vr_qtdia_corridos) - 1)) +
                                                               -- Fator Juros Nominais da parcela Anterior
                                                               pr_tab_parcelas(vr_nrparepr - 1).fator_juros_nominais;

          -- Procedure para calcular a taxa no periodo no mes anterior
          pc_calc_taxa_periodo_mes_ant(pr_cdcooper              => pr_cdcooper
                                      ,pr_vlrdtaxa              => vr_vlrdtaxa
                                      ,pr_dtvencto              => pr_tab_parcelas(vr_nrparepr).dtvencto
                                      ,pr_taxa_periodo_anterior => vr_taxa_periodo_anterior
                                      ,pr_cdcritic              => vr_cdcritic
                                      ,pr_dscritic              => vr_dscritic);
                                      
          -- Condicao para verificar se houve erro
          IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          -- Calculo do Fator Correcao Monetaria         -- Fator Acumulado da parcela Anterior
          pr_tab_parcelas(vr_nrparepr).fator_correcao := (pr_tab_parcelas(vr_nrparepr - 1).fator_acumulado * 
                                                          (((1 + vr_taxa_periodo_anterior) * pr_tab_parcelas(vr_nrparepr).taxa_periodo) + vr_taxa_periodo_anterior)) +
                                                         pr_tab_parcelas(vr_nrparepr - 1).fator_correcao;

        ELSE
          -- Calculo do Fator Juros Nominais 
          pr_tab_parcelas(vr_nrparepr).fator_juros_nominais := POWER(1 + vr_txdiaria,vr_qtdia_corridos);
          -- Calculo do Fator Correcao Monetaria
          pr_tab_parcelas(vr_nrparepr).fator_correcao       := 1 * (1 + pr_tab_parcelas(vr_nrparepr).taxa_periodo);        
        END IF;

        -- Calculo do Fator Acumulado
        pr_tab_parcelas(vr_nrparepr).fator_acumulado := pr_tab_parcelas(vr_nrparepr).fator_juros_nominais + pr_tab_parcelas(vr_nrparepr).fator_correcao - 1;
        -- Calculo fator Price
        pr_tab_parcelas(vr_nrparepr).fator_price := 1 / pr_tab_parcelas(vr_nrparepr).fator_acumulado;
        -- Armazenar o valor price total
        vr_fator_price_total := vr_fator_price_total + pr_tab_parcelas(vr_nrparepr).fator_price;
        -- Incrementar a data de pagamento para o proximo mês
        vr_data_inicial := vr_data_final;
        vr_data_final   := ADD_MONTHS(vr_data_final,1);
      END LOOP;

      -- Percorrer todas as parcelas e calcular o valor de cada parcela
      FOR vr_nrparepr IN 1..pr_tab_parcelas.COUNT LOOP
        pr_tab_parcelas(vr_nrparepr).vlparepr := pr_vlsdeved / vr_fator_price_total;
      END LOOP;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variavel de saida
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        -- Apenas retornar a variavel de saida
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Erro na procedure pc_calcula_parcelas_pos_fixado: ' || SQLERRM;

    END;

  END pc_calcula_parcelas_pos_fixado;

  PROCEDURE pc_calcula_iof_pos_fixado(pr_vltariof OUT NUMBER                    --> Valor de IOF
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_calcula_iof_pos_fixado
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Maio/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para calcular o IOF para Pos-Fixado.

       Alteracoes: 
    ............................................................................. */

    DECLARE
      -- Variaveis tratamento de erros
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      vr_exc_erro EXCEPTION;

    BEGIN

      pr_vltariof := 2; -- JFF

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variavel de saida
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        -- Apenas retornar a variavel de saida
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Erro na procedure pc_calcula_iof_pos_fixado: ' || SQLERRM;

    END;

  END pc_calcula_iof_pos_fixado;

  PROCEDURE pc_valida_dados_pos_fixado(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa
                                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE     --> Data do movimento atual
                                      ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE     --> Codigo da linha de credito
                                      ,pr_vlemprst  IN crapepr.vlemprst%TYPE     --> Valor do emprestimo
                                      ,pr_qtparepr  IN crapepr.qtpreemp%TYPE     --> Quantidade de parcelas
                                      ,pr_dtlibera  IN crawepr.dtlibera%TYPE     --> Data da liberacao
                                      ,pr_dtdpagto  IN crapepr.dtdpagto%TYPE     --> Data do pagamento
                                      ,pr_dtcarenc  IN crawepr.dtcarenc%TYPE     --> Data da Carencia
                                      ,pr_flgpagto  IN crapepr.flgpagto%TYPE     --> Debito Folha: 0-Nao/1-Sim
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_valida_dados_pos_fixado
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Abril/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para validar as parcelas do Pos-Fixado.

       Alteracoes: 
    ............................................................................. */

    DECLARE
      -- Variaveis locais
      vr_blnfound            BOOLEAN;
      vr_vlminimo_emprestado tbepr_posfix_param.vlminimo_emprestado%TYPE;
      vr_vlmaximo_emprestado tbepr_posfix_param.vlmaximo_emprestado%TYPE;
      vr_qtdminima_parcela   tbepr_posfix_param.qtdminima_parcela%TYPE;
      vr_qtdmaxima_parcela   tbepr_posfix_param.qtdmaxima_parcela%TYPE;

      -- Variaveis tratamento de erros
      vr_cdcritic            crapcri.cdcritic%TYPE;
      vr_dscritic            crapcri.dscritic%TYPE;
      vr_exc_erro            EXCEPTION;

      -- Busca os dados da linha de credito
      CURSOR cr_craplcr (pr_cdcooper IN craplcr.cdcooper%TYPE
                        ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT tpdescto
              ,dslcremp
              ,nrinipre
              ,nrfimpre
          FROM craplcr 
         WHERE cdcooper = pr_cdcooper
           AND cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;

    BEGIN
      -- Buscar a taxa de juros
      OPEN cr_craplcr (pr_cdcooper => pr_cdcooper
                      ,pr_cdlcremp => pr_cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_craplcr%FOUND;
      -- Fecha cursor
      CLOSE cr_craplcr;

      -- Se NAO achou
      IF NOT vr_blnfound THEN
        -- Gerar erro
        vr_cdcritic := 363;
        RAISE vr_exc_erro;
      END IF;

      -- Se for linha de Emprestimo Consignado
      IF rw_craplcr.tpdescto = 2 THEN
        vr_dscritic := 'Linha nao permitida para esse produto.';
        RAISE vr_exc_erro;
      END IF;    

      -- Se na decricao tiver CDC
      IF UPPER(TRIM(rw_craplcr.dslcremp)) LIKE '%CDC%' THEN
        vr_dscritic := 'Linha nao permitida para esse produto.';
        RAISE vr_exc_erro;
      END IF;

      -- Se na decricao tiver CREDITO DIRETO AO COOPERADO
      IF UPPER(TRIM(rw_craplcr.dslcremp)) LIKE '%CREDITO DIRETO AO COOPERADO%' THEN
        vr_dscritic := 'Linha nao permitida para esse produto.';
        RAISE vr_exc_erro;
      END IF;

      -- Se for debito em folha
      IF pr_flgpagto = 1 THEN
        vr_dscritic := 'Tipo de debito folha bloqueado para todas as operacoes.';
        RAISE vr_exc_erro;
      END IF;

      -- Se a quantidade de parcelas nao estiver dentro do limite
      IF pr_qtparepr < rw_craplcr.nrinipre OR
         pr_qtparepr > rw_craplcr.nrfimpre THEN
         vr_dscritic := 'Quantidade de parcelas deve estar dentro '
                     || 'da faixa limite parametrizada para a '
                     || 'linha de credito.';
         RAISE vr_exc_erro;
      END IF;

      -- Se data da liberacao menor que atual
      IF pr_dtlibera < pr_dtmvtolt THEN
        vr_dscritic := 'Data de Liberacao de Emprestimo nao pode '
                    || 'ser menor que data atual de movimento.';
        RAISE vr_exc_erro;
      END IF;

      -- Se data de pagamento menor que atual
      IF pr_dtdpagto < pr_dtmvtolt THEN
        vr_dscritic := 'Data de pagamento da primeira parcela '
                    || 'nao pode ser menor que data atual de movimento.';
        RAISE vr_exc_erro;
      END IF;

      -- Se mes do pagamento for menor ou igual ao da carencia
      IF TO_CHAR(pr_dtdpagto, 'MM') <= TO_CHAR(pr_dtcarenc, 'MM') THEN
        vr_dscritic := 'O campo Data de Pagamento nao pode ser menor ou igual ao mes do campo Data Pagto 1a Carencia.';
        RAISE vr_exc_erro;
      END IF;
      
      -- Busca os dados parametrizados
      TELA_ATENDA_EMPRESTIMO.pc_busca_prmpos(pr_vlminimo_emprestado => vr_vlminimo_emprestado
                                            ,pr_vlmaximo_emprestado => vr_vlmaximo_emprestado
                                            ,pr_qtdminima_parcela   => vr_qtdminima_parcela  
                                            ,pr_qtdmaxima_parcela   => vr_qtdmaxima_parcela  
                                            ,pr_cdcritic            => vr_cdcritic
                                            ,pr_dscritic            => vr_dscritic);
      -- Se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Se valor emprestado for menor que o minimo
      IF pr_vlemprst < vr_vlminimo_emprestado THEN
        vr_dscritic := 'O campo valor do emprestimo nao pode ser menor que o valor minimo R$ ' || to_char(vr_vlminimo_emprestado,'FM99G999G990D00') || ' parametrizado.';
        RAISE vr_exc_erro;
      END IF;

      -- Se possui valor maximo cadastrado e valor emprestado for maior que o maximo
      IF vr_vlmaximo_emprestado > 0 AND pr_vlemprst > vr_vlmaximo_emprestado THEN
        vr_dscritic := 'O campo valor do emprestimo nao pode ser maior que o valor maximo R$ ' || to_char(vr_vlmaximo_emprestado,'FM99G999G990D00') || ' parametrizado.';
        RAISE vr_exc_erro;
      END IF;

      -- Se quantidade for menor que a minima
      IF pr_qtparepr < vr_qtdminima_parcela THEN
        vr_dscritic := 'O campo quantidade de parcelas nao pode ser menor que a quantidade minima ' || vr_qtdminima_parcela || ' parametrizada.';
        RAISE vr_exc_erro;
      END IF;

      -- Se possui quantidade cadastrada e quantidade for maior que a maxima
      IF vr_qtdmaxima_parcela > 0 AND pr_qtparepr > vr_qtdmaxima_parcela THEN
        vr_dscritic := 'O campo quantidade de parcelas nao pode ser maior que a quantidade maxima ' || vr_qtdmaxima_parcela || ' parametrizada.';
        RAISE vr_exc_erro;
      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variavel de saida
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        -- Apenas retornar a variavel de saida
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Erro na procedure pc_valida_dados_pos_fixado: ' || SQLERRM;

    END;

  END pc_valida_dados_pos_fixado;

  PROCEDURE pc_grava_parcel_pos_fixado(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Numero da Conta
                                      ,pr_dtmvtoan  IN crapdat.dtmvtoan%TYPE     --> Data do movimento anterior
                                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE     --> Data do movimento atual
                                      ,pr_nrctremp  IN crapepr.nrctremp%TYPE     --> Numero do contrato
                                      ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE     --> Codigo da linha de credito
                                      ,pr_vlemprst  IN crapepr.vlemprst%TYPE     --> Valor do emprestimo
                                      ,pr_qtparepr  IN crapepr.qtpreemp%TYPE     --> Quantidade de parcelas
                                      ,pr_dtdpagto  IN crapepr.dtdpagto%TYPE     --> Data do pagamento
                                      ,pr_vlpreemp OUT crapepr.vlpreemp%TYPE     --> Valor da prestacao
                                      ,pr_txdiaria OUT crawepr.txdiaria%TYPE     --> Taxa diaria
                                      ,pr_txmensal OUT crawepr.txmensal%TYPE     --> Taxa mensal
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_grava_parcel_pos_fixado
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Abril/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para gravar as parcelas do Pos-Fixado.

       Alteracoes: 
    ............................................................................. */

    DECLARE
      -- Variaveis locais
      vr_ind_parcelas BINARY_INTEGER;
      vr_tab_parcelas typ_tab_parcelas;
      vr_txdiaria     craplcr.txdiaria%TYPE;
      vr_vlpreemp     crapepr.vlpreemp%TYPE := 0;

      -- Variaveis tratamento de erros
      vr_cdcritic     crapcri.cdcritic%TYPE;
      vr_dscritic     crapcri.dscritic%TYPE;
      vr_exc_erro     EXCEPTION;

      -- Busca os dados da linha de credito
      CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                       ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT txmensal
          FROM craplcr 
         WHERE cdcooper = pr_cdcooper
           AND cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;

    BEGIN

      BEGIN
        DELETE
          FROM crappep
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;
      EXCEPTION
	      WHEN OTHERS THEN
          vr_dscritic := 'Problema ao deletar dados da crappep: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      -- Chama o calculo das parcelas
      pc_calcula_parcelas_pos_fixado(pr_cdcooper     => pr_cdcooper
                                    ,pr_dtmvtoan     => pr_dtmvtoan
                                    ,pr_dtmvtolt     => pr_dtmvtolt
                                    ,pr_cdlcremp     => pr_cdlcremp
                                    ,pr_qtpreemp     => pr_qtparepr
                                    ,pr_dtdpagto     => pr_dtdpagto
                                    ,pr_vlsdeved     => pr_vlemprst
                                    ,pr_tab_parcelas => vr_tab_parcelas
                                    ,pr_cdcritic     => vr_cdcritic
                                    ,pr_dscritic     => vr_dscritic);
      -- Se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Buscar Primeiro registro
      vr_ind_parcelas := vr_tab_parcelas.FIRST;

      -- Percorrer todos os registros
      WHILE vr_ind_parcelas IS NOT NULL LOOP

        -- Guarda a prestacao apenas uma vez
        IF vr_vlpreemp = 0 THEN
          vr_vlpreemp := vr_tab_parcelas(vr_ind_parcelas).vlparepr;
        END IF;

        BEGIN
          INSERT INTO crappep
                     (cdcooper
                     ,nrdconta
                     ,nrctremp
                     ,nrparepr
                     ,vlparepr
                     ,vlsdvpar
                     ,vlsdvsji
                     ,dtvencto
                     ,inliquid)
               VALUES(pr_cdcooper
                     ,pr_nrdconta
                     ,pr_nrctremp
                     ,vr_tab_parcelas(vr_ind_parcelas).nrparepr
                     ,vr_tab_parcelas(vr_ind_parcelas).vlparepr
                     ,vr_tab_parcelas(vr_ind_parcelas).vlparepr
                     ,vr_tab_parcelas(vr_ind_parcelas).vlparepr
                     ,vr_tab_parcelas(vr_ind_parcelas).dtvencto
                     ,0);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao incluir dados na crappep: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        -- Proximo Registro
        vr_ind_parcelas:= vr_tab_parcelas.NEXT(vr_ind_parcelas);
      END LOOP;

      -- Buscar a taxa de juros
      OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                     ,pr_cdlcremp => pr_cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
      CLOSE cr_craplcr;

      -- Taxa de juros remunerados mensal
      vr_txdiaria := POWER(1 + (NVL(rw_craplcr.txmensal,0) / 100),(1 / 30)) - 1;

      BEGIN
        UPDATE crawepr
           SET vlpreemp = vr_vlpreemp
              ,txdiaria = vr_txdiaria
              ,txmensal = rw_craplcr.txmensal
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;
      EXCEPTION
	      WHEN OTHERS THEN
          vr_dscritic := 'Problema ao alterar dados da crawepr: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      -- Retorna os valores
      pr_vlpreemp := vr_vlpreemp;
      pr_txdiaria := vr_txdiaria;
      pr_txmensal := rw_craplcr.txmensal;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variavel de saida
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        -- Apenas retornar a variavel de saida
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Erro na procedure pc_grava_parcel_pos_fixado: ' || SQLERRM;

    END;

  END pc_grava_parcel_pos_fixado;

  PROCEDURE pc_busca_vl_prest_pos_prog(pr_cdcooper  IN crapepr.cdcooper%TYPE     --> Codigo da Cooperativa
                                      ,pr_dtmvtoan  IN crapdat.dtmvtoan%TYPE     --> Data do movimento anterior
                                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE     --> Data do movimento atual
                                      ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE     --> Codigo da linha de credito
                                      ,pr_qtpreemp  IN crapepr.qtpreemp%TYPE     --> Quantidade de prestacoes
                                      ,pr_dtdpagto  IN crapepr.dtdpagto%TYPE     --> Data do pagamento
                                      ,pr_vlsdeved  IN crapepr.vlsdeved%TYPE     --> Valor do saldo devedor
                                      ,pr_vlpreemp OUT crapepr.vlpreemp%TYPE     --> Valor da prestacao
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_busca_vl_prest_pos_prog
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Abril/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para buscar o valor da prestacao do Pos-Fixado.

       Alteracoes: 
    ............................................................................. */

    DECLARE
      -- Variaveis Calculo da Parcela
      vr_tab_parcelas typ_tab_parcelas;

      -- Variaveis tratamento de erros
      vr_cdcritic     crapcri.cdcritic%TYPE;
      vr_dscritic     crapcri.dscritic%TYPE;
      vr_exc_erro     EXCEPTION;

    BEGIN
      -- Chama o calculo da parcela
      pc_calcula_parcelas_pos_fixado(pr_cdcooper     => pr_cdcooper
                                    ,pr_dtmvtoan     => pr_dtmvtoan
                                    ,pr_dtmvtolt     => pr_dtmvtolt
                                    ,pr_cdlcremp     => pr_cdlcremp
                                    ,pr_qtpreemp     => pr_qtpreemp
                                    ,pr_dtdpagto     => pr_dtdpagto
                                    ,pr_vlsdeved     => pr_vlsdeved
                                    ,pr_tab_parcelas => vr_tab_parcelas
                                    ,pr_cdcritic     => vr_cdcritic
                                    ,pr_dscritic     => vr_dscritic);
      -- Se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Se possui dados
      IF vr_tab_parcelas.COUNT > 0 THEN
        pr_vlpreemp := vr_tab_parcelas(vr_tab_parcelas.FIRST).vlparepr;
      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variavel de saida
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        -- Apenas retornar a variavel de saida
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Erro na procedure pc_busca_vl_prest_pos_prog: ' || SQLERRM;

    END;

  END pc_busca_vl_prest_pos_prog;

  PROCEDURE pc_alt_numero_parcelas_pos(pr_cdcooper      IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa
                                      ,pr_nrdconta      IN crapass.nrdconta%TYPE     --> Numero da Conta
                                      ,pr_nrctremp_old  IN crapepr.nrctremp%TYPE     --> Numero do contrato
                                      ,pr_nrctremp_new  IN crapepr.nrctremp%TYPE     --> Numero do contrato
                                      ,pr_cdcritic     OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                      ,pr_dscritic     OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_alt_numero_parcelas_pos
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Abril/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para alterar o numero de contrato nas pascelas.

       Alteracoes: 
    ............................................................................. */

    DECLARE
      -- Variaveis tratamento de erros
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      vr_exc_erro EXCEPTION;

    BEGIN

      BEGIN
        UPDATE crappep
           SET nrctremp = pr_nrctremp_new
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp_old;
      EXCEPTION
	      WHEN OTHERS THEN
          vr_dscritic := 'Problema ao alterar dados da crappep: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variavel de saida
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        -- Apenas retornar a variavel de saida
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Erro na procedure pc_alt_numero_parcelas_pos: ' || SQLERRM;

    END;

  END pc_alt_numero_parcelas_pos;

  PROCEDURE pc_exclui_prop_pos_fixado(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Numero da Conta
                                     ,pr_nrctremp  IN crapepr.nrctremp%TYPE     --> Numero do contrato
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_exclui_prop_pos_fixado
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Abril/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para excluir proposta do Pos-Fixado.

       Alteracoes: 
    ............................................................................. */

    DECLARE
      -- Variaveis tratamento de erros
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      vr_exc_erro EXCEPTION;

    BEGIN

      BEGIN
        DELETE
          FROM crappep
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;
      EXCEPTION
	      WHEN OTHERS THEN
          vr_dscritic := 'Problema ao excluir dados da crappep: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variavel de saida
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        -- Apenas retornar a variavel de saida
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Erro na procedure pc_exclui_prop_pos_fixado: ' || SQLERRM;

    END;

  END pc_exclui_prop_pos_fixado;

  PROCEDURE pc_efetua_credito_conta(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa
                                   ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Numero da Conta
                                   ,pr_nrctremp  IN crawepr.nrctremp%TYPE     --> Numero do contrato
                                   ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE     --> Data do movimento atual
                                   ,pr_cdprogra  IN crapprg.cdprogra%TYPE     --> Codigo Programa
                                   ,pr_inpessoa  IN crapass.inpessoa%TYPE     --> Tipo de pessoa
                                   ,pr_cdagenci  IN crapage.cdagenci%TYPE     --> Codigo da agencia
                                   ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE     --> Numero do caixa
                                   ,pr_cdpactra  IN crapage.cdagenci%TYPE     --> Codigo do PA de Transacao
                                   ,pr_cdoperad  IN crapope.cdoperad%TYPE     --> Codigo do Operador
                                   ,pr_vltottar OUT NUMBER                    --> Valor da tarifa
                                   ,pr_vltariof OUT NUMBER                    --> Valor do IOF
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                   ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_efetua_credito_conta
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Maio/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para efetuar o credito do emprestimo direto na conta online.

       Alteracoes: 
    ............................................................................. */

    DECLARE

      -- Busca o associado
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.vllimcre
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Cursor de Emprestimo
      CURSOR cr_crawepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT qtpreemp
              ,vlpreemp
              ,vlemprst
              ,dtdpagto
              ,dtlibera
              ,cdfinemp
              ,cdlcremp
              ,tpemprst
          FROM crawepr
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;
      rw_crawepr cr_crawepr%ROWTYPE;

      -- Cursor de Portabilidade
      CURSOR cr_portabilidade(pr_cdcooper IN crapcop.cdcooper%TYPE
                             ,pr_nrdconta IN crapcop.nrdconta%TYPE
                             ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
        SELECT 1
          FROM tbepr_portabilidade
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;
      rw_portabilidade cr_portabilidade%ROWTYPE;

      -- Cursor da Linha de Credito
      CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                       ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT cdusolcr
              ,tpctrato
              ,flgcrcta
          FROM craplcr
         WHERE cdcooper = pr_cdcooper
           AND cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;

      -- Cursor dos Bens da Proposta
      CURSOR cr_crapbpr(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT dscatbem
          FROM crapbpr
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND tpctrpro = 90
           AND nrctrpro = pr_nrctremp
           AND flgalien = 1;

      -- Cursor generico de calendario
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

      -- Variaveis locais
      vr_vltottar NUMBER := 0;
      vr_vltariof NUMBER := 0;
      vr_cdhistor INTEGER;
      vr_cdhisest INTEGER;
      vr_vlrtarif NUMBER;
      vr_vltrfesp NUMBER;
      vr_dtdivulg DATE;
      vr_dtvigenc DATE;
      vr_cdfvlcop INTEGER;
      vr_cdhistmp craphis.cdhistor%TYPE;
      vr_cdfvltmp crapfco.cdfvlcop%TYPE;
      vr_cdlantar craplat.cdlantar%TYPE;
      vr_flgcrcta craplcr.flgcrcta%TYPE;
      vr_blnachou BOOLEAN;
      vr_cdbattar VARCHAR2(100) := ' ';
      vr_flgoutrosbens BOOLEAN;
      vr_index_saldo   PLS_INTEGER;
      vr_vlsldisp      NUMBER;
      vr_tab_saldos    EXTR0001.typ_tab_saldos;
      vr_rowid         ROWID;

      -- Variaveis tratamento de erros
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      vr_exc_erro EXCEPTION;
      vr_tab_erro GENE0001.typ_tab_erro;
      vr_des_reto VARCHAR2(3);

    BEGIN
      -- Seleciona o calendario
      OPEN  BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      vr_blnachou := BTCH0001.cr_crapdat%FOUND;
      CLOSE BTCH0001.cr_crapdat;
      -- Se NAO achou
      IF NOT vr_blnachou THEN
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
      END IF;

      -- Busca o associado
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      vr_blnachou := cr_crapass%FOUND;
      CLOSE cr_crapass;
      -- Se NAO achou
      IF NOT vr_blnachou THEN
        vr_cdcritic := 9;
        RAISE vr_exc_erro;
      END IF;

      -- Buscar dados do emprestimo
      OPEN cr_crawepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crawepr INTO rw_crawepr;
      vr_blnachou := cr_crawepr%FOUND;
      CLOSE cr_crawepr;
      -- Se NAO achou
      IF NOT vr_blnachou THEN
        vr_cdcritic := 510;
        RAISE vr_exc_erro;
      END IF;

      -- Selecionar Linha de Credito
      OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                     ,pr_cdlcremp => rw_crawepr.cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
      vr_blnachou := cr_craplcr%FOUND;
      CLOSE cr_craplcr;
      -- Se NAO achou
      IF NOT vr_blnachou THEN
        vr_dscritic := 'Linha de Credito nao encontrada.';
        RAISE vr_exc_erro;
      END IF;

      -- Consulta o registro na tabela de portabilidade
      OPEN cr_portabilidade(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrctremp => pr_nrctremp);
      FETCH cr_portabilidade INTO rw_portabilidade;
      vr_blnachou := cr_portabilidade%FOUND;
      CLOSE cr_portabilidade;
      -- Se NAO achou
      IF NOT vr_blnachou THEN
        vr_flgcrcta := rw_craplcr.flgcrcta;
      ELSE
        vr_flgcrcta := 0;
      END IF;

      IF vr_flgcrcta = 1 THEN
        -- Efetua o credito na conta corrente do cooperado
        EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                      ,pr_dtmvtolt => pr_dtmvtolt   --> Movimento atual
                                      ,pr_cdagenci => pr_cdagenci   --> Codigo da agencia
                                      ,pr_cdbccxlt => 100           --> Numero do caixa
                                      ,pr_cdoperad => pr_cdoperad   --> Codigo do Operador
                                      ,pr_cdpactra => pr_cdpactra   --> PA da transacao
                                      ,pr_nrdolote => 8456          --> Numero do Lote
                                      ,pr_nrdconta => pr_nrdconta   --> Numero da conta
                                      ,pr_cdhistor => 15            --> Codigo historico
                                      ,pr_vllanmto => rw_crawepr.vlemprst --> Valor do emprestimo
                                      ,pr_nrparepr => 0             --> Numero parcelas emprestimo
                                      ,pr_nrctremp => pr_nrctremp   --> Numero do contrato de emprestimo
                                      ,pr_des_reto => vr_des_reto   --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro); --> Tabela com possives erros
        -- Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
          -- Se possui algum erro na tabela de erros
          IF vr_tab_erro.COUNT() > 0 THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao criar o lancamento de emprestimo na conta.';
          END IF;
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Calcula o IOF
      EMPR0001.pc_calcula_iof_epr(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_dtmvtolt => pr_dtmvtolt
                                 ,pr_inpessoa => pr_inpessoa
                                 ,pr_cdlcremp => rw_crawepr.cdlcremp
                                 ,pr_qtpreemp => rw_crawepr.qtpreemp
                                 ,pr_vlpreemp => rw_crawepr.vlpreemp
                                 ,pr_vlemprst => rw_crawepr.vlemprst
                                 ,pr_dtdpagto => rw_crawepr.dtdpagto
                                 ,pr_dtlibera => rw_crawepr.dtlibera
                                 ,pr_tpemprst => rw_crawepr.tpemprst
                                 ,pr_valoriof => vr_vltariof
                                 ,pr_dscritic => vr_dscritic);
      -- Se ocorreu erro
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Se possuir IOF para cobranca
      IF vr_vltariof > 0 THEN

        -- Lanca o IOF na conta corrente do cooperado
        EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                      ,pr_dtmvtolt => pr_dtmvtolt   --> Movimento atual
                                      ,pr_cdagenci => pr_cdagenci   --> Codigo da agencia
                                      ,pr_cdbccxlt => 100           --> Numero do caixa
                                      ,pr_cdoperad => pr_cdoperad   --> Codigo do Operador
                                      ,pr_cdpactra => pr_cdpactra   --> PA da transacao
                                      ,pr_nrdolote => 10025         --> Numero do Lote
                                      ,pr_nrdconta => pr_nrdconta   --> Numero da conta
                                      ,pr_cdhistor => 322           --> Codigo historico
                                      ,pr_vllanmto => vr_vltariof   --> Valor de IOF
                                      ,pr_nrparepr => 0             --> Numero parcelas emprestimo
                                      ,pr_nrctremp => pr_nrctremp   --> Numero do contrato de emprestimo
                                      ,pr_des_reto => vr_des_reto   --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro); --> Tabela com possives erros
        -- Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
          -- Se possui algum erro na tabela de erros
          IF vr_tab_erro.COUNT() > 0 THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao criar o lancamento de IOF na conta.';
          END IF;
          RAISE vr_exc_erro;
        END IF;

        BEGIN
          UPDATE crapcot
             SET crapcot.vliofepr = crapcot.vliofepr + vr_vltariof
                ,crapcot.vlbsiepr = crapcot.vlbsiepr + rw_crawepr.vlemprst
           WHERE crapcot.cdcooper = pr_cdcooper
             AND crapcot.nrdconta = pr_nrdconta;
        EXCEPTION 
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar a crapcot: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;

      END IF; -- vr_vltariof > 0

      -- Obter Saldo do Dia
      EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper
                                 ,pr_rw_crapdat => rw_crapdat
                                 ,pr_cdagenci   => pr_cdagenci
                                 ,pr_nrdcaixa   => pr_nrdcaixa
                                 ,pr_cdoperad   => pr_cdoperad
                                 ,pr_nrdconta   => pr_nrdconta
                                 ,pr_flgcrass   => FALSE
                                 ,pr_vllimcre   => rw_crapass.vllimcre
                                 ,pr_dtrefere   => rw_crapdat.dtmvtolt
                                 ,pr_des_reto   => vr_des_reto
                                 ,pr_tab_sald   => vr_tab_saldos
                                 ,pr_tipo_busca => 'A'
                                 ,pr_tab_erro   => vr_tab_erro);
      -- Buscar Indice
      vr_index_saldo := vr_tab_saldos.FIRST;
      IF vr_index_saldo IS NOT NULL THEN
        -- Saldo Disponivel
        vr_vlsldisp := ROUND(NVL(vr_tab_saldos(vr_index_saldo).vlsddisp, 0) +
                             NVL(vr_tab_saldos(vr_index_saldo).vllimcre, 0),2);
      END IF;

      -- Caso seja MICROCREDITO
      IF rw_craplcr.cdusolcr = 1 THEN

        IF pr_inpessoa = 1 THEN
          vr_cdbattar := 'MICROCREPF'; -- Microcredito Pessoa Fisica
        ELSE
          vr_cdbattar := 'MICROCREPJ'; -- Microcredito Pessoa Juridica
        END IF;
        
        -- Buscar tarifa emprestimo vigente
        TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                             ,pr_cdbattar => vr_cdbattar
                                             ,pr_vllanmto => rw_crawepr.vlemprst
                                             ,pr_cdprogra => pr_cdprogra
                                             ,pr_cdhistor => vr_cdhistor
                                             ,pr_cdhisest => vr_cdhisest
                                             ,pr_vltarifa => vr_vlrtarif
                                             ,pr_dtdivulg => vr_dtdivulg
                                             ,pr_dtvigenc => vr_dtvigenc
                                             ,pr_cdfvlcop => vr_cdfvlcop
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic
                                             ,pr_tab_erro => vr_tab_erro);
        -- Se ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          -- Se possui algum erro na tabela de erros
          IF vr_tab_erro.COUNT() > 0 THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Nao foi possivel carregar a tarifa.';
          END IF;
          RAISE vr_exc_erro;
        END IF;

      ELSE

        -- Buscar tarifa emprestimo
        TARI0001.pc_carrega_dados_tarifa_empr(pr_cdcooper => pr_cdcooper
                                             ,pr_cdlcremp => rw_crawepr.cdlcremp
                                             ,pr_cdmotivo => 'EM'
                                             ,pr_inpessoa => pr_inpessoa
                                             ,pr_vllanmto => rw_crawepr.vlemprst
                                             ,pr_cdprogra => pr_cdprogra
                                             ,pr_cdhistor => vr_cdhistor
                                             ,pr_cdhisest => vr_cdhisest
                                             ,pr_vltarifa => vr_vlrtarif
                                             ,pr_dtdivulg => vr_dtdivulg
                                             ,pr_dtvigenc => vr_dtvigenc
                                             ,pr_cdfvlcop => vr_cdfvlcop
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic
                                             ,pr_tab_erro => vr_tab_erro);
        -- Se ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          -- Se possui algum erro na tabela de erros
          IF vr_tab_erro.COUNT() > 0 THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Nao foi possivel carregar a tarifa.';
          END IF;
          RAISE vr_exc_erro;
        END IF;

        -- Codigo historico
        vr_cdhistmp := vr_cdhistor;
        vr_cdfvltmp := vr_cdfvlcop;

        -- Buscar tarifa emprestimo Especial
        TARI0001.pc_carrega_dados_tarifa_empr(pr_cdcooper => pr_cdcooper
                                             ,pr_cdlcremp => rw_crawepr.cdlcremp
                                             ,pr_cdmotivo => 'ES'
                                             ,pr_inpessoa => pr_inpessoa
                                             ,pr_vllanmto => rw_crawepr.vlemprst
                                             ,pr_cdprogra => pr_cdprogra
                                             ,pr_cdhistor => vr_cdhistor
                                             ,pr_cdhisest => vr_cdhisest
                                             ,pr_vltarifa => vr_vltrfesp
                                             ,pr_dtdivulg => vr_dtdivulg
                                             ,pr_dtvigenc => vr_dtvigenc
                                             ,pr_cdfvlcop => vr_cdfvlcop
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic
                                             ,pr_tab_erro => vr_tab_erro);
        -- Se ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          -- Se possui algum erro na tabela de erros
          IF vr_tab_erro.COUNT() > 0 THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Nao foi possivel carregar a tarifa.';
          END IF;
          RAISE vr_exc_erro;
        END IF;

        IF NVL(vr_cdhistor,0) = 0 AND NVL(vr_cdfvlcop,0) = 0 THEN
          -- Retornar Valores Salvos
          vr_cdhistor := vr_cdhistmp;
          vr_cdfvlcop := vr_cdfvltmp;
        END IF;

      END IF; -- rw_craplcr.cdusolcr = 1

      -- Total Tarifa a ser Cobrado
      vr_vltottar := NVL(vr_vlrtarif,0) + NVL(vr_vltrfesp,0);

      -- Se possuir Tarifa para cobranca
      IF vr_vltottar > 0 THEN

        -- Se possuir saldo
        IF vr_vlsldisp > vr_vltottar THEN

          -- Realizar lancamento tarifa
          TARI0001.pc_lan_tarifa_online(pr_cdcooper => pr_cdcooper   -- Codigo Cooperativa
                                       ,pr_cdagenci => pr_cdagenci   -- Codigo Agencia destino
                                       ,pr_nrdconta => pr_nrdconta   -- Numero da Conta Destino
                                       ,pr_cdbccxlt => 100           -- Codigo banco/caixa
                                       ,pr_nrdolote => 8452          -- Numero do Lote
                                       ,pr_tplotmov => 1             -- Tipo Lote
                                       ,pr_cdoperad => pr_cdoperad   -- Codigo Operador
                                       ,pr_dtmvtlat => pr_dtmvtolt   -- Data Tarifa
                                       ,pr_dtmvtlcm => pr_dtmvtolt   -- Data lancamento
                                       ,pr_nrdctabb => pr_nrdconta   -- Numero Conta BB
                                       ,pr_nrdctitg => TO_CHAR(pr_nrdconta,'fm00000000') -- Conta Integracao
                                       ,pr_cdhistor => vr_cdhistor   -- Codigo Historico
                                       ,pr_cdpesqbb => pr_nrctremp   -- Codigo pesquisa
                                       ,pr_cdbanchq => 0             -- Codigo Banco Cheque
                                       ,pr_cdagechq => 0             -- Codigo Agencia Cheque
                                       ,pr_nrctachq => 0             -- Numero Conta Cheque
                                       ,pr_flgaviso => FALSE         -- Flag Aviso
                                       ,pr_tpdaviso => 0             -- Tipo Aviso
                                       ,pr_vltarifa => vr_vltottar   -- Valor tarifa
                                       ,pr_nrdocmto => pr_nrctremp   -- Numero Documento
                                       ,pr_cdcoptfn => 0             -- Codigo Cooperativa Terminal
                                       ,pr_cdagetfn => 0             -- Codigo Agencia Terminal
                                       ,pr_nrterfin => 0             -- Numero Terminal Financeiro
                                       ,pr_nrsequni => 0             -- Numero Sequencial Unico
                                       ,pr_nrautdoc => 0             -- Numero Autenticacao Documento
                                       ,pr_dsidenti => NULL          -- Descricao Identificacao
                                       ,pr_cdfvlcop => vr_cdfvlcop   -- Codigo Faixa Valor Cooperativa
                                       ,pr_inproces => 1             -- Indicador Processo
                                       ,pr_cdlantar => vr_cdlantar   -- Codigo Lancamento tarifa
                                       ,pr_tab_erro => vr_tab_erro   -- Tabela de erro
                                       ,pr_cdcritic => vr_cdcritic   -- Codigo do erro
                                       ,pr_dscritic => vr_dscritic); -- Descricao do erro
          -- Se ocorreu erro
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            -- Se possui algum erro na tabela de erros
            IF vr_tab_erro.COUNT() > 0 THEN
              vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            ELSE
              vr_cdcritic := 0;
              vr_dscritic := 'Nao foi possivel lancar a tarifa.';
            END IF;
            RAISE vr_exc_erro;
          END IF;

        ELSE

          -- Criar lancamento automatico de tarifa
          TARI0001.pc_cria_lan_auto_tarifa(pr_cdcooper      => pr_cdcooper
                                          ,pr_nrdconta      => pr_nrdconta
                                          ,pr_dtmvtolt      => pr_dtmvtolt
                                          ,pr_cdhistor      => vr_cdhistor
                                          ,pr_vllanaut      => vr_vltottar
                                          ,pr_cdoperad      => pr_cdoperad
                                          ,pr_cdagenci      => pr_cdagenci
                                          ,pr_cdbccxlt 	    => 100
                                          ,pr_nrdolote      => 8452
                                          ,pr_tpdolote      => 1
                                          ,pr_nrdocmto      => pr_nrctremp
                                          ,pr_nrdctabb      => pr_nrdconta
                                          ,pr_nrdctitg      => GENE0002.fn_mask(pr_nrdconta,'99999999')
                                          ,pr_cdpesqbb      => 'Fato gerador tarifa:' || TO_CHAR(pr_nrctremp)
                                          ,pr_cdbanchq      => 0
                                          ,pr_cdagechq      => 0
                                          ,pr_nrctachq      => 0
                                          ,pr_flgaviso      => FALSE
                                          ,pr_tpdaviso      => 0
                                          ,pr_cdfvlcop      => vr_cdfvlcop
                                          ,pr_inproces      => 1
                                          ,pr_rowid_craplat => vr_rowid
                                          ,pr_tab_erro      => vr_tab_erro
                                          ,pr_cdcritic      => vr_cdcritic
                                          ,pr_dscritic      => vr_dscritic);
          -- Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          -- Subtrai do saldo o valor da tarifa
          vr_vlsldisp := vr_vlsldisp - vr_vltottar;

        END IF; -- vr_vlsldisp > vr_vltottar

      END IF; -- vr_vltottar > 0

      -- Limpa Variaveis de Tarifa     
      vr_vlrtarif := 0;
      vr_cdhistor := 0;
      vr_cdhisest := 0;
      vr_cdfvlcop := 0;

      -- 2 - Avaliacao de garantia de bem movel
      -- 3 - Avaliacao de garantia de bem imovel
      IF rw_craplcr.tpctrato IN (2,3) THEN

        IF rw_craplcr.tpctrato = 2 THEN -- Bem Movel
          IF pr_inpessoa = 1 THEN -- Fisica 
            vr_cdbattar := 'AVALBMOVPF'; -- Avaliacao de Garantia de Bem Movel - PF
          ELSE
            vr_cdbattar := 'AVALBMOVPJ'; -- Avaliacao de Garantia de Bem Movel - PJ
          END IF;
        ELSE -- Bens Imoveis
          IF pr_inpessoa = 1 THEN -- Fisica
            vr_cdbattar := 'AVALBIMVPF'; -- Avaliacao de Garantia de Bem Imovel - PF
          ELSE
            vr_cdbattar := 'AVALBIMVPJ'; -- Avaliacao de Garantia de Bem Imovel - PF
          END IF;    
        END IF;

        -- Busca Valor da Tarifa
        TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                             ,pr_cdbattar => vr_cdbattar
                                             ,pr_vllanmto => 1
                                             ,pr_cdprogra => pr_cdprogra
                                             ,pr_cdhistor => vr_cdhistor
                                             ,pr_cdhisest => vr_cdhisest
                                             ,pr_vltarifa => vr_vlrtarif
                                             ,pr_dtdivulg => vr_dtdivulg
                                             ,pr_dtvigenc => vr_dtvigenc
                                             ,pr_cdfvlcop => vr_cdfvlcop
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic
                                             ,pr_tab_erro => vr_tab_erro);
        -- Se ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          -- Se possui algum erro na tabela de erros
          IF vr_tab_erro.COUNT() > 0 THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Nao foi possivel carregar a tarifa.';
          END IF;
          RAISE vr_exc_erro;
        END IF;

        IF rw_craplcr.tpctrato = 2 THEN -- Bem Movel
          vr_flgoutrosbens := FALSE;

          FOR rw_crapbpr IN cr_crapbpr(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrctremp => pr_nrctremp) LOOP
            -- Se for carro, moto ou caminhao
            IF rw_crapbpr.dscatbem LIKE '%AUTOMOVEL%' 
            OR rw_crapbpr.dscatbem LIKE '%MOTO%' 
            OR rw_crapbpr.dscatbem LIKE '%CAMINHAO%' THEN

              -- Se possuir saldo
              IF vr_vlsldisp > vr_vlrtarif THEN

                -- Realizar lancamento tarifa
                TARI0001.pc_lan_tarifa_online(pr_cdcooper => pr_cdcooper   -- Codigo Cooperativa
                                             ,pr_cdagenci => pr_cdagenci   -- Codigo Agencia destino
                                             ,pr_nrdconta => pr_nrdconta   -- Numero da Conta Destino
                                             ,pr_cdbccxlt => 100           -- Codigo banco/caixa
                                             ,pr_nrdolote => 8452          -- Numero do Lote
                                             ,pr_tplotmov => 1             -- Tipo Lote
                                             ,pr_cdoperad => pr_cdoperad   -- Codigo Operador
                                             ,pr_dtmvtlat => pr_dtmvtolt   -- Data Tarifa
                                             ,pr_dtmvtlcm => pr_dtmvtolt   -- Data lancamento
                                             ,pr_nrdctabb => pr_nrdconta   -- Numero Conta BB
                                             ,pr_nrdctitg => TO_CHAR(pr_nrdconta,'fm00000000') -- Conta Integracao
                                             ,pr_cdhistor => vr_cdhistor   -- Codigo Historico
                                             ,pr_cdpesqbb => pr_nrctremp   -- Codigo pesquisa
                                             ,pr_cdbanchq => 0             -- Codigo Banco Cheque
                                             ,pr_cdagechq => 0             -- Codigo Agencia Cheque
                                             ,pr_nrctachq => 0             -- Numero Conta Cheque
                                             ,pr_flgaviso => FALSE         -- Flag Aviso
                                             ,pr_tpdaviso => 0             -- Tipo Aviso
                                             ,pr_vltarifa => vr_vlrtarif   -- Valor tarifa
                                             ,pr_nrdocmto => pr_nrctremp   -- Numero Documento
                                             ,pr_cdcoptfn => 0             -- Codigo Cooperativa Terminal
                                             ,pr_cdagetfn => 0             -- Codigo Agencia Terminal
                                             ,pr_nrterfin => 0             -- Numero Terminal Financeiro
                                             ,pr_nrsequni => 0             -- Numero Sequencial Unico
                                             ,pr_nrautdoc => 0             -- Numero Autenticacao Documento
                                             ,pr_dsidenti => NULL          -- Descricao Identificacao
                                             ,pr_cdfvlcop => vr_cdfvlcop   -- Codigo Faixa Valor Cooperativa
                                             ,pr_inproces => 1             -- Indicador Processo
                                             ,pr_cdlantar => vr_cdlantar   -- Codigo Lancamento tarifa
                                             ,pr_tab_erro => vr_tab_erro   -- Tabela de erro
                                             ,pr_cdcritic => vr_cdcritic   -- Codigo do erro
                                             ,pr_dscritic => vr_dscritic); -- Descricao do erro
                -- Se ocorreu erro
                IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                  -- Se possui algum erro na tabela de erros
                  IF vr_tab_erro.COUNT() > 0 THEN
                    vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                    vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                  ELSE
                    vr_cdcritic := 0;
                    vr_dscritic := 'Nao foi possivel lancar a tarifa.';
                  END IF;
                  RAISE vr_exc_erro;
                END IF;

              ELSE

                -- Criar lancamento automatico de tarifa
                TARI0001.pc_cria_lan_auto_tarifa(pr_cdcooper      => pr_cdcooper
                                                ,pr_nrdconta      => pr_nrdconta
                                                ,pr_dtmvtolt      => pr_dtmvtolt
                                                ,pr_cdhistor      => vr_cdhistor
                                                ,pr_vllanaut      => vr_vlrtarif
                                                ,pr_cdoperad      => pr_cdoperad
                                                ,pr_cdagenci      => pr_cdagenci
                                                ,pr_cdbccxlt 	    => 100
                                                ,pr_nrdolote      => 8452
                                                ,pr_tpdolote      => 1
                                                ,pr_nrdocmto      => pr_nrctremp
                                                ,pr_nrdctabb      => pr_nrdconta
                                                ,pr_nrdctitg      => GENE0002.fn_mask(pr_nrdconta,'99999999')
                                                ,pr_cdpesqbb      => 'Fato gerador tarifa:' || TO_CHAR(pr_nrctremp)
                                                ,pr_cdbanchq      => 0
                                                ,pr_cdagechq      => 0
                                                ,pr_nrctachq      => 0
                                                ,pr_flgaviso      => FALSE
                                                ,pr_tpdaviso      => 0
                                                ,pr_cdfvlcop      => vr_cdfvlcop
                                                ,pr_inproces      => 1
                                                ,pr_rowid_craplat => vr_rowid
                                                ,pr_tab_erro      => vr_tab_erro
                                                ,pr_cdcritic      => vr_cdcritic
                                                ,pr_dscritic      => vr_dscritic);
                -- Se ocorreu erro
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  RAISE vr_exc_erro;
                END IF;

                -- Subtrai do saldo o valor da tarifa
                vr_vlsldisp := vr_vlsldisp - vr_vlrtarif;

              END IF; -- vr_vlsldisp > vr_vlrtarif

              -- Total Tarifa a ser Cobrado
              vr_vltottar := NVL(vr_vltottar,0) + NVL(vr_vlrtarif,0);

            ELSE
              vr_flgoutrosbens := TRUE;
            END IF; -- Se for carro, moto ou caminhao

          END LOOP; -- cr_crapbpr
          
          -- Se houver outros bens cobrar mais uma tarifa
          IF vr_flgoutrosbens THEN

              -- Se possuir saldo
              IF vr_vlsldisp > vr_vlrtarif THEN

                -- Realizar lancamento tarifa
                TARI0001.pc_lan_tarifa_online(pr_cdcooper => pr_cdcooper   -- Codigo Cooperativa
                                             ,pr_cdagenci => pr_cdagenci   -- Codigo Agencia destino
                                             ,pr_nrdconta => pr_nrdconta   -- Numero da Conta Destino
                                             ,pr_cdbccxlt => 100           -- Codigo banco/caixa
                                             ,pr_nrdolote => 8452          -- Numero do Lote
                                             ,pr_tplotmov => 1             -- Tipo Lote
                                             ,pr_cdoperad => pr_cdoperad   -- Codigo Operador
                                             ,pr_dtmvtlat => pr_dtmvtolt   -- Data Tarifa
                                             ,pr_dtmvtlcm => pr_dtmvtolt   -- Data lancamento
                                             ,pr_nrdctabb => pr_nrdconta   -- Numero Conta BB
                                             ,pr_nrdctitg => TO_CHAR(pr_nrdconta,'fm00000000') -- Conta Integracao
                                             ,pr_cdhistor => vr_cdhistor   -- Codigo Historico
                                             ,pr_cdpesqbb => pr_nrctremp   -- Codigo pesquisa
                                             ,pr_cdbanchq => 0             -- Codigo Banco Cheque
                                             ,pr_cdagechq => 0             -- Codigo Agencia Cheque
                                             ,pr_nrctachq => 0             -- Numero Conta Cheque
                                             ,pr_flgaviso => FALSE         -- Flag Aviso
                                             ,pr_tpdaviso => 0             -- Tipo Aviso
                                             ,pr_vltarifa => vr_vlrtarif   -- Valor tarifa
                                             ,pr_nrdocmto => pr_nrctremp   -- Numero Documento
                                             ,pr_cdcoptfn => 0             -- Codigo Cooperativa Terminal
                                             ,pr_cdagetfn => 0             -- Codigo Agencia Terminal
                                             ,pr_nrterfin => 0             -- Numero Terminal Financeiro
                                             ,pr_nrsequni => 0             -- Numero Sequencial Unico
                                             ,pr_nrautdoc => 0             -- Numero Autenticacao Documento
                                             ,pr_dsidenti => NULL          -- Descricao Identificacao
                                             ,pr_cdfvlcop => vr_cdfvlcop   -- Codigo Faixa Valor Cooperativa
                                             ,pr_inproces => 1             -- Indicador Processo
                                             ,pr_cdlantar => vr_cdlantar   -- Codigo Lancamento tarifa
                                             ,pr_tab_erro => vr_tab_erro   -- Tabela de erro
                                             ,pr_cdcritic => vr_cdcritic   -- Codigo do erro
                                             ,pr_dscritic => vr_dscritic); -- Descricao do erro
                -- Se ocorreu erro
                IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                  -- Se possui algum erro na tabela de erros
                  IF vr_tab_erro.COUNT() > 0 THEN
                    vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                    vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                  ELSE
                    vr_cdcritic := 0;
                    vr_dscritic := 'Nao foi possivel lancar a tarifa.';
                  END IF;
                  RAISE vr_exc_erro;
                END IF;

              ELSE

                -- Criar lancamento automatico de tarifa
                TARI0001.pc_cria_lan_auto_tarifa(pr_cdcooper      => pr_cdcooper
                                                ,pr_nrdconta      => pr_nrdconta
                                                ,pr_dtmvtolt      => pr_dtmvtolt
                                                ,pr_cdhistor      => vr_cdhistor
                                                ,pr_vllanaut      => vr_vlrtarif
                                                ,pr_cdoperad      => pr_cdoperad
                                                ,pr_cdagenci      => pr_cdagenci
                                                ,pr_cdbccxlt 	    => 100
                                                ,pr_nrdolote      => 8452
                                                ,pr_tpdolote      => 1
                                                ,pr_nrdocmto      => pr_nrctremp
                                                ,pr_nrdctabb      => pr_nrdconta
                                                ,pr_nrdctitg      => GENE0002.fn_mask(pr_nrdconta,'99999999')
                                                ,pr_cdpesqbb      => 'Fato gerador tarifa:' || TO_CHAR(pr_nrctremp)
                                                ,pr_cdbanchq      => 0
                                                ,pr_cdagechq      => 0
                                                ,pr_nrctachq      => 0
                                                ,pr_flgaviso      => FALSE
                                                ,pr_tpdaviso      => 0
                                                ,pr_cdfvlcop      => vr_cdfvlcop
                                                ,pr_inproces      => 1
                                                ,pr_rowid_craplat => vr_rowid
                                                ,pr_tab_erro      => vr_tab_erro
                                                ,pr_cdcritic      => vr_cdcritic
                                                ,pr_dscritic      => vr_dscritic);
                -- Se ocorreu erro
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  RAISE vr_exc_erro;
                END IF;

              END IF; -- vr_vlsldisp > vr_vlrtarif

              -- Total Tarifa a ser Cobrado
              vr_vltottar := NVL(vr_vltottar,0) + NVL(vr_vlrtarif,0);

          END IF; -- vr_flgoutrosbens

        ELSE

          -- Se possuir saldo
          IF vr_vlsldisp > vr_vlrtarif THEN

            -- Realizar lancamento tarifa
            TARI0001.pc_lan_tarifa_online(pr_cdcooper => pr_cdcooper   -- Codigo Cooperativa
                                         ,pr_cdagenci => pr_cdagenci   -- Codigo Agencia destino
                                         ,pr_nrdconta => pr_nrdconta   -- Numero da Conta Destino
                                         ,pr_cdbccxlt => 100           -- Codigo banco/caixa
                                         ,pr_nrdolote => 8452          -- Numero do Lote
                                         ,pr_tplotmov => 1             -- Tipo Lote
                                         ,pr_cdoperad => pr_cdoperad   -- Codigo Operador
                                         ,pr_dtmvtlat => pr_dtmvtolt   -- Data Tarifa
                                         ,pr_dtmvtlcm => pr_dtmvtolt   -- Data lancamento
                                         ,pr_nrdctabb => pr_nrdconta   -- Numero Conta BB
                                         ,pr_nrdctitg => TO_CHAR(pr_nrdconta,'fm00000000') -- Conta Integracao
                                         ,pr_cdhistor => vr_cdhistor   -- Codigo Historico
                                         ,pr_cdpesqbb => pr_nrctremp   -- Codigo pesquisa
                                         ,pr_cdbanchq => 0             -- Codigo Banco Cheque
                                         ,pr_cdagechq => 0             -- Codigo Agencia Cheque
                                         ,pr_nrctachq => 0             -- Numero Conta Cheque
                                         ,pr_flgaviso => FALSE         -- Flag Aviso
                                         ,pr_tpdaviso => 0             -- Tipo Aviso
                                         ,pr_vltarifa => vr_vlrtarif   -- Valor tarifa
                                         ,pr_nrdocmto => pr_nrctremp   -- Numero Documento
                                         ,pr_cdcoptfn => 0             -- Codigo Cooperativa Terminal
                                         ,pr_cdagetfn => 0             -- Codigo Agencia Terminal
                                         ,pr_nrterfin => 0             -- Numero Terminal Financeiro
                                         ,pr_nrsequni => 0             -- Numero Sequencial Unico
                                         ,pr_nrautdoc => 0             -- Numero Autenticacao Documento
                                         ,pr_dsidenti => NULL          -- Descricao Identificacao
                                         ,pr_cdfvlcop => vr_cdfvlcop   -- Codigo Faixa Valor Cooperativa
                                         ,pr_inproces => 1             -- Indicador Processo
                                         ,pr_cdlantar => vr_cdlantar   -- Codigo Lancamento tarifa
                                         ,pr_tab_erro => vr_tab_erro   -- Tabela de erro
                                         ,pr_cdcritic => vr_cdcritic   -- Codigo do erro
                                         ,pr_dscritic => vr_dscritic); -- Descricao do erro
            -- Se ocorreu erro
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              -- Se possui algum erro na tabela de erros
              IF vr_tab_erro.COUNT() > 0 THEN
                vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              ELSE
                vr_cdcritic := 0;
                vr_dscritic := 'Nao foi possivel lancar a tarifa.';
              END IF;
              RAISE vr_exc_erro;
            END IF;

          ELSE

            -- Criar lancamento automatico de tarifa
            TARI0001.pc_cria_lan_auto_tarifa(pr_cdcooper      => pr_cdcooper
                                            ,pr_nrdconta      => pr_nrdconta
                                            ,pr_dtmvtolt      => pr_dtmvtolt
                                            ,pr_cdhistor      => vr_cdhistor
                                            ,pr_vllanaut      => vr_vlrtarif
                                            ,pr_cdoperad      => pr_cdoperad
                                            ,pr_cdagenci      => pr_cdagenci
                                            ,pr_cdbccxlt 	    => 100
                                            ,pr_nrdolote      => 8452
                                            ,pr_tpdolote      => 1
                                            ,pr_nrdocmto      => pr_nrctremp
                                            ,pr_nrdctabb      => pr_nrdconta
                                            ,pr_nrdctitg      => GENE0002.fn_mask(pr_nrdconta,'99999999')
                                            ,pr_cdpesqbb      => 'Fato gerador tarifa:' || TO_CHAR(pr_nrctremp)
                                            ,pr_cdbanchq      => 0
                                            ,pr_cdagechq      => 0
                                            ,pr_nrctachq      => 0
                                            ,pr_flgaviso      => FALSE
                                            ,pr_tpdaviso      => 0
                                            ,pr_cdfvlcop      => vr_cdfvlcop
                                            ,pr_inproces      => 1
                                            ,pr_rowid_craplat => vr_rowid
                                            ,pr_tab_erro      => vr_tab_erro
                                            ,pr_cdcritic      => vr_cdcritic
                                            ,pr_dscritic      => vr_dscritic);
            -- Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;

          END IF; -- vr_vlsldisp > vr_vlrtarif

          -- Total Tarifa a ser Cobrado
          vr_vltottar := NVL(vr_vltottar,0) + NVL(vr_vlrtarif,0);
    
        END IF; -- rw_craplcr.tpctrato = 2

      END IF; -- rw_craplcr.tpctrato IN (2,3)

      -- Retorna as tarifas
      pr_vltottar := NVL(vr_vltottar, 0);
      pr_vltariof := NVL(vr_vltariof, 0);

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variavel de saida
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        -- Apenas retornar a variavel de saida
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Erro na procedure pc_efetua_credito_conta: ' || SQLERRM;

    END;

  END pc_efetua_credito_conta;

  PROCEDURE pc_busca_tip_atualiz_index(pr_cddindex       IN tbepr_posfix_param_index.cddindex%TYPE      --> Codigo do indice (FK crapind)
                                      ,pr_tpatualizacao OUT tbepr_posfix_param_index.tpatualizacao%TYPE --> Tipo de Atualizacao Indexador
                                      ,pr_cdcritic      OUT crapcri.cdcritic%TYPE                       --> Codigo da critica
                                      ,pr_dscritic      OUT crapcri.dscritic%TYPE) IS                   --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_busca_tip_atualiz_index
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Junho/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para buscar o Tipo de Atualizacao Indexador (1-Diario / 2-Quinzenal / 3-Mensal).

       Alteracoes: 
    ............................................................................. */

    DECLARE

      -- Busca os dados do Indexador Parametros
      CURSOR cr_param_index(pr_cddindex IN tbepr_posfix_param_index.cddindex%TYPE) IS
        SELECT tpatualizacao
          FROM tbepr_posfix_param_index
         WHERE cddindex = pr_cddindex;

      -- Variaveis
      vr_tpatualizacao tbepr_posfix_param_index.tpatualizacao%TYPE;

    BEGIN
      OPEN  cr_param_index(pr_cddindex => pr_cddindex);
      FETCH cr_param_index INTO vr_tpatualizacao;
      CLOSE cr_param_index;
      pr_tpatualizacao := NVL(vr_tpatualizacao,0);
    EXCEPTION

      WHEN OTHERS THEN
        -- Apenas retornar a variavel de saida
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na procedure pc_busca_tip_atualiz_index: ' || SQLERRM;

    END;

  END pc_busca_tip_atualiz_index;

END EMPR0011;
/
