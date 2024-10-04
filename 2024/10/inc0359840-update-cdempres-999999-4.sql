DECLARE

BEGIN

  UPDATE cecred.crapepr epr
     SET epr.cdempres = 999999
   WHERE epr.tpemprst = 1
     AND epr.tpdescto = 2
     AND epr.cdempres = 9999
     AND (epr.cdcooper, epr.nrdconta, epr.nrctremp) in ((5, 16242459, 100840), (10, 80772, 25808));

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;
