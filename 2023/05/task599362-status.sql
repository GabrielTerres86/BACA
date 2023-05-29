BEGIN
  UPDATE cecred.tbepr_consignado_pagamento c
     SET c.instatus = 2
   WHERE c.cdcooper = 1
     AND c.nrdconta = 3628280
     AND c.nrctremp = 3965338
     AND c.nrparepr = 21;
     
  UPDATE cecred.tbepr_consignado_pagamento c
     SET c.instatus = 2
   WHERE c.cdcooper = 1
     AND c.nrdconta = 10230602
     AND c.nrctremp = 4472925
     AND c.nrparepr = 15;
     
  UPDATE cecred.tbepr_consignado_pagamento c
     SET c.instatus = 2
   WHERE c.cdcooper = 1
     AND c.nrdconta = 11951605
     AND c.nrctremp = 4745153
     AND c.nrparepr = 14;
     
  UPDATE cecred.tbepr_consignado_pagamento c
     SET c.instatus = 2
   WHERE c.cdcooper = 2
     AND c.nrdconta = 770876
     AND c.nrctremp = 303009
     AND c.nrparepr = 22;
     
  UPDATE cecred.tbepr_consignado_pagamento c
     SET c.instatus = 2
   WHERE c.cdcooper = 5
     AND c.nrdconta = 8214
     AND c.nrctremp = 17228
     AND c.nrparepr = 37;
     
  UPDATE cecred.tbepr_consignado_pagamento c
     SET c.instatus = 2
   WHERE c.cdcooper = 10
     AND c.nrdconta = 145890
     AND c.nrctremp = 12747
     AND c.nrparepr = 23;
     
  UPDATE cecred.tbepr_consignado_pagamento c
     SET c.instatus = 2
   WHERE c.cdcooper = 10
     AND c.nrdconta = 164321
     AND c.nrctremp = 28487
     AND c.nrparepr = 12;
     
  UPDATE cecred.tbepr_consignado_pagamento c
     SET c.instatus = 2
   WHERE c.cdcooper = 13
     AND c.nrdconta = 256544
     AND c.nrctremp = 58944
     AND c.nrparepr = 34;
     
  UPDATE cecred.tbepr_consignado_pagamento c
     SET c.instatus = 2
   WHERE c.cdcooper = 16
     AND c.nrdconta = 14559161
     AND c.nrctremp = 493781
     AND c.nrparepr = 6;
   
  COMMIT;        
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
