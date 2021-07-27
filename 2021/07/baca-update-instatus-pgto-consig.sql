BEGIN

	UPDATE tbepr_consignado_pagamento
	   SET instatus = 0
	 WHERE cdcooper = 1
	   AND nrdconta = 12720828
	   AND nrctremp = 3995814
	   AND nrparepr = 1;

	COMMIT;
	
END;