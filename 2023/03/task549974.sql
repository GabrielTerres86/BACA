DECLARE

BEGIN

  UPDATE cecred.crappep pep
     SET pep.vlparepr = 839.96
        ,pep.vlsdvpar = 839.96
        ,pep.vlsdvsji = 839.96
   WHERE pep.nrdconta = 16100158
     AND pep.nrctremp = 307918
     AND pep.cdcooper = 11;

  UPDATE cecred.crawepr w
     SET w.vlpreemp = 839.96
        ,w.vlpreori = 839.96
        ,w.vliofepr = 1549.92
        ,w.txminima = 1.35
        ,w.txbaspre = 1.35
        ,w.txmensal = 1.35
        ,w.txorigin = 1.35
   WHERE w.nrdconta = 16100158
     AND w.nrctremp = 307918
     AND w.cdcooper = 11;

  UPDATE cecred.crapepr epr
     SET epr.vlpreemp = 839.96
        ,epr.vliofepr = 1549.92
        ,epr.vltariof = 1549.92
        ,epr.txmensal = 1.35
   WHERE epr.nrdconta = 16100158
     AND epr.nrctremp = 307918
     AND epr.cdcooper = 11;

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
  
    ROLLBACK;
  
END;
