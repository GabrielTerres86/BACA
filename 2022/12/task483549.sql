BEGIN

  UPDATE cecred.crawepr w
     SET w.vliofepr = 276.47
   WHERE w.nrdconta = 15813070
     AND w.nrctremp = 423443
     AND w.cdcooper = 2;

  UPDATE cecred.crapepr epr
     SET epr.vliofepr = 276.47,
         epr.vltariof = 276.47
   WHERE epr.nrdconta = 15813070
     AND epr.nrctremp = 423443
     AND epr.cdcooper = 2;


  COMMIT;

EXCEPTION
  
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;
