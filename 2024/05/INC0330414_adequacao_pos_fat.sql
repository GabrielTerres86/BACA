begin
  update cecred.crapseg p set p.cdsitseg = 1 where  p.NRDCONTA = 15390772 and p.NRCTRSEG = 192184 and p.CDCOOPER = 7;   
  commit;
  delete cecred.crawseg p where p.cdcooper = 1 and p.NRDCONTA = 2269686 and p.nrctrato = 8182559 and p.NRCTRSEG = 1778740 and p.NRPROPOSTA = '202406252576';
  delete cecred.crapseg p where p.cdcooper = 1 and p.NRDCONTA = 2269686 and p.NRCTRSEG = 1778740;
  delete cecred.tbseg_prestamista p where p.cdcooper = 1 and p.NRDCONTA = 2269686 and p.NRCTREMP = 8182559 and p.NRCTRSEG = 1778740 and p.NRPROPOSTA = '202406252576';
  commit;
end;
