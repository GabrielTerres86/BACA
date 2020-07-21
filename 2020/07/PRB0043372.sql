BEGIN
  
  UPDATE crappep t
     SET inliquid = 1,
         vlsdvpar = 0,
         vlsdvatu = 0
   WHERE cdcooper = 1
     AND nrdconta = 1868624
     and nrctremp = 2155420
     and nrparepr = 48;

  UPDATE crappep
     SET vlparepr = 4137.19,
         vlsdvpar = 4137.19
   WHERE cdcooper = 1
     AND nrdconta = 1927337
     and nrctremp = 1941874
     and inliquid = 0;
     
  UPDATE crapepr 
     SET vlpreemp = 4137.19
   WHERE cdcooper = 1
     AND nrdconta = 1927337
     and nrctremp = 1941874;  
       
  COMMIT;
  
EXCEPTION
     WHEN OTHERS THEN
          rollback;
END;
