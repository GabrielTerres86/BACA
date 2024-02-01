BEGIN
  
  DELETE cecred.tbcrd_utilizacao_cartao 
   WHERE dtmvtolt between '01/01/2023' and '30/11/2023';
   
  COMMIT;
  
END;   
