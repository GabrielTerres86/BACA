CREATE OR REPLACE PROCEDURE CECRED.pc_crps735(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo Cooperativa
                                             ,pr_stprogra OUT PLS_INTEGER               --> Saida de termino da execucao
                                             ,pr_infimsol OUT PLS_INTEGER               --> Saida de termino da solicitacao
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da Critica
                                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da Critica
BEGIN
  /* .............................................................................

     Programa: pc_crps735
     Sistema : Crédito - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Lucas Lazari (GFT)
     Data    : Junho/2018                     Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Diaria.
     Objetivo  : Realiza o pagamento de títulos vencidos através das regras de raspada de conta corrente.

     Alteracoes:

  ............................................................................ */
  DECLARE

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Codigo do programa
    vr_cdprogra  CONSTANT crapprg.cdprogra%TYPE := 'CRPSYYY';

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    ------------------------------- CURSORES ---------------------------------
    -- Cursor generico de calendario
    rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;
    
    -- Busca dos dados do associado
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT 0
                     ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE DEFAULT 0) IS
     SELECT crapass.cdcooper
           ,crapass.nrdconta
           ,crapass.inpessoa
           ,crapass.vllimcre
           ,crapass.nmprimtl
           ,crapass.nrcpfcgc
           ,crapass.dtdemiss
           ,crapass.inadimpl
       FROM crapass
      WHERE crapass.cdcooper = pr_cdcooper
        AND crapass.nrdconta = DECODE(pr_nrdconta,0,crapass.nrdconta,pr_nrdconta)
        AND crapass.nrcpfcgc = DECODE(pr_nrcpfcgc,0,crapass.nrcpfcgc,pr_nrcpfcgc);
    rw_crapass cr_crapass%ROWTYPE;
    
    --  Busca todos os títulos liberados que estão vencidos e pendentes de pagamento
    CURSOR cr_craptdb(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
      SELECT ROWID,
             craptdb.cdcooper,
             craptdb.nrdconta,
             craptdb.nrborder,
             craptdb.cdbandoc,
             craptdb.dtvencto,
             craptdb.dtlibbdt,
             craptdb.nrcnvcob,
             craptdb.nrdctabb,
             craptdb.nrdocmto,
             craptdb.nrinssac,
             craptdb.vltitulo,
             craptdb.vlsldtit,
             craptdb.vliofcpl,
             craptdb.vlpagiof,
             craptdb.vlmtatit,
             craptdb.vlpagmta,
             craptdb.vlmratit,
             craptdb.vlpagmra,
             craptdb.vlliquid
        FROM craptdb
       WHERE craptdb.cdcooper  = pr_cdcooper
         AND craptdb.dtvencto  < pr_dtmvtolt
         AND craptdb.insittit  = 4 -- liberado
       ORDER BY dtvencto, vlsldtit desc;
       
    -- Busca o borderô para verificar a qual versão ele pertence
    CURSOR cr_crapbdt (pr_cdcooper IN crapbdt.cdcooper%type
                      ,pr_nrborder IN crapbdt.nrborder%type) IS
      SELECT crapbdt.txmensal
            ,crapbdt.vltaxiof
            ,crapbdt.flverbor
            ,crapbdt.vltxmult
            ,crapbdt.vltxmora 
      FROM crapbdt
      WHERE crapbdt.cdcooper = pr_cdcooper
      AND   crapbdt.nrborder = pr_nrborder;
    rw_crapbdt cr_crapbdt%ROWTYPE;

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

    

    ------------------------------- VARIAVEIS -------------------------------
    
    vr_dsctajud     crapprm.dsvlrprm%TYPE; -- Armazena as conta que possuem alguma ação judicial
    vr_dtultdia     DATE;                  -- Variavel para armazenar o ultimo dia util do ano
    
    vr_tab_saldos EXTR0001.typ_tab_saldos;

    -- Variavel dos Indices
    vr_index_saldo PLS_INTEGER;
    
    -- Variaveis tratamento de erros
    vr_exc_erro EXCEPTION;
    vr_des_reto VARCHAR2(10);
    vr_tab_erro GENE0001.typ_tab_erro;
    vr_vlsldisp NUMBER;  
    vr_flgcrass BOOLEAN;    
    
  BEGIN
    --------------- VALIDACOES INICIAIS -----------------

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra
                              ,pr_action => NULL);

    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

    -- Leitura do calendario
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      vr_cdcritic := 1;
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_saida;
    END IF;
    CLOSE BTCH0001.cr_crapdat;

    -- Validacoes iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se possui erro
    IF vr_cdcritic <> 0 THEN
      RAISE vr_exc_saida;
    END IF;
    
    -- Lista de contas que nao podem debitar na conta corrente, devido a acao judicial
    vr_dsctajud := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                             pr_cdcooper => pr_cdcooper,
                                             pr_cdacesso => 'CONTAS_ACAO_JUDICIAL');  
      
    
    -- Rotina para achar o ultimo dia útil do ano
    vr_dtultdia := add_months(TRUNC(rw_crapdat.dtmvtoan,'RRRR'),12)-1;    
    CASE to_char(vr_dtultdia,'d') 
      WHEN '1' THEN vr_dtultdia := vr_dtultdia - 2;
      WHEN '7' THEN vr_dtultdia := vr_dtultdia - 1;
      ELSE vr_dtultdia := add_months(TRUNC(rw_crapdat.dtmvtoan,'RRRR'),12)-1;
    END CASE;
    
    -- Loop principal dos títulos vencidos
    FOR rw_craptdb IN cr_craptdb(pr_cdcooper => pr_cdcooper
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP

      -- Valida existência do borderô do respectivo título
      OPEN cr_crapbdt (pr_cdcooper => pr_cdcooper
                      ,pr_nrborder => rw_craptdb.nrborder);
      FETCH cr_crapbdt INTO rw_crapbdt;

      IF cr_crapbdt%NOTFOUND THEN
        vr_cdcritic := 1166; --Bordero nao encontrado. Ajuste mensagem de erro - 15/02/2018 - Chamado 851591
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        CLOSE cr_crapbdt;
      RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapbdt;
      
      --Verifica se a conta existe
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => rw_craptdb.nrdconta);
      FETCH cr_crapass INTO rw_crapass;
        
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_cdcritic := 9; --Associado n cadastrado: --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapass;
      
      /* Somente os títulos de borderôs inclusos na versão nova devem ser considerados aqui */
      IF rw_crapbdt.flverbor = 0 THEN
        CONTINUE;
      END IF;
      
      -- Condicao para verificar se permite incluir as linhas parametrizadas
      IF INSTR(',' || vr_dsctajud || ',',',' || rw_craptdb.nrdconta || ',') > 0 THEN
        CONTINUE;
      END IF;
      
      /* Caso o titulo venca num feriado ou fim de semana, pula pois sera pego no proximo dia util */
      IF gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                     pr_dtmvtolt => rw_craptdb.dtvencto) > rw_crapdat.dtmvtoan THEN
        CONTINUE;
      END IF;
      
      -- #################################################################################################
      --   REGRA PARA NÃO DEBITAR TÍTULOS VENCIDOS NO PRIMEIRO DIA UTIL DO ANO E QUE VENCERAM NO
      --   DIA UTIL ANTERIOR.
      --   Ex: Boleto com vencto  = 29/12/2017  (ultimo dia útil do ano)
      --       Se o movimento for = 02/01/2018  (primeiro dia util do ano) -- nao debitar --
      --       Se o movimento for = 03/01/2018  (segundo dia util do ano)  -- debitar --
      -- #################################################################################################        
      -- se o titulo vencer no último dia útil do ano e também no dia útil anterior,
      -- entao "não" deverá debitar o título
      IF rw_craptdb.dtvencto = vr_dtultdia AND
         rw_craptdb.dtvencto = rw_crapdat.dtmvtoan THEN
         CONTINUE;
      END IF;
      -- #################################################################################################
      
      -- OBS: Adicionar regra para verificar emissão de boletos pela COBTIT
      
      -- Verificar se o BATCH esta rodando
      IF rw_crapdat.inproces <> 1 THEN
        -- Se estiver no BATCH, utiliza a verificacao da conta a partir do vetor de contas
        -- que se nao estiver carregado fara a leitura de todas as contas da cooperativa
        -- Quando eh BATCH mantem o padrao TRUE
        vr_flgcrass := TRUE;
      ELSE 
        -- Se nao estiver no BATCH, busca apenas a informacao da conta que esta sendo passada
        vr_flgcrass := FALSE;
      END IF;
      
      
      -- Limpar tabela saldos
      vr_tab_saldos.DELETE;

      -- Obter Saldo do Dia
      EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper
                                 ,pr_rw_crapdat => rw_crapdat
                                 ,pr_cdagenci   => 1
                                 ,pr_nrdcaixa   => 100
                                 ,pr_cdoperad   => 1
                                 ,pr_nrdconta   => rw_craptdb.nrdconta
                                 ,pr_vllimcre   => rw_crapass.vllimcre
                                 ,pr_dtrefere   => rw_crapdat.dtmvtolt
                                 ,pr_flgcrass   => FALSE
                                 ,pr_des_reto   => vr_des_reto
                                 ,pr_tab_sald   => vr_tab_saldos
                                 ,pr_tipo_busca => 'A'
                                 ,pr_tab_erro   => vr_tab_erro);
                                 
      -- Se retornou erro
      IF vr_des_reto <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_dscritic := 'Erro na procedure pc_crps735.';
        END IF;
        RAISE vr_exc_erro;
      END IF;

      -- Buscar Indice
      vr_index_saldo := vr_tab_saldos.FIRST;
      IF vr_index_saldo IS NOT NULL THEN
        -- Acumular Saldo
        vr_vlsldisp := ROUND(NVL(vr_tab_saldos(vr_index_saldo).vlsddisp, 0) + NVL(vr_tab_saldos(vr_index_saldo).vllimcre, 0),2);
      END IF;
      
      -- se não há saldo disponível na conta corrente, pula o título
      IF vr_vlsldisp <= 0 THEN
        CONTINUE;
      END IF;
      
      -- Realiza o pagamento do título
      DSCT0003.pc_pagar_titulo( pr_cdcooper => pr_cdcooper 
                               ,pr_cdagenci => 1  
                               ,pr_nrdcaixa => 100  
                               ,pr_idorigem => 1  
                               ,pr_cdoperad => 1  
                               ,pr_nrdconta => rw_craptdb.nrdconta    
                               ,pr_nrborder => rw_craptdb.nrborder    
                               ,pr_cdbandoc => rw_craptdb.cdbandoc    
                               ,pr_nrdctabb => rw_craptdb.nrdctabb    
                               ,pr_nrcnvcob => rw_craptdb.nrcnvcob    
                               ,pr_nrdocmto => rw_craptdb.nrdocmto    
                               ,pr_cdorigpg => 0 -- Conta corrente
                               ,pr_vlpagmto => vr_vlsldisp
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt    
                               ,pr_inproces => rw_crapdat.inproces    
                               ,pr_cdcritic => vr_cdcritic    
                               ,pr_dscritic => vr_cdcritic);

      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    END LOOP;

    -- Processo OK, devemos chamar a fimprg
    BTCH0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    COMMIT;

  EXCEPTION

    WHEN vr_exc_saida THEN
      vr_cdcritic := NVL(vr_cdcritic, 0);
      IF vr_cdcritic > 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
      END IF;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
      -- Efetuar rollback
      ROLLBACK;

  END;

END pc_crps735;
/
