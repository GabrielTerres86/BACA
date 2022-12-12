BEGIN

  UPDATE cecred.crawepr w
     SET w.vliofepr = 68.74
   WHERE w.nrdconta = 1019570
     AND w.nrctremp = 422463
     AND w.cdcooper = 2;

  UPDATE cecred.crapepr epr
     SET epr.vliofepr = 68.74,
         epr.vltariof = 68.74
   WHERE epr.nrdconta = 1019570
     AND epr.nrctremp = 422463
     AND epr.cdcooper = 2;


  COMMIT;

EXCEPTION
  
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;
