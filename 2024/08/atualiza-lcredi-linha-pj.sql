begin

update cecred.craplcr l 
   set l.tppessoa = 0
 where cdcooper = 5 
   and l.cdlcremp = 703;
   
commit;
end;   