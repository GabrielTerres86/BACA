update craprli c
   set c.qtmeslic = 2 
 where c.tplimite = 1;
   
update craprli c
   set c.qtmeslic = 4 
 where c.tplimite = 1
   and c.cdcooper = 11;

 COMMIT;