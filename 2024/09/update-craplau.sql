begin
  
update cecred.craplau
  set craplau.dtdebito = to_date('24/09/2024','dd/mm/yyyy')
where craplau.nrdconta = 8076901 
  and craplau.cdcooper = 1 
  and craplau.progress_recid = 42398793

commit;
end;
