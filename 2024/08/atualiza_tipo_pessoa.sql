begin 
  update cecred.craplcr l
     set l.tppessoa = 0
  where cdcooper = 11
     and l.cdlcremp = 281;
  commit;
end;  
