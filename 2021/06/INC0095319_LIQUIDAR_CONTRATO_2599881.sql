--INC0095319 liquidar parcelas de um contrato
BEGIN
  UPDATE crapepr
     SET inliquid = 1,
         vlsdeved = 0,
         vlsdevat = 0
   WHERE nrdconta = 8660948
     AND nrctremp = 2599881
     AND cdcooper = 1;

  UPDATE crappep
     SET inliquid = 1,
         vlsdvpar = 0,
         vlsdvatu = 0,
         vlsdvsji = 0
   WHERE nrdconta = 8660948
     AND nrctremp = 2599881
     AND cdcooper = 1
     AND inliquid = 0;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
