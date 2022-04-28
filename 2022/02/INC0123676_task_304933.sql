DECLARE

BEGIN
  UPDATE crappep
     SET vlpagpar = 126.89,
         inliquid = 1
   WHERE cdcooper = 1
     AND nrdconta = 12701904
     AND nrctremp = 4198336
     AND nrparepr = 3;
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20500, SQLERRM);
    ROLLBACK;
END;