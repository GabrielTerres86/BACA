BEGIN
	UPDATE crapprm
	   SET dsvlrprm = 2448000
	 WHERE cp.nmsistem = 'CRED'
       AND cp.cdacesso = 'BLQJ_HORATED_JURIDICO'             
       AND cp.cdcooper = 0;
	COMMIT;
END
