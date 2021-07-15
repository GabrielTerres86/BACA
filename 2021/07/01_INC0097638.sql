update 
	tbconv_registro_remessa_pagfor pag 
set 
	pag.cdstatus_processamento = 2 
where 
	pag.idsicredi in (3538135, 3538124);

commit;