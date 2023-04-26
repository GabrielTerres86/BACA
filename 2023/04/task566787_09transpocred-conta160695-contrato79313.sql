BEGIN
  UPDATE cecred.crappep pep
     SET pep.vlparepr = 694.37
        ,pep.vlsdvpar = 694.37
        ,pep.vlsdvsji = 694.37
   WHERE pep.nrdconta = 160695
     AND pep.nrctremp = 79313
     AND pep.cdcooper = 9;

  UPDATE cecred.crawepr w
     SET w.vlpreemp = 694.37
        ,w.vlpreori = 694.37
        ,w.vliofepr = 524.18
   WHERE w.nrdconta = 160695
     AND w.nrctremp = 79313
     AND w.cdcooper = 9;

  UPDATE cecred.crapepr epr
     SET epr.vlpreemp = 694.37
        ,epr.vliofepr = 524.18
        ,epr.vltariof = 524.18
   WHERE epr.nrdconta = 160695
     AND epr.nrctremp = 79313
     AND epr.cdcooper = 9;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
