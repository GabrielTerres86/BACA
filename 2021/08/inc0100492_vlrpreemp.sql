BEGIN
  UPDATE crapepr r
  SET    r.vlpreemp = 1785.46
  WHERE  r.cdcooper = 1
  AND    r.nrdconta = 10612084
  AND    r.nrctremp = 4020784;
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
