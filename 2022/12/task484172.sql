BEGIN

  UPDATE cecred.crawepr w
     SET w.vliofepr = 46.43
   WHERE w.nrdconta = 15314472
     AND w.nrctremp = 43612
     AND w.cdcooper = 10;

  UPDATE cecred.crapepr epr
     SET epr.vliofepr = 46.43,
         epr.vltariof = 46.43
   WHERE epr.nrdconta = 15314472
     AND epr.nrctremp = 43612
     AND epr.cdcooper = 10;


  COMMIT;

EXCEPTION
  
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;
