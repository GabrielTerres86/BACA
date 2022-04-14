begin
  
update cecred.crapfdc f 
  set f.incheque = 8, f.dtretchq = trunc(sysdate), f.dtliqchq = trunc(sysdate), f.dtemschq = trunc(sysdate)
where  f.cdcooper = 14
  and  f.nrdconta in (47724,63142)
  and  f.nrpedido = 123024
  and  f.nrcheque in (21,22,23,24,25,26,27,28,29,30,91,92,93,94,95,96,97,98,99,100);
  
commit;
end;
