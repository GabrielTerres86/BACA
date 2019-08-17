/*
  Script para remover registro de senha do segundo titular - INC0031982

  SELECT * FROM crapsnh WHERE progress_recid = 218044;
  
*/       
DELETE crapsnh WHERE progress_recid = 218044;

commit;