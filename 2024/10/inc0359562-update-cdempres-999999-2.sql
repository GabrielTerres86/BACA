DECLARE

BEGIN

  UPDATE cecred.crapepr epr
     SET epr.cdempres = 999999
   WHERE epr.tpemprst = 1
     AND epr.tpdescto = 2
     AND epr.cdempres = 9999
     AND (cdcooper, nrdconta, nrctremp) in
         ((1, 6612784, 7054629),
          (1, 10961062, 7688221),
          (1, 17446171, 7880422),
          (2, 1031481, 323479),
          (2, 1120824, 469408),
          (10, 16423780, 53602),
          (13, 94129, 365250),
          (13, 273309, 197758),
          (13, 15232344, 303082),
          (13, 16403274, 343590),
          (13, 16994132, 365938),
          (16, 15147045, 521779),
          (16, 18221408, 789244));

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;
