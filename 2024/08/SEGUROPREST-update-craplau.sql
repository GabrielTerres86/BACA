begin
update cecred.craplau l
   set l.dtmvtolt = to_date('24/01/2024','dd/mm/yyyy'),
       l.dtmvtopg = to_date('24/01/2024','dd/mm/yyyy'),
       l.dtrefatu = to_date('24/01/2024','dd/mm/yyyy')
 where l.cdcooper = 11
   and l.nrdconta = 99938421
   and l.nrctremp = 440037
   and l.nrdocmto = 99594128;
commit;
end;  
