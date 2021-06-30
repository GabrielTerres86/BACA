BEGIN
  -- Viacredi
  DELETE FROM tbepr_renegociacao_craplem l WHERE l.cdcooper = 1 AND nrdconta = 10469150 AND nrctremp IN (2084637,3372529,1523293,1669889) AND cdhistor = 2304 AND dtmvtolt = '01/04/2021';
  DELETE FROM tbepr_renegociacao_craplem l WHERE l.cdcooper = 1 AND nrdconta = 8783926 AND nrctremp IN (3113747,3725727,1624598,3109149) AND cdhistor = 2304 AND dtmvtolt = '06/04/2021';
  DELETE FROM tbepr_renegociacao_craplem l WHERE l.cdcooper = 1 AND nrdconta = 6263453 AND nrctremp IN (2550836,3332988,2105056,1715656,1916672) AND cdhistor = 2304 AND dtmvtolt = '07/04/2021';
  DELETE FROM tbepr_renegociacao_craplem l WHERE l.cdcooper = 1 AND nrdconta = 10714740 AND nrctremp IN (2665706,2375104,3342410,2999790,2084014,2042887,2187045,2131614) AND cdhistor = 2304 AND dtmvtolt = '09/04/2021';
  DELETE FROM tbepr_renegociacao_craplem l WHERE l.cdcooper = 1 AND nrdconta = 9911928 AND nrctremp IN (1336139,1518989,1969972) AND cdhistor = 1037 AND dtmvtolt = '14/04/2021';
  DELETE FROM tbepr_renegociacao_craplem l WHERE l.cdcooper = 1 AND nrdconta = 8148139 AND nrctremp IN (1982171,1671840,2114917,2080011,1483645,1046961,1023405,1390485,1149086) AND cdhistor = 2304 AND dtmvtolt = '14/04/2021';
  DELETE FROM tbepr_renegociacao_craplem l WHERE l.cdcooper = 1 AND nrdconta = 9911928 AND nrctremp IN (1336139,1518989,1969972,1336139,1518989,1969972,1336139,1518989,1969972) AND cdhistor IN (3051,3052,3217) AND dtmvtolt = '14/04/2021';
  DELETE FROM tbepr_renegociacao_craplem l WHERE l.cdcooper = 1 AND nrdconta = 2492563 AND nrctremp IN (3340812,3327791,3359138,3381315,3377351,3082886,2470771,3115429,3315776,3223301) AND cdhistor = 2304 AND dtmvtolt = '16/04/2021';
  DELETE FROM tbepr_renegociacao_craplem l WHERE l.cdcooper = 1 AND nrdconta = 10046178 AND nrctremp IN (1851712,1871937,1918948,1704503,1784727,1823222) AND cdhistor = 2304 AND dtmvtolt = '19/04/2021';
  
  
  COMMIT;
END;