BEGIN
  DELETE FROM tbepr_renegociacao_craplem WHERE cdcooper = 1 AND nrdconta = 11565500 AND nrctremp = 3741861 AND cdhistor = 2304 AND nrversao = 2;
  COMMIT;
END;