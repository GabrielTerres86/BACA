begin
  update cecred.tbseg_prestamista p set p.tpregist = 3, p.vlprodut = 0.61, p.vldevatu = 2009.39, p.dtdenvio=to_Date('01/07/2024','dd/mm/yyyy') where p.CDCOOPER = 1 and p.nrdconta = 10525866 and p.NRCTRSEG = 1812133 and p.NRCTREMP = 8122111 and p.NRPROPOSTA = '202406349235';
  update cecred.crapseg p set p.CDSITSEG = 1, p.DTCANCEL = null, p.VLPREMIO = 0.61, p.CDMOTCAN = 0 where p.CDCOOPER = 1 and p.nrdconta = 10525866 and p.NRCTRSEG = 1812133;
  update cecred.crawseg p set p.vlpremio = 0.61 where p.CDCOOPER = 1 and p.nrdconta = 10525866 and p.NRCTRSEG = 1812133 and p.nrctrato = 8122111 and p.NRPROPOSTA = '202406349235';   
  
  delete cecred.crawseg p where p.CDCOOPER = 1 and p.nrdconta = 10525866 and p.NRCTRSEG = 1846400 and p.nrctrato = 8122111 and p.NRPROPOSTA = '202406344583';   
  delete cecred.tbseg_prestamista p where p.CDCOOPER = 1 and p.nrdconta = 10525866 and p.NRCTRSEG = 1846400 and p.NRCTREMP = 8122111 and p.NRPROPOSTA = '202406344583';   
  delete cecred.crapseg p where p.CDCOOPER = 1 and p.nrdconta = 10525866 and p.NRCTRSEG = 1846400;   
 
  commit;
  
end;
