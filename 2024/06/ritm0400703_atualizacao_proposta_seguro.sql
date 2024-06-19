begin
  delete cecred.crawseg p where p.CDCOOPER = 1 and p.NRDCONTA = 6462650 and p.NRCTRSEG = 1804414 and p.NRCTRATO = 8267517 and p.NRPROPOSTA = '202406275288';
  delete cecred.crapseg p where p.CDCOOPER = 1 and p.NRDCONTA = 6462650 and p.NRCTRSEG = 1804414;
  delete cecred.tbseg_prestamista p where p.CDCOOPER = 1 and p.NRDCONTA = 6462650 and p.NRCTRSEG = 1804414 and p.NRCTREMP = 8267517 and p.NRPROPOSTA = '202406275288';  

  commit;
  
  update cecred.crawseg w set w.NRPROPOSTA = '202400163233' where w.CDCOOPER = 1 and w.NRDCONTA = 2678446 and w.NRCTRSEG = 1818370 and w.NRCTRATO = 1461972;            
  update cecred.crawseg w set w.NRPROPOSTA = '202400140294' where w.CDCOOPER = 1 and w.NRDCONTA = 2678446 and w.NRCTRSEG = 1818369 and w.NRCTRATO = 953275;            
                
  update cecred.tbseg_prestamista w set w.NRPROPOSTA = '202400163233' where w.CDCOOPER = 1 and w.NRDCONTA = 2678446 and w.NRCTRSEG = 1818370 and w.NRCTREMP = 1461972;            
  update cecred.tbseg_prestamista w set w.NRPROPOSTA = '202400140294' where w.CDCOOPER = 1 and w.NRDCONTA = 2678446 and w.NRCTRSEG = 1818369 and w.NRCTREMP = 953275;   
  
  commit;
end;  
