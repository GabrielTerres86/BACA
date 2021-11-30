declare 
  vr_cdcooper crapcop.cdcooper%TYPE := 1;
  vr_nrdconta crapass.nrdconta%TYPE := 9963057;
  
BEGIN
  DELETE FROM crapsim sim
   WHERE sim.cdcooper = vr_cdcooper
     AND sim.nrdconta = vr_nrdconta
     AND sim.dtmvtolt < to_date('01/09/2021','dd/mm/rrrr')
     AND NOT EXISTS ( SELECT 1
                        FROM crawepr wpr
                       WHERE wpr.cdcooper = sim.cdcooper
                         AND wpr.nrdconta = sim.nrdconta
                         AND wpr.nrsimula = sim.nrsimula );

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
end;