BEGIN

	UPDATE tbepr_consignado_pagamento
	   SET instatus = NULL
	 WHERE cdcooper = 5
	   AND nrdconta = 61646
	   AND nrctremp = 30944
	   AND nrparepr = 7;

	COMMIT;
	
END;