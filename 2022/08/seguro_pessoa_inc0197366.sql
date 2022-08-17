BEGIN
  UPDATE cecred.tbseg_prestamista p
     SET p.tpregist = 3
   WHERE p.cdcooper = 13
     AND p.nrproposta = '770629332928';

  UPDATE cecred.crapseg p
     SET p.cdmotcan = 20
   WHERE p.cdcooper = 13
     AND p.nrdconta = 654116
     AND p.nrctrseg = 347849
     AND p.tpseguro = 4;

  UPDATE cecred.tbseg_prestamista p
     SET p.tpregist = 3
   WHERE p.cdcooper = 16
     AND p.nrproposta = '770658370626';

  UPDATE cecred.crapseg p
     SET p.cdmotcan = 20
   WHERE p.cdcooper = 16
     AND p.nrdconta = 277819
     AND p.nrctrseg = 214705
     AND p.tpseguro = 4;
  COMMIT;
END;
/
