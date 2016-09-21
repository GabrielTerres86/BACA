CREATE OR REPLACE PROCEDURE CECRED.pc_crps150(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Coop conectada
                                      ,pr_flgresta IN PLS_INTEGER            --> Indicador para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
  /* ............................................................................
   Programa: PC_CRPS150 (Antigo Fontes/crps150.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson/Odair
   Data    : Marco/96.                       Ultima atualizacao: 26/04/2016

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Gerar lancamento de cobranca de tarifa sobre retirada
               de talonarios.

   Alteracoes: 21/05/96 - Alterado para tratar conta conjunta (ate 2 taloes
                          gratuitos por mes) (Deborah).

               05/02/97 - Nao cobrar taloes referente conta convenio CPMF
                          (Odair)

               27/08/97 - Alterado para incluir o campo flgproce na criacao
                          do crapavs (Deborah).

               15/03/99 - Alterado para permitir ate 2 talonarios para as
                          contas conjuntas (Deborah).

               05/03/99 - Nao selecionar cheques de transferencia (Odair)

               01/11/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               24/02/2003 - Usar agencia e numero do lote para separar
                            as agencias (Margarete).

               22/10/2004 - Tratar conta de integracao (Margarete).

               29/06/2005 - Alimentado  campo cdcooper das tabelas craplot,
                            craplcm e crapavs (Diego).
                            
               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               01/09/2008 - Alteracao CDEMPRES (Kbase).

               01/10/2008 - Lote 10023 para histor 162, trfa talao (Magui).
               
               15/12/2008 - Substituir a tab "ContaConve" pela gnctace (Ze).
               
               11/01/2013 - Tratamento para contas migradas 
                              Viacredi -> AltoVale. (Fabricio)
                              
               26/03/2013 - Ajustes referentes ao projeto tarifas fase 2
                            Grupo de cheques (Lucas R.)
                            
               11/10/2013 - Incluido parametro cdprogra nas procedures da 
                            b1wgen0153 que carregam dados de tarifas e incluído
                            tratamento pessoa jurídica (Tiago).
                            
               12/02/2014 - Retirados "Return" para nao abortar a execucao quando
                            for feita chamada a b1wgen0153 (Tiago).
    
               12/03/2015 - Conversão Progress >> Oracle PL-Sql (Daniel)
  
               25/08/2015 - Inclusao do parametro pr_cdpesqbb na procedure
                            tari0001.pc_cria_lan_auto_tarifa, projeto de 
                            Tarifas-218(Jean Michel)
														
							 26/04/2016 - Adicionado chamada da procedure TARI0001.pc_verifica_tarifa_operacao
							              para tratar isenção de tarifas. (Reinert)
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
      
  -- Cursor Cadastro de Aditivos Contratuais
  CURSOR cr_crapreq(pr_cdcooper IN crapreq.cdcooper%TYPE,
                    pr_dtmvtolt IN crapreq.dtmvtolt%TYPE) IS
    SELECT req.nrdconta
          ,req.cdcooper
          ,req.nrfinchq
          ,req.nrinichq
          ,NVL(ass.inpessoa,0) inpessoa
          ,NVL(ass.qtfolmes,0) qtfolmes
          ,ass.ROWID rowid_ass
     FROM crapreq req
         ,crapass ass
    WHERE req.cdcooper = pr_cdcooper
      AND req.dtmvtolt = pr_dtmvtolt           
      AND req.nrinichq > 0
      AND req.tprequis <> 2
      AND ass.cdcooper (+) = req.cdcooper
      AND ass.nrdconta (+) = req.nrdconta
      ORDER BY req.nrdconta;
      
  -- Cursor para verificar se Conta Migrada
  CURSOR cr_craptco(pr_cdcooper IN craptco.cdcooper%TYPE,
                    pr_nrdconta IN craptco.nrctaant%TYPE) IS
    SELECT tco.nrdconta
          ,tco.cdcooper
          ,NVL(ass.inpessoa,0) inpessoa
     FROM craptco tco
         ,crapass ass
    WHERE tco.cdcopant = pr_cdcooper
      AND tco.nrctaant = pr_nrdconta            
      AND tco.flgativo = 1 -- TRUE
      AND tco.tpctatrf = 1
      AND ass.cdcooper (+) = tco.cdcooper
      AND ass.nrdconta (+) = tco.nrdconta;
  rw_craptco cr_craptco%ROWTYPE;    
      
  ------------------------------- VARIAVEIS -------------------------------
  -- Código do programa
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS150';

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic PLS_INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_erro VARCHAR2(4000);
  
  -- Tabela Temporaria
  vr_tab_erro GENE0001.typ_tab_erro;
  
  -- Rowid de retorno lançamento de tarifa
  vr_rowid    ROWID;
 
  -- Variaveis de tarifa
  vr_cdhistor craphis.cdhistor%TYPE;
  vr_cdhisest craphis.cdhistor%TYPE;
  vr_dtdivulg DATE;
  vr_dtvigenc DATE;
  vr_cdfvlcop crapfco.cdfvlcop%TYPE;
  vr_vltarifa crapfco.vltarifa%TYPE;
  
  vr_dsconteu VARCHAR2(4000);
  
  vr_cdfvlcop_pf crapfco.cdfvlcop%TYPE;
  vr_vltarifa_pf crapfco.vltarifa%TYPE;
  vr_cdhistor_pf craphis.cdhistor%TYPE;
  
  vr_cdfvlcop_pj crapfco.cdfvlcop%TYPE;
  vr_vltarifa_pj crapfco.vltarifa%TYPE;
  vr_cdhistor_pj craphis.cdhistor%TYPE;
  
  vr_qtisenta NUMBER :=0;
  vr_qtretfol NUMBER :=0;
  
  vr_qtisenta_pf NUMBER :=0;
  vr_qtisenta_pj NUMBER :=0;
  
  vr_qtfolcob NUMBER :=0;
  vr_qtfolmes NUMBER :=0;
  vr_nrdconta crapass.nrdconta%TYPE;
  vr_migrado BOOLEAN := FALSE;

	-- Variáveis utilizadas na chamada da procedure TARI0001.pc_verifica_tarifa_operacao
	vr_qtacobra INTEGER;
	vr_fliseope INTEGER;

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
  
 
  TARI0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper,
                                         pr_cdbattar => 'FLSCHQISEN',
                                         pr_dsconteu => vr_dsconteu,
                                         pr_cdcritic => vr_cdcritic,
                                         pr_dscritic => vr_dscritic,
                                         pr_des_erro => vr_des_erro,
                                         pr_tab_erro => vr_tab_erro);
                                         
  -- Verifica se Houve Erro no Retorno
  IF vr_des_erro = 'NOK' THEN
    -- Envio Centralizado de Log de Erro
    IF vr_tab_erro.count > 0 THEN

      -- Recebe Fescrição do Erro
      vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

      -- Gera Log
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro Tratado
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                    ' -' || vr_cdprogra || ' --> '  ||
                                                    vr_dscritic || ' - FLSCHQISEN');
      -- Efetua Limpeza das variaveis de critica
      vr_cdcritic := 0;
      vr_dscritic := NULL;
      
      -- Quantidade Isento
      vr_qtisenta_pf := 0;
    END IF;
  ELSE
    -- Quantidade Isento
    vr_qtisenta_pf := to_number(vr_dsconteu);  
  END IF;
  
  TARI0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper,
                                         pr_cdbattar => 'FLCHQISEPJ',
                                         pr_dsconteu => vr_dsconteu,
                                         pr_cdcritic => vr_cdcritic,
                                         pr_dscritic => vr_dscritic,
                                         pr_des_erro => vr_des_erro,
                                         pr_tab_erro => vr_tab_erro);
                                         
  -- Verifica se Houve Erro no Retorno
  IF vr_des_erro = 'NOK' THEN
    -- Envio Centralizado de Log de Erro
    IF vr_tab_erro.count > 0 THEN

      -- Recebe Fescrição do Erro
      vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

      -- Gera Log
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro Tratado
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                    ' -' || vr_cdprogra || ' --> '  ||
                                                    vr_dscritic || ' - FLCHQISEPJ');
      -- Efetua Limpeza das variaveis de critica
      vr_cdcritic := 0;
      vr_dscritic := NULL;
      
      -- Quantidade Isento
      -- Caso der erro assume valor da Pessoa Fisica
      vr_qtisenta_pj := vr_qtisenta_pf;
    END IF;
  ELSE
    -- Quantidade Isento
    vr_qtisenta_pj := to_number(vr_dsconteu);  
  END IF;
  
  -- Busca valor da tarifa 
  TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                       ,pr_cdbattar => 'FOLHACHQPJ'
                                       ,pr_vllanmto => 1
                                       ,pr_cdprogra => vr_cdprogra
                                       ,pr_cdhistor => vr_cdhistor_pj
                                       ,pr_cdhisest => vr_cdhisest
                                       ,pr_vltarifa => vr_vltarifa_pj
                                       ,pr_dtdivulg => vr_dtdivulg
                                       ,pr_dtvigenc => vr_dtvigenc
                                       ,pr_cdfvlcop => vr_cdfvlcop_pj
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic
                                       ,pr_tab_erro => vr_tab_erro);
                                                      
  --Se ocorreu erro
  IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
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
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                               || vr_cdprogra || ' --> '
                                               || vr_dscritic || ' - FOLHACHQPJ');
    -- Efetua Limpeza das variaveis de critica
    vr_cdcritic := 0;
    vr_dscritic := NULL;
  END IF;

  -- Busca valor da tarifa 
  TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                       ,pr_cdbattar => 'FOLHACHQPF'
                                       ,pr_vllanmto => 1
                                       ,pr_cdprogra => vr_cdprogra
                                       ,pr_cdhistor => vr_cdhistor_pf
                                       ,pr_cdhisest => vr_cdhisest
                                       ,pr_vltarifa => vr_vltarifa_pf
                                       ,pr_dtdivulg => vr_dtdivulg
                                       ,pr_dtvigenc => vr_dtvigenc
                                       ,pr_cdfvlcop => vr_cdfvlcop_pf
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic
                                       ,pr_tab_erro => vr_tab_erro);
                                                      
  --Se ocorreu erro
  IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
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
                                               || vr_dscritic || ' - FOLHACHQPF');
    -- Efetua Limpeza das variaveis de critica
    vr_cdcritic := 0;
    vr_dscritic := NULL;
  END IF;
   

  IF vr_vltarifa_pf > 0 OR
     vr_vltarifa_pj > 0 THEN
     
    vr_nrdconta := -1;
    -- Buscar Requisicoes de talonarios 
    FOR rw_crapreq IN cr_crapreq(pr_cdcooper => pr_cdcooper,
                                 pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
     
      vr_qtfolcob := 0;
      -- incrementar valor do folha mês pois informação é atualizada na crapass
      IF vr_nrdconta <> rw_crapreq.nrdconta THEN
        vr_qtfolmes := rw_crapreq.qtfolmes;
        vr_nrdconta := rw_crapreq.nrdconta;
      END IF;
       
      -- Caso rw_crapreq.inpessoa for igual a 0 significa que não
      -- encontrou nem um associado com o valor de rw_crapreq.nrdconta
      -- Neste caso iremos logar critica 9 e pular para o proximo registro
      IF rw_crapreq.inpessoa = 0 THEN
        vr_cdcritic:= 9; 
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic)||
                      gene0002.fn_mask(rw_crapreq.nrdconta,'zzzz.zzz.9');
                  
        -- Gera Log
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro Tratado
                                   pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                      ' -' || vr_cdprogra || ' --> '  ||
                                                      vr_dscritic);
                  
        -- Efetua Limpeza das variaveis de critica
        vr_cdcritic := 0;
        vr_dscritic := NULL;
                                                              
        -- Proximo Registro
        CONTINUE;              
      END IF;
      
      vr_qtretfol := (to_number(SUBSTR(gene0002.fn_mask(rw_crapreq.nrfinchq,'99999999'),1,7))
                      - to_number(SUBSTR(gene0002.fn_mask(rw_crapreq.nrinichq,'99999999'),1,7))) + 1;
          
      IF rw_crapreq.inpessoa = 1 THEN
        -- Pessoa Fisica
        vr_qtisenta := vr_qtisenta_pf;
      ELSE
        -- Pessoa Juridica
        vr_qtisenta := vr_qtisenta_pj;
      END IF;
      
		  /* Efetua verificacao para cobrancas de tarifas sobre operacoes */
		  TARI0001.pc_verifica_tarifa_operacao(pr_cdcooper => pr_cdcooper              --> Codigo da Cooperativa
																					,pr_cdoperad => '1'                      --> Codigo Operador
																					,pr_cdagenci => 1                        --> Codigo Agencia
																					,pr_cdbccxlt => 100                      --> Codigo banco caixa
																					,pr_dtmvtolt => rw_crapdat.dtmvtolt      --> Data Lancamento
																					,pr_cdprogra => 'CUST0001'               --> Nome do Programa que chama a rotina
																					,pr_idorigem => 7                        --> Identificador Origem(1-AYLLOS,2-CAIXA,3-INTERNET,4-TAA,5-AYLLOS WEB,6-URA)
																					,pr_nrdconta => rw_crapreq.nrdconta      --> Numero da Conta
																					,pr_tipotari => 5                        --> Tipo de Tarifa(1-Saque,2-Consulta)
																					,pr_tipostaa => 0                        --> Tipo de TAA que foi efetuado a operacao(1-BB, 2-Banco 24h, 3-Banco 24h compartilhado, 4-Rede Cirrus)
																					,pr_qtoperac => vr_qtretfol              --> Quantidade de registros da operação (Custódia, contra-ordem, folhas de cheque)
																					,pr_qtacobra => vr_qtacobra              --> Quantidade de registros a cobrar tarifa na operação
																					,pr_fliseope => vr_fliseope              --> Flag indica se ira isentar tarifa:0-Não isenta,1-Isenta
																					,pr_cdcritic => vr_cdcritic              --> Codigo da critica
																					,pr_dscritic => vr_dscritic);            --> Descricao da critica
																										 
			-- Se ocorreu erro
			IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN

          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '||
                                                        gene0002.fn_mask_conta(rw_crapreq.nrdconta)||'- '
                                                     || vr_dscritic );
          -- Limpa valores das variaveis de critica
          vr_cdcritic:= 0;
          vr_dscritic:= NULL;  
          
          -- Proximo Registro
          CONTINUE;         

			END IF;

			IF vr_fliseope <> 1 AND vr_qtacobra > 0 THEN
      -- Calcula Quantidade de Folhas a Serem Cobradas
				IF (vr_qtfolmes + vr_qtacobra) > vr_qtisenta THEN
	        
					IF  vr_qtfolmes >= vr_qtisenta THEN
						vr_qtfolcob := vr_qtacobra;
					ELSE
						vr_qtfolcob := vr_qtacobra - (vr_qtisenta - vr_qtfolmes); 
					END IF;    
	                                              
				END IF;
			ELSE
				IF vr_fliseope <> 1 THEN
					-- Calcula Quantidade de Folhas a Serem Cobradas
      IF (vr_qtfolmes + vr_qtretfol) > vr_qtisenta THEN
        
        IF  vr_qtfolmes >= vr_qtisenta THEN
          vr_qtfolcob := vr_qtretfol;
        ELSE
          vr_qtfolcob := vr_qtretfol - (vr_qtisenta - vr_qtfolmes); 
        END IF;    
                                              
      END IF;
				END IF;
		  END IF;
      
      --Atualizar Tabela de Associados
      BEGIN
				IF vr_fliseope <> 1 AND vr_qtacobra > 0 THEN
					UPDATE crapass SET crapass.qtfolmes = crapass.qtfolmes + vr_qtacobra
					WHERE crapass.ROWID = rw_crapreq.rowid_ass
					-- retornar valores para variavel pois não será lido novamente para a mesma conta
					RETURNING crapass.qtfolmes INTO vr_qtfolmes;
				ELSIF vr_fliseope <> 1 THEN
        UPDATE crapass SET crapass.qtfolmes = crapass.qtfolmes + vr_qtretfol
        WHERE crapass.ROWID = rw_crapreq.rowid_ass
        -- retornar valores para variavel pois não será lido novamente para a mesma conta
        RETURNING crapass.qtfolmes INTO vr_qtfolmes;
				END IF;
        
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar tabela crapass. Nao efetuado cobranca Tarifa ' || SQLERRM;
          
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '||
                                                        gene0002.fn_mask_conta(rw_crapreq.nrdconta)||'- '
                                                     || vr_dscritic );
          -- Limpa valores das variaveis de critica
          vr_cdcritic:= 0;
          vr_dscritic:= NULL;  
          
          -- Proximo Registro
          CONTINUE;
         
      END;
      
      -- Efetua lançamento de Tarifas caso tenha Valor a Cobrar
      IF rw_crapreq.inpessoa <> 3 AND vr_qtfolcob > 0 THEN
        
        -- Verifica se Conta Migrada
        OPEN cr_craptco(pr_cdcooper => rw_crapreq.cdcooper,
                        pr_nrdconta => rw_crapreq.nrdconta);
        FETCH cr_craptco INTO rw_craptco;            

        IF cr_craptco%FOUND THEN
          vr_migrado := TRUE;
        ELSE
          vr_migrado := FALSE;
        END IF;
        
        -- Fecha Cursor
        CLOSE cr_craptco;
      
        -- Conta não Migrada
        IF vr_migrado = FALSE THEN
          
          IF rw_crapreq.inpessoa = 1 THEN 
            -- Pessoa Fisica
            vr_cdhistor := vr_cdhistor_pf;
            vr_vltarifa := vr_qtfolcob * vr_vltarifa_pf;
            vr_cdfvlcop := vr_cdfvlcop_pf;
          ELSE
            -- Pessoa Juridica
            vr_cdhistor := vr_cdhistor_pj;
            vr_vltarifa := vr_qtfolcob * vr_vltarifa_pj;
            vr_cdfvlcop := vr_cdfvlcop_pj;
          END IF;   
          
          -- Criar Lançamento automatico Tarifas
          TARI0001.pc_cria_lan_auto_tarifa( pr_cdcooper     => pr_cdcooper
                                          , pr_nrdconta     => rw_crapreq.nrdconta
                                          , pr_dtmvtolt     => rw_crapdat.dtmvtolt
                                          , pr_cdhistor     => vr_cdhistor
                                          , pr_vllanaut     => vr_vltarifa
                                          , pr_cdoperad     => '1'
                                          , pr_cdagenci     => 1
                                          , pr_cdbccxlt     => 100
                                          , pr_nrdolote     => 10023
                                          , pr_tpdolote     => 1
                                          , pr_nrdocmto     => 0
                                          , pr_nrdctabb     => rw_crapreq.nrdconta
                                          , pr_nrdctitg     => gene0002.fn_mask(rw_crapreq.nrdconta,'99999999')
                                          , pr_cdpesqbb     => 'Fato gerador tarifa:' || TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY') --Codigo pesquisa
                                          , pr_cdbanchq     => 0
                                          , pr_cdagechq     => 0
                                          , pr_nrctachq     => 0
                                          , pr_flgaviso     => TRUE
                                          , pr_tpdaviso     => 2
                                          , pr_cdfvlcop     => vr_cdfvlcop
                                          , pr_inproces     => rw_crapdat.inproces
                                          , pr_rowid_craplat=> vr_rowid
                                          , pr_tab_erro     => vr_tab_erro
                                          , pr_cdcritic     => vr_cdcritic
                                          , pr_dscritic     => vr_dscritic);
          -- Se ocorreu erro
          IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            -- Se possui erro no vetor
            IF vr_tab_erro.Count > 0 THEN
              vr_cdcritic:= vr_tab_erro(1).cdcritic;
              vr_dscritic:= vr_tab_erro(1).dscritic;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro no lancamento Tarifa';
            END IF;
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '||
                                                          gene0002.fn_mask_conta(rw_crapreq.nrdconta)||'- '
                                                       || vr_dscritic );
            -- Limpa valores das variaveis de critica
            vr_cdcritic:= 0;
            vr_dscritic:= NULL;                                           
          END IF;
        
        ELSE
          
          -- Caso rw_craptco.inpessoa for igual a 0 significa que não
          -- encontrou nem um associado com o valor de rw_craptco.nrdconta
          -- Neste caso iremos logar critica 9 e pular para o proximo registro
          IF rw_craptco.inpessoa = 0 THEN
            vr_cdcritic:= 9; 
            vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic)||
                          gene0002.fn_mask(rw_craptco.nrdconta,'zzzz.zzz.9');
                      
            -- Gera Log
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                       pr_ind_tipo_log => 2, -- Erro Tratado
                                       pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                          ' -' || vr_cdprogra || ' --> '  ||
                                                          vr_dscritic);
                      
            -- Efetua Limpeza das variaveis de critica
            vr_cdcritic := 0;
            vr_dscritic := NULL;
                                                                  
            -- Proximo Registro
            CONTINUE;              
          END IF;
          
          IF rw_craptco.inpessoa = 1 THEN 
            -- Pessoa Fisica
            vr_cdhistor := vr_cdhistor_pf;
            vr_vltarifa := vr_qtfolcob * vr_vltarifa_pf;
            vr_cdfvlcop := vr_cdfvlcop_pf;
          ELSE
            -- Pessoa Juridica
            vr_cdhistor := vr_cdhistor_pj;
            vr_vltarifa := vr_qtfolcob * vr_vltarifa_pj;
            vr_cdfvlcop := vr_cdfvlcop_pj;
          END IF;   
                    
          -- Criar Lançamento automatico Tarifas
          TARI0001.pc_cria_lan_auto_tarifa( pr_cdcooper     => rw_craptco.cdcooper
                                          , pr_nrdconta     => rw_craptco.nrdconta
                                          , pr_dtmvtolt     => rw_crapdat.dtmvtolt
                                          , pr_cdhistor     => vr_cdhistor
                                          , pr_vllanaut     => vr_vltarifa
                                          , pr_cdoperad     => '1'
                                          , pr_cdagenci     => 1
                                          , pr_cdbccxlt     => 100
                                          , pr_nrdolote     => 10023
                                          , pr_tpdolote     => 1
                                          , pr_nrdocmto     => 0
                                          , pr_nrdctabb     => rw_craptco.nrdconta
                                          , pr_nrdctitg     => gene0002.fn_mask(rw_craptco.nrdconta,'99999999')
                                          , pr_cdpesqbb     => 'Fato gerador tarifa:' || TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY') --Codigo pesquisa
                                          , pr_cdbanchq     => 0
                                          , pr_cdagechq     => 0
                                          , pr_nrctachq     => 0
                                          , pr_flgaviso     => TRUE
                                          , pr_tpdaviso     => 2
                                          , pr_cdfvlcop     => vr_cdfvlcop
                                          , pr_inproces     => rw_crapdat.inproces
                                          , pr_rowid_craplat=> vr_rowid
                                          , pr_tab_erro     => vr_tab_erro
                                          , pr_cdcritic     => vr_cdcritic
                                          , pr_dscritic     => vr_dscritic);
          -- Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
            -- Se possui erro no vetor
            IF vr_tab_erro.Count > 0 THEN
              vr_cdcritic:= vr_tab_erro(1).cdcritic;
              vr_dscritic:= vr_tab_erro(1).dscritic;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro no lancamento Tarifa';
            END IF;
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '||
                                                          gene0002.fn_mask_conta(rw_craptco.nrdconta)||'- '
                                                       || vr_dscritic );
            -- Limpa valores das variaveis de critica
            vr_cdcritic:= 0;
            vr_dscritic:= NULL;                                           
          END IF;
                  
        END IF;
      
      END IF;
     
    END LOOP;
         
  END IF;
  
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
END pc_crps150;
/
