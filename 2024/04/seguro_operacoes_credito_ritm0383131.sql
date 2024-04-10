BEGIN
   DELETE cecred.crapseg p WHERE p.cdcooper = 1 AND p.nrdconta = 80023185 AND p.nrctrseg = 1743097;
   DELETE cecred.crawseg p WHERE p.cdcooper = 1 AND p.nrdconta = 80023185 AND p.nrctrseg = 1743097;
   DELETE cecred.tbseg_prestamista p WHERE p.cdcooper = 1 AND p.nrdconta = 80023185 AND p.nrctrseg = 1743097;
COMMIT;
END;
/