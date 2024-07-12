DECLARE
  vr_dscritic VARCHAR2(4000);
begin
 
  gestaoderisco.gerarCargaScore(pr_idscore => 601,
                                pr_dscritic => vr_dscritic);
 
  IF vr_dscritic IS NOT NULL THEN
    RAISE_application_error(-20500,vr_dscritic);
  END IF;                                   
end;