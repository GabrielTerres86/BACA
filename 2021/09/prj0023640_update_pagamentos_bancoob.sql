BEGIN

UPDATE tbconv_registro_remessa_pagfor a
   SET a.cdstatus_processamento = 2
 WHERE a.idsicredi IN (3553099,3553100,3553103,3553101,3553102);
 
 COMMIT;
END;
