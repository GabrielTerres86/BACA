BEGIN

  UPDATE cecred.crawepr w
     SET w.vliofepr = 110.21
   WHERE w.nrdconta = 6702210
     AND w.nrctremp = 6324064
     AND w.cdcooper = 1;

  UPDATE cecred.crapepr epr
     SET epr.vliofepr = 110.21,
         epr.vltariof = 110.21
   WHERE epr.nrdconta = 6702210
     AND epr.nrctremp = 6324064
     AND epr.cdcooper = 1;  
     
  COMMIT;

EXCEPTION
  
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;
