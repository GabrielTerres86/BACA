BEGIN
  UPDATE cecred.crapcyb a
     SET a.dtmancad =
         (SELECT b.dtmvtoan
            FROM cecred.crapdat b
           WHERE b.cdcooper = a.cdcooper)
        ,a.dtmanavl =
         (SELECT b.dtmvtoan
            FROM cecred.crapdat b
           WHERE b.cdcooper = a.cdcooper)
        ,a.dtmangar =
         (SELECT b.dtmvtoan
            FROM cecred.crapdat b
           WHERE b.cdcooper = a.cdcooper)
        ,a.dtatufin =
         (SELECT b.dtmvtoan
            FROM cecred.crapdat b
           WHERE b.cdcooper = a.cdcooper)
   WHERE a.cdcooper = 8
     AND a.dtdbaixa IS NULL;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
