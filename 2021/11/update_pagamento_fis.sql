BEGIN
  
  UPDATE tbepr_consignado_pagamento SET INSTATUS = null
  WHERE nrdconta = 643017 and nrctremp = 297340 and cdcooper = 2 and NRPAREPR in (7,8);
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    
END;
