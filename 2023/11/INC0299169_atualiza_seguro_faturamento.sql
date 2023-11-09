Declare
  pnrproposta tbseg_nrproposta.NRPROPOSTA%type;
Begin 
  update cecred.crapseg s
     set s.CDMOTCAN = 4
   where s.NRDCONTA = 16871820
     and s.CDCOOPER = 13
     and s.NRCTRSEG = 535071;

  update cecred.tbseg_prestamista p
     set p.TPREGIST = 0
   where p.NRDCONTA = 16871820
     and p.CDCOOPER = 13
     and p.NRPROPOSTA = '202316455638'
     and p.NRCTRSEG = 535071
     and p.NRCTREMP = 324226;

  update cecred.tbseg_prestamista p
     set p.TPREGIST = 0   
   where p.NRDCONTA = 7298846
     and p.CDCOOPER = 1
     and p.NRPROPOSTA = '770349780976'
     and p.NRCTRSEG = 696466
     and p.NRCTREMP = 1764489;

  SELECT p.nrproposta
    into pnrproposta
    FROM cecred.tbseg_nrproposta p
   WHERE p.dhseguro IS NULL
     AND p.tpcustei = 1
     AND rownum = 1;

  update cecred.tbseg_prestamista p
     set p.NRPROPOSTA = pnrproposta
   select p.NRPROPOSTA from tbseg_prestamista p    
   where p.NRDCONTA = 7298846
     and p.CDCOOPER = 1
     and p.NRCTRSEG = 1571215
     and p.NRCTREMP = 1764489
     and p.NRPROPOSTA = '770349780976A01';

  update cecred.crawseg w
     set w.NRPROPOSTA = pnrproposta
    select w.NRPROPOSTA from crawseg w       
   where w.NRDCONTA = 7298846
     and w.CDCOOPER = 1
     and w.NRCTRSEG = 1571215
     and w.nrctrato = 1764489
     and w.NRPROPOSTA = '770349780976A01';

  UPDATE cecred.tbseg_nrproposta
     SET dhseguro = SYSDATE
   WHERE nrproposta = pnrproposta;   

  update cecred.crapseg s 
    set s.CDMOTCAN = null
  where s.NRCTRSEG = 1463380
    and s.NRDCONTA = 10378065
    and CDCOOPER = 1;
    
  commit;    
end;
