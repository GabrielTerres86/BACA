BEGIN
  UPDATE cecred.crapepr
     SET dtliquid = to_date('27/05/2024', 'DD/MM/YYYY')
        ,inliquid = 1
        ,vlsdeved = 0
        ,vlsdevat = 0
   WHERE cdcooper = 3
         AND nrdconta = 86
         AND nrctremp = 211532;

  UPDATE cecred.crappep
     SET inliquid = 1
        ,vlsdvpar = 0
        ,vlsdvatu = 0
        ,vlpagpar = 178202.50
        ,dtultpag = to_date('27/05/2024', 'DD/MM/YYYY')
   WHERE cdcooper = 3
         AND nrdconta = 86
         AND nrctremp = 211532
         AND nrparepr = 11;

  UPDATE cecred.crappep
     SET inliquid = 1
        ,vlsdvpar = 0
        ,vlsdvatu = 0
        ,vlpagpar = 178202.50
        ,dtultpag = to_date('27/05/2024', 'DD/MM/YYYY')
   WHERE cdcooper = 3
         AND nrdconta = 86
         AND nrctremp = 211532
         AND nrparepr = 12;

  UPDATE cecred.crappep
     SET inliquid = 1
        ,vlsdvpar = 0
        ,vlsdvatu = 0
        ,vlpagpar = 513814.91
        ,dtultpag = to_date('27/05/2024', 'DD/MM/YYYY')
   WHERE cdcooper = 3
         AND nrdconta = 86
         AND nrctremp = 211532
         AND nrparepr = 13;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
