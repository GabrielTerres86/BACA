BEGINS

  UPDATE cecred.tbepr_consignado_pagamento
     SET instatus = 2
   WHERE cdcooper = 10
     AND nrdconta = 164321
     AND nrctremp = 28487
     AND nrparepr = 12;

  UPDATE cecred.tbepr_consignado_pagamento
     SET instatus = 2
   WHERE cdcooper = 16
     AND nrdconta = 14559161
     AND nrctremp = 493781
     AND nrparepr = 6;

  UPDATE cecred.tbepr_consignado_pagamento
     SET instatus = 2
   WHERE cdcooper = 5
     AND nrdconta = 8214
     AND nrctremp = 17228
     AND nrparepr = 37;

  UPDATE cecred.tbepr_consignado_pagamento
     SET instatus = 2
   WHERE CDCOOPER = 2
     AND nrdconta = 770876
     AND nrctremp = 303009
     AND nrparepr = 22;

  UPDATE cecred.tbepr_consignado_pagamento
     SET instatus = 2
   WHERE cdcooper = 10
     AND nrdconta = 145890
     AND nrctremp = 12747
     AND nrparepr = 23;

  UPDATE cecred.tbepr_consignado_pagamento
     SET instatus = 2
   WHERE cdcooper = 1
     AND nrdconta = 10230602
     AND nrctremp = 4472925
     AND nrparepr = 15;

  UPDATE cecred.tbepr_consignado_pagamento
     SET instatus = 2
   WHERE cdcooper = 13
     AND nrdconta = 256544
     AND nrctremp = 58944
     AND nrparepr = 34;

  UPDATE cecred.tbepr_consignado_pagamento
     SET instatus = 2
   WHERE cdcooper = 1
     AND nrdconta = 11951605
     AND nrctremp = 4745153
     AND nrparepr = 14;

  UPDATE cecred.tbepr_consignado_pagamento
     SET instatus = 2
   WHERE cdcooper = 10
     AND nrdconta = 46469
     AND nrctremp = 24157
     AND nrparepr = 25;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
