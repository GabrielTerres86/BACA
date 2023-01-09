begin
  
update cecred.crapfdc c
  set c.incheque = 8,
      c.dtliqchq = trunc(sysdate)
where cdcooper = 11 
   and nrctachq = 278939 
   and nrcheque = 2560;
   
commit;
end;
