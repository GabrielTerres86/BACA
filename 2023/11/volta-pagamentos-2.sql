BEGIN
  UPDATE tbconv_registro_remessa_pagfor
     SET dhinclusao_processamento = to_date('16/11/2023 08:55:23', 'dd/mm/yyyy hh24:mi:ss'),
         dhretorno_processamento  = to_date('16/11/2023 08:55:23', 'dd/mm/yyyy hh24:mi:ss'),
         nmarquivo_inclusao       = '1qth16112023.ret',
         nmarquivo_retorno        = '1qth16112023.ret',
         cdprocessamento          = '503'
   WHERE idsicredi = 8583407;
  COMMIT;
END;
