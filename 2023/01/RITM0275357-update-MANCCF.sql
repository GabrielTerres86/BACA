Begin
  
 update cecred.crapneg c
   set c.flgctitg = 2
 where c.nrctachq = 237663
       and c.cdcooper = 14
       and c.nrdocmto = 531
       and c.dtiniest = to_date('27/12/2022','dd/mm/yyyy')
       and c.flgctitg = 4 ;
       
commit;
end;
