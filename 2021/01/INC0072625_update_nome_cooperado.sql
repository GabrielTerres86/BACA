begin
  update crapass c 
     set c.nmprimtl = 'DRAYTON ROGER LEBID'
   where c.cdcooper = 7
     and c.nrdconta = 91049;
     
  update crapttl t 
     set t.nmextttl = 'DRAYTON ROGER LEBID'
   where t.cdcooper = 7
     and t.nrdconta = 91049;
     
  commit;
end;