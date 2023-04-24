BEGIN
  UPDATE cecred.crappep pep
     SET pep.vlparepr = 1019.34
        ,pep.vlsdvpar = 1019.34
        ,pep.vlsdvsji = 1019.34
   WHERE pep.nrdconta = 314226
     AND pep.nrctremp = 79049
     AND pep.cdcooper = 9;

  UPDATE cecred.crawepr w
     SET w.vlpreemp = 1019.34
        ,w.vlpreori = 1019.34
        ,w.vliofepr = 702.75
   WHERE w.nrdconta = 314226
     AND w.nrctremp = 79049
     AND w.cdcooper = 9;

  UPDATE cecred.crapepr epr
     SET epr.vlpreemp = 1019.34
        ,epr.vliofepr = 702.75
        ,epr.vltariof = 702.75
   WHERE epr.nrdconta = 314226
     AND epr.nrctremp = 79049
     AND epr.cdcooper = 9;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
