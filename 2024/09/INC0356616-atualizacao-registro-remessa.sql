BEGIN
  UPDATE cecred.tbconv_registro_remessa_pagfor
     SET cdstatus_processamento_serpro          = 3,
         dhretorno_processamento_serpro         = to_date('03/09/2024 23:25:12', 'DD/MM/YYYY HH24:mi:ss'),
         dsprocessamento_serpro                 = 'Aceito para processamento - '
   WHERE IDREMESSA   IN (460449,460304,460351,460266,460384,460296,460398,460412,460419,460192,460240,460308,460416,460430,
                         460367,460473,460488,460279,460345,460235,460403,460427,460374,460485);

  UPDATE cecred.tbconv_remessa_pagfo
     SET cdstatus_retorno_serpro   =  3,   
         flgocorrencia_serpro      =  0
   WHERE idremessa     IN (460449,460304,460351,460266,460384,460296,460398,460412,460419,460192,460240,460308,460416,460430,
                           460367,460473,460488,460279,460345,460235,460403,460427,460374,460485);
  
  COMMIT;
END;