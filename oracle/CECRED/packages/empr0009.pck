CREATE OR REPLACE PACKAGE CECRED.EMPR0009 IS

  PROCEDURE pc_efetiva_pag_atraso_tr(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                    ,pr_cdagenci  IN crapass.cdagenci%TYPE --> Agencia
                                    ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE --> Caixa
                                    ,pr_cdoperad  IN craplot.cdoperad%TYPE --> Operador
                                    ,pr_nmdatela  IN crapprg.cdprogra%TYPE --> Nome da Tela
                                    ,pr_idorigem  IN INTEGER               --> Origem
                                    ,pr_nrdconta  IN crapepr.nrdconta%TYPE --> Conta
                                    ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> Contrato
                                    ,pr_vlpreapg  IN crapepr.vlpreemp%TYPE --> Valor a pagar
                                    ,pr_qtmesdec  IN crapepr.qtmesdec%TYPE --> Quantidade de meses decorridos
                                    ,pr_qtprecal  IN crapepr.qtprecal%TYPE --> Quantidade de prestacoes calculadas
                                    ,pr_vlpagpar  IN crapepr.vlpreemp%TYPE --> Valor de pagamento da parcela
                                    ,pr_vlsldisp  IN NUMBER DEFAULT NULL   --> Valor Saldo Disponivel
                                    ,pr_cdhismul OUT INTEGER               --> Historico da Multa
                                    ,pr_vldmulta OUT NUMBER                --> Valor da Multa
                                    ,pr_cdhismor OUT INTEGER               --> Historico Juros de Mora
                                    ,pr_vljumora OUT NUMBER                --> Valor Juros de Mora
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2);            --> Descricao da critica

	PROCEDURE pc_efetiva_lcto_pendente_job;

