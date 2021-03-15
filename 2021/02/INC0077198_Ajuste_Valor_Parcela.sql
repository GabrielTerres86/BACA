BEGIN
  UPDATE crappep t
    SET inliquid = 1
      , vlmrapar = 0
      , vlsdvpar = 0
      , vlsdvatu = 0
      , vlsdvsji = 0
      , vljura60 = 0
      , vlmtapar = 0
  WHERE t.cdcooper = 2
    AND t.nrdconta = 379999 
  AND t.nrctremp = 276957
    AND t.nrparepr = 120;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
