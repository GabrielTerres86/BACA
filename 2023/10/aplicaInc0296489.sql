BEGIN
  UPDATE cecred.tbconv_registro_remessa_pagfor reg
     SET reg.nmarquivo_inclusao_serpro       = 'K3244.K05438BA.B0850130.D231019.H002544',
         reg.dhinclusao_processamento_serpro = to_date('19/10/2023 00:28:00','DD/MM/YYYY hh24:mi:ss'),
         reg.idremessa_serpro                = '130'
   WHERE reg.idremessa IN
         (SELECT rem.idremessa
            FROM cecred.tbconv_remessa_pagfor rem
           WHERE rem.dtmovimento = to_date('18/10/2023', 'DD/MM/YYYY')
             AND rem.cdagente_arrecadacao = 4);
  COMMIT;

  UPDATE cecred.tbconv_remessa_pagfor rem
     SET rem.nmarquivo_serpro        = 'K3244.K05438BA.B0850130.D231019.H002544',
         rem.dhenvio_remessa_serpro  = to_date('19/10/2023 00:28:00','DD/MM/YYYY hh24:mi:ss'),
         rem.cdstatus_remessa_serpro = 1,
         rem.idremessa_serpro        = '130'
   WHERE rem.cdagente_arrecadacao = 4
     AND rem.dtmovimento = to_date('18/10/2023', 'DD/MM/YYYY');

  COMMIT;

  UPDATE cecred.crapprm prm
     SET prm.dsvlrprm = '80100'
   WHERE prm.nmsistem = 'CRED'
     AND prm.cdacesso IN ('HRFIM_ENV_REM_RFB')
     AND prm.progress_recid = 936590;

  COMMIT;
END;
