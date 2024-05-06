BEGIN

UPDATE	CECRED.crapbpr
SET	flcancel = 1,
	tpcancel = 'A',
	flgbaixa = 0,
	tpdbaixa = null
WHERE	CDCOOPER = 9
AND	NRDCONTA = 82938261
AND	NRCTRPRO = 95610;

COMMIT;

END;