BEGIN  
  UPDATE cecred.tbepr_consignado_pagamento tcp
     SET tcp.instatus = 2
   WHERE tcp.cdcooper = 1
     AND tcp.nrdconta = 80170781
     AND tcp.nrctremp = 3472408
     AND tcp.nrparepr = 17
     AND tcp.instatus = 3;
     
     
  UPDATE cecred.tbepr_consignado_pagamento tcp
     SET tcp.instatus = 2
   WHERE tcp.cdcooper = 1
     AND tcp.nrdconta = 11951605
     AND tcp.nrctremp = 4745153
     AND tcp.nrparepr = 12
     AND tcp.instatus = 3;
     
     
  UPDATE cecred.tbepr_consignado_pagamento tcp
     SET tcp.instatus = 2
   WHERE tcp.cdcooper = 1
     AND tcp.nrdconta = 11204800
     AND tcp.nrctremp = 4349266
     AND tcp.nrparepr = 11
     AND tcp.instatus = 3;
     
  UPDATE cecred.tbepr_consignado_pagamento tcp
     SET tcp.instatus = 2
   WHERE tcp.cdcooper = 10
     AND tcp.nrdconta = 129100
     AND tcp.nrctremp = 20657
     AND tcp.nrparepr = 21
     AND tcp.instatus = 3;
     
  UPDATE cecred.tbepr_consignado_pagamento tcp
     SET tcp.instatus = 2
   WHERE tcp.cdcooper = 12
     AND tcp.nrdconta = 80756
     AND tcp.nrctremp = 45219
     AND tcp.nrparepr = 8
     AND tcp.instatus = 3;
     
  UPDATE cecred.tbepr_consignado_pagamento tcp
     SET tcp.instatus = 2
   WHERE tcp.cdcooper = 13
     AND tcp.nrdconta = 288535
     AND tcp.nrctremp = 98543
     AND tcp.nrparepr = 15
     AND tcp.instatus = 3;
   
  COMMIT;

  EXCEPTION
    
    WHEN OTHERS THEN
      RAISE_application_error(-20500, SQLERRM);
      ROLLBACK;
  
END;
