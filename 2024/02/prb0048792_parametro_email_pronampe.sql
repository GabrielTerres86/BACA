BEGIN

	INSERT INTO crapprm (
		NMSISTEM
		,CDCOOPER
		,CDACESSO
		,DSTEXPRM
		,DSVLRPRM
	) VALUES (
		'CRED'
		,0
		,'EMAIL_ERR_REM_PRONAMPE'
		,'Email para receber informacao de quando ocorrer erro na remessa do pronampe'
		,'comunicacaopronampe.peac@ailos.coop.br'
	);
	
    COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
