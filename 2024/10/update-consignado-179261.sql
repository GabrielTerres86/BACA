BEGIN

  UPDATE cecred.tbepr_consignado_pagamento t
     SET t.instatus = 5
   WHERE t.cdcooper = 13
         AND t.nrdconta = 416606
         AND t.nrctremp = 179261
         AND t.nrparepr = 22;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
