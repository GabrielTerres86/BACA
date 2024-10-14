DECLARE

BEGIN

  UPDATE cecred.crapepr epr
     SET epr.cdempres = 9999
   WHERE epr.tpemprst = 1
     AND epr.tpdescto = 2
     AND epr.cdempres = 999999;

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;
