begin
  delete cecred.crawseg p where p.CDCOOPER = 1 and p.NRDCONTA = 3796299 and p.NRCTRSEG = 1896250 and p.NRCTRATO = 8478912 and p.NRPROPOSTA = '202410428644';
  delete cecred.tbseg_prestamista p where p.CDCOOPER = 1 and p.NRDCONTA = 3796299 and p.NRCTRSEG = 1896250 and p.NRCTREMP = 8478912 and p.NRPROPOSTA = '202410428644';
  delete cecred.crapseg p where p.CDCOOPER = 1 and p.NRDCONTA = 3796299 and p.NRCTRSEG = 1896250;
  commit;
end;  
