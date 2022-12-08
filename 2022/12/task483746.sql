BEGIN

  UPDATE cecred.crawepr w
     SET w.vliofepr = 238.84
   WHERE w.nrdconta = 257141
     AND w.nrctremp = 251101
     AND w.cdcooper = 13;

  UPDATE cecred.crapepr epr
     SET epr.vliofepr = 238.84,
         epr.vltariof = 238.84
   WHERE epr.nrdconta = 257141
     AND epr.nrctremp = 251101
     AND epr.cdcooper = 13;
     
  COMMIT;

EXCEPTION
  
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;
