begin
  delete cecred.CRAWSEG p where p.CDCOOPER = 1 and p.NRDCONTA = 7877234 AND P.NRCTRSEG = 1961983 and p.NRCTRATO = 8609578;
  delete cecred.tbseg_prestamista p where p.CDCOOPER = 1 and p.NRDCONTA = 7877234 AND P.NRCTRSEG = 1961983 and p.NRCTREMP = 8609578;
  delete cecred.crapseg p where p.CDCOOPER = 1 and p.NRDCONTA = 7877234 AND P.NRCTRSEG = 1961983;
  commit;
end; 
