BEGIN
  UPDATE CECRED.crappep
     SET inliquid = 1,        
         vlsdvpar = 0,
         vlsdvatu = 0,
         vlpagpar = 0,		 
         dtultpag = to_date('14/08/2023','DD/MM/YYYY')
   WHERE cdcooper = 1
     AND nrdconta = 7053100
     AND nrctremp = 7265483
     AND inliquid = 0;

  UPDATE CECRED.crappep
     SET inliquid = 1,        
         vlsdvpar = 0,
         vlsdvatu = 0,
         vlpagpar = 0,		 
         dtultpag = to_date('14/08/2023','DD/MM/YYYY')
   WHERE cdcooper = 1
     AND nrdconta = 7577761
     AND nrctremp = 7181689
     AND inliquid = 0;

  UPDATE CECRED.crappep
     SET inliquid = 1,        
         vlsdvpar = 0,
         vlsdvatu = 0,
         vlpagpar = 0,		 
         dtultpag = to_date('14/08/2023','DD/MM/YYYY')
   WHERE cdcooper = 1
     AND nrdconta = 8427780
     AND nrctremp = 7238081
     AND inliquid = 0;
  
  UPDATE CECRED.crapepr
     SET inliquid = 1,
         vlsdeved = 0,
         vlsdevat = 0,
		   vlsprojt = 0,
		   dtliquid = to_date('14/08/2023', 'DD/MM/YYYY')
   WHERE cdcooper = 1
     AND nrdconta = 7053100
     AND nrctremp = 7265483
     AND inliquid = 0;

  UPDATE CECRED.crapepr
     SET inliquid = 1,
         vlsdeved = 0,
         vlsdevat = 0,
		   vlsprojt = 0,
		   dtliquid = to_date('14/08/2023', 'DD/MM/YYYY')
   WHERE cdcooper = 1
     AND nrdconta = 7577761
     AND nrctremp = 7181689
     AND inliquid = 0;

  UPDATE CECRED.crapepr
     SET inliquid = 1,
         vlsdeved = 0,
         vlsdevat = 0,
		   vlsprojt = 0,
		   dtliquid = to_date('14/08/2023', 'DD/MM/YYYY')
   WHERE cdcooper = 1
     AND nrdconta = 8427780
     AND nrctremp = 7238081
     AND inliquid = 0;      
 
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20500, SQLERRM);
    ROLLBACK;
END;