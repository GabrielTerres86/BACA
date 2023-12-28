BEGIN
  UPDATE cecred.tbconv_registro_remessa_pagfor reg
     SET reg.dsprocessamento_serpro         = NULL,
         reg.nmarquivo_retorno_serpro       = NULL,
         reg.dhretorno_processamento_serpro = NULL,
         reg.cdstatus_processamento_serpro  = NULL
   WHERE reg.idremessa IN
         (SELECT rem.idremessa
            FROM cecred.tbconv_remessa_pagfor rem
           WHERE rem.dtmovimento = to_date('20/12/2023', 'DD/MM/YYYY')
             AND rem.cdagente_arrecadacao = 4)
     AND reg.idremessa IN (388861, 388862, 388863, 388864, 388867, 388870, 388872,
                           388874, 388876, 388878, 388880, 388882, 388884, 388887,
                           388889, 388891, 388893, 388895, 388897, 388899, 388901,
                           388903, 388905, 388907, 388909, 388911, 388913, 388915,
                           388917, 388919, 388921, 388923, 388925, 388927, 388941,
                           388943, 388945, 388947, 388949, 388951, 388961, 388963,
                           388965, 388967, 388969, 388971, 388973, 388975, 388977,
                           388979, 388981, 388983, 389001);
  COMMIT;

  UPDATE cecred.tbconv_remessa_pagfor rem
     SET rem.cdstatus_retorno_serpro = NULL,
         rem.flgocorrencia_serpro    = NULL
   WHERE rem.cdagente_arrecadacao = 4
     AND rem.dtmovimento = to_date('20/12/2023', 'DD/MM/YYYY')
     AND rem.idremessa IN (388861, 388862, 388863, 388864, 388867, 388870, 388872,
                           388874, 388876, 388878, 388880, 388882, 388884, 388887,
                           388889, 388891, 388893, 388895, 388897, 388899, 388901,
                           388903, 388905, 388907, 388909, 388911, 388913, 388915,
                           388917, 388919, 388921, 388923, 388925, 388927, 388941,
                           388943, 388945, 388947, 388949, 388951, 388961, 388963,
                           388965, 388967, 388969, 388971, 388973, 388975, 388977,
                           388979, 388981, 388983, 389001); 
  COMMIT;
END;