begin  
  update cecred.tbseg_prestamista p  set p.VLPRODUT = 0.01,  p.tpregist = 0 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1129349 and p.NRCTREMP = 5917272 and p.NRPROPOSTA = '770658541285';
  update cecred.tbseg_prestamista p  set p.VLPRODUT = 0.01,  p.tpregist = 0 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1129350 and p.NRCTREMP = 2499014 and p.NRPROPOSTA = '770658541307';
  update cecred.tbseg_prestamista p  set p.VLPRODUT = 0.01,  p.tpregist = 0 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1129351 and p.NRCTREMP = 3243113 and p.NRPROPOSTA = '770658541315';
  update cecred.tbseg_prestamista p  set p.VLPRODUT = 0.01,  p.tpregist = 0 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1129352 and p.NRCTREMP = 3719797 and p.NRPROPOSTA = '770658541323';
  update cecred.tbseg_prestamista p  set p.VLPRODUT = 0.01,  p.tpregist = 0 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1129353 and p.NRCTREMP = 4034631 and p.NRPROPOSTA = '770658541331';
  update cecred.tbseg_prestamista p  set p.VLPRODUT = 0.01,  p.tpregist = 0 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1129354 and p.NRCTREMP = 4039341 and p.NRPROPOSTA = '770658541340';
  update cecred.tbseg_prestamista p  set p.VLPRODUT = 0.01,  p.tpregist = 0 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1371593 and p.NRCTREMP = 6788140 and p.NRPROPOSTA = '202304290001';

  update cecred.crapseg c set c.vlpremio = 0.01, c.cdsitseg = 2, c.CDMOTCAN = 2, c.DTCANCEL = to_date('02/01/2024','dd/mm/yyyy')  where c.cdcooper = 1 and c.nrdconta = 10156690 and c.nrctrseg = 1129349;
  update cecred.crapseg c set c.vlpremio = 0.01, c.cdsitseg = 2, c.CDMOTCAN = 2, c.DTCANCEL = to_date('02/01/2024','dd/mm/yyyy')  where c.cdcooper = 1 and c.nrdconta = 10156690 and c.nrctrseg = 1129350;
  update cecred.crapseg c set c.vlpremio = 0.01, c.cdsitseg = 2, c.CDMOTCAN = 2, c.DTCANCEL = to_date('02/01/2024','dd/mm/yyyy')  where c.cdcooper = 1 and c.nrdconta = 10156690 and c.nrctrseg = 1129351;
  update cecred.crapseg c set c.vlpremio = 0.01, c.cdsitseg = 2, c.CDMOTCAN = 2, c.DTCANCEL = to_date('02/01/2024','dd/mm/yyyy')  where c.cdcooper = 1 and c.nrdconta = 10156690 and c.nrctrseg = 1129352;
  update cecred.crapseg c set c.vlpremio = 0.01, c.cdsitseg = 2, c.CDMOTCAN = 2, c.DTCANCEL = to_date('02/01/2024','dd/mm/yyyy')  where c.cdcooper = 1 and c.nrdconta = 10156690 and c.nrctrseg = 1129353;
  update cecred.crapseg c set c.vlpremio = 0.01, c.cdsitseg = 2, c.CDMOTCAN = 2, c.DTCANCEL = to_date('02/01/2024','dd/mm/yyyy')  where c.cdcooper = 1 and c.nrdconta = 10156690 and c.nrctrseg = 1129354;
  update cecred.crapseg c set c.vlpremio = 0.01, c.cdsitseg = 2, c.CDMOTCAN = 2, c.DTCANCEL = to_date('02/01/2024','dd/mm/yyyy')  where c.cdcooper = 1 and c.nrdconta = 10156690 and c.nrctrseg = 1371593;

  update cecred.crawseg p  set p.vlpremio = 0.01 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1129349 and p.nrctrato = 5917272 and p.NRPROPOSTA = '770658541285';
  update cecred.crawseg p  set p.vlpremio = 0.01 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1129350 and p.nrctrato = 2499014 and p.NRPROPOSTA = '770658541307';
  update cecred.crawseg p  set p.vlpremio = 0.01 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1129351 and p.nrctrato = 3243113 and p.NRPROPOSTA = '770658541315';
  update cecred.crawseg p  set p.vlpremio = 0.01 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1129352 and p.nrctrato = 3719797 and p.NRPROPOSTA = '770658541323';
  update cecred.crawseg p  set p.vlpremio = 0.01 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1129353 and p.nrctrato = 4034631 and p.NRPROPOSTA = '770658541331';
  update cecred.crawseg p  set p.vlpremio = 0.01 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1129354 and p.nrctrato = 4039341 and p.NRPROPOSTA = '770658541340';
  update cecred.crawseg p  set p.vlpremio = 0.01 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1371593 and p.nrctrato = 6788140 and p.NRPROPOSTA = '202304290001';

  commit;
end;
