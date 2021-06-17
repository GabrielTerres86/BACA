update 
	tbconv_registro_remessa_pagfor pag 
set 
	pag.cdstatus_processamento = 2 
where 
	pag.idsicredi in (3381565, 3381263, 3383568, 3381215, 3381375, 3384265, 3383622);

commit;