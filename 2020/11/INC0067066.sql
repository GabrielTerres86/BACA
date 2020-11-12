-- Liberar para efetivar INC0067066
UPDATE tbepr_renegociacao SET dtlibera = '' WHERE cdcooper = 1 AND nrdconta = 80427650 AND nrctremp = 3025658;

COMMIT;