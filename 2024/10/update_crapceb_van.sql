BEGIN
  UPDATE CECRED.CRAPCEB SET
  FLGVAN = 1
  WHERE CDCOOPER = 9
  AND NRDCONTA = 81792719;
  
  COMMIT;
END;