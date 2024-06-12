BEGIN

  insert into crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  values (309, 'Linhas BNDES', 2, 0);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (309, 1, null);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (309, 2, null);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (309, 5, null);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (309, 6, null);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (309, 7, null);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (309, 8, null);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (309, 9, null);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (309, 10, null);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (309, 11, null);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (309, 12, null);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (309, 13, null);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (309, 14, null);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (309, 16, null);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
	  RAISE_APPLICATION_ERROR(-20500, SQLERRM);
END;