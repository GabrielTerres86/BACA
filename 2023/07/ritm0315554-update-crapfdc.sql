begin
  
update cecred.crapfdc c
  set c.incheque = 8,
      c.dtliqchq = trunc(sysdate),
      c.dtretchq = trunc(sysdate)
where cdcooper = 2
   and nrctachq = 874990 
   and nrcheque in (11,12,13,14,15,16,17,18,19,20);
   
commit;
end;
