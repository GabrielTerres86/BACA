
update craprpp
   set dtvctopp = to_date('31/07/2020','dd/mm/rrrr')
 where cdprodut = 1007 
   and cdsitrpp <> 5 
   and dtvctopp < to_date('30/04/2020','dd/mm/rrrr');
   
commit;