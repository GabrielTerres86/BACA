BEGIN
  DELETE crapsda 
   WHERE cdcooper = 6
     AND dtmvtolt = to_date('26/04/2022','dd/mm/yyyy');
     
  COMMIT;
END;       
