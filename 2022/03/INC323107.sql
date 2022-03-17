BEGIN

  BEGIN
      UPDATE crapsli sli
         SET sli.vlsddisp = 79403.06
       WHERE sli.nrdconta = 364843
         AND sli.cdcooper = 9;
       
  EXCEPTION 
       WHEN OTHERS THEN
          raise_application_error(-20000,'Ocorreu um erro ao atualizar o registro da tabela CRAPSLI. Código do erro:'||SQLERRM);   
  END;
  
  BEGIN
      UPDATE crapsli 
         SET dtrefere = to_date('31/03/2022','dd/mm/yyyy') 
       WHERE nrdconta = 256021 and cdcooper = 9;    
      
  EXCEPTION 
      WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(-20001,'Ocorreu um erro ao atualizar o registro. Código do erro:'||SQLERRM);
  END;
  
  COMMIT;
  
END;
  
  
  



  
