
begin 

  update CECRED.craplau l
     set l.dtmvtopg = to_date('22/10/2024','dd/mm/yyyy')
   where l.cdcooper = 2
     and l.nrdconta = 99020432
     and l.vllanaut = 4 ;
  commit;                        
 
end;                        

