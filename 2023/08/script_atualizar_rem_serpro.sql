BEGIN

UPDATE tbconv_registro_remessa_pagfor reg
                  SET reg.nmarquivo_inclusao_serpro       = 'K3244.K05438BA.B0850068.D230721.H190522',
                      reg.dhinclusao_processamento_serpro = to_date('21/07/2023 19:10:00','DD/MM/YYYY HH24:mi:ss'),
                      reg.idremessa_serpro                = 68 
                WHERE reg.idsicredi = 8134760;
				
UPDATE tbconv_registro_remessa_pagfor reg
                  SET reg.nmarquivo_inclusao_serpro       = 'K3244.K05438BA.B0850072.D230727.H190017',
                      reg.dhinclusao_processamento_serpro = to_date('27/07/2023 19:10:00','DD/MM/YYYY HH24:mi:ss'),
                      reg.idremessa_serpro                = 72 
                WHERE reg.idsicredi = 8153753;

UPDATE tbconv_registro_remessa_pagfor reg
                  SET reg.nmarquivo_inclusao_serpro       = 'K3244.K05438BA.B0850074.D230731.H190020',
                      reg.dhinclusao_processamento_serpro = to_date('31/07/2023 19:05:00','DD/MM/YYYY HH24:mi:ss'),
                      reg.idremessa_serpro                = 74 
                WHERE reg.idsicredi in (8169617,8169619,8170600);				

UPDATE tbconv_registro_remessa_pagfor reg
                  SET reg.nmarquivo_inclusao_serpro       = 'K3244.K05438BA.B0850075.D230801.H190021',
                      reg.dhinclusao_processamento_serpro = to_date('01/08/2023 19:05:00','DD/MM/YYYY HH24:mi:ss'),
                      reg.idremessa_serpro                = 75
                WHERE reg.idsicredi in (8187905);

  COMMIT;

END;