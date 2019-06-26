CREATE OR REPLACE PACKAGE CECRED.CCRD0009 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CCRD0009
  --  Sistema  : Rotinas para Importacao do Arquivo de Inadimplentes (CB093)
  --  Sigla    : CCRD
  --  Autor    : Nagasava - Supero
  --  Data     : Marco/2019.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas genericas para a importacao dos dados do arquivo de inadimplentes (CB093)
  --
  -- Alteracoes: 
	--
  ---------------------------------------------------------------------------------------------------------------
  
  -- Definicao de tipo de registro
  TYPE typ_reg_crapcop IS
    RECORD (cdcooper crapcop.cdcooper%TYPE
           ,nmrescop crapcop.nmrescop%TYPE
           ,cdagebcb crapcop.cdagebcb%TYPE);
           
  TYPE typ_tab_crapcop IS TABLE OF typ_reg_crapcop INDEX BY VARCHAR2(10); 
  
	PROCEDURE pc_import_arq_inadim_job;
	
	PROCEDURE pc_insere_dados_financeiros(pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE
		                                   ,pr_dscritic OUT VARCHAR2
		                                   );
	  
END CCRD0009;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CCRD0009 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CCRD0009
  --  Sistema  : CRED
  --  Sigla    : CCRD
  --  Autor    : Nagasava - Supero
  --  Data     : Março/2019.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas genericas para a importacao/processamento do arquivo de inadimplentes (CB093).
  --
  -- Alterações: 
	--
  ---------------------------------------------------------------------------------------------------------------  
	FUNCTION fn_coop_blocked(pr_cdcooper IN crapprm.cdcooper%TYPE
		                      ) RETURN BOOLEAN IS
		--
		CURSOR cr_param IS
		  SELECT prm.dsvlrprm
				FROM crapprm prm
			 WHERE prm.nmsistem = 'CRED'
				 AND prm.cdcooper = 0
				 AND prm.cdacesso = 'BLQ_COOP_CCRD_BANCOOB';
		--
		vr_dsvlrprm crapprm.dsvlrprm%TYPE;
		--
	BEGIN
		--
		OPEN cr_param;
		--
		FETCH cr_param INTO vr_dsvlrprm;
		--
		CLOSE cr_param;
		--
		IF INSTR(',' || vr_dsvlrprm || ',',',' || pr_cdcooper || ',') > 0 THEN
      --
			RETURN FALSE;
			--
		ELSE
			--
			RETURN TRUE;
			--
    END IF;
		--
	END fn_coop_blocked;
	--
	PROCEDURE pc_insere_ocorrencia(pr_tpocorrencia IN  tbcrd_ocorrencia_arq_inadim.tpocorrencia%TYPE
		                            ,pr_dsocorrencia IN  tbcrd_ocorrencia_arq_inadim.dsocorrencia%TYPE
																,pr_nmarquivo    IN  tbcrd_ocorrencia_arq_inadim.nmarquivo%TYPE
																,pr_dscritic     OUT VARCHAR2
		                            ) IS
	  ---------------------------------------------------------------------------------------------------------------
		--  Programa : pc_insere_ocorrencia
		--  Sistema  : Aimaro
		--  Sigla    : CRED
		--  Autor    : Nagasava - Supero
		--  Data     : Março/2019.                   Ultima atualizacao:
		--
		-- Dados referentes ao programa:
		--
		-- Frequencia: -----
		-- Objetivo  : Insere as ocorrencias durante a importacao do arquivo de inadimplentes (CB093)
		-- 
		-- Alterações
		---------------------------------------------------------------------------------------------------------------
		--
		PRAGMA AUTONOMOUS_TRANSACTION;
		--
	BEGIN
		--
		INSERT INTO tbcrd_ocorrencia_arq_inadim(dtprocessamento
		                                       ,tpocorrencia
																					 ,dsocorrencia
																					 ,nmarquivo
																					 )
																		 VALUES(SYSDATE
																		       ,pr_tpocorrencia
																					 ,pr_dsocorrencia
																					 ,pr_nmarquivo
																		       );
		--
		COMMIT;
		--
	EXCEPTION
		WHEN OTHERS THEN
      ROLLBACK;
			pr_dscritic := 'Erro ao inserir a ocorrencia: ' || SQLERRM;
	END pc_insere_ocorrencia;
	--
	PROCEDURE pc_insere_controle(pr_dtmvtolt         IN  tbcrd_controle_arq_inadim.dtprocessamento%TYPE
		                          ,pr_nmarquivo        IN  tbcrd_controle_arq_inadim.nmarquivo%TYPE
		                          ,pr_dslinha_controle IN  tbcrd_controle_arq_inadim.dslinha_controle%TYPE
															,pr_idcontrole       OUT tbcrd_controle_arq_inadim.idcontrole%TYPE
															,pr_dscritic         OUT VARCHAR2
		                          ) IS
	  ---------------------------------------------------------------------------------------------------------------
		--  Programa : pc_insere_controle
		--  Sistema  : Aimaro
		--  Sigla    : CRED
		--  Autor    : Nagasava - Supero
		--  Data     : Março/2019.                   Ultima atualizacao:
		--
		-- Dados referentes ao programa:
		--
		-- Frequencia: -----
		-- Objetivo  : Insere o controle proveniente da importacao do arquivo de inadimplentes (CB093)
		-- 
		-- Alterações
		---------------------------------------------------------------------------------------------------------------
	BEGIN
		--
		INSERT INTO tbcrd_controle_arq_inadim(dtprocessamento
		                                     ,nmarquivo
																				 ,dslinha_controle
																				 )
																	 VALUES(pr_dtmvtolt
																	       ,pr_nmarquivo
																				 ,pr_dslinha_controle
																	       )
																RETURNING idcontrole
																     INTO pr_idcontrole;
		--
	EXCEPTION
		WHEN OTHERS THEN
			pr_dscritic := 'Erro ao inserir o controle: ' || SQLERRM;
	END pc_insere_controle;
	--
	PROCEDURE pc_insere_conta(pr_dtmvtolt      IN  tbcrd_conta_arq_inadim.dtprocessamento%TYPE
		                       ,pr_idcontrole    IN  tbcrd_conta_arq_inadim.idcontrole%TYPE
		                       ,pr_nmarquivo     IN  tbcrd_conta_arq_inadim.nmarquivo%TYPE
													 ,pr_dslinha_conta IN  tbcrd_conta_arq_inadim.dslinha_conta%TYPE
													 ,pr_dscritic      OUT VARCHAR2
												   ) IS
	  ---------------------------------------------------------------------------------------------------------------
		--  Programa : pc_insere_conta
		--  Sistema  : Aimaro
		--  Sigla    : CRED
		--  Autor    : Nagasava - Supero
		--  Data     : Março/2019.                   Ultima atualizacao:
		--
		-- Dados referentes ao programa:
		--
		-- Frequencia: -----
		-- Objetivo  : Insere as contas provenientes da importacao do arquivo de inadimplentes (CB093)
		-- 
		-- Alterações
		---------------------------------------------------------------------------------------------------------------
		--
		vr_idlinha tbcrd_conta_arq_inadim.idlinha%TYPE;
		--
	BEGIN
		--
		SELECT COUNT(1) + 1
		  INTO vr_idlinha
		  FROM tbcrd_conta_arq_inadim
		 WHERE pr_idcontrole = pr_idcontrole;
		--
		INSERT INTO tbcrd_conta_arq_inadim(idcontrole
		                                  ,idlinha
																			,dtprocessamento
																			,nmarquivo
																			,dslinha_conta
																			)
															  VALUES(pr_idcontrole
																      ,vr_idlinha
																			,pr_dtmvtolt
																		  ,pr_nmarquivo
																		  ,pr_dslinha_conta
																		  );
		--
	EXCEPTION
		WHEN OTHERS THEN
			pr_dscritic := 'Erro ao inserir a conta: ' || SQLERRM;
	END pc_insere_conta;
	--
	PROCEDURE pc_insere_dados_contratos(pr_cdcooper IN  crapcyc.cdcooper%TYPE
																		 ,pr_nrdconta IN  crapcyc.nrdconta%TYPE
																		 ,pr_nrctremp IN  crapcyc.nrctremp%TYPE
																		 ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE
																		 ,pr_dscritic OUT VARCHAR2
		                                   ) IS
	  --
		CURSOR cr_contratos(pr_cdcooper crapcyc.cdcooper%TYPE
		                   ,pr_nrdconta crapcyc.nrdconta%TYPE
		                   ) IS
		  SELECT cyc.cdcooper
						,cyc.nrdconta
						,cyc.dtenvcbr
						,cyc.dtinclus
						,cyc.cdopeinc
						,cyc.dtaltera
						,cyc.cdassess
						,cyc.cdmotant
				FROM crapcyc cyc
			 WHERE cyc.cdmotcin IN(2, 7)
				 AND cyc.nrdconta = pr_nrdconta
				 AND cyc.cdcooper = pr_cdcooper;
		--
		rw_contratos cr_contratos%ROWTYPE;
		--
		vr_exc_erro EXCEPTION;
		--
	BEGIN
		--
		OPEN cr_contratos(pr_cdcooper
										 ,pr_nrdconta
										 );
		--
		FETCH cr_contratos INTO rw_contratos;
		--
		IF cr_contratos%FOUND THEN
			--
			BEGIN
				--
				INSERT INTO crapcyc(cdcooper
													 ,cdorigem
													 ,nrdconta
													 ,nrctremp
													 ,flgjudic
													 ,flextjud
													 ,flgehvip
													 ,cdoperad
													 ,progress_recid
													 ,dtenvcbr
													 ,dtinclus
													 ,cdopeinc
													 ,dtaltera
													 ,cdassess
													 ,cdmotcin
													 ,flvipant
													 ,cdmotant
													 )
										 VALUES(pr_cdcooper
													 ,5 -- Cartoes
													 ,pr_nrdconta
													 ,pr_nrctremp
													 ,0
													 ,0
													 ,1
													 ,'cyber'
													 ,NULL
													 ,pr_dtmvtolt
													 ,pr_dtmvtolt
													 ,'cyber'
													 ,pr_dtmvtolt
													 ,0
													 ,2
													 ,0
													 ,0
													 );
				--
			EXCEPTION
				WHEN dup_val_on_index THEN
					BEGIN
						--
						UPDATE crapcyc cyc
						   SET cyc.dtaltera = pr_dtmvtolt
						 WHERE cyc.cdcooper = pr_cdcooper
						   AND cyc.cdorigem = 5 -- Cartoes
							 AND cyc.nrdconta = pr_nrdconta
							 AND cyc.nrctremp = pr_nrctremp;
						--
					EXCEPTION
						WHEN OTHERS THEN
							pr_dscritic := 'Erro ao atualizar na CRAPCYC: ' || SQLERRM;
					    RAISE vr_exc_erro;
					END;
				WHEN OTHERS THEN
					pr_dscritic := 'Erro ao incluir na CRAPCYC: ' || SQLERRM;
					RAISE vr_exc_erro;
			END;
			--
		END IF;
		--
		CLOSE cr_contratos;
		--
	EXCEPTION
		WHEN vr_exc_erro THEN
			NULL;
		WHEN OTHERS THEN
			CLOSE cr_contratos;
			pr_dscritic := 'Erro na pc_insere_dados_contratos: ' || SQLERRM;
	END pc_insere_dados_contratos;
	--
	PROCEDURE pc_insere_dados_financeiros(pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE
		                                   ,pr_dscritic OUT VARCHAR2
		                                   ) IS
	  --
		CURSOR cr_controle(pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
		  SELECT ctl.idcontrole
			  FROM tbcrd_controle_arq_inadim ctl
       WHERE trunc(ctl.dtprocessamento) = pr_dtmvtolt;
		--
    CURSOR cr_conta(pr_idcontrole tbcrd_conta_arq_inadim.idcontrole%TYPE
		               ) IS
			SELECT ctanum
						,cpf_cnpj
						,nome
						,agencia
						,cartao
						,dt_inadimp
						,dt_venc
						,valor_fatura
						,valor_pg_min
						,pagamentos
						,estado
						,rua_num
						,bairro
						,cidade
						,uf
						,produto
						,limite_total
						,divida_consolidada
						,(SELECT cop.cdcooper
								FROM crapcop cop
							 WHERE cop.cdagebcb = agencia) cdcooper
			FROM(
			WITH DATA AS (SELECT dslinha_conta col FROM tbcrd_conta_arq_inadim WHERE idcontrole = pr_idcontrole)
			SELECT ctanum
			      ,cpf_cnpj
						,nome
						,agencia
						,cartao
						,dt_inadimp
						,dt_venc
						,valor_fatura
						,valor_pg_min
						,pagamentos
						,estado
						,rua_num
						,bairro
						,cidade
						,uf
						,produto
						,limite_total
						,divida_consolidada
				FROM DATA
					 , XMLTABLE(('cta')
											PASSING XMLTYPE(col)
											COLUMNS ctanum             VARCHAR2(255) PATH 'ctanum'
														 ,cpf_cnpj           VARCHAR2(255) PATH 'cpf-cnpj'
														 ,nome               VARCHAR2(255) PATH 'nome'
														 ,agencia            VARCHAR2(255) PATH 'agencia'
														 ,cartao             VARCHAR2(255) PATH 'cartao'
														 ,dt_inadimp         VARCHAR2(255) PATH 'dt-inadimp'
														 ,dt_venc            VARCHAR2(255) PATH 'dt-venc'
														 ,valor_fatura       VARCHAR2(255) PATH 'valor-fatura'
														 ,valor_pg_min       VARCHAR2(255) PATH 'valor-pg-min'
														 ,pagamentos         VARCHAR2(255) PATH 'pagamentos'
														 ,estado             VARCHAR2(255) PATH 'estado'
														 ,rua_num            VARCHAR2(255) PATH 'endereco/rua-num'
														 ,bairro             VARCHAR2(255) PATH 'endereco/bairro'
														 ,cidade             VARCHAR2(255) PATH 'endereco/cidade'
														 ,uf                 VARCHAR2(255) PATH 'endereco/uf'
														 ,produto            VARCHAR2(255) PATH 'produto'
														 ,limite_total       VARCHAR2(255) PATH 'limite-total'
														 ,divida_consolidada VARCHAR2(255) PATH 'divida-consolidada'
											 ));
		--
		CURSOR cr_cartao(pr_nrcctig  crawcrd.nrcctitg%TYPE
										,pr_cdcooper crawcrd.cdcooper%TYPE
		                ) IS
			SELECT tcc.nrdconta
				FROM tbcrd_conta_cartao tcc
			 WHERE tcc.cdcooper       = pr_cdcooper
				 AND tcc.nrconta_cartao = pr_nrcctig;
		--
		vr_nrctremp crapcyb.nrctremp%TYPE;
		vr_vlsdeved crapcyb.vlsdeved%TYPE;
		vr_vlpreapg crapcyb.vlpreapg%TYPE;
		vr_qtdiaatr crapcyb.qtdiaatr%TYPE;
		vr_qtmesdec crapcyb.qtmesdec%TYPE;
		vr_vlemprst crapcyb.vlemprst%TYPE;
		--
		vr_exc_erro EXCEPTION;
		--
	BEGIN
		-- Percorrer todos os dados retornados no arquivo com aprovações
    FOR rg_controle IN cr_controle(pr_dtmvtolt) LOOP
			--
			FOR rg_conta IN cr_conta(rg_controle.idcontrole) LOOP
				--
				FOR rg_cartao IN cr_cartao(rg_conta.ctanum
																	,rg_conta.cdcooper
																	 ) LOOP
					-- Inicializa as variaveis
					vr_nrctremp := NULL;
					vr_vlsdeved := NULL;
					vr_vlpreapg := NULL;
					vr_vlemprst := NULL;
					vr_qtdiaatr := NULL;
					vr_qtmesdec := NULL;
					-- Gera o numero do contrato com base na conta cartao, utiliando os 8 ultimos digitos
					SELECT CASE WHEN LENGTH(rg_conta.ctanum) >= 6 THEN
									 SUBSTR(rg_conta.ctanum, -6, 6)
								 ELSE
									 SUBSTR(rg_conta.ctanum,LENGTH(rg_conta.ctanum)*-1, LENGTH(rg_conta.ctanum))
								 END
						INTO vr_nrctremp
						FROM dual;
					-- Converte os valores para number
					vr_vlsdeved := to_number(substr(rg_conta.valor_fatura
																				 ,0
																				 ,LENGTH(rg_conta.valor_fatura) -2) 
																	 || ',' ||
																	 substr(rg_conta.valor_fatura
																				 ,LENGTH(rg_conta.valor_fatura) -1
																				 ,2));
					vr_vlpreapg := to_number(substr(rg_conta.valor_pg_min
																				 ,0
																				 ,LENGTH(rg_conta.valor_pg_min) -2) 
																	 || ',' ||
																	 substr(rg_conta.valor_pg_min
																				 ,LENGTH(rg_conta.valor_pg_min) -1
																				 ,2));
          vr_vlemprst := to_number(substr(rg_conta.limite_total
																				 ,0
																				 ,LENGTH(rg_conta.limite_total) -2) 
																	 || ',' ||
																	 substr(rg_conta.limite_total
																				 ,LENGTH(rg_conta.limite_total) -1
																				 ,2));
					-- Calculo de dias de atraso
					vr_qtdiaatr := pr_dtmvtolt - to_date(rg_conta.dt_inadimp,'yyyymmdd');
					-- Calculo de meses ade atraso
					vr_qtmesdec := trunc(months_between(pr_dtmvtolt
                                             ,to_date(rg_conta.dt_inadimp,'yyyymmdd')));
					
					-- Gera os dados dos contratos para o CYBER
					pc_insere_dados_contratos(pr_cdcooper => rg_conta.cdcooper  -- Codigo da Cooperativa
																	 ,pr_nrdconta => rg_cartao.nrdconta  -- Numero da conta
																	 ,pr_nrctremp => vr_nrctremp         -- Numero do contrato
																	 ,pr_dtmvtolt => pr_dtmvtolt         -- Identifica a data de criacao do reg. de cobranca na CYBER.
																	 ,pr_dscritic => pr_dscritic         -- Descrição do erro
																	 );
					--
					IF pr_dscritic IS NOT NULL THEN
						--
						RAISE vr_exc_erro;
						--
					END IF;
					-- Atualiza dados do emprestimo para o CYBER
					cybe0001.pc_atualiza_dados_financeiro(pr_cdcooper => rg_conta.cdcooper                                -- Codigo da Cooperativa
																							 ,pr_nrdconta => rg_cartao.nrdconta                                -- Numero da conta
																							 ,pr_nrctremp => vr_nrctremp                                       -- Numero do contrato
																							 ,pr_cdorigem => 5 -- Fixo                                         -- Origem cyber
																							 ,pr_dtmvtolt => pr_dtmvtolt                                       -- Identifica a data de criacao do reg. de cobranca na CYBER.
																							 ,pr_vlsdeved => vr_vlsdeved                                       -- Saldo devedor
																							 ,pr_vlpreapg => vr_vlpreapg                                       -- Valor a regularizar
																							 ,pr_qtprepag => NULL -- ???                                       -- Prestacoes Pagas
																							 ,pr_txmensal => NULL -- ???                                       -- Taxa mensal
																							 ,pr_txdiaria => NULL -- ???                                       -- Taxa diaria
																							 ,pr_vlprepag => NULL -- ???                                       -- Vlr. Prest. Pagas
																							 ,pr_qtmesdec => vr_qtmesdec                                       -- Qtd. meses decorridos
																							 ,pr_dtdpagto => to_date(rg_conta.dt_inadimp,'yyyymmdd')           -- Data de pagamento
																							 ,pr_cdlcremp => NULL -- ???                                       -- Codigo da linha de credito
																							 ,pr_cdfinemp => NULL -- ???                                       -- Codigo da finalidade.
																							 ,pr_dtefetiv => NULL -- rg_cartao.dtlibera                                -- Data da efetivacao do emprestimo.
																							 ,pr_vlemprst => vr_vlemprst                                       -- Valor emprestado.
																							 ,pr_qtpreemp => NULL -- ???                                       -- Quantidade de prestacoes.
																							 ,pr_flgfolha => NULL -- ???                                       -- O pagamento e por Folha
																							 ,pr_vljura60 => NULL -- ???                                       -- Juros 60 dias
																							 ,pr_vlpreemp => NULL -- ???                                       -- Valor da prestacao
																							 ,pr_qtpreatr => NULL -- ???                                       -- Qtd. Prestacoes
																							 ,pr_vldespes => NULL -- ???                                       -- Valor despesas
																							 ,pr_vlperris => NULL -- ???                                       -- Valor percentual risco
																							 ,pr_nivrisat => NULL -- ???                                       -- Risco atual
																							 ,pr_nivrisan => NULL -- ???                                       -- Risco anterior
																							 ,pr_dtdrisan => NULL -- ???                                       -- Data risco anterior
																							 ,pr_qtdiaris => NULL -- ???                                       -- Quantidade dias risco
																							 ,pr_qtdiaatr => vr_qtdiaatr                                       -- Dias de atraso
																							 ,pr_flgrpeco => NULL -- ???                                       -- Grupo Economico
																							 ,pr_flgpreju => NULL -- ???                                       -- Esta em prejuizo.
																							 ,pr_flgconsg => NULL -- ???                                       -- Indicador de valor consignado.
																							 ,pr_flgresid => NULL -- ???                                       -- Flag de residuo
																							 ,pr_dtvencto => to_date(rg_conta.dt_venc,'yyyymmdd')              -- Data de vencimento do cartão
																							 ,pr_dscritic => pr_dscritic
																							 );
					--
					IF pr_dscritic IS NOT NULL THEN
						--
						RAISE vr_exc_erro;
						--
					END IF;
					--
				END LOOP;
				--
			END LOOP;
			--
		END LOOP;
		--
	EXCEPTION
		WHEN vr_exc_erro THEN
			NULL;
		WHEN OTHERS THEN
			pr_dscritic := 'ccrd.pc_insere_dados_financeiros: ' || SQLERRM;
	END pc_insere_dados_financeiros;
	--
	PROCEDURE pc_atualiza_crapcyb(pr_cdcooper IN  crapcyb.cdcooper%TYPE
		                           ,pr_dtmvtolt IN  crapcyb.dtmvtolt%TYPE
															 ,pr_dtmvtoan IN  crapdat.dtmvtoan%TYPE
															 ,pr_dscritic OUT VARCHAR2
		                 	         ) IS
		--
		PRAGMA AUTONOMOUS_TRANSACTION;
		--
	BEGIN
		--
		UPDATE crapcyb cyb
		   SET cyb.dtatufin = pr_dtmvtolt
		 WHERE cyb.cdcooper = pr_cdcooper
		   AND cyb.cdorigem = 5; -- Cartoes
		--
		COMMIT;
		--
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			pr_dscritic := 'Erro ao tentar atualizar a crapcyb: ' || SQLERRM;
	END pc_atualiza_crapcyb;
	--
  PROCEDURE pc_atual_param_import_inadim(pr_cdcooper IN  crapcop.cdcooper%TYPE
																				,pr_tipsplit IN  GENE0002.typ_split
																				,pr_dscritic OUT VARCHAR2
																				) IS
		---------------------------------------------------------------------------------------------------------------
		--  Programa : pc_atual_param_import_inadim
		--  Sistema  : Aimaro
		--  Sigla    : CRED
		--  Autor    : Nagasava - Supero
		--  Data     : Março/2019.                   Ultima atualizacao:
		--
		-- Dados referentes ao programa:
		--
		-- Frequencia: -----
		-- Objetivo  : Atualizar o status de controle de importacao do arquivo de inadimplentes (CB093)
		-- 
		-- Alterações
		---------------------------------------------------------------------------------------------------------------
		--
		vr_dsvlrprm crapprm.dsvlrprm%TYPE;
		vr_total    INTEGER;
		--
    PRAGMA AUTONOMOUS_TRANSACTION;
    
	BEGIN
		vr_total := pr_tipsplit.COUNT;
		FOR vr_indice IN pr_tipsplit.first .. pr_tipsplit.last LOOP
			IF vr_total = vr_indice THEN
				vr_dsvlrprm := vr_dsvlrprm || pr_tipsplit(vr_indice);
			ELSE
				vr_dsvlrprm := vr_dsvlrprm || pr_tipsplit(vr_indice) || ';';
			END IF;
		END LOOP;
      
		BEGIN
			UPDATE crapprm
				 SET dsvlrprm = vr_dsvlrprm
			 WHERE cdcooper = pr_cdcooper
				 AND UPPER(nmsistem) = 'CRED' 
				 AND UPPER(cdacesso) = 'IMPORTACAO_CB093';
         
      COMMIT;
		EXCEPTION
			WHEN OTHERS THEN
        ROLLBACK;
				pr_dscritic := 'Erro ao atualizar crapprm: ' || SQLERRM;
		END;
    --
  END pc_atual_param_import_inadim;
  
  PROCEDURE pc_gera_log(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_cdprogra IN crapprg.cdprogra%TYPE
                       ,pr_cdorigem IN INTEGER
                       ,pr_cdcritic IN crapcri.cdcritic%TYPE
                       ,pr_dscritic IN crapcri.dscritic%TYPE) IS
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_gera_log
    --  Sistema  : Aimaro
    --  Sigla    : CRED
    --  Autor    : Nagasava - Supero
    --  Data     : Marco/2019.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Atualizar o status de controle de importacao do arquivo
    -- 
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------                        
    --
		vr_cdcooper PLS_INTEGER;
		vr_dscritic VARCHAR2(4000);    
	BEGIN
		vr_cdcooper := pr_cdcooper;
		vr_dscritic := pr_dscritic;
		-- Job
		IF pr_cdorigem = 7 THEN
			-- CECRED
			vr_cdcooper := 3;
		END IF;
		-- Se foi passado somente o codigo da critica
		IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
			-- Buscar a descrição
			vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
		-- Se foi passado como parametro o codigo da critica e a descricao da critica          
		ELSIF pr_cdcritic > 0 AND pr_dscritic IS NOT NULL THEN
			vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic) || ' --> ' || vr_dscritic;
		END IF;
		-- Monta a descricao para o LOG
		vr_dscritic := TO_CHAR(SYSDATE,'HH24:MI:SS') || ' - ' || pr_cdprogra || ' --> ' || vr_dscritic;
		-- Gera o LOG
		btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
															,pr_ind_tipo_log => 2
															,pr_des_log      => vr_dscritic);
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
  END pc_gera_log;
    
  PROCEDURE pc_lista_arquivos(pr_cdcooper IN crapcop.cdcooper%TYPE    --> Cooperativa
		                         ,pr_cdagebcb IN crapcop.cdagebcb%TYPE    --> Agencia do Bancoob
                             ,pr_dsdirarq IN crapscb.dsdirarq%TYPE    --> Diretorio que contem os arquivos
														 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
														 ,pr_dtmvtoan IN crapdat.dtmvtoan%TYPE
                             ,pr_listadir OUT VARCHAR2                --> Arquivos que serao importados
                             ,pr_nmrquivo OUT VARCHAR2                --> Nome do Arquivo
                             ,pr_cdcritic OUT PLS_INTEGER             --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2) IS            --> Descrição da crítica                  
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_lista_arquivos
    --  Sistema  : Aimaro
    --  Sigla    : CRED
    --  Autor    : Nagasava - Supero
    --  Data     : Marco/2019.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Listar os arquivos que serao importados
    -- 
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------                        
		--
		-- Variaveis de Erro
		vr_cdcritic   crapcri.cdcritic%TYPE;
		vr_dscritic   VARCHAR2(4000);
			
		-- Variaveis Excecao
		vr_exc_erro   EXCEPTION;
	BEGIN
		-- Monta nome do arquivo
		pr_nmrquivo := '756-2011-CB093_756_' || TO_CHAR(lpad(pr_cdagebcb,4,'0')) || '_' || to_char(pr_dtmvtolt, 'yyyymmdd');
		-- Recupera a lista de arquivos "CB093"
		gene0001.pc_lista_arquivos(pr_path     => pr_dsdirarq || '/recebe/' -- '/micros/connectdirect'
															,pr_pesq     => pr_nmrquivo || '%'
															,pr_listarq  => pr_listadir
															,pr_des_erro => vr_dscritic
															);
                                     
		IF vr_dscritic IS NOT NULL THEN
			RAISE vr_exc_erro;
		END IF;
		--
		IF pr_listadir IS NULL THEN
			--
			pc_atualiza_crapcyb(pr_cdcooper => pr_cdcooper -- IN
												 ,pr_dtmvtolt => pr_dtmvtolt -- IN
												 ,pr_dtmvtoan => pr_dtmvtoan -- IN
												 ,pr_dscritic => vr_dscritic -- OUT
												 );
			--
			IF vr_dscritic IS NOT NULL THEN
				RAISE vr_exc_erro;
			END IF;
			--
		  pc_insere_ocorrencia(pr_tpocorrencia => 'A' -- IN
													,pr_dsocorrencia => 'Arquivo da agencia ' || TO_CHAR(lpad(pr_cdagebcb,4,'0')) ||
													                    ' e data ' || to_char(pr_dtmvtolt, 'yyyymmdd') ||
																							' nao encontrado.' -- IN
													,pr_nmarquivo    => pr_nmrquivo -- IN
													,pr_dscritic     => vr_dscritic -- OUT
													);
			--
		IF vr_dscritic IS NOT NULL THEN
			RAISE vr_exc_erro;
			END IF;
			--
		END IF;
		-- 
	EXCEPTION
		WHEN vr_exc_erro THEN
			--Variavel de erro recebe erro ocorrido
			IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
				-- Buscar a descrição
				vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			END IF;
			pr_cdcritic := vr_cdcritic;
			pr_dscritic := vr_dscritic;
		WHEN OTHERS THEN
			-- Descricao do erro
			pr_dscritic := 'Erro nao tratado na CCRD0009.pc_lista_arquivos ' || SQLERRM;
  END pc_lista_arquivos;    
  
  /* Procedure para mover arquivos processados para a pasta /USR/CONNECT/BANCOOB/RECEBIDOS */
  PROCEDURE pc_move_arquivo_recebido(pr_cdcooper IN crapcop.cdcooper%TYPE
                                    ,pr_cdorigem IN INTEGER
                                    ,pr_nmdireto IN VARCHAR2     --> Caminho de arquivos do Bancoob/CABAL
                                    ,pr_nmrquivo IN VARCHAR2) IS --> Nome do arquivo  
    ---------------------------------------------------------------------------------------------------------------------
    --  Programa : pc_move_arquivo_recebido
    --  Sistema  : Aimaro
    --  Sigla    : CRED
    --  Autor    : Nagasava - Supero
    --  Data     : Marco/2019.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Esta rotina responsavel por salvar os arquivos recebidos
    -- 
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------------      
		 vr_comando   VARCHAR2(2000); --> Comando UNIX para Mover arquivo lido
		 vr_typ_saida VARCHAR2(100);  -- Tipo de saida
       
		 -- Variaveis tratamento de erros
		 vr_cdcritic  PLS_INTEGER;
		 vr_dscritic  VARCHAR2(4000);
	BEGIN
		--
		IF pr_nmdireto IS NOT NULL AND pr_nmrquivo IS NOT NULL THEN
			--
			vr_comando := 'mv '|| pr_nmdireto || '/recebe/' || pr_nmrquivo || ' ' || pr_nmdireto || '/recebidos/';
			GENE0001.pc_OScommand(pr_typ_comando => 'S'
													 ,pr_des_comando => vr_comando                           
													 ,pr_typ_saida   => vr_typ_saida
													 ,pr_des_saida   => vr_dscritic);
	                           
			IF vr_dscritic IS NOT NULL THEN
				-- Grava LOG
				pc_gera_log(pr_cdcooper => pr_cdcooper
									 ,pr_cdprogra => 'JOB_IMPORTACAO_CB093'
									 ,pr_cdorigem => pr_cdorigem
									 ,pr_cdcritic => vr_cdcritic
									 ,pr_dscritic => vr_dscritic);
			END IF;
			--
		END IF;
		--
  END pc_move_arquivo_recebido;  
                      
  PROCEDURE pc_import_arq_inadim(pr_dsdirarq   IN VARCHAR2  --> Diretorio dos arquivos
															  ,pr_listadir   IN VARCHAR2  --> Lista os arquivos que serao importados
																,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE
															  ,pr_dscritic   OUT VARCHAR2 --> Descricao da critica
															  ) IS
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_import_arq_inadim
    --  Sistema  : Aimaro
    --  Sigla    : CRED
    --  Autor    : Nagasava - Supero
    --  Data     : Marco/2019.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Importar os arquivos de inadimplentes
    --
    -- Alterações: 
		--
    ---------------------------------------------------------------------------------------------------------------
		-- CURSOR
    CURSOR cr_dados_controle(pr_dsxmlarq CLOB) IS
			SELECT extract(XMLTYPE(pr_dsxmlarq),
						 'cb093/controle') dslinha
				FROM dual;
	  -- CURSOR
    CURSOR cr_dados_conta(pr_dsxmlarq xmltype) IS
			SELECT column_value
				FROM (SELECT pr_dsxmlarq col FROM dual) x,
				table(xmlsequence(extract(x.col, 'cb093/cta'))) d;
		--
		vr_dsarquivo  CLOB;
		vr_idcontrole tbcrd_controle_arq_inadim.idcontrole%TYPE;
		-- Variaveis Excecao
    vr_exc_proximo EXCEPTION;
		--
  BEGIN
		--
		vr_dsarquivo := gene0002.fn_arq_para_clob(pr_caminho => pr_dsdirarq || '/recebe' -- '/micros/connectdirect'
																						 ,pr_arquivo => pr_listadir
																						 );
		-- Percorrer todos os dados de controle retornados no arquivo
    FOR rg_dados_controle IN cr_dados_controle(vr_dsarquivo) LOOP
			--
			--dbms_output.put_line(rg_dados_controle.dslinha.getClobVal());
			pc_insere_controle(pr_dtmvtolt         => pr_dtmvtolt                            -- IN
			                  ,pr_nmarquivo        => pr_listadir                            -- IN
												,pr_dslinha_controle => rg_dados_controle.dslinha.getClobVal() -- IN
												,pr_idcontrole       => vr_idcontrole                          -- OUT
												,pr_dscritic         => pr_dscritic                            -- OUT
												);
			--
			IF pr_dscritic IS NOT NULL THEN
				--
				RAISE vr_exc_proximo;
				--
			END IF;
			--
		END LOOP;
		-- Percorrer todos os dados de conta retornados no arquivo
    FOR rg_dados_conta IN cr_dados_conta(xmltype(vr_dsarquivo)) LOOP
			--
			--dbms_output.put_line(rg_dados_conta.column_value.getClobVal());
			pc_insere_conta(pr_dtmvtolt      => pr_dtmvtolt                              -- IN
			               ,pr_idcontrole    => vr_idcontrole                            -- IN
										 ,pr_nmarquivo     => pr_listadir                              -- IN
										 ,pr_dslinha_conta => rg_dados_conta.column_value.getClobVal() -- IN
										 ,pr_dscritic      => pr_dscritic                              -- OUT
										 );
			--
			IF pr_dscritic IS NOT NULL THEN
				--
				RAISE vr_exc_proximo;
				--
			END IF;
			--
		END LOOP;
		--
  EXCEPTION
		WHEN vr_exc_proximo THEN
			pc_gera_log(pr_cdcooper => 3
								 ,pr_cdprogra => 'IMPORTACAO_CB093'
								 ,pr_cdorigem => 7
								 ,pr_cdcritic => 0
								 ,pr_dscritic => pr_dscritic
								 );
			--
      pc_insere_ocorrencia(pr_tpocorrencia => 'E' -- IN
													,pr_dsocorrencia => pr_dscritic -- IN
													,pr_nmarquivo    => pr_listadir -- IN
													,pr_dscritic     => pr_dscritic -- OUT
													);
    WHEN OTHERS THEN
			pc_gera_log(pr_cdcooper => 3
								 ,pr_cdprogra => 'IMPORTACAO_CB093'
								 ,pr_cdorigem => 7
								 ,pr_cdcritic => 0
								 ,pr_dscritic => SQLERRM
								 );
			--
			pc_insere_ocorrencia(pr_tpocorrencia => 'E' -- IN
													,pr_dsocorrencia => SQLERRM -- IN
													,pr_nmarquivo    => pr_listadir -- IN
													,pr_dscritic     => pr_dscritic -- OUT
													);
  END pc_import_arq_inadim;
  
  /* Esta rotina é acionada diretamente pelo Job */
  PROCEDURE pc_import_arq_inadim_job IS
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_import_arq_inadim_job
    --  Sistema  : Aimaro
    --  Sigla    : CRED
    --  Autor    : Nagasava - Supero
    --  Data     : Março/2019.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Esta rotina será acionada diretamente pelo Job para importar os arquivos de inadimplemtes (CB093)
    -- 
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------
		-- Busca as cooperativas
		CURSOR cr_crapcop IS
			SELECT cdcooper
						,nmrescop
						,cdagebcb
				FROM crapcop
			 WHERE flgativo = 1
				 AND cdcooper <> 3
		ORDER BY cdcooper;
      
		CURSOR cr_crapscb IS
			SELECT dsdirarq
				FROM crapscb
			 WHERE tparquiv = 6; -- CB093
		rw_crapscb cr_crapscb%ROWTYPE;
      
		-- Cursor generico de calendario
		rw_crapdat     BTCH0001.CR_CRAPDAT%ROWTYPE;
      
		-- Variaveis
		vr_hasfound    BOOLEAN;
		vr_cdcooper    crapcop.cdcooper%TYPE;
		vr_dsprmris    crapprm.dsvlrprm%TYPE;
		vr_cdorigem    INTEGER;
		vr_listadir    VARCHAR2(4000);  -- Descricao da saida
		vr_nmrquivo    VARCHAR2(4000);  -- Nome do arquivo
		vr_indice      VARCHAR2(10);
		vr_dtrefere    DATE;
		vr_dtmvtolt    crapdat.dtmvtolt%TYPE;
		vr_dtmvtoan    crapdat.dtmvtoan%TYPE;
      
		-- Variaveis de Erro
		vr_cdcritic    crapcri.cdcritic%TYPE;
		vr_dscritic    VARCHAR2(4000);

		-- Variaveis Excecao
		vr_exc_proximo EXCEPTION;
      
		-- Tabela para armazenar os registros do arquivo
		vr_tab_crapcop typ_tab_crapcop;
		vr_tipsplit    gene0002.typ_split;
	BEGIN
		-- Batch
		vr_cdorigem := 7;
		vr_tab_crapcop.DELETE;
      
		-- Leitura do calendário da cooperativa
		OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
		FETCH btch0001.cr_crapdat
			INTO rw_crapdat;
		CLOSE btch0001.cr_crapdat;
		-- TO_DO: Ajustar
		-- Se estiver rodando pós processo 
		IF rw_crapdat.inproces = 1 THEN
			--
			vr_dtmvtolt := rw_crapdat.dtmvtoan;
			vr_dtmvtoan := GENE0005.fn_valida_dia_util(pr_cdcooper  => 3
                                                ,pr_dtmvtolt  => vr_dtmvtolt - 1
                                                ,pr_tipo      => 'A'
																								);
			--
		ELSE
			--
			vr_dtmvtolt := rw_crapdat.dtmvtolt;
			vr_dtmvtoan := rw_crapdat.dtmvtoan;
			--
		END IF;
      
		-- Inicio da geracao de LOG no arquivo
		pc_gera_log(pr_cdcooper => 3
							 ,pr_cdprogra => 'JOB_IMPORTACAO_CB093'
							 ,pr_cdorigem => vr_cdorigem
							 ,pr_cdcritic => 0
							 ,pr_dscritic => 'Inicio da execucao do JOB_IMPORTACAO_CB093');
      
		-- buscar informações do arquivo a ser processado
		OPEN cr_crapscb;
		FETCH cr_crapscb INTO rw_crapscb;
		CLOSE cr_crapscb;
       
		-- Vamos percorrer todas as cooperativas e gravar na tabela temporaria, devido ao erro ORA-01002
		FOR rw_crapcop IN cr_crapcop LOOP
			-- So processa o arquivo das cooperativas que nao estao bloqueadas
			IF fn_coop_blocked(rw_crapcop.cdcooper) THEN
				--
				vr_indice := LPAD(rw_crapcop.cdcooper,10,'0');
				vr_tab_crapcop(vr_indice).cdcooper := rw_crapcop.cdcooper;
				vr_tab_crapcop(vr_indice).nmrescop := rw_crapcop.nmrescop;        
				vr_tab_crapcop(vr_indice).cdagebcb := rw_crapcop.cdagebcb;
				--
			END IF;
			--
		END LOOP;
      
		-- Faz laço com todas as cooperativas     
		vr_indice := vr_tab_crapcop.first;
		WHILE vr_indice IS NOT NULL LOOP
			BEGIN
				vr_cdcooper := vr_tab_crapcop(vr_indice).cdcooper;
				-- Buscar a data do movimento
				OPEN btch0001.cr_crapdat(vr_cdcooper);
				FETCH btch0001.cr_crapdat INTO rw_crapdat;
				-- Verificar se existe informacao, e gerar erro caso nao exista
				vr_hasfound := btch0001.cr_crapdat%FOUND;
				-- Fechar o cursor
				CLOSE btch0001.cr_crapdat;
				IF NOT vr_hasfound THEN
					-- Gerar excecao
					vr_cdcritic := 1;
					RAISE vr_exc_proximo;
				END IF;
				-- Data de Referencia
				vr_dtrefere := rw_crapdat.dtultdma;          
				-- Condicao para verificar se o arquivo contabil jah foi gerado -- TO_DO: Manter essa validação?
				vr_dsprmris := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
																								,pr_cdcooper => vr_cdcooper
																								,pr_cdacesso => 'IMPORTACAO_CB093');
                                                       
				vr_tipsplit := gene0002.fn_quebra_string(pr_string => vr_dsprmris, pr_delimit => ';');
				-- Condicao para verificar se nesse momento estah ocorrendo a geracao do arquivo contabil, ou se o arquivo jah foi gerado
				IF ((vr_tipsplit(2) = 1) OR (TO_CHAR(TO_DATE(vr_tipsplit(1),'DD/MM/RRRR'),'MMRRRR') = TO_CHAR(rw_crapdat.dtmvtolt,'MMRRRR'))) THEN
					RAISE vr_exc_proximo;
				END IF;
          
				-- Condicao para verificar se nesse momento estah sendo importado os arquivos de inadimplentes
				IF vr_tipsplit(3) = 1 THEN
					RAISE vr_exc_proximo;
				END IF;
          
				-- Seta a flag para informar que estah sendo importado o arquivo de inadimiplentes
				vr_tipsplit(3) := 1;
				pc_atual_param_import_inadim(pr_cdcooper => vr_cdcooper
																		,pr_tipsplit => vr_tipsplit
																		,pr_dscritic => vr_dscritic);
				IF vr_dscritic IS NOT NULL THEN
					RAISE vr_exc_proximo;
				END IF;
          
				-- Busca os arquivos que serao importados
				pc_lista_arquivos(pr_cdcooper => vr_cdcooper
				                 ,pr_cdagebcb => vr_tab_crapcop(vr_indice).cdagebcb
												 ,pr_dsdirarq => rw_crapscb.dsdirarq
												 ,pr_listadir => vr_listadir
												 ,pr_dtmvtolt => vr_dtmvtolt
												 ,pr_dtmvtoan => vr_dtmvtoan
												 ,pr_nmrquivo => vr_nmrquivo
												 ,pr_cdcritic => vr_cdcritic
												 ,pr_dscritic => vr_dscritic
												 );
				-- Condicao para verificar se houve erro
				IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
					RAISE vr_exc_proximo;
				END IF;
				
				-- Condicao para se o arquivo nao foi encontrado
				IF vr_listadir IS NULL THEN
					--
					vr_dscritic := 'Arquivo ' || vr_nmrquivo || 'nao encontrado';
					RAISE vr_exc_proximo;
					--
				END IF; 
          
				-- Procedure responsavel pela importacao do arquivo de risco do cartao
				pc_import_arq_inadim(pr_dsdirarq                => rw_crapscb.dsdirarq --> Diretorio dos arquivos
													  ,pr_listadir                => vr_listadir         --> Lista os arquivos que serao importados
														,pr_dtmvtolt                => vr_dtmvtolt
													  ,pr_dscritic                => vr_dscritic         --> Descricao da critica
													  );
          
				-- Condicao para verificar se houve erro
				IF vr_dscritic IS NOT NULL THEN
					RAISE vr_exc_proximo;
				END IF;
				--
			EXCEPTION
				WHEN vr_exc_proximo THEN
					ROLLBACK;
					IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
						-- Grava LOG
						pc_gera_log(pr_cdcooper => 3
											 ,pr_cdprogra => 'IMPORTACAO_CB093'
											 ,pr_cdorigem => vr_cdorigem
											 ,pr_cdcritic => vr_cdcritic
											 ,pr_dscritic => vr_dscritic);
					END IF;
				WHEN OTHERS THEN
					ROLLBACK;
					-- Grava LOG
					pc_gera_log(pr_cdcooper => 3
										 ,pr_cdprogra => 'IMPORTACAO_CB093'
										 ,pr_cdorigem => vr_cdorigem
										 ,pr_cdcritic => 0
										 ,pr_dscritic => SQLERRM);
			END;
        
			-- Seta a flag para informar que acabou de importar o arquivo a cooperativa
			vr_tipsplit(3) := 0;
			pc_atual_param_import_inadim(pr_cdcooper => vr_cdcooper
																	,pr_tipsplit => vr_tipsplit
																	,pr_dscritic => vr_dscritic);                                          
			-----------------------------------------------------------------------------------------------------------
			--  INICIO PARA MOVER OS ARQUIVOS PROCESSADOS PARA A PASTA /USR/CONNECT/BANCOOB/RECEBIDOS
			-----------------------------------------------------------------------------------------------------------
			pc_move_arquivo_recebido(pr_cdcooper => vr_cdcooper
															,pr_cdorigem => vr_cdorigem
															,pr_nmdireto => rw_crapscb.dsdirarq
															,pr_nmrquivo => vr_listadir
															);
			-- Proxima cooperativa
			vr_indice := vr_tab_crapcop.next(vr_indice);
 			-- Comitar por cooperativa
			COMMIT;
		END LOOP;
		--
		pc_insere_dados_financeiros(pr_dtmvtolt => vr_dtmvtolt -- IN
		                           ,pr_dscritic => vr_dscritic -- OUT
															 );
		-- Condicao para verificar se houve erro
		IF vr_dscritic IS NOT NULL THEN
			RAISE vr_exc_proximo;
		END IF;
      
		-- Inicio da geracao de LOG no arquivo
		pc_gera_log(pr_cdcooper => 3
							 ,pr_cdprogra => 'IMPORTACAO_CB093'
							 ,pr_cdorigem => vr_cdorigem
							 ,pr_cdcritic => 0
							 ,pr_dscritic => 'Execucao ok');
  	COMMIT;

	EXCEPTION
		WHEN OTHERS THEN
			-- Desfazer a operacao
			ROLLBACK;
			-- Gera log
			pc_gera_log(pr_cdcooper => 3
								 ,pr_cdprogra => 'IMPORTACAO_CB093'
								 ,pr_cdorigem => vr_cdorigem
								 ,pr_cdcritic => 0
								 ,pr_dscritic => SQLERRM);
  END pc_import_arq_inadim_job;
  --  
END CCRD0009;
/
