BEGIN

	INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
	VALUES ('CRED', 0, 'SSPC01_TIMEOUT_PROTOCOLO', 'Tempo do transfer timeout',  '100');
 
	COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;