begin
  delete cecred.crapseg p where p.NRDCONTA = 2604930 and p.CDCOOPER = 1 and p.NRCTRSEG = 1528785;
  delete cecred.crawseg p where p.NRDCONTA = 2604930 and p.CDCOOPER = 1 and p.NRCTRSEG = 1528785 and p.NRCTRATO = 7410074;
  commit;
end;
