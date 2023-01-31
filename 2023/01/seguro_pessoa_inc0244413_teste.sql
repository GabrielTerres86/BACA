BEGIN
  UPDATE CECRED.tbseg_prestamista p
     SET p.tpregist = 0
   WHERE p.cdcooper = 1
     AND p.nrdconta = 93822715
     AND p.nrctrseg = 1139441;
     
  UPDATE CECRED.crapseg p
     SET p.cdsitseg = 2
   WHERE p.cdcooper = 1
     AND p.nrdconta = 93822715
     AND p.nrctrseg = 1139441;
     
  UPDATE CECRED.crapseg p
     SET p.cdsitseg = 2
   WHERE p.cdcooper = 1
     AND p.nrdconta = 93822715
     AND p.nrctrseg = 1134306; 
  
  COMMIT;
END;
/
