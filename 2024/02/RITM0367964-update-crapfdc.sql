begin
  
update cecred.crapfdc c
  set c.incheque = 8, c.dtliqchq = trunc(sysdate)
where c.cdcooper = 1
   and c.nrdconta = 7577150 
   and c.nrcheque = 341;
   
update cecred.crapfdc c
  set c.incheque = 8, c.dtliqchq = trunc(sysdate)
where c.cdcooper = 14
   and c.nrdconta = 135682 
   and c.nrcheque = 589;
   
update cecred.crapfdc c
  set c.incheque = 8, c.dtliqchq = trunc(sysdate)
where c.cdcooper = 9
   and c.nrdconta = 333298 
   and c.nrcheque = 193;
   
commit;
end;
