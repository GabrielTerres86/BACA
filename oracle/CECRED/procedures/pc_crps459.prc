CREATE OR REPLACE PROCEDURE CECRED.pc_crps459(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Coop conectada
                                             ,pr_flgresta IN PLS_INTEGER            --> Indicador para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
                                             
  /* ............................................................................
   Programa: PC_CRPS459 (Antigo Fontes/crps459.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes     
   Data    : Novembro/2005                     Ultima atualizacao: 25/10/2017

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 001.
               Lancar tarifa aditivos de emprestimos.                    

   Alteracoes: 17/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
   
               11/07/2013 - Alterado processo de busca tarifas de aditivos
                            projeto tarifas (Daniel). 
                            
               11/10/2013 - Incluido parametro cdprogra nas procedures da 
                            b1wgen0153 que carregam dados de tarifas (Tiago).
                            
               29/11/2013 - Efetuado restruturacao dos logs de tarifa (Tiago).
               
               20/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714)
  
               05/03/2015 - Conversão Progress >> Oracle PL-Sql (Daniel)
  
               25/08/2015 - Inclusao do parametro pr_cdpesqbb na procedure
                            tari0001.pc_cria_lan_auto_tarifa, projeto de 
                            Tarifas-218(Jean Michel)
  
               25/10/2017 - Inclusao de regra para aditivos de
                            emprestimo/financiamento ou aplicacao de terceiro.
                            (Jaison/Marcos Martini - PRJ404)

  ............................................................................. */
  
  ------------------------------- CURSORES ---------------------------------
  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT cop.nmrescop
          ,cop.nmextcop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  -- Cursor genérico de calendário
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
  -- Cursor Leitura Lançamentos
  CURSOR cr_crapadt(pr_cdcooper IN crapadt.cdcooper%TYPE,
                    pr_dtmvtolt IN crapadt.dtmvtolt%TYPE) IS
    
    SELECT adt.nrdconta
          ,adt.nrctremp
          ,adt.cdaditiv
          ,adt.tpctrato
          ,ROW_NUMBER () OVER (PARTITION BY adt.nrdconta ORDER BY adt.nrdconta) nrseq
          ,COUNT(1) OVER (PARTITION BY adt.nrdconta ORDER BY adt.nrdconta) qtreg
     FROM crapadt adt
    WHERE adt.cdcooper = pr_cdcooper
      AND adt.dtmvtolt = pr_dtmvtolt
          ORDER BY adt.cdcooper
                   ,adt.nrdconta 
                   ,adt.nrctremp;
                  
                  
  -- Cursor Leitura Associado
  CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                     pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT crapass.inpessoa,
           crapass.nrdconta
      FROM crapass
     WHERE crapass.cdcooper = pr_cdcooper
       AND crapass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

  -- Buscar configuracao da garantia de limite
  CURSOR cr_gar_wpr(pr_cdcooper IN crawepr.cdcooper%TYPE
                   ,pr_nrdconta IN crawepr.nrdconta%TYPE
                   ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
    SELECT gar.nrconta_terceiro
      FROM tbgar_cobertura_operacao gar
          ,crawepr wpr
    WHERE wpr.idcobope = gar.idcobertura
      AND wpr.cdcooper = pr_cdcooper
      AND wpr.nrdconta = pr_nrdconta
      AND wpr.nrctremp = pr_nrctremp;

  -- Buscar configuracao da garantia de emprestimo/financiamento
  CURSOR cr_gar_lim(pr_cdcooper IN craplim.cdcooper%TYPE
                   ,pr_nrdconta IN craplim.nrdconta%TYPE
                   ,pr_nrctrlim IN craplim.nrctrlim%TYPE
                   ,pr_tpctrlim IN craplim.tpctrlim%TYPE) IS
    SELECT gar.nrconta_terceiro
      FROM tbgar_cobertura_operacao gar
          ,craplim lim
    WHERE lim.idcobope = gar.idcobertura
      AND lim.cdcooper = pr_cdcooper
      AND lim.nrdconta = pr_nrdconta
      AND lim.nrctrlim = pr_nrctrlim
      AND lim.tpctrlim = pr_tpctrlim;

  ------------------------------- VARIAVEIS -------------------------------
  -- Código do programa
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS459';

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic PLS_INTEGER;
  vr_dscritic VARCHAR2(4000);
  
  -- Tabela Temporaria
  vr_tab_erro GENE0001.typ_tab_erro;
  
  -- Rowid de retorno lançamento de tarifa
  vr_rowid    ROWID;
 
  vr_cdhistor craphis.cdhistor%TYPE;
  vr_cdhisest craphis.cdhistor%TYPE;
  vr_dtdivulg DATE;
  vr_dtvigenc DATE;
  vr_cdfvlcop crapfco.cdfvlcop%TYPE;
  vr_vltarifa crapfco.vltarifa%TYPE;
  vr_cdbattar VARCHAR2(100);
  vr_valor    NUMBER  := 0;
  vr_nrconta_terceiro tbgar_cobertura_operacao.nrconta_terceiro%TYPE;

  -- Listas utilizadas para carga de tarifas
  vr_lstarifa VARCHAR2(2000);
  vr_lspessoa VARCHAR2(2000);
  vr_lsaditiv VARCHAR2(2000);
  
  -- Tabela temporaria para as tarifas
  TYPE typ_reg_tarifa IS
   RECORD(cdbattar VARCHAR2(100)
         ,cdhistor crapfvl.cdhistor%TYPE
         ,cdfvlcop crapfvl.cdfaixav%TYPE
         ,vltarifa crapfco.vltarifa%TYPE
         ,inpessoa crapass.inpessoa%TYPE
         ,cdaditiv crapadt.cdaditiv%TYPE);
  TYPE typ_tab_tarifa IS
    TABLE OF typ_reg_tarifa
      INDEX BY VARCHAR2(10);
  -- Vetor para armazenar os percentuais de risco
  vr_tab_tarifa typ_tab_tarifa;
  -- Variavel para o indice
  vr_indice_tarifa VARCHAR2(10);
  
  
BEGIN

  -- Incluir nome do módulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                            ,pr_action => NULL);
                              
  -- Verifica se a cooperativa esta cadastrada
  OPEN cr_crapcop;
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
    
  -- Leitura do calendário da cooperativa
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
  -- Se não encontrar
  IF BTCH0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor pois efetuaremos raise
    CLOSE BTCH0001.cr_crapdat;
    -- Montar mensagem de critica
    vr_cdcritic:= 1;
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
  
  --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
  
  vr_lstarifa := 'ALTDTDEBPF;ALTDTDEBPJ;' || -- Aditivo de alteracao da data de debito                 
                 'APLICVINPF;APLICVINPJ;' || --  Aditivo de aplicacao vinculada de emprestimo           
                 'APLICTERPF;APLICTERPJ;' || -- Aditivo de aplicacao vinculada terceiro                
                 'INCLFIADPF;INCLFIADPJ;' || -- Inclusao de fiador/avalista em emprestimo concedido    
                 'SUBSTVEIPF;SUBSTVEIPJ;' || -- Aditivo efetuuando substituicao de veiculo             
                 'GARANVEIPF;GARANVEIPJ;' || -- Inclusao interveniente garantidor de veiculo           
                 'SUBROCNPPF;SUBROCNPPJ;' || -- Sub-rogacao c/ nota promissoria                        
                 'SUBROSNPPF;SUBROSNPPJ;' || -- Sub-rogacao s/ nota promissoria
                 'APLICVINPF;APLICVINPJ;' || -- Aditivo de Garantia aplicacao vinculada de emprestimo
                 'APLICTERPF;APLICTERPJ';    -- Aditivo de Garantia aplicacao vinculada terceiro

  -- 1 - Pessoa Fisica    2 - Pessoa Juridica 
  vr_lspessoa := '1;2;' ||
                 '1;2;' ||
                 '1;2;' ||
                 '1;2;' ||
                 '1;2;' ||
                 '1;2;' ||
                 '1;2;' ||
                 '1;2;' ||
                 '1;2;' ||
                 '1;2;';  
    
  vr_lsaditiv := '1;1;' || -- 1 - Aditivo de alteracao da data de debito               
                 '2;2;' || -- 2 - Aditivo de aplicacao vinculada de emprestimo         
                 '3;3;' || -- 3 - Aditivo de aplicacao vinculada terceiro              
                 '4;4;' || -- 4 - Inclusao de fiador/avalista em emprestimo concedido  
                 '5;5;' || -- 5 - Aditivo efetuuando substituicao de veiculo           
                 '6;6;' || -- 6 - Inclusao interveniente garantidor de veiculo         
                 '7;7;' || -- 7 - Sub-rogacao c/ nota promissoria                      
                 '8;8;' || -- 8 - Sub-rogacao s/ nota promissoria
                 '9;9;' || -- 2 - Aditivo de aplicacao vinculada de emprestimo
                 '10;10';  -- 3 - Aditivo de aplicacao vinculada terceiro
                  
  -- Popula a PL/TABLE de tarifas
  FOR ind IN 1..20 LOOP
     
    -- Inicializa as variaveis
    vr_cdhistor := 0;      
    vr_cdfvlcop := 0;
    vr_vltarifa := 0;
         
    -- Codigo da Tarifa
    vr_cdbattar := gene0002.fn_busca_entrada(ind,vr_lstarifa,';');
         
    -- Monta indice da PL/TABLE
    vr_indice_tarifa := LPAD(gene0002.fn_busca_entrada(ind,vr_lspessoa,';'),5,'0') ||
                        LPAD(gene0002.fn_busca_entrada(ind,vr_lsaditiv,';'),5,'0');
       
    -- Busca valor da tarifa transferencia cartao BB pessoa fisica
    TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                         ,pr_cdbattar => vr_cdbattar
                                         ,pr_vllanmto => 1
                                         ,pr_cdprogra => vr_cdprogra
                                         ,pr_cdhistor => vr_cdhistor
                                         ,pr_cdhisest => vr_cdhisest
                                         ,pr_vltarifa => vr_vltarifa
                                         ,pr_dtdivulg => vr_dtdivulg
                                         ,pr_dtvigenc => vr_dtvigenc
                                         ,pr_cdfvlcop => vr_cdfvlcop
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic
                                         ,pr_tab_erro => vr_tab_erro);
                                                      
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
      --Se possui erro no vetor
      IF vr_tab_erro.Count() > 0 THEN
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel carregar a tarifa.';
      END IF;
      -- Envio centralizado de log de erro
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic || ' - ' || vr_cdbattar);
      -- Efetua Limpeza das variaveis de critica
      vr_cdcritic := 0;
      vr_dscritic := NULL;
    END IF;
     
    -- Armazena Valores na PL/TABLE
    vr_tab_tarifa(vr_indice_tarifa).inpessoa := gene0002.fn_busca_entrada(ind,vr_lspessoa,';');
    vr_tab_tarifa(vr_indice_tarifa).cdbattar := vr_cdbattar;
    vr_tab_tarifa(vr_indice_tarifa).cdaditiv := gene0002.fn_busca_entrada(ind,vr_lsaditiv,';');
    vr_tab_tarifa(vr_indice_tarifa).cdhistor := vr_cdhistor;
    vr_tab_tarifa(vr_indice_tarifa).cdfvlcop := vr_cdfvlcop;
    vr_tab_tarifa(vr_indice_tarifa).vltarifa := vr_vltarifa;
     
  END LOOP;  
   
   
  -- Leitura dos Aditivos
  FOR rw_crapadt IN cr_crapadt(pr_cdcooper => pr_cdcooper,
                               pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
                               
    -- Sempre que for primeiro registro da conta, limpa valor a ser cobrado de tarifa
    IF rw_crapadt.nrseq = 1 THEN
      vr_valor := 0;
    END IF;                            
                     
    -- Selecionar Dados Associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => rw_crapadt.nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    -- Se nao encontrou associado
    IF cr_crapass%NOTFOUND THEN
      vr_cdcritic:= 9; 
      vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic)||
                    gene0002.fn_mask(rw_crapadt.nrdconta,'zzzz.zzz.9');
      -- Fechar Cursor
      CLOSE cr_crapass;
      
      -- Gera Log
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro Tratado
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                    ' -' || vr_cdprogra || ' --> '  ||
                                                    vr_dscritic);
      
      -- Efetua Limpeza das variaveis de critica
      vr_cdcritic := 0;
      vr_dscritic := NULL;
                                                  
      --Proximo Registro
      CONTINUE;
    END IF;
    
    --Fechar Cursor
    CLOSE cr_crapass;

    -- Se for aditivo de emprestimo ou aplicacao de terceiro
    IF rw_crapadt.cdaditiv = 9 THEN

      -- Inicializa
      vr_nrconta_terceiro := 0;

      -- Se for Emprestimo/Financiamento
      IF rw_crapadt.tpctrato = 90 THEN
        -- Buscar configuracao da garantia por Emprestimo/Financiamento
        OPEN cr_gar_wpr(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => rw_crapadt.nrdconta
                       ,pr_nrctremp => rw_crapadt.nrctremp);
        FETCH cr_gar_wpr INTO vr_nrconta_terceiro;
        CLOSE cr_gar_wpr;
      ELSE
        -- Buscar configuracao da garantia por limite
        OPEN cr_gar_lim(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => rw_crapadt.nrdconta
                       ,pr_nrctrlim => rw_crapadt.nrctremp
                       ,pr_tpctrlim => rw_crapadt.tpctrato);
        FETCH cr_gar_lim INTO vr_nrconta_terceiro;
        CLOSE cr_gar_lim;
      END IF;

      -- Se garantia vinculada for de conta terceiro
      IF NVL(vr_nrconta_terceiro,0) <> 0 THEN
        -- Mudamos o tipo aditivo apenas para buscar tarifa correta
        rw_crapadt.cdaditiv := 10;
      END IF;

    END IF;

    -- Monta indice da PL/TABLE
    vr_indice_tarifa := LPAD(rw_crapass.inpessoa,5,'0') ||
                        LPAD(rw_crapadt.cdaditiv,5,'0');
  
    -- verifica se existe o registro na PL/TABLE
    IF vr_tab_tarifa.EXISTS(vr_indice_tarifa) THEN
      -- Acumula valor a ser tarifado
      vr_valor := vr_valor + NVL(vr_tab_tarifa(vr_indice_tarifa).vltarifa,0);
    END IF;
    
    -- Cobrança Tarifa de Aditivo quando for ultimo registro da Conta
    IF vr_valor > 0 AND (rw_crapadt.nrseq = rw_crapadt.qtreg) THEN 
      
      -- verifica se existe o registro na PL/TABLE
      IF vr_tab_tarifa.EXISTS(vr_indice_tarifa) THEN
        vr_cdhistor :=  NVL(vr_tab_tarifa(vr_indice_tarifa).cdhistor,0);
        vr_cdfvlcop :=  NVL(vr_tab_tarifa(vr_indice_tarifa).cdfvlcop,0);
      ELSE
        vr_cdhistor :=  0;
        vr_cdfvlcop :=  0;  
      END IF;  
 
      -- Criar Lançamento automatico tarifa
      TARI0001.pc_cria_lan_auto_tarifa( pr_cdcooper     => pr_cdcooper
                                      , pr_nrdconta     => rw_crapadt.nrdconta
                                      , pr_dtmvtolt     => rw_crapdat.dtmvtolt
                                      , pr_cdhistor     => vr_cdhistor
                                      , pr_vllanaut     => vr_valor
                                      , pr_cdoperad     => '1'
                                      , pr_cdagenci     => 1
                                      , pr_cdbccxlt     => 100
                                      , pr_nrdolote     => 10107
                                      , pr_tpdolote     => 1
                                      , pr_nrdocmto     => 0
                                      , pr_nrdctabb     => rw_crapadt.nrdconta
                                      , pr_nrdctitg     => gene0002.fn_mask(rw_crapadt.nrdconta,'99999999')
                                      , pr_cdpesqbb     => 'Fato gerador tarifa:' || TO_CHAR(rw_crapadt.nrctremp)
                                      , pr_cdbanchq     => 0
                                      , pr_cdagechq     => 0
                                      , pr_nrctachq     => 0
                                      , pr_flgaviso     => FALSE
                                      , pr_tpdaviso     => 0
                                      , pr_cdfvlcop     => vr_cdfvlcop
                                      , pr_inproces     => rw_crapdat.inproces
                                      , pr_rowid_craplat=> vr_rowid
                                      , pr_tab_erro     => vr_tab_erro
                                      , pr_cdcritic     => vr_cdcritic
                                      , pr_dscritic     => vr_dscritic
                                      );
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Se possui erro no vetor
        IF vr_tab_erro.Count > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.first).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.first).dscritic;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro no lancamento tarifa adtivo.';
        END IF;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '||
                                                      gene0002.fn_mask_conta(rw_crapadt.nrdconta)||'- '
                                                   || vr_dscritic );
        -- Limpa valores das variaveis de critica
        vr_cdcritic:= 0;
        vr_dscritic:= NULL;                                           
      END IF;
        
    END IF; -- Final Cobrança Tarifa
      
  END LOOP; -- Fim Leitura Associados

  -- Processo OK, devemos chamar a fimprg
  BTCH0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  -- Salvar informacoes no banco de dados
  COMMIT;
   

EXCEPTION
  WHEN vr_exc_fimprg THEN

    -- Se retornou apenas o codigo
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Busca Descrição
      vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
    END IF;

    -- Se foi gerado critica para envio ao log
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN

      -- Envio Centralizado de Log de Erro
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- ERRO TRATATO
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                    ' -' || vr_cdprogra || ' --> ' ||
                                                     vr_dscritic);

    END IF;

    -- Chamos o pc_valida_fimprg para encerrar o processo sem parar a cadeia
    BTCH0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);

    -- Salva informações no banco de dados
    COMMIT;
      
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic, 0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;
END pc_crps459;
/
