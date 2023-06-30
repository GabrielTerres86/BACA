BEGIN
  UPDATE cecred.tbconv_remessa_pagfor rem
     SET rem.nmarquivo_serpro        = 'K3244.K05438BA.B0850048.D230626.H190020',
         rem.dhenvio_remessa_serpro  = to_date('26/06/2023 19:10:00', 'DD/MM/YYYY HH24:mi:ss'),
         rem.cdstatus_remessa_serpro = 1,
         rem.idremessa_serpro        = 48
   WHERE rem.idremessa = 337055;

  UPDATE cecred.tbconv_remessa_pagfor rem
     SET rem.nmarquivo_serpro        = NULL,
         rem.dhenvio_remessa_serpro  = NULL,
         rem.cdstatus_remessa_serpro = NULL,
         rem.idremessa_serpro        = NULL
   WHERE rem.idremessa = 337064;
  COMMIT;
END;