DECLARE

BEGIN

  UPDATE cecred.crapepr epr
     SET epr.cdempres = 103
   WHERE epr.cdcooper = 1
     AND epr.nrdconta = 10179569
     AND epr.nrctremp = 2967816;

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
  
    ROLLBACK;
  
END;
