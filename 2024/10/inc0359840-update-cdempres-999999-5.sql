DECLARE

BEGIN

  UPDATE cecred.crapepr epr
     SET epr.cdempres = 999999
   WHERE epr.tpemprst = 1
     AND epr.tpdescto = 2
     AND epr.cdempres = 9999
     AND (epr.cdcooper, epr.nrdconta, epr.nrctremp) IN
         ((1, 3004031, 3859328),
          (1, 3004031, 3990299),
          (1, 3004031, 6268139),
          (1, 7326327, 5933181),
          (10, 18185606, 58428),
          (13, 251771, 379617),
          (13, 19204450, 374595),
          (16, 196878, 703283),
          (16, 288594, 798185));

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;
