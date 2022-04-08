BEGIN
 
     DELETE tbgen_batch_param t
       WHERE t.cdcooper   = 16
       AND   t.idparametro = 100
       AND t.cdprograma = 'CRPS515';
    
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
