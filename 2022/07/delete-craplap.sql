BEGIN
  
  DELETE craplap
   WHERE cdcooper = 1
     AND nrdconta = 834300
     AND dtmvtolt BETWEEN to_date('01/07/2022','dd/mm/yyyy') and to_date('31/07/2022','dd/mm/yyyy');
     
  COMMIT;
END;       
        
