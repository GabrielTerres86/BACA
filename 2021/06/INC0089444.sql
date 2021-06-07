BEGIN
  DELETE FROM tbepr_renegociacao_craplem l WHERE l.cdcooper = 1 AND l.nrdconta = 8783926  AND l.nrctremp = 1624594 AND l.nrversao = 2 AND l.cdhistor = 2305;
  DELETE FROM tbepr_renegociacao_craplem l WHERE l.cdcooper = 1 AND l.nrdconta = 8148139  AND l.nrctremp = 1646595 AND l.nrversao = 2 AND l.cdhistor = 2305;
  DELETE FROM tbepr_renegociacao_craplem l WHERE l.cdcooper = 1 AND l.nrdconta = 10469150 AND l.nrctremp = 1523295 AND l.nrversao = 3 AND l.cdhistor = 2305;
  
  UPDATE crapris SET cdmodali = 499 WHERE cdcooper = 2 AND nrdconta = 766909 AND nrctremp = 291866 AND cdmodali = 299;
  UPDATE crapvri SET cdmodali = 499 WHERE cdcooper = 2 AND nrdconta = 766909 AND nrctremp = 291866 AND cdmodali = 299;
  UPDATE crapepr SET cdlcremp = 955 WHERE cdcooper = 2 AND nrdconta = 766909 AND nrctremp = 291866;
  
  UPDATE crapris SET cdmodali = 499 WHERE cdcooper = 13 AND nrdconta = 141739 AND nrctremp = 49713 AND cdmodali = 299;
  UPDATE crapvri SET cdmodali = 499 WHERE cdcooper = 13 AND nrdconta = 141739 AND nrctremp = 49713 AND cdmodali = 299;
  UPDATE crapepr SET cdlcremp = 171 WHERE cdcooper = 13 AND nrdconta = 141739 AND nrctremp = 49713;  
  COMMIT;
END;