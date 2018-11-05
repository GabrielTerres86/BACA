CREATE OR REPLACE PROCEDURE CECRED.pc_crps136 (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Coop conectada
                                              ,pr_flgresta IN PLS_INTEGER            --> Indicador para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
  /* ............................................................................
   Programa: PC_CRPS136 (Antigo Fontes/crps136.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Outubro/95.                     Ultima atualizacao: 26/10/2018

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Gerar lancamento de cobranca de taxa de cadastramento de contra
               ordem.

   Alteracoes: 27/08/97 - Alterado para incluir o campo flgproce na criacao
                          do crapavs (Deborah).

               11/12/98 - Alterado para permitir cobranca diferenciada para
                          cheques em branco (hist 825). (Deborah).

               18/12/98 - Tratar historico 835 da mesma forma que o 825
                          (Deborah).

               29/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm e crapavs (Diego).

               10/11/2005 - Tratar campo cdcooper na leitura da tabela
                            crapcor (Edson).
                            
               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
                            
               30/01/2007 - Ler crapcor por dtmvtolt e nao dtemscor (Magui).
               
               21/07/2008 - Inclusao do cdcooper no FIND craphis (Julio)
               
               08/12/2009 - Retiradas variaveis que nao estao sendo utilizadas:
                            res_nrdctabb, res_nrdocmto, res_cdhistor (Diego).
                            
               09/06/2011 - Nao tarifar histório 818 (Diego). 
               
               12/12/2011 - Sustação provisória (André R./Supero).
               
               09/05/2012 - Ajuste na cobranca de tarifas - Sustacao Prov. (Ze).
               
               09/01/2013 - Tratamento para contas migradas 
                            Viacredi -> AltoVale. (Fabricio)
                            
               08/05/2013 - Incluir ajustes referentes ao Projeto de Tarifas
                            Fase 2 (Lucas R.)
                            
               11/10/2013 - Incluido parametro cdprogra nas procedures da 
                            b1wgen0153 que carregam dados de tarifas (Tiago).
  
               16/03/2015 - Conversão Progress >> Oracle PL-Sql (Daniel)
               
               25/08/2015 - Inclusao do parametro pr_cdpesqbb na procedure
                            tari0001.pc_cria_lan_auto_tarifa, projeto de 
                            Tarifas-218(Jean Michel)
														
               25/04/2016 - Incluido chamada à procedure TARI0001.pc_verifica_tarifa_operacao,
							              alteração feita para o Projeto de Tarifas - 218 fase 2 
                            (Reinert).														
                            
               26/10/0218 - Incluido validação para não cobrar cheques de contra ordem definitiva 
                            caso já tenha sido cobrado a provisoria. (Anderson-Alan, Supero)
                            
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
       
 -- Busca contagem de tarifas das ordens definitivas
  CURSOR cr_crapcor_tar(pr_cdcooper IN crapcor.cdcooper%TYPE,
                        pr_nrdconta IN crapcor.nrdconta%TYPE,
                        pr_nrcheque IN crapcor.nrcheque%TYPE) IS
    SELECT COUNT(1) AS QTDTARIFADOS
      FROM crapcor cor
     WHERE cor.cdcooper = pr_cdcooper
       AND cor.nrdconta = pr_nrdconta
       AND cor.nrcheque = nrcheque
       AND cor.cdlantar > 0
       AND cor.cdhistor NOT IN (816,818,817,825,835);
  
  -- Cursor Cadastro de Contra-Ordens
  CURSOR cr_crapcor(pr_cdcooper IN crapcor.cdcooper%TYPE,
                    pr_dtmvtolt IN crapcor.dtmvtolt%TYPE) IS
    SELECT cor.cdcooper 
          ,cor.nrdconta  
          ,cor.dtvalcor
          ,cor.nrcheque
          ,cor.dtmvtolt
          ,cor.progress_recid
          ,his.tplotmov tplotmov
          ,NVL(his.cdhistor,0) cdhistor
          ,ROW_NUMBER () OVER (PARTITION BY cor.nrdconta ORDER BY cor.nrdconta) nrseq
          ,COUNT(1) OVER (PARTITION BY cor.nrdconta ORDER BY cor.nrdconta) qtreg 
      FROM crapcor cor
          ,craphis his
     WHERE cor.cdcooper = pr_cdcooper
       AND cor.dtmvtolt = pr_dtmvtolt
       AND cor.cdhistor NOT IN (816,818,817,825,835)          
       AND his.cdcooper (+) = cor.cdcooper
       AND his.cdhistor (+) = cor.cdhistor
  ORDER BY -- Ordenacao essencial para garantir o retorno dos cheques Provisorios seguidas de seus Permanentes.
           cor.nrdconta,
           cor.nrcheque,
           cor.dtvalcor,
           cor.dtmvtolt;
       -- 816 - CANCELADO - NAO ENTREGUE
       -- 817 - PERDA/EXTRAVIO - CHEQUE PREENCHIDO
       -- 818 - FURTO/ROUBO C/ BO - CHEQUE PREENCHIDO
       -- 825 - PERDA/EXTRAVIO - CHEQUE EM BRANCO
       -- 835 - FURTO/ROUBO C/ BO - CHEQUE EM BRANCO

  -- Cursor Leitura Associado
  CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                     pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT crapass.inpessoa,
           crapass.nrdconta,
           crapass.cdcooper,
           crapass.nrdctitg
      FROM crapass
     WHERE crapass.cdcooper = pr_cdcooper
       AND crapass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;     
  
  -- Cursor para Verificar se Conta Migrada
  CURSOR cr_craptco(pr_cdcooper IN craptco.cdcooper%TYPE,
                    pr_nrdconta IN craptco.nrctaant%TYPE) IS
    SELECT tco.nrdconta
          ,tco.cdcooper
          ,NVL(ass.inpessoa,0) inpessoa
          ,NVL(ass.nrdctitg,0) nrdctitg
     FROM craptco tco
         ,crapass ass
    WHERE tco.cdcopant = pr_cdcooper
      AND tco.nrctaant = pr_nrdconta            
      AND tco.flgativo = 1 -- TRUE
      AND tco.tpctatrf = 1
      AND ass.cdcooper (+) = tco.cdcooper
      AND ass.nrdconta (+) = tco.nrdconta;
  rw_craptco cr_craptco%ROWTYPE; 
  
  -- Cursor Leitura tarifas provisorias
  CURSOR cr_craplat (pr_rowid IN ROWID) IS
    SELECT lat.cdlantar
      FROM craplat lat
      WHERE lat.rowid = pr_rowid;

  -------------------------------------------------------------------------
  TYPE typ_tab_cor_cheque_provi IS TABLE OF NUMBER(23) INDEX BY BINARY_INTEGER;
  
  TYPE typ_reg_cor IS RECORD(
      vr_tab_cor_cheque typ_tab_cor_cheque_provi,
      vr_progress_re  NUMBER
  );
  
  TYPE typ_tab_contra_ordem IS TABLE OF typ_reg_cor INDEX BY VARCHAR2(20);
  
  vr_tab_cor_prov typ_tab_contra_ordem;
  vr_tab_cor_defin typ_tab_contra_ordem;
  vr_tab_cor_def_inpro typ_tab_contra_ordem;
  vr_index_crapcor VARCHAR(20);
  vr_crapcor_nrcheque_id NUMBER(10);
  
  ------------------------------- VARIAVEIS -------------------------------
  -- Código do programa
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS136';

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic PLS_INTEGER;
  vr_dscritic VARCHAR2(4000);
  
  -- Tabela Temporaria
  vr_tab_erro GENE0001.typ_tab_erro;
  
  -- Rowid de retorno lançamento de tarifa
  vr_rowid    ROWID;
  
  -- Indicativo de Conta Migrada
  vr_migrado BOOLEAN := FALSE;
  
  vr_cdcooper crapcor.cdcooper%TYPE;
  vr_nrdconta crapcor.nrdconta%TYPE;
  vr_nrdctitg crapass.nrdctitg%TYPE;
 
  -- Variaveis de tarifa
  vr_cdhistor craphis.cdhistor%TYPE;
  vr_cdhisest craphis.cdhistor%TYPE;
  vr_dtdivulg DATE;
  vr_dtvigenc DATE;
  vr_cdfvlcop crapfco.cdfvlcop%TYPE;
  vr_vltarifa crapfco.vltarifa%TYPE;
  vr_cnt_cor_lantar craplat.cdlantar%TYPE;
  vr_cdlantar craplat.cdlantar%TYPE;
  
  -- Valores Tarifa
  vr_cdbattar VARCHAR2(10);
  vr_vlcobper NUMBER := 0;
  vr_vlcobpro NUMBER := 0;
   
  -- Listas utilizadas para carga de tarifas
  vr_lstarifa VARCHAR2(2000);
  
  vr_qtemiper NUMBER := 0;
  vr_qtemipro NUMBER := 0;
  vr_qtemiper_inpro NUMBER := 0;
  
  vr_ctordpro VARCHAR2(10);
  vr_ctordper VARCHAR2(10);

  -- Variáveis utilizadas para verificar operações de tarifas	
	vr_qtacobra INTEGER;
  vr_fliseope INTEGER;
  
  -- Tabela temporaria para as tarifas
  TYPE typ_reg_tarifa IS
   RECORD(cdhistor crapfvl.cdhistor%TYPE
         ,cdfvlcop crapfvl.cdfaixav%TYPE
         ,vltarifa crapfco.vltarifa%TYPE);
  TYPE typ_tab_tarifa IS
    TABLE OF typ_reg_tarifa
      INDEX BY VARCHAR2(10);
      
  -- Vetor para armazenar os percentuais de risco
  vr_tab_tarifa typ_tab_tarifa;
  
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
  
  -- Processo de carga tarifas para Pl/Table
  vr_lstarifa := 'CONTRORDPJ;' || -- Contra Ordem (Ou Revogação) e Oposição (Ou Sustação) ao Pagamento de Cheque PJ - Permanente
                 'CONTRORDPF;' || -- Contra Ordem (Ou Revogação) e Oposição (Ou Sustação) ao Pagamento de Cheque PF - Permanente 
                 'CORDPROVPJ;' || -- Contra Ordem (Ou Revogação) e Oposição (Ou Sustação) ao Pagamento de Cheque PJ - Provisoria
                 'CORDPROVPF';    -- Contra Ordem (Ou Revogação) e Oposição (Ou Sustação) ao Pagamento de Cheque PF - Provisoria
                 
  -- Popula a PL/TABLE de tarifas
  FOR ind IN 1..4 LOOP
     
    -- Inicializa as variaveis
    vr_cdhistor := 0;      
    vr_cdfvlcop := 0;
    vr_vltarifa := 0;
         
    -- Codigo da Tarifa
    vr_cdbattar := gene0002.fn_busca_entrada(ind,vr_lstarifa,';');
         
    -- Busca valor da tarifa
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
    IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
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
    vr_tab_tarifa(vr_cdbattar).cdhistor := NVl(vr_cdhistor,0);
    vr_tab_tarifa(vr_cdbattar).cdfvlcop := NVL(vr_cdfvlcop,0);
    vr_tab_tarifa(vr_cdbattar).vltarifa := NVL(vr_vltarifa,0);
     
  END LOOP;

  -- Leitura 
  FOR rw_crapcor IN cr_crapcor(pr_cdcooper => pr_cdcooper,
                               pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
                            
    -- Inicializa as Variaveis   
    IF rw_crapcor.nrseq = 1 THEN
      vr_qtemiper := 0;
      vr_qtemipro := 0;
      vr_qtemiper_inpro := 0;
      vr_vlcobper := 0;
      vr_vlcobpro := 0;
    END IF;                           

    IF rw_crapcor.cdhistor = 0 THEN
      vr_cdcritic:= 83; -- 083 - Historico desconhecido no lancamento.
      vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic)||
                    gene0002.fn_mask(rw_crapcor.nrdconta,'zzzz.zzz.9');
        
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
                               
    IF rw_crapcor.tplotmov <> 9 THEN
      CONTINUE;
    END IF;
    
    -- Cria o indice para collection
    vr_index_crapcor := LPAD(rw_crapcor.cdcooper , 10, '0' ) ||  LPAD(rw_crapcor.nrdconta, 10,'0');
     
    -- Verifica se é provisoria ou permanente
    IF rw_crapcor.dtvalcor IS NOT NULL THEN
      
      -- Validacao para garantir definicao da collection.
      IF NOT vr_tab_cor_prov.EXISTS(vr_index_crapcor) OR NOT vr_tab_cor_prov(vr_index_crapcor).vr_tab_cor_cheque.EXISTS(rw_crapcor.nrcheque) THEN
          
          -- Contador de Ordens Provisorias
      vr_qtemipro := vr_qtemipro + 1;
          
          -- Seta o progress_recid para atualizar a culona cdlantar do registro na crapcor.
          vr_tab_cor_prov(vr_index_crapcor).vr_tab_cor_cheque(rw_crapcor.nrcheque) := rw_crapcor.progress_recid;
          
      END IF;
      
    ELSE 
      -- Busca cdlantar da tabela crapcor
      OPEN cr_crapcor_tar(pr_cdcooper => rw_crapcor.cdcooper,
                          pr_nrdconta => rw_crapcor.nrdconta,
                          pr_nrcheque => rw_crapcor.nrcheque);
      FETCH cr_crapcor_tar INTO vr_cnt_cor_lantar;
      CLOSE cr_crapcor_tar;
      
      -- Verifica se nao existe codigo de tarifa definido na crapcor para esse cheque
      IF vr_cnt_cor_lantar = 0 THEN
          
          -- Verifica se o registro esta na vr_tab_cor_prov
          IF vr_tab_cor_prov.EXISTS(vr_index_crapcor) AND vr_tab_cor_prov(vr_index_crapcor).vr_tab_cor_cheque.EXISTS(rw_crapcor.nrcheque) THEN
              
              -- Contador de ordens permanentes com provisorias
              vr_qtemiper_inpro := vr_qtemiper_inpro + 1;
              
              -- Validacao para garantir definicao da collection.
              IF NOT vr_tab_cor_def_inpro.EXISTS(vr_index_crapcor) OR NOT vr_tab_cor_def_inpro(vr_index_crapcor).vr_tab_cor_cheque.EXISTS(rw_crapcor.nrcheque) THEN
                
                -- Seta o progress_recid para atualizar a culona cdlantar do registro na crapcor.
                vr_tab_cor_def_inpro(vr_index_crapcor).vr_tab_cor_cheque(rw_crapcor.nrcheque) := rw_crapcor.progress_recid;
                
              END IF;
              
          ELSE
              -- Contador de ordens permanentes
      vr_qtemiper := vr_qtemiper + 1;
              
              -- Validacao para garantir definicao da collection.
              IF NOT vr_tab_cor_defin.EXISTS(vr_index_crapcor) OR NOT vr_tab_cor_defin(vr_index_crapcor).vr_tab_cor_cheque.EXISTS(rw_crapcor.nrcheque) THEN
                
                -- Seta o progress_recid para atualizar a culona cdlantar do registro na crapcor.
                vr_tab_cor_defin(vr_index_crapcor).vr_tab_cor_cheque(rw_crapcor.nrcheque) := rw_crapcor.progress_recid;
                
    END IF;  
              
          END IF;
          
      END IF;
      
    END IF;  
    
    -- Efetua lançamento quando ultimo registro da conta
    IF rw_crapcor.nrseq = rw_crapcor.qtreg THEN
      
      -- Caso não exista ocorrencia vai para proxima conta
      IF vr_qtemiper = 0 AND vr_qtemipro = 0 THEN
          CONTINUE;
      END IF;    
      
      -- Selecionar Dados Associado
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => rw_crapcor.nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- Se nao encontrou associado
      IF cr_crapass%NOTFOUND THEN
        vr_cdcritic:= 9; -- 9 - Associado nao cadastrado.
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic)||
                      gene0002.fn_mask(rw_crapcor.nrdconta,'zzzz.zzz.9');
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
      
      IF rw_crapass.inpessoa = 3 THEN 
        CONTINUE;
      END IF; 

      IF rw_crapass.inpessoa = 1 THEN 
        vr_ctordpro := 'CORDPROVPF'; -- Contra Ordem - Provisoria
        vr_ctordper := 'CONTRORDPF'; -- Contra Ordem - Permanente
      ELSE
        vr_ctordpro := 'CORDPROVPJ'; -- Contra Ordem - Provisoria
        vr_ctordper := 'CONTRORDPJ'; -- Contra Ordem - Permanente
      END IF;          
          
			-- Verifica se Conta Migrada
			OPEN cr_craptco(pr_cdcooper => rw_crapcor.cdcooper,
											pr_nrdconta => rw_crapcor.nrdconta);
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
				vr_cdcooper := rw_crapass.cdcooper;
				vr_nrdconta := rw_crapass.nrdconta;
				vr_nrdctitg := rw_crapass.nrdctitg;
			ELSE
          
				-- Tratamento Conta Migrada
        
				-- Se nao encontrou associado migrado
				IF rw_craptco.inpessoa = 0 THEN
					vr_cdcritic:= 9; -- 9 - Associado nao cadastrado. 
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
                    
					--Proximo Registro
					CONTINUE;
				END IF;
          
				-- Efetua Lançamento Com Dados da Conta Migrada
				vr_cdcooper := rw_craptco.cdcooper;
				vr_nrdconta := rw_craptco.nrdconta;
				vr_nrdctitg := rw_craptco.nrdctitg;
          
			END IF;
			
      -- Calcula Valor a Ser Tarifado Contra Ordem - Provisoria
      IF vr_qtemipro > 0 THEN
				/* Efetua verificacao para cobrancas de tarifas sobre operacoes */
				tari0001.pc_verifica_tarifa_operacao(pr_cdcooper => vr_cdcooper              --> Codigo da Cooperativa
																						,pr_cdoperad => '1'                      --> Codigo Operador
																						,pr_cdagenci => 1                        --> Codigo Agencia
																						,pr_cdbccxlt => 100                      --> Codigo banco caixa
																						,pr_dtmvtolt => rw_crapdat.dtmvtolt      --> Data Lancamento
																						,pr_cdprogra => 'CUST0001'               --> Nome do Programa que chama a rotina
																						,pr_idorigem => 7                        --> Identificador Origem(1-AYLLOS,2-CAIXA,3-INTERNET,4-TAA,5-AYLLOS WEB,6-URA)
																						,pr_nrdconta => vr_nrdconta              --> Numero da Conta
																						,pr_tipotari => 4                        --> Tipo de Tarifa(1-Saque,2-Consulta)
																						,pr_tipostaa => 0                        --> Tipo de TAA que foi efetuado a operacao(1-BB, 2-Banco 24h, 3-Banco 24h compartilhado, 4-Rede Cirrus)
																						,pr_qtoperac => vr_qtemipro              --> Quantidade de registros da operação (Custódia, contra-ordem, folhas de cheque)
																						,pr_qtacobra => vr_qtacobra              --> Quantidade de registros a cobrar tarifa na operação
																						,pr_fliseope => vr_fliseope              --> Flag indica se ira isentar tarifa:0-Não isenta,1-Isenta
																						,pr_cdcritic => vr_cdcritic              --> Codigo da critica
																						,pr_dscritic => vr_dscritic);            --> Descricao da critica
				
				-- Se ocorreu erro
				IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        
					-- Envio centralizado de log de erro
					btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
																		,pr_ind_tipo_log => 2 -- Erro tratato
																		,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
																										 || vr_cdprogra || ' --> '||
																												gene0002.fn_mask_conta(rw_crapcor.nrdconta)||'- '
																										 || vr_dscritic );
					-- Limpa valores das variaveis de critica
					vr_cdcritic:= 0;
					vr_dscritic:= NULL;                                           
					
          --Proximo Registro
          CONTINUE;
				END IF;
        
				-- Se não for isento de tarifa
                IF   vr_fliseope <> 1 THEN
                     -- Se ultrapassou o limite de operacoes permitidas no pacote    
                     IF   vr_qtacobra > 0 THEN
                          -- Atribui novo valor total a cobrar
                          vr_vlcobpro := vr_tab_tarifa(vr_ctordper).vltarifa * vr_qtacobra;
                     -- Senao, o cooperado nao possui pacote, cobra tarifa normal
                     ELSE
                          vr_vlcobpro := vr_tab_tarifa(vr_ctordpro).vltarifa * vr_qtemipro;
                          
                     END IF;
                -- Operacao isenta pelo pacote de tarifas
                ELSE
                     vr_vlcobpro := 0;
                END IF;
                
                --Caso o valor das provisorias for igual a zero, considera
               IF vr_vlcobpro = 0 THEN
                     vr_qtemiper := vr_qtemiper + vr_qtemiper_inpro;
                     
              END IF;
              
      END IF;
      
      -- Calcula Valor a Ser Tarifado Contra Ordem - Permanente
      IF vr_qtemiper > 0 THEN        
				/* Efetua verificacao para cobrancas de tarifas sobre operacoes */
				tari0001.pc_verifica_tarifa_operacao(pr_cdcooper => vr_cdcooper              --> Codigo da Cooperativa
																						,pr_cdoperad => '1'                      --> Codigo Operador
																						,pr_cdagenci => 1                        --> Codigo Agencia
																						,pr_cdbccxlt => 100                      --> Codigo banco caixa
																						,pr_dtmvtolt => rw_crapdat.dtmvtolt      --> Data Lancamento
																						,pr_cdprogra => 'CUST0001'               --> Nome do Programa que chama a rotina
																						,pr_idorigem => 7                        --> Identificador Origem(1-AYLLOS,2-CAIXA,3-INTERNET,4-TAA,5-AYLLOS WEB,6-URA)
																						,pr_nrdconta => vr_nrdconta              --> Numero da Conta
																						,pr_tipotari => 4                        --> Tipo de Tarifa(1-Saque,2-Consulta)
																						,pr_tipostaa => 0                        --> Tipo de TAA que foi efetuado a operacao(1-BB, 2-Banco 24h, 3-Banco 24h compartilhado, 4-Rede Cirrus)
																						,pr_qtoperac => vr_qtemiper              --> Quantidade de registros da operação (Custódia, contra-ordem, folhas de cheque)
																						,pr_qtacobra => vr_qtacobra              --> Quantidade de registros a cobrar tarifa na operação
																						,pr_fliseope => vr_fliseope              --> Flag indica se ira isentar tarifa:0-Não isenta,1-Isenta
																						,pr_cdcritic => vr_cdcritic              --> Codigo da critica
																						,pr_dscritic => vr_dscritic);            --> Descricao da critica

				-- Se ocorreu erro
				IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN

					-- Envio centralizado de log de erro
					btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
																		,pr_ind_tipo_log => 2 -- Erro tratato
																		,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
																										 || vr_cdprogra || ' --> '||
																												gene0002.fn_mask_conta(rw_crapcor.nrdconta)||'- '
																										 || vr_dscritic );
					-- Limpa valores das variaveis de critica
					vr_cdcritic:= 0;
					vr_dscritic:= NULL;                                           
					
          --Proximo Registro
          CONTINUE;
				END IF;

				-- Se não for isento de tarifa
                IF   vr_fliseope <> 1 THEN
                     -- Se ultrapassou o limite de operacoes permitidas no pacote    
                     IF   vr_qtacobra > 0 THEN
                         -- Atribui novo valor total a cobrar
                         vr_vlcobper := vr_tab_tarifa(vr_ctordper).vltarifa * vr_qtacobra;
                     -- Senao, o cooperado nao possui pacote, cobra tarifa normal
                     ELSE
                         vr_vlcobper := vr_tab_tarifa(vr_ctordper).vltarifa * vr_qtemiper;
                     END IF;
              
                -- Operacao isenta pelo pacote de tarifas
                ELSE
                     vr_vlcobper := 0;
                END IF;                 

      END IF;

      -- Verifica se Possui Valores a Serem Tarifados
      IF vr_vlcobper > 0 OR vr_vlcobpro > 0 THEN
        
				-- Se não isenta tarifa
				IF vr_fliseope <> 1 THEN
		
					-- Caso Valor Tenha Tarifa Contra Ordem - Provisoria
					IF vr_vlcobpro > 0 THEN
	        
						-- Criar Lançamento automatico Tarifas
						TARI0001.pc_cria_lan_auto_tarifa( pr_cdcooper     => vr_cdcooper
																						, pr_nrdconta     => vr_nrdconta
																						, pr_dtmvtolt     => rw_crapdat.dtmvtolt
																						, pr_cdhistor     => vr_tab_tarifa(vr_ctordpro).cdhistor
																						, pr_vllanaut     => vr_vlcobpro
																						, pr_cdoperad     => '1'
																						, pr_cdagenci     => 1
																						, pr_cdbccxlt     => 100
																						, pr_nrdolote     => 8452
																						, pr_tpdolote     => 1
																						, pr_nrdocmto     => 0
																						, pr_nrdctabb     => vr_nrdconta
																						, pr_nrdctitg     => vr_nrdconta
																						, pr_cdpesqbb     => 'Fato gerador tarifa:' || TO_CHAR(rw_crapcor.nrcheque)
																						, pr_cdbanchq     => 0
																						, pr_cdagechq     => 0
																						, pr_nrctachq     => 0
																						, pr_flgaviso     => TRUE
																						, pr_tpdaviso     => 2
																						, pr_cdfvlcop     => vr_tab_tarifa(vr_ctordpro).cdfvlcop
																						, pr_inproces     => rw_crapdat.inproces
																						, pr_rowid_craplat=> vr_rowid
																						, pr_tab_erro     => vr_tab_erro
																						, pr_cdcritic     => vr_cdcritic
																						, pr_dscritic     => vr_dscritic
																						);
              
              
              IF vr_tab_cor_prov.EXISTS(vr_index_crapcor) AND vr_tab_cor_prov(vr_index_crapcor).vr_tab_cor_cheque.COUNT  >  0 THEN
                
                -- Leitura do codigo cdlantar pelo rowid do insert da tarifa
                OPEN cr_craplat(pr_rowid => vr_rowid);
                FETCH cr_craplat INTO vr_cdlantar;
                -- Se não encontrar
                IF cr_craplat%NOTFOUND THEN
                  -- Fechar o cursor pois efetuaremos raise
                  CLOSE cr_craplat;
                  -- Montar mensagem de critica
                  vr_cdcritic:= 1;
                  RAISE vr_exc_saida;
							ELSE
                  -- Apenas fechar o cursor
                  CLOSE cr_craplat;
							END IF;
                
                vr_crapcor_nrcheque_id :=  vr_tab_cor_prov(vr_index_crapcor).vr_tab_cor_cheque.FIRST;
                LOOP
                  
                  UPDATE crapcor cor
                     SET cor.cdlantar = vr_cdlantar
                   WHERE cor.cdcooper = rw_crapcor.cdcooper
                     AND cor.nrdconta = rw_crapcor.nrdconta
                     AND cor.dtmvtolt = rw_crapcor.dtmvtolt
                     AND cor.progress_recid = vr_tab_cor_prov(vr_index_crapcor).vr_tab_cor_cheque(vr_crapcor_nrcheque_id);
                   
                   EXIT WHEN vr_crapcor_nrcheque_id = vr_tab_cor_prov(vr_index_crapcor).vr_tab_cor_cheque.LAST;
                   vr_crapcor_nrcheque_id :=  vr_tab_cor_prov(vr_index_crapcor).vr_tab_cor_cheque.NEXT(vr_crapcor_nrcheque_id);
                   
                 END LOOP;
                 
						END IF;
	          
						-- Se ocorreu erro
						IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
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
																														gene0002.fn_mask_conta(rw_crapcor.nrdconta)||'- '
																												 || vr_dscritic );
							-- Limpa valores das variaveis de critica
							vr_cdcritic:= 0;
							vr_dscritic:= NULL;                                           
						END IF;
	          
					END IF;
					
          -- Caso Valor Tenha Tarifa Contra Ordem - Permanente
					IF vr_vlcobper > 0 THEN
            -- Criar Lançamento automatico Tarifas
            TARI0001.pc_cria_lan_auto_tarifa( pr_cdcooper     => vr_cdcooper
                                            , pr_nrdconta     => vr_nrdconta
                                            , pr_dtmvtolt     => rw_crapdat.dtmvtolt
                                            , pr_cdhistor     => vr_tab_tarifa(vr_ctordper).cdhistor
                                         	  , pr_vllanaut     => vr_vlcobper
                                            , pr_cdoperad     => '1'
                                            , pr_cdagenci     => 1
                                            , pr_cdbccxlt     => 100
                                            , pr_nrdolote     => 8452
                                            , pr_tpdolote     => 1
                                            , pr_nrdocmto     => rw_crapcor.nrcheque
                                            , pr_nrdctabb     => vr_nrdconta
                                            , pr_nrdctitg     => vr_nrdctitg
                                            , pr_cdpesqbb     => 'Fato gerador tarifa:' || TO_CHAR(rw_crapcor.nrcheque)
                                            , pr_cdbanchq     => 0
                                            , pr_cdagechq     => 0
                                            , pr_nrctachq     => 0
                                            , pr_flgaviso     => TRUE
                                            , pr_tpdaviso     => 2
                                            , pr_cdfvlcop     => vr_tab_tarifa(vr_ctordper).cdfvlcop
                                            , pr_inproces     => rw_crapdat.inproces
                                            , pr_rowid_craplat=> vr_rowid
                                            , pr_tab_erro     => vr_tab_erro
                                            , pr_cdcritic     => vr_cdcritic
                                            , pr_dscritic     => vr_dscritic
                                            );
                                            
            
            IF vr_tab_cor_defin.EXISTS(vr_index_crapcor) AND vr_tab_cor_defin(vr_index_crapcor).vr_tab_cor_cheque.COUNT  >  0 THEN
              
              -- Leitura do codigo cdlantar pelo rowid do insert da tarifa
              OPEN cr_craplat(pr_rowid => vr_rowid);
              FETCH cr_craplat INTO vr_cdlantar;
              -- Se não encontrar
              IF cr_craplat%NOTFOUND THEN
                -- Fechar o cursor pois efetuaremos raise
                CLOSE cr_craplat;
                -- Montar mensagem de critica
                vr_cdcritic:= 1;
                RAISE vr_exc_saida;
              ELSE
                -- Apenas fechar o cursor
                CLOSE cr_craplat;
              END IF;
              
              vr_crapcor_nrcheque_id :=  vr_tab_cor_defin(vr_index_crapcor).vr_tab_cor_cheque.FIRST;
              LOOP
                
                UPDATE crapcor cor
                   SET cor.cdlantar = vr_cdlantar
                 WHERE cor.cdcooper = rw_crapcor.cdcooper
                   AND cor.nrdconta = rw_crapcor.nrdconta
                   AND cor.dtmvtolt = rw_crapcor.dtmvtolt
                   AND cor.progress_recid = vr_tab_cor_defin(vr_index_crapcor).vr_tab_cor_cheque(vr_crapcor_nrcheque_id);
                 
                 EXIT WHEN vr_crapcor_nrcheque_id = vr_tab_cor_defin(vr_index_crapcor).vr_tab_cor_cheque.LAST;
                 vr_crapcor_nrcheque_id :=  vr_tab_cor_defin(vr_index_crapcor).vr_tab_cor_cheque.NEXT(vr_crapcor_nrcheque_id);
                 
              END LOOP;
              
            END IF;
            
            IF vr_vlcobpro = 0 THEN
              IF vr_tab_cor_def_inpro.EXISTS(vr_index_crapcor) AND vr_tab_cor_def_inpro(vr_index_crapcor).vr_tab_cor_cheque.COUNT  >  0 THEN
                
                -- Leitura do codigo cdlantar pelo rowid do insert da tarifa
                OPEN cr_craplat(pr_rowid => vr_rowid);
                FETCH cr_craplat INTO vr_cdlantar;
                -- Se não encontrar
                IF cr_craplat%NOTFOUND THEN
                  -- Fechar o cursor pois efetuaremos raise
                  CLOSE cr_craplat;
                  -- Montar mensagem de critica
                  vr_cdcritic:= 1;
                  RAISE vr_exc_saida;
                ELSE
                  -- Apenas fechar o cursor
                  CLOSE cr_craplat;
                END IF;
                
                vr_crapcor_nrcheque_id :=  vr_tab_cor_def_inpro(vr_index_crapcor).vr_tab_cor_cheque.FIRST;
                LOOP
                  
                  UPDATE crapcor cor
                     SET cor.cdlantar = vr_cdlantar
                   WHERE cor.cdcooper = rw_crapcor.cdcooper
                     AND cor.nrdconta = rw_crapcor.nrdconta
                     AND cor.dtmvtolt = rw_crapcor.dtmvtolt
                     AND cor.progress_recid = vr_tab_cor_def_inpro(vr_index_crapcor).vr_tab_cor_cheque(vr_crapcor_nrcheque_id);
                   
                   EXIT WHEN vr_crapcor_nrcheque_id = vr_tab_cor_def_inpro(vr_index_crapcor).vr_tab_cor_cheque.LAST;
                   vr_crapcor_nrcheque_id :=  vr_tab_cor_def_inpro(vr_index_crapcor).vr_tab_cor_cheque.NEXT(vr_crapcor_nrcheque_id);
                   
                END LOOP;
                
              END IF;
            END IF;
            
            -- Se ocorreu erro
            IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
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
																														gene0002.fn_mask_conta(rw_crapcor.nrdconta)||'- '
																												 || vr_dscritic );
							-- Limpa valores das variaveis de critica
							vr_cdcritic:= 0;
							vr_dscritic:= NULL;                                           
						END IF;
					END IF;
					
				END IF;
                                    
      END IF;
  
    END IF; --  Fim IF rw_crapcor.nrseq = rw_crapcor.qtreg
  
  END LOOP;
     
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
END pc_crps136;
/
