BEGIN
	UPDATE crapprm set DSVLRPRM = '1'
		WHERE crapprm.cdcooper = 0
		 AND crapprm.nmsistem = 'CRED'
		 AND crapprm.cdacesso = 'LIBCRM';
	 
  
	COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
