BEGIN
  UPDATE tbepr_renegociacao_craplem SET nrversao = 1 WHERE cdcooper = 1 AND nrdconta = 10819061 AND cdhistor = 2304 AND dtmvtolt = TO_DATE('03/05/2021', 'DD/MM/RRRR') AND nrversao = 2;
  UPDATE tbepr_renegociacao_craplem SET nrversao = 1 WHERE cdcooper = 1 AND nrdconta = 6862462  AND cdhistor = 2304 AND dtmvtolt = TO_DATE('05/05/2021', 'DD/MM/RRRR') AND nrversao = 2;
  UPDATE tbepr_renegociacao_craplem SET nrversao = 1 WHERE cdcooper = 1 AND nrdconta = 10484485 AND cdhistor = 2304 AND dtmvtolt = TO_DATE('07/05/2021', 'DD/MM/RRRR') AND nrversao = 2;
  UPDATE tbepr_renegociacao_craplem SET nrversao = 1 WHERE cdcooper = 1 AND nrdconta = 7327668  AND cdhistor = 2304 AND dtmvtolt = TO_DATE('13/05/2021', 'DD/MM/RRRR') AND nrversao = 2;
  UPDATE tbepr_renegociacao_craplem SET nrversao = 1 WHERE cdcooper = 1 AND nrdconta = 7835612  AND cdhistor = 2304 AND dtmvtolt = TO_DATE('20/05/2021', 'DD/MM/RRRR') AND nrversao = 2;
  DELETE FROM tbepr_renegociacao_craplem WHERE cdcooper = 1 AND cdhistor = 1036 AND dtmvtolt = TO_DATE('12/05/2021', 'DD/MM/RRRR') AND nrdconta = 11164140;

  COMMIT;
END;
