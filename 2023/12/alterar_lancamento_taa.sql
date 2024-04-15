BEGIN
  UPDATE cecred.craplcm a
     SET a.dtmvtolt = to_date('19/01/2023', 'dd/mm/yyyy')
        ,a.nrsequni = 140361
        ,a.vllanmto = 10
  
   WHERE a.cdcooper = 9
     AND a.nrdconta = 82665451
     AND a.dtmvtolt = to_date('15/04/2024', 'dd/mm/yyyy')
     AND a.cdhistor = 316
     AND a.nrsequni = 140367;

  COMMIT;

END;
