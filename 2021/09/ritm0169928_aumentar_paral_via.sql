--RITM0169928
UPDATE tbgen_batch_param
   SET qtparalelo = 40
 WHERE cdcooper = 1
   AND cdprograma IN ('CRPS008','CRPS133', 'CRPS140', 'CRPS168');
UPDATE tbgen_batch_param
   SET qtparalelo = 30
 WHERE cdcooper = 1
   AND cdprograma = 'CRPS516';
COMMIT;
