BEGIN
  UPDATE cecred.crapepr
     SET dtliquid = to_date('14/08/2023', 'DD/MM/YYYY'), inliquid = 1
   WHERE cdcooper = 1
         AND nrdconta = 8207690
         AND nrctremp = 2416667;

  UPDATE cecred.crappep
     SET inliquid = 1, vlsdvpar = 0, vlsdvatu = 0, vlpagpar = 60.95, dtultpag = to_date('14/08/2023','DD/MM/YYYY')
   WHERE cdcooper = 1
         AND nrdconta = 8207690
         AND nrctremp = 2416667
         AND nrparepr >= 18;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
