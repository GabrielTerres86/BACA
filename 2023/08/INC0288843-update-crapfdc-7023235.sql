begin
  
update cecred.crapfdc c
  set c.incheque = 8,
      c.dtliqchq = trunc(sysdate),
      c.dtretchq = trunc(sysdate)
where c.cdcooper = 1
   and c.nrctachq = 7023235 
   and c.nrcheque in (193,194,195,196,197,198,199,200,201,202);
   
commit;
end;
