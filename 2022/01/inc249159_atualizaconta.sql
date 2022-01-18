BEGIN
  
  UPDATE crapsda 
  SET    vlsdbloq = -1
  WHERE  cdcooper = 1 
  AND    nrdconta = 11037 
  AND    dtmvtolt = '11/01/2022';
  
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
