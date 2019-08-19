PL/SQL Developer Test script 3.0
52
declare 
  CURSOR cr_contas(pr_dtmvtolt DATE) IS
	SELECT cdcooper
	     , nrdconta
			 , vllanmto
	  FROM craplcm lcm
	 WHERE cdhistor IN (50,59,290,471,613,614,658,661,668)
	   AND dtmvtolt >= pr_dtmvtolt
		 AND EXISTS (SELECT 1
		               FROM tbcc_prejuizo
									WHERE cdcooper = lcm.cdcooper
									  AND nrdconta = lcm.nrdconta
										AND dtliquidacao IS NULL)
     AND NOT EXISTS (
           SELECT 1
             FROM craplcm aux
            WHERE aux.cdcooper = lcm.cdcooper
              AND aux.nrdconta = lcm.nrdconta
              AND aux.dtmvtolt = lcm.dtmvtolt
              AND aux.cdhistor = 662
              AND aux.vllanmto = lcm.vllanmto
         );
	rw_contas cr_contas%ROWTYPE;
	
	rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
	
	vr_dtmvtolt DATE := to_date('11/02/2019', 'DD/MM/YYYY'); -- ******* DATA DOS LANÇAMENTOS ******
	vr_cdcritic NUMBER;
	vr_dscritic VARCHAR(2000);
begin
  FOR rw_contas IN cr_contas(vr_dtmvtolt) LOOP
	  OPEN BTCH0001.cr_crapdat(rw_contas.cdcooper);
		FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
		CLOSE BTCH0001.cr_crapdat;
		
	  PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => rw_contas.cdcooper
		                                , pr_nrdconta => rw_contas.nrdconta
																		, pr_dtmvtolt => rw_crapdat.dtmvtolt
																		, pr_cdhistor => 2408
																		, pr_vllanmto => rw_contas.vllanmto
																		, pr_cdcritic => vr_cdcritic
																		, pr_dscritic => vr_dscritic);
																		
		UPDATE tbcc_prejuizo
		   SET vlsdprej = vlsdprej + rw_contas.vllanmto
		 WHERE cdcooper = rw_contas.cdcooper
		   AND nrdconta = rw_contas.nrdconta
			 AND dtliquidacao IS NULL;
  END LOOP;  
	
	COMMIT;
end;
0
0
