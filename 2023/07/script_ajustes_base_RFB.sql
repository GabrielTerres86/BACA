Begin

	UPDATE cecred.tbconv_remessa_pagfor 
					  SET nmarquivo_serpro         = 'K3244.K05438BA.B0850040.D230614.H235356',
						  dhenvio_remessa_serpro   = to_date('14/06/2023 23:57:50','DD/MM/YYYY HH24:mi:ss'),
						  cdstatus_remessa_serpro  = 1,
						  idremessa_serpro         = 40
					WHERE idremessa IN (333401,333402,333403,333404,333405,333406,333407,333408,333409,333410,333411,333412,333413);
					
	UPDATE cecred.tbconv_remessa_pagfor 
					  SET nmarquivo_serpro         = 'K3244.K05438BA.B0850001.D230314.H115215',
						  dhenvio_remessa_serpro   = to_date('14/03/2023 11:51:22','DD/MM/YYYY HH24:mi:ss'),
						  cdstatus_remessa_serpro  = 1,
						  idremessa_serpro         = 1
					WHERE idremessa = 304321;

	UPDATE cecred.tbconv_remessa_pagfor 
					  SET nmarquivo_serpro         = 'K3244.K05438BA.B0850025.D230523.H190046',
						  dhenvio_remessa_serpro   = to_date('23/05/2023 19:06:50','DD/MM/YYYY HH24:mi:ss'),
						  cdstatus_remessa_serpro  = 1,
						  idremessa_serpro         = 25
					WHERE idremessa = 327294;
					
	UPDATE cecred.tbconv_registro_remessa_pagfor 
					  SET nmarquivo_inclusao_serpro       = 'K3244.K05438BA.B0850052.D230630.H190045',
						  dhinclusao_processamento_serpro = to_date('30/06/2023 19:06:58','DD/MM/YYYY HH24:mi:ss'),
						  cdstatus_processamento_serpro   = 3,
						  idremessa_serpro                = 52
					WHERE idsicredi = 8015790;
					
	UPDATE cecred.tbconv_registro_remessa_pagfor 
					  SET nmarquivo_inclusao_serpro       = 'K3244.K05438BA.B0850021.D230517.H190023',
						  dhinclusao_processamento_serpro = to_date('17/05/2023 19:06:50','DD/MM/YYYY HH24:mi:ss'),
						  cdstatus_processamento_serpro   = 3,
						  idremessa_serpro                = 21
					WHERE idsicredi = 7720008;
					
	UPDATE cecred.tbconv_registro_remessa_pagfor 
					  SET nmarquivo_inclusao_serpro       = 'K3244.K05438BA.B0850008.D230420.H190029',
						  dhinclusao_processamento_serpro = to_date('20/04/2023 19:06:50','DD/MM/YYYY HH24:mi:ss'),
						  cdstatus_processamento_serpro   = 3,
						  idremessa_serpro                = 8
					WHERE idsicredi = 7586697;
					
	UPDATE cecred.tbconv_registro_remessa_pagfor 
					  SET nmarquivo_inclusao_serpro       = 'K3244.K05438BA.B0850025.D230523.H190046',
						  dhinclusao_processamento_serpro = to_date('23/05/2023 19:06:50','DD/MM/YYYY HH24:mi:ss'),
						  cdstatus_processamento_serpro   = 3,
						  idremessa_serpro                = 25
					WHERE idsicredi = 7796693;
					
	UPDATE cecred.tbconv_registro_remessa_pagfor 
					  SET nmarquivo_inclusao_serpro       = 'K3244.K05438BA.B0850052.D230630.H190045',
						  dhinclusao_processamento_serpro = to_date('30/06/2023 19:06:50','DD/MM/YYYY HH24:mi:ss'),
						  cdstatus_processamento_serpro   = 3,
						  idremessa_serpro                = 52
					WHERE idsicredi = 8003835;
					
	UPDATE cecred.tbconv_registro_remessa_pagfor 
					  SET nmarquivo_inclusao_serpro       = 'K3244.K05438BA.B0850051.D230629.H190019',
						  dhinclusao_processamento_serpro = to_date('29/06/2023 19:06:50','DD/MM/YYYY HH24:mi:ss'),
						  cdstatus_processamento_serpro   = 3,
						  idremessa_serpro                = 51
					WHERE idsicredi = 7996590;
					
	UPDATE cecred.tbconv_registro_remessa_pagfor 
					  SET nmarquivo_inclusao_serpro       = 'K3244.K05438BA.B0850051.D230629.H190019',
						  dhinclusao_processamento_serpro = to_date('29/06/2023 19:06:50','DD/MM/YYYY HH24:mi:ss'),
						  cdstatus_processamento_serpro   = 3,
						  idremessa_serpro                = 51
					WHERE idsicredi = 7996597;
					
	UPDATE cecred.tbconv_registro_remessa_pagfor 
					  SET nmarquivo_inclusao_serpro       = 'K3244.K05438BA.B0850051.D230629.H190019',
						  dhinclusao_processamento_serpro = to_date('29/06/2023 19:06:50','DD/MM/YYYY HH24:mi:ss'),
						  cdstatus_processamento_serpro   = 3,
						  idremessa_serpro                = 51
					WHERE idsicredi = 7996600;
					
	UPDATE cecred.tbconv_registro_remessa_pagfor 
					  SET nmarquivo_inclusao_serpro       = 'K3244.K05438BA.B0850001.D230314.H115215',
						  dhinclusao_processamento_serpro = to_date('14/03/2023 11:51:50','DD/MM/YYYY HH24:mi:ss'),
						  cdstatus_processamento_serpro   = 3,
						  idremessa_serpro                = 1
					WHERE idsicredi = 7333022;
					
	UPDATE cecred.tbconv_registro_remessa_pagfor 
					  SET nmarquivo_inclusao_serpro       = 'K3244.K05438BA.B0850025.D230523.H190046',
						  dhinclusao_processamento_serpro =  to_date('23/05/2023 19:07:50','DD/MM/YYYY HH24:mi:ss'),
						  cdstatus_processamento_serpro   = 3,
						  idremessa_serpro                = 25
					WHERE idsicredi = 7796729;
					
	UPDATE cecred.tbconv_registro_remessa_pagfor 
					  SET nmarquivo_inclusao_serpro       = 'K3244.K05438BA.B0850052.D230630.H190045',
						  dhinclusao_processamento_serpro = to_date('30/06/2023 19:06:50','DD/MM/YYYY HH24:mi:ss'),
						  cdstatus_processamento_serpro   = 3,
						  idremessa_serpro                = 52
					WHERE idsicredi = 7998833;
					
	UPDATE cecred.tbconv_registro_remessa_pagfor 
					  SET nmarquivo_inclusao_serpro       = 'K3244.K05438BA.B0850051.D230629.H190019',
						  dhinclusao_processamento_serpro = to_date('29/06/2023 19:06:50','DD/MM/YYYY HH24:mi:ss'),
						  cdstatus_processamento_serpro   = 3,
						  idremessa_serpro                = 51
					WHERE idsicredi = 7993850;				

    UPDATE cecred.tbconv_registro_remessa_pagfor 
       SET nmarquivo_inclusao_serpro       = 'K3244.K05438BA.B0850066.D230719.H190037',
           dhinclusao_processamento_serpro = to_date('19/07/2023 19:35:05','DD/MM/YYYY HH24:mi:ss'),
           cdstatus_processamento_serpro   = 3,
           idremessa_serpro                = 66
     WHERE idsicredi = 8081118;

  commit;

end;				