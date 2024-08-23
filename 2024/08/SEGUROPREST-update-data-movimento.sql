begin

update cecred.crawseg w
   set w.dtmvtolt = to_date('24/01/2024','dd/mm/yyyy'),
       w.dtinivig = to_date('24/01/2024','dd/mm/yyyy')
 where cdcooper = 11 
   and nrdconta = 99938421 
   and nrctrseg = 420534;
   
update cecred.crapseg s
   set s.dtmvtolt = to_date('24/01/2024','dd/mm/yyyy'),
       s.dtinivig = to_date('24/01/2024','dd/mm/yyyy')
 where cdcooper = 11 
   and nrdconta = 99938421 
   and nrctrseg = 420534;   
   
update cecred.tbseg_prestamista p
   set p.dtinivig = to_date('24/01/2024','dd/mm/yyyy')
 where cdcooper = 11 
   and nrdconta = 99938421 
   and nrctrseg = 420534;    
   
commit;
end;   
