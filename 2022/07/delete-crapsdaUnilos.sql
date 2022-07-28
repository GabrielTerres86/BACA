BEGIN
  DELETE crapsda 
   WHERE cdcooper = 6
     AND dtmvtolt between to_date('29/04/2022','dd/mm/yyyy') and to_date('02/05/2022','dd/mm/yyyy');
     
  COMMIT;
END;       
