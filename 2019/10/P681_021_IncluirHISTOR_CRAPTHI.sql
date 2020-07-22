BEGIN
  INSERT INTO CECRED.CRAPTHI (CDHISTOR, DSORIGEM, VLTARIFA, CDCOOPER)
    SELECT t.cdhistor, 'AIMARO', 0, t.cdcooper
      FROM craphis t
     WHERE NOT EXISTS (SELECT 1
              FROM crapthi x
             WHERE x.cdcooper = t.cdcooper
               AND x.cdhistor = t.cdhistor);

  INSERT INTO CECRED.CRAPTHI (CDHISTOR, DSORIGEM, VLTARIFA, CDCOOPER)
    SELECT t.cdhistor, 'CAIXA', 0, t.cdcooper
      FROM craphis t
     WHERE NOT EXISTS (SELECT 1
              FROM crapthi x
             WHERE x.cdcooper = t.cdcooper
               AND x.cdhistor = t.cdhistor);

  INSERT INTO CECRED.CRAPTHI (CDHISTOR, DSORIGEM, VLTARIFA, CDCOOPER)
    SELECT t.cdhistor, 'INTERNET', 0, t.cdcooper
      FROM craphis t
     WHERE NOT EXISTS (SELECT 1
              FROM crapthi x
             WHERE x.cdcooper = t.cdcooper
               AND x.cdhistor = t.cdhistor);

  INSERT INTO CECRED.CRAPTHI (CDHISTOR, DSORIGEM, VLTARIFA, CDCOOPER)
    SELECT t.cdhistor, 'CASH', 0, t.cdcooper
      FROM craphis t
     WHERE NOT EXISTS (SELECT 1
              FROM crapthi x
             WHERE x.cdcooper = t.cdcooper
               AND x.cdhistor = t.cdhistor);

  COMMIT;

END;
