BEGIN

  UPDATE cecred.crawcrd crd
     SET crd.nrcpftit = 3703997907
   WHERE crd.cdcooper = 9
     AND crd.nrdconta = 99999595
     AND crd.nrcrcard = 6393500000038738;

  UPDATE cecred.crapcrd crd
     SET crd.nrcpftit = 3703997907
   WHERE crd.cdcooper = 9
     AND crd.nrdconta = 99999595
     AND crd.nrcrcard = 6393500000038738;

  COMMIT;

END;
