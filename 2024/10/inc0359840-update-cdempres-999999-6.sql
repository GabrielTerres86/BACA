DECLARE

BEGIN

  UPDATE cecred.crapepr epr
     SET epr.cdempres = 999999
   WHERE epr.tpemprst = 1
     AND epr.tpdescto = 2
     AND epr.cdempres = 9999
     AND (epr.cdcooper, epr.nrdconta, epr.nrctremp) IN
         ((1, 6284620, 7112950),
          (1, 10034234, 8217939),
          (1, 10034234, 8410277),
          (1, 12009008, 8205035),
          (1, 13407813, 6546199),
          (1, 15886441, 7128443),
          (1, 15886441, 7369201),
          (1, 19167091, 8426025),
          (7, 14085909, 129484),
          (7, 14085909, 132151),
          (7, 15081516, 94243),
          (7, 16792270, 106498),
          (7, 17005930, 110546),
          (7, 17005930, 124283),
          (14, 195065, 43146));

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;
