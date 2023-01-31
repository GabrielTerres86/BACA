begin
  
update cecred.crapfdc c
  set c.incheque = 8,
      c.dtliqchq = trunc(sysdate),
      c.dtretchq = trunc(sysdate)
where cdcooper = 13
   and nrctachq = 224464 
   and nrcheque in (41,42,43,44,45,46,47,48,49,50);
   
commit;
end;
