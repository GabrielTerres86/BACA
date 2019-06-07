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
  
  -- Criar motivos de exclusão de cargas de pre-aprovado legado por garantia
  INSERT INTO tbepr_motivo_nao_aprv(cdcooper
                                   ,nrdconta
                                   ,idcarga
                                   ,idmotivo
                                   ,tppessoa
                                   ,nrcpfcnpj_base
                                   ,dtbloqueio)
        SELECT cpa.cdcooper
              ,0
              ,cpa.iddcarga
              ,79
              ,cpa.tppessoa
              ,cpa.nrcpfcnpj_base
              ,SYSDATE
        FROM crapcpa cpa
        WHERE cpa.nrdconta > 0
          AND cpa.cdsituacao IS NULL
          AND EXISTS (SELECT 1
                      FROM tbepr_carga_pre_aprv aprv
                      WHERE aprv.idcarga = cpa.iddcarga
                        AND aprv.cdcooper = cpa.cdcooper);
  
  -- Atualizar CPA das cargas antigas
  UPDATE crapcpa cpa
    SET cpa.dtbloqueio = SYSDATE
       ,cpa.cdoperad_bloque = 1
       ,cpa.cdsituacao = 'B'
  WHERE cpa.nrdconta > 0
    AND cpa.cdsituacao IS NULL;
    
  COMMIT;
END;
