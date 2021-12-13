begin
  
update crapfdc c
  set c.cdbantic = 0, c.cdagetic = 0, c.nrctatic = 0
where  c.cdcooper = 9
  and  c.nrdconta = 1651
  and  c.nrcheque in (28548
                     ,28549
                     ,28550
                     ,28551
                     ,28552
                     ,28553
                     ,28554);
                     
commit;
end;
