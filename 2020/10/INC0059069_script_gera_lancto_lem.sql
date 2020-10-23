-- Created on 16/09/2020 by T0031546 
DECLARE 
  --
  CURSOR cr_craplcm IS
	  SELECT lcm.dtmvtolt
					,lcm.vllanmto
					,lcm.cdcooper
					,lcm.nrdconta
					,epr.nrctremp
					,epr.cdlcremp
					,epr.vlpreemp
					,epr.txjuremp
					,pep.vlparepr
					,pep.nrparepr
			FROM craplcm lcm
			    ,crapepr epr
					,crappep pep
		 WHERE lcm.cdcooper = epr.cdcooper
		   AND lcm.nrdconta = epr.nrdconta
			 AND REPLACE(TRIM(lcm.cdpesqbb), '.', '') = epr.nrctremp
			 AND epr.cdcooper = pep.cdcooper
			 AND epr.nrdconta = pep.nrdconta
			 AND epr.nrctremp = pep.nrctremp
			 AND lcm.nrparepr = pep.nrparepr
		   AND lcm.cdcooper = 1
			 AND lcm.nrdconta = 2258692
			 AND lcm.dtmvtolt = '19/08/2020'
			 AND TRIM(lcm.cdpesqbb) = '983.114'
			 AND lcm.nrparepr = 64
	UNION
	  SELECT lcm.dtmvtolt
          ,lcm.vllanmto
          ,lcm.cdcooper
          ,lcm.nrdconta
          ,epr.nrctremp
          ,epr.cdlcremp
          ,epr.vlpreemp
          ,epr.txjuremp
          ,pep.vlparepr
          ,pep.nrparepr
      FROM craplcm lcm
          ,crapepr epr
          ,crappep pep
     WHERE lcm.cdcooper = epr.cdcooper
       AND lcm.nrdconta = epr.nrdconta
       AND REPLACE(TRIM(lcm.cdpesqbb), '.', '') = epr.nrctremp
       AND epr.cdcooper = pep.cdcooper
       AND epr.nrdconta = pep.nrdconta
       AND epr.nrctremp = pep.nrctremp
       AND lcm.nrparepr = pep.nrparepr
			 AND lcm.cdcooper = 1
			 AND lcm.nrdconta = 10136347
			 AND lcm.dtmvtolt = '19/08/2020'
			 AND TRIM(lcm.cdpesqbb) = '2.849.886'
			 AND lcm.nrparepr = 1;
  --
	rw_craplcm cr_craplcm%ROWTYPE;
	-- Cursor de Linha de Credito
  CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                   ,pr_cdlcremp IN craplcr.cdlcremp%TYPE
									 ) IS
    SELECT craplcr.cdlcremp
          ,craplcr.dsoperac
      FROM craplcr
     WHERE craplcr.cdcooper = pr_cdcooper
       AND craplcr.cdlcremp = pr_cdlcremp;
  --
	rw_craplcr cr_craplcr%ROWTYPE;
	--
	vr_cdcritic     crapcri.cdcritic%TYPE;
	vr_dscritic     crapcri.dscritic%TYPE;
	vr_floperac     BOOLEAN;
	vr_pag_nrdolote INTEGER;
	vr_pag_cdhistor INTEGER;
	vr_des_nrdolote INTEGER;
	vr_des_cdhistor INTEGER;
	vr_lcm_nrdolote INTEGER;
	rw_crapdat      btch0001.cr_crapdat%ROWTYPE;
	--
