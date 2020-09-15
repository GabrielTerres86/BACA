declare
vr_dtmvtolt crapdat.dtmvtolt%TYPE;
vr_cdcooper crawepr.cdcooper%TYPE;
vr_nrdconta crawepr.nrdconta%TYPE;
vr_nrctremp crawepr.nrctremp%TYPE;
vr_dscritic crapcri.dscritic%TYPE;
vr_cdcritic crapcri.cdcritic%TYPE;
vr_dsmensag varchar2(2000);

begin
  --Parametros
  vr_cdcooper := 1;
  vr_nrdconta := 10827056;
  vr_nrctremp := 2960176;
  
  -- Busca a data atual
  select dtmvtolt into vr_dtmvtolt from crapdat where cdcooper = vr_cdcooper;

  -- Call the procedure
  cecred.este0001.pc_incluir_proposta_est(pr_cdcooper => vr_cdcooper,
                                          pr_cdagenci => 90,
                                          pr_cdoperad => 996,
                                          pr_cdorigem => 3,
                                          pr_nrdconta => vr_nrdconta,
                                          pr_nrctremp => vr_nrctremp,
                                          pr_dtmvtolt => vr_dtmvtolt,
                                          pr_nmarquiv => '',
                                          pr_dsmensag => vr_dsmensag,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);
                                          
  dbms_output.put_line('cdcritic: ' || vr_cdcritic);
  dbms_output.put_line('dscritic: ' || vr_dscritic);
  dbms_output.put_line('dsmensag: ' || vr_dsmensag);
                                            
end;

