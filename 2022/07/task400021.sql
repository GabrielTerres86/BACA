DECLARE
BEGIN

  UPDATE cecred.tbepr_consignado_pagamento cp
     SET cp.instatus = 2
   WHERE cp.cdcooper = 9
     AND cp.nrdconta = 526096
     AND cp.nrctremp = 21100115
     AND cp.nrparepr = 12
     AND cp.idsequencia = 1463000;

  IF SQL%ROWCOUNT = 1 THEN
    COMMIT;
  ELSE
    ROLLBACK;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
