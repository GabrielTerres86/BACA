BEGIN
	--
	insert into crapmbr (CDBIRCON, CDMODBIR, DSMODBIR, INPESSOA, NMTAGMOD, NRORDIMP)
	values (1, 4, '482', 2, 'PEFINCOMP', 2);
  --
	insert into crapmbr (CDBIRCON, CDMODBIR, DSMODBIR, INPESSOA, NMTAGMOD, NRORDIMP)
	values (1, 5, '309', 2, 'PLUSMASTER', 1);
  --
	COMMIT;
	--
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		dbms_output.put_line('Erro: ' || SQLERRM);
END;
