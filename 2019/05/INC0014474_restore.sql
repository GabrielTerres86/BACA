BEGIN 
  UPDATE crapepr 
     SET inliquid = 0
   WHERE crapepr.cdcooper = 1 
     AND crapepr.nrdconta = 2372827 
     AND crapepr.nrctremp = 703755;
  COMMIT;   
END;