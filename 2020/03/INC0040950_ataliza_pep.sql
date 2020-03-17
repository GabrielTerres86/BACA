BEGIN
  UPDATE crappep
    SET inliquid = 1
      , vlmrapar = 0
      , vlsdvpar = 0      
      , vlsdvatu = 0
      , vlsdvsji = 0
      , vljura60 = 0
      , vlmtapar = 0
      , vlpagpar = vlparepr
  WHERE cdcooper = 1
    AND nrdconta = 6960839
    AND nrctremp = 1463557
    AND nrparepr = 8;
  COMMIT;
END;
