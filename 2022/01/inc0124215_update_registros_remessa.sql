BEGIN
  
  UPDATE tbconv_registro_remessa_pagfor reg
     SET reg.cdstatus_processamento = 4
   WHERE reg.idsicredi IN (4851608,4851609,4851610,4851611,4851612,4851613,4851614,4851615);
  
  COMMIT;
 
END;
