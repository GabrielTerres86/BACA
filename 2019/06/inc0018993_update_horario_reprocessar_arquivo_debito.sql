
--Executar
UPDATE crapprm 
   SET crapprm.dsvlrprm = '09:00;18:00'
WHERE progress_recid = 19224;

/*
--Rollback 09:00;10:00
UPDATE crapprm 
   SET crapprm.dsvlrprm = '09:00;10:00'
WHERE progress_recid = 19224;

*/

COMMIT;
