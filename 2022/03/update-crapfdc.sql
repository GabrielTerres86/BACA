begin

update cecred.crapfdc f 
  set f.incheque = 8,
      f.dtliqchq = trunc(sysdate) 
where  f.cdcooper = 1
  and  f.nrdconta = 11755326
  and  f.nrcheque in (26, 27); 
  
commit;
end;
