begin
  update cecred.crapfdc 
     set nrctachq = 82921288,
         nrdctabb = 82921288 
     where dtretchq = to_date('01/06/2024','dd/mm/yyyy') 
       and nrdconta = 82921288
       and cdcooper = 12;
  commit;   
end;


