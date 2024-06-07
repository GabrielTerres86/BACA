BEGIN
  UPDATE CECRED.CRAWSEG p
     SET P.NMBAIRRO = 'SANTA ROSA DE LIMA'
   where p.CDCOOPER = 9
     and p.NRDCONTA = 500356
     and p.NRCEPEND = 91175120;
     
  UPDATE CECRED.CRAWSEG p
     SET P.NMBAIRRO = 'COLONIA DONA LUIZA'
   where p.CDCOOPER = 7
     and p.NRDCONTA = 17910714
     and p.NRCEPEND = 84045904;

  UPDATE CECRED.tbseg_prestamista p
     SET P.NMBAIRRO = 'SANTA ROSA DE LIMA'
   where p.CDCOOPER = 9
     and p.NRDCONTA = 500356
     and p.NRCEPEND = 91175120;
     
  UPDATE CECRED.tbseg_prestamista p
     SET P.NMBAIRRO = 'COLONIA DONA LUIZA'
   where p.CDCOOPER = 7
     and p.NRDCONTA = 17910714
     and p.NRCEPEND = 84045904;

  COMMIT;

  UPDATE CECRED.CRAWSEG p
     SET P.VLSEGURO                 = 474.06,
         P.DTINIVIG                 = TO_DATE('21/05/2024', 'DD/MM/YYYY'),
         P.DTDEBITO                 = TO_DATE('21/05/2024', 'DD/MM/YYYY'),
         P.DTINISEG                 = TO_DATE('21/05/2024', 'DD/MM/YYYY'),
         P.DTPRIDEB                 = TO_DATE('21/05/2024', 'DD/MM/YYYY'),
         P.FLFINANCIASEGPRESTAMISTA = 0,
         P.DTMVTOLT                 = TO_DATE('21/05/2024', 'DD/MM/YYYY')
   where P.CDCOOPER = 2
     AND P.NRDCONTA = 759970
     AND P.NRCTRSEG = 420035
     AND P.NRCTRATO = 539239
     AND p.nrproposta = '202406672145';

  UPDATE CECRED.TBSEG_PRESTAMISTA p
     SET P.VLSDEVED                 = 474.06,
         P.DTINIVIG                 = TO_DATE('21/05/2024', 'DD/MM/YYYY'),
         P.DTDEVEND                 = TO_DATE('21/05/2024', 'DD/MM/YYYY'),
         P.FLFINANCIASEGPRESTAMISTA = 0
   where P.CDCOOPER = 2
     AND P.NRDCONTA = 759970
     AND P.NRCTRSEG = 420035
     AND P.NRCTREMP = 539239
     AND p.nrproposta = '202406672145';

  UPDATE CECRED.CRAPSEG p
     SET P.vlslddev = 474.06,
         P.DTINIVIG = TO_DATE('21/05/2024', 'DD/MM/YYYY'),
         P.DTMVTOLT = TO_DATE('21/05/2024', 'DD/MM/YYYY'),
         P.DTDEBITO = TO_DATE('21/05/2024', 'DD/MM/YYYY'),
         P.DTINISEG = TO_DATE('21/05/2024', 'DD/MM/YYYY'),
         P.Dtultpag = TO_DATE('21/05/2024', 'DD/MM/YYYY'),
         p.dtprideb = TO_DATE('21/05/2024', 'DD/MM/YYYY')
   where P.CDCOOPER = 2
     AND P.NRDCONTA = 759970
     AND P.NRCTRSEG = 420035;

  COMMIT;
  
  Update cecred.CRAWSEG p set p.VLPREMIO =  66.2 where p.NRCTRATO = 6760589 and p.nrproposta = '202304351543' and p.cdcooper = 1 and p.nrctrseg = 1425719  and p.nrdconta= 7640609;
  Update cecred.CRAWSEG p set p.VLPREMIO = 104.4 where p.NRCTRATO = 6975564 and p.nrproposta = '202308546051' and p.cdcooper = 1 and p.nrctrseg = 1439529  and p.nrdconta= 9020233;
  Update cecred.CRAWSEG p set p.VLPREMIO = 46.36 where p.NRCTRATO = 7796144 and p.nrproposta = '202319679113' and p.cdcooper = 1 and p.nrctrseg = 1693819  and p.nrdconta= 4505280;
  Update cecred.CRAWSEG p set p.VLPREMIO =  9.58 where p.NRCTRATO = 1828913 and p.nrproposta = '202319707474' and p.cdcooper = 1 and p.nrctrseg = 1709091  and p.nrdconta= 850063;
  Update cecred.CRAWSEG p set p.VLPREMIO = 104.4 where p.NRCTRATO = 968466 and p.nrproposta = '770349723204' and p.cdcooper = 1  and p.nrctrseg = 702454   and p.nrdconta= 2327503;
  Update cecred.CRAWSEG p set p.VLPREMIO = 104.4 where p.NRCTRATO = 4996320 and p.nrproposta = '770355636038' and p.cdcooper = 1 and p.nrctrseg = 923093   and p.nrdconta= 3928217;
  Update cecred.CRAWSEG p set p.VLPREMIO = 104.4 where p.NRCTRATO = 4643519 and p.nrproposta = '770356038193' and p.cdcooper = 1 and p.nrctrseg = 903460   and p.nrdconta= 12180920;
  Update cecred.CRAWSEG p set p.VLPREMIO = 104.4 where p.NRCTRATO = 4667762 and p.nrproposta = '770356997972' and p.cdcooper = 1 and p.nrctrseg = 866143   and p.nrdconta= 648086;
  Update cecred.CRAWSEG p set p.VLPREMIO =  3.37 where p.NRCTRATO = 5743822 and p.nrproposta = '770656107456' and p.cdcooper = 1 and p.nrctrseg = 1181853  and p.nrdconta= 2628040;
  Update cecred.CRAWSEG p set p.VLPREMIO = 104.4 where p.NRCTRATO = 6016942 and p.nrproposta = '770658862880' and p.cdcooper = 1 and p.nrctrseg = 1267816  and p.nrdconta= 3891917;
  Update cecred.CRAWSEG p set p.VLPREMIO = 50.50 where p.NRCTRATO = 107766 and p.nrproposta = '202304262311' and p.cdcooper = 1  and p.nrctrseg = 157176   and p.nrdconta= 308072;
  Update cecred.CRAWSEG p set p.VLPREMIO = 19.53 where p.NRCTRATO = 119957 and p.nrproposta = '202315154752' and p.cdcooper = 1  and p.nrctrseg = 178793   and p.nrdconta= 18511;
  Update cecred.CRAWSEG p set p.VLPREMIO = 69.36 where p.NRCTRATO = 727589 and p.nrproposta = '202308532139' and p.cdcooper = 1  and p.nrctrseg = 352455   and p.nrdconta= 6330673;
  Update cecred.CRAWSEG p set p.VLPREMIO = 104.4 where p.NRCTRATO = 757974 and p.nrproposta = '202315153011' and p.cdcooper = 1  and p.nrctrseg = 371642   and p.nrdconta= 143090;
  Update cecred.CRAWSEG p set p.VLPREMIO = 104.4 where p.NRCTRATO = 738558 and p.nrproposta = '202315165461' and p.cdcooper = 1  and p.nrctrseg = 358389   and p.nrdconta= 58858;
  Update cecred.CRAWSEG p set p.VLPREMIO =  6.98 where p.NRCTRATO = 758680 and p.nrproposta = '202319707457' and p.cdcooper = 1  and p.nrctrseg = 398652   and p.nrdconta= 16457595;
   
  Update cecred.tbseg_prestamista p set p.VLPRODUT =  66.2 where p.NRCTREMP = 6760589 and p.nrproposta = '202304351543' and p.cdcooper = 1 and p.nrctrseg = 1425719 and p.nrdconta = 7640609;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 104.4 where p.NRCTREMP = 6975564 and p.nrproposta = '202308546051' and p.cdcooper = 1 and p.nrctrseg = 1439529 and p.nrdconta = 9020233;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 46.36 where p.NRCTREMP = 7796144 and p.nrproposta = '202319679113' and p.cdcooper = 1 and p.nrctrseg = 1693819 and p.nrdconta = 4505280;
  Update cecred.tbseg_prestamista p set p.VLPRODUT =  9.58 where p.NRCTREMP = 1828913 and p.nrproposta = '202319707474' and p.cdcooper = 1 and p.nrctrseg = 1709091 and p.nrdconta = 850063;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 104.4 where p.NRCTREMP = 968466 and p.nrproposta = '770349723204' and p.cdcooper = 1 and p.nrctrseg = 702454 and p.nrdconta = 2327503;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 104.4 where p.NRCTREMP = 4996320 and p.nrproposta = '770355636038' and p.cdcooper = 1 and p.nrctrseg = 923093 and p.nrdconta = 3928217;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 104.4 where p.NRCTREMP = 4643519 and p.nrproposta = '770356038193' and p.cdcooper = 1 and p.nrctrseg = 903460 and p.nrdconta = 12180920;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 104.4 where p.NRCTREMP = 4667762 and p.nrproposta = '770356997972' and p.cdcooper = 1 and p.nrctrseg = 866143 and p.nrdconta = 648086;
  Update cecred.tbseg_prestamista p set p.VLPRODUT =  3.37 where p.NRCTREMP = 5743822 and p.nrproposta = '770656107456' and p.cdcooper = 1 and p.nrctrseg = 1181853 and p.nrdconta = 2628040;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 104.4 where p.NRCTREMP = 6016942 and p.nrproposta = '770658862880' and p.cdcooper = 1 and p.nrctrseg = 1267816 and p.nrdconta = 3891917;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 50.50 where p.NRCTREMP = 107766 and p.nrproposta = '202304262311' and p.cdcooper = 7 and p.nrctrseg = 157176 and p.nrdconta = 308072;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 19.53 where p.NRCTREMP = 119957 and p.nrproposta = '202315154752' and p.cdcooper = 7 and p.nrctrseg = 178793 and p.nrdconta = 18511;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 69.36 where p.NRCTREMP = 727589 and p.nrproposta = '202308532139' and p.cdcooper = 16 and p.nrctrseg = 352455 and p.nrdconta = 6330673;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 104.4 where p.NRCTREMP = 757974 and p.nrproposta = '202315153011' and p.cdcooper = 16 and p.nrctrseg = 371642 and p.nrdconta = 143090;
  Update cecred.tbseg_prestamista p set p.VLPRODUT = 104.4 where p.NRCTREMP = 738558 and p.nrproposta = '202315165461' and p.cdcooper = 16 and p.nrctrseg = 358389 and p.nrdconta = 58858;
  Update cecred.tbseg_prestamista p set p.VLPRODUT =  6.98 where p.NRCTREMP = 758680 and p.nrproposta = '202319707457' and p.cdcooper = 16 and p.nrctrseg = 398652 and p.nrdconta = 16457595;
    
  Update cecred.CRAPSEG p set p.VLPREMIO =  66.2 where p.cdcooper  = 1 and p.nrctrseg = 1425719 and p.nrdconta= 7640609;
  Update cecred.CRAPSEG p set p.VLPREMIO = 104.4 where p.cdcooper  = 1 and p.nrctrseg = 1439529 and p.nrdconta= 9020233;
  Update cecred.CRAPSEG p set p.VLPREMIO = 46.36 where p.cdcooper  = 1 and p.nrctrseg = 1693819 and p.nrdconta= 4505280;
  Update cecred.CRAPSEG p set p.VLPREMIO =  9.58 where p.cdcooper  = 1 and p.nrctrseg = 1709091 and p.nrdconta= 850063;
  Update cecred.CRAPSEG p set p.VLPREMIO = 104.4 where p.cdcooper  = 1 and p.nrctrseg = 702454 and p.nrdconta= 2327503;
  Update cecred.CRAPSEG p set p.VLPREMIO = 104.4 where p.cdcooper  = 1 and p.nrctrseg = 923093 and p.nrdconta= 3928217;
  Update cecred.CRAPSEG p set p.VLPREMIO = 104.4 where p.cdcooper  = 1 and p.nrctrseg = 903460 and p.nrdconta= 12180920;
  Update cecred.CRAPSEG p set p.VLPREMIO = 104.4 where p.cdcooper  = 1 and p.nrctrseg = 866143 and p.nrdconta= 648086;
  Update cecred.CRAPSEG p set p.VLPREMIO =  3.37 where p.cdcooper  = 1 and p.nrctrseg = 1181853 and p.nrdconta= 2628040;
  Update cecred.CRAPSEG p set p.VLPREMIO = 104.4 where p.cdcooper  = 1 and p.nrctrseg = 1267816 and p.nrdconta= 3891917;
  Update cecred.CRAPSEG p set p.VLPREMIO = 50.50 where p.cdcooper  = 7 and p.nrctrseg = 157176 and p.nrdconta= 308072;
  Update cecred.CRAPSEG p set p.VLPREMIO = 19.53 where p.cdcooper  = 7 and p.nrctrseg = 178793 and p.nrdconta= 18511;
  Update cecred.CRAPSEG p set p.VLPREMIO = 69.36 where p.cdcooper  = 16 and p.nrctrseg = 352455 and p.nrdconta= 6330673;
  Update cecred.CRAPSEG p set p.VLPREMIO = 104.4 where p.cdcooper  = 16 and p.nrctrseg = 371642 and p.nrdconta= 143090;
  Update cecred.CRAPSEG p set p.VLPREMIO = 104.4 where p.cdcooper  = 16 and p.nrctrseg = 358389 and p.nrdconta= 58858;
  Update cecred.CRAPSEG p set p.VLPREMIO =  6.98 where p.cdcooper  = 16 and p.nrctrseg = 398652 and p.nrdconta= 16457595;
  
  COMMIT;

END;
