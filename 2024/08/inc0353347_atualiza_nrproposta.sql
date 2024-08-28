begin
  update cecred.crawseg w set w.NRPROPOSTA = '202410428644' where w.CDCOOPER = 1 and w.NRDCONTA = 843407 and w.NRCTRSEG = 1879113 and w.NRCTRATO = 5782319;                   
  update cecred.tbseg_prestamista w set w.NRPROPOSTA = '202410428644' where w.CDCOOPER = 1 and w.NRDCONTA = 843407 and w.NRCTRSEG = 1879113 and w.NRCTREMP = 5782319;            
  commit; 
end; 
