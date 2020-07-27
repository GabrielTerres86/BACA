--ritm0075145_aumento_paralelismo RITM0075145 paralelismo
UPDATE tbgen_batch_param SET qtparalelo = 80 WHERE cdprograma = 'CRPS445';
UPDATE tbgen_batch_param SET qtparalelo = 40 WHERE cdprograma = 'CRPS616';
COMMIT;
