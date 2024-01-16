BEGIN

	UPDATE crapprm prm
	   SET prm.dsvlrprm = prm.dsvlrprm || ',4601,4602'
	WHERE prm.cdacesso = 'LINHA_PEAC_3040'
	   AND prm.cdcooper = 0;
	 
	INSERT INTO crapprm
	  (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
	VALUES
	  ('CRED',
	   14,
	   'LINHA_PEAC_3040',
	   'Linhas de credito do PEAC para tratamento no 3040',
	   '5600,4601,4602,4603');

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
