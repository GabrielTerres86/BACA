begin
  delete cecred.crapseg c where c.NRCTRSEG = 12973  and c.NRDCONTA = 103896 and c.CDCOOPER = 7;
  delete cecred.crapseg c where c.NRCTRSEG = 70995  and c.NRDCONTA = 113972 and c.CDCOOPER = 10;
  delete cecred.crapseg c where c.NRCTRSEG = 586212 and c.NRDCONTA = 18502733 and c.CDCOOPER = 13;
  delete cecred.crapseg c where c.NRCTRSEG = 582940 and c.NRDCONTA = 15840972 and c.CDCOOPER = 13;
  commit;
  
  delete cecred.crapseg p where p.cdcooper = 1 and p.nrdconta = 80328733 and p.nrctrseg = 1724763;
  delete cecred.crawseg p where p.cdcooper = 1 and p.nrdconta = 80328733 and p.nrctrseg = 1724763;
  delete cecred.tbseg_prestamista p where p.cdcooper = 1 and p.nrdconta = 80328733 and p.nrctrseg = 1724763;
  
  commit;
  
end;