BEGIN
  --
	OPEN btch0001.cr_crapdat(pr_cdcooper => 1);
	FETCH btch0001.cr_crapdat
		INTO rw_crapdat;
	CLOSE btch0001.cr_crapdat;
	--
	OPEN cr_craplcm;
	--
	LOOP
		--
		FETCH cr_craplcm INTO rw_craplcm;
		EXIT WHEN cr_craplcm%NOTFOUND;
		-- Cursor de Linha de Credito
		OPEN cr_craplcr(pr_cdcooper => rw_craplcm.cdcooper
									 ,pr_cdlcremp => rw_craplcm.cdlcremp
									 );
		FETCH cr_craplcr INTO rw_craplcr;
		-- Se nao encontrou
		IF cr_craplcr%NOTFOUND THEN
			-- Fechar Cursor
			CLOSE cr_craplcr;
		ELSE
			-- Fechar Cursor
			CLOSE cr_craplcr;
			-- Operacao
			vr_floperac:= rw_craplcr.dsoperac = 'FINANCIAMENTO';
		END IF;

		-- Financiamento
		IF vr_floperac THEN
			vr_pag_nrdolote:= 600013;
			vr_des_nrdolote:= 600017;
			vr_des_cdhistor:= 1049;
			vr_lcm_nrdolote:= 600015;
		ELSE -- Emprestimo
			vr_pag_nrdolote:= 600012;
			vr_des_nrdolote:= 600016;
			vr_des_cdhistor:= 1048;
			vr_lcm_nrdolote:= 600014;
		END IF;
		-- Financiamento OU Emprestimo
    vr_pag_cdhistor:= CASE vr_floperac WHEN TRUE THEN 1039 ELSE 1044 END;
		--
		--dbms_output.put_line(rw_crapdat.dtmvtolt || ' ' || rw_craplcm.cdcooper || ' ' || rw_craplcm.nrdconta || ' ' || rw_craplcm.nrctremp || ' ' || vr_des_cdhistor || ' ' || (rw_craplcm.vlpreemp - rw_craplcm.vllanmto));
		-- Lancamento de Desconto da Parcela e atualiza o seu lote
		empr0001.pc_cria_lancamento_lem(pr_cdcooper => rw_craplcm.cdcooper   -- Codigo Cooperativa
																	 ,pr_dtmvtolt => rw_crapdat.dtmvtolt   -- Data Emprestimo
																	 ,pr_cdagenci => 90                    -- Codigo Agencia
																	 ,pr_cdbccxlt => 100                   -- Codigo Caixa
																	 ,pr_cdoperad => '1'                   -- Operador
																	 ,pr_cdpactra => 90                    -- Posto Atendimento
																	 ,pr_tplotmov => 5                     -- Tipo movimento
																	 ,pr_nrdolote => vr_des_nrdolote       -- Numero Lote
																	 ,pr_nrdconta => rw_craplcm.nrdconta   -- Numero da Conta
																	 ,pr_cdhistor => vr_des_cdhistor       -- Codigo Historico
																	 ,pr_nrctremp => rw_craplcm.nrctremp   -- Numero Contrato
																	 ,pr_vllanmto => (rw_craplcm.vlpreemp - 
																	 								  rw_craplcm.vllanmto) -- Valor Lancamento
																	 ,pr_dtpagemp => rw_crapdat.dtmvtolt   -- Data Pagamento Emprestimo
																	 ,pr_txjurepr => rw_craplcm.txjuremp   -- Taxa Juros Emprestimo
																	 ,pr_vlpreemp => rw_craplcm.vlparepr   -- Valor Emprestimo
																	 ,pr_nrsequni => 0                     -- Numero Sequencia
																	 ,pr_nrparepr => rw_craplcm.nrparepr   -- Numero Parcelas Emprestimo
																	 ,pr_flgincre => TRUE                  -- Indicador Credito
																	 ,pr_flgcredi => TRUE                  -- Credito
																	 ,pr_nrseqava => 0                     -- Pagamento: Sequencia do avalista
																	 ,pr_cdorigem => 3
																	 ,pr_cdcritic => vr_cdcritic           -- Codigo Erro
																	 ,pr_dscritic => vr_dscritic           -- Descricao Erro
																	 );

		--dbms_output.put_line(rw_crapdat.dtmvtolt || ' ' || rw_craplcm.cdcooper || ' ' || rw_craplcm.nrdconta || ' ' || rw_craplcm.nrctremp || ' ' || vr_pag_cdhistor || ' ' || rw_craplcm.vllanmto);
		-- Lancamento de Valor Pago da Parcela e atualiza o seu lote
		empr0001.pc_cria_lancamento_lem(pr_cdcooper => rw_craplcm.cdcooper -- Codigo Cooperativa
																	 ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data Emprestimo
																	 ,pr_cdagenci => 90                  -- Codigo Agencia
																	 ,pr_cdbccxlt => 100                 -- Codigo Caixa
																	 ,pr_cdoperad => '1'                 -- Operador
																	 ,pr_cdpactra => 90                  -- Posto Atendimento
																	 ,pr_tplotmov => 5                   -- Tipo movimento
																	 ,pr_nrdolote => vr_pag_nrdolote     -- Numero Lote
																	 ,pr_nrdconta => rw_craplcm.nrdconta -- Numero da Conta
																	 ,pr_cdhistor => vr_pag_cdhistor     -- Codigo Historico
																	 ,pr_nrctremp => rw_craplcm.nrctremp -- Numero Contrato
																	 ,pr_vllanmto => rw_craplcm.vllanmto -- Valor Lancamento
																	 ,pr_dtpagemp => rw_crapdat.dtmvtolt -- Data Pagamento Emprestimo
																	 ,pr_txjurepr => rw_craplcm.txjuremp -- Taxa Juros Emprestimo
																	 ,pr_vlpreemp => rw_craplcm.vlparepr -- Valor Emprestimo
																	 ,pr_nrsequni => rw_craplcm.nrparepr -- Numero Sequencia
																	 ,pr_nrparepr => rw_craplcm.nrparepr -- Numero Parcelas Emprestimo
																	 ,pr_flgincre => TRUE                -- Indicador Credito
																	 ,pr_flgcredi => TRUE                -- Credito
																	 ,pr_nrseqava => 0                   -- Pagamento: Sequencia do avalista
																	 ,pr_cdorigem => 3
																	 ,pr_cdcritic => vr_cdcritic         -- Codigo Erro
																	 ,pr_dscritic => vr_dscritic         -- Descricao Erro
																	 );
	END LOOP;
	--
	CLOSE cr_craplcm;
  --
	COMMIT;
	--
END;
