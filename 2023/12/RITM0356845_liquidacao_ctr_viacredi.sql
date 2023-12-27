BEGIN
	UPDATE 	crapepr
	SET		dtliquid = to_date('21/12/2023', 'DD/MM/YYYY'),
			inliquid = 1,
			vlsdeved = 0,
			vlsdevat = 0
	WHERE	cdcooper = 1
	AND		nrdconta = 10386904
	AND		nrctremp = 7571644;

	UPDATE	crappep
	SET		inliquid = 1,
			vlsdvpar = 0,
			vlsdvatu = 0,
			vlsdvsji = 0,
			vlpagpar = 0
	WHERE	cdcooper = 1
	AND		nrdconta = 10386904
	AND		nrctremp = 7571644
	AND 	inliquid = 0;

	COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
