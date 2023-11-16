BEGIN
  update tbconv_registro_remessa_pagfor set CDSTATUS_PROCESSAMENTO=4,DSPROCESSAMENTO='Service Unavailable -',CDSTATUSHTTP='503'
  where IDSICREDI=8583407;
  COMMIT;
END;
