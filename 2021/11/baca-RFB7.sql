begin

update tbconv_registro_remessa_pagfor set
tbconv_registro_remessa_pagfor.cdstatus_processamento = 4, 
tbconv_registro_remessa_pagfor.dhretorno_processamento = tbconv_registro_remessa_pagfor.dhinclusao_processamento
WHERE to_date(tbconv_registro_remessa_pagfor.dhinclusao_processamento,'dd/mm/YYYY') = TO_DATE('05/11/2021','dd/mm/YYYY') 
AND  tbconv_registro_remessa_pagfor.cdhistor = 3464 ;
commit;

end;