DECLARE
  vr_cdcooper CONSTANT NUMBER := 7;
  vr_nrdconta CONSTANT NUMBER := 99884089;
  
BEGIN
  
  UPDATE craplcm t
     SET t.dtmvtolt = to_date('30/09/2024','dd/mm/yyyy')
   WHERE t.cdcooper = vr_cdcooper 
     AND t.nrdconta = vr_nrdconta 
     AND t.dtmvtolt = to_date('27/09/2024','dd/mm/yyyy');
  
  COMMIT;
  
END;
