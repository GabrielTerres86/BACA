BEGIN
  UPDATE
    tbepr_consignado_pagamento
  SET
    instatus = NULL  
  WHERE 
    nrdconta = 117412
and nrparepr = 10 
and cdcooper = 13
and nrctremp = 54042 
and instatus = 3;
    
  COMMIT;
EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK; 
END;