begin

delete cecred.crapndb b 
where b.cdcooper = 13
  and b.nrdconta = 345040
  and b.dtmvtolt = to_date('08/08/2024','dd/mm/yyyy');
  
commit;
end;  
