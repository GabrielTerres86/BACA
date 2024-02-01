BEGIN
  
  DELETE cecred.tbcrd_utilizacao_cartao 
   WHERE dtmvtolt between to_date('01/01/2023','dd/mm/yyyy') and to_date('30/11/2023','dd/mm/yyyy');
   
  COMMIT;
  
END;   
