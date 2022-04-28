BEGIN
  UPDATE crapfdc f 
     SET f.incheque = 0,
         f.dtliqchq = NULL
  WHERE f.cdcooper = 9 AND f.nrdconta = 57193 AND f.nrcheque IN (448,449);

  DELETE FROM craplcm l 
   WHERE l.cdcooper = 9 
     AND l.nrdconta = 57193 
     AND l.dtmvtolt >= to_date('01/12/2021','dd/mm/yyyy') 
     AND l.nrdocmto IN (4480,4499);
COMMIT;
END;  
