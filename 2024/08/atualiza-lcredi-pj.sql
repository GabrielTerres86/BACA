begin 
  update cecred.craplcr l
     set l.tppessoa = 0
   where cdcooper = 13
     and l.cdlcremp = 305;
  commit;
end;  