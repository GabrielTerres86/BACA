begin

  UPDATE tbconv_registro_remessa_pagfor pag
     SET pag.cdstatus_processamento = 2, pag.dsprocessamento = null
   WHERE pag.idsicredi IN (3402300,3402316,3513167,3533044,3565850);
  COMMIT;

end;
