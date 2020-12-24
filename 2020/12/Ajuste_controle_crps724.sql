UPDATE crapprm
   SET dsvlrprm = '24/12/2020#4'
 WHERE cdcooper NOT IN (3, 4, 15, 17)
   AND cdacesso = 'CTRL_CRPS724_EXEC';
   
commit;
