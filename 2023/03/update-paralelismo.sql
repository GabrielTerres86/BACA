BEGIN
  
  UPDATE cecred.tbgen_batch_param
     SET QTPARALELO = 20
   WHERE cdprograma = 'CRPS145'
     AND cdcooper = 1;;

  COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'INC0255410');
    ROLLBACK; 
    
END;
