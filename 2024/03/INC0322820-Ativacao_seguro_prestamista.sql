begin
  update cecred.crawseg p
     set p.DTMVTOLT = to_date('01/03/2024', 'dd/mm/yyyy'),
         p.DTDEBITO = to_date('01/03/2024', 'dd/mm/yyyy'),
         p.DTPRIDEB = to_date('01/03/2024', 'dd/mm/yyyy'),
         p.DTINIVIG = to_date('01/03/2024', 'dd/mm/yyyy'),
         p.DTINISEG = to_date('01/03/2024', 'dd/mm/yyyy')
   where p.CDCOOPEr = 7
     and p.NRDCONTA = 191531
     and p.NRCTRATO = 52993
     and p.NRPROPOSTA = '202319707459';

  update cecred.crapseg p
     set p.CDSITSEG = 1,
         p.CDMOTCAN = null,
         p.DTINIVIG = to_date('01/03/2024', 'dd/mm/yyyy'),
         p.DTMVTOLT = to_date('01/03/2024', 'dd/mm/yyyy'),
         p.DTALTSEG = to_date('01/03/2024', 'dd/mm/yyyy'),
         p.DTDEBITO = to_date('01/03/2024', 'dd/mm/yyyy'),
         p.DTCANCEL = null,
         p.DTINISEG = to_date('01/03/2024', 'dd/mm/yyyy'),
         p.DTULTPAG = to_date('01/03/2024', 'dd/mm/yyyy'),
         p.DTPRIDEB = to_date('01/03/2024', 'dd/mm/yyyy'),
         p.DTINSORI = to_date('01/03/2024 07:03:44', 'dd/mm/yyyy hh24:mi:ss')
   where p.CDCOOPEr = 7
     and p.NRDCONTA = 191531
     and p.nrctrseg = 191548;

  update cecred.tbseg_prestamista p
     set p.TPREGIST = 1,
         p.DTINIVIG = to_date('01/03/2024', 'dd/mm/yyyy'),
         p.DTDEVEND = to_date('01/03/2024', 'dd/mm/yyyy'),
         p.DTREFCOB = to_date('01/03/2024', 'dd/mm/yyyy'),
         p.DTDENVIO = null
   where p.CDCOOPEr = 7
     and p.NRDCONTA = 191531
     and p.NRCTREMP = 52993
     and p.NRPROPOSTA = '202319707459';
     
  commit;
  
  delete cecred.crapseg c where c.NRDCONTA = 119172 and c.CDCOOPER = 9 and c.NRCTRSEG = 108699;
  
  commit;
  
end;
