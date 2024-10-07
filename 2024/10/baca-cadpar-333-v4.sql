BEGIN

  UPDATE cecred.crappat a SET a.cdpartar = 347 WHERE a.cdpartar = 333;

  UPDATE cecred.crappco a SET a.cdpartar = 347 WHERE a.cdpartar = 333;

  INSERT INTO cecred.crappat
    (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  VALUES
    (333, 'Desligar contratacao e pagamento de emprestimo', 1, 0);

  INSERT INTO cecred.crappco
    (CDPARTAR, CDCOOPER, DSCONTEU)
  VALUES
    (333, 1, '0');

  INSERT INTO cecred.crappco
    (CDPARTAR, CDCOOPER, DSCONTEU)
  VALUES
    (333, 2, '0');

  INSERT INTO cecred.crappco
    (CDPARTAR, CDCOOPER, DSCONTEU)
  VALUES
    (333, 3, '0');

  INSERT INTO cecred.crappco
    (CDPARTAR, CDCOOPER, DSCONTEU)
  VALUES
    (333, 5, '0');

  INSERT INTO cecred.crappco
    (CDPARTAR, CDCOOPER, DSCONTEU)
  VALUES
    (333, 6, '0');

  INSERT INTO cecred.crappco
    (CDPARTAR, CDCOOPER, DSCONTEU)
  VALUES
    (333, 7, '0');

  INSERT INTO cecred.crappco
    (CDPARTAR, CDCOOPER, DSCONTEU)
  VALUES
    (333, 8, '0');

  INSERT INTO cecred.crappco
    (CDPARTAR, CDCOOPER, DSCONTEU)
  VALUES
    (333, 9, '0');

  INSERT INTO cecred.crappco
    (CDPARTAR, CDCOOPER, DSCONTEU)
  VALUES
    (333, 10, '0');

  INSERT INTO cecred.crappco
    (CDPARTAR, CDCOOPER, DSCONTEU)
  VALUES
    (333, 11, '0');

  INSERT INTO cecred.crappco
    (CDPARTAR, CDCOOPER, DSCONTEU)
  VALUES
    (333, 12, '0');

  INSERT INTO cecred.crappco
    (CDPARTAR, CDCOOPER, DSCONTEU)
  VALUES
    (333, 13, '0');

  INSERT INTO cecred.crappco
    (CDPARTAR, CDCOOPER, DSCONTEU)
  VALUES
    (333, 14, '0');

  INSERT INTO cecred.crappco
    (CDPARTAR, CDCOOPER, DSCONTEU)
  VALUES
    (333, 16, '0');

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
