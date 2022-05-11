BEGIN
  
  UPDATE cecred.crapsli 
     SET dtrefere = to_date('31/05/2022','dd/mm/yyyy') 
   WHERE nrdconta = 191051 
     AND cdcooper = 9
     AND dtrefere = to_date('30/04/2022','dd/mm/yyyy');
  
  COMMIT;
  
  EXCEPTION 
      WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(-20000,'Ocorreu um erro ao atualizar o registro. Código do erro:'||SQLERRM);
  
END;
