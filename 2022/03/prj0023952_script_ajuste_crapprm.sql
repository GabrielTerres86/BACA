BEGIN

  UPDATE crapprm
     SET dsvlrprm = 'https://ailosincident.powerappsportals.com/inscricoes/'
   WHERE NMSISTEM = 'CRED' 
	AND CDACESSO = 'URL_NOVO_SGE' 	
	AND PROGRESS_RECID = 253720 ; 

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
