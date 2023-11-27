BEGIN
	UPDATE	crapepr
	SET		dtliquid = to_date('21/11/2023', 'DD/MM/YYYY'),
			inliquid = 1,
			vlsdeved = 0,
			vlsdevat = 0
	WHERE	cdcooper = 7
	AND		nrdconta in (451886, 17468728)
	AND		nrctremp in (118375, 118363);

	UPDATE	crappep
	SET		inliquid = 1,
			vlsdvpar = 0,
			vlsdvatu = 0,
			vlsdvsji = 0,
			vlpagpar = 0
	WHERE	cdcooper = 7
	AND		nrdconta in (451886, 17468728)
	AND		nrctremp in (118375, 118363)
	AND		inliquid = 0;

	COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
