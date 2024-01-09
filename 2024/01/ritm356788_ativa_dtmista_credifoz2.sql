Begin
  update cecred.tbseg_parametros_prst p set p.dtctrmista = to_date('01/01/2024','dd/mm/yyyy') where p.CDCOOPER = 11 and p.TPCUSTEI = 1 and p.nrapolic = '000000077001236';  
  update cecred.tbseg_prestamista p set  p.tpregist = 0, p.tprecusa = '8', situacao = 0,  p.dtrecusa = to_date('04/01/2024','dd/mm/yyyy'), p.cdmotrec = 126  where p.CDCOOPER = 11 and p.nrdconta = 99579146 and p.nrctremp = 386948;
  update cecred.crapseg p set p.cdsitseg = 5, p.dtcancel =  to_date('04/01/2024','dd/mm/yyyy') where p.CDCOOPER = 11 and p.nrdconta = 99579146 and p.nrctrseg = 361717;
  
  update cecred.tbseg_prestamista p set  p.tpregist = 0, p.tprecusa = '8', situacao = 0,  p.dtrecusa = to_date('04/01/2024','dd/mm/yyyy'), p.cdmotrec = 126  where p.CDCOOPER = 11 and p.nrdconta = 99579146 and p.nrctremp = 386947 and p.nrctrseg = 361721;
  update cecred.crapseg p set p.cdsitseg = 5, p.dtcancel =  to_date('04/01/2024','dd/mm/yyyy') where p.CDCOOPER = 11 and p.nrdconta = 99579146 and p.nrctrseg = 361721;
  
  commit;
End;
