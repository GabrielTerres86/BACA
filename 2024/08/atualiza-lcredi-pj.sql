begin 
update cecred.craplcr l
   set l.tppessoa = 0
where cdcooper = 7
   and l.cdlcremp = 10104;
commit;
end;  