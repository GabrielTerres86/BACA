BEGIN
  UPDATE tbepr_consignado_pagamento
     SET instatus = 2
   WHERE cdcooper = 13
     AND nrdconta = 252514
     AND nrctremp = 72630
     AND nrparepr IN (12, 58, 59)
     AND idintegracao IS NULL;

  UPDATE tbepr_consignado_pagamento
     SET instatus = 2
   WHERE cdcooper = 13
     AND nrdconta = 66877
     AND nrctremp = 91959
     AND nrparepr IN (9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36)
     AND idintegracao IS NULL;
          
  UPDATE crappep
     SET dtultpag = '13/07/2021'
        ,vlsdvatu = 0
        ,inliquid = 1                      
   WHERE cdcooper = 13
     AND nrdconta = 252514
     AND nrctremp = 72630
     AND inliquid = 0;

  UPDATE crappep
     SET dtultpag = '16/09/2021'
        ,vlsdvatu = 0
        ,inliquid = 1                        
   WHERE cdcooper = 13
     AND nrdconta = 66877
     AND nrctremp = 91959
     AND inliquid = 0;

  UPDATE crapepr 
     SET inliquid = 1
        ,vlsdeved = 0
        ,vlsdvctr = 0
        ,vlsdevat = 0
        ,vlpapgat = 0
   WHERE cdcooper = 13
     AND nrdconta IN (252514, 66877)
     AND nrctremp IN (72630, 91959);

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
