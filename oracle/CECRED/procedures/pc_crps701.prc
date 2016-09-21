CREATE OR REPLACE PROCEDURE CECRED.pc_crps701 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps701 
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Lucas Reinert
       Data    : Abril/2016                     Ultima atualizacao:  / /

       Dados referentes ao programa:

       Frequencia: Mensal
       Objetivo  : Lançar/Programar todos os débitos de pagamento do pacotes de 
			             tarifas do próximo mês

       Alteracoes: 

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS701';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
			vr_exc_erro   EXCEPTION;
			vr_exc_erro2  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
			vr_tab_erro   gene0001.typ_tab_erro;
			
			-- Variáveis auxiliares
			vr_vldescon NUMBER;
			vr_vllanaut NUMBER;
			vr_vlrealiz NUMBER;
			vr_perdesin NUMBER;
			vr_perdesin_tot NUMBER;
			vr_numocorr NUMBER;
      vr_dtinicio DATE;
      vr_datfinal DATE;
			vr_rowid_craplat ROWID;
			vr_idapuraca_recip NUMBER(10);
      vr_flgatingido INTEGER;
			vr_dtfimvig DATE;

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
			
			CURSOR cr_indica_coop(pr_cdrecipr  IN tbtarif_contas_pacote.cdreciprocidade%TYPE
			                     ,pr_idindica IN tbrecip_indicador.idindicador%TYPE)IS 
			  SELECT tbrecip.perscore
				  FROM tbrecip_parame_indica_calculo tbrecip
				 WHERE tbrecip.idparame_reciproci = pr_cdrecipr
				   AND tbrecip.idindicador = pr_idindica;
			rw_indica_coop cr_indica_coop%ROWTYPE;
			
			-- Busca pacotes de tarifas ativos da cooperativa
			CURSOR cr_tarif_contas_pacote IS
			  SELECT tpac.nrdconta
				      ,tpac.cdreciprocidade
							,tpac.dtinicio_vigencia
							,tpac.perdesconto_manual
							,tpac.qtdmeses_desconto
							,tpac.nrdiadebito
							,tpct.cdtarifa_lancamento
							,tpac.cdpacote
				  FROM tbtarif_contas_pacote tpac
					    ,tbtarif_pacotes tpct
				 WHERE tpac.cdcooper = pr_cdcooper
				   AND tpac.flgsituacao = 1
					 AND tpct.cdpacote = tpac.cdpacote;
					 
			CURSOR cr_crapfvl(pr_cdtarifa IN crapfvl.cdtarifa%TYPE) IS 
				SELECT crapfco.vltarifa
              ,crapfvl.cdhistor
							,crapfco.cdfvlcop
					FROM crapfvl
							,crapfco
				 WHERE crapfco.cdcooper = pr_cdcooper 
					 AND crapfco.flgvigen = 1  /* ativa */
					 AND crapfco.cdfaixav = crapfvl.cdfaixav
					 AND crapfvl.cdtarifa = pr_cdtarifa;
			rw_crapfvl cr_crapfvl%ROWTYPE;
			
			-- Buscar desconto por indicador de reciprocidade
			CURSOR cr_reciprocidade (pr_cdrecipr  IN tbtarif_contas_pacote.cdreciprocidade%TYPE) IS 
			  SELECT tbrecip.idparame_reciproci
				      ,tbrecip.idindicador
				  FROM tbrecip_parame_indica_calculo tbrecip
				 WHERE tbrecip.idparame_reciproci = pr_cdrecipr;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
		  --Tipo de Registro para apuração de indicadores
			TYPE typ_reg_apurac_ind IS
				RECORD (indicador NUMBER --Id do indicador
							 ,vlrealizado NUMBER -- Valor realizado atingido
							 ,cdreciproci NUMBER -- Código de reciprocidade
							 ,perdesconto NUMBER); -- Percentual de desconto atingido

			--Tipo de tabela de memoria para apuração de indicadores
			TYPE typ_tab_apurac_ind IS TABLE OF typ_reg_apurac_ind INDEX BY PLS_INTEGER;
      -- Cria PLTable
      vr_tab_apurac_ind typ_tab_apurac_ind;
			-- Inidice da PLTable
			vr_ind_apurac_ind NUMBER;
      ------------------------------- VARIAVEIS -------------------------------

      --------------------------- SUBROTINAS INTERNAS --------------------------

    BEGIN

      --------------- VALIDACOES INICIAIS -----------------

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
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
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
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

      BEGIN
				
			  -- Atualiza situação dos pacotes de tarifas cancelados
				UPDATE tbtarif_contas_pacote
					 SET flgsituacao = 0
				 WHERE cdcooper = pr_cdcooper
					 AND flgsituacao = 1
					 AND dtcancelamento IS NOT NULL;
					 
			EXCEPTION
				WHEN OTHERS THEN
					vr_cdcritic := 0;
					vr_dscritic := 'Erro ao atualizar situação dos pacotes de tarifas cancelados --> ' || SQLERRM;			
					RAISE vr_exc_saida;
      END;				 
			-- Percorre pacote de tarifas ativo dos cooperados
      FOR rw_tarif_contas_pacote IN cr_tarif_contas_pacote LOOP
			  
			  -- Limpa PL/Table
			  vr_tab_apurac_ind.DELETE;
			
				-- Busca faixa de valor
				OPEN cr_crapfvl(rw_tarif_contas_pacote.cdtarifa_lancamento);
				FETCH cr_crapfvl INTO rw_crapfvl;
				
				-- Se não encontrou faixa de valor				  
				IF cr_crapfvl%NOTFOUND THEN
					-- Gera crítica
					vr_cdcritic := 0;
					vr_dscritic := 'Faixa de valor não encontrada';
					-- Fecha cursor
					CLOSE cr_crapfvl;
					-- Levanta exceção
					RAISE vr_exc_saida;
				END IF;
					
				-- Fecha cursor
				CLOSE cr_crapfvl;

        -- Data final da vigencia é a data de inicio mais a quantidade de meses de desconto menos 1 dia
        vr_dtfimvig := (add_months(rw_tarif_contas_pacote.dtinicio_vigencia, nvl(rw_tarif_contas_pacote.qtdmeses_desconto,0)) - 1);
        -- Busca a data útil anterior do fim da vigência				
        gene0005.pc_valida_dia_util(pr_cdcooper => pr_cdcooper
																	 ,pr_dtmvtolt => vr_dtfimvig
																	 ,pr_tipo => 'A');
			
			  -- Verifica se não está no final da vigencia do pacote
			  IF (vr_dtfimvig >= rw_crapdat.dtmvtolt) THEN       
				  -- Valor do desconto é o valor de desconto do pacote vezes o valor da tarifa
					vr_vldescon := (nvl(rw_tarif_contas_pacote.perdesconto_manual,0)/100) * rw_crapfvl.vltarifa;
				ELSE
					-- Zerar valor de desconto
					vr_vldescon := 0;
				END IF;
				-- Zera percentual de desconto total de reciprocidade
				vr_perdesin_tot := 0;
				
				-- Se pacote possui reciprocidade
				IF rw_tarif_contas_pacote.cdreciprocidade > 0 THEN
          
				  -- Busca todos os indicadores de reciprocidade do pacote
				  FOR rw_reciprocidade IN cr_reciprocidade(rw_tarif_contas_pacote.cdreciprocidade) LOOP
				
				    -- Tratar indicadores de reciprocidade utilizados no pacote de tarifas
            IF rw_reciprocidade.idindicador = 4 THEN
								vr_dtinicio := add_months(trunc(rw_crapdat.dtmvtolt, 'MM'), -2);
								vr_datfinal := rw_crapdat.dtmvtolt;
								vr_numocorr := 0;
						ELSE 
								vr_dtinicio := trunc(rw_crapdat.dtmvtolt, 'MM');
								vr_datfinal := rw_crapdat.dtmvtolt;
								vr_numocorr := 0;
						END IF;															
						
						-- Calcular o valor realizado do indicador no período solicitado
						vr_vlrealiz := RCIP0001.fn_valor_realizado_indicador(pr_cdcooper    => pr_cdcooper
																																,pr_nrdconta    => rw_tarif_contas_pacote.nrdconta
																																,pr_idindicador => rw_reciprocidade.idindicador
																																,pr_numocorre   => vr_numocorr
																																,pr_datinicio   => vr_dtinicio
																																,pr_datfinal    => vr_datfinal);
																								 
						-- Calcular o valor de desconto conforme previstoXrealizado.
						vr_perdesin := nvl(RCIP0001.fn_percentu_desconto_indicador(pr_idparame    => rw_reciprocidade.idparame_reciproci
																																  ,pr_idindicador => rw_reciprocidade.idindicador
																																  ,pr_vlrbase     => vr_vlrealiz), 0);
						
						-- Adicionar desconto de reciprocidade de cada indicador
            vr_vldescon := vr_vldescon + (rw_crapfvl.vltarifa * (vr_perdesin/100));
						
						-- Soma dos percentuais de desconto de reciprocidade
						vr_perdesin_tot := nvl(vr_perdesin_tot,0) + vr_perdesin;
						
						-- Atribui indice
						vr_ind_apurac_ind := vr_tab_apurac_ind.COUNT;
						
						-- PLTable para armazenar os dados do indicador
						vr_tab_apurac_ind(vr_ind_apurac_ind).indicador := rw_reciprocidade.idindicador;
						vr_tab_apurac_ind(vr_ind_apurac_ind).vlrealizado := vr_vlrealiz;
						vr_tab_apurac_ind(vr_ind_apurac_ind).perdesconto := vr_perdesin;
						vr_tab_apurac_ind(vr_ind_apurac_ind).cdreciproci := rw_reciprocidade.idparame_reciproci;
																															 
				  END LOOP;
					
					-- Se o valor total de desconto for maior que o valor da tarifa
					IF (vr_vldescon > rw_crapfvl.vltarifa) THEN
						-- Valor de desconto é o valor da tarifa
						vr_vldescon := rw_crapfvl.vltarifa;
						-- Percentual de desconto total é de 100%
						vr_perdesin_tot := 100;
					END IF;
					
					BEGIN 
						-- Registrar período de apuração de reciprocidade
						INSERT INTO tbrecip_apuracao (cdcooper, 
																					nrdconta, 
																					cdproduto, 
																					cdchave_produto, 
																					tpreciproci, 
																					idconfig_recipro, 
																					dtinicio_apuracao, 
																					dttermino_apuracao, 
																					indsituacao_apuracao, 
																					perrecipro_atingida)
																	 VALUES(pr_cdcooper,
																					rw_tarif_contas_pacote.nrdconta,
																					26, -- Pacote de tarifas
																					rw_tarif_contas_pacote.cdpacote,
																					2, -- Faixa estipulada
																					rw_tarif_contas_pacote.cdreciprocidade,
																					trunc(rw_crapdat.dtmvtolt, 'MM'),
																					rw_crapdat.dtmvtolt,
																					'E',
																					vr_perdesin_tot)
																	RETURNING tbrecip_apuracao.idapuracao_reciproci INTO vr_idapuraca_recip;

            -- Percorre indicadores de reciprocidade para a apuração
						FOR vr_ind IN vr_tab_apurac_ind.first..vr_tab_apurac_ind.last LOOP						
							-- Se possui algum registro na PLTable
							IF vr_tab_apurac_ind.COUNT > 0 THEN
								BEGIN
								  -- Procura Percentual de Score
								  OPEN cr_indica_coop(vr_tab_apurac_ind(vr_ind).cdreciproci
									                   ,vr_tab_apurac_ind(vr_ind).indicador);
									FETCH cr_indica_coop INTO rw_indica_coop;
									
									-- Não encontrou
									IF cr_indica_coop%NOTFOUND THEN
									  -- Fecha cursor
								    CLOSE cr_indica_coop;
										-- Se não encontrou busca próximo indicador
									   continue;
									END IF;
								  -- Fecha cursor
								  CLOSE cr_indica_coop;
									
									-- Se o percentual atingido for maior ou igual ao percentual de score do indicador
									IF vr_tab_apurac_ind(vr_ind).perdesconto >= rw_indica_coop.perscore THEN
										-- Atingido
										vr_flgatingido := 1;
									ELSE
										-- Não atingido
										vr_flgatingido := 0;										
									END IF;
									
									-- Insere registro de apuração de indicador
									INSERT INTO tbrecip_apuracao_indica(idapuracao_reciproci, 
																											idindicador, 
																											vlrealizado, 
																											perdesconto,
																											flgatingido)
																							VALUES(vr_idapuraca_recip,
																										 vr_tab_apurac_ind(vr_ind).indicador,
																										 vr_tab_apurac_ind(vr_ind).vlrealizado,
																										 vr_tab_apurac_ind(vr_ind).perdesconto,
																										 vr_flgatingido);
																										 
								EXCEPTION
									WHEN vr_exc_erro2 THEN
										-- Levanta exceção
										RAISE vr_exc_erro;
									WHEN OTHERS THEN
										-- Gera crítica
										vr_cdcritic := 0;																					
										vr_dscritic := 'Erro ao registrar período de apuracao do indicador de reciprocidade: ' || SQLERRM;
										-- Levanta exceção
										RAISE vr_exc_erro;
								END;
							END IF;
						END LOOP;
																					
						-- Insere registro de apuração de tarifa
						INSERT INTO tbrecip_apuracao_tarifa(cdcooper, 
																								nrdconta, 
																								cdproduto, 
																								cdchave_produto, 
																								dtocorre, 
																								cdtarifa, 
																								vlocorrencia, 
																								vltarifa_original, 
																								perdesconto, 
																								vltarifa_cobrado)
																				 VALUES(pr_cdcooper,
																								rw_tarif_contas_pacote.nrdconta,
																								26,
																								rw_tarif_contas_pacote.cdpacote,
																								rw_crapdat.dtmvtolt,
																								rw_tarif_contas_pacote.cdtarifa_lancamento,
																								0,
																								rw_crapfvl.vltarifa,
																								vr_perdesin_tot,
																								rw_crapfvl.vltarifa - vr_vldescon);
						
					EXCEPTION
						WHEN vr_exc_erro THEN
							RAISE vr_exc_saida;
						WHEN OTHERS THEN
							-- Gera crítica
							vr_cdcritic := 0;																					
							vr_dscritic := 'Erro ao registrar período de apuracao de reciprocidade/tarifa: ' || SQLERRM;
							-- Levanta exceção
							RAISE vr_exc_saida;
					END;
				END IF;
			
			  -- Valor final a ser debitado da conta do cooperado
			  vr_vllanaut := rw_crapfvl.vltarifa - nvl(vr_vldescon,0);
				
				-- Cria lançamento automatico
        TARI0001.pc_cria_lan_auto_tarifa(pr_cdcooper => pr_cdcooper
				                                ,pr_nrdconta => rw_tarif_contas_pacote.nrdconta
																				,pr_dtmvtolt => ((TRUNC(rw_crapdat.dtmvtopr, 'MM') + rw_tarif_contas_pacote.nrdiadebito) - 1)
																				,pr_cdhistor => rw_crapfvl.cdhistor
																				,pr_vllanaut => vr_vllanaut
																				,pr_cdoperad => 1
																				,pr_cdagenci => 1
																				,pr_cdbccxlt => 100
																				,pr_nrdolote => '10139'
																				,pr_tpdolote => 1
																				,pr_nrdocmto => 0
																				,pr_nrdctabb => rw_tarif_contas_pacote.nrdconta
																				,pr_nrdctitg => 0
																				,pr_cdpesqbb => 'Fato gerador tarifa: ' || TO_CHAR(rw_crapdat.dtmvtolt,'MMYY')
																				,pr_cdbanchq => 0
																				,pr_cdagechq => 0
																				,pr_nrctachq => 0
																				,pr_flgaviso => FALSE
																				,pr_tpdaviso => 0
																				,pr_cdfvlcop => rw_crapfvl.cdfvlcop
																				,pr_inproces => rw_crapdat.inproces
																				,pr_rowid_craplat => vr_rowid_craplat
																				,pr_tab_erro => vr_tab_erro
																				,pr_cdcritic => vr_cdcritic 
																				,pr_dscritic => vr_dscritic);
			END LOOP;

      ----------------- ENCERRAMENTO DO PROGRAMA -------------------

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informações atualizadas
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit
        COMMIT;
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps701;
/
