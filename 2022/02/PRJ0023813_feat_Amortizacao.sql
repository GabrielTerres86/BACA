DECLARE
vr_nrseqrdr craprdr.nrseqrdr%TYPE;

BEGIN

	UPDATE craptel
	   SET
		   cdopptel = cdopptel||',A',
		   lsopptel = lsopptel||',AMORTIZACAO',
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
	('CONSULTA_AMORTIZ_PEAC'
	,'TELA_PEAC'
	,'pc_consultar_amortizacao_web'
	,'pr_cdcooper,pr_nrdconta,pr_nrcontrato,pr_nriniseq,pr_nrregist,pr_datrini,pr_datrfim'
	,vr_nrseqrdr);

	COMMIT;
  
  
		
	-- A - AMORTIZACAO	
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
		,'A'
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