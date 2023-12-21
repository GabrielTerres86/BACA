BEGIN
  UPDATE cecred.tbconv_registro_remessa_pagfor reg 
     SET reg.nmarquivo_inclusao_serpro='K3244.K05438BA.B0850172.D231219.H235011',
         reg.dhinclusao_processamento_serpro=TO_DATE('20/12/2023 05:08:00','DD/MM/YYYY hh24:mi:ss'),
         reg.idremessa_serpro='172'
  WHERE  reg.idremessa IN
         (
                SELECT rem.idremessa
                FROM   cecred.tbconv_remessa_pagfor rem
                WHERE  rem.dtmovimento = TO_DATE('19/12/2023', 'DD/MM/YYYY')
                AND    rem.cdagente_arrecadacao=4
				AND	   rem.idremessa not in (388850,388845));
  COMMIT;

  UPDATE cecred.tbconv_remessa_pagfor rem 
     SET rem.NMARQUIVO_SERPRO='K3244.K05438BA.B0850172.D231219.H235011',
     rem.DHENVIO_REMESSA_SERPRO=TO_DATE('20/12/2023 05:08:00','DD/MM/YYYY hh24:mi:ss'),
     rem.CDSTATUS_REMESSA_SERPRO=1,
     rem.IDREMESSA_SERPRO='172' 
  WHERE  rem.CDAGENTE_ARRECADACAO=4 and rem.DTMOVIMENTO = TO_DATE('19/12/2023', 'DD/MM/YYYY') and rem.idremessa not in (388850,388845); 
  COMMIT;

  UPDATE cecred.tbconv_registro_remessa_pagfor reg 
     SET reg.nmarquivo_inclusao_serpro='K3244.K05438BA.B0850173.D231220.H122542',
         reg.dhinclusao_processamento_serpro=TO_DATE('20/12/2023 11:32:00','DD/MM/YYYY hh24:mi:ss'),
         reg.idremessa_serpro='173'
  WHERE  reg.idremessa IN
         (
                SELECT rem.idremessa
                FROM   cecred.tbconv_remessa_pagfor rem
                WHERE  rem.dtmovimento = TO_DATE('19/12/2023', 'DD/MM/YYYY')
                AND    rem.cdagente_arrecadacao=4
				AND    rem.idremessa in (388850,388845));
  COMMIT;

  UPDATE cecred.tbconv_remessa_pagfor rem 
     SET rem.NMARQUIVO_SERPRO='K3244.K05438BA.B0850173.D231220.H122542',
     rem.DHENVIO_REMESSA_SERPRO=TO_DATE('20/12/2023 11:32:00','DD/MM/YYYY hh24:mi:ss'),
     rem.CDSTATUS_REMESSA_SERPRO=1,
     rem.IDREMESSA_SERPRO='173' 
  WHERE  rem.CDAGENTE_ARRECADACAO=4 and rem.DTMOVIMENTO = TO_DATE('19/12/2023', 'DD/MM/YYYY') and rem.idremessa in (388850,388845); 
  COMMIT;
END;
