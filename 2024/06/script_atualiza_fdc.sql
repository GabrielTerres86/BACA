begin
  update cecred.crapfdc 
     set dtretchq = to_date('01/06/2024','dd/mm/yyyy')
     where dtretchq is null 
     and nrdconta = 82921288
     and cdcooper = 12;
  commit;   
end;

