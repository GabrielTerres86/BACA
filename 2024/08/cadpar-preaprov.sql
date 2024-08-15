BEGIN
  
  insert into cecred.crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  values (323, 'Pre-Aprovado fluxo IFRS9', 1, 0);  
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (323, 7, '0');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (323, 16, '0');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (323, 12, '0');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (323, 6, '0');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (323, 9, '0');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (323, 1, '0');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (323, 2, '0');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (323, 13, '0');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (323, 3, '1');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (323, 10, '0');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (323, 14, '0');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (323, 5, '0');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (323, 8, '0');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (323, 11, '0');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
