declare

  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);

begin
  GESTAODERISCO.geraCargaCentral(pr_cdcooper => 1
                                ,pr_flgcarta => TRUE
                                ,pr_dtrefere => '30/06/2024'
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
                                
   dbms_output.put_line('vr_cdcritic: ' || vr_cdcritic || ' = ' || vr_dscritic);
end;
