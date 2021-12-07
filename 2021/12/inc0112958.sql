BEGIN
  UPDATE tbepr_renegociacao_craplem SET vllanmto = 167.58 WHERE cdcooper = 9 AND nrdconta = 502294 AND nrctremp = 20000424 AND cdhistor = 1041 AND dtmvtolt = to_date('28/10/2021', 'DD/MM/RRRR');
  DELETE FROM tbepr_renegociacao_craplem WHERE cdcooper = 13 AND nrdconta = 207438 AND nrctremp = 90130 AND dtmvtolt = to_date('01/10/2021', 'DD/MM/RRRR');
  COMMIT;
END;
