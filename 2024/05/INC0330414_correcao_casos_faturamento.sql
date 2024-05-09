begin
  update cecred.tbseg_prestamista p set p.TPREGIST = 2 where p.CDCOOPER = 13 and p.NRDCONTA = 704504 and P.NRCTRSEG = 337467 and p.NRCTREMP = 200249;
  commit;

  Update cecred.tbseg_prestamista p set p.VLPRODUT = 2.52  where p.NRCTREMP = 5743822 and p.nrproposta = '770656107456' and p.cdcooper = 1 and p.nrctrseg = 1181853 and p.nrdconta = 2628040;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 104.4 where p.NRCTREMP = 738558 and p.nrproposta = '202315165461' and p.cdcooper = 16 and p.nrctrseg = 358389 and p.nrdconta = 58858;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 66.03 where p.NRCTREMP = 6760589 and p.nrproposta = '202304351543' and p.cdcooper = 1 and p.nrctrseg = 1425719 and p.nrdconta = 7640609;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 69.13 where p.NRCTREMP = 727589 and p.nrproposta = '202308532139' and p.cdcooper = 16 and p.nrctrseg = 352455 and p.nrdconta = 6330673;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 104.4 where p.NRCTREMP = 7590978 and p.nrproposta = '202319594353' and p.cdcooper = 1 and p.nrctrseg = 1680037 and p.nrdconta = 2738988;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 104.4 where p.NRCTREMP = 4996320 and p.nrproposta = '770355636038' and p.cdcooper = 1 and p.nrctrseg = 923093 and p.nrdconta = 3928217;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 104.4 where p.NRCTREMP = 6932864 and p.nrproposta = '202304319058' and p.cdcooper = 1 and p.nrctrseg = 1398302 and p.nrdconta = 2664259;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 45.58 where p.NRCTREMP = 7796144 and p.nrproposta = '202319679113' and p.cdcooper = 1 and p.nrctrseg = 1693819 and p.nrdconta = 4505280;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 1.95  where p.NRCTREMP = 758680 and p.nrproposta = '202319707457' and p.cdcooper = 16 and p.nrctrseg = 398652 and p.nrdconta = 16457595;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 104.4 where p.NRCTREMP = 6975564 and p.nrproposta = '202308546051' and p.cdcooper = 1 and p.nrctrseg = 1439529 and p.nrdconta = 9020233;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 49.20 where p.NRCTREMP = 107766 and p.nrproposta = '202304262311' and p.cdcooper = 7 and p.nrctrseg = 157176 and p.nrdconta = 308072;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 17.48 where p.NRCTREMP = 119957 and p.nrproposta = '202315154752' and p.cdcooper = 7 and p.nrctrseg = 178793 and p.nrdconta = 18511;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 104.4 where p.NRCTREMP = 4667762 and p.nrproposta = '770356997972' and p.cdcooper = 1 and p.nrctrseg = 866143 and p.nrdconta = 648086;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 104.4 where p.NRCTREMP = 6016942 and p.nrproposta = '770658862880' and p.cdcooper = 1 and p.nrctrseg = 1267816 and p.nrdconta = 3891917;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 104.4 where p.NRCTREMP = 968466 and p.nrproposta = '770349723204' and p.cdcooper = 1 and p.nrctrseg = 702454 and p.nrdconta = 2327503;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 6.35  where p.NRCTREMP = 1828913 and p.nrproposta = '202319707474' and p.cdcooper = 1 and p.nrctrseg = 1709091 and p.nrdconta = 850063;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 104.4 where p.NRCTREMP = 4643519 and p.nrproposta = '770356038193' and p.cdcooper = 1 and p.nrctrseg = 903460 and p.nrdconta = 12180920;

  Update cecred.CRAWSEG p set p.VLPREMIO = 2.52   where p.NRCTRATO = 5743822 and p.nrproposta = '770656107456' and p.cdcooper = 1 and p.nrctrseg = 497431  and p.nrdconta= 2628040;
  Update cecred.CRAWSEG p set p.VLPREMIO = 104.4  where p.NRCTRATO = 738558 and p.nrproposta = '202315165461' and p.cdcooper = 1 and p.nrctrseg = 497431  and p.nrdconta= 58858;
  Update cecred.CRAWSEG p set p.VLPREMIO = 66.03  where p.NRCTRATO = 6760589 and p.nrproposta = '202304351543' and p.cdcooper = 1 and p.nrctrseg = 497431  and p.nrdconta= 7640609;
  Update cecred.CRAWSEG p set p.VLPREMIO = 69.13  where p.NRCTRATO = 727589 and p.nrproposta = '202308532139' and p.cdcooper = 1 and p.nrctrseg = 497431  and p.nrdconta= 6330673;
  Update cecred.CRAWSEG p set p.VLPREMIO = 104.4  where p.NRCTRATO = 7590978 and p.nrproposta = '202319594353' and p.cdcooper = 1 and p.nrctrseg = 497431  and p.nrdconta= 2738988;
  Update cecred.CRAWSEG p set p.VLPREMIO = 104.4  where p.NRCTRATO = 4996320 and p.nrproposta = '770355636038' and p.cdcooper = 1 and p.nrctrseg = 497431  and p.nrdconta= 3928217;
  Update cecred.CRAWSEG p set p.VLPREMIO = 104.4  where p.NRCTRATO = 6932864 and p.nrproposta = '202304319058' and p.cdcooper = 1 and p.nrctrseg = 497431  and p.nrdconta= 2664259;
  Update cecred.CRAWSEG p set p.VLPREMIO = 45.58  where p.NRCTRATO = 7796144 and p.nrproposta = '202319679113' and p.cdcooper = 1 and p.nrctrseg = 497431  and p.nrdconta= 4505280;
  Update cecred.CRAWSEG p set p.VLPREMIO = 1.95   where p.NRCTRATO = 758680 and p.nrproposta = '202319707457' and p.cdcooper = 1 and p.nrctrseg = 497431  and p.nrdconta= 16457595;
  Update cecred.CRAWSEG p set p.VLPREMIO = 104.4  where p.NRCTRATO = 6975564 and p.nrproposta = '202308546051' and p.cdcooper = 1 and p.nrctrseg = 497431  and p.nrdconta= 9020233;
  Update cecred.CRAWSEG p set p.VLPREMIO = 49.20  where p.NRCTRATO = 107766 and p.nrproposta = '202304262311' and p.cdcooper = 1 and p.nrctrseg = 497431  and p.nrdconta= 308072;
  Update cecred.CRAWSEG p set p.VLPREMIO = 17.48  where p.NRCTRATO = 119957 and p.nrproposta = '202315154752' and p.cdcooper = 1 and p.nrctrseg = 497431  and p.nrdconta= 18511;
  Update cecred.CRAWSEG p set p.VLPREMIO = 104.4  where p.NRCTRATO = 4667762 and p.nrproposta = '770356997972' and p.cdcooper = 1 and p.nrctrseg = 497431  and p.nrdconta= 648086;
  Update cecred.CRAWSEG p set p.VLPREMIO = 104.4  where p.NRCTRATO = 6016942 and p.nrproposta = '770658862880' and p.cdcooper = 1 and p.nrctrseg = 497431  and p.nrdconta= 3891917;
  Update cecred.CRAWSEG p set p.VLPREMIO = 104.4  where p.NRCTRATO = 968466 and p.nrproposta = '770349723204' and p.cdcooper = 1 and p.nrctrseg = 497431  and p.nrdconta= 2327503;
  Update cecred.CRAWSEG p set p.VLPREMIO = 6.35   where p.NRCTRATO = 1828913 and p.nrproposta = '202319707474' and p.cdcooper = 1 and p.nrctrseg = 497431  and p.nrdconta= 850063;
  Update cecred.CRAWSEG p set p.VLPREMIO = 104.4  where p.NRCTRATO = 4643519 and p.nrproposta = '770356038193' and p.cdcooper = 1 and p.nrctrseg = 497431  and p.nrdconta= 12180920;
  
  Update cecred.CRAPSEG p set p.VLPREMIO = 2.52   where p.cdcooper  = 1 and p.nrctrseg = 1181853 and p.nrdconta= 2628040;
  Update cecred.CRAPSEG p set p.VLPREMIO = 104.4  where p.cdcooper  = 16 and p.nrctrseg = 358389 and p.nrdconta= 58858;
  Update cecred.CRAPSEG p set p.VLPREMIO = 66.03  where p.cdcooper  = 1 and p.nrctrseg = 1425719 and p.nrdconta= 7640609;
  Update cecred.CRAPSEG p set p.VLPREMIO = 69.13  where p.cdcooper  = 16 and p.nrctrseg = 352455 and p.nrdconta= 6330673;
  Update cecred.CRAPSEG p set p.VLPREMIO = 104.4  where p.cdcooper  = 1 and p.nrctrseg = 1680037 and p.nrdconta= 2738988;
  Update cecred.CRAPSEG p set p.VLPREMIO = 104.4  where p.cdcooper  = 1 and p.nrctrseg = 923093 and p.nrdconta= 3928217;
  Update cecred.CRAPSEG p set p.VLPREMIO = 104.4  where p.cdcooper  = 1 and p.nrctrseg = 1398302 and p.nrdconta= 2664259;
  Update cecred.CRAPSEG p set p.VLPREMIO = 45.58  where p.cdcooper  = 1 and p.nrctrseg = 1693819 and p.nrdconta= 4505280;
  Update cecred.CRAPSEG p set p.VLPREMIO = 1.95   where p.cdcooper  = 16 and p.nrctrseg = 398652 and p.nrdconta= 16457595;
  Update cecred.CRAPSEG p set p.VLPREMIO = 104.4  where p.cdcooper  = 1 and p.nrctrseg = 1439529 and p.nrdconta= 9020233;
  Update cecred.CRAPSEG p set p.VLPREMIO = 49.20  where p.cdcooper  = 7 and p.nrctrseg = 157176 and p.nrdconta= 308072;
  Update cecred.CRAPSEG p set p.VLPREMIO = 17.48  where p.cdcooper  = 7 and p.nrctrseg = 178793 and p.nrdconta= 18511;
  Update cecred.CRAPSEG p set p.VLPREMIO = 104.4  where p.cdcooper  = 1 and p.nrctrseg = 866143 and p.nrdconta= 648086;
  Update cecred.CRAPSEG p set p.VLPREMIO = 104.4  where p.cdcooper  = 1 and p.nrctrseg = 1267816 and p.nrdconta= 3891917;
  Update cecred.CRAPSEG p set p.VLPREMIO = 104.4  where p.cdcooper  = 1 and p.nrctrseg = 702454 and p.nrdconta= 2327503;
  Update cecred.CRAPSEG p set p.VLPREMIO = 6.35   where p.cdcooper  = 1 and p.nrctrseg = 1709091 and p.nrdconta= 850063;
  Update cecred.CRAPSEG p set p.VLPREMIO = 104.4  where p.cdcooper  = 1 and p.nrctrseg = 903460 and p.nrdconta= 12180920;

  commit;
  
  update cecred.crawseg p set p.nrproposta = '202400140285' where p.NRDCONTA = 15390772 and p.NRCTRSEG = 192184 and p.CDCOOPER = 7 and p.NRCTRATO = 126686;
  update cecred.tbseg_prestamista p set p.nrproposta = '202400140285' where  p.NRDCONTA = 15390772 and p.NRCTRSEG = 192184 and p.CDCOOPER = 7 and p.NRCTREMP = 126686; 
  
  commit;
     
  update cecred.tbseg_prestamista p set p.TPREGIST = 3, p.TPRECUSA = '', p.DTRECUSA = null, p.CDMOTREC = null, p.VLDEVATU = 230394.25 where  p.NRDCONTA = 15390772 and p.NRCTRSEG = 192184 and p.CDCOOPER = 7 and p.NRCTREMP = 126686; 
  update cecred.crapseg p set p.DTCANCEL = null, p.CDMOTCAN = 0, p.DTINSEXC = null where  p.NRDCONTA = 15390772 and p.NRCTRSEG = 192184 and p.CDCOOPER = 7;   

  commit;     
  
end;
