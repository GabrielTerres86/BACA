BEGIN
  update cecred.tbconv_registro_remessa_pagfor set dsprocessamento = 'Pagamento Cancelado - ', cdstatus_processamento = 4, cdsituacao = '02' where idsicredi = 8377693 AND idremessa = 358262;
  update cecred.tbconv_registro_remessa_pagfor set dsprocessamento = 'Aceito para processamento -', cdstatus_processamento = 3, cdsituacao = '03' where idsicredi = 8737731 AND idremessa = 376705;
  update cecred.tbconv_registro_remessa_pagfor set dsprocessamento = 'Aceito para processamento -', cdstatus_processamento = 3, cdsituacao = '03' where idsicredi = 8737770 AND idremessa = 376707;
  update cecred.tbconv_registro_remessa_pagfor set dsprocessamento = 'Aceito para processamento -', cdstatus_processamento = 3, cdsituacao = '03' where idsicredi = 8737771 AND idremessa = 376707;
  update cecred.tbconv_registro_remessa_pagfor set dsprocessamento = 'Aceito para processamento -', cdstatus_processamento = 3, cdsituacao = '03' where idsicredi = 8737772 AND idremessa = 376707;
  update cecred.tbconv_registro_remessa_pagfor set dsprocessamento = 'Aceito para processamento -', cdstatus_processamento = 3, cdsituacao = '03' where idsicredi = 8825933 AND idremessa = 379707;

  update cecred.crappro set dsprotoc = '4B06.030C.011C.0B17.1B51.5507'  WHERE progress_recid = 630402148;
  update cecred.crappro set dsprotoc = '4B06.0410.011C.0B17.1B52.2313'  WHERE progress_recid = 630402160;
  update cecred.crappro set dsprotoc = '5212.0D34.0110.0B17.2E2A.4103'  WHERE progress_recid = 625133738;
  update cecred.crappro set dsprotoc = '0104.2954.5401.100B.172E.445E.2A'  WHERE progress_recid = 625138439;
  DELETE cecred.crappro WHERE progress_recid = 593861859;
  
  COMMIT;
END;