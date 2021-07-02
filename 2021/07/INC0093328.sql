BEGIN
  UPDATE tbepr_renegociacao_craplem SET nrversao = 1 WHERE cdcooper = 1 AND cdhistor = 2304 AND dtmvtolt = '03/05/2021' AND nrversao = 2;
  UPDATE tbepr_renegociacao_craplem SET nrversao = 1 WHERE cdcooper = 1 AND cdhistor = 2304 AND dtmvtolt = '05/05/2021' AND nrversao = 2;
  UPDATE tbepr_renegociacao_craplem SET nrversao = 1 WHERE cdcooper = 1 AND cdhistor = 2304 AND dtmvtolt = '07/05/2021' AND nrversao = 2;
  UPDATE tbepr_renegociacao_craplem SET nrversao = 1 WHERE cdcooper = 1 AND cdhistor = 2304 AND dtmvtolt = '13/05/2021' AND nrversao = 2;
  UPDATE tbepr_renegociacao_craplem SET nrversao = 1 WHERE cdcooper = 1 AND cdhistor = 2304 AND dtmvtolt = '20/05/2021' AND nrversao = 2;
  DELETE FROM tbepr_renegociacao_craplem WHERE cdcooper = 1 AND cdhistor = 1036 AND dtmvtolt = '12/05/2021' AND nrdconta = 11164140;

  COMMIT;
END;
