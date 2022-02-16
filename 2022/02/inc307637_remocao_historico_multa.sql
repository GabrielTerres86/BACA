BEGIN
  
  DELETE craplem 
  WHERE  cdcooper = 13 
  AND    nrdconta = 451509 
  AND    nrctremp = 72432 
  AND    dtmvtolt in (TO_DATE('17/09/2021','dd/mm/yyyy'),TO_DATE('22/10/2021','dd/mm/yyyy'))
  AND    cdhistor in (2365, 2349)
  AND    vllanmto  = 37.16;
  
  DELETE craplem 
  WHERE cdcooper = 16 
  AND   nrdconta = 350052 
  AND   nrctremp = 132801 
  AND   dtmvtolt in (TO_DATE('03/11/2021'),TO_DATE('02/12/2021','dd/mm/yyyy'))
  AND   cdhistor in (2365, 2349)
  AND   vllanmto  = 180.76; 
  
  DELETE craplem 
  WHERE cdcooper = 16 
  AND   nrdconta = 350052 
  AND   nrctremp = 132801 
  AND   dtmvtolt in (TO_DATE('06/01/2022','dd/mm/yyyy'))
  AND   cdhistor in (2365, 2349)
  AND   vllanmto  = 192.56;
  
  DELETE craplem 
  WHERE cdcooper = 5 
  AND   nrdconta = 127744 
  AND   nrctremp = 14792 
  AND   cdhistor in (2365, 2349)
  AND   ( (dtmvtolt = TO_DATE('19/10/2021','dd/mm/yyyy') and vllanmto  = 45.39) OR
          (dtmvtolt = TO_DATE('18/11/2021','dd/mm/yyyy') and vllanmto  = 46.84) OR
          (dtmvtolt = TO_DATE('20/12/2021','dd/mm/yyyy') and vllanmto  = 49.03));
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
