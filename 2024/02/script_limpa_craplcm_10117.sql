begin
delete cecred.craplcm
 where cdcooper = 1
   and dtmvtolt = to_date('17/10/2023','dd/mm/yyyy')
   and nrdolote = 10117;

delete cecred.crapsol 
       where nrsolici = 78;

update cecred.crapdev
   set insitdev = 0, cddevolu = 0
 where insitdev = 1
   and cdcooper = 1;

commit;
end;
