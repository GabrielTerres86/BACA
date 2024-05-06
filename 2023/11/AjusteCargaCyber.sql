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
        ,a.dtatufin =
         (SELECT b.dtmvtoan
            FROM crapdat b
           WHERE b.cdcooper = a.cdcooper)
   WHERE a.cdcooper = 14
     AND a.dtdbaixa IS NULL;
  COMMIT;
END;
