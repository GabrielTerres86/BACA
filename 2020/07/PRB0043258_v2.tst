PL/SQL Developer Test script 3.0
88
declare
vr_cdcritic number;
vr_dscritic varchar2(4000);
begin
  -- Call the procedure
  cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => 5,
                                         pr_dtmvtolt => to_date('02/07/2020','dd/mm/yyyy'),
                                         pr_cdagenci => 1,
                                         pr_cdbccxlt => 100,
                                         pr_cdoperad => 1,
                                         pr_cdpactra => 1,
                                         pr_tplotmov => 5,
                                         pr_nrdolote => 600031,
                                         pr_nrdconta => 163031,
                                         pr_cdhistor => 3272,
                                         pr_nrctremp => 15811,
                                         pr_vllanmto => 13445.76,
                                         pr_dtpagemp => to_date('02/07/2020','dd/mm/yyyy'),
                                         pr_txjurepr => 0.0836442,
                                         pr_vlpreemp => 319.05,
                                         pr_nrsequni => 0,
                                         pr_nrparepr => 0,
                                         pr_flgincre => true,
                                         pr_flgcredi => true,
                                         pr_nrseqava => 0,
                                         pr_cdorigem => 7,
                                         pr_cdcritic => vr_cdcritic,
                                         pr_dscritic => vr_dscritic);

   -- Call the procedure
  cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => 13,
                                         pr_dtmvtolt => to_date('02/07/2020','dd/mm/yyyy'),
                                         pr_cdagenci => 1,
                                         pr_cdbccxlt => 100,
                                         pr_cdoperad => 1,
                                         pr_cdpactra => 1,
                                         pr_tplotmov => 5,
                                         pr_nrdolote => 600031,
                                         pr_nrdconta => 131822,
                                         pr_cdhistor => 3272,
                                         pr_nrctremp => 54110,
                                         pr_vllanmto => 305.65,
                                         pr_dtpagemp => to_date('02/07/2020','dd/mm/yyyy'),
                                         pr_txjurepr => 0.0820171,
                                         pr_vlpreemp => 299.67,
                                         pr_nrsequni => 0,
                                         pr_nrparepr => 0,
                                         pr_flgincre => true,
                                         pr_flgcredi => true,
                                         pr_nrseqava => 0,
                                         pr_cdorigem => 7,
                                         pr_cdcritic => vr_cdcritic,
                                         pr_dscritic => vr_dscritic);
                                         
   -- Call the procedure
  cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => 13,
                                         pr_dtmvtolt => to_date('02/07/2020','dd/mm/yyyy'),
                                         pr_cdagenci => 1,
                                         pr_cdbccxlt => 100,
                                         pr_cdoperad => 1,
                                         pr_cdpactra => 1,
                                         pr_tplotmov => 5,
                                         pr_nrdolote => 600031,
                                         pr_nrdconta => 191736,
                                         pr_cdhistor => 3272,
                                         pr_nrctremp => 57756,
                                         pr_vllanmto => 36665.67,
                                         pr_dtpagemp => to_date('02/07/2020','dd/mm/yyyy'),
                                         pr_txjurepr => 0.0496410,
                                         pr_vlpreemp => 852.96,
                                         pr_nrsequni => 0,
                                         pr_nrparepr => 0,
                                         pr_flgincre => true,
                                         pr_flgcredi => true,
                                         pr_nrseqava => 0,
                                         pr_cdorigem => 7,
                                         pr_cdcritic => vr_cdcritic,
                                         pr_dscritic => vr_dscritic);
                                         
                                                                                                                      
                                                                                    
  commit;
  exception when others then      
    rollback;                                    
    dbms_output.put_line(vr_dscritic);
    cecred.pc_internal_exception(pr_compleme => vr_cdcritic || ': ' ||
                                                    vr_dscritic);
end;
0
0
