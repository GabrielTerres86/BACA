begin
  

update cecred.craplft t
  set  t.idanafrd = 0
where  t.cdcooper = 9
  and  t.nrdconta = 82346569
  and  t.dtmvtolt = to_date('09/10/2024','dd/mm/yyyy');


commit;
end;
