--ritm0136193 aumentar sess�es paralelas
UPDATE TBGEN_BATCH_PARAM T
   SET T.QTPARALELO = 50
 WHERE T.CDPROGRAMA = 'CRPS723'
   AND T.CDCOOPER = 1;
COMMIT;