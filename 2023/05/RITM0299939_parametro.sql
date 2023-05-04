BEGIN
	insert into crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
	values (213, 'Bloqueio para importacao do arquivos TOTVS com saldos iguais a 0 (zero)', 1, 0);
	
	insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
	values (213, 1, '1');

	insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
	values (213, 2, '1');

	insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
	values (213, 6, '1');

	insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
	values (213, 11, '1');

	insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
	values (213, 16, '1');

	insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
	values (213, 3, '1');

	insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
	values (213, 12, '1');

	insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
	values (213, 5, '1');

	insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
	values (213, 8, '1');

	insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
	values (213, 7, '1');

	insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
	values (213, 9, '1');

	insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
	values (213, 10, '1');

	insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
	values (213, 13, '1');

	insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
	values (213, 14, '1');
	
	COMMIT;
	
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		raise_application_error(-20000,'ERRO AO EXECUTAR SCRIPT: '||SQLERRM);
END;