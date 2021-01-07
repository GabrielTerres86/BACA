begin

	update pix.tbpix_transacao t
	   set t.idreq_endtoend = t.idreq_sistema_cliente
	 where t.idreq_endtoend is null 
	   and t.idreq_sistema_cliente is not null 
	   and t.idreq_jdpi is null
	   and t.cdbccxlt_pagador = 85
	   and t.cdbccxlt_recebedor = 85;

	update pix.tbpix_tipo_fase
	   set nmfase = 'Validação dos créditos do cooperado'
	 where idfase = 19;

	update pix.tbpix_tipo_fase
	   set nmfase = 'Retorno Análise OFSAA (Automático)'
	 where idfase = 12;


  commit;

end;