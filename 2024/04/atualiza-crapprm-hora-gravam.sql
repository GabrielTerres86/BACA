BEGIN

UPDATE	CECRED.crapprm
SET	DSVLRPRM = '01:00'
WHERE	NMSISTEM = 'CRED'
AND	CDACESSO IN ('GRAVAM_HRENVIO_01','GRAVAM_HRENVIO_02','GRAVAM_HRENVIO_03')
AND	CDCOOPER <> 9
AND	DSVLRPRM IS NOT NULL;

COMMIT;

END;