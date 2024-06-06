BEGIN
  
 UPDATE cecred.tbgen_batch_paralelo a
    SET a.situacao = 2
  WHERE a.cdcooper = 6
    AND a.cdprogra = 'CRPS001'
    AND a.dtmvtolt = to_date('04/06/2024', 'dd/mm/yyyy');
    
 COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
END; 
