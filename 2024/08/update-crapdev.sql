begin
  
update cecred.crapdev v
  set v.cdalinea = 0
where  v.cdcooper = 12
  and  v.dtmvtolt = to_date('28/06/2024','dd/mm/yyyy');


commit;
end;
