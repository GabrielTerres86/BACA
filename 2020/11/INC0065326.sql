-- Liberar para efetivar INC0065326
UPDATE tbepr_renegociacao SET dtlibera = '' WHERE cdcooper = 1 AND nrdconta = 8881740 AND nrctremp = 3066250;
UPDATE tbepr_renegociacao SET dtlibera = '' WHERE cdcooper = 1 AND nrdconta = 8881740 AND nrctremp = 3066272;
UPDATE tbepr_renegociacao SET dtlibera = '' WHERE cdcooper = 1 AND nrdconta = 6024122 AND nrctremp = 2956248;

COMMIT;
