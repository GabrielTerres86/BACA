BEGIN
 
     DELETE tbgen_batch_param t
     WHERE t.cdcooper   = 16
     AND   t.idparametro in (101,103);
    
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
