begin
  
update cecred.craplau
  set craplau.dtdebito = to_date('24/09/2024','dd/mm/yyyy')
where craplau.nrdconta = 91923034 
  and cdcooper = 1 
  and craplau.nrdocmto = 10004080;

commit;
end;
