DECLARE

BEGIN

  UPDATE cecred.crapepr epr
     SET epr.cdempres = 999999
   WHERE epr.tpemprst = 1
     AND epr.tpdescto = 2
     AND epr.cdempres = 9999
     AND (cdcooper, nrdconta, nrctremp) in ((1, 7011598, 7458013),
                                            (1, 19048327, 8366396),
                                            (2, 601470, 376735),
                                            (2, 16539540, 450619),
                                            (10, 121479, 50155));

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;
