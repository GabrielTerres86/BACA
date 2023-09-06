BEGIN
  UPDATE cecred.tbconv_registro_remessa_pagfor reg
          SET reg.nmarquivo_inclusao_serpro       = 'K3244.K05438BA.B0850098.D230831.H190522',
              reg.dhinclusao_processamento_serpro = to_date('31/08/2023 19:10:00', 'DD/MM/YYYY HH245:mi:ss'),
              reg.cdreprocessamento               = 0,  
              reg.idremessa_serpro                = 98 
        WHERE reg.idsicredi = 8351755;
        
  UPDATE cecred.tbconv_registro_remessa_pagfor reg
            SET reg.nmarquivo_inclusao_serpro       = 'K3244.K05438BA.B0850098.D230831.H190522',
                reg.dhinclusao_processamento_serpro = to_date('31/08/2023 19:10:00', 'DD/MM/YYYY HH245:mi:ss'),
                reg.cdreprocessamento               = 0,  
                reg.idremessa_serpro                = 98 
          WHERE reg.idsicredi = 8351751;
    
  UPDATE cecred.tbconv_registro_remessa_pagfor reg
            SET reg.nmarquivo_inclusao_serpro       = 'K3244.K05438BA.B0850091.D230822.H190024',
                reg.dhinclusao_processamento_serpro = to_date('22/08/2023 19:05:00', 'DD/MM/YYYY HH245:mi:ss'),
                reg.cdreprocessamento               = 0,  
                reg.idremessa_serpro                = 91 
          WHERE reg.idsicredi = 8305641;              

  COMMIT;
END;