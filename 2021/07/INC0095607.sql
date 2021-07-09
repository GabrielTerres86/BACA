BEGIN
  UPDATE crappep
     SET inliquid = 1
        ,vlmrapar = 0
        ,vlsdvpar = 0
        ,vlsdvatu = 0
        ,vlsdvsji = 0
        ,vljura60 = 0
        ,vlmtapar = 0
        ,vlpagpar = 2069.62
  WHERE cdcooper = 16
    AND nrdconta = 547735
    AND nrctremp = 166231
    AND nrparepr = 117;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
