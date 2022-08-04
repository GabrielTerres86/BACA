BEGIN
  DELETE crapsda 
   WHERE cdcooper = 6
     AND dtmvtolt between to_date('07/06/2022','dd/mm/yyyy') and  to_date('30/06/2022','dd/mm/yyyy');
     
  COMMIT;
END;       
