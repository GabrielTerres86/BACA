DECLARE

BEGIN

  UPDATE cecred.crapepr epr
     SET epr.cdempres = 999999
   WHERE epr.tpemprst = 1
     AND epr.tpdescto = 2
     AND epr.cdempres = 9999
     AND (epr.cdcooper, epr.nrdconta, epr.nrctremp) IN
         ((1, 8111383, 3805450),
          (1, 10034234, 8217939),
          (1, 10034234, 8410277),
          (1, 10034234, 8652629),
          (5, 274860, 79121),
          (7, 15105490, 107860),
          (10, 15373959, 47495),
          (13, 320447, 365097),
          (13, 664774, 286728),
          (13, 741108, 356333));

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;
