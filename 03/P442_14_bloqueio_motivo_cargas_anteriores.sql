-- Script para ajustar cargas anteriores a liberação bloqueando e exibindo o motivo de bloqueio
BEGIN
  -- Incluir registros de bloqueio manual
  INSERT INTO tbcc_hist_param_pessoa_prod(cdcooper
                                       ,nrdconta
                                       ,tppessoa
                                       ,nrcpfcnpj_base
                                       ,dtoperac
                                       ,cdproduto
                                       ,cdoperac_produto
                                       ,flglibera
                                       ,idmotivo
                                       ,cdoperad)
		  SELECT apr.cdcooper
				,apr.nrdconta
				,ass.inpessoa
				,ass.nrcpfcnpj_base
				,apr.dtatualiza_pre_aprv
				,25
				,1
				,0
				,79
				,1
		  FROM tbepr_param_conta apr
			  ,crapass ass
		  WHERE apr.idmotivo IS NULL
			AND apr.flglibera_pre_aprv = 0
			AND ass.cdcooper = apr.cdcooper
			AND ass.nrdconta = apr.nrdconta;

  COMMIT;
END;
