-- Created on 03/04/2020 by F0030248 - Rafael Cechet
-- Baca para transferir valores de crédito de cooperados-cartórios
-- para conta da Central 1.000.000-3, referente a boletos pagos em cartório
declare 
  -- Local variables here
  i integer;
	vr_dtmvtolt DATE;
	vr_cdcritic INTEGER;
	vr_dscritic VARCHAR2(1000);
begin
  -- Test statements here
  
	SELECT dtmvtolt INTO vr_dtmvtolt FROM crapdat WHERE cdcooper = 1;
	
	FOR rw IN (
		
		SELECT cdpesqbb, trim(SUBSTR(cdpesqbb, 45, 8)), 
					 ass.nrdconta, 
					 ass.nmprimtl, 
					 ass.nrcpfcgc,
					 ass.cdcooper, 
					 lcm.dtmvtolt, 
					 lcm.vllanmto,
					 (SELECT COUNT(1) FROM tbcobran_cartorio_protesto car WHERE car.nrcpf_cnpj = ass.nrcpfcgc) cartorio,
					 lcm.cdbccxlt,
					 lcm.nrdolote,
					 lcm.cdagenci,
					 lcm.nrdocmto
					 
			FROM craplcm lcm
					,crapass ass
		WHERE lcm.cdcooper = 1
			AND lcm.nrdconta = 850004
			AND lcm.dtmvtolt >= to_date('01/01/2020','DD/MM/RRRR')
			AND lcm.cdhistor = 539  
			AND ass.cdcooper (+) = 1
			AND ass.nrdconta (+) = trim(SUBSTR(cdpesqbb, 45, 8))
			AND ass.nrcpfcgc <> 82639451000138
			AND ass.nrcpfcgc IN (54901537920,68722770925)
		) LOOP 
		
      cobr0011.pc_transfere_cartorio_coop(pr_cdcooper => rw.cdcooper
                                          ,pr_dtmvtolt => vr_dtmvtolt
                                          ,pr_dtmvtocd => vr_dtmvtolt
                                          ,pr_cdagenci => rw.cdagenci
                                          ,pr_cdbccxlt => rw.cdbccxlt
                                          ,pr_nrdolote => rw.nrdolote
                                          ,pr_nrdcaixa => 900
                                          ,pr_nrdconta => rw.nrdconta
                                          ,pr_idseqttl => 0
                                          ,pr_nrdocmto => rw.nrdocmto
                                          ,pr_cdhiscre => cobr0011.vr_trfprotestocre
                                          ,pr_cdhisdeb => cobr0011.vr_trfprotestodeb
                                          ,pr_vllanmto => rw.vllanmto
                                          ,pr_cdoperad => '1'
                                          ,pr_nrctatrf => rw.nrdconta
                                          ,pr_flagenda => 0
                                          ,pr_cdcoptfn => 0 -- pr_cdcoptfn
                                          ,pr_cdagetfn => 0 -- pr_cdagetfn
                                          ,pr_nrterfin => 0 -- pr_nrterfin
                                          ,pr_cdorigem => 3 -- pr_cdorigem
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);


      IF nvl(vr_cdcritic,0) <> 0 OR trim(vr_dscritic) IS NOT NULL THEN
		dbms_output.put_line(vr_cdcritic || ' - ' || vr_dscritic);
      END IF;
			 
  END LOOP;
  
  commit;
	
end;