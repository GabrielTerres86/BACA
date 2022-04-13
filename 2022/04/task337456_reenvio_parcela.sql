DECLARE
  vr_xml_parcela VARCHAR2(1000);
  vr_motenvio    VARCHAR2(50);
  vr_dsxmlali    XMLType;
  vr_dscritic    VARCHAR2(4000);
  vr_idevento    tbgen_evento_soa.idevento%TYPE;
  vr_tipo_pagto  VARCHAR2(500);
  vr_exc_saida EXCEPTION;
  
  CURSOR cr_contas IS
	SELECT 5 AS cdcooper
		  ,REGEXP_SUBSTR('884,34371,2259,6742,36285,41432,27243,9636,8214,36200,21997,57908,62782,3700,49662,141372,153826,163597,73717,270113,31070','[^,]+',1,LEVEL) AS nrdconta
		  ,REGEXP_SUBSTR('24536,17890,15256,26288,29058,15601,25283,28411,17228,28417,24455,21011,21358,25233,21947,27934,25877,23601,30177,29401,27398', '[^,]+', 1, LEVEL) AS nrctremp
		  ,'2022-04-11' AS dtmvtolt
		  ,REGEXP_SUBSTR('20,25,28,19,18,28,20,18,26,18,20,22,22,20,21,18,19,21,17,17,19', '[^,]+', 1, LEVEL) AS nrparepr1
		  ,REGEXP_SUBSTR('20,25,28,19,18,28,20,18,26,18,20,22,22,20,21,18,19,21,17,17,19', '[^,]+', 1, LEVEL) AS nrparepr2
	  FROM   DUAL
	  CONNECT BY REGEXP_SUBSTR('1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,','[^,]+',1,LEVEL) IS NOT NULL;
  rw_contas cr_contas%ROWTYPE;

  CURSOR cr_craplcm (pr_cdcooper NUMBER,
					 pr_nrdconta NUMBER,
					 pr_nrctremp NUMBER,
					 pr_nrparepr1 NUMBER,
					 pr_nrparepr2 NUMBER) IS
    SELECT b.dtvencto
          ,b.vlpagpar
          ,b.nrdconta
          ,b.nrctremp
          ,b.cdcooper
          ,b.nrparepr
          ,b.dtmvtolt
          ,MIN(b.idsequencia) idsequencia
      FROM tbepr_consignado_pagamento b
          ,(SELECT cdcooper
                  ,nrdconta
                  ,nrctremp
                  ,nrparepr
              FROM crappep
             WHERE (cdcooper, nrdconta, nrctremp) IN
                   ((pr_cdcooper, pr_nrdconta, pr_nrctremp))
				   AND nrparepr BETWEEN pr_nrparepr1 AND pr_nrparepr2
               AND inliquid = 0) pep
     WHERE pep.nrdconta = b.nrdconta
       AND pep.nrctremp = b.nrctremp
       AND pep.cdcooper = b.cdcooper
       AND pep.nrparepr = b.nrparepr
       AND b.instatus <> 2
     GROUP BY b.dtvencto
             ,b.vlpagpar
             ,b.nrdconta
             ,b.nrctremp
             ,b.cdcooper
             ,b.nrparepr
             ,b.dtmvtolt 
     ORDER BY b.cdcooper
             ,b.nrdconta
             ,b.nrctremp
             ,b.nrparepr;
  rw_craplcm cr_craplcm%ROWTYPE;
BEGIN
  FOR rw_contas in cr_contas LOOP
	  FOR rw_craplcm IN cr_craplcm ( pr_cdcooper => rw_contas.cdcooper,
									 pr_nrdconta => rw_contas.nrdconta,
									 pr_nrctremp => rw_contas.nrctremp,
									 pr_nrparepr1 => rw_contas.nrparepr1,
									 pr_nrparepr2 => rw_contas.nrparepr2) LOOP
		vr_motenvio    := 'REENVIARPAGTO';
		vr_tipo_pagto  := ' <valor>' || TRIM(to_char(rw_craplcm.vlpagpar, '999999990.00')) || '</valor>';
		vr_xml_parcela := ' <parcela>
							  <dataEfetivacao>' || rw_contas.dtmvtolt || 'T' || to_char(SYSDATE, 'hh24:mi:ss') || '</dataEfetivacao>
							  <dataVencimento>' || to_char(rw_craplcm.dtvencto, 'yyyy-mm-dd') || '</dataVencimento>
							  <identificador>' || rw_craplcm.idsequencia || '</identificador>' || vr_tipo_pagto || 
						  '</parcela>';
	  
		CECRED.EMPR0020.pc_gera_xml_pagamento_consig(pr_cdcooper     => rw_craplcm.cdcooper,
													 pr_nrdconta     => rw_craplcm.nrdconta,
													 pr_nrctremp     => rw_craplcm.nrctremp,
													 pr_xml_parcelas => vr_xml_parcela, 
													 pr_tpenvio      => 1, 
													 pr_tptransa     => 'DEBITO', 
													 pr_motenvio     => vr_motenvio,
													 pr_dsxmlali     => vr_dsxmlali,
													 pr_dscritic     => vr_dscritic);
	  
		IF vr_dscritic IS NOT NULL THEN
		  RAISE vr_exc_saida;
		END IF;
	  
		soap0003.pc_gerar_evento_soa(pr_cdcooper              => rw_craplcm.cdcooper,
									 pr_nrdconta              => rw_craplcm.nrdconta,
									 pr_nrctrprp              => rw_craplcm.nrctremp,
									 pr_tpevento              => 'PAGTO_PAGAR',
									 pr_tproduto_evento       => 'CONSIGNADO',
									 pr_tpoperacao            => 'INSERT',
									 pr_dsconteudo_requisicao => vr_dsxmlali.getClobVal(),
									 pr_idevento              => vr_idevento,
									 pr_dscritic              => vr_dscritic);
	  END LOOP;
  END LOOP;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
	RAISE_APPLICATION_ERROR(-20500, SQLERRM);
    ROLLBACK;
END;
