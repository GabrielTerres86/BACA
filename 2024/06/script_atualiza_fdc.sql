begin
  update cecred.crapfdc 
     set dtretchq = '01/06/2024'
     where dtretchq is null 
     and nrdconta = 82921288
     and cdcooper = 12;
  commit;   
end;

