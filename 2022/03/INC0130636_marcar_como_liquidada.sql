DECLARE

BEGIN
  UPDATE crappep
     SET vlpagpar = 150.10,
         inliquid = 1
   WHERE cdcooper = 13
     AND nrdconta = 369845
     AND nrctremp = 99051
     AND nrparepr = 12;
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20500, SQLERRM);
    ROLLBACK;
END;