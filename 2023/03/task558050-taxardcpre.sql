BEGIN
  UPDATE cecred.crapttx 
     SET qtdiaini = 30 
   WHERE tptaxrdc = 7 
     AND cdcooper = 13 
     AND cdperapl = 1; 
     
  COMMIT;
  
 EXCEPTION
    WHEN OTHERS THEN
      SISTEMA.excecaoInterna(pr_compleme => 'RITM0288800');
      ROLLBACK;
END;
