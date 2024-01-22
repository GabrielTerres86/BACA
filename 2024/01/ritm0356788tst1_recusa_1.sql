Begin   
  update cecred.tbseg_prestamista p set  p.tpregist = 0, p.tprecusa = '8', situacao = 0,  p.dtrecusa = to_date('16/10/2023','dd/mm/yyyy'), p.cdmotrec = 126   where p.CDCOOPER = 7 and p.nrdconta = 99651815 and p.nrctremp = 117417 and p.nrctrseg = 174290;
  update cecred.crapseg p set p.cdsitseg = 5, p.dtcancel =  to_date('16/10/2023','dd/mm/yyyy') where p.CDCOOPER = 7 and p.nrdconta = 99651815 and p.nrctrseg = 174290;

  commit;
End;
