UPDATE crapprm 
   SET dsvlrprm = 0
 WHERE nmsistem = 'CRED'
   AND cdcooper = 0
   AND cdacesso = 'PRM_VALIDACAO_500';
   
COMMIT;