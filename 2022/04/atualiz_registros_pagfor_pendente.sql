BEGIN
 UPDATE tbconv_registro_remessa_pagfor a
    SET a.cdstatus_processamento = 2
       ,a.nrnsubcb = NULL
  WHERE a.idremessa = 191509;
      
  COMMIT;
END;
