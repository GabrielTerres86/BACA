BEGIN
  UPDATE tbgen_batch_param
   SET QTPARALELO = 20
   WHERE CDPROGRAMA = 'CRPS145' AND CDCOOPER = 1; 
  COMMIT;
   EXCEPTION
    WHEN OTHERS THEN
      SISTEMA.excecaoInterna(pr_compleme => 'PRB0047778');
      ROLLBACK;
  END;
  
