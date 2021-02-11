PL/SQL Developer Test script 3.0
36
declare
vr_cdcritic number;
vr_dscritic varchar2(4000);
begin
  -- Call the procedure
  cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => 13,
                                         pr_dtmvtolt => to_date('26/11/2020','dd/mm/yyyy'),
                                         pr_cdagenci => 1,
                                         pr_cdbccxlt => 100,
                                         pr_cdoperad => 1,
                                         pr_cdpactra => 1,
                                         pr_tplotmov => 5,
                                         pr_nrdolote => 600031,
                                         pr_nrdconta => 163830,
                                         pr_cdhistor => 3272,
                                         pr_nrctremp => 51946,
                                         pr_vllanmto => 2872.43,
                                         pr_dtpagemp => to_date('26/11/2020','dd/mm/yyyy'),
                                         pr_txjurepr => 0.0496410,
                                         pr_vlpreemp => 78.91,
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
