BEGIN

  delete from craptxi
   where cddindex = 5
     and dtiniper > to_date('01/05/2022','dd/mm/yyyy');
   
  COMMIT;
END;  
