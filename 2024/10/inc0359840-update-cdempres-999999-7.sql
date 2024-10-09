DECLARE

BEGIN

  UPDATE cecred.crapepr epr
     SET epr.cdempres = 999999
   WHERE epr.tpemprst = 1
     AND epr.tpdescto = 2
     AND epr.cdempres = 9999
     AND (epr.cdcooper, epr.nrdconta, epr.nrctremp) in
         ((1, 13196979, 6860207),
          (1, 16380312, 7871834),
          (1, 18565727, 8256974),
          (2, 1098470, 496365),
          (6, 72192, 272745),
          (13, 548251, 370501));

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;
