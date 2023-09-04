begin
  
update cecred.crapfdc c
  set c.incheque = 8,
      c.dtliqchq = trunc(sysdate),
      c.dtretchq = trunc(sysdate)
where c.cdcooper = 16
   and c.nrctachq = 644749 
   and c.incheque = 0;
   
commit;
end;
