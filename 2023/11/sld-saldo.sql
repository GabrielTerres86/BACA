BEGIN
update cecred.crapsld 
   set dtrefere = to_date('16/11/2023','dd/mm/yyyy')
 where cdcooper = 11
   and dtrefere >= '01/10/2023';
   COMMIT;
END;   
