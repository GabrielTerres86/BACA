BEGIN
  UPDATE tbconv_registro_remessa_pagfor
     SET CDSTATUS_PROCESSAMENTO = 1
   WHERE idsicredi in (6948738,6948736)
     AND cdhistor=3465;
  COMMIT;
  END;