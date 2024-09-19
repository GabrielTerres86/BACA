begin
  
delete cecred.craplft f
where  f.cdcooper = 1
  and  f.dtmvtolt = to_date('24/04/2024','dd/mm/yyyy')
  and  f.cdagenci = 90
  and  f.cdhistor = 4556;  

commit;
end;
