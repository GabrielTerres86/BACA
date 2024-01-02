UPDATE gestaoderisco.htrisco_central_retorno r
   SET r.DTREFERENCIA = to_date('31/12/2023','DD/MM/RRRR')
 WHERE r.DTREFERENCIA = to_date('31/12/2024','DD/MM/RRRR')
   and r.cdcooper = 3;    

COMMIT; 
