DELETE FROM tbepr_renegociacao_crapepr WHERE cdcooper = 1 AND nrdconta = 8757240 AND nrversao >= 2; 
DELETE FROM tbepr_renegociacao_craplem WHERE cdcooper = 1 AND nrdconta = 8757240 AND dtmvtolt = '22/10/2020' AND nrversao >= 2; 
DELETE FROM tbepr_renegociacao_crappep WHERE cdcooper = 1 AND nrdconta = 8757240 AND nrversao >= 2; 
DELETE FROM tbepr_renegociacao_crawepr WHERE cdcooper = 1 AND nrdconta = 8757240 AND nrversao >= 2; 
commit;