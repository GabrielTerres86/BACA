
begin
  
update cecred.craplft t
  set  t.dtmvtolt = to_date('10/10/2024','dd/mm/yyyy'),
       t.dtvencto = to_date('10/10/2024','dd/mm/yyyy')
where  t.cdcooper = 9
  and  t.nrdconta = 82346569;

commit;
end;   
