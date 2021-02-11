-- Correcao na segregacao de valores de contrato para regularizar no PA - INC0062842
UPDATE craplem SET vllanmto = 40128.36 WHERE cdcooper = 9 AND nrdconta = 32611 AND nrctremp = 17837 AND cdhistor = 2381 AND dtmvtolt = '28/09/2020';
UPDATE craplem SET vllanmto = 31460.81 WHERE cdcooper = 9 AND nrdconta = 32611 AND nrctremp = 17837 AND cdhistor = 2382 AND dtmvtolt = '28/09/2020';
commit;