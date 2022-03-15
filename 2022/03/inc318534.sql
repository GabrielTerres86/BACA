BEGIN
  UPDATE crapsli 
     SET dtrefere = to_date('31/03/2022','dd/mm/yyyy') 
   WHERE nrdconta = 256021 and cdcooper = 9;
  
  COMMIT;
  
  EXCEPTION 
      WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(-20000,'Ocorreu um erro ao atualizar o registro. Código do erro:'||SQLERRM);
  
end;
  
 
 



 
 
  


