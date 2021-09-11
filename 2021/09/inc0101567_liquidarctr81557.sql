--INC0101567 liquidar parcelas de um contrato
BEGIN

  UPDATE crappep
     SET inliquid = 1,
         vlsdvpar = 0,
         vlsdvatu = 0,
         vlsdvsji = 0
   WHERE nrdconta = 558222
     AND nrctremp = 81557
     AND cdcooper = 11
     AND inliquid = 0
     AND nrparepr = 180;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
