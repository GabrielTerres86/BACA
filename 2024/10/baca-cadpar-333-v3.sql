BEGIN
  
  insert into cecred.crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  values (333, 'Desligar contratacao e pagamento de emprestimo', 1, 0);

  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (333, 1, '0');

  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (333, 2, '0');

  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (333, 3, '0');

  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (333, 5, '0');

  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (333, 6, '0');

  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (333, 7, '0');

  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (333, 8, '0');

  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (333, 9, '0');

  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (333, 10, '0');

  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (333, 11, '0');

  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (333, 12, '0');

  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (333, 13, '0');

  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (333, 14, '0');

  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (333, 16, '0');


  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;


