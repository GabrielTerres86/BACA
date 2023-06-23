Begin
  UPDATE cecred.tbconv_registro_remessa_pagfor 
     SET nmarquivo_inclusao_serpro       = 'K3244.K05438BA.B0850040.D230614.H235356',
         dhinclusao_processamento_serpro = to_date('14/06/2023 23:57:00','DD/MM/YYYY HH24:mi:ss'),
         idremessa_serpro                = 40 
   WHERE IDSICREDI IN (7890084,7889371,7889529,7889557,7888840,7888783,7890085,7888993,7889523,7890322,7890404,7889558,7888721,7889525,7889821,7889287,7889284,7890325,7890195,7890200);
  commit;
end;