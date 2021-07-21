BEGIN
  update crapfdc fdc
  set fdc.cdbantic = null, fdc.cdagetic = null, fdc.nrctatic = null, fdc.dtlibtic = null
where  cdcooper = 16
  and  nrdconta = 818798
  and  nrcheque in (5, 7, 17, 18);
commit;
END;
