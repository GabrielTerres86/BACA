begin
  
update cecred.crapfdc c
  set c.incheque = 8, c.dtliqchq = trunc(sysdate)
where c.cdcooper = 1
   and c.nrdconta = 9814086 
   and c.nrcheque in (25);
   
update cecred.crapfdc c
  set c.incheque = 8, c.dtliqchq = trunc(sysdate)
where c.cdcooper = 14
   and c.nrdconta = 135682 
   and c.nrcheque in (588);
   
commit;
end;
