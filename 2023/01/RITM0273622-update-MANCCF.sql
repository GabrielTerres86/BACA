Begin
  
 update cecred.crapneg c
   set c.flgctitg = 2
 where c.nrctachq=6732038
       and c.cdcooper = 1
       and c.nrdocmto = 574
       and c.dtiniest = to_date('06/12/2022','dd/mm/yyyy')
       and c.flgctitg = 4 ;
       
  update cecred.crapneg c
   set c.flgctitg = 2
 where c.nrctachq=6089887
       and c.cdcooper = 1
       and c.nrdocmto in (2690,2674)
       and c.dtiniest = to_date('14/11/2022','dd/mm/yyyy')
       and c.flgctitg = 4 ;
       
  update cecred.crapneg c
   set c.flgctitg = 2
 where c.nrctachq=10113061
       and c.cdcooper = 1
       and c.nrdocmto = 175
       and c.dtiniest = to_date('21/11/2022','dd/mm/yyyy')
       and c.flgctitg = 4 ;       
       
commit;
end;