END EMPR0009;
/
CREATE OR REPLACE PACKAGE BODY CECRED.EMPR0009 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : EMPR0009
  --  Sistema  : Conta-Corrente - Cooperativa de Credito
  --  Sigla    : CRED
  --  Autor    : Jaison Fernando
  --  Data     : Maio - 2016                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas para calcular multa e juros de mora 
  --             para os contratos de emprestimo TR.
  --
  -- Alteracoes: 
  --
  ---------------------------------------------------------------------------

	PROCEDURE pc_calcula_atraso_tr(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Cooperativa
                                ,pr_vlpreapg  IN crapepr.vlpreemp%TYPE     --> Valor a pagar
                                ,pr_dtdpagto  IN crapepr.dtdpagto%TYPE     --> Data do pagamento
                                ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE     --> Movimento atual
                                ,pr_dtmvtoan  IN crapdat.dtmvtoan%TYPE     --> Data anterior do movimento
                                ,pr_qtpreemp  IN crapepr.qtpreemp%TYPE     --> Quantidade de prestacoes do emprestimo
                                ,pr_qtmesdec  IN crapepr.qtmesdec%TYPE     --> Quantidade de meses decorridos
                                ,pr_qtprecal  IN crapepr.qtprecal%TYPE     --> Quantidade de prestacoes calculadas
                                ,pr_vlpreemp  IN crapepr.vlpreemp%TYPE     --> Valor da prestacao do emprestimo
                                ,pr_nmtelant  IN VARCHAR2                  --> Nome da tela anterior
                                ,pr_vlatraso OUT crapepr.vlemprst%TYPE) IS --> Valor calculado
  BEGIN
    /* .............................................................................

       Programa: pc_calcula_atraso_tr
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Maio/2016                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para calcular o valor do atraso do emprestimo TR.

       Alteracoes: 

    ............................................................................. */
    DECLARE
    	-- Variaveis
      vr_qtnaopag  INTEGER;
      vr_dtnovapg  DATE;
      vr_dtcalcul  DATE;

    BEGIN
      pr_vlatraso := 0;      
      -- Condicao do emprestimo que estah todo em atraso
      IF pr_qtmesdec > pr_qtpreemp THEN
        -- Calculo do Valor em Atraso
        pr_vlatraso := ROUND(pr_vlpreemp * (pr_qtpreemp - pr_qtprecal),2);
      ELSE        
        -- Pagamento de Emprestimo de Boleto POR FORA
        IF pr_nmtelant = 'COMPEFORA' THEN
          vr_dtcalcul := pr_dtmvtoan;
        ELSE
          vr_dtcalcul := pr_dtmvtolt;
        END IF;
        -- Quantidade de prestacoes NAO pagas
        vr_qtnaopag := pr_qtmesdec - pr_qtprecal - 1;
        -- Nova data de pagamento
        vr_dtnovapg := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                  ,pr_dtmvtolt => ADD_MONTHS(pr_dtdpagto,vr_qtnaopag));
        -- Se nova data igual a data atual
        IF vr_dtnovapg = vr_dtcalcul THEN
          pr_vlatraso := pr_vlpreapg - pr_vlpreemp;
        ELSE
          pr_vlatraso := pr_vlpreapg;
        END IF;
      END IF;      
      -- Condicao para verificar se o valor estah negativo
      IF pr_vlatraso < 0 THEN
        pr_vlatraso := 0;
      END IF;
    END;

  END pc_calcula_atraso_tr;

	PROCEDURE pc_calcula_multa_tr(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                               ,pr_vlpagatr  IN crapepr.vlpreemp%TYPE --> Valor Pago do Atraso
                               ,pr_vldmulta OUT crapepr.vlemprst%TYPE) IS --> Valor calculado
  BEGIN
    /* .............................................................................

       Programa: pc_calcula_multa_tr
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Maio/2016                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para calcular o valor da multa do emprestimo TR.

       Alteracoes: 

    ............................................................................. */
    DECLARE
      -- Variaveis
      vr_vlperctl NUMBER;

    BEGIN
      -- Carrega o percentual
      vr_vlperctl := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_cdacesso => 'PERCENTUAL_MULTA_TR');
      -- Calcula a multa
      pr_vldmulta := pr_vlpagatr * (vr_vlperctl / 100);
    END;

  END pc_calcula_multa_tr;

	PROCEDURE pc_calcula_juros_mora_tr(pr_qtpreemp  IN crapepr.qtpreemp%TYPE --> Quantidade de prestacoes do emprestimo
                                    ,pr_qtmesdec  IN crapepr.qtmesdec%TYPE --> Quantidade de meses decorridos
                                    ,pr_qtprecal  IN crapepr.qtprecal%TYPE --> Quantidade de prestacoes calculadas
                                    ,pr_dtdpagto  IN crapepr.dtdpagto%TYPE --> Data do pagamento
                                    ,pr_vlpagatr  IN crapepr.vlpreemp%TYPE --> Valor Pago do Atraso
                                    ,pr_vlpreemp  IN crapepr.vlpreemp%TYPE --> Valor da prestacao do emprestimo
                                    ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                    ,pr_perjurmo  IN craplcr.perjurmo%TYPE --> Percentual de juros de mora por atraso
                                    ,pr_vldjuros OUT crapepr.vlemprst%TYPE) IS --> Valor calculado
  BEGIN
    /* .............................................................................

       Programa: pc_calcula_juros_mora_tr
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Maio/2016                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para calcular o juros de mora do emprestimo TR.

       Alteracoes: 

    ............................................................................. */
    DECLARE

    	-- Variaveis
      vr_qtdiamor INTEGER;
      vr_txdiaria NUMBER;
      vr_vlpagatr NUMBER;
      vr_vlpgdisp NUMBER := 0;
      vr_dtdpagto crapepr.dtdpagto%TYPE;
      vr_nrparepr crappep.nrparepr%TYPE;

    BEGIN
      vr_vlpgdisp := pr_vlpagatr;
      vr_dtdpagto := pr_dtdpagto;      
      -- Caso os meses decorridos for maior que a quantidade de prestacoes
      IF pr_qtmesdec > pr_qtpreemp THEN
        vr_nrparepr := pr_qtpreemp - FLOOR(pr_qtprecal);
      -- Caso a quantidade de prestacoes for maior que 1  
      ELSIF pr_qtpreemp > 1 THEN
        vr_nrparepr := pr_qtmesdec - FLOOR(pr_qtprecal);
      ELSE
        vr_nrparepr := pr_qtpreemp;
      END IF;
      
      -- Calculo para verificar se jah foi pago alguma coisa da primeira parcela
      vr_vlpagatr := pr_vlpreemp - ROUND((pr_qtprecal - FLOOR(pr_qtprecal)) * pr_vlpreemp,2);
      -- Condicao para verificar se o valor de pagamento eh menor que o valor da parcela
      IF pr_vlpagatr - vr_vlpagatr < 0 THEN
        vr_vlpagatr := pr_vlpagatr;
      END IF;
      -- Taxa de mora recebe o valor da linha de credito
      vr_txdiaria := ROUND((100 * (POWER((pr_perjurmo / 100) + 1,(1 / 30)) - 1)),10);
      vr_txdiaria := vr_txdiaria / 100;

      -- Calcular o valor do juros de mora para cada parcela
      FOR vr_indice IN 1 .. vr_nrparepr LOOP
        -- Na segunda parcela em atraso, sera calculado em cima do valor da prestacao
        IF vr_indice > 1 THEN
          vr_vlpagatr := pr_vlpreemp;
          -- Condicao para verificar se possui valor de pagamento disponivel
          IF vr_vlpagatr > vr_vlpgdisp THEN
            vr_vlpagatr := vr_vlpgdisp;
          END IF;
          -- Incrementar a data de pagamento para o proximo mes
          vr_dtdpagto := ADD_MONTHS(pr_dtdpagto, vr_indice - 1);
        END IF;

        -- Calculo dos dias do Juros de Mora
        vr_qtdiamor := pr_dtmvtolt - vr_dtdpagto;
        -- Calculo do valor do Juros de Mora
        pr_vldjuros := NVL(pr_vldjuros,0) + ROUND((vr_vlpagatr * vr_txdiaria * vr_qtdiamor),2);
        vr_vlpgdisp := vr_vlpgdisp - vr_vlpagatr;
        -- Condicao para verificar se possui valor disponivel para fazer o pagamento
        IF vr_vlpgdisp <= 0 THEN
          EXIT;
        END IF;

      END LOOP;

    END;

  END pc_calcula_juros_mora_tr;

	PROCEDURE pc_cria_lanc_futuro(pr_cdcooper IN craplau.cdcooper%TYPE --> Cooperativa
                               ,pr_nrdconta IN craplau.nrdconta%TYPE --> Conta
                               ,pr_nrdctitg IN craplau.nrdctitg%TYPE --> Conta integracao
                               ,pr_cdagenci IN craplau.cdagenci%TYPE --> Numero do PA
                               ,pr_dtmvtolt IN craplau.dtmvtolt%TYPE --> Data do movimento
                               ,pr_cdhistor IN craplau.cdhistor%TYPE --> Historico do lancamento
                               ,pr_vllanaut IN craplau.vllanaut%TYPE --> Valor do lancamento
                               ,pr_nrctremp IN craplau.nrctremp%TYPE --> Contrato
                               ,pr_dscritic OUT VARCHAR2) IS         --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_cria_lanc_futuro
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Maio/2016                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para criacao de lancamentos futuros.

       Alteracoes: 

    ............................................................................. */
    DECLARE
      -- Variaveis
      vr_nrseqdig INTEGER;

    BEGIN
      vr_nrseqdig := fn_sequence('CRAPLAU','NRSEQDIG',''||pr_cdcooper||';'||pr_dtmvtolt||'');

      BEGIN
        INSERT INTO craplau
                   (cdcooper
                   ,nrdconta
                   ,nrdctabb
                   ,nrdctitg
                   ,cdagenci
                   ,dtmvtolt
                   ,dtmvtopg
                   ,cdhistor
                   ,vllanaut
                   ,nrseqdig
                   ,nrdocmto
                   ,nrctremp
                   ,cdbccxlt
                   ,nrdolote
                   ,insitlau
                   ,dtdebito
                   ,dsorigem)
             VALUES(pr_cdcooper
                   ,pr_nrdconta
                   ,pr_nrdconta
                   ,pr_nrdctitg
                   ,pr_cdagenci
                   ,pr_dtmvtolt
                   ,pr_dtmvtolt
                   ,pr_cdhistor
                   ,pr_vllanaut
                   ,vr_nrseqdig
                   ,vr_nrseqdig
                   ,pr_nrctremp
                   ,100
                   ,600033
                   ,1
                   ,NULL
                   ,'TRMULTAJUROS');
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro ao inserir o registro na CRAPLAU: ' || SQLERRM;
      END;
    END;

  END pc_cria_lanc_futuro;

	PROCEDURE pc_efetiva_pag_atraso_tr(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                    ,pr_cdagenci  IN crapass.cdagenci%TYPE --> Agencia
                                    ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE --> Caixa
                                    ,pr_cdoperad  IN craplot.cdoperad%TYPE --> Operador
                                    ,pr_nmdatela  IN crapprg.cdprogra%TYPE --> Nome da Tela
                                    ,pr_idorigem  IN INTEGER               --> Origem
                                    ,pr_nrdconta  IN crapepr.nrdconta%TYPE --> Conta
                                    ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> Contrato
                                    ,pr_vlpreapg  IN crapepr.vlpreemp%TYPE --> Valor a pagar
                                    ,pr_qtmesdec  IN crapepr.qtmesdec%TYPE --> Quantidade de meses decorridos
                                    ,pr_qtprecal  IN crapepr.qtprecal%TYPE --> Quantidade de prestacoes calculadas
                                    ,pr_vlpagpar  IN crapepr.vlpreemp%TYPE --> Valor de pagamento da parcela
                                    ,pr_vlsldisp  IN NUMBER DEFAULT NULL   --> Valor Saldo Disponivel
                                    ,pr_cdhismul OUT INTEGER               --> Historico da Multa
                                    ,pr_vldmulta OUT NUMBER                --> Valor da Multa
                                    ,pr_cdhismor OUT INTEGER               --> Historico Juros de Mora
                                    ,pr_vljumora OUT NUMBER                --> Valor Juros de Mora
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_efetiva_pag_atraso_tr
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Maio/2016                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Efetivacao do pagamento da Multa e Juros de Mora do emprestimo TR.

       Alteracoes: 

    ............................................................................. */
    DECLARE
      -- Busca o emprestimo
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT crapepr.dtdpagto
              ,crapepr.flgpagto
              ,crapepr.inprejuz
              ,crapepr.cdlcremp
              ,crapepr.vlpreemp
              ,crapepr.qtpreemp
          FROM crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;

      -- Busca a linha de credito
      CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                       ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT craplcr.perjurmo,
               craplcr.flgcobmu,
               craplcr.dsoperac
          FROM craplcr
         WHERE craplcr.cdcooper = pr_cdcooper
           AND craplcr.cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;

      -- Busca o associado
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.vllimcre
              ,crapass.nrdctitg
              ,crapass.cdagenci
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Cursor generico de calendario
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      -- Tratamento de erros
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
      vr_des_reto  VARCHAR2(3);
      vr_tab_erro  GENE0001.typ_tab_erro;

      -- Variaveis
      vr_index    PLS_INTEGER;
      vr_blnfound BOOLEAN;
      vr_vlatraso NUMBER;
      vr_vlpagatr NUMBER;
      vr_vldmulta NUMBER;
      vr_vllanfut NUMBER;
      vr_vllanmto NUMBER;
      vr_vldjuros NUMBER;
      vr_vlsldisp NUMBER;
      vr_vlsldis2 NUMBER;
      vr_floperac BOOLEAN;
      vr_cdhistor INTEGER;
      vr_nrdolote INTEGER := 600033;
      vr_nrdrowid ROWID;

      -- Tabela de Saldos
      vr_tab_saldos EXTR0001.typ_tab_saldos;

    BEGIN
      -- Limpa tabela saldos
      vr_tab_saldos.DELETE;
      
      -- Reseta os valores
      pr_cdhismul := 0;
      pr_vldmulta := 0;
      pr_cdhismor := 0;
      pr_vljumora := 0;
      
      -- Caso NAO esteja habilitado a cobranca de multa e juros de mora
      IF GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_cdacesso => 'HABIL_COB_MULTA_JUROS_TR') <> '1' THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Caso NAO tenha valor a pagar
      IF NVL(pr_vlpreapg, 0) = 0 THEN
        RAISE vr_exc_saida;
      END IF;

      -- Verifica se a data esta cadastrada
      OPEN  BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Alimenta a booleana
      vr_blnfound := BTCH0001.cr_crapdat%FOUND;
      -- Fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
      -- Se NAO encontrar
      IF NOT vr_blnfound THEN
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
      END IF;

      -- Busca o associado
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- Alimenta a booleana
      vr_blnfound := cr_crapass%FOUND;
      -- Fechar o cursor
      CLOSE cr_crapass;
      -- Se NAO encontrar
      IF NOT vr_blnfound THEN
        vr_cdcritic := 9;
        RAISE vr_exc_erro;
      END IF;

      -- Busca o emprestimo
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crapepr INTO rw_crapepr;
      -- Alimenta a booleana
      vr_blnfound := cr_crapepr%FOUND;
      -- Fechar o cursor
      CLOSE cr_crapepr;
      -- Se NAO encontrar
      IF NOT vr_blnfound THEN
        vr_cdcritic := 356;
        RAISE vr_exc_erro;
      END IF;

      -- Parcela precisa estar vencida
      IF ((rw_crapepr.dtdpagto > rw_crapdat.dtmvtoan AND rw_crapepr.dtdpagto <= rw_crapdat.dtmvtolt) OR 
          (rw_crapepr.dtdpagto >= rw_crapdat.dtmvtolt)) THEN
        RAISE vr_exc_saida;
      END IF;

      -- Emprestimo em Folha nao sera cobrado Juros de Mora e Multa
      IF rw_crapepr.flgpagto = 1 THEN
        RAISE vr_exc_saida;
      END IF;

      -- Emprestimo em Prejuizo nao sera cobrado Juros de Mora e Multa
      IF rw_crapepr.inprejuz = 1 THEN
        RAISE vr_exc_saida;
      END IF;

      -- Se nao tem Valor de pagamento da parcela
      IF NVL(pr_vlpagpar, 0) = 0 THEN
        RAISE vr_exc_saida;
      END IF;

      -- Busca a linha de credito
      OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                     ,pr_cdlcremp => rw_crapepr.cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
      -- Alimenta a booleana
      vr_blnfound := cr_craplcr%FOUND;
      -- Fechar o cursor
      CLOSE cr_craplcr;
      -- Se NAO encontrar
      IF NOT vr_blnfound THEN
        vr_cdcritic := 55;
        RAISE vr_exc_erro;
      END IF;

      -- Calcular o valor do atraso da parcela
      EMPR0009.pc_calcula_atraso_tr(pr_cdcooper => pr_cdcooper
                                   ,pr_vlpreapg => pr_vlpreapg
                                   ,pr_dtdpagto => rw_crapepr.dtdpagto
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   ,pr_dtmvtoan => rw_crapdat.dtmvtoan
                                   ,pr_qtpreemp => rw_crapepr.qtpreemp
                                   ,pr_qtmesdec => pr_qtmesdec
                                   ,pr_qtprecal => pr_qtprecal
                                   ,pr_vlpreemp => rw_crapepr.vlpreemp
                                   ,pr_nmtelant => pr_nmdatela
                                   ,pr_vlatraso => vr_vlatraso);
      -- Se NAO calculou o valor de atraso
      IF NVL(vr_vlatraso, 0) <= 0 THEN
        RAISE vr_exc_saida;
      END IF;

      -- Valor Pago do Atraso
      vr_vlpagatr := pr_vlpagpar;

      -- Condicao para verificar se foi pago mais que o valor do atraso
      IF pr_vlpagpar - vr_vlatraso > 0 THEN
        vr_vlpagatr := vr_vlatraso;
      END IF;

      -- Se foi passado o Saldo Disponivel
      IF pr_vlsldisp IS NOT NULL THEN
        vr_vlsldisp := ROUND(pr_vlsldisp,2);
      ELSE
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
        vr_index := vr_tab_saldos.FIRST;
        IF vr_index IS NOT NULL THEN
          -- Saldo Disponivel
          vr_vlsldisp := ROUND(NVL(vr_tab_saldos(vr_index).vlsddisp, 0) +
                               NVL(vr_tab_saldos(vr_index).vlsdchsl, 0) +
                               NVL(vr_tab_saldos(vr_index).vlsdbloq, 0) +
                               NVL(vr_tab_saldos(vr_index).vlsdblpr, 0) +
                               NVL(vr_tab_saldos(vr_index).vlsdblfp, 0) +
                               NVL(vr_tab_saldos(vr_index).vllimcre, 0),2);
        END IF;

      END IF;

      -- Guarda o saldo antes dos debitos
      vr_vlsldis2 := vr_vlsldisp;

      -- Verifica se eh financiamento
      vr_floperac := rw_craplcr.dsoperac = 'FINANCIAMENTO';

      -- Verificar se cobra multa
      IF rw_craplcr.flgcobmu = 1 THEN

        -- Calcula o valor que sera cobrado da multa
        EMPR0009.pc_calcula_multa_tr(pr_cdcooper => pr_cdcooper
                                    ,pr_vlpagatr => vr_vlpagatr
                                    ,pr_vldmulta => vr_vldmulta);

        -- Se possuir multa para debitar
        IF vr_vldmulta > 0 THEN

          IF vr_floperac THEN
            vr_cdhistor := 2084; -- Financiamento
          ELSE
            vr_cdhistor := 2090; -- Emprestimo
          END IF;

          vr_vllanmto := 0;
          vr_vllanfut := 0;

          -- Cobrar valor integral
          IF vr_vlsldisp - vr_vldmulta >= 0 THEN
            vr_vllanmto := vr_vldmulta;
          -- Cobrar valor parcial
          ELSIF vr_vldmulta - ABS(vr_vlsldisp) >= 0 THEN
            vr_vllanmto := vr_vlsldisp;
            vr_vllanfut := vr_vldmulta - vr_vllanmto;
          ELSE
             vr_vllanfut := vr_vldmulta;
          END IF;

          -- Verifica se efetua o lancamento na conta
          IF vr_vllanmto > 0 THEN

            -- Criar o lancamento da Multa
            EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Movimento atual
                                          ,pr_cdagenci => pr_cdagenci         --> Codigo da agencia
                                          ,pr_cdbccxlt => 100                 --> Numero do caixa
                                          ,pr_cdoperad => pr_cdoperad         --> Codigo do Operador
                                          ,pr_cdpactra => pr_cdagenci         --> P.A. da transacao
                                          ,pr_nrdolote => vr_nrdolote         --> Numero do Lote
                                          ,pr_nrdconta => pr_nrdconta         --> Numero da conta
                                          ,pr_cdhistor => vr_cdhistor         --> Codigo historico
                                          ,pr_vllanmto => vr_vllanmto         --> Valor da Multa
                                          ,pr_nrparepr => 0                   --> Numero parcelas emprestimo
                                          ,pr_nrctremp => pr_nrctremp         --> Numero do contrato de emprestimo
                                          ,pr_nrseqava => 0                   --> Pagamento: Sequencia do avalista
                                          ,pr_des_reto => vr_des_reto         --> Retorno OK / NOK
                                          ,pr_tab_erro => vr_tab_erro);       --> Tabela de erros
            -- Se ocorreu erro
            IF vr_des_reto <> 'OK' THEN
              -- Se possui algum erro na tabela de erros
              IF vr_tab_erro.COUNT() > 0 THEN
                vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              ELSE
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao criar o lancamento da Multa.';
              END IF;
              RAISE vr_exc_erro;
            END IF;

          END IF;

          -- Verifica se lanca na tela LAUTOM
          IF vr_vllanfut > 0 THEN

            -- Criar o registro para exibir na tela LAUTOM
            EMPR0009.pc_cria_lanc_futuro(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrdctitg => rw_crapass.nrdctitg
                                        ,pr_cdagenci => rw_crapass.cdagenci
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                        ,pr_cdhistor => vr_cdhistor
                                        ,pr_vllanaut => vr_vllanfut
                                        ,pr_nrctremp => pr_nrctremp
                                        ,pr_dscritic => vr_dscritic);
            -- Se ocorreu erro
            IF vr_dscritic IS NOT NULL THEN
              vr_cdcritic := 0;
              RAISE vr_exc_erro;
            END IF;

          END IF;

          -- Diminuir a multa do saldo disponivel
          vr_vldmulta := vr_vllanmto;
          vr_vlsldisp := vr_vlsldisp - vr_vldmulta;
          
          -- Retorna os valores
          pr_cdhismul := vr_cdhistor;
          pr_vldmulta := vr_vldmulta;

        END IF; -- vr_vldmulta > 0

      END IF; -- rw_craplcr.flgcobmu = 1

      -- Condicao para verificar se possui valor do juros de mora
      IF NVL(rw_craplcr.perjurmo,0) > 0 THEN      
        -- Calcular o valor do juros de mora
        EMPR0009.pc_calcula_juros_mora_tr(pr_qtpreemp => rw_crapepr.qtpreemp
                                         ,pr_qtmesdec => pr_qtmesdec
                                         ,pr_qtprecal => pr_qtprecal
                                         ,pr_dtdpagto => rw_crapepr.dtdpagto
                                         ,pr_vlpagatr => vr_vlpagatr
                                         ,pr_vlpreemp => rw_crapepr.vlpreemp
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_perjurmo => rw_craplcr.perjurmo
                                         ,pr_vldjuros => vr_vldjuros);

        -- Se possuir Juros de Mora para debitar
        IF vr_vldjuros > 0 THEN
          IF vr_floperac THEN
            vr_cdhistor := 2087; -- Financiamento
          ELSE
            vr_cdhistor := 2093; -- Emprestimo
          END IF;

          vr_vllanmto := 0;
          vr_vllanfut := 0;

          -- Cobrar valor integral
          IF vr_vlsldisp - vr_vldjuros >= 0 THEN
            vr_vllanmto := vr_vldjuros;
          -- Cobrar valor parcial
          ELSIF vr_vldjuros - ABS(vr_vlsldisp) >= 0 THEN
            vr_vllanmto := vr_vlsldisp;
            vr_vllanfut := vr_vldjuros - vr_vllanmto;
          ELSE
             vr_vllanfut := vr_vldjuros;
          END IF;

          -- Verifica se efetua o lancamento na conta
          IF vr_vllanmto > 0 THEN

            -- Criar o lancamento do Juros de Mora
            EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Movimento atual
                                          ,pr_cdagenci => pr_cdagenci         --> Codigo da agencia
                                          ,pr_cdbccxlt => 100                 --> Numero do caixa
                                          ,pr_cdoperad => pr_cdoperad         --> Codigo do Operador
                                          ,pr_cdpactra => pr_cdagenci         --> P.A. da transacao
                                          ,pr_nrdolote => vr_nrdolote         --> Numero do Lote
                                          ,pr_nrdconta => pr_nrdconta         --> Numero da conta
                                          ,pr_cdhistor => vr_cdhistor         --> Codigo historico
                                          ,pr_vllanmto => vr_vllanmto         --> Valor do Juros de Mora
                                          ,pr_nrparepr => 0                   --> Numero parcelas emprestimo
                                          ,pr_nrctremp => pr_nrctremp         --> Numero do contrato de emprestimo
                                          ,pr_nrseqava => 0                   --> Pagamento: Sequencia do avalista
                                          ,pr_des_reto => vr_des_reto         --> Retorno OK / NOK
                                          ,pr_tab_erro => vr_tab_erro);       --> Tabela de erros
            -- Se ocorreu erro
            IF vr_des_reto <> 'OK' THEN
              -- Se possui algum erro na tabela de erros
              IF vr_tab_erro.COUNT() > 0 THEN
                vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              ELSE
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao criar o lancamento do Juros de Mora.';
              END IF;
              RAISE vr_exc_erro;
            END IF;

          END IF;

          -- Verifica se lanca na tela LAUTOM
          IF vr_vllanfut > 0 THEN

            -- Criar o registro para exibir na tela LAUTOM
            EMPR0009.pc_cria_lanc_futuro(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrdctitg => rw_crapass.nrdctitg
                                        ,pr_cdagenci => rw_crapass.cdagenci
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                        ,pr_cdhistor => vr_cdhistor
                                        ,pr_vllanaut => vr_vllanfut
                                        ,pr_nrctremp => pr_nrctremp
                                        ,pr_dscritic => vr_dscritic);
            -- Se ocorreu erro
            IF vr_dscritic IS NOT NULL THEN
              vr_cdcritic := 0;
              RAISE vr_exc_erro;
            END IF;

          END IF;

          -- Diminuir a multa do saldo disponivel
          vr_vldjuros := vr_vllanmto;
          vr_vlsldisp := vr_vlsldisp - vr_vldjuros;

          -- Retorna os valores
          pr_cdhismor := vr_cdhistor;
          pr_vljumora := vr_vldjuros;

        END IF; -- vr_vldjuros > 0
        
      END IF;
      
      -- Gera LOG
			GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
				                   pr_cdoperad => pr_cdoperad,
													 pr_dscritic => '',
													 pr_dsorigem => TRIM(GENE0001.vr_vet_des_origens(pr_idorigem)),
													 pr_dstransa => 'Pagamento Multa e Juros de Mora para emprestimo TR',
													 pr_dttransa => TRUNC(SYSDATE),
													 pr_flgtrans => 1,
													 pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSSSS')),
													 pr_idseqttl => 0,
													 pr_nmdatela => pr_nmdatela,
													 pr_nrdconta => pr_nrdconta,
													 pr_nrdrowid => vr_nrdrowid);

		  -- Gera item do LOG
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Contrato',
																pr_dsdadant => '',
																pr_dsdadatu => pr_nrctremp);

		  -- Gera item do LOG
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Data de Pagamento',
																pr_dsdadant => '',
																pr_dsdadatu => TO_CHAR(rw_crapepr.dtdpagto,'DD/MM/RRRR'));

		  -- Gera item do LOG
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Saldo Disponivel CC',
																pr_dsdadant => TO_CHAR(vr_vlsldis2,'fm999g999g999g990d00'),
																pr_dsdadatu => TO_CHAR(vr_vlsldisp,'fm999g999g999g990d00'));

		  -- Gera item do LOG
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Valor Pago Atraso',
																pr_dsdadant => '',
																pr_dsdadatu => TO_CHAR(vr_vlpagatr,'fm999g999g999g990d00'));

      -- Gera item do LOG
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Meses Decorridos',
																pr_dsdadant => '',
																pr_dsdadatu => pr_qtmesdec);
                        
      -- Gera item do LOG        
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Qtde. Prest. Pagas',
																pr_dsdadant => '',
																pr_dsdadatu => pr_qtprecal);                                
      -- Gera item do LOG
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Valor Pago Multa',
																pr_dsdadant => '',
																pr_dsdadatu => TO_CHAR(vr_vldmulta,'fm999g999g999g990d00'));

		  -- Gera item do LOG
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Valor Pago Juros Mora',
																pr_dsdadant => '',
																pr_dsdadatu => TO_CHAR(vr_vldjuros,'fm999g999g999g990d00'));                          
                                
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN vr_exc_saida THEN
        NULL;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela EMPR0009: ' || SQLERRM;
    END;

  END pc_efetiva_pag_atraso_tr;

	PROCEDURE pc_efetiva_lcto_pendente_job IS
  BEGIN
    /* .............................................................................

       Programa: pc_efetiva_lcto_pendente_job
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Maio/2016                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para efetivar o lancamento pendente via JOB.

       Alteracoes: 

    ............................................................................. */
    DECLARE

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cdcooper
          FROM crapcop
         WHERE flgativo = 1;

      -- Cursor para retornar lancamentos automaticos
      CURSOR cr_craplau(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT nrdconta
              ,vllanaut
              ,dtmvtolt
              ,nrdolote
              ,nrseqdig
              ,cdhistor
              ,nrctremp
              ,ROW_NUMBER() OVER (PARTITION BY nrdconta ORDER BY nrdconta) AS numconta
          FROM craplau      
         WHERE cdcooper = pr_cdcooper
           AND insitlau = 1 -- Pendente
           AND cdbccxlt = 100
           AND nrdolote = 600033
           AND dsorigem = 'TRMULTAJUROS';

      -- Busca dados do cooperado
      CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT cdagenci
              ,vllimcre
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Cursor generico de calendario
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

      -- Variaveis
      vr_index    PLS_INTEGER;
      vr_blnfound BOOLEAN;
      vr_flgerlog BOOLEAN;
      vr_des_reto VARCHAR2(3);
      vr_vlsldisp NUMBER;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_tab_erro  GENE0001.typ_tab_erro;

      -- Tabela de Saldos
      vr_tab_saldos EXTR0001.typ_tab_saldos;

      --------------------------- SUBROTINAS INTERNAS --------------------------
      --> Controla log proc_batch, para apensa exibir qnd realmente processar informacao
      PROCEDURE pc_controla_log_batch(pr_cdcooper IN PLS_INTEGER
                                     ,pr_dstiplog IN VARCHAR2
                                     ,pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
      BEGIN

        --> Controlar geração de log de execução dos jobs
        BTCH0001.pc_log_exec_job( pr_cdcooper  => pr_cdcooper    --> Cooperativa
                                 ,pr_cdprogra  => 'JBEPR_LCTO_MULTA_JUROS_TR' --> Codigo do programa
                                 ,pr_nomdojob  => 'JBEPR_LCTO_MULTA_JUROS_TR' --> Nome do job
                                 ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                                 ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                                 ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim

      END pc_controla_log_batch;

    BEGIN

      -- Listagem de cooperativas
      FOR rw_crapcop IN cr_crapcop LOOP

        -- Log de inicio de execucao
        pc_controla_log_batch(pr_cdcooper => rw_crapcop.cdcooper
                             ,pr_dstiplog => 'I');

        -- Verifica se a data esta cadastrada
        OPEN  BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        -- Alimenta a booleana
        vr_blnfound := BTCH0001.cr_crapdat%FOUND;
        -- Fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
        -- Se NAO encontrar
        IF NOT vr_blnfound THEN
          -- Log de erro de execucao
          pc_controla_log_batch(pr_cdcooper => rw_crapcop.cdcooper
                               ,pr_dstiplog => 'E',
                                pr_dscritic => GENE0001.fn_busca_critica(pr_cdcritic => 1));
          CONTINUE;
        END IF;

        -- Final de semana e Feriado nao pode ocorrer o debito
        IF TRUNC(SYSDATE) <> rw_crapdat.dtmvtolt and rw_crapdat.inproces = 1 THEN
          CONTINUE;
        END IF;

        -- Condicao para verificar se o processo estah rodando
        IF NVL(rw_crapdat.inproces,0) <> 1 THEN
          CONTINUE;
        END IF;

        -- Busca todos os lancamentos pendentes
        FOR rw_craplau IN cr_craplau(pr_cdcooper => rw_crapcop.cdcooper) LOOP

          -- Se for a primeira vez de acesso da conta
          IF rw_craplau.numconta = 1 THEN
            
            -- Busca dados do cooperado
            OPEN cr_crapass(pr_cdcooper => rw_crapcop.cdcooper
                           ,pr_nrdconta => rw_craplau.nrdconta);
            FETCH cr_crapass INTO rw_crapass;
            -- Fecha o cursor
            CLOSE cr_crapass;

            -- Limpa tabela saldos
            vr_tab_saldos.DELETE;
      		
            -- Buscar o saldo disponivel a vista		
            EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => rw_crapcop.cdcooper
                                       ,pr_rw_crapdat => rw_crapdat
                                       ,pr_cdagenci   => rw_crapass.cdagenci
                                       ,pr_nrdcaixa   => 0
                                       ,pr_cdoperad   => '1'
                                       ,pr_nrdconta   => rw_craplau.nrdconta
                                       ,pr_flgcrass   => FALSE
                                       ,pr_vllimcre   => rw_crapass.vllimcre
                                       ,pr_dtrefere   => rw_crapdat.dtmvtolt
                                       ,pr_des_reto   => vr_des_reto
                                       ,pr_tab_sald   => vr_tab_saldos
                                       ,pr_tipo_busca => 'A'
                                       ,pr_tab_erro   => vr_tab_erro);
            -- Buscar Indice
            vr_index := vr_tab_saldos.FIRST;
            IF vr_index IS NOT NULL THEN
              -- Saldo Disponivel
              vr_vlsldisp := ROUND(NVL(vr_tab_saldos(vr_index).vlsddisp, 0) +
                                   NVL(vr_tab_saldos(vr_index).vlsdchsl, 0) +
                                   NVL(vr_tab_saldos(vr_index).vlsdbloq, 0) +
                                   NVL(vr_tab_saldos(vr_index).vlsdblpr, 0) +
                                   NVL(vr_tab_saldos(vr_index).vlsdblfp, 0) +
                                   NVL(vr_tab_saldos(vr_index).vllimcre, 0),2);
            END IF;
      		
          END IF;

          -- Verificar se possui saldo disponivel
          IF NVL(vr_vlsldisp, 0) - rw_craplau.vllanaut >= 0 THEN
            -- Efetivar lancamento
            TELA_LAUTOM.pc_efetiva_lcto_pendente(pr_cdcooper => rw_crapcop.cdcooper
                                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                ,pr_dtrefere => rw_craplau.dtmvtolt
                                                ,pr_cdagenci => rw_crapass.cdagenci
                                                ,pr_cdbccxlt => 0
                                                ,pr_cdoperad => '1'
                                                ,pr_nrdolote => rw_craplau.nrdolote
                                                ,pr_nrdconta => rw_craplau.nrdconta
                                                ,pr_cdhistor => rw_craplau.cdhistor
                                                ,pr_nrctremp => rw_craplau.nrctremp
                                                ,pr_nrseqdig => rw_craplau.nrseqdig
                                                ,pr_vllanmto => rw_craplau.vllanaut
                                                ,pr_cdcritic => vr_cdcritic
                                                ,pr_dscritic => vr_dscritic);
            -- Se ocorreu erro
            IF vr_dscritic IS NOT NULL THEN
              -- Log de erro de execucao
              pc_controla_log_batch(pr_cdcooper => rw_crapcop.cdcooper
                                   ,pr_dstiplog => 'E',
                                    pr_dscritic => vr_dscritic);
              CONTINUE;
            END IF;

            -- Para cada lancamento diminuir saldo disponivel
            vr_vlsldisp	:= vr_vlsldisp - rw_craplau.vllanaut;

          END IF;

        END LOOP; -- cr_craplau

        -- Log de final de execucao
        pc_controla_log_batch(pr_cdcooper => rw_crapcop.cdcooper
                             ,pr_dstiplog => 'F');

        COMMIT;

      END LOOP; -- cr_crapcop

    EXCEPTION
      WHEN vr_exc_saida THEN
        NULL;

    END;

  END pc_efetiva_lcto_pendente_job;

END EMPR0009;
/
