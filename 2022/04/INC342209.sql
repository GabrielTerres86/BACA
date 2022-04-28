BEGIN
  
  BEGIN
    UPDATE cecred.crapsli
       SET dtrefere = to_date('30/04/2022','dd/mm/yyyy')
     WHERE nrdconta = 732001
       AND dtrefere = to_date('31/03/2022','dd/mm/yyyy')
       AND cdcooper = 16;
  
  EXCEPTION
     WHEN OTHERS THEN 
       ROLLBACK;
       RAISE_APPLICATION_ERROR(-20001,'Ocorreu um problema ao atualizar o registro da tabela crapsli.'||SQLERRM);
  END;     
    
  COMMIT;
   
END;

