BEGIN
  
  UPDATE cecred.craptxi
     SET dtcadast = to_date('10/08/2022','dd/mm/yyyy')
   WHERE cddindex = 5
     AND dtiniper = to_date('01/07/2022','dd/mm/yyyy');
  
  COMMIT;
 
END;
