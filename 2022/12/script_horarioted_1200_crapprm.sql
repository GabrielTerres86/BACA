BEGIN
	UPDATE crapprm
	   SET dsvlrprm = 1728000
	 WHERE cp.nmsistem = 'CRED'
       AND cp.cdacesso = 'BLQJ_HORATED_JURIDICO'             
       AND cp.cdcooper = 0;
	COMMIT;
END
