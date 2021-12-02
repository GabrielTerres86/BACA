BEGIN
  UPDATE tbconv_registro_remessa_pagfor r
     SET r.cdstatus_processamento = 2,
         r.dhinclusao_processamento = SYSDATE
   WHERE r.idsicredi IN (4520983,4521129,4521130,4521132,4521133,4521150,4521151,4521159,4521166,4521214,4521216,4521222,4521228,4521247,4521254,4521257,4521274);
 COMMIT;     
END;
