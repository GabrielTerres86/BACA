begin
  delete cecred.tbseg_prestamista p where p.cdcooper = 1 and p.NRDCONTA = 6767583 and p.NRCTREMP = 2729042 and p.NRCTRSEG = 477493 and p.NRPROPOSTA = '770349681145';
  commit;
  update cecred.crawseg w set w.NRPROPOSTA = '202410427414' where w.CDCOOPER = 1 and w.NRDCONTA = 6767583 and w.NRCTRSEG = 1924744 and w.NRCTRATO = 2729042;                   
  update cecred.tbseg_prestamista w set w.NRPROPOSTA = '202410427414' where w.CDCOOPER = 1 and w.NRDCONTA = 6767583 and w.NRCTRSEG = 1924744 and w.NRCTREMP = 2729042;              
  commit;  
end; 

