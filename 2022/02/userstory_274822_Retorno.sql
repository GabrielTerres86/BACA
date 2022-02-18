DECLARE
vr_nrseqrdr craprdr.nrseqrdr%TYPE;

BEGIN

	UPDATE craptel
	   SET
		   cdopptel = cdopptel||',R',
		   lsopptel = lsopptel||',RETORNO/CRITICAS',
		   idambtel = 2
	WHERE nmdatela = 'PEAC';

	COMMIT;

	SELECT 
		nrseqrdr
	INTO 
		vr_nrseqrdr
	FROM craprdr
	WHERE nmprogra = 'TELA_PEAC';

	INSERT INTO crapaca
	(nmdeacao
	,nmpackag
	,nmproced
	,lstparam
	,nrseqrdr)
	VALUES
	('CONSULTA_RETORNOS_PEAC'
	,'TELA_PEAC'
	,'pc_consultar_retornos_web'
	,'pr_cdcooper,pr_tipooperacao,pr_nrdconta,pr_nrcontrato,pr_datasolicitacao,pr_status'
	,vr_nrseqrdr);

	COMMIT;
  
	INSERT INTO crapace
		(nmdatela
		,cddopcao
		,cdoperad
		,cdcooper
		,nrmodulo
		,idevento
		,idambace)
	SELECT 
		nmdatela
		,'R'
		,cdoperad
		,cdcooper
		,nrmodulo
		,idevento
		,idambace
	FROM crapace
	WHERE UPPER(nmdatela) = 'PEAC'
		AND cddopcao = 'C'
		AND cdcooper = 3
		AND idambace = 2;

	COMMIT;
END;