declare

  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);

begin
  GESTAODERISCO.geraCargaCentral(pr_cdcooper => 1
                                ,pr_flgexddt => TRUE
                                ,pr_flgsaida => TRUE
                                ,pr_dtrefere => '30/09/2024'
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);

   IF nvl(vr_cdcritic,0) > 0 or TRIM(vr_dscritic) IS not NULL THEN
     dbms_output.put_line('vr_cdcritic: ' || vr_cdcritic || ' = ' || vr_dscritic);
     ROLLBACK;
   ELSE
     COMMIT;
   END IF;
end;
