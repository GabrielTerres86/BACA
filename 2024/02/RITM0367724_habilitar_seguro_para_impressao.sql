BEGIN
  update cecred.tbseg_prestamista p  set p.tpregist = 3, p.VLPRODUT = 2.42 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1129349 and p.NRCTREMP = 5917272 and p.NRPROPOSTA = '770658541285';
  update cecred.tbseg_prestamista p  set p.tpregist = 3, p.VLPRODUT = 3.81 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1129350 and p.NRCTREMP = 2499014 and p.NRPROPOSTA = '770658541307';
  update cecred.tbseg_prestamista p  set p.tpregist = 3, p.VLPRODUT = 0.35 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1129351 and p.NRCTREMP = 3243113 and p.NRPROPOSTA = '770658541315';
  update cecred.tbseg_prestamista p  set p.tpregist = 3, p.VLPRODUT = 0.99 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1129352 and p.NRCTREMP = 3719797 and p.NRPROPOSTA = '770658541323';
  update cecred.tbseg_prestamista p  set p.tpregist = 3, p.VLPRODUT = 0.5 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1129353 and p.NRCTREMP = 4034631 and p.NRPROPOSTA = '770658541331';
  update cecred.tbseg_prestamista p  set p.tpregist = 3, p.VLPRODUT = 0.94 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1129354 and p.NRCTREMP = 4039341 and p.NRPROPOSTA = '770658541340';
  update cecred.tbseg_prestamista p  set p.tpregist = 3, p.VLPRODUT = 0.88 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1371593 and p.NRCTREMP = 6788140 and p.NRPROPOSTA = '202304290001';

  update cecred.crapseg c set c.cdsitseg = 1, c.CDMOTCAN = 0, c.DTCANCEL = null, c.vlpremio = 2.42 where c.cdcooper = 1 and c.nrdconta = 10156690 and c.nrctrseg = 1129349;
  update cecred.crapseg c set c.cdsitseg = 1, c.CDMOTCAN = 0, c.DTCANCEL = null, c.vlpremio = 3.81 where c.cdcooper = 1 and c.nrdconta = 10156690 and c.nrctrseg = 1129350;
  update cecred.crapseg c set c.cdsitseg = 1, c.CDMOTCAN = 0, c.DTCANCEL = null, c.vlpremio = 0.35 where c.cdcooper = 1 and c.nrdconta = 10156690 and c.nrctrseg = 1129351;
  update cecred.crapseg c set c.cdsitseg = 1, c.CDMOTCAN = 0, c.DTCANCEL = null, c.vlpremio = 0.99 where c.cdcooper = 1 and c.nrdconta = 10156690 and c.nrctrseg = 1129352;
  update cecred.crapseg c set c.cdsitseg = 1, c.CDMOTCAN = 0, c.DTCANCEL = null, c.vlpremio = 0.5 where c.cdcooper = 1 and c.nrdconta = 10156690 and c.nrctrseg = 1129353;
  update cecred.crapseg c set c.cdsitseg = 1, c.CDMOTCAN = 0, c.DTCANCEL = null, c.vlpremio = 0.94 where c.cdcooper = 1 and c.nrdconta = 10156690 and c.nrctrseg = 1129354;
  update cecred.crapseg c set c.cdsitseg = 1, c.CDMOTCAN = 0, c.DTCANCEL = null, c.vlpremio = 0.88 where c.cdcooper = 1 and c.nrdconta = 10156690 and c.nrctrseg = 1371593;

  update cecred.crawseg p  set p.vlpremio = 2.42 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1129349 and p.nrctrato = 5917272 and p.NRPROPOSTA = '770658541285';
  update cecred.crawseg p  set p.vlpremio = 3.81 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1129350 and p.nrctrato = 2499014 and p.NRPROPOSTA = '770658541307';
  update cecred.crawseg p  set p.vlpremio = 0.35 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1129351 and p.nrctrato = 3243113 and p.NRPROPOSTA = '770658541315';
  update cecred.crawseg p  set p.vlpremio = 0.99 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1129352 and p.nrctrato = 3719797 and p.NRPROPOSTA = '770658541323';
  update cecred.crawseg p  set p.vlpremio = 0.5 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1129353 and p.nrctrato = 4034631 and p.NRPROPOSTA = '770658541331';
  update cecred.crawseg p  set p.vlpremio = 0.94 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1129354 and p.nrctrato = 4039341 and p.NRPROPOSTA = '770658541340';
  update cecred.crawseg p  set p.vlpremio = 0.88 where p.cdcooper = 1 and p.nrdconta = 10156690 and p.nrctrseg = 1371593 and p.nrctrato = 6788140 and p.NRPROPOSTA = '202304290001';

  COMMIT;
END;  
