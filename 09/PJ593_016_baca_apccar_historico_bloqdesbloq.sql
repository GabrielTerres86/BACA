DECLARE    

BEGIN

    INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	VALUES ('BLOQUEAR_DESBLOQUEAR_CARGA', 'CCRD0009', 'pccrd_bloqdesbloq_carga', 'pr_idcarga, pr_cdcooperativa', (SELECT NRSEQRDR FROM craprdr WHERE nmprogra = 'CCRD0009'));
    COMMIT;
	
	INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	VALUES ('BUSCA_HISTORICO', 'CCRD0009', 'pccrd_buscar_historico', 'pr_cdcooperativa, pr_idcarga, pr_pagina, pr_tamanho_pagina', (SELECT NRSEQRDR FROM craprdr WHERE nmprogra = 'CCRD0009'));
    COMMIT;
	
END;
