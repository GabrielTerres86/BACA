BEGIN
   UPDATE tbconv_registro_remessa_pagfor reg SET reg.cdstatus_processamento = 2 where reg.idsicredi IN (3552919, 3552871);
   COMMIT;
END;