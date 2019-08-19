/*Erros gerados ao executar as tasks*/

SELECT cnk.error_code, cnk.error_message 
  FROM dbms_parallel_execute_chunks$ cnk
 WHERE trim(cnk.error_message) IS NOT NULL
