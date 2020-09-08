BEGIN

  UPDATE crapepr t
    SET vlsprojt = vlsprojt - 1630
  WHERE t.cdcooper = 1
    AND t.nrdconta = 9171525 
	AND t.nrctremp = 2438098;

  UPDATE crappep t
    SET inliquid = 1
      , vlmrapar = 0
      , vlsdvpar = 0
      , vlsdvatu = 0
      , vlsdvsji = 0
      , vljura60 = 0
      , vlmtapar = 0
      , vlpagpar = vlparepr
  WHERE t.cdcooper = 1
    AND t.nrdconta = 9171525 
	AND t.nrctremp = 2438098
    AND t.nrparepr = 1;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
