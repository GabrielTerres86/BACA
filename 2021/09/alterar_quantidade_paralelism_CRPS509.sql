-- Altera a quantidade de paralelismo da CRPS509

UPDATE tbgen_batch_param
   SET QTPARALELO = 07
 WHERE CDPROGRAMA = 'CRPS509'
   AND CDCOOPER = 1;
   
COMMIT;