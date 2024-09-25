BEGIN
  DELETE cecred.tbgen_batch_paralelo a
   WHERE a.cdcooper = 7
     AND a.dtmvtolt >= to_date('20/09/2024', 'dd/mm/yyyy'); 
    
  COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
END;

