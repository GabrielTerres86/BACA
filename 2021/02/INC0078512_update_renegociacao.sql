/* INC0078512 - Preenche o número da proposta nos registros de renegociação */

BEGIN

	UPDATE tbepr_renegociacao SET nrctremp = 49560 WHERE cdcooper = 7 AND nrdconta = 104396 AND vlemprst = 5940.52;

	UPDATE tbepr_renegociacao_contrato SET nrctremp = 49560 WHERE cdcooper = 7 AND nrdconta = 104396 AND nrctrepr in (30810, 35087) AND nrversao = 1;
	
	COMMIT;  
END;  
