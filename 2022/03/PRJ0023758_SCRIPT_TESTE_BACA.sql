BEGIN
  
  UPDATE CRAWCRD SET
  NRCRCARD = 5158940050030200,
  INSITCRD = 3
  WHERE CDCOOPER = 1
  AND NRDCONTA = 930
  AND NRCTRCRD = 2010153;
  
  UPDATE CRAPCRD SET
  NRCRCARD = 5158940050030200
  WHERE CDCOOPER = 1
  AND NRDCONTA = 930
  AND NRCTRCRD = 2010153;
  
  UPDATE CRAWCRD SET
  NRCRCARD = 5127070283056646,
  INSITCRD = 3
  WHERE CDCOOPER = 1
  AND NRDCONTA = 337
  AND NRCTRCRD = 2327464;
  
  UPDATE CRAPCRD SET
  NRCRCARD = 5127070283056646
  WHERE CDCOOPER = 1
  AND NRDCONTA = 337
  AND NRCTRCRD = 2327464;
  
  UPDATE CRAWCRD SET
  NRCRCARD = 6393500067088329,
  INSITCRD = 3
  WHERE CDCOOPER = 1
  AND NRDCONTA = 329
  AND NRCTRCRD = 1488014;
  
  UPDATE CRAPCRD SET
  NRCRCARD = 6393500067088329
  WHERE CDCOOPER = 1
  AND NRDCONTA = 329
  AND NRCTRCRD = 1488014;
  
  COMMIT;
END;