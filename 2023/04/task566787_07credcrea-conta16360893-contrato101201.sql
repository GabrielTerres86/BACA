BEGIN
  UPDATE cecred.crawepr w
     SET w.vliofepr = 322.67
   WHERE w.nrdconta = 16360893
     AND w.nrctremp = 101201
     AND w.cdcooper = 7;

  UPDATE cecred.crapepr epr
     SET epr.vliofepr = 322.67
        ,epr.vltariof = 322.67
   WHERE epr.nrdconta = 16360893
     AND epr.nrctremp = 101201
     AND epr.cdcooper = 7;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
