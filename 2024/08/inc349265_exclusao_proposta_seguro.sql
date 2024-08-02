begin
  delete cecred.crawseg w
   where w.nrdconta = 15127214
     AND W.CDCOOPER = 1
     AND W.NRCTRATO = 8448891
     AND W.NRPROPOSTA = '202400161261';

  delete cecred.TBSEG_PRESTAMISTA P
   where P.nrdconta = 15127214
     AND P.CDCOOPER = 1
     AND P.NRCTREMP = 8448891
     AND P.NRPROPOSTA = '202400161261';

  delete cecred.CRAPSEG S
   WHERE S.NRCTRSEG = 1875982
     AND S.nrdconta = 15127214
     AND S.CDCOOPER = 1;
     
  commit;
end; 
