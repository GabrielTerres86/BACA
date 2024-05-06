BEGIN
  UPDATE cecred.crapcyb a
     SET a.dtmancad =
         (SELECT b.dtmvtoan
            FROM crapdat b
           WHERE b.cdcooper = a.cdcooper)
        ,a.dtmanavl =
         (SELECT b.dtmvtoan
            FROM crapdat b
           WHERE b.cdcooper = a.cdcooper)
        ,a.dtmangar =
         (SELECT b.dtmvtoan
            FROM crapdat b
           WHERE b.cdcooper = a.cdcooper)
   WHERE a.cdcooper = 14
     AND a.dtatufin = to_date('14/11/2023', 'dd/mm/rrrr')
     AND a.dtdbaixa IS NULL;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
