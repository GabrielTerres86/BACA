begin
  
 update cecred.crapneg c
   set c.flgctitg = 2
 where c.nrdconta = 278912 
        and c.cdcooper = 9
        and c.nrdocmto in (1554, 1538) 
       and c.flgctitg = 4;
   
commit;
end;




