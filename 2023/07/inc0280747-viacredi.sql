BEGIN
  UPDATE cecred.tbepr_consignado_pagamento
     SET instatus = 2,
         dtupdreg = SYSDATE
   WHERE cdcooper = 1
     AND nrdconta = 10761896
     AND nrctremp = 6853868
     AND nrparepr in (5,6,8,10);
            
  COMMIT;        
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
