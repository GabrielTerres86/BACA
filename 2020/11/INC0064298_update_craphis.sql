DECLARE
  CURSOR cr_craphis IS(
    SELECT his.rowid
      FROM cecred.craphis his
     WHERE his.cdhistor IN (2671, 2672, 2673, 2675, 2876)
       AND his.indcalds = 'N');
  rw_craphis cr_craphis%ROWTYPE;
BEGIN
  FOR his IN cr_craphis LOOP
    UPDATE cecred.craphis SET indcalds = 'S' WHERE ROWID = his.rowid;
  END LOOP;
  COMMIT;
END;
