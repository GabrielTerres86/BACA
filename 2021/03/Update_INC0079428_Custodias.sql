update crapfdc c
  set c.cdbantic = 0, c.cdagetic = 0, c.nrctatic = 0, c.dtlibtic = null
where  cdcooper = 1
  and  nrdconta in (2041928,7614659)
  and  nrcheque in (452,453,454,455,21,22,23,24,25,26,27,28,29,30,41,42,43,44)
  and  dtatutic = '04/11/2019';
  
update crapfdc c
  set c.cdbantic = 0, c.cdagetic = 0, c.nrctatic = 0, c.dtlibtic = null
where  cdcooper = 1
  and  nrdconta = 10488456
  and  nrcheque = 33
  and  dtatutic = '05/08/2020';  
commit;    
