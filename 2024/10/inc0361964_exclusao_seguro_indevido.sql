begin
  delete cecred.CRAWSEG p where p.CDCOOPER = 16 and p.NRDCONTA = 73687 AND P.NRCTRSEG = 470407 and p.NRCTRATO = 883300;
  delete cecred.tbseg_prestamista p where p.CDCOOPER = 16 and p.NRDCONTA = 73687 AND P.NRCTRSEG = 470407 and p.NRCTREMP = 883300;
  delete cecred.crapseg p where p.CDCOOPER = 16 and p.NRDCONTA = 73687 AND P.NRCTRSEG = 470407;
  commit;
end;  
