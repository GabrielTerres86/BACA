begin  
  update  cecred.crawseg c set c.NRPROPOSTA = '202308549767' where c.CDCOOPER = 1 and c.NRDCONTA = 7556420 and NRCTRSEG = 1593997;
  commit;
  update cecred.crawseg c  set c.NRPROPOSTA = '770359954433',  c.nrctrato = 3642471 where c.CDCOOPER = 1 and c.NRDCONTA = 11033410 and NRCTRSEG = 1593998;
  commit;
end;  
