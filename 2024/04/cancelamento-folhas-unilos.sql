begin
  
update cecred.crapfdc c
  set c.incheque = 8, c.dtliqchq = trunc(sysdate)
where c.cdcooper = 6
   and c.nrdconta = 99798387 
   and c.nrcheque in (575);
   
commit;
end;
