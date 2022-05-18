begin
  
update cecred.crapfdc f
  set f.dtlibtic = null,
      f.cdbantic = 0,
      f.cdagetic = 0,
      f.nrctatic = 0,
      f.incheque = 8,
      f.dtliqchq = trunc(sysdate)
where  f.cdcooper = 16
  and  f.nrdconta = 761109
  and  f.nrcheque = 20;
  
commit;
end;


     
