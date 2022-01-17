UPDATE tbgen_batch_param t SET t.qtparalelo = 30
 WHERE t.cdcooper = 1 AND t.cdprograma IN ('CRPS310', 'CRPS515');
 
 COMMIT;
