BEGIN
  UPDATE cecred.craprda
     SET insaqtot = 1
   WHERE cdcooper = 1
     AND nrdconta = 8684723
     AND nraplica = 1;
  COMMIT;
EXCEPTION  
WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'INC026574');
    ROLLBACK;    
END;     
