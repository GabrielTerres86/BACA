BEGIN
  UPDATE tbepr_consignado_pagamento
     SET instatus = 2 
   WHERE cdcooper = 13
     AND nrdconta = 252514
     AND nrctremp = 72630
     AND nrparepr IN (12, 58, 59)
     AND idintegracao IS NULL;
     
     
  UPDATE crappep
     SET dtultpag = '13/07/2021'
        ,vlsdvatu = 0 
        ,inliquid = 1                           
   WHERE cdcooper = 13
     AND nrdconta = 252514
     AND nrctremp = 72630
     AND inliquid = 0;


  UPDATE crapepr 
     SET inliquid = 1
        ,vlsdeved = 0
        ,vlsdvctr = 0
        ,vlsdevat = 0
        ,vlpapgat = 0
   WHERE cdcooper = 13
     AND nrdconta = 252514
     AND nrctremp = 72630;

   COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
