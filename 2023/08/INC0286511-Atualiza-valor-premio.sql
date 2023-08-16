BEGIN   
  update cecred.crawseg s set s.vlpremio = 467.84 where s.nrdconta   = 83810 and s.CDCOOPER =  14 and s.NRCTRSEG = 77605  and s.NRPROPOSTA = '202309027071';
  update cecred.crapseg s set s.vlpremio = 467.84 where s.nrdconta   = 83810 and s.CDCOOPER =  14 and s.NRCTRSEG = 77605;      
  COMMIT;
END; 
