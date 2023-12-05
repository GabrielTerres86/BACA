begin
  
update cecred.crapfdc c
  set c.incheque = 8,
      c.dtliqchq = trunc(sysdate),
      c.dtretchq = trunc(sysdate)
where c.cdcooper = 13
   and c.nrdconta = 710229 
   and c.nrcheque in (31, 32, 33, 34, 35, 36, 37, 38, 39, 40);
   
commit;
end;