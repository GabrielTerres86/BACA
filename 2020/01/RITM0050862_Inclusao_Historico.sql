--RITM0050862 - Inclusao dos historicos 2846 e 2857

UPDATE crapprm
   SET dsvlrprm = DSVLRPRM || ';2846;2857'
 WHERE cdacesso = 'HIS_CRED_RECEBIDOS';
 
 COMMIT;