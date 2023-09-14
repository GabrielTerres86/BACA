DECLARE

BEGIN

  UPDATE cecred.tbepr_consignado_pagamento cp
     SET cp.instatus = 2
        ,cp.dtupdreg = SYSDATE
   WHERE (cp.idsequencia, cp.cdcooper, cp.nrdconta, cp.nrctremp, cp.nrparepr) IN
         ((3147688, 01, 08637733, 4101609, 024),
          (3147683, 16, 00316091, 0520270, 012),
          (3413742, 13, 00144762, 0236458, 017),
          (3414276, 13, 00144762, 0222021, 016),
          (3414092, 13, 00144762, 0232894, 034),
          (3413915, 13, 00144762, 0236458, 075),
          (3414032, 13, 00144762, 0236458, 114),
          (3414101, 11, 17303680, 0369120, 029),
          (3414264, 11, 17303680, 0369133, 001),
          (3413752, 07, 17313376, 0112758, 004),
          (3417859, 11, 15884473, 0371754, 019))
     AND cp.instatus = 1
     AND cp.dtupdreg IS NULL;

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
  
    ROLLBACK;
  
    RAISE_APPLICATION_ERROR(-20501, SQLERRM);
  
END;
