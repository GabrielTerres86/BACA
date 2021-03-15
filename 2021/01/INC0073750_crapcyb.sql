UPDATE crapcyb x
   SET x.dtmanavl = ( SELECT dtmvtolt
                        FROM crapdat
                       WHERE cdcooper = 16)
 WHERE x.cdcooper = 16
   AND x.nrdconta = 2599619
   AND x.dtdbaixa IS NULL
   AND x.dtmanavl IS NOT NULL;

COMMIT;   
