BEGIN

DELETE FROM cecred.tbgen_batch_paralelo bp
 WHERE bp.cdcooper = 16
   AND bp.dtmvtolt >= trunc(to_date('14/03/2024', 'dd/mm/yyyy'));
    
  COMMIT;  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END;