Begin
  UPDATE cecred.tbconv_registro_remessa_pagfor 
     SET nmarquivo_inclusao_serpro       = 'K3244.K05438BA.B0850048.D230626.H190020',
         dhinclusao_processamento_serpro = to_date('26/06/2023 19:10:00','DD/MM/YYYY HH24:mi:ss'),
         idremessa_serpro                = 48 
   WHERE IDSICREDI IN (7985370);

   UPDATE cecred.tbconv_registro_remessa_pagfor 
     SET nmarquivo_inclusao_serpro       = null,
         dhinclusao_processamento_serpro = null,
         idremessa_serpro                = null,
         cdstatus_processamento_serpro   = null,
         dsprocessamento_serpro          = null
   WHERE IDSICREDI IN (7985471);
  commit;
end;