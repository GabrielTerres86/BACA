BEGIN
  UPDATE tbconv_registro_remessa_pagfor reg
          SET reg.nmarquivo_inclusao_serpro       = 'K3244.K05438BA.B0850316.D240717.H000703',
              reg.dhinclusao_processamento_serpro = to_date('16/07/2024 23:00:01', 'DD/MM/YYYY HH245:mi:ss'), 
              reg.idremessa_serpro                = 316 
        WHERE TRUNC(reg.dhinclusao_processamento)           = to_Date('16/07/2024', 'DD/MM/YYYY')
   AND reg.cdempresa_documento IN ('G0270', 'D0432', 'D0328', 'D0385', 'D0153', 'D0100', 'D0064');
        
  UPDATE tbconv_remessa_pagfor rem
          SET rem.nmarquivo_serpro         = 'K3244.K05438BA.B0850316.D240717.H000703',
              rem.dhenvio_remessa_serpro   = to_date('16/07/2024 23:00:01', 'DD/MM/YYYY HH245:mi:ss'),
              rem.cdstatus_remessa_serpro  = 1,
              rem.idremessa_serpro         = 316
        WHERE TRUNC(rem.DHENVIO_REMESSA)           = to_Date('16/07/2024', 'DD/MM/YYYY')
   AND rem.CDCONVENIO_PAGFOR = 'RFB.%';         
  COMMIT;
END;