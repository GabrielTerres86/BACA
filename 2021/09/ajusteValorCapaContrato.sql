BEGIN 
  UPDATE crapepr t 
  SET t.vlpreemp = 46624.43
  WHERE t.cdcooper = 3 
  AND t.nrdconta = 94
  AND t.nrctremp = 211409;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
   ROLLBACK;  
END;
