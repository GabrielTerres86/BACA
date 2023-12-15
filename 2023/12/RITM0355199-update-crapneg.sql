begin
  
 update cecred.crapneg c
   set c.flgctitg = 2
 where c.nrdconta = 82198
       and c.cdcooper = 13
       and c.nrdocmto = 124
       and c.dtiniest = to_date('23/11/2023','dd/mm/yyyy')
       and c.flgctitg = 4 ;
   
commit;
end;




