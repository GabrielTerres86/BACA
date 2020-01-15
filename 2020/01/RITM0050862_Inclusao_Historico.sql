--RITM0050862 - Inclusao dos historicos 2846 e 2857 - RITM0056180 - Inclusao dos historicos 2870 e 2859 

UPDATE crapprm
   SET dsvlrprm = DSVLRPRM || ';2846;2857;2870;2859'
 WHERE cdacesso = 'HIS_CRED_RECEBIDOS';
 
 COMMIT;