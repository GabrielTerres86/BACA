BEGIN
	UPDATE 	crapepr
	SET		dtliquid = to_date('21/11/2023', 'DD/MM/YYYY'),
			inliquid = 1,
			vlsdeved = 0,
			vlsdevat = 0
	WHERE	cdcooper = 16
	AND		nrdconta = 17732336
	AND		nrctremp = 747245;

	UPDATE	crappep
	SET		inliquid = 1,
			vlsdvpar = 0,
			vlsdvatu = 0,
			vlsdvsji = 0,
			vlpagpar = 0
	WHERE	cdcooper = 16
	AND		nrdconta = 17732336
	AND		nrctremp = 747245
	AND 	inliquid = 0;

	COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
