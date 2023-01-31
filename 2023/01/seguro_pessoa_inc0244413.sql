BEGIN
  UPDATE CECRED.tbseg_prestamista p
     SET p.tpregist = 0
   WHERE p.cdcooper = 1
     AND p.nrdconta = 6177220
     AND p.nrctrseg = 1139441;
     
  UPDATE CECRED.crapseg p
     SET p.cdsitseg = 2
   WHERE p.cdcooper = 1
     AND p.nrdconta = 6177220
     AND p.nrctrseg = 1139441;
     
  UPDATE CECRED.crapseg p
     SET p.cdsitseg = 2
   WHERE p.cdcooper = 1
     AND p.nrdconta = 6177220
     AND p.nrctrseg = 1134306;

  UPDATE tbseg_prestamista p
     SET p.tpregist = 1
   WHERE p.nrproposta = '202208458811';
  
  COMMIT;
END;
/
