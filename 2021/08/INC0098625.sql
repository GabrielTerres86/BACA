BEGIN
  UPDATE
    tbepr_consignado_pagamento p
  SET
    p.instatus = NULL  
  WHERE 
    p.cdcooper = 10  AND p.nrdconta = 141674  AND p.nrctremp = 18679 and p.nrparepr = 5 and p.instatus = 3;
    
  COMMIT;
EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK; 
END;
