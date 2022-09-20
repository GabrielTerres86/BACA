BEGIN
    
  UPDATE cecred.tbconv_registro_remessa_pagfor pag 
     SET pag.cdstatus_processamento = 2
   WHERE pag.idsicredi = 6183676;
  
  COMMIT;
END;
