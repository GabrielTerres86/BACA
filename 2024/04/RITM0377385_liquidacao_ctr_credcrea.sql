BEGIN
	UPDATE 	cecred.crapepr
	SET		dtliquid = TRUNC(SYSDATE),
			inliquid = 1,
			vlsdeved = 0,
			vlsdevat = 0
	WHERE	cdcooper = 7
	AND		nrdconta = 218332
	AND		nrctremp = 128337;

	UPDATE	cecred.crappep
	SET		inliquid = 1,
			vlsdvpar = 0,
			vlsdvatu = 0,
			vlsdvsji = 0,
			vlpagpar = 0
	WHERE	cdcooper = 7
	AND		nrdconta = 218332
	AND		nrctremp = 128337
	AND 	inliquid = 0;

	COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
