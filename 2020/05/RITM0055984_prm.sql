UPDATE crapprm x
   SET x.dsvlrprm = NULL 
WHERE x.cdacesso = 'ERRO_EMAIL_ESTEIRA'
  AND x.cdcooper = 2;
  
COMMIT;