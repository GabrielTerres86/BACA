BEGIN
  UPDATE cecred.crappep pep
     SET pep.vlparepr = 387.42
        ,pep.vlsdvpar = 387.42
        ,pep.vlsdvsji = 387.42
   WHERE pep.nrdconta = 9701133
     AND pep.nrctremp = 6706690
     AND pep.cdcooper = 1;

  UPDATE cecred.crawepr w
     SET w.vlpreemp = 387.42
        ,w.vlpreori = 387.42
        ,w.vliofepr = 163.86
   WHERE w.nrdconta = 9701133
     AND w.nrctremp = 6706690
     AND w.cdcooper = 1;

  UPDATE cecred.crapepr epr
     SET epr.vlpreemp = 387.42
        ,epr.vliofepr = 163.86
        ,epr.vltariof = 163.86
   WHERE epr.nrdconta = 9701133
     AND epr.nrctremp = 6706690
     AND epr.cdcooper = 1;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
