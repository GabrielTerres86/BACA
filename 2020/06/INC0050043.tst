PL/SQL Developer Test script 3.0
35
declare
vr_cdcritic number;
vr_dscritic varchar2(4000);
begin
  -- Call the procedure
  cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => 1,
                                         pr_dtmvtolt => to_date('18/06/2020','dd/mm/yyyy'),
                                         pr_cdagenci => 1,
                                         pr_cdbccxlt => 100,
                                         pr_cdoperad => 1,
                                         pr_cdpactra => 1,
                                         pr_tplotmov => 5,
                                         pr_nrdolote => 600012,
                                         pr_nrdconta => 80146392,
                                         pr_cdhistor => 1044,
                                         pr_nrctremp => 1882025,
                                         pr_vllanmto => 47.40,
                                         pr_dtpagemp => to_date('18/06/2020','dd/mm/yyyy'),
                                         pr_txjurepr => 0.0529252,
                                         pr_vlpreemp => 760.95,
                                         pr_nrsequni => 11,
                                         pr_nrparepr => 11,
                                         pr_flgincre => true,
                                         pr_flgcredi => true,
                                         pr_nrseqava => 0,
                                         pr_cdorigem => 5,
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
